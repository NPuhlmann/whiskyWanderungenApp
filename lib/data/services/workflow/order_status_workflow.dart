import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/enhanced_order.dart';
import '../database/backend_api.dart';
import '../notifications/supabase_notification_service.dart';
import '../tracking/order_tracking_service.dart';

/// Service für Order Status Workflows und Transition Management
/// Verwaltet Status-Übergänge, Validierung und Business Rules
class OrderStatusWorkflow {
  final BackendApiService _backendApi;
  final SupabaseNotificationService _notificationService;
  final OrderTrackingService _trackingService;

  OrderStatusWorkflow({
    required BackendApiService backendApi,
    required SupabaseNotificationService notificationService,
    required OrderTrackingService trackingService,
  }) : _backendApi = backendApi,
       _notificationService = notificationService,
       _trackingService = trackingService;

  /// Validate if status transition is allowed
  bool canTransitionTo(EnhancedOrderStatus from, EnhancedOrderStatus to) {
    // Define allowed transitions
    const allowedTransitions = <EnhancedOrderStatus, List<EnhancedOrderStatus>>{
      EnhancedOrderStatus.pending: [
        EnhancedOrderStatus.paymentPending,
        EnhancedOrderStatus.confirmed,
        EnhancedOrderStatus.cancelled,
        EnhancedOrderStatus.failed,
      ],
      EnhancedOrderStatus.paymentPending: [
        EnhancedOrderStatus.confirmed,
        EnhancedOrderStatus.failed,
        EnhancedOrderStatus.cancelled,
      ],
      EnhancedOrderStatus.confirmed: [
        EnhancedOrderStatus.processing,
        EnhancedOrderStatus.cancelled,
        EnhancedOrderStatus.refunded,
      ],
      EnhancedOrderStatus.processing: [
        EnhancedOrderStatus.shipped,
        EnhancedOrderStatus.cancelled,
        EnhancedOrderStatus.failed,
      ],
      EnhancedOrderStatus.shipped: [
        EnhancedOrderStatus.outForDelivery,
        EnhancedOrderStatus.delivered,
        EnhancedOrderStatus.failed, // Lost package
      ],
      EnhancedOrderStatus.outForDelivery: [
        EnhancedOrderStatus.delivered,
        EnhancedOrderStatus.failed, // Delivery failed
      ],
      EnhancedOrderStatus.delivered: [
        EnhancedOrderStatus.refunded, // Customer return
      ],
      // Terminal states (no further transitions)
      EnhancedOrderStatus.cancelled: [],
      EnhancedOrderStatus.refunded: [],
      EnhancedOrderStatus.failed: [
        EnhancedOrderStatus.processing, // Retry processing
        EnhancedOrderStatus.cancelled,
      ],
    };

    return allowedTransitions[from]?.contains(to) ?? false;
  }

  /// Execute status transition with all business logic
  Future<EnhancedOrder> transitionOrderStatus({
    required int orderId,
    required EnhancedOrderStatus toStatus,
    String? reason,
    String? notes,
    Map<String, dynamic>? transitionData,
    String? userId, // User performing the transition
  }) async {
    try {
      dev.log(
        '🔄 Processing status transition for order $orderId to ${toStatus.name}',
      );

      // Get current order
      final currentOrder = await _backendApi.getEnhancedOrderById(orderId);
      if (currentOrder == null) {
        throw Exception('Order $orderId not found');
      }

      final fromStatus = currentOrder.status;

      // Validate transition
      if (!canTransitionTo(fromStatus, toStatus)) {
        throw Exception(
          'Invalid status transition: ${fromStatus.name} -> ${toStatus.name}',
        );
      }

      // Execute pre-transition business logic
      await _executePreTransitionLogic(currentOrder, toStatus, transitionData);

      // Update order status
      final updatedOrder = await _backendApi.updateEnhancedOrderStatus(
        orderId: orderId,
        newStatus: toStatus.name,
        reason: reason ?? _getDefaultTransitionReason(fromStatus, toStatus),
        notes: notes,
        metadata: {
          'status_transition': {
            'from': fromStatus.name,
            'to': toStatus.name,
            'timestamp': DateTime.now().toIso8601String(),
            'triggered_by': userId ?? 'system',
            'reason': reason,
            'notes': notes,
          },
          ...?transitionData,
        },
      );

      // Execute post-transition business logic
      await _executePostTransitionLogic(updatedOrder, fromStatus, toStatus);

      dev.log(
        '✅ Order $orderId status transitioned: ${fromStatus.name} -> ${toStatus.name}',
      );
      return updatedOrder;
    } catch (e) {
      dev.log('❌ Error transitioning order status: $e', error: e);
      throw Exception('Failed to transition order status: $e');
    }
  }

