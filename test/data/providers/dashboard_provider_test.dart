import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/providers/dashboard_provider.dart';
import 'package:whisky_hikes/data/services/admin/dashboard_metrics_service.dart';

@GenerateMocks([DashboardMetricsService])
import 'dashboard_provider_test.mocks.dart';

void main() {
  group('DashboardProvider Tests', () {
    late DashboardProvider provider;
    late MockDashboardMetricsService mockService;

    setUp(() {
      mockService = MockDashboardMetricsService();
      provider = DashboardProvider(metricsService: mockService);
    });

    group('Initial State', () {
      test('should initialize with correct default values', () {
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.metrics, isEmpty);
        expect(provider.recentOrders, isEmpty);
        expect(provider.popularRoutes, isEmpty);
      });
    });

    group('State Management', () {
      test('should set loading state correctly', () {
        provider.setLoading(true);
        expect(provider.isLoading, isTrue);

        provider.setLoading(false);
        expect(provider.isLoading, isFalse);
      });

      test('should set error message correctly', () {
        const errorMessage = 'Test error';
        provider.setError(errorMessage);
        expect(provider.errorMessage, equals(errorMessage));
      });

      test('should clear error message', () {
        provider.setError('Initial error');
        provider.clearError();
        expect(provider.errorMessage, isNull);
      });
    });

    group('Metrics Loading', () {
      test('should load dashboard metrics successfully', () async {
        final mockMetrics = {
          'dailyRevenue': 150.0,
          'weeklyRevenue': 800.0,
          'monthlyRevenue': 3500.0,
          'totalActiveOrders': 15,
          'pendingOrders': 5,
          'processingOrders': 7,
          'shippedOrders': 3,
          'soldRoutesToday': 2,
          'soldRoutesThisWeek': 12,
          'soldRoutesThisMonth': 45,
          'avgCustomerRating': 4.5,
          'recentOrders': [
            {
              'id': 1,
              'customer_name': 'John Doe',
              'total_amount': 89.99,
              'status': 'pending',
              'hike_name': 'Highland Adventure',
            },
          ],
          'popularRoutes': [
            {'hike_id': 1, 'hike_name': 'Highland Adventure', 'count': 15},
          ],
        };

        when(
          mockService.getDashboardMetrics(),
        ).thenAnswer((_) async => mockMetrics);

        await provider.loadDashboardData();

        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.metrics, equals(mockMetrics));
        expect(provider.recentOrders.length, equals(1));
        expect(provider.popularRoutes.length, equals(1));
        verify(mockService.getDashboardMetrics()).called(1);
      });

      test('should handle loading error gracefully', () async {
        when(
          mockService.getDashboardMetrics(),
        ).thenThrow(Exception('Database connection failed'));

        await provider.loadDashboardData();

        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNotNull);
        expect(provider.metrics, isEmpty);
      });

      test('should set loading state during async operation', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return <String, dynamic>{};
        });

        final loadingFuture = provider.loadDashboardData();

        // Should be loading immediately after calling
        expect(provider.isLoading, isTrue);

        await loadingFuture;

        // Should not be loading after completion
        expect(provider.isLoading, isFalse);
      });
    });

    group('Revenue Metrics', () {
      test('should return correct revenue values', () {
        provider.metrics = {
          'dailyRevenue': 150.50,
          'weeklyRevenue': 800.75,
          'monthlyRevenue': 3500.25,
        };

        expect(provider.dailyRevenue, equals(150.50));
        expect(provider.weeklyRevenue, equals(800.75));
        expect(provider.monthlyRevenue, equals(3500.25));
      });

      test('should return 0.0 for missing revenue data', () {
        provider.metrics = <String, dynamic>{};

        expect(provider.dailyRevenue, equals(0.0));
        expect(provider.weeklyRevenue, equals(0.0));
        expect(provider.monthlyRevenue, equals(0.0));
      });

      test('should format revenue correctly', () {
        when(mockService.formatCurrency(150.50)).thenReturn('150,50 €');
        when(mockService.formatCurrency(0.0)).thenReturn('0,00 €');

        provider.metrics = {'dailyRevenue': 150.50};

        expect(provider.formattedDailyRevenue, contains('150'));

        provider.metrics = <String, dynamic>{};
        expect(provider.formattedDailyRevenue, contains('0'));
      });
    });

    group('Order Metrics', () {
      test('should return correct order counts', () {
        provider.metrics = {
          'totalActiveOrders': 15,
          'pendingOrders': 5,
          'processingOrders': 7,
          'shippedOrders': 3,
        };

        expect(provider.totalActiveOrders, equals(15));
        expect(provider.pendingOrders, equals(5));
        expect(provider.processingOrders, equals(7));
        expect(provider.shippedOrders, equals(3));
      });

      test('should return 0 for missing order data', () {
        provider.metrics = <String, dynamic>{};

        expect(provider.totalActiveOrders, equals(0));
        expect(provider.pendingOrders, equals(0));
        expect(provider.processingOrders, equals(0));
        expect(provider.shippedOrders, equals(0));
      });
    });

    group('Route Sales Metrics', () {
      test('should return correct route sales counts', () {
        provider.metrics = {
          'soldRoutesToday': 2,
          'soldRoutesThisWeek': 12,
          'soldRoutesThisMonth': 45,
        };

        expect(provider.soldRoutesToday, equals(2));
        expect(provider.soldRoutesThisWeek, equals(12));
        expect(provider.soldRoutesThisMonth, equals(45));
      });

      test('should return 0 for missing route sales data', () {
        provider.metrics = <String, dynamic>{};

        expect(provider.soldRoutesToday, equals(0));
        expect(provider.soldRoutesThisWeek, equals(0));
        expect(provider.soldRoutesThisMonth, equals(0));
      });
    });

    group('Customer Rating', () {
      test('should return correct average rating', () {
        provider.metrics = {'avgCustomerRating': 4.7};

        expect(provider.averageCustomerRating, equals(4.7));
      });

      test('should return 0.0 for missing rating data', () {
        provider.metrics = <String, dynamic>{};

        expect(provider.averageCustomerRating, equals(0.0));
      });

      test('should format rating correctly', () {
        provider.metrics = {'avgCustomerRating': 4.7};

        expect(provider.formattedRating, equals('4.7'));

        provider.metrics = <String, dynamic>{};
        expect(provider.formattedRating, equals('0.0'));
      });

      test('should get rating stars correctly', () {
        provider.metrics = {'avgCustomerRating': 4.2};

        expect(provider.ratingStars, equals(4));

        provider.metrics = {'avgCustomerRating': 4.8};
        expect(provider.ratingStars, equals(5));

        provider.metrics = <String, dynamic>{};
        expect(provider.ratingStars, equals(0));
      });
    });

    group('Data Refresh', () {
      test('should refresh data and clear previous errors', () async {
        // Set initial error state
        provider.setError('Previous error');

        final mockMetrics = {'dailyRevenue': 100.0};
        when(
          mockService.getDashboardMetrics(),
        ).thenAnswer((_) async => mockMetrics);

        await provider.refreshData();

        expect(provider.errorMessage, isNull);
        expect(provider.metrics, equals(mockMetrics));
        verify(mockService.getDashboardMetrics()).called(1);
      });

      test('should handle refresh error', () async {
        when(
          mockService.getDashboardMetrics(),
        ).thenThrow(Exception('Network error'));

        await provider.refreshData();

        expect(provider.errorMessage, isNotNull);
        expect(provider.isLoading, isFalse);
      });
    });

    group('Growth Calculations', () {
      test('should calculate daily vs weekly growth correctly', () {
        provider.metrics = {'dailyRevenue': 150.0, 'weeklyRevenue': 700.0};

        // Daily average from weekly: 700/7 = 100
        // Growth: (150 - 100) / 100 = 0.5 = 50%
        expect(provider.dailyGrowthPercentage, closeTo(50.0, 1.0));
      });

      test('should handle zero weekly revenue in growth calculation', () {
        provider.metrics = {'dailyRevenue': 150.0, 'weeklyRevenue': 0.0};

        expect(provider.dailyGrowthPercentage, equals(0.0));
      });

      test('should calculate weekly vs monthly growth correctly', () {
        provider.metrics = {'weeklyRevenue': 800.0, 'monthlyRevenue': 3200.0};

        // Weekly average from monthly: 3200/4 = 800
        // Growth: (800 - 800) / 800 = 0%
        expect(provider.weeklyGrowthPercentage, equals(0.0));
      });
    });

    group('Has Data Checks', () {
      test('should detect if has revenue data', () {
        provider.metrics = {'dailyRevenue': 150.0};
        expect(provider.hasRevenueData, isTrue);

        provider.metrics = <String, dynamic>{};
        expect(provider.hasRevenueData, isFalse);
      });

      test('should detect if has order data', () {
        provider.metrics = {'totalActiveOrders': 5};
        expect(provider.hasOrderData, isTrue);

        provider.metrics = <String, dynamic>{};
        expect(provider.hasOrderData, isFalse);
      });

      test('should detect if has recent orders', () {
        provider.recentOrders = [
          {'id': 1},
        ];
        expect(provider.hasRecentOrders, isTrue);

        provider.recentOrders = [];
        expect(provider.hasRecentOrders, isFalse);
      });

      test('should detect if has popular routes', () {
        provider.popularRoutes = [
          {'hike_id': 1},
        ];
        expect(provider.hasPopularRoutes, isTrue);

        provider.popularRoutes = [];
        expect(provider.hasPopularRoutes, isFalse);
      });
    });

    group('Data Filtering', () {
      test('should filter recent orders by status', () {
        provider.recentOrders = [
          {'id': 1, 'status': 'pending'},
          {'id': 2, 'status': 'processing'},
          {'id': 3, 'status': 'pending'},
          {'id': 4, 'status': 'shipped'},
        ];

        final pendingOrders = provider.getOrdersByStatus('pending');
        expect(pendingOrders.length, equals(2));
        expect(
          pendingOrders.every((order) => order['status'] == 'pending'),
          isTrue,
        );
      });

      test('should return empty list for non-existent status', () {
        provider.recentOrders = [
          {'id': 1, 'status': 'pending'},
        ];

        final cancelledOrders = provider.getOrdersByStatus('cancelled');
        expect(cancelledOrders, isEmpty);
      });
    });
  });
}
