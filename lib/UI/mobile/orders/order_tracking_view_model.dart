import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/models/enhanced_order.dart';
import '../../../domain/models/basic_order.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/services/payment/stripe_service.dart';

/// ViewModel for managing order tracking state and business logic
class OrderTrackingViewModel extends ChangeNotifier {
  final int orderId;
  final bool useEnhancedOrder;
  final PaymentRepository _paymentRepository;

  OrderTrackingViewModel({
    required this.orderId,
    this.useEnhancedOrder = true,
    PaymentRepository? paymentRepository,
  }) : _paymentRepository = paymentRepository ?? PaymentRepository(
          supabaseClient: Supabase.instance.client,
          stripeService: StripeService.instance,
        );

  // State variables
  bool _isLoading = true;
  String? _error;
  BasicOrder? _order;
  EnhancedOrder? _enhancedOrder;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  BasicOrder? get order => _order;
  EnhancedOrder? get enhancedOrder => _enhancedOrder;

  /// Initialize the view model and load order data
  Future<void> initialize() async {
    await _loadOrder();
  }

  /// Load order data from the repository
  Future<void> _loadOrder() async {
    try {
      _setLoading(true);
      _clearError();

      if (useEnhancedOrder) {
        await _loadEnhancedOrder();
      } else {
        await _loadBasicOrder();
      }
    } catch (e) {
      _setError('Fehler beim Laden der Bestellung: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load enhanced order data
  Future<void> _loadEnhancedOrder() async {
    try {
      // TODO: Implement enhanced order loading when repository supports it
      // For now, fall back to basic order
      await _loadBasicOrder();
    } catch (e) {
      throw Exception('Fehler beim Laden der erweiterten Bestellung: $e');
    }
  }

  /// Load basic order data
  Future<void> _loadBasicOrder() async {
    try {
      final order = await _paymentRepository.getOrderById(orderId);
      _order = order;
      notifyListeners();
    } catch (e) {
      throw Exception('Fehler beim Laden der Bestellung: $e');
    }
  }

  /// Retry loading the order
  Future<void> retry() async {
    await _loadOrder();
  }

  /// Refresh order data
  Future<void> refresh() async {
    await _loadOrder();
  }

  /// Cancel the current order
  Future<void> cancelOrder() async {
    try {
      _setLoading(true);
      
      if (useEnhancedOrder && _enhancedOrder != null) {
        // TODO: Implement enhanced order cancellation
        await _cancelEnhancedOrder(_enhancedOrder!);
      } else if (_order != null) {
        await _cancelBasicOrder(_order!);
      }
      
      // Reload order data after cancellation
      await _loadOrder();
    } catch (e) {
      _setError('Fehler beim Stornieren der Bestellung: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel enhanced order
  Future<void> _cancelEnhancedOrder(EnhancedOrder order) async {
    // TODO: Implement when enhanced order repository is available
    throw UnimplementedError('Enhanced order cancellation not yet implemented');
  }

  /// Cancel basic order
  Future<void> _cancelBasicOrder(BasicOrder order) async {
    if (!order.canBeCancelled) {
      throw Exception('Diese Bestellung kann nicht mehr storniert werden');
    }

    // Update order status to cancelled
    await _paymentRepository.updateOrderStatus(
      orderId: order.id,
      status: OrderStatus.cancelled,
    );
  }

  /// Update order status
  Future<void> updateOrderStatus(OrderStatus newStatus) async {
    try {
      _setLoading(true);
      
      await _paymentRepository.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );
      
      // Reload order data
      await _loadOrder();
    } catch (e) {
      _setError('Fehler beim Aktualisieren des Bestellstatus: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update enhanced order status
  Future<void> updateEnhancedOrderStatus(EnhancedOrderStatus newStatus) async {
    try {
      _setLoading(true);
      
      // TODO: Implement when enhanced order repository is available
      throw UnimplementedError('Enhanced order status update not yet implemented');
    } catch (e) {
      _setError('Fehler beim Aktualisieren des Bestellstatus: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get order status history
  List<OrderStatusChange> getOrderStatusHistory() {
    if (useEnhancedOrder && _enhancedOrder != null) {
      return _enhancedOrder!.statusHistory ?? [];
    }
    
    // For basic orders, create a simple history from current status
    if (_order != null) {
      return [
        OrderStatusChange(
          id: 0, // Temporary ID for basic orders
          orderId: _order!.id,
          oldStatus: _mapBasicToEnhancedStatus(_order!.status),
          newStatus: _mapBasicToEnhancedStatus(_order!.status),
          changedAt: _order!.createdAt,
          reason: 'Bestellung erstellt',
          changedBy: 'system',
          fromStatus: _mapBasicToEnhancedStatus(_order!.status),
          toStatus: _mapBasicToEnhancedStatus(_order!.status),
        ),
      ];
    }
    
    return [];
  }

  /// Map basic order status to enhanced order status
  EnhancedOrderStatus _mapBasicToEnhancedStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return EnhancedOrderStatus.pending;
      case OrderStatus.confirmed:
        return EnhancedOrderStatus.confirmed;
      case OrderStatus.processing:
        return EnhancedOrderStatus.processing;
      case OrderStatus.shipped:
        return EnhancedOrderStatus.shipped;
      case OrderStatus.delivered:
        return EnhancedOrderStatus.delivered;
      case OrderStatus.cancelled:
        return EnhancedOrderStatus.cancelled;
      case OrderStatus.failed:
        return EnhancedOrderStatus.failed;
    }
  }

  /// Check if order can be cancelled
  bool get canCancelOrder {
    if (useEnhancedOrder && _enhancedOrder != null) {
      return _enhancedOrder!.canBeCancelled;
    } else if (_order != null) {
      return _order!.canBeCancelled;
    }
    return false;
  }

  /// Check if order can be tracked
  bool get canTrackOrder {
    if (useEnhancedOrder && _enhancedOrder != null) {
      return _enhancedOrder!.canBeTracked ?? false;
    } else if (_order != null) {
      return _order!.trackingNumber?.isNotEmpty == true &&
             [OrderStatus.shipped, OrderStatus.delivered].contains(_order!.status);
    }
    return false;
  }

  /// Get estimated delivery date
  DateTime? get estimatedDelivery {
    if (useEnhancedOrder && _enhancedOrder != null) {
      return _enhancedOrder!.estimatedDelivery;
    } else if (_order != null) {
      return _order!.estimatedDelivery;
    }
    return null;
  }

  /// Get tracking number
  String? get trackingNumber {
    if (useEnhancedOrder && _enhancedOrder != null) {
      return _enhancedOrder!.trackingNumber;
    } else if (_order != null) {
      return _order!.trackingNumber;
    }
    return null;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