  /// Execute business logic before status transition
  Future<void> _executePreTransitionLogic(
    EnhancedOrder order,
    EnhancedOrderStatus toStatus,
    Map<String, dynamic>? transitionData,
  ) async {
    switch (toStatus) {
      case EnhancedOrderStatus.confirmed:
        await _handleOrderConfirmation(order, transitionData);
        break;
      case EnhancedOrderStatus.processing:
        await _handleOrderProcessing(order, transitionData);
        break;
      case EnhancedOrderStatus.shipped:
        await _handleOrderShipped(order, transitionData);
        break;
      case EnhancedOrderStatus.outForDelivery:
        await _handleOrderOutForDelivery(order, transitionData);
        break;
      case EnhancedOrderStatus.delivered:
        await _handleOrderDelivered(order, transitionData);
        break;
      case EnhancedOrderStatus.cancelled:
        await _handleOrderCancellation(order, transitionData);
        break;
      case EnhancedOrderStatus.refunded:
        await _handleOrderRefund(order, transitionData);
        break;
      case EnhancedOrderStatus.failed:
        await _handleOrderFailure(order, transitionData);
        break;
      default:
        // No special logic required
        break;
    }
  }

  /// Execute business logic after status transition
  Future<void> _executePostTransitionLogic(
    EnhancedOrder order,
    EnhancedOrderStatus fromStatus,
    EnhancedOrderStatus toStatus,
  ) async {
    // Send notifications for significant status changes
    final significantChanges = [
      EnhancedOrderStatus.confirmed,
      EnhancedOrderStatus.shipped,
      EnhancedOrderStatus.outForDelivery,
      EnhancedOrderStatus.delivered,
      EnhancedOrderStatus.cancelled,
      EnhancedOrderStatus.refunded,
    ];

    if (significantChanges.contains(toStatus)) {
      await _notificationService.sendOrderStatusChangeNotification(
        customerId: order.userId,
        orderId: order.id,
        orderNumber: order.orderNumber,
        newStatus: toStatus.name,
        trackingNumber: order.trackingNumber,
      );
    }

    // Schedule follow-up actions if needed
    await _scheduleFollowUpActions(order, toStatus);
  }

  /// Handle order confirmation logic
  Future<void> _handleOrderConfirmation(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('💰 Processing order confirmation for ${order.orderNumber}');

    // Validate payment information
    if (data?['payment_intent_id'] == null) {
      throw Exception('Payment intent ID required for order confirmation');
    }

    // Reserve inventory (if applicable)
    await _reserveHikeCapacity(order.hikeId);

    // Schedule processing
    await _scheduleOrderProcessing(order.id);
  }

  /// Handle order processing logic
  Future<void> _handleOrderProcessing(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('⚙️ Processing order ${order.orderNumber}');

    // Verify inventory availability, prepare items for shipping, generate
    // shipping labels, etc. Placeholder until the warehouse/fulfillment
    // integration lands.
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing
  }

