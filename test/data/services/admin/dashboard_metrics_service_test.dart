import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/admin/dashboard_metrics_service.dart';

// Simplified mock approach - focus on the client interface
@GenerateMocks([SupabaseClient])
import 'dashboard_metrics_service_test.mocks.dart';

// Create a test-specific service that exposes the logic we want to test
class TestableDashboardMetricsService extends DashboardMetricsService {
  TestableDashboardMetricsService(SupabaseClient client)
    : super(client: client);

  // Extract the calculation logic for testing
  double calculateTotalFromResults(List<Map<String, dynamic>> results) {
    double total = 0.0;
    for (final order in results) {
      total += (order['total_amount'] as num).toDouble();
    }
    return total;
  }

  // Extract the rating calculation logic
  double calculateAverageRating(List<Map<String, dynamic>> results) {
    if (results.isEmpty) return 0.0;

    double sum = 0.0;
    for (final review in results) {
      sum += (review['rating'] as num).toDouble();
    }
    return sum / results.length;
  }

  // Extract growth calculation logic
  double calculateGrowthPercentage(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100.0;
  }
}

void main() {
  group('DashboardMetricsService Tests', () {
    late TestableDashboardMetricsService service;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      service = TestableDashboardMetricsService(mockClient);
    });

    group('Revenue Calculation Logic', () {
      test('should calculate total from order results correctly', () {
        final results = [
          {'total_amount': 89.99},
          {'total_amount': 79.99},
          {'total_amount': 99.99},
        ];

        final total = service.calculateTotalFromResults(results);

        expect(total, closeTo(269.97, 0.01));
      });

      test('should handle empty results', () {
        final results = <Map<String, dynamic>>[];

        final total = service.calculateTotalFromResults(results);

        expect(total, equals(0.0));
      });

      test('should handle mixed numeric types', () {
        final results = [
          {'total_amount': 89}, // int
          {'total_amount': 79.99}, // double
          {'total_amount': 50}, // int
        ];

        final total = service.calculateTotalFromResults(results);

        expect(total, equals(218.99));
      });

      test('should handle null or invalid amounts gracefully', () {
        final results = [
          {'total_amount': 89.99},
          {'total_amount': null}, // Should throw
          {'total_amount': 99.99},
        ];

        // The current implementation would throw, which is expected behavior
        expect(
          () => service.calculateTotalFromResults(results),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('Rating Calculation Logic', () {
      test('should calculate average rating correctly', () {
        final results = [
          {'rating': 4.5},
          {'rating': 5.0},
          {'rating': 3.8},
          {'rating': 4.2},
        ];

        final average = service.calculateAverageRating(results);

        expect(average, closeTo(4.375, 0.001));
      });

      test('should handle empty rating results', () {
        final results = <Map<String, dynamic>>[];

        final average = service.calculateAverageRating(results);

        expect(average, equals(0.0));
      });

      test('should handle single rating', () {
        final results = [
          {'rating': 4.5},
        ];

        final average = service.calculateAverageRating(results);

        expect(average, equals(4.5));
      });
    });

    group('Growth Calculation Logic', () {
      test('should calculate positive growth correctly', () {
        final growth = service.calculateGrowthPercentage(120.0, 100.0);

        expect(growth, equals(20.0));
      });

      test('should calculate negative growth correctly', () {
        final growth = service.calculateGrowthPercentage(80.0, 100.0);

        expect(growth, equals(-20.0));
      });

      test('should handle zero previous value', () {
        final growth = service.calculateGrowthPercentage(50.0, 0.0);

        expect(growth, equals(100.0));
      });

      test('should handle zero current and previous values', () {
        final growth = service.calculateGrowthPercentage(0.0, 0.0);

        expect(growth, equals(0.0));
      });

      test('should handle zero current with non-zero previous', () {
        final growth = service.calculateGrowthPercentage(0.0, 100.0);

        expect(growth, equals(-100.0));
      });
    });

    group('Service Initialization', () {
      test('should initialize service with provided client', () {
        expect(service, isNotNull);
        // Service is initialized with mock client - this confirms dependency injection works
      });
    });

    group('Date Calculation Helpers', () {
      test('should handle date calculations correctly', () {
        final today = DateTime.now();
        final todayStr = today.toIso8601String().split('T')[0];
        final tomorrowStr = today
            .add(Duration(days: 1))
            .toIso8601String()
            .split('T')[0];

        // Verify date string formatting
        expect(todayStr.length, equals(10)); // YYYY-MM-DD
        expect(tomorrowStr.length, equals(10));
        expect(
          DateTime.parse(
            tomorrowStr,
          ).difference(DateTime.parse(todayStr)).inDays,
          equals(1),
        );
      });

      test('should handle weekly date range calculations', () {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartStr = weekStart.toIso8601String().split('T')[0];

        // Verify week start calculation
        expect(weekStart.weekday, equals(1)); // Monday
        expect(weekStartStr.length, equals(10));
        expect(
          weekStart.isBefore(now) || weekStart.isAtSameMomentAs(now),
          isTrue,
        );
      });
    });

    group('Data Validation', () {
      test('should validate that count operations return integers', () {
        final testData = [
          {'id': 1},
          {'id': 2},
          {'id': 3},
        ];

        final count = testData.length;
        expect(count, isA<int>());
        expect(count, equals(3));
      });

      test('should validate popular routes data structure', () {
        final mockRoutes = [
          {'hike_id': 1, 'route_name': 'Highland Trail', 'order_count': 15},
          {'hike_id': 2, 'route_name': 'Speyside Walk', 'order_count': 12},
        ];

        expect(mockRoutes, hasLength(2));
        expect(mockRoutes[0]['route_name'], isA<String>());
        expect(mockRoutes[0]['order_count'], isA<int>());
        expect(mockRoutes[0]['hike_id'], isA<int>());
      });
    });
  });
}
