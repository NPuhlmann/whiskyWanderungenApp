import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/providers/dashboard_provider.dart';
import 'package:whisky_hikes/data/services/admin/dashboard_metrics_service.dart';

@GenerateMocks([DashboardMetricsService])
import 'dashboard_provider_simple_test.mocks.dart';

void main() {
  group('DashboardProvider Simple Tests', () {
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

      test('should return 0 for all metrics initially', () {
        expect(provider.dailyRevenue, equals(0.0));
        expect(provider.weeklyRevenue, equals(0.0));
        expect(provider.monthlyRevenue, equals(0.0));
        expect(provider.totalActiveOrders, equals(0));
        expect(provider.pendingOrders, equals(0));
        expect(provider.processingOrders, equals(0));
        expect(provider.shippedOrders, equals(0));
        expect(provider.soldRoutesToday, equals(0));
        expect(provider.soldRoutesThisWeek, equals(0));
        expect(provider.soldRoutesThisMonth, equals(0));
        expect(provider.averageCustomerRating, equals(0.0));
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

    group('Metrics Loading Success', () {
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
              'hike_name': 'Highland Adventure'
            }
          ],
          'popularRoutes': [
            {'hike_id': 1, 'hike_name': 'Highland Adventure', 'count': 15}
          ]
        };

        when(mockService.getDashboardMetrics())
            .thenAnswer((_) async => mockMetrics);

        await provider.loadDashboardData();

        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.metrics, equals(mockMetrics));
        expect(provider.recentOrders.length, equals(1));
        expect(provider.popularRoutes.length, equals(1));

        // Test specific metric values
        expect(provider.dailyRevenue, equals(150.0));
        expect(provider.weeklyRevenue, equals(800.0));
        expect(provider.monthlyRevenue, equals(3500.0));
        expect(provider.totalActiveOrders, equals(15));
        expect(provider.pendingOrders, equals(5));
        expect(provider.averageCustomerRating, equals(4.5));

        verify(mockService.getDashboardMetrics()).called(1);
      });

      test('should handle loading state during async operation', () async {
        when(mockService.getDashboardMetrics())
            .thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return <String, dynamic>{
            'dailyRevenue': 100.0,
            'recentOrders': [],
            'popularRoutes': [],
          };
        });

        final loadingFuture = provider.loadDashboardData();

        // Should be loading immediately after calling
        expect(provider.isLoading, isTrue);

        await loadingFuture;

        // Should not be loading after completion
        expect(provider.isLoading, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle loading error gracefully', () async {
        when(mockService.getDashboardMetrics())
            .thenThrow(Exception('Database connection failed'));

        await provider.loadDashboardData();

        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('Failed to load dashboard data'));
      });

      test('should clear previous error on successful refresh', () async {
        // First set an error
        provider.setError('Previous error');

        final mockMetrics = {
          'dailyRevenue': 100.0,
          'recentOrders': [],
          'popularRoutes': [],
        };
        when(mockService.getDashboardMetrics())
            .thenAnswer((_) async => mockMetrics);

        await provider.refreshData();

        expect(provider.errorMessage, isNull);
      });
    });

    group('Formatting Methods', () {
      test('should format revenue correctly', () async {
        when(mockService.formatCurrency(150.0)).thenReturn('150,00 €');
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'dailyRevenue': 150.0,
          'weeklyRevenue': 800.0,
          'monthlyRevenue': 3500.0,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.formattedDailyRevenue, contains('150'));
        verify(mockService.formatCurrency(150.0)).called(1);
      });

      test('should format rating correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'avgCustomerRating': 4.7,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.formattedRating, equals('4.7'));
        expect(provider.ratingStars, equals(5));
      });

      test('should handle zero rating correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.formattedRating, equals('0.0'));
        expect(provider.ratingStars, equals(0));
      });
    });

    group('Growth Calculations', () {
      test('should calculate daily growth correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'dailyRevenue': 150.0,
          'weeklyRevenue': 700.0, // Daily average: 100
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        // Growth: (150 - 100) / 100 * 100 = 50%
        expect(provider.dailyGrowthPercentage, equals(50.0));
      });

      test('should handle zero weekly revenue in growth calculation', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'dailyRevenue': 150.0,
          'weeklyRevenue': 0.0,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.dailyGrowthPercentage, equals(0.0));
      });

      test('should calculate weekly growth correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'weeklyRevenue': 800.0,
          'monthlyRevenue': 3200.0, // Weekly average: 800
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        // Growth: (800 - 800) / 800 * 100 = 0%
        expect(provider.weeklyGrowthPercentage, equals(0.0));
      });
    });

    group('Data Status Checks', () {
      test('should detect revenue data correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'dailyRevenue': 150.0,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.hasRevenueData, isTrue);
      });

      test('should detect no revenue data correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.hasRevenueData, isFalse);
      });

      test('should detect order data correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'totalActiveOrders': 5,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.hasOrderData, isTrue);
      });

      test('should detect recent orders correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'recentOrders': [{'id': 1}],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        expect(provider.hasRecentOrders, isTrue);
      });

      test('should detect popular routes correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'recentOrders': [],
          'popularRoutes': [{'hike_id': 1}],
        });

        await provider.loadDashboardData();

        expect(provider.hasPopularRoutes, isTrue);
      });
    });

    group('Utility Methods', () {
      test('should get quick stats correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'dailyRevenue': 150.0,
          'weeklyRevenue': 700.0,
          'monthlyRevenue': 3500.0,
          'totalActiveOrders': 15,
          'soldRoutesThisMonth': 45,
          'avgCustomerRating': 4.5,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        final quickStats = provider.getQuickStats();

        expect(quickStats['totalRevenue'], equals(3500.0));
        expect(quickStats['totalOrders'], equals(15));
        expect(quickStats['totalRoutesSold'], equals(45));
        expect(quickStats['averageRating'], equals(4.5));
        expect(quickStats['dailyGrowth'], equals(50.0)); // (150 - 100) / 100 * 100
      });

      test('should get revenue trend data correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'dailyRevenue': 150.0,
          'weeklyRevenue': 800.0,
          'monthlyRevenue': 3500.0,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        final trendData = provider.getRevenueTrendData();

        expect(trendData.length, equals(3));
        expect(trendData[0]['period'], equals('Today'));
        expect(trendData[0]['revenue'], equals(150.0));
        expect(trendData[1]['period'], equals('This Week'));
        expect(trendData[1]['revenue'], equals(800.0));
        expect(trendData[2]['period'], equals('This Month'));
        expect(trendData[2]['revenue'], equals(3500.0));
      });

      test('should get order status distribution correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'pendingOrders': 5,
          'processingOrders': 7,
          'shippedOrders': 3,
          'recentOrders': [],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        final distribution = provider.getOrderStatusDistribution();

        expect(distribution['pending'], equals(5));
        expect(distribution['processing'], equals(7));
        expect(distribution['shipped'], equals(3));
      });
    });

    group('Data Filtering', () {
      test('should filter orders by status correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'recentOrders': [
            {'id': 1, 'status': 'pending'},
            {'id': 2, 'status': 'processing'},
            {'id': 3, 'status': 'pending'},
            {'id': 4, 'status': 'shipped'},
          ],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        final pendingOrders = provider.getOrdersByStatus('pending');
        expect(pendingOrders.length, equals(2));
        expect(pendingOrders.every((order) => order['status'] == 'pending'), isTrue);

        final processingOrders = provider.getOrdersByStatus('processing');
        expect(processingOrders.length, equals(1));

        final cancelledOrders = provider.getOrdersByStatus('cancelled');
        expect(cancelledOrders, isEmpty);
      });

      test('should get top routes with limit correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'recentOrders': [],
          'popularRoutes': [
            {'hike_id': 1, 'name': 'Route 1'},
            {'hike_id': 2, 'name': 'Route 2'},
            {'hike_id': 3, 'name': 'Route 3'},
            {'hike_id': 4, 'name': 'Route 4'},
            {'hike_id': 5, 'name': 'Route 5'},
            {'hike_id': 6, 'name': 'Route 6'},
          ],
        });

        await provider.loadDashboardData();

        final topRoutes = provider.getTopRoutes(limit: 3);
        expect(topRoutes.length, equals(3));
        expect(topRoutes[0]['name'], equals('Route 1'));
      });

      test('should get recent activity with limit correctly', () async {
        when(mockService.getDashboardMetrics()).thenAnswer((_) async => {
          'recentOrders': [
            {'id': 1, 'customer_name': 'Customer 1'},
            {'id': 2, 'customer_name': 'Customer 2'},
            {'id': 3, 'customer_name': 'Customer 3'},
            {'id': 4, 'customer_name': 'Customer 4'},
            {'id': 5, 'customer_name': 'Customer 5'},
            {'id': 6, 'customer_name': 'Customer 6'},
          ],
          'popularRoutes': [],
        });

        await provider.loadDashboardData();

        final recentActivity = provider.getRecentActivity(limit: 3);
        expect(recentActivity.length, equals(3));
        expect(recentActivity[0]['customer_name'], equals('Customer 1'));
      });
    });
  });
}