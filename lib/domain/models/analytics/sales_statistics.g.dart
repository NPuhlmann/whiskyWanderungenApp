// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalesStatistics _$SalesStatisticsFromJson(Map<String, dynamic> json) =>
    _SalesStatistics(
      totalOrders: (json['totalOrders'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      ordersByRoute:
          (json['ordersByRoute'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      revenueByRoute:
          (json['revenueByRoute'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      ordersByDate:
          (json['ordersByDate'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      revenueByDate:
          (json['revenueByDate'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
    );

Map<String, dynamic> _$SalesStatisticsToJson(_SalesStatistics instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'totalRevenue': instance.totalRevenue,
      'averageOrderValue': instance.averageOrderValue,
      'ordersByRoute': instance.ordersByRoute,
      'revenueByRoute': instance.revenueByRoute,
      'ordersByDate': instance.ordersByDate,
      'revenueByDate': instance.revenueByDate,
    };
