// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_insights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerInsights _$CustomerInsightsFromJson(Map<String, dynamic> json) =>
    _CustomerInsights(
      totalCustomers: (json['totalCustomers'] as num).toInt(),
      newCustomers: (json['newCustomers'] as num).toInt(),
      returningCustomers: (json['returningCustomers'] as num).toInt(),
      repeatPurchaseRate: (json['repeatPurchaseRate'] as num).toDouble(),
      averageLifetimeValue: (json['averageLifetimeValue'] as num).toDouble(),
      customersByLocation:
          (json['customersByLocation'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      orderFrequencyDistribution:
          (json['orderFrequencyDistribution'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$CustomerInsightsToJson(_CustomerInsights instance) =>
    <String, dynamic>{
      'totalCustomers': instance.totalCustomers,
      'newCustomers': instance.newCustomers,
      'returningCustomers': instance.returningCustomers,
      'repeatPurchaseRate': instance.repeatPurchaseRate,
      'averageLifetimeValue': instance.averageLifetimeValue,
      'customersByLocation': instance.customersByLocation,
      'orderFrequencyDistribution': instance.orderFrequencyDistribution.map(
        (k, e) => MapEntry(k.toString(), e),
      ),
    };
