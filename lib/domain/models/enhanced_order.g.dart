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
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => Hike.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hikeId: (json['hike_id'] as num?)?.toInt(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      baseAmount: (json['base_amount'] as num?)?.toDouble() ?? 0.0,
      status:
          $enumDecodeNullable(_$EnhancedOrderStatusEnumMap, json['status']) ??
          EnhancedOrderStatus.pending,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
      confirmedAt:
          json['confirmed_at'] == null
              ? null
              : DateTime.parse(json['confirmed_at'] as String),
      shippedAt:
          json['shipped_at'] == null
              ? null
              : DateTime.parse(json['shipped_at'] as String),
      deliveredAt:
          json['delivered_at'] == null
              ? null
              : DateTime.parse(json['delivered_at'] as String),
      cancelledAt:
          json['cancelled_at'] == null
              ? null
              : DateTime.parse(json['cancelled_at'] as String),
      customerId: json['customer_id'] as String,
      customerEmail: json['customer_email'] as String?,
      customerPhone: json['customer_phone'] as String?,
      deliveryType:
          $enumDecodeNullable(_$DeliveryTypeEnumMap, json['delivery_type']) ??
          DeliveryType.standardShipping,
      deliveryAddress: DeliveryAddress.fromJson(
        json['delivery_address'] as Map<String, dynamic>,
      ),
      trackingNumber: json['tracking_number'] as String?,
      trackingUrl: json['tracking_url'] as String?,
      shippingCarrier: json['shipping_carrier'] as String?,
      shippingMethod: json['shipping_method'] as String?,
      shippingService: json['shipping_service'] as String?,
      estimatedDeliveryDate: json['estimated_delivery_date'] as String?,
      estimatedDelivery:
          json['estimated_delivery'] == null
              ? null
              : DateTime.parse(json['estimated_delivery'] as String),
      actualDelivery:
          json['actual_delivery'] == null
              ? null
              : DateTime.parse(json['actual_delivery'] as String),
      shippingDetails:
          json['shipping_details'] == null
              ? null
              : ShippingCostResult.fromJson(
                json['shipping_details'] as Map<String, dynamic>,
              ),
      paymentIntentId: json['payment_intent_id'] as String?,
      paymentMethodId: json['payment_method_id'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentDate:
          json['payment_date'] == null
              ? null
              : DateTime.parse(json['payment_date'] as String),
      notes: json['notes'] as String?,
      internalNotes: json['internal_notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      statusHistory:
          (json['status_history'] as List<dynamic>?)
              ?.map(
                (e) => OrderStatusChange.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      vendorOrderId: json['vendor_order_id'] as String?,
      vendorNotes: json['vendor_notes'] as String?,
      vendorMetadata: json['vendor_metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EnhancedOrderToJson(_EnhancedOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'companyId': instance.companyId,
      'company': instance.company,
      'items': instance.items,
      'hike_id': instance.hikeId,
      'subtotal': instance.subtotal,
      'tax_amount': instance.taxAmount,
      'shipping_cost': instance.shippingCost,
      'total_amount': instance.totalAmount,
      'currency': instance.currency,
      'base_amount': instance.baseAmount,
      'status': _$EnhancedOrderStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'confirmed_at': instance.confirmedAt?.toIso8601String(),
      'shipped_at': instance.shippedAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'customer_id': instance.customerId,
      'customer_email': instance.customerEmail,
      'customer_phone': instance.customerPhone,
      'delivery_type': _$DeliveryTypeEnumMap[instance.deliveryType]!,
      'delivery_address': instance.deliveryAddress,
      'tracking_number': instance.trackingNumber,
      'tracking_url': instance.trackingUrl,
      'shipping_carrier': instance.shippingCarrier,
      'shipping_method': instance.shippingMethod,
      'shipping_service': instance.shippingService,
      'estimated_delivery_date': instance.estimatedDeliveryDate,
      'estimated_delivery': instance.estimatedDelivery?.toIso8601String(),
      'actual_delivery': instance.actualDelivery?.toIso8601String(),
      'shipping_details': instance.shippingDetails,
      'payment_intent_id': instance.paymentIntentId,
      'payment_method_id': instance.paymentMethodId,
      'payment_status': instance.paymentStatus,
      'payment_date': instance.paymentDate?.toIso8601String(),
      'notes': instance.notes,
      'internal_notes': instance.internalNotes,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'status_history': instance.statusHistory,
      'vendor_order_id': instance.vendorOrderId,
      'vendor_notes': instance.vendorNotes,
      'vendor_metadata': instance.vendorMetadata,
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

const _$DeliveryTypeEnumMap = {
  DeliveryType.pickup: 'pickup',
  DeliveryType.standardShipping: 'standardShipping',
  DeliveryType.expressShipping: 'expressShipping',
  DeliveryType.premiumShipping: 'premiumShipping',
};

_OrderStatusChange _$OrderStatusChangeFromJson(Map<String, dynamic> json) =>
    _OrderStatusChange(
      fromStatus: $enumDecode(
        _$EnhancedOrderStatusEnumMap,
        json['from_status'],
      ),
      toStatus: $enumDecode(_$EnhancedOrderStatusEnumMap, json['to_status']),
      changedAt: DateTime.parse(json['changed_at'] as String),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      changedBy: json['changed_by'] as String?,
    );

Map<String, dynamic> _$OrderStatusChangeToJson(_OrderStatusChange instance) =>
    <String, dynamic>{
      'from_status': _$EnhancedOrderStatusEnumMap[instance.fromStatus]!,
      'to_status': _$EnhancedOrderStatusEnumMap[instance.toStatus]!,
      'changed_at': instance.changedAt.toIso8601String(),
      'reason': instance.reason,
      'notes': instance.notes,
      'changed_by': instance.changedBy,
    };
