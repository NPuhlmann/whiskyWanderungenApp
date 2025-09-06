import 'package:freezed_annotation/freezed_annotation.dart';

part 'basic_order.freezed.dart';
part 'basic_order.g.dart';

/// Order status enum for tracking order progression
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  failed
}

/// Delivery type enum for order fulfillment
enum DeliveryType {
  pickup,
  standardShipping,
  expressShipping
}

@freezed
abstract class BasicOrder with _$BasicOrder {
  const factory BasicOrder({
    required int id,
    required String orderNumber,
    required int hikeId,
    required String userId,
    required double totalAmount,
    required DeliveryType deliveryType,
    required OrderStatus status,
    required DateTime createdAt,
    DateTime? estimatedDelivery,
    String? trackingNumber,
    Map<String, dynamic>? deliveryAddress,
    String? paymentIntentId,
    DateTime? updatedAt,
  }) = _BasicOrder;

  factory BasicOrder.fromJson(Map<String, dynamic> json) =>
      _$BasicOrderFromJson(json);
}

/// Extension for business logic on BasicOrder
extension BasicOrderExtensions on BasicOrder {
  /// Check if the order requires a delivery address
  bool get requiresDeliveryAddress => deliveryType == DeliveryType.standardShipping || deliveryType == DeliveryType.expressShipping;
  
  /// Check if the order is in a final state (completed or cancelled)
  bool get isFinalStatus => status == OrderStatus.delivered || status == OrderStatus.cancelled || status == OrderStatus.failed;
  
  /// Check if the order can be cancelled
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  /// Get the delivery cost based on delivery type
  double get deliveryCost {
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
  double get basePrice => totalAmount - deliveryCost;
  
  /// Generate a formatted order number display
  String get formattedOrderNumber => '#$orderNumber';
}