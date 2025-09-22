// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentResult _$PaymentResultFromJson(Map<String, dynamic> json) =>
    _PaymentResult(
      isSuccess: json['isSuccess'] as bool,
      order: json['order'] == null
          ? null
          : Order.fromJson(json['order'] as Map<String, dynamic>),
      clientSecret: json['clientSecret'] as String?,
      errorMessage: json['errorMessage'] as String?,
      status: $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']),
      paymentIntentId: json['paymentIntentId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentResultToJson(_PaymentResult instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'order': instance.order,
      'clientSecret': instance.clientSecret,
      'errorMessage': instance.errorMessage,
      'status': _$PaymentStatusEnumMap[instance.status],
      'paymentIntentId': instance.paymentIntentId,
      'metadata': instance.metadata,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.succeeded: 'succeeded',
  PaymentStatus.failed: 'failed',
  PaymentStatus.pending: 'pending',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.requiresAction: 'requires_action',
};
