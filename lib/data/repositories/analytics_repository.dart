import '../../domain/models/analytics/customer_insights.dart';
import '../../domain/models/analytics/route_performance.dart';
import '../../domain/models/analytics/sales_statistics.dart';
import '../services/analytics/customer_analytics_service.dart';
import '../services/analytics/sales_analytics_service.dart';

/// Repository für Verkaufs- und Kundenauswertungen (ADR-0004).
///
/// Reiner Pass-through auf [SalesAnalyticsService] und
/// [CustomerAnalyticsService]; die Aggregationslogik bleibt dort.
class AnalyticsRepository {
  final SalesAnalyticsService _sales;
  final CustomerAnalyticsService _customer;

  AnalyticsRepository({
    required SalesAnalyticsService salesService,
    required CustomerAnalyticsService customerService,
  }) : _sales = salesService,
       _customer = customerService;

  Future<SalesStatistics> getSalesStatistics({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) => _sales.getSalesStatistics(
    startDate: startDate,
    endDate: endDate,
    companyId: companyId,
  );

  Future<List<RoutePerformance>> getTopRoutes({int limit = 10}) =>
      _sales.getTopRoutes(limit: limit);

  Future<CustomerInsights> getCustomerInsights({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) => _customer.getCustomerInsights(
    startDate: startDate,
    endDate: endDate,
    companyId: companyId,
  );

  Future<Map<String, int>> getCustomerSegmentation() =>
      _customer.getCustomerSegmentation();

  Future<int> getChurnRiskCount({int days = 90}) =>
      _customer.getChurnRiskCount(days: days);
}
