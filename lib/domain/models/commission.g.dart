// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Commission _$CommissionFromJson(Map<String, dynamic> json) => _Commission(
  id: (json['id'] as num).toInt(),
  hikeId: (json['hike_id'] as num).toInt(),
  companyId: json['company_id'] as String,
  orderId: json['order_id'] as String,
  commissionRate: (json['commission_rate'] as num).toDouble(),
  baseAmount: (json['base_amount'] as num).toDouble(),
  commissionAmount: (json['commission_amount'] as num).toDouble(),
  status: $enumDecode(_$CommissionStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  paidAt: json['paid_at'] == null
      ? null
      : DateTime.parse(json['paid_at'] as String),
  billingPeriodId: json['billing_period_id'] as String?,
  notes: json['notes'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CommissionToJson(_Commission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hike_id': instance.hikeId,
      'company_id': instance.companyId,
      'order_id': instance.orderId,
      'commission_rate': instance.commissionRate,
      'base_amount': instance.baseAmount,
      'commission_amount': instance.commissionAmount,
      'status': _$CommissionStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'paid_at': instance.paidAt?.toIso8601String(),
      'billing_period_id': instance.billingPeriodId,
      'notes': instance.notes,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$CommissionStatusEnumMap = {
  CommissionStatus.pending: 'pending',
  CommissionStatus.calculated: 'calculated',
  CommissionStatus.paid: 'paid',
  CommissionStatus.cancelled: 'cancelled',
};
