import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/admin/dashboard_metrics_service.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
import 'dashboard_metrics_service_test.mocks.dart';

void main() {
  group('DashboardMetricsService Tests', () {
    late DashboardMetricsService service;
    late MockSupabaseClient mockClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      service = DashboardMetricsService(client: mockClient);
    });

    group('Revenue Metrics', () {
      test('should calculate daily revenue correctly', () async {
        final today = DateTime.now();
        final todayStr = today.toIso8601String().split('T')[0];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('total_amount')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', '$todayStr 00:00:00')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.lt('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'completed')).thenReturn(mockFilterBuilder);

        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'total_amount': 89.99},
          {'total_amount': 79.99},
          {'total_amount': 99.99},
        ]);

        final revenue = await service.getDailyRevenue();

        expect(revenue, equals(269.97));
        verify(mockClient.from('orders')).called(1);
      });

      test('should calculate weekly revenue correctly', () async {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartStr = weekStart.toIso8601String().split('T')[0];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('total_amount')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', '$weekStartStr 00:00:00')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'completed')).thenReturn(mockFilterBuilder);

        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'total_amount': 89.99},
          {'total_amount': 79.99},
          {'total_amount': 99.99},
          {'total_amount': 119.99},
          {'total_amount': 69.99},
        ]);

        final revenue = await service.getWeeklyRevenue();

        expect(revenue, equals(459.95));
      });

      test('should calculate monthly revenue correctly', () async {
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final monthStartStr = monthStart.toIso8601String().split('T')[0];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('total_amount')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', '$monthStartStr 00:00:00')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'completed')).thenReturn(mockFilterBuilder);

        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'total_amount': 1200.50},
          {'total_amount': 890.25},
          {'total_amount': 1450.75},
        ]);

        final revenue = await service.getMonthlyRevenue();

        expect(revenue, equals(3541.50));
      });

      test('should handle empty revenue data gracefully', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('total_amount')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.lt('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'completed')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => []);

        final revenue = await service.getDailyRevenue();

        expect(revenue, equals(0.0));
      });
    });

    group('Order Metrics', () {
      test('should count active orders by status', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'pending')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'id': 1}, {'id': 2}, {'id': 3}
        ]);

        final count = await service.getActiveOrdersByStatus('pending');

        expect(count, equals(3));
        verify(mockFilterBuilder.eq('status', 'pending')).called(1);
      });

      test('should get total active orders correctly', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.in_('status', ['pending', 'processing', 'shipped'])).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'id': 1}, {'id': 2}, {'id': 3}, {'id': 4}, {'id': 5}
        ]);

        final count = await service.getTotalActiveOrders();

        expect(count, equals(5));
      });

      test('should get recent orders with details', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(10)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {
            'id': 1,
            'customer_name': 'John Doe',
            'total_amount': 89.99,
            'status': 'pending',
            'created_at': '2024-01-15T10:00:00Z',
            'hike_name': 'Highland Adventure'
          },
          {
            'id': 2,
            'customer_name': 'Jane Smith',
            'total_amount': 79.99,
            'status': 'processing',
            'created_at': '2024-01-14T15:30:00Z',
            'hike_name': 'Speyside Journey'
          }
        ]);

        final orders = await service.getRecentOrders();

        expect(orders.length, equals(2));
        expect(orders[0]['customer_name'], equals('John Doe'));
        expect(orders[1]['total_amount'], equals(79.99));
      });
    });

    group('Route Metrics', () {
      test('should count sold routes for different periods', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.lt('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'completed')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'id': 1}, {'id': 2}, {'id': 3}, {'id': 4}
        ]);

        final count = await service.getSoldRoutesToday();

        expect(count, equals(4));
      });

      test('should get most popular routes', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'completed')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'hike_id': 1, 'hike_name': 'Highland Adventure', 'count': 15},
          {'hike_id': 2, 'hike_name': 'Speyside Journey', 'count': 12},
          {'hike_id': 3, 'hike_name': 'Islay Challenge', 'count': 8}
        ]);

        final popularRoutes = await service.getMostPopularRoutes();

        expect(popularRoutes.length, equals(3));
        expect(popularRoutes[0]['hike_name'], equals('Highland Adventure'));
        expect(popularRoutes[0]['count'], equals(15));
      });
    });

    group('Customer Metrics', () {
      test('should calculate average customer rating', () async {
        when(mockClient.from('reviews')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('rating')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => [
          {'rating': 5}, {'rating': 4}, {'rating': 5}, {'rating': 3}, {'rating': 4}
        ]);

        final avgRating = await service.getAverageCustomerRating();

        expect(avgRating, equals(4.2));
      });

      test('should handle empty ratings gracefully', () async {
        when(mockClient.from('reviews')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('rating')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenAnswer((_) async => []);

        final avgRating = await service.getAverageCustomerRating();

        expect(avgRating, equals(0.0));
      });
    });

    group('Comprehensive Dashboard Metrics', () {
      test('should get all dashboard metrics in one call', () async {
        // Mock all the required calls for getDashboardMetrics
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockClient.from('reviews')).thenReturn(mockQueryBuilder);

        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.lt('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.in_('status', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order(any, ascending: anyNamed('ascending'))).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(any)).thenReturn(mockFilterBuilder);

        // Mock responses for different metrics
        when(mockFilterBuilder.execute()).thenAnswer((invocation) async {
          // This is a simplified mock - in reality we'd need to distinguish between calls
          return [
            {'total_amount': 150.0, 'id': 1, 'rating': 4}
          ];
        });

        final metrics = await service.getDashboardMetrics();

        expect(metrics, isA<Map<String, dynamic>>());
        expect(metrics.containsKey('dailyRevenue'), isTrue);
        expect(metrics.containsKey('weeklyRevenue'), isTrue);
        expect(metrics.containsKey('monthlyRevenue'), isTrue);
        expect(metrics.containsKey('totalActiveOrders'), isTrue);
        expect(metrics.containsKey('pendingOrders'), isTrue);
        expect(metrics.containsKey('processingOrders'), isTrue);
        expect(metrics.containsKey('shippedOrders'), isTrue);
        expect(metrics.containsKey('soldRoutesToday'), isTrue);
        expect(metrics.containsKey('soldRoutesThisWeek'), isTrue);
        expect(metrics.containsKey('soldRoutesThisMonth'), isTrue);
        expect(metrics.containsKey('avgCustomerRating'), isTrue);
        expect(metrics.containsKey('recentOrders'), isTrue);
        expect(metrics.containsKey('popularRoutes'), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully for revenue', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('total_amount')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.lt('created_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'completed')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenThrow(Exception('Database error'));

        expect(() => service.getDailyRevenue(), throwsException);
      });

      test('should handle database errors gracefully for orders', () async {
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'pending')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.execute()).thenThrow(Exception('Database error'));

        expect(() => service.getActiveOrdersByStatus('pending'), throwsException);
      });
    });

    group('Data Formatting', () {
      test('should format currency values correctly', () {
        expect(service.formatCurrency(1234.56), equals('€1,234.56'));
        expect(service.formatCurrency(0.0), equals('€0.00'));
        expect(service.formatCurrency(99.9), equals('€99.90'));
      });

      test('should format percentage values correctly', () {
        expect(service.formatPercentage(0.1234), equals('12.34%'));
        expect(service.formatPercentage(0.0), equals('0.00%'));
        expect(service.formatPercentage(1.0), equals('100.00%'));
      });

      test('should format large numbers with K/M suffixes', () {
        expect(service.formatNumber(1234), equals('1.2K'));
        expect(service.formatNumber(1234567), equals('1.2M'));
        expect(service.formatNumber(999), equals('999'));
      });
    });
  });
}