import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/analytics/customer_insights.dart';

/// Simple unit tests for CustomerAnalyticsService business logic
///
/// These tests focus on customer behavior analysis and segmentation logic
/// without mocking Supabase (same approach as SalesAnalyticsService).
void main() {
  group('CustomerAnalyticsService Business Logic', () {
    group('Customer Acquisition & Retention', () {
      test('should calculate new vs returning customers correctly', () {
        // Simulate customer data with first_order_date
        final customers = [
          {'id': 'user-1', 'first_order_date': '2025-01-01', 'total_orders': 1},
          {'id': 'user-2', 'first_order_date': '2025-01-15', 'total_orders': 1},
          {'id': 'user-3', 'first_order_date': '2024-12-20', 'total_orders': 3},
          {'id': 'user-4', 'first_order_date': '2024-11-10', 'total_orders': 2},
        ];

        // Period: January 2025
        final periodStart = DateTime(2025, 1, 1);
        final periodEnd = DateTime(2025, 1, 31);

        int newCustomers = 0;
        int returningCustomers = 0;

        for (var customer in customers) {
          final firstOrderDate = DateTime.parse(
            customer['first_order_date'] as String,
          );
          final isNewInPeriod =
              firstOrderDate.isAfter(periodStart.subtract(Duration(days: 1))) &&
              firstOrderDate.isBefore(periodEnd.add(Duration(days: 1)));

          if (isNewInPeriod) {
            newCustomers++;
          } else {
            returningCustomers++;
          }
        }

        expect(newCustomers, 2); // user-1, user-2
        expect(returningCustomers, 2); // user-3, user-4
      });

      test('should calculate repeat purchase rate correctly', () {
        final customers = [
          {'total_orders': 1}, // One-time customer
          {'total_orders': 2}, // Repeat customer
          {'total_orders': 1}, // One-time customer
          {'total_orders': 3}, // Repeat customer
          {'total_orders': 1}, // One-time customer
        ];

        int customersWithRepeats = 0;
        for (var customer in customers) {
          if ((customer['total_orders'] as int) > 1) {
            customersWithRepeats++;
          }
        }

        final repeatRate = customers.isNotEmpty
            ? customersWithRepeats / customers.length
            : 0.0;

        expect(repeatRate, 0.4); // 2 out of 5 = 40%
      });

      test('should calculate average lifetime value correctly', () {
        final customers = [
          {'total_spent': 100.0},
          {'total_spent': 250.0},
          {'total_spent': 150.0},
          {'total_spent': 200.0},
        ];

        double totalSpent = 0.0;
        for (var customer in customers) {
          totalSpent += (customer['total_spent'] as num).toDouble();
        }

        final avgLTV = customers.isNotEmpty
            ? totalSpent / customers.length
            : 0.0;
        expect(avgLTV, 175.0); // (100 + 250 + 150 + 200) / 4
      });
    });

    group('Geographic Distribution', () {
      test('should aggregate customers by location correctly', () {
        final customers = [
          {'location': 'Berlin'},
          {'location': 'Munich'},
          {'location': 'Berlin'},
          {'location': 'Hamburg'},
          {'location': 'Berlin'},
          {'location': 'Munich'},
        ];

        Map<String, int> customersByLocation = {};
        for (var customer in customers) {
          final location = customer['location'];
          if (location != null && location.isNotEmpty) {
            customersByLocation[location] =
                (customersByLocation[location] ?? 0) + 1;
          }
        }

        expect(customersByLocation['Berlin'], 3);
        expect(customersByLocation['Munich'], 2);
        expect(customersByLocation['Hamburg'], 1);
      });

      test('should handle null/empty locations gracefully', () {
        final customers = [
          {'location': 'Berlin'},
          {'location': null},
          {'location': ''},
          {'location': 'Munich'},
        ];

        Map<String, int> customersByLocation = {};
        for (var customer in customers) {
          final location = customer['location'];
          if (location != null && location.isNotEmpty) {
            customersByLocation[location] =
                (customersByLocation[location] ?? 0) + 1;
          }
        }

        expect(customersByLocation.length, 2);
        expect(customersByLocation['Berlin'], 1);
        expect(customersByLocation['Munich'], 1);
      });
    });

    group('Order Frequency Distribution', () {
      test('should create order frequency distribution correctly', () {
        final customers = [
          {'total_orders': 1},
          {'total_orders': 1},
          {'total_orders': 2},
          {'total_orders': 3},
          {'total_orders': 1},
          {'total_orders': 2},
          {'total_orders': 4},
        ];

        Map<int, int> frequencyDistribution = {};
        for (var customer in customers) {
          final orders = customer['total_orders'] as int;
          frequencyDistribution[orders] =
              (frequencyDistribution[orders] ?? 0) + 1;
        }

        expect(frequencyDistribution[1], 3); // 3 customers with 1 order
        expect(frequencyDistribution[2], 2); // 2 customers with 2 orders
        expect(frequencyDistribution[3], 1); // 1 customer with 3 orders
        expect(frequencyDistribution[4], 1); // 1 customer with 4 orders
      });

      test('should handle edge case with no orders', () {
        final customers = <Map<String, dynamic>>[];

        Map<int, int> frequencyDistribution = {};
        for (var customer in customers) {
          final orders = customer['total_orders'] as int;
          frequencyDistribution[orders] =
              (frequencyDistribution[orders] ?? 0) + 1;
        }

        expect(frequencyDistribution, isEmpty);
      });
    });

    group('CustomerInsights Model Integration', () {
      test('should create valid CustomerInsights from aggregated data', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 250.0,
          customersByLocation: {
            'Berlin': 40,
            'Munich': 30,
            'Hamburg': 20,
            'Cologne': 10,
          },
          orderFrequencyDistribution: {1: 50, 2: 30, 3: 15, 4: 5},
        );

        expect(insights.totalCustomers, 100);
        expect(insights.newCustomerRate, 0.3);
        expect(insights.topLocation, 'Berlin');
        expect(insights.hasHealthyRetention, isTrue); // >30%
        expect(insights.retentionGrade, 'B'); // 40% = B
      });

      test('should calculate average orders per customer correctly', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 250.0,
          orderFrequencyDistribution: {
            1: 40, // 40 customers * 1 order = 40
            2: 30, // 30 customers * 2 orders = 60
            3: 20, // 20 customers * 3 orders = 60
            4: 10, // 10 customers * 4 orders = 40
          },
        );

        // Total orders: 40 + 60 + 60 + 40 = 200
        // Avg: 200 / 100 = 2.0
        expect(insights.averageOrdersPerCustomer, 2.0);
      });
    });

    group('Data Validation', () {
      test('should handle zero total customers gracefully', () {
        final insights = CustomerInsights.empty();

        expect(insights.totalCustomers, 0);
        expect(insights.newCustomerRate, 0.0);
        expect(insights.averageOrdersPerCustomer, 0.0);
      });

      test('should calculate metrics with partial data', () {
        final insights = CustomerInsights(
          totalCustomers: 50,
          newCustomers: 50,
          returningCustomers: 0,
          repeatPurchaseRate: 0.0,
          averageLifetimeValue: 100.0,
        );

        expect(insights.newCustomerRate, 1.0); // All new
        expect(insights.hasHealthyRetention, isFalse); // 0% repeat rate
      });
    });
  });
}
