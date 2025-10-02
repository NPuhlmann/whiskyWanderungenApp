// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_performance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutePerformance _$RoutePerformanceFromJson(Map<String, dynamic> json) =>
    _RoutePerformance(
      routeId: (json['routeId'] as num).toInt(),
      routeName: json['routeName'] as String,
      totalSales: (json['totalSales'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      conversionRate: (json['conversionRate'] as num).toDouble(),
      totalViews: (json['totalViews'] as num).toInt(),
      salesByMonth:
          (json['salesByMonth'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$RoutePerformanceToJson(_RoutePerformance instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'totalSales': instance.totalSales,
      'totalRevenue': instance.totalRevenue,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
      'conversionRate': instance.conversionRate,
      'totalViews': instance.totalViews,
      'salesByMonth': instance.salesByMonth,
    };
