import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/enhanced_order.dart';
import '../database/backend_api.dart';
import '../notifications/supabase_notification_service.dart';

/// Service für Order Tracking Management mit Real-Time Updates
/// Verwaltet Tracking-Nummern, Status-Updates und Benachrichtigungen
class OrderTrackingService {
  final BackendApiService _backendApi;
  final SupabaseNotificationService _notificationService;
  final SupabaseClient _supabaseClient;

  OrderTrackingService({
    required BackendApiService backendApi,
    required SupabaseNotificationService notificationService,
    SupabaseClient? supabaseClient,
  })  : _backendApi = backendApi,
        _notificationService = notificationService,
        _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Assign tracking number to an enhanced order
  Future<EnhancedOrder> assignTrackingNumber({
    required int orderId,
    required String trackingNumber,
    required String shippingCarrier,
    String? shippingService,
    DateTime? estimatedDelivery,
  }) async {
    try {
      dev.log('📦 Assigning tracking number $trackingNumber to order $orderId');

      // Validate tracking number format
      _validateTrackingNumber(trackingNumber, shippingCarrier);

      // Update order with tracking information and mark as shipped
      final updatedOrder = await _backendApi.updateEnhancedOrderStatus(
        orderId: orderId,
        newStatus: 'shipped',
        trackingNumber: trackingNumber,
        shippingCarrier: shippingCarrier,
        estimatedDelivery: estimatedDelivery,
        metadata: {
          'tracking_assigned_at': DateTime.now().toIso8601String(),
          'tracking_assigned_by': 'system',
          'shipping_service': shippingService,
        },
      );

      // Send notification to customer
      await _notificationService.sendOrderTrackingNotification(
        customerId: updatedOrder.customerId,
        orderId: orderId,
        orderNumber: updatedOrder.orderNumber,
        trackingNumber: trackingNumber,
        shippingCarrier: shippingCarrier,
        estimatedDelivery: estimatedDelivery,
      );

      dev.log('✅ Tracking number assigned and customer notified');
      return updatedOrder;

    } catch (e) {
      dev.log('❌ Error assigning tracking number: $e', error: e);
      throw Exception('Failed to assign tracking number: $e');
    }
  }

  /// Update tracking status (usually called by shipping carrier webhooks)
  Future<EnhancedOrder> updateTrackingStatus({
    required String trackingNumber,
    required String newStatus,
    String? statusDescription,
    String? location,
    DateTime? timestamp,
    Map<String, dynamic>? carrierData,
  }) async {
    try {
      dev.log('🔄 Updating tracking status for $trackingNumber to $newStatus');

      // Find order by tracking number
      final orders = await _supabaseClient
          .from('enhanced_orders')
          .select()
          .eq('tracking_number', trackingNumber)
          .limit(1);

      if (orders.isEmpty) {
        throw Exception('No order found with tracking number $trackingNumber');
      }

      final orderData = orders.first;
      final orderId = orderData['id'] as int;

      // Map carrier status to our order status
      final orderStatus = _mapCarrierStatusToOrderStatus(newStatus);

      // Update order status
      final updatedOrder = await _backendApi.updateEnhancedOrderStatus(
        orderId: orderId,
        newStatus: orderStatus,
        metadata: {
          'last_tracking_update': DateTime.now().toIso8601String(),
          'carrier_status': newStatus,
          'carrier_description': statusDescription,
          'last_known_location': location,
          'carrier_timestamp': timestamp?.toIso8601String(),
          'carrier_data': carrierData,
        },
      );

      // Send real-time notification for significant status changes
      if (_isSignificantStatusChange(orderStatus)) {
        await _notificationService.sendOrderStatusChangeNotification(
          customerId: updatedOrder.customerId,
          orderId: orderId,
          orderNumber: updatedOrder.orderNumber,
          newStatus: orderStatus,
          statusDescription: statusDescription,
          trackingNumber: trackingNumber,
        );
      }

      dev.log('✅ Tracking status updated and notifications sent');
      return updatedOrder;

    } catch (e) {
      dev.log('❌ Error updating tracking status: $e', error: e);
      throw Exception('Failed to update tracking status: $e');
    }
  }

