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
      currency: json['currency'] as String,
      deliveryType: $enumDecode(_$DeliveryTypeEnumMap, json['deliveryType']),
      status: $enumDecode(_$EnhancedOrderStatusEnumMap, json['status']),
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
      baseAmount: (json['baseAmount'] as num?)?.toDouble(),
      shippingCost: (json['shippingCost'] as num?)?.toDouble(),
      shippingService: json['shippingService'] as String?,
      actualDelivery:
          json['actualDelivery'] == null
              ? null
              : DateTime.parse(json['actualDelivery'] as String),
      trackingUrl: json['trackingUrl'] as String?,
    );

Map<String, dynamic> _$EnhancedOrderToJson(_EnhancedOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'hikeId': instance.hikeId,
      'userId': instance.userId,
      'totalAmount': instance.totalAmount,
      'currency': instance.currency,
      'deliveryType': _$DeliveryTypeEnumMap[instance.deliveryType]!,
      'status': _$EnhancedOrderStatusEnumMap[instance.status]!,
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
      'baseAmount': instance.baseAmount,
      'shippingCost': instance.shippingCost,
      'shippingService': instance.shippingService,
      'actualDelivery': instance.actualDelivery?.toIso8601String(),
      'trackingUrl': instance.trackingUrl,
    };

const _$DeliveryTypeEnumMap = {
  DeliveryType.pickup: 'pickup',
  DeliveryType.standardShipping: 'standardShipping',
  DeliveryType.expressShipping: 'expressShipping',
};

const _$EnhancedOrderStatusEnumMap = {
  EnhancedOrderStatus.pending: 'pending',
  EnhancedOrderStatus.paymentPending: 'paymentPending',
  EnhancedOrderStatus.confirmed: 'confirmed',
  EnhancedOrderStatus.processing: 'processing',
  EnhancedOrderStatus.shipped: 'shipped',
  EnhancedOrderStatus.outForDelivery: 'outForDelivery',
  EnhancedOrderStatus.delivered: 'delivered',
  EnhancedOrderStatus.cancelled: 'cancelled',
  EnhancedOrderStatus.refunded: 'refunded',
  EnhancedOrderStatus.failed: 'failed',
};

_OrderStatusChange _$OrderStatusChangeFromJson(Map<String, dynamic> json) =>
    _OrderStatusChange(
      id: (json['id'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      oldStatus: $enumDecode(_$EnhancedOrderStatusEnumMap, json['oldStatus']),
      newStatus: $enumDecode(_$EnhancedOrderStatusEnumMap, json['newStatus']),
      changedAt: DateTime.parse(json['changedAt'] as String),
      reason: json['reason'] as String?,
      changedBy: json['changedBy'] as String?,
      fromStatus: $enumDecodeNullable(
        _$EnhancedOrderStatusEnumMap,
        json['from_status'],
      ),
      toStatus: $enumDecodeNullable(
        _$EnhancedOrderStatusEnumMap,
        json['to_status'],
      ),
    );

Map<String, dynamic> _$OrderStatusChangeToJson(_OrderStatusChange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'oldStatus': _$EnhancedOrderStatusEnumMap[instance.oldStatus]!,
      'newStatus': _$EnhancedOrderStatusEnumMap[instance.newStatus]!,
      'changedAt': instance.changedAt.toIso8601String(),
      'reason': instance.reason,
      'changedBy': instance.changedBy,
      'from_status': _$EnhancedOrderStatusEnumMap[instance.fromStatus],
      'to_status': _$EnhancedOrderStatusEnumMap[instance.toStatus],
    };
