import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'customer_insights.freezed.dart';
part 'customer_insights.g.dart';

/// Customer insights model for analytics
///
/// Provides insights into customer behavior:
/// - Customer acquisition and retention
/// - Repeat purchase patterns
/// - Customer lifetime value
/// - Geographic distribution
@freezed
abstract class CustomerInsights with _$CustomerInsights {
  const CustomerInsights._();

  const factory CustomerInsights({
    required int totalCustomers,
    required int newCustomers,
    required int returningCustomers,
    required double repeatPurchaseRate,
    required double averageLifetimeValue,
    @Default({}) Map<String, int> customersByLocation,
    @Default({}) Map<int, int> orderFrequencyDistribution,
  }) = _CustomerInsights;

  factory CustomerInsights.fromJson(Map<String, dynamic> json) =>
      _$CustomerInsightsFromJson(json);

  /// Returns formatted repeat purchase rate as percentage
  String get formattedRepeatPurchaseRate {
    return '${(repeatPurchaseRate * 100).toStringAsFixed(1)}%';
  }

  /// Returns formatted average lifetime value with Euro symbol
  String get formattedLifetimeValue {
    return NumberFormat.currency(locale: 'de_DE', symbol: '€')
        .format(averageLifetimeValue);
  }

  /// Percentage of new customers
  double get newCustomerRate {
    if (totalCustomers == 0) return 0.0;
    return newCustomers / totalCustomers;
  }

  /// Returns formatted new customer rate as percentage
  String get formattedNewCustomerRate {
    return '${(newCustomerRate * 100).toStringAsFixed(1)}%';
  }

  /// Returns top N locations by customer count
  List<MapEntry<String, int>> getTopLocations(int limit) {
    final entries = customersByLocation.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Returns most common location
  String? get topLocation {
    if (customersByLocation.isEmpty) return null;
    return customersByLocation.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Returns total customers from a specific location
  int getCustomersFromLocation(String location) {
    return customersByLocation[location] ?? 0;
  }

  /// Returns average orders per customer
  double get averageOrdersPerCustomer {
    if (totalCustomers == 0) return 0.0;

    int totalOrders = 0;
    orderFrequencyDistribution.forEach((orderCount, customerCount) {
      totalOrders += orderCount * customerCount;
    });

    return totalOrders / totalCustomers;
  }

  /// Returns formatted average orders per customer
  String get formattedAverageOrders {
    return averageOrdersPerCustomer.toStringAsFixed(1);
  }

  /// Checks if customer retention is healthy (>30% repeat purchase rate)
  bool get hasHealthyRetention {
    return repeatPurchaseRate >= 0.3;
  }

  /// Returns customer retention grade (A-F) based on repeat purchase rate
  String get retentionGrade {
    if (repeatPurchaseRate >= 0.5) return 'A';
    if (repeatPurchaseRate >= 0.4) return 'B';
    if (repeatPurchaseRate >= 0.3) return 'C';
    if (repeatPurchaseRate >= 0.2) return 'D';
    return 'F';
  }

  /// Creates an empty CustomerInsights instance
  factory CustomerInsights.empty() {
    return const CustomerInsights(
      totalCustomers: 0,
      newCustomers: 0,
      returningCustomers: 0,
      repeatPurchaseRate: 0.0,
      averageLifetimeValue: 0.0,
      customersByLocation: {},
      orderFrequencyDistribution: {},
    );
  }
}
