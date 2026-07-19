import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/providers/analytics_provider.dart';
import 'package:whisky_hikes/data/services/analytics/customer_analytics_service.dart';
import 'package:whisky_hikes/data/services/analytics/sales_analytics_service.dart';
import 'package:whisky_hikes/domain/models/analytics/customer_insights.dart';
import 'package:whisky_hikes/domain/models/analytics/route_performance.dart';
import 'package:whisky_hikes/domain/models/analytics/sales_statistics.dart';

class _FakeSales implements SalesAnalyticsService {
  SalesStatistics stats;
  List<RoutePerformance> routes;
  Object? error;
  int statsCalls = 0;
  DateTime? lastStart;
  DateTime? lastEnd;
  String? lastCompanyId;

  _FakeSales({required this.stats, required this.routes});

  @override
  Future<SalesStatistics> getSalesStatistics({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) async {
    statsCalls++;
    lastStart = startDate;
    lastEnd = endDate;
    lastCompanyId = companyId;
    if (error != null) throw error!;
    return stats;
  }

  @override
  Future<RoutePerformance> getRoutePerformance(int routeId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<RoutePerformance>> getTopRoutes({int limit = 10}) async {
    if (error != null) throw error!;
    return routes.take(limit).toList();
  }
}

class _FakeCustomer implements CustomerAnalyticsService {
  CustomerInsights insights;
  Map<String, int> segmentation;
  int churn;
  Object? error;

  _FakeCustomer({
    required this.insights,
    required this.segmentation,
    required this.churn,
  });

  @override
  Future<CustomerInsights> getCustomerInsights({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) async {
    if (error != null) throw error!;
    return insights;
  }

  @override
  Future<Map<String, int>> getCustomerSegmentation() async {
    if (error != null) throw error!;
    return segmentation;
  }

  @override
  Future<int> getChurnRiskCount({int days = 90}) async {
    if (error != null) throw error!;
    return churn;
  }
}

SalesStatistics _stats({double revenue = 100, int orders = 4}) =>
    SalesStatistics(
      totalOrders: orders,
      totalRevenue: revenue,
      averageOrderValue: orders == 0 ? 0 : revenue / orders,
      ordersByRoute: const {'1': 4},
      revenueByRoute: {'1': revenue},
      ordersByDate: const {'2026-05-01': 4},
      revenueByDate: {'2026-05-01': revenue},
    );

CustomerInsights _insights({int total = 3}) => CustomerInsights(
  totalCustomers: total,
  newCustomers: 1,
  returningCustomers: total - 1,
  repeatPurchaseRate: 0.5,
  averageLifetimeValue: 200,
);

void main() {
  group('AnalyticsProvider', () {
    test('load() füllt Sales-, Customer- und Top-Routes-Daten', () async {
      final sales = _FakeSales(
        stats: _stats(),
        routes: [
          const RoutePerformance(
            routeId: 1,
            routeName: 'A',
            totalSales: 4,
            totalRevenue: 100,
            averageRating: 4.5,
            reviewCount: 2,
            conversionRate: 0.25,
            totalViews: 16,
          ),
        ],
      );
      final customer = _FakeCustomer(
        insights: _insights(),
        segmentation: const {'high': 1, 'medium': 1, 'low': 1},
        churn: 2,
      );
      final p = AnalyticsProvider(
        salesService: sales,
        customerService: customer,
      );

      await p.load();

      expect(p.sales.totalRevenue, 100);
      expect(p.customerInsights.totalCustomers, 3);
      expect(p.topRoutes, hasLength(1));
      expect(p.segmentation['high'], 1);
      expect(p.churnRisk, 2);
      expect(p.error, isNull);
      expect(p.isLoading, isFalse);
    });

    test('setDateRange ruft Service mit neuen Daten auf', () async {
      final sales = _FakeSales(stats: _stats(), routes: const []);
      final customer = _FakeCustomer(
        insights: _insights(),
        segmentation: const {'high': 0, 'medium': 0, 'low': 0},
        churn: 0,
      );
      final p = AnalyticsProvider(
        salesService: sales,
        customerService: customer,
      );

      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 2, 1);
      await p.setDateRange(startDate: start, endDate: end);

      expect(sales.lastStart, start);
      expect(sales.lastEnd, end);
      expect(p.startDate, start);
      expect(p.endDate, end);
    });

    test('setCompanyId reicht companyId an Services weiter', () async {
      final sales = _FakeSales(stats: _stats(), routes: const []);
      final customer = _FakeCustomer(
        insights: _insights(),
        segmentation: const {'high': 0, 'medium': 0, 'low': 0},
        churn: 0,
      );
      final p = AnalyticsProvider(
        salesService: sales,
        customerService: customer,
      );

      await p.setCompanyId('cmp-1');

      expect(sales.lastCompanyId, 'cmp-1');
      expect(p.companyId, 'cmp-1');
    });

    test('Fehler setzt error und reset Daten auf empty', () async {
      final sales = _FakeSales(stats: _stats(), routes: const []);
      sales.error = Exception('boom');
      final customer = _FakeCustomer(
        insights: _insights(),
        segmentation: const {'high': 0, 'medium': 0, 'low': 0},
        churn: 0,
      );
      final p = AnalyticsProvider(
        salesService: sales,
        customerService: customer,
      );

      await p.load();

      expect(p.error, contains('boom'));
      expect(p.sales.totalOrders, 0);
      expect(p.customerInsights.totalCustomers, 0);
      expect(p.topRoutes, isEmpty);
    });

    test('clearError leert den Fehlerzustand', () async {
      final sales = _FakeSales(stats: _stats(), routes: const []);
      sales.error = Exception('boom');
      final customer = _FakeCustomer(
        insights: _insights(),
        segmentation: const {'high': 0, 'medium': 0, 'low': 0},
        churn: 0,
      );
      final p = AnalyticsProvider(
        salesService: sales,
        customerService: customer,
      );
      await p.load();
      expect(p.error, isNotNull);

      p.clearError();
      expect(p.error, isNull);
    });
  });
}