  /// Handle order shipped logic
  Future<void> _handleOrderShipped(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('📦 Processing order shipment for ${order.orderNumber}');

    // Validate tracking information
    final trackingNumber = data?['tracking_number'] as String?;
    final shippingCarrier = data?['shipping_carrier'] as String?;

    if (trackingNumber == null || shippingCarrier == null) {
      throw Exception(
        'Tracking number and shipping carrier required for shipment',
      );
    }

    // Use tracking service to handle shipment
    await _trackingService.assignTrackingNumber(
      orderId: order.id,
      trackingNumber: trackingNumber,
      shippingCarrier: shippingCarrier,
      shippingService: data!['shipping_service'] as String?,
      estimatedDelivery: data['estimated_delivery'] != null
          ? DateTime.parse(data['estimated_delivery'])
          : null,
    );
  }

  /// Handle out for delivery logic
  Future<void> _handleOrderOutForDelivery(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('🚛 Processing out for delivery for ${order.orderNumber}');

    await _trackingService.markOutForDelivery(
      orderId: order.id,
      estimatedDeliveryTime: data?['estimated_delivery_time'] != null
          ? DateTime.parse(data!['estimated_delivery_time'])
          : null,
      deliveryInstructions: data?['delivery_instructions'] as String?,
      courierName: data?['courier_name'] as String?,
      courierPhone: data?['courier_phone'] as String?,
    );
  }

  /// Handle order delivered logic
  Future<void> _handleOrderDelivered(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('✅ Processing order delivery for ${order.orderNumber}');

    await _trackingService.markDelivered(
      orderId: order.id,
      deliveryTime: data?['delivery_time'] != null
          ? DateTime.parse(data!['delivery_time'])
          : null,
      deliveryLocation: data?['delivery_location'] as String?,
      recipientName: data?['recipient_name'] as String?,
      deliveryProofUrl: data?['delivery_proof_url'] as String?,
      deliveryNotes: data?['delivery_notes'] as String?,
    );

    // Complete the order lifecycle
    await _completeOrderLifecycle(order);
  }

  /// Handle order cancellation logic
  Future<void> _handleOrderCancellation(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('❌ Processing order cancellation for ${order.orderNumber}');

    final cancellationReason =
        data?['cancellation_reason'] as String? ?? 'Customer request';

    // Release reserved inventory
    await _releaseHikeCapacity(order.hikeId);

    // Process refund if payment was completed
    if (order.status == EnhancedOrderStatus.confirmed ||
        order.status == EnhancedOrderStatus.processing) {
      await _processRefund(order, cancellationReason);
    }

    // Cancel any active shipping
    if (order.trackingNumber != null) {
      await _cancelShipping(order.trackingNumber!, order.shippingService);
    }
  }

  /// Handle order refund logic
  Future<void> _handleOrderRefund(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('💸 Processing refund for ${order.orderNumber}');

    final refundReason = data?['refund_reason'] as String? ?? 'Customer return';
    final refundAmount = data?['refund_amount'] as double? ?? order.totalAmount;

    await _processRefund(order, refundReason, refundAmount);
  }

  /// Handle order failure logic
  Future<void> _handleOrderFailure(
    EnhancedOrder order,
    Map<String, dynamic>? data,
  ) async {
    dev.log('⚠️ Processing order failure for ${order.orderNumber}');

    final failureReason = data?['failure_reason'] as String? ?? 'Unknown error';

    // Log failure for analysis
    await _logOrderFailure(order, failureReason);

    // Notify support team
    await _notifySupportTeam(order, failureReason);

    // Attempt automatic recovery if possible
    if (_canAttemptRecovery(failureReason)) {
      await _scheduleRecoveryAttempt(order.id, failureReason);
    }
  }

  /// Get default transition reason
  String _getDefaultTransitionReason(
    EnhancedOrderStatus from,
    EnhancedOrderStatus to,
  ) {
    return 'Status changed from ${from.name} to ${to.name}';
  }

