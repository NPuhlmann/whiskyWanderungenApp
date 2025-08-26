import 'package:freezed_annotation/freezed_annotation.dart';

part 'simple_order.freezed.dart';
part 'simple_order.g.dart';

/// Order status enum for tracking order progression
enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('processing')
  processing,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled
}

/// Delivery type enum for order fulfillment
enum DeliveryType {
  @JsonValue('pickup')
  pickup,
  @JsonValue('shipping')
  shipping
}

/// Order model representing a completed purchase
@freezed
class SimpleOrder with _$SimpleOrder {
  const factory SimpleOrder({
    required int id,
    required String orderNumber,
    required int hikeId,
    required String userId,
    required double totalAmount,
    required DeliveryType deliveryType,
    required OrderStatus status,
    required DateTime createdAt,
  }) = _SimpleOrder;

  factory SimpleOrder.fromJson(Map<String, dynamic> json) => _$SimpleOrderFromJson(json);
}

/// Extension for business logic on SimpleOrder
extension SimpleOrderExtensions on SimpleOrder {
  /// Check if the order requires a delivery address
  bool get requiresDeliveryAddress => deliveryType == DeliveryType.shipping;
  
  /// Check if the order can be cancelled
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  /// Get the delivery cost based on delivery type
  double get deliveryCost => deliveryType == DeliveryType.shipping ? 5.0 : 0.0;
  
  /// Get base price (total minus delivery cost)
  double get basePrice => totalAmount - deliveryCost;
  
  /// Generate a formatted order number display
  String get formattedOrderNumber => '#$orderNumber';
}