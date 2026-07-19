import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/services/analytics/analytics_export_service.dart';
import 'package:whisky_hikes/domain/models/analytics/customer_insights.dart';
import 'package:whisky_hikes/domain/models/analytics/route_performance.dart';
import 'package:whisky_hikes/domain/models/analytics/sales_statistics.dart';

void main() {
  group('AnalyticsExportService', () {
    late AnalyticsExportService service;
    late SalesStatistics sales;
    late CustomerInsights insights;
    late List<RoutePerformance> topRoutes;

    setUp(() {
      service = AnalyticsExportService();
      sales = const SalesStatistics(
        totalOrders: 4,
        totalRevenue: 320.0,
        averageOrderValue: 80.0,
        ordersByRoute: {'100': 2, '101': 1, '102': 1},
        revenueByRoute: {'100': 200.0, '101': 80.0, '102': 40.0},
        ordersByDate: {'2026-05-15': 2, '2026-05-16': 2},
        revenueByDate: {'2026-05-15': 200.0, '2026-05-16': 120.0},
      );
      insights = const CustomerInsights(
        totalCustomers: 10,
        newCustomers: 4,
        returningCustomers: 6,
        repeatPurchaseRate: 0.4,
        averageLifetimeValue: 150.0,
        customersByLocation: {'Berlin': 5, 'München': 3},
        orderFrequencyDistribution: {1: 4, 2: 4, 3: 2},
      );
      topRoutes = [
        const RoutePerformance(
          routeId: 100,
          routeName: 'Speyside-Tour',
          totalSales: 12,
          totalRevenue: 900.0,
          averageRating: 4.6,
          reviewCount: 8,
          conversionRate: 0.6,
          totalViews: 20,
          salesByMonth: {'2026-05': 12},
        ),
        const RoutePerformance(
          routeId: 101,
          routeName: 'Islay-Wanderung',
          totalSales: 7,
          totalRevenue: 525.0,
          averageRating: 4.2,
          reviewCount: 5,
          conversionRate: 0.4,
          totalViews: 17,
          salesByMonth: {'2026-05': 7},
        ),
      ];
    });

    group('generateAnalyticsPDF', () {
      test('produces a non-empty PDF byte stream', () async {
        final bytes = await service.generateAnalyticsPDF(
          sales: sales,
          insights: insights,
          topRoutes: topRoutes,
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 31),
          segmentation: const {'high': 2, 'medium': 5, 'low': 3},
          churnRisk: 1,
        );

        expect(bytes.length, greaterThan(100));
        // PDFs start with the %PDF magic header.
        final header = String.fromCharCodes(bytes.sublist(0, 4));
        expect(header, '%PDF');
      });

      test('throws ArgumentError when startDate is after endDate', () {
        expect(
          () => service.generateAnalyticsPDF(
            sales: sales,
            insights: insights,
            topRoutes: topRoutes,
            startDate: DateTime(2026, 6, 1),
            endDate: DateTime(2026, 5, 1),
          ),
          throwsArgumentError,
        );
      });

      test('handles empty datasets gracefully', () async {
        final bytes = await service.generateAnalyticsPDF(
          sales: SalesStatistics.empty(),
          insights: CustomerInsights.empty(),
          topRoutes: const [],
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 31),
        );
        expect(bytes.length, greaterThan(100));
      });
    });

    List<String> splitCsv(String content) => content
        .split(RegExp(r'\r?\n'))
        .where((line) => line.isNotEmpty)
        .toList();

    group('generateRevenueTimelineCSV', () {
      test('writes header + one row per day, sorted by date', () {
        final csvOutput = service.generateRevenueTimelineCSV(sales);
        final lines = splitCsv(csvOutput);

        expect(lines.first, 'Datum,Umsatz (EUR),Bestellungen');
        expect(lines.length, 3); // header + 2 days
        expect(lines[1], startsWith('2026-05-15'));
        expect(lines[1], contains('200.00'));
        expect(lines[1], endsWith('2'));
        expect(lines[2], contains('120.00'));
      });

      test('returns header-only CSV when there are no revenue entries', () {
        final csvOutput = service.generateRevenueTimelineCSV(
          SalesStatistics.empty(),
        );
        final lines = splitCsv(csvOutput);
        expect(lines.length, 1);
        expect(lines.first, 'Datum,Umsatz (EUR),Bestellungen');
      });
    });

    group('generateRouteBreakdownCSV', () {
      test('lists routes sorted by revenue descending', () {
        final csvOutput = service.generateRouteBreakdownCSV(
          sales,
          performances: topRoutes,
        );
        final lines = splitCsv(csvOutput);

        expect(lines.first, 'Route ID,Route Name,Umsatz (EUR),Bestellungen');
        expect(lines[1], startsWith('100,Speyside-Tour'));
        expect(lines[2], startsWith('101,Islay-Wanderung'));
        expect(lines[3], startsWith('102,'));
        // Route #102 has no name in performances → fallback label.
        expect(lines[3], contains('Route #102'));
      });

      test('handles routes without a known name', () {
        final csvOutput = service.generateRouteBreakdownCSV(sales);
        final lines = splitCsv(csvOutput);
        expect(lines.length, 4); // header + 3 routes
        expect(lines[1], contains('Route #100'));
      });
    });

    group('generateExportFilename', () {
      test('includes the slug and timestamp with the requested extension', () {
        final filename = service.generateExportFilename(
          type: 'csv',
          slug: 'Sales Timeline',
        );
        expect(filename, startsWith('analytics_sales_timeline_'));
        expect(filename, endsWith('.csv'));
      });

      test('falls back to "export" when slug sanitises to empty', () {
        final filename = service.generateExportFilename(
          type: 'pdf',
          slug: '---',
        );
        expect(filename, startsWith('analytics_export_'));
        expect(filename, endsWith('.pdf'));
      });
    });
  });
}
