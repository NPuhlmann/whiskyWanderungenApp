import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'performance_metrics.freezed.dart';
part 'performance_metrics.g.dart';

/// Performance metrics model for analytics
///
/// Tracks key performance indicators (KPIs):
/// - Conversion rate (views to purchases)
/// - Average order value
/// - Customer lifetime value
/// - Metrics over time periods
@freezed
abstract class PerformanceMetrics with _$PerformanceMetrics {
  const PerformanceMetrics._();

  const factory PerformanceMetrics({
    required double conversionRate,
    required double averageOrderValue,
    required double customerLifetimeValue,
    required int totalViews,
    required int totalPurchases,
    @Default({}) Map<String, double> metricsByPeriod,
  }) = _PerformanceMetrics;

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricsFromJson(json);

  /// Returns formatted conversion rate as percentage
  String get formattedConversionRate {
    return '${(conversionRate * 100).toStringAsFixed(2)}%';
  }

  /// Returns formatted average order value with Euro symbol
  String get formattedAverageOrderValue {
    return NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
    ).format(averageOrderValue);
  }

  /// Returns formatted customer lifetime value with Euro symbol
  String get formattedCustomerLifetimeValue {
    return NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
    ).format(customerLifetimeValue);
  }

  /// Returns formatted total views with thousand separators
  String get formattedTotalViews {
    return NumberFormat.decimalPattern('de_DE').format(totalViews);
  }

  /// Returns formatted total purchases with thousand separators
  String get formattedTotalPurchases {
    return NumberFormat.decimalPattern('de_DE').format(totalPurchases);
  }

  /// Checks if conversion rate is healthy (>5%)
  bool get hasHealthyConversion {
    return conversionRate >= 0.05;
  }

  /// Returns conversion grade (A-F) based on rate
  /// A: >10%, B: >7%, C: >5%, D: >3%, F: ≤3%
  String get conversionGrade {
    if (conversionRate >= 0.10) return 'A';
    if (conversionRate >= 0.07) return 'B';
    if (conversionRate >= 0.05) return 'C';
    if (conversionRate >= 0.03) return 'D';
    return 'F';
  }

  /// Returns metrics for a specific period
  double? getMetricForPeriod(String period) {
    return metricsByPeriod[period];
  }

  /// Returns metrics timeline sorted by period
  List<MapEntry<String, double>> get metricsTimeline {
    final entries = metricsByPeriod.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Returns estimated total potential revenue (views * AOV * conversion)
  double get potentialRevenue {
    return totalViews * averageOrderValue * conversionRate;
  }

  /// Returns formatted potential revenue
  String get formattedPotentialRevenue {
    return NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
    ).format(potentialRevenue);
  }

  /// Creates an empty PerformanceMetrics instance
  factory PerformanceMetrics.empty() {
    return const PerformanceMetrics(
      conversionRate: 0.0,
      averageOrderValue: 0.0,
      customerLifetimeValue: 0.0,
      totalViews: 0,
      totalPurchases: 0,
      metricsByPeriod: {},
    );
  }
}