  /// Mark order as out for delivery
  Future<EnhancedOrder> markOutForDelivery({
    required int orderId,
    DateTime? estimatedDeliveryTime,
    String? deliveryInstructions,
    String? courierName,
    String? courierPhone,
  }) async {
    try {
      dev.log('🚛 Marking order $orderId as out for delivery');

      final updatedOrder = await _backendApi.updateEnhancedOrderStatus(
        orderId: orderId,
        newStatus: 'outForDelivery',
        estimatedDelivery: estimatedDeliveryTime,
        metadata: {
          'out_for_delivery_at': DateTime.now().toIso8601String(),
          'delivery_instructions': deliveryInstructions,
          'courier_name': courierName,
          'courier_phone': courierPhone,
        },
      );

      // Send urgent notification - delivery today
      await _notificationService.sendOrderOutForDeliveryNotification(
        customerId: updatedOrder.customerId,
        orderId: orderId,
        orderNumber: updatedOrder.orderNumber,
        estimatedDeliveryTime: estimatedDeliveryTime,
        courierName: courierName,
        courierPhone: courierPhone,
      );

      dev.log('✅ Order marked as out for delivery and customer notified');
      return updatedOrder;

    } catch (e) {
      dev.log('❌ Error marking order out for delivery: $e', error: e);
      throw Exception('Failed to mark order out for delivery: $e');
    }
  }

  /// Mark order as delivered
  Future<EnhancedOrder> markDelivered({
    required int orderId,
    DateTime? deliveryTime,
    String? deliveryLocation,
    String? recipientName,
    String? deliveryProofUrl, // Image URL of delivery confirmation
    String? deliveryNotes,
  }) async {
    try {
      dev.log('✅ Marking order $orderId as delivered');

      final updatedOrder = await _backendApi.updateEnhancedOrderStatus(
        orderId: orderId,
        newStatus: 'delivered',
        metadata: {
          'delivered_at': (deliveryTime ?? DateTime.now()).toIso8601String(),
          'delivery_location': deliveryLocation,
          'recipient_name': recipientName,
          'delivery_proof_url': deliveryProofUrl,
          'delivery_notes': deliveryNotes,
        },
      );

      // Send delivery confirmation
      await _notificationService.sendOrderDeliveredNotification(
        customerId: updatedOrder.customerId,
        orderId: orderId,
        orderNumber: updatedOrder.orderNumber,
        deliveryTime: deliveryTime ?? DateTime.now(),
        recipientName: recipientName,
        deliveryProofUrl: deliveryProofUrl,
      );

      dev.log('✅ Order marked as delivered and customer notified');
      return updatedOrder;

    } catch (e) {
      dev.log('❌ Error marking order as delivered: $e', error: e);
      throw Exception('Failed to mark order as delivered: $e');
    }
  }

  /// Get real-time tracking information for an order
  Future<Map<String, dynamic>> getTrackingInformation(int orderId) async {
    try {
      dev.log('🔍 Getting tracking information for order $orderId');

      final order = await _backendApi.getEnhancedOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      if (order.trackingNumber == null || order.shippingCarrier == null) {
        return {
          'hasTracking': false,
          'status': order.status.name,
          'message': 'Tracking information not yet available',
        };
      }

      // Get carrier-specific tracking details
      final trackingDetails = await _getCarrierTrackingDetails(
        order.trackingNumber!,
        order.shippingCarrier!,
      );

      // Get status history
      final statusHistory = await _backendApi.getOrderStatusHistory(orderId);

      return {
        'hasTracking': true,
        'trackingNumber': order.trackingNumber,
        'shippingCarrier': order.shippingCarrier,
        'trackingUrl': order.trackingUrl,
        'currentStatus': order.status.name,
        'estimatedDelivery': order.estimatedDelivery?.toIso8601String(),
        'trackingDetails': trackingDetails,
        'statusHistory': statusHistory.map((h) => h.toJson()).toList(),
        'lastUpdated': order.updatedAt?.toIso8601String(),
      };

    } catch (e) {
      dev.log('❌ Error getting tracking information: $e', error: e);
      throw Exception('Failed to get tracking information: $e');
    }
  }

