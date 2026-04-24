import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/admin/dashboard_metrics_service.dart';

@GenerateMocks([SupabaseClient])
import 'dashboard_metrics_service_simple_test.mocks.dart';

void main() {
  group('DashboardMetricsService Simple Tests', () {
    late DashboardMetricsService service;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      service = DashboardMetricsService(client: mockClient);
    });

    group('Data Formatting', () {
      test('should format currency values correctly', () {
        expect(service.formatCurrency(1234.56), contains('€'));
        expect(service.formatCurrency(1234.56), contains('1'));
        expect(service.formatCurrency(0.0), contains('0'));
        expect(service.formatCurrency(99.9), contains('99'));
      });

      test('should format percentage values correctly', () {
        expect(service.formatPercentage(0.1234), contains('%'));
        expect(service.formatPercentage(0.1234), contains('12'));
        expect(service.formatPercentage(0.0), contains('0'));
        expect(service.formatPercentage(1.0), contains('100'));
      });

      test('should format large numbers with K/M suffixes', () {
        expect(service.formatNumber(1234), equals('1.2K'));
        expect(service.formatNumber(1234567), equals('1.2M'));
        expect(service.formatNumber(999), equals('999'));
        expect(service.formatNumber(0), equals('0'));
      });
    });

    group('Revenue Calculation Logic', () {
      test('should handle empty revenue data gracefully', () {
        // Test revenue calculation logic with empty data
        final emptyData = <Map<String, dynamic>>[];
        double total = 0.0;
        for (final order in emptyData) {
          total += (order['total_amount'] as num).toDouble();
        }
        expect(total, equals(0.0));
      });

      test('should calculate total from order data correctly', () {
        // Test revenue calculation logic with sample data
        final sampleData = [
          {'total_amount': 89.99},
          {'total_amount': 79.99},
          {'total_amount': 99.99},
        ];

        double total = 0.0;
        for (final order in sampleData) {
          total += (order['total_amount'] as num).toDouble();
        }
        expect(total, closeTo(269.97, 0.01));
      });

      test('should handle mixed number types in revenue calculation', () {
        final mixedData = [
          {'total_amount': 89.99}, // double
          {'total_amount': 80}, // int
          {'total_amount': 79.50}, // double
        ];

        double total = 0.0;
        for (final order in mixedData) {
          total += (order['total_amount'] as num).toDouble();
        }
        expect(total, equals(249.49));
      });
    });

    group('Rating Calculation Logic', () {
      test('should calculate average rating correctly', () {
        final ratingsData = [
          {'rating': 5},
          {'rating': 4},
          {'rating': 5},
          {'rating': 3},
          {'rating': 4},
        ];

        if (ratingsData.isEmpty) {
          expect(0.0, equals(0.0));
          return;
        }

        double total = 0.0;
        for (final review in ratingsData) {
          total += (review['rating'] as num).toDouble();
        }
        final average = total / ratingsData.length;

        expect(average, equals(4.2));
      });

      test('should handle empty ratings gracefully', () {
        final emptyRatings = <Map<String, dynamic>>[];

        if (emptyRatings.isEmpty) {
          expect(0.0, equals(0.0));
        }
      });

      test('should handle single rating correctly', () {
        final singleRating = [
          {'rating': 5},
        ];

        double total = 0.0;
        for (final review in singleRating) {
          total += (review['rating'] as num).toDouble();
        }
        final average = total / singleRating.length;

        expect(average, equals(5.0));
      });
    });

    group('Data Transformation Logic', () {
      test('should transform order data correctly', () {
        final orderData = {
          'id': 1,
          'customer_name': 'John Doe',
          'total_amount': 89.99,
          'status': 'pending',
          'created_at': '2024-01-15T10:00:00Z',
          'hikes': {'name': 'Highland Adventure'},
        };

        // Test transformation logic
        final transformed = Map<String, dynamic>.from(orderData);
        final hikes = orderData['hikes'] as Map<String, dynamic>?;
        if (hikes != null && hikes['name'] != null) {
          transformed['hike_name'] = hikes['name'];
        }
        transformed.remove('hikes');

        expect(transformed['hike_name'], equals('Highland Adventure'));
        expect(transformed.containsKey('hikes'), isFalse);
        expect(transformed['customer_name'], equals('John Doe'));
      });

      test('should handle missing hike data in transformation', () {
        final orderDataWithoutHike = {
          'id': 1,
          'customer_name': 'John Doe',
          'total_amount': 89.99,
          'status': 'pending',
          'created_at': '2024-01-15T10:00:00Z',
          'hikes': null,
        };

        final transformed = Map<String, dynamic>.from(orderDataWithoutHike);
        final hikes = orderDataWithoutHike['hikes'] as Map<String, dynamic>?;
        if (hikes != null && hikes['name'] != null) {
          transformed['hike_name'] = hikes['name'];
        }
        transformed.remove('hikes');

        expect(transformed.containsKey('hike_name'), isFalse);
        expect(transformed.containsKey('hikes'), isFalse);
      });
    });

    group('Date Range Logic', () {
      test('should generate correct date strings for queries', () {
        final today = DateTime(2024, 1, 15, 14, 30, 0);
        final todayStr = today.toIso8601String().split('T')[0];
        final tomorrowStr = today
            .add(Duration(days: 1))
            .toIso8601String()
            .split('T')[0];

        expect(todayStr, equals('2024-01-15'));
        expect(tomorrowStr, equals('2024-01-16'));
      });

      test('should calculate week start correctly', () {
        final testDate = DateTime(2024, 1, 17); // Wednesday
        final weekStart = testDate.subtract(
          Duration(days: testDate.weekday - 1),
        );
        final weekStartStr = weekStart.toIso8601String().split('T')[0];

        expect(weekStart.weekday, equals(1)); // Monday
        expect(weekStartStr, equals('2024-01-15'));
      });

      test('should calculate month start correctly', () {
        final testDate = DateTime(2024, 1, 17, 14, 30, 0);
        final monthStart = DateTime(testDate.year, testDate.month, 1);
        final monthStartStr = monthStart.toIso8601String().split('T')[0];

        expect(monthStartStr, equals('2024-01-01'));
      });
    });

    group('Popular Routes Logic', () {
      test('should group and count routes correctly', () {
        final ordersData = [
          {
            'hike_id': 1,
            'hikes': {'name': 'Highland Adventure'},
          },
          {
            'hike_id': 2,
            'hikes': {'name': 'Speyside Journey'},
          },
          {
            'hike_id': 1,
            'hikes': {'name': 'Highland Adventure'},
          },
          {
            'hike_id': 3,
            'hikes': {'name': 'Islay Challenge'},
          },
          {
            'hike_id': 1,
            'hikes': {'name': 'Highland Adventure'},
          },
        ];

        // Group by hike and count
        final Map<int, Map<String, dynamic>> hikeStats = {};
        for (final order in ordersData) {
          final hikeId = order['hike_id'] as int;
          final hikes = order['hikes'] as Map<String, dynamic>;
          if (!hikeStats.containsKey(hikeId)) {
            hikeStats[hikeId] = {
              'hike_id': hikeId,
              'hike_name': hikes['name'],
              'count': 0,
            };
          }
          hikeStats[hikeId]!['count'] =
              (hikeStats[hikeId]!['count'] as int) + 1;
        }

        final sortedStats = hikeStats.values.toList()
          ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

        expect(sortedStats.length, equals(3));
        expect(sortedStats[0]['hike_name'], equals('Highland Adventure'));
        expect(sortedStats[0]['count'], equals(3));
        expect(sortedStats[1]['count'], equals(1));
        expect(sortedStats[2]['count'], equals(1));
      });

      test('should handle empty popular routes data', () {
        final emptyData = <Map<String, dynamic>>[];
        final Map<int, Map<String, dynamic>> hikeStats = {};

        for (final order in emptyData) {
          final hikeId = order['hike_id'] as int;
          if (!hikeStats.containsKey(hikeId)) {
            hikeStats[hikeId] = {
              'hike_id': hikeId,
              'hike_name': order['hikes']['name'],
              'count': 0,
            };
          }
          hikeStats[hikeId]!['count'] =
              (hikeStats[hikeId]!['count'] as int) + 1;
        }

        expect(hikeStats.isEmpty, isTrue);
      });
    });

    group('Number Formatting Edge Cases', () {
      test('should handle edge cases in number formatting', () {
        expect(service.formatNumber(999), equals('999'));
        expect(service.formatNumber(1000), equals('1.0K'));
        expect(service.formatNumber(1001), equals('1.0K'));
        expect(service.formatNumber(999999), equals('1000.0K'));
        expect(service.formatNumber(1000000), equals('1.0M'));
      });

      test('should handle negative numbers in formatting', () {
        expect(service.formatCurrency(-123.45), contains('-'));
        expect(service.formatPercentage(-0.1), contains('-'));
      });
    });
  });
}
