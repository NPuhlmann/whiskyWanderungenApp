// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnhancedOrder _$EnhancedOrderFromJson(Map<String, dynamic> json) =>
    _EnhancedOrder(
      id: (json['id'] as num).toInt(),
      orderNumber: json['orderNumber'] as String,
      hikeId: (json['hikeId'] as num).toInt(),
      userId: json['userId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryType: $enumDecode(_$DeliveryTypeEnumMap, json['deliveryType']),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      estimatedDelivery:
          json['estimatedDelivery'] == null
              ? null
              : DateTime.parse(json['estimatedDelivery'] as String),
      trackingNumber: json['trackingNumber'] as String?,
      deliveryAddress: json['deliveryAddress'] as Map<String, dynamic>?,
      paymentIntentId: json['paymentIntentId'] as String?,
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      companyId: json['companyId'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      statusHistory:
          (json['statusHistory'] as List<dynamic>?)
              ?.map(
                (e) => OrderStatusChange.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      shippingDetails: json['shippingDetails'] as Map<String, dynamic>?,
      canBeTracked: json['canBeTracked'] as bool?,
    );

Map<String, dynamic> _$EnhancedOrderToJson(_EnhancedOrder instance) =>
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
      'companyId': instance.companyId,
      'customerEmail': instance.customerEmail,
      'customerPhone': instance.customerPhone,
      'statusHistory': instance.statusHistory,
      'shippingDetails': instance.shippingDetails,
      'canBeTracked': instance.canBeTracked,
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

_OrderStatusChange _$OrderStatusChangeFromJson(Map<String, dynamic> json) =>
    _OrderStatusChange(
      id: (json['id'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      oldStatus: $enumDecode(_$OrderStatusEnumMap, json['oldStatus']),
      newStatus: $enumDecode(_$OrderStatusEnumMap, json['newStatus']),
      changedAt: DateTime.parse(json['changedAt'] as String),
      reason: json['reason'] as String?,
      changedBy: json['changedBy'] as String?,
    );

Map<String, dynamic> _$OrderStatusChangeToJson(_OrderStatusChange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'oldStatus': _$OrderStatusEnumMap[instance.oldStatus]!,
      'newStatus': _$OrderStatusEnumMap[instance.newStatus]!,
      'changedAt': instance.changedAt.toIso8601String(),
      'reason': instance.reason,
      'changedBy': instance.changedBy,
    };