  /// Setup real-time tracking updates subscription
  Stream<Map<String, dynamic>> trackOrderRealTime(int orderId) {
    dev.log('📡 Setting up real-time tracking for order $orderId');

    return _supabaseClient
        .from('enhanced_orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) {
          if (data.isEmpty) {
            return {
              'status': 'error',
              'message': 'Order not found',
            };
          }

          final orderData = data.first;
          return {
            'status': 'success',
            'orderId': orderId,
            'orderStatus': orderData['status'],
            'trackingNumber': orderData['tracking_number'],
            'lastUpdated': orderData['updated_at'],
            'estimatedDelivery': orderData['estimated_delivery'],
            'metadata': orderData['metadata'],
          };
        });
  }

  /// Batch update multiple orders from carrier webhook
  Future<void> batchUpdateTrackingStatus(List<Map<String, dynamic>> updates) async {
    try {
      dev.log('📦 Processing batch tracking update for ${updates.length} orders');

      for (final update in updates) {
        try {
          await updateTrackingStatus(
            trackingNumber: update['trackingNumber'],
            newStatus: update['status'],
            statusDescription: update['description'],
            location: update['location'],
            timestamp: update['timestamp'] != null 
                ? DateTime.parse(update['timestamp'])
                : null,
            carrierData: update['carrierData'],
          );
        } catch (e) {
          dev.log('⚠️ Warning: Failed to update tracking for ${update['trackingNumber']}: $e');
          // Continue with other updates
        }
      }

      dev.log('✅ Batch tracking update completed');

    } catch (e) {
      dev.log('❌ Error in batch tracking update: $e', error: e);
      throw Exception('Failed to process batch tracking update: $e');
    }
  }

  /// Validate tracking number format for different carriers
  void _validateTrackingNumber(String trackingNumber, String carrier) {
    final cleanTrackingNumber = trackingNumber.trim().toUpperCase();
    
    switch (carrier.toUpperCase()) {
      case 'DHL_EXPRESS':
      case 'DHL_PAKET':
        if (!RegExp(r'^[0-9]{10}$|^[0-9]{11}$|^JD[0-9]{18}$').hasMatch(cleanTrackingNumber)) {
          throw ArgumentError('Invalid DHL tracking number format');
        }
        break;
      case 'UPS':
        if (!RegExp(r'^1Z[A-Z0-9]{16}$|^[TH][0-9]{10}$').hasMatch(cleanTrackingNumber)) {
          throw ArgumentError('Invalid UPS tracking number format');
        }
        break;
      case 'FEDEX':
        if (!RegExp(r'^[0-9]{12}$|^[0-9]{14}$|^96[0-9]{20}$').hasMatch(cleanTrackingNumber)) {
          throw ArgumentError('Invalid FedEx tracking number format');
        }
        break;
      // Add more carrier validations as needed
    }
  }

  /// Map carrier-specific status to our order status
  String _mapCarrierStatusToOrderStatus(String carrierStatus) {
    switch (carrierStatus.toLowerCase()) {
      case 'shipped':
      case 'in_transit':
      case 'picked_up':
        return 'shipped';
      case 'out_for_delivery':
      case 'on_vehicle':
        return 'outForDelivery';
      case 'delivered':
      case 'completed':
        return 'delivered';
      case 'exception':
      case 'failed_delivery':
        return 'processing'; // Keep in processing for exception handling
      default:
        return 'shipped'; // Default to shipped for unknown statuses
    }
  }

  /// Check if status change is significant enough to notify customer
  bool _isSignificantStatusChange(String status) {
    return ['shipped', 'outForDelivery', 'delivered'].contains(status);
  }

  /// Get carrier-specific tracking details (placeholder for carrier API integration)
  Future<Map<String, dynamic>> _getCarrierTrackingDetails(
    String trackingNumber,
    String carrier,
  ) async {
    // This would integrate with actual carrier APIs in production
    // For now, return basic information
    return {
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'events': [
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'status': 'In Transit',
          'location': 'Sorting Facility',
          'description': 'Package is in transit to destination',
        }
      ],
      'estimatedDelivery': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    };
  }
}

/// Factory for creating OrderTrackingService instances
class OrderTrackingServiceFactory {
  static OrderTrackingService create({
    BackendApiService? backendApi,
    SupabaseNotificationService? notificationService,
    SupabaseClient? supabaseClient,
  }) {
    return OrderTrackingService(
      backendApi: backendApi ?? BackendApiService(),
      notificationService: notificationService ?? SupabaseNotificationService(),
      supabaseClient: supabaseClient,
    );
  }
}