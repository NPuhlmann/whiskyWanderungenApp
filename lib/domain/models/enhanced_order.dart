import 'package:freezed_annotation/freezed_annotation.dart';
import 'basic_order.dart';

part 'enhanced_order.freezed.dart';
part 'enhanced_order.g.dart';

/// Enhanced order status enum with more detailed states
enum EnhancedOrderStatus {
  pending,
  paymentPending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
  failed
}

@freezed
abstract class EnhancedOrder with _$EnhancedOrder {
  const factory EnhancedOrder({
    required int id,
    required String orderNumber,
    required int hikeId,
    required String userId,
    required double totalAmount,
    required String currency,
    required DeliveryType deliveryType,
    required EnhancedOrderStatus status,
    required DateTime createdAt,
    DateTime? estimatedDelivery,
    String? trackingNumber,
    Map<String, dynamic>? deliveryAddress,
    String? paymentIntentId,
    DateTime? updatedAt,
    // Enhanced fields
    String? companyId,
    String? customerEmail,
    String? customerPhone,
    List<OrderStatusChange>? statusHistory,
    Map<String, dynamic>? shippingDetails,
    bool? canBeTracked,
    // Additional fields for enhanced functionality
    double? baseAmount,
    double? shippingCost,
    String? shippingService,
    DateTime? actualDelivery,
    String? trackingUrl,
  }) = _EnhancedOrder;

  factory EnhancedOrder.fromJson(Map<String, dynamic> json) =>
      _$EnhancedOrderFromJson(json);
}

@freezed
abstract class OrderStatusChange with _$OrderStatusChange {
  const factory OrderStatusChange({
    required int id,
    required int orderId,
    required EnhancedOrderStatus oldStatus,
    required EnhancedOrderStatus newStatus,
    required DateTime changedAt,
    String? reason,
    String? changedBy,
    @JsonKey(name: 'from_status') EnhancedOrderStatus? fromStatus,
    @JsonKey(name: 'to_status') EnhancedOrderStatus? toStatus,
  }) = _OrderStatusChange;

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusChangeFromJson(json);
}

/// Extension for business logic on EnhancedOrder
extension EnhancedOrderExtensions on EnhancedOrder {
  /// Check if the order requires a delivery address
  bool get requiresDeliveryAddress => 
      deliveryType == DeliveryType.standardShipping || 
      deliveryType == DeliveryType.expressShipping;
  
  /// Check if the order can be cancelled
  bool get canBeCancelled => 
      status == EnhancedOrderStatus.pending || 
      status == EnhancedOrderStatus.paymentPending ||
      status == EnhancedOrderStatus.confirmed;
  
  /// Get the delivery cost based on delivery type
  double get deliveryCost {
    if (shippingCost != null) return shippingCost!;
    
    switch (deliveryType) {
      case DeliveryType.standardShipping:
        return 5.0;
      case DeliveryType.expressShipping:
        return 10.0;
      case DeliveryType.pickup:
      default:
        return 0.0;
    }
  }
  
  /// Get base price (total minus delivery cost)
  double get basePrice {
    if (baseAmount != null) return baseAmount!;
    return totalAmount - deliveryCost;
  }
  
  /// Check if the order can be tracked
  bool get isTrackable {
    return canBeTracked ?? false;
  }
  
  /// Generate a formatted order number display
  String get formattedOrderNumber => '#$orderNumber';
  
  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case EnhancedOrderStatus.pending:
        return 'Ausstehend';
      case EnhancedOrderStatus.paymentPending:
        return 'Zahlung ausstehend';
      case EnhancedOrderStatus.confirmed:
        return 'Bestätigt';
      case EnhancedOrderStatus.processing:
        return 'In Bearbeitung';
      case EnhancedOrderStatus.shipped:
        return 'Versendet';
      case EnhancedOrderStatus.outForDelivery:
        return 'Unterwegs';
      case EnhancedOrderStatus.delivered:
        return 'Geliefert';
      case EnhancedOrderStatus.cancelled:
        return 'Storniert';
      case EnhancedOrderStatus.refunded:
        return 'Erstattet';
      case EnhancedOrderStatus.failed:
        return 'Fehlgeschlagen';
    }
  }
  
  /// Get delivery type display text
  String get deliveryTypeDisplayText {
    switch (deliveryType) {
      case DeliveryType.pickup:
        return 'Abholung';
      case DeliveryType.standardShipping:
        return 'Standardversand';
      case DeliveryType.expressShipping:
        return 'Expressversand';
    }
  }
}

