import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/analytics/sales_statistics.dart';

void main() {
  group('SalesStatistics', () {
    group('creation', () {
      test('should create SalesStatistics with required fields', () {
        final stats = SalesStatistics(
          totalOrders: 100,
          totalRevenue: 5000.0,
          averageOrderValue: 50.0,
        );

        expect(stats.totalOrders, 100);
        expect(stats.totalRevenue, 5000.0);
        expect(stats.averageOrderValue, 50.0);
      });

      test('should create empty SalesStatistics', () {
        final stats = SalesStatistics.empty();

        expect(stats.totalOrders, 0);
        expect(stats.totalRevenue, 0.0);
        expect(stats.averageOrderValue, 0.0);
        expect(stats.ordersByRoute, isEmpty);
        expect(stats.revenueByRoute, isEmpty);
      });

      test('should create SalesStatistics with route data', () {
        final stats = SalesStatistics(
          totalOrders: 15,
          totalRevenue: 1500.0,
          averageOrderValue: 100.0,
          ordersByRoute: {'1': 10, '2': 5},
          revenueByRoute: {'1': 1000.0, '2': 500.0},
        );

        expect(stats.ordersByRoute, {'1': 10, '2': 5});
        expect(stats.revenueByRoute, {'1': 1000.0, '2': 500.0});
      });
    });

    group('formatting', () {
      test('should format revenue with Euro symbol', () {
        final stats = SalesStatistics(
          totalOrders: 10,
          totalRevenue: 1234.56,
          averageOrderValue: 123.46,
        );

        expect(stats.formattedRevenue, contains('1.234,56'));
        expect(stats.formattedRevenue, contains('€'));
      });

      test('should format average order value with Euro symbol', () {
        final stats = SalesStatistics(
          totalOrders: 10,
          totalRevenue: 1000.0,
          averageOrderValue: 100.0,
        );

        expect(stats.formattedAverageOrderValue, contains('100,00'));
        expect(stats.formattedAverageOrderValue, contains('€'));
      });
    });

    group('route analysis', () {
      test('should return correct route count', () {
        final stats = SalesStatistics(
          totalOrders: 30,
          totalRevenue: 3000.0,
          averageOrderValue: 100.0,
          ordersByRoute: {'1': 10, '2': 15, '3': 5},
        );

        expect(stats.routeCount, 3);
      });

      test('should identify most popular route', () {
        final stats = SalesStatistics(
          totalOrders: 30,
          totalRevenue: 3000.0,
          averageOrderValue: 100.0,
          ordersByRoute: {'1': 10, '2': 15, '3': 5},
        );

        expect(stats.mostPopularRouteId, '2');
      });

      test('should return null for most popular route when no orders', () {
        final stats = SalesStatistics.empty();

        expect(stats.mostPopularRouteId, isNull);
      });

      test('should get revenue for specific route', () {
        final stats = SalesStatistics(
          totalOrders: 15,
          totalRevenue: 1500.0,
          averageOrderValue: 100.0,
          revenueByRoute: {'1': 1000.0, '2': 500.0},
        );

        expect(stats.getRevenueForRoute('1'), 1000.0);
        expect(stats.getRevenueForRoute('2'), 500.0);
        expect(stats.getRevenueForRoute('3'), 0.0);
      });

      test('should get orders for specific route', () {
        final stats = SalesStatistics(
          totalOrders: 15,
          totalRevenue: 1500.0,
          averageOrderValue: 100.0,
          ordersByRoute: {'1': 10, '2': 5},
        );

        expect(stats.getOrdersForRoute('1'), 10);
        expect(stats.getOrdersForRoute('2'), 5);
        expect(stats.getOrdersForRoute('3'), 0);
      });
    });

    group('top routes', () {
      test('should return top routes by revenue', () {
        final stats = SalesStatistics(
          totalOrders: 60,
          totalRevenue: 6000.0,
          averageOrderValue: 100.0,
          revenueByRoute: {
            '1': 2000.0,
            '2': 1500.0,
            '3': 1200.0,
            '4': 800.0,
            '5': 500.0,
          },
        );

        final topRoutes = stats.getTopRoutesByRevenue(3);

        expect(topRoutes.length, 3);
        expect(topRoutes[0].key, '1');
        expect(topRoutes[0].value, 2000.0);
        expect(topRoutes[1].key, '2');
        expect(topRoutes[2].key, '3');
      });

      test('should return top routes by order count', () {
        final stats = SalesStatistics(
          totalOrders: 100,
          totalRevenue: 10000.0,
          averageOrderValue: 100.0,
          ordersByRoute: {
            '1': 30,
            '2': 25,
            '3': 20,
            '4': 15,
            '5': 10,
          },
        );

        final topRoutes = stats.getTopRoutesByOrders(2);

        expect(topRoutes.length, 2);
        expect(topRoutes[0].key, '1');
        expect(topRoutes[0].value, 30);
        expect(topRoutes[1].key, '2');
      });

      test('should limit top routes correctly', () {
        final stats = SalesStatistics(
          totalOrders: 15,
          totalRevenue: 1500.0,
          averageOrderValue: 100.0,
          ordersByRoute: {'1': 10, '2': 5},
        );

        final topRoutes = stats.getTopRoutesByOrders(10);

        expect(topRoutes.length, 2); // Only 2 routes available
      });
    });

    group('timeline analysis', () {
      test('should return revenue timeline sorted by date', () {
        final stats = SalesStatistics(
          totalOrders: 30,
          totalRevenue: 3000.0,
          averageOrderValue: 100.0,
          revenueByDate: {
            '2025-01-03': 300.0,
            '2025-01-01': 100.0,
            '2025-01-02': 200.0,
          },
        );

        final timeline = stats.revenueTimeline;

        expect(timeline.length, 3);
        expect(timeline[0].key, '2025-01-01');
        expect(timeline[1].key, '2025-01-02');
        expect(timeline[2].key, '2025-01-03');
      });

      test('should return orders timeline sorted by date', () {
        final stats = SalesStatistics(
          totalOrders: 30,
          totalRevenue: 3000.0,
          averageOrderValue: 100.0,
          ordersByDate: {
            '2025-01-03': 10,
            '2025-01-01': 5,
            '2025-01-02': 15,
          },
        );

        final timeline = stats.ordersTimeline;

        expect(timeline.length, 3);
        expect(timeline[0].key, '2025-01-01');
        expect(timeline[0].value, 5);
        expect(timeline[1].value, 15);
        expect(timeline[2].value, 10);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON', () {
        final stats = SalesStatistics(
          totalOrders: 10,
          totalRevenue: 1000.0,
          averageOrderValue: 100.0,
          ordersByRoute: {'1': 5, '2': 5},
          revenueByRoute: {'1': 500.0, '2': 500.0},
        );

        final json = stats.toJson();

        expect(json['totalOrders'], 10);
        expect(json['totalRevenue'], 1000.0);
        expect(json['averageOrderValue'], 100.0);
      });

      test('should deserialize from JSON', () {
        final json = <String, dynamic>{
          'totalOrders': 20,
          'totalRevenue': 2000.0,
          'averageOrderValue': 100.0,
          'ordersByRoute': <String, dynamic>{'1': 10, '2': 10},
          'revenueByRoute': <String, dynamic>{'1': 1000.0, '2': 1000.0},
          'ordersByDate': <String, dynamic>{},
          'revenueByDate': <String, dynamic>{},
        };

        final stats = SalesStatistics.fromJson(json);

        expect(stats.totalOrders, 20);
        expect(stats.totalRevenue, 2000.0);
        expect(stats.ordersByRoute, {'1': 10, '2': 10});
      });
    });
  });
}
