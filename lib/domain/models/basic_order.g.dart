// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BasicOrder _$BasicOrderFromJson(Map<String, dynamic> json) => _BasicOrder(
  id: (json['id'] as num).toInt(),
  orderNumber: json['orderNumber'] as String,
  hikeId: (json['hikeId'] as num).toInt(),
  userId: json['userId'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  deliveryType: $enumDecode(_$DeliveryTypeEnumMap, json['deliveryType']),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  estimatedDelivery: json['estimatedDelivery'] == null
      ? null
      : DateTime.parse(json['estimatedDelivery'] as String),
  trackingNumber: json['trackingNumber'] as String?,
  deliveryAddress: json['deliveryAddress'] as Map<String, dynamic>?,
  paymentIntentId: json['paymentIntentId'] as String?,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BasicOrderToJson(_BasicOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'hikeId': instance.hikeId,
      'userId': instance.userId,
      'totalAmount': instance.totalAmount,
      'deliveryType': _$DeliveryTypeEnumMap[instance.deliveryType]!,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'estimatedDelivery': instance.estimatedDelivery?.toIso8601String(),
      'trackingNumber': instance.trackingNumber,
      'deliveryAddress': instance.deliveryAddress,
      'paymentIntentId': instance.paymentIntentId,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DeliveryTypeEnumMap = {
  DeliveryType.pickup: 'pickup',
  DeliveryType.standardShipping: 'standardShipping',
  DeliveryType.expressShipping: 'expressShipping',
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.failed: 'failed',
};
