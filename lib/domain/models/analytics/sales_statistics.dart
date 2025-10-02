import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'sales_statistics.freezed.dart';
part 'sales_statistics.g.dart';

/// Sales statistics model for analytics
///
/// Aggregates order data to provide insights into:
/// - Total revenue and order counts
/// - Revenue and orders grouped by route
/// - Daily revenue and order trends
@freezed
abstract class SalesStatistics with _$SalesStatistics {
  const SalesStatistics._();

  const factory SalesStatistics({
    required int totalOrders,
    required double totalRevenue,
    required double averageOrderValue,
    @Default({}) Map<String, int> ordersByRoute,
    @Default({}) Map<String, double> revenueByRoute,
    @Default({}) Map<String, int> ordersByDate,
    @Default({}) Map<String, double> revenueByDate,
  }) = _SalesStatistics;

  factory SalesStatistics.fromJson(Map<String, dynamic> json) =>
      _$SalesStatisticsFromJson(json);

  /// Returns formatted revenue with Euro symbol
  String get formattedRevenue {
    return NumberFormat.currency(locale: 'de_DE', symbol: '€').format(totalRevenue);
  }

  /// Returns formatted average order value with Euro symbol
  String get formattedAverageOrderValue {
    return NumberFormat.currency(locale: 'de_DE', symbol: '€').format(averageOrderValue);
  }

  /// Number of unique routes with orders
  int get routeCount => ordersByRoute.length;

  /// Returns the most popular route by order count
  /// Returns null if no routes have orders
  String? get mostPopularRouteId {
    if (ordersByRoute.isEmpty) return null;

    return ordersByRoute.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Returns revenue timeline sorted by date
  List<MapEntry<String, double>> get revenueTimeline {
    final entries = revenueByDate.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Returns orders timeline sorted by date
  List<MapEntry<String, int>> get ordersTimeline {
    final entries = ordersByDate.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Returns top N routes by revenue
  List<MapEntry<String, double>> getTopRoutesByRevenue(int limit) {
    final entries = revenueByRoute.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Returns top N routes by order count
  List<MapEntry<String, int>> getTopRoutesByOrders(int limit) {
    final entries = ordersByRoute.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Returns total revenue for a specific route
  double getRevenueForRoute(String routeId) {
    return revenueByRoute[routeId] ?? 0.0;
  }

  /// Returns total orders for a specific route
  int getOrdersForRoute(String routeId) {
    return ordersByRoute[routeId] ?? 0;
  }

  /// Creates an empty SalesStatistics instance
  factory SalesStatistics.empty() {
    return const SalesStatistics(
      totalOrders: 0,
      totalRevenue: 0.0,
      averageOrderValue: 0.0,
      ordersByRoute: {},
      revenueByRoute: {},
      ordersByDate: {},
      revenueByDate: {},
    );
  }
}