  /// Schedule follow-up actions based on status
  Future<void> _scheduleFollowUpActions(
    EnhancedOrder order,
    EnhancedOrderStatus status,
  ) async {
    switch (status) {
      case EnhancedOrderStatus.shipped:
        // Schedule delivery reminder
        await _scheduleDeliveryReminder(order.id, const Duration(days: 2));
        break;
      case EnhancedOrderStatus.delivered:
        // Schedule review request
        await _scheduleReviewRequest(order.id, const Duration(days: 3));
        break;
      case EnhancedOrderStatus.processing:
        // Schedule processing timeout check
        await _scheduleProcessingTimeoutCheck(
          order.id,
          const Duration(days: 3),
        );
        break;
      default:
        // No follow-up actions needed
        break;
    }
  }

  // ================================
  // Helper Methods (Placeholder implementations)
  // ================================

  Future<void> _reserveHikeCapacity(int hikeId) async {
    // Implement inventory reservation logic
    dev.log('📝 Reserving capacity for hike $hikeId');
  }

  Future<void> _releaseHikeCapacity(int hikeId) async {
    // Implement inventory release logic
    dev.log('🔓 Releasing capacity for hike $hikeId');
  }

  Future<void> _scheduleOrderProcessing(int orderId) async {
    // Schedule order for processing (could use job queue)
    dev.log('⏰ Scheduling processing for order $orderId');
  }

  Future<void> _processRefund(
    EnhancedOrder order,
    String reason, [
    double? amount,
  ]) async {
    // Implement refund processing with payment gateway
    dev.log('💰 Processing refund for ${order.orderNumber}: $reason');
  }

  Future<void> _cancelShipping(String trackingNumber, String? carrier) async {
    // Cancel shipping with carrier API
    dev.log('📦 Cancelling shipping: $trackingNumber');
  }

  Future<void> _completeOrderLifecycle(EnhancedOrder order) async {
    // Complete order lifecycle (analytics, cleanup, etc.)
    dev.log('🏁 Completing lifecycle for ${order.orderNumber}');
  }

  Future<void> _logOrderFailure(EnhancedOrder order, String reason) async {
    // Log failure for analysis
    dev.log('📝 Logging failure for ${order.orderNumber}: $reason');
  }

  Future<void> _notifySupportTeam(EnhancedOrder order, String reason) async {
    // Notify support team of order failure
    dev.log('📧 Notifying support team about ${order.orderNumber}: $reason');
  }

  bool _canAttemptRecovery(String failureReason) {
    // Determine if automatic recovery is possible
    return ![
      'payment_declined',
      'fraud_detected',
      'address_invalid',
    ].contains(failureReason);
  }

  Future<void> _scheduleRecoveryAttempt(int orderId, String reason) async {
    // Schedule automatic recovery attempt
    dev.log('🔄 Scheduling recovery attempt for order $orderId');
  }

  Future<void> _scheduleDeliveryReminder(int orderId, Duration delay) async {
    // Schedule delivery reminder notification
    dev.log('⏰ Scheduling delivery reminder for order $orderId');
  }

  Future<void> _scheduleReviewRequest(int orderId, Duration delay) async {
    // Schedule review request email/notification
    dev.log('⭐ Scheduling review request for order $orderId');
  }

  Future<void> _scheduleProcessingTimeoutCheck(
    int orderId,
    Duration delay,
  ) async {
    // Schedule check for processing timeout
    dev.log('⏱️ Scheduling timeout check for order $orderId');
  }
}

/// Factory for creating OrderStatusWorkflow instances
class OrderStatusWorkflowFactory {
  static OrderStatusWorkflow create({
    BackendApiService? backendApi,
    SupabaseNotificationService? notificationService,
    OrderTrackingService? trackingService,
  }) {
    final api = backendApi ?? BackendApiService();
    return OrderStatusWorkflow(
      backendApi: api,
      notificationService:
          notificationService ??
          SupabaseNotificationService(Supabase.instance.client),
      trackingService:
          trackingService ??
          OrderTrackingServiceFactory.create(backendApi: api),
    );
  }
}
