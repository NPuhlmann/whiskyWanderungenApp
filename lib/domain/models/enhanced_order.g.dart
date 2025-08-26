// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnhancedOrder _$EnhancedOrderFromJson(Map<String, dynamic> json) =>
    _EnhancedOrder(
      id: (json['id'] as num).toInt(),
      orderNumber: json['orderNumber'] as String,
      companyId: json['companyId'] as String,
      company:
          json['company'] == null
              ? null
              : Company.fromJson(json['company'] as Map<String, dynamic>),
      userId: json['userId'] as String,
      hikeId: (json['hikeId'] as num).toInt(),
      hike:
          json['hike'] == null
              ? null
              : Hike.fromJson(json['hike'] as Map<String, dynamic>),
      baseAmount: (json['baseAmount'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      deliveryType: $enumDecode(_$DeliveryTypeEnumMap, json['deliveryType']),
      deliveryAddress:
          json['deliveryAddress'] == null
              ? null
              : DeliveryAddress.fromJson(
                json['deliveryAddress'] as Map<String, dynamic>,
              ),
      deliveryAddressRaw: json['delivery_address_raw'] as Map<String, dynamic>?,
      status: $enumDecode(_$EnhancedOrderStatusEnumMap, json['status']),
      trackingNumber: json['trackingNumber'] as String?,
      trackingUrl: json['trackingUrl'] as String?,
      estimatedDelivery:
          json['estimatedDelivery'] == null
              ? null
              : DateTime.parse(json['estimatedDelivery'] as String),
      actualDelivery:
          json['actualDelivery'] == null
              ? null
              : DateTime.parse(json['actualDelivery'] as String),
      paymentIntentId: json['paymentIntentId'] as String?,
      paymentMethodId: json['paymentMethodId'] as String?,
      paymentProvider: $enumDecodeNullable(
        _$PaymentProviderEnumMap,
        json['paymentProvider'],
      ),
      shippingDetails:
          json['shippingDetails'] == null
              ? null
              : ShippingCostResult.fromJson(
                json['shippingDetails'] as Map<String, dynamic>,
              ),
      shippingService: json['shippingService'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      customerNotes: json['customerNotes'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
      internalNotes: json['internalNotes'] as String?,
      statusHistory:
          (json['statusHistory'] as List<dynamic>?)
              ?.map(
                (e) => OrderStatusChange.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$EnhancedOrderToJson(_EnhancedOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'companyId': instance.companyId,
      'company': instance.company,
      'userId': instance.userId,
      'hikeId': instance.hikeId,
      'hike': instance.hike,
      'baseAmount': instance.baseAmount,
      'shippingCost': instance.shippingCost,
      'totalAmount': instance.totalAmount,
      'taxAmount': instance.taxAmount,
      'currency': instance.currency,
      'deliveryType': _$DeliveryTypeEnumMap[instance.deliveryType]!,
      'deliveryAddress': instance.deliveryAddress,
      'delivery_address_raw': instance.deliveryAddressRaw,
      'status': _$EnhancedOrderStatusEnumMap[instance.status]!,
      'trackingNumber': instance.trackingNumber,
      'trackingUrl': instance.trackingUrl,
      'estimatedDelivery': instance.estimatedDelivery?.toIso8601String(),
      'actualDelivery': instance.actualDelivery?.toIso8601String(),
      'paymentIntentId': instance.paymentIntentId,
      'paymentMethodId': instance.paymentMethodId,
      'paymentProvider': _$PaymentProviderEnumMap[instance.paymentProvider],
      'shippingDetails': instance.shippingDetails,
      'shippingService': instance.shippingService,
      'items': instance.items,
      'customerNotes': instance.customerNotes,
      'deliveryInstructions': instance.deliveryInstructions,
      'internalNotes': instance.internalNotes,
      'statusHistory': instance.statusHistory,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$DeliveryTypeEnumMap = {
  DeliveryType.pickup: 'pickup',
  DeliveryType.standardShipping: 'standard_shipping',
  DeliveryType.expressShipping: 'express_shipping',
  DeliveryType.premiumShipping: 'premium_shipping',
};

const _$EnhancedOrderStatusEnumMap = {
  EnhancedOrderStatus.pending: 'pending',
  EnhancedOrderStatus.paymentPending: 'payment_pending',
  EnhancedOrderStatus.confirmed: 'confirmed',
  EnhancedOrderStatus.processing: 'processing',
  EnhancedOrderStatus.shipped: 'shipped',
  EnhancedOrderStatus.outForDelivery: 'out_for_delivery',
  EnhancedOrderStatus.delivered: 'delivered',
  EnhancedOrderStatus.cancelled: 'cancelled',
  EnhancedOrderStatus.refunded: 'refunded',
  EnhancedOrderStatus.failed: 'failed',
};

const _$PaymentProviderEnumMap = {
  PaymentProvider.stripe: 'stripe',
  PaymentProvider.paypal: 'paypal',
  PaymentProvider.applePay: 'apple_pay',
  PaymentProvider.googlePay: 'google_pay',
};

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  id: (json['id'] as num).toInt(),
  hikeId: (json['hikeId'] as num).toInt(),
  hike:
      json['hike'] == null
          ? null
          : Hike.fromJson(json['hike'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hikeId': instance.hikeId,
      'hike': instance.hike,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'notes': instance.notes,
    };

_OrderStatusChange _$OrderStatusChangeFromJson(Map<String, dynamic> json) =>
    _OrderStatusChange(
      fromStatus: $enumDecode(_$EnhancedOrderStatusEnumMap, json['fromStatus']),
      toStatus: $enumDecode(_$EnhancedOrderStatusEnumMap, json['toStatus']),
      changedAt: DateTime.parse(json['changedAt'] as String),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      changedBy: json['changedBy'] as String?,
    );

Map<String, dynamic> _$OrderStatusChangeToJson(_OrderStatusChange instance) =>
    <String, dynamic>{
      'fromStatus': _$EnhancedOrderStatusEnumMap[instance.fromStatus]!,
      'toStatus': _$EnhancedOrderStatusEnumMap[instance.toStatus]!,
      'changedAt': instance.changedAt.toIso8601String(),
      'reason': instance.reason,
      'notes': instance.notes,
      'changedBy': instance.changedBy,
    };
