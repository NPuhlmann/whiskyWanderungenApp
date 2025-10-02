// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PerformanceMetrics _$PerformanceMetricsFromJson(Map<String, dynamic> json) =>
    _PerformanceMetrics(
      conversionRate: (json['conversionRate'] as num).toDouble(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      customerLifetimeValue: (json['customerLifetimeValue'] as num).toDouble(),
      totalViews: (json['totalViews'] as num).toInt(),
      totalPurchases: (json['totalPurchases'] as num).toInt(),
      metricsByPeriod:
          (json['metricsByPeriod'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
    );

Map<String, dynamic> _$PerformanceMetricsToJson(_PerformanceMetrics instance) =>
    <String, dynamic>{
      'conversionRate': instance.conversionRate,
      'averageOrderValue': instance.averageOrderValue,
      'customerLifetimeValue': instance.customerLifetimeValue,
      'totalViews': instance.totalViews,
      'totalPurchases': instance.totalPurchases,
      'metricsByPeriod': instance.metricsByPeriod,
    };
