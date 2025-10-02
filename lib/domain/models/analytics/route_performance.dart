import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'route_performance.freezed.dart';
part 'route_performance.g.dart';

/// Route performance metrics for analytics
///
/// Tracks performance indicators for individual hiking routes:
/// - Sales volume and revenue
/// - Customer ratings and reviews
/// - Conversion rate (views to purchases)
/// - Monthly sales trends
@freezed
abstract class RoutePerformance with _$RoutePerformance {
  const RoutePerformance._();

  const factory RoutePerformance({
    required int routeId,
    required String routeName,
    required int totalSales,
    required double totalRevenue,
    required double averageRating,
    required int reviewCount,
    required double conversionRate,
    required int totalViews,
    @Default({}) Map<String, int> salesByMonth,
  }) = _RoutePerformance;

  factory RoutePerformance.fromJson(Map<String, dynamic> json) =>
      _$RoutePerformanceFromJson(json);

  /// Returns formatted revenue with Euro symbol
  String get formattedRevenue {
    return NumberFormat.currency(locale: 'de_DE', symbol: '€')
        .format(totalRevenue);
  }

  /// Returns formatted average revenue per sale
  String get formattedAverageRevenue {
    final avgRevenue = totalSales > 0 ? totalRevenue / totalSales : 0.0;
    return NumberFormat.currency(locale: 'de_DE', symbol: '€')
        .format(avgRevenue);
  }

  /// Returns formatted conversion rate as percentage
  String get formattedConversionRate {
    return '${(conversionRate * 100).toStringAsFixed(1)}%';
  }

  /// Returns formatted average rating with one decimal
  String get formattedRating {
    return averageRating.toStringAsFixed(1);
  }

  /// Returns monthly sales sorted by date
  List<MapEntry<String, int>> get monthlySalesTimeline {
    final entries = salesByMonth.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Checks if the route has good performance (>4.0 rating, >50% conversion)
  bool get hasGoodPerformance {
    return averageRating >= 4.0 && conversionRate >= 0.5;
  }

  /// Returns performance score (0-100) based on multiple factors
  /// Weighted: 40% conversion, 30% rating, 30% sales volume
  double get performanceScore {
    // Normalize conversion rate (0-100%)
    final conversionScore = conversionRate * 100;

    // Normalize rating (0-5 → 0-100)
    final ratingScore = (averageRating / 5.0) * 100;

    // Normalize sales (assume max 100 sales for normalization)
    final salesScore = (totalSales / 100.0).clamp(0.0, 1.0) * 100;

    return (conversionScore * 0.4) + (ratingScore * 0.3) + (salesScore * 0.3);
  }

  /// Returns best performing month by sales count
  String? get bestMonth {
    if (salesByMonth.isEmpty) return null;
    return salesByMonth.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Creates an empty RoutePerformance instance
  factory RoutePerformance.empty(int routeId, String routeName) {
    return RoutePerformance(
      routeId: routeId,
      routeName: routeName,
      totalSales: 0,
      totalRevenue: 0.0,
      averageRating: 0.0,
      reviewCount: 0,
      conversionRate: 0.0,
      totalViews: 0,
      salesByMonth: {},
    );
  }
}
