// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SimpleOrder _$SimpleOrderFromJson(Map<String, dynamic> json) => _SimpleOrder(
  id: (json['id'] as num).toInt(),
  orderNumber: json['orderNumber'] as String,
  hikeId: (json['hikeId'] as num).toInt(),
  userId: json['userId'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  deliveryType: $enumDecode(_$DeliveryTypeEnumMap, json['deliveryType']),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SimpleOrderToJson(_SimpleOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'hikeId': instance.hikeId,
      'userId': instance.userId,
      'totalAmount': instance.totalAmount,
      'deliveryType': _$DeliveryTypeEnumMap[instance.deliveryType]!,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DeliveryTypeEnumMap = {
  DeliveryType.pickup: 'pickup',
  DeliveryType.shipping: 'shipping',
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
