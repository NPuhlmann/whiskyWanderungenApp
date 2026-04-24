import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/analytics/performance_metrics.dart';

void main() {
  group('PerformanceMetrics', () {
    group('creation', () {
      test('should create PerformanceMetrics with required fields', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.08,
          averageOrderValue: 125.0,
          customerLifetimeValue: 450.0,
          totalViews: 1000,
          totalPurchases: 80,
        );

        expect(metrics.conversionRate, 0.08);
        expect(metrics.averageOrderValue, 125.0);
        expect(metrics.customerLifetimeValue, 450.0);
        expect(metrics.totalViews, 1000);
        expect(metrics.totalPurchases, 80);
      });

      test('should create empty PerformanceMetrics', () {
        final metrics = PerformanceMetrics.empty();

        expect(metrics.conversionRate, 0.0);
        expect(metrics.averageOrderValue, 0.0);
        expect(metrics.customerLifetimeValue, 0.0);
        expect(metrics.totalViews, 0);
        expect(metrics.totalPurchases, 0);
      });

      test('should create with period metrics', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 500,
          totalPurchases: 50,
          metricsByPeriod: {'2025-01': 0.08, '2025-02': 0.12},
        );

        expect(metrics.metricsByPeriod.length, 2);
      });
    });

    group('formatting', () {
      test('should format conversion rate as percentage', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.0876,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 88,
        );

        expect(metrics.formattedConversionRate, '8.76%');
      });

      test('should format average order value with Euro symbol', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 1234.56,
          customerLifetimeValue: 300.0,
          totalViews: 100,
          totalPurchases: 10,
        );

        expect(metrics.formattedAverageOrderValue, contains('1.234,56'));
        expect(metrics.formattedAverageOrderValue, contains('€'));
      });

      test('should format customer lifetime value with Euro symbol', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 100.0,
          customerLifetimeValue: 567.89,
          totalViews: 100,
          totalPurchases: 10,
        );

        expect(metrics.formattedCustomerLifetimeValue, contains('567,89'));
        expect(metrics.formattedCustomerLifetimeValue, contains('€'));
      });

      test('should format total views with thousand separators', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.05,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 123456,
          totalPurchases: 6173,
        );

        expect(metrics.formattedTotalViews, contains('123.456'));
      });

      test('should format total purchases with thousand separators', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 50000,
          totalPurchases: 5000,
        );

        expect(metrics.formattedTotalPurchases, contains('5.000'));
      });
    });

    group('conversion health', () {
      test('should identify healthy conversion rate', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.06,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 60,
        );

        expect(metrics.hasHealthyConversion, isTrue);
      });

      test('should identify poor conversion rate', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.03,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 30,
        );

        expect(metrics.hasHealthyConversion, isFalse);
      });
    });

    group('conversion grades', () {
      test('should assign grade A for excellent conversion', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.12,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 120,
        );

        expect(metrics.conversionGrade, 'A');
      });

      test('should assign grade B for good conversion', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.08,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 80,
        );

        expect(metrics.conversionGrade, 'B');
      });

      test('should assign grade C for acceptable conversion', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.06,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 60,
        );

        expect(metrics.conversionGrade, 'C');
      });

      test('should assign grade D for poor conversion', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.04,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 40,
        );

        expect(metrics.conversionGrade, 'D');
      });

      test('should assign grade F for very poor conversion', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.02,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 20,
        );

        expect(metrics.conversionGrade, 'F');
      });
    });

    group('period metrics', () {
      test('should get metric for specific period', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 100,
          metricsByPeriod: {'2025-01': 0.08, '2025-02': 0.12, '2025-03': 0.10},
        );

        expect(metrics.getMetricForPeriod('2025-01'), 0.08);
        expect(metrics.getMetricForPeriod('2025-02'), 0.12);
        expect(metrics.getMetricForPeriod('2025-04'), isNull);
      });

      test('should return metrics timeline sorted by period', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 100,
          metricsByPeriod: {'2025-03': 0.10, '2025-01': 0.08, '2025-02': 0.12},
        );

        final timeline = metrics.metricsTimeline;

        expect(timeline.length, 3);
        expect(timeline[0].key, '2025-01');
        expect(timeline[0].value, 0.08);
        expect(timeline[1].key, '2025-02');
        expect(timeline[2].key, '2025-03');
      });
    });

    group('potential revenue', () {
      test('should calculate potential revenue correctly', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 100,
        );

        // 1000 views * 100€ AOV * 0.1 conversion = 10,000€
        expect(metrics.potentialRevenue, 10000.0);
      });

      test('should format potential revenue with Euro symbol', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.08,
          averageOrderValue: 125.0,
          customerLifetimeValue: 300.0,
          totalViews: 2000,
          totalPurchases: 160,
        );

        // 2000 * 125 * 0.08 = 20,000€
        expect(metrics.formattedPotentialRevenue, contains('20.000'));
        expect(metrics.formattedPotentialRevenue, contains('€'));
      });

      test('should handle zero values in potential revenue', () {
        final metrics = PerformanceMetrics.empty();

        expect(metrics.potentialRevenue, 0.0);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON', () {
        final metrics = PerformanceMetrics(
          conversionRate: 0.1,
          averageOrderValue: 100.0,
          customerLifetimeValue: 300.0,
          totalViews: 1000,
          totalPurchases: 100,
          metricsByPeriod: {'2025-01': 0.08},
        );

        final json = metrics.toJson();

        expect(json['conversionRate'], 0.1);
        expect(json['averageOrderValue'], 100.0);
        expect(json['totalViews'], 1000);
      });

      test('should deserialize from JSON', () {
        final json = {
          'conversionRate': 0.12,
          'averageOrderValue': 125.0,
          'customerLifetimeValue': 400.0,
          'totalViews': 2000,
          'totalPurchases': 240,
          'metricsByPeriod': {'2025-01': 0.12},
        };

        final metrics = PerformanceMetrics.fromJson(json);

        expect(metrics.conversionRate, 0.12);
        expect(metrics.averageOrderValue, 125.0);
        expect(metrics.totalViews, 2000);
      });
    });
  });
}
