import 'package:freezed_annotation/freezed_annotation.dart';
import 'basic_order.dart';

part 'enhanced_order.freezed.dart';
part 'enhanced_order.g.dart';

@freezed
class EnhancedOrder with _$EnhancedOrder {
  const factory EnhancedOrder({
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
    // Enhanced fields
    String? companyId,
    String? customerEmail,
    String? customerPhone,
    List<OrderStatusChange>? statusHistory,
    Map<String, dynamic>? shippingDetails,
    bool? canBeTracked,
  }) = _EnhancedOrder;

  factory EnhancedOrder.fromJson(Map<String, dynamic> json) =>
      _$EnhancedOrderFromJson(json);
}

@freezed
class OrderStatusChange with _$OrderStatusChange {
  const factory OrderStatusChange({
    required int id,
    required int orderId,
    required OrderStatus oldStatus,
    required OrderStatus newStatus,
    required DateTime changedAt,
    String? reason,
    String? changedBy,
  }) = _OrderStatusChange;

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusChangeFromJson(json);
}

