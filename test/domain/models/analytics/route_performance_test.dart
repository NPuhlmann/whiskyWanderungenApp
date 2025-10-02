import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/analytics/route_performance.dart';

void main() {
  group('RoutePerformance', () {
    group('creation', () {
      test('should create RoutePerformance with required fields', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Highland Trail',
          totalSales: 50,
          totalRevenue: 2500.0,
          averageRating: 4.5,
          reviewCount: 20,
          conversionRate: 0.25,
          totalViews: 200,
        );

        expect(performance.routeId, 1);
        expect(performance.routeName, 'Highland Trail');
        expect(performance.totalSales, 50);
        expect(performance.totalRevenue, 2500.0);
        expect(performance.averageRating, 4.5);
        expect(performance.conversionRate, 0.25);
      });

      test('should create empty RoutePerformance', () {
        final performance = RoutePerformance.empty(1, 'Test Route');

        expect(performance.routeId, 1);
        expect(performance.routeName, 'Test Route');
        expect(performance.totalSales, 0);
        expect(performance.totalRevenue, 0.0);
        expect(performance.averageRating, 0.0);
        expect(performance.conversionRate, 0.0);
      });
    });

    group('formatting', () {
      test('should format revenue with Euro symbol', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 10,
          totalRevenue: 1234.56,
          averageRating: 4.0,
          reviewCount: 5,
          conversionRate: 0.5,
          totalViews: 20,
        );

        expect(performance.formattedRevenue, contains('1.234,56'));
        expect(performance.formattedRevenue, contains('€'));
      });

      test('should format conversion rate as percentage', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 25,
          totalRevenue: 1250.0,
          averageRating: 4.0,
          reviewCount: 10,
          conversionRate: 0.251,
          totalViews: 100,
        );

        expect(performance.formattedConversionRate, '25.1%');
      });

      test('should format rating with one decimal', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 10,
          totalRevenue: 500.0,
          averageRating: 4.567,
          reviewCount: 15,
          conversionRate: 0.1,
          totalViews: 100,
        );

        expect(performance.formattedRating, '4.6');
      });

      test('should format average revenue per sale', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 10,
          totalRevenue: 1000.0,
          averageRating: 4.0,
          reviewCount: 5,
          conversionRate: 0.5,
          totalViews: 20,
        );

        expect(performance.formattedAverageRevenue, contains('100,00'));
        expect(performance.formattedAverageRevenue, contains('€'));
      });

      test('should handle zero sales in average revenue calculation', () {
        final performance = RoutePerformance.empty(1, 'Test');

        expect(performance.formattedAverageRevenue, contains('0,00'));
      });
    });

    group('performance metrics', () {
      test('should identify good performance', () {
        final goodPerformance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 100,
          totalRevenue: 5000.0,
          averageRating: 4.5,
          reviewCount: 50,
          conversionRate: 0.6,
          totalViews: 167,
        );

        expect(goodPerformance.hasGoodPerformance, isTrue);
      });

      test('should identify poor performance', () {
        final poorPerformance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 5,
          totalRevenue: 250.0,
          averageRating: 3.0,
          reviewCount: 2,
          conversionRate: 0.2,
          totalViews: 25,
        );

        expect(poorPerformance.hasGoodPerformance, isFalse);
      });

      test('should calculate performance score correctly', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 50,
          totalRevenue: 2500.0,
          averageRating: 5.0,
          reviewCount: 20,
          conversionRate: 0.5,
          totalViews: 100,
        );

        // 50% conversion * 40 + 100% rating * 30 + 50% sales * 30
        // = 20 + 30 + 15 = 65
        final score = performance.performanceScore;
        expect(score, greaterThan(60.0));
        expect(score, lessThan(70.0));
      });

      test('should handle edge cases in performance score', () {
        final performance = RoutePerformance.empty(1, 'Test');

        final score = performance.performanceScore;
        expect(score, 0.0);
      });
    });

    group('monthly sales', () {
      test('should return monthly sales timeline sorted', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 60,
          totalRevenue: 3000.0,
          averageRating: 4.0,
          reviewCount: 10,
          conversionRate: 0.3,
          totalViews: 200,
          salesByMonth: {
            '2025-03': 20,
            '2025-01': 10,
            '2025-02': 30,
          },
        );

        final timeline = performance.monthlySalesTimeline;

        expect(timeline.length, 3);
        expect(timeline[0].key, '2025-01');
        expect(timeline[0].value, 10);
        expect(timeline[1].key, '2025-02');
        expect(timeline[2].key, '2025-03');
      });

      test('should identify best month', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test',
          totalSales: 60,
          totalRevenue: 3000.0,
          averageRating: 4.0,
          reviewCount: 10,
          conversionRate: 0.3,
          totalViews: 200,
          salesByMonth: {
            '2025-01': 10,
            '2025-02': 30,
            '2025-03': 20,
          },
        );

        expect(performance.bestMonth, '2025-02');
      });

      test('should return null for best month when no sales data', () {
        final performance = RoutePerformance.empty(1, 'Test');

        expect(performance.bestMonth, isNull);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON', () {
        final performance = RoutePerformance(
          routeId: 1,
          routeName: 'Test Route',
          totalSales: 50,
          totalRevenue: 2500.0,
          averageRating: 4.5,
          reviewCount: 20,
          conversionRate: 0.25,
          totalViews: 200,
          salesByMonth: {'2025-01': 50},
        );

        final json = performance.toJson();

        expect(json['routeId'], 1);
        expect(json['routeName'], 'Test Route');
        expect(json['totalSales'], 50);
        expect(json['conversionRate'], 0.25);
      });

      test('should deserialize from JSON', () {
        final json = {
          'routeId': 2,
          'routeName': 'Island Trail',
          'totalSales': 30,
          'totalRevenue': 1500.0,
          'averageRating': 4.2,
          'reviewCount': 15,
          'conversionRate': 0.3,
          'totalViews': 100,
          'salesByMonth': {'2025-01': 30},
        };

        final performance = RoutePerformance.fromJson(json);

        expect(performance.routeId, 2);
        expect(performance.routeName, 'Island Trail');
        expect(performance.totalSales, 30);
        expect(performance.conversionRate, 0.3);
      });
    });
  });
}
