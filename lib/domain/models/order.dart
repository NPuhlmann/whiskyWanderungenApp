import 'package:freezed_annotation/freezed_annotation.dart';
import 'basic_order.dart';

part 'order.freezed.dart';
part 'order.g.dart';

// Use enums from basic_order.dart

/// Order model representing a completed purchase
@freezed
abstract class Order with _$Order {
  const factory Order({
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
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

/// Extension for business logic on Order
extension OrderExtensions on Order {
  /// Check if the order requires a delivery address
  bool get requiresDeliveryAddress => deliveryType == DeliveryType.shipping;
  
  /// Check if the order is in a final state (completed or cancelled)
  bool get isFinalStatus => status == OrderStatus.delivered || status == OrderStatus.cancelled;
  
  /// Check if the order can be cancelled
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  /// Get the delivery cost based on delivery type
  double get deliveryCost => deliveryType == DeliveryType.shipping ? 5.0 : 0.0;
  
  /// Get base price (total minus delivery cost)
  double get basePrice => totalAmount - deliveryCost;
  
  /// Generate a formatted order number display
  String get formattedOrderNumber => '#$orderNumber';
}