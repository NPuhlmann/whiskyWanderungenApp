import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/analytics/customer_insights.dart';

void main() {
  group('CustomerInsights', () {
    group('creation', () {
      test('should create CustomerInsights with required fields', () {
        final insights = CustomerInsights(
          totalCustomers: 500,
          newCustomers: 150,
          returningCustomers: 350,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 250.0,
        );

        expect(insights.totalCustomers, 500);
        expect(insights.newCustomers, 150);
        expect(insights.returningCustomers, 350);
        expect(insights.repeatPurchaseRate, 0.4);
        expect(insights.averageLifetimeValue, 250.0);
      });

      test('should create empty CustomerInsights', () {
        final insights = CustomerInsights.empty();

        expect(insights.totalCustomers, 0);
        expect(insights.newCustomers, 0);
        expect(insights.returningCustomers, 0);
        expect(insights.repeatPurchaseRate, 0.0);
        expect(insights.averageLifetimeValue, 0.0);
      });

      test('should create with location and frequency data', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.5,
          averageLifetimeValue: 300.0,
          customersByLocation: {'Berlin': 40, 'Munich': 30, 'Hamburg': 30},
          orderFrequencyDistribution: {1: 50, 2: 30, 3: 20},
        );

        expect(insights.customersByLocation.length, 3);
        expect(insights.orderFrequencyDistribution.length, 3);
      });
    });

    group('formatting', () {
      test('should format repeat purchase rate as percentage', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.456,
          averageLifetimeValue: 200.0,
        );

        expect(insights.formattedRepeatPurchaseRate, '45.6%');
      });

      test('should format lifetime value with Euro symbol', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 1234.56,
        );

        expect(insights.formattedLifetimeValue, contains('1.234,56'));
        expect(insights.formattedLifetimeValue, contains('€'));
      });

      test('should format new customer rate', () {
        final insights = CustomerInsights(
          totalCustomers: 200,
          newCustomers: 50,
          returningCustomers: 150,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 200.0,
        );

        expect(insights.formattedNewCustomerRate, '25.0%');
      });
    });

    group('customer rates', () {
      test('should calculate new customer rate correctly', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 25,
          returningCustomers: 75,
          repeatPurchaseRate: 0.5,
          averageLifetimeValue: 200.0,
        );

        expect(insights.newCustomerRate, 0.25);
      });

      test('should handle zero customers in new customer rate', () {
        final insights = CustomerInsights.empty();

        expect(insights.newCustomerRate, 0.0);
      });
    });

    group('location analysis', () {
      test('should get top locations correctly', () {
        final insights = CustomerInsights(
          totalCustomers: 150,
          newCustomers: 50,
          returningCustomers: 100,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 250.0,
          customersByLocation: {
            'Berlin': 60,
            'Munich': 40,
            'Hamburg': 30,
            'Cologne': 20,
          },
        );

        final topLocations = insights.getTopLocations(2);

        expect(topLocations.length, 2);
        expect(topLocations[0].key, 'Berlin');
        expect(topLocations[0].value, 60);
        expect(topLocations[1].key, 'Munich');
      });

      test('should identify top location', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 200.0,
          customersByLocation: {'Berlin': 50, 'Munich': 30, 'Hamburg': 20},
        );

        expect(insights.topLocation, 'Berlin');
      });

      test('should return null for top location when no data', () {
        final insights = CustomerInsights.empty();

        expect(insights.topLocation, isNull);
      });

      test('should get customers from specific location', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 200.0,
          customersByLocation: {'Berlin': 40, 'Munich': 30},
        );

        expect(insights.getCustomersFromLocation('Berlin'), 40);
        expect(insights.getCustomersFromLocation('Munich'), 30);
        expect(insights.getCustomersFromLocation('Hamburg'), 0);
      });
    });

    group('order frequency', () {
      test('should calculate average orders per customer', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 200.0,
          orderFrequencyDistribution: {
            1: 40, // 40 customers with 1 order
            2: 30, // 30 customers with 2 orders
            3: 20, // 20 customers with 3 orders
            4: 10, // 10 customers with 4 orders
          },
        );

        // Total orders: (1*40) + (2*30) + (3*20) + (4*10) = 40 + 60 + 60 + 40 = 200
        // Average: 200 / 100 = 2.0
        expect(insights.averageOrdersPerCustomer, 2.0);
      });

      test('should format average orders per customer', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 200.0,
          orderFrequencyDistribution: {1: 50, 2: 30, 3: 20},
        );

        expect(insights.formattedAverageOrders, contains('1.7'));
      });

      test('should handle zero customers in average orders', () {
        final insights = CustomerInsights.empty();

        expect(insights.averageOrdersPerCustomer, 0.0);
      });
    });

    group('retention metrics', () {
      test('should identify healthy retention', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.35,
          averageLifetimeValue: 200.0,
        );

        expect(insights.hasHealthyRetention, isTrue);
      });

      test('should identify poor retention', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 80,
          returningCustomers: 20,
          repeatPurchaseRate: 0.15,
          averageLifetimeValue: 150.0,
        );

        expect(insights.hasHealthyRetention, isFalse);
      });

      test('should assign retention grade A for excellent retention', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 20,
          returningCustomers: 80,
          repeatPurchaseRate: 0.6,
          averageLifetimeValue: 300.0,
        );

        expect(insights.retentionGrade, 'A');
      });

      test('should assign retention grade B for good retention', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 40,
          returningCustomers: 60,
          repeatPurchaseRate: 0.45,
          averageLifetimeValue: 250.0,
        );

        expect(insights.retentionGrade, 'B');
      });

      test('should assign retention grade C for acceptable retention', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 60,
          returningCustomers: 40,
          repeatPurchaseRate: 0.35,
          averageLifetimeValue: 200.0,
        );

        expect(insights.retentionGrade, 'C');
      });

      test('should assign retention grade F for poor retention', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 90,
          returningCustomers: 10,
          repeatPurchaseRate: 0.1,
          averageLifetimeValue: 100.0,
        );

        expect(insights.retentionGrade, 'F');
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON', () {
        final insights = CustomerInsights(
          totalCustomers: 100,
          newCustomers: 30,
          returningCustomers: 70,
          repeatPurchaseRate: 0.4,
          averageLifetimeValue: 250.0,
          customersByLocation: {'Berlin': 50},
          orderFrequencyDistribution: {1: 40, 2: 30},
        );

        final json = insights.toJson();

        expect(json['totalCustomers'], 100);
        expect(json['newCustomers'], 30);
        expect(json['repeatPurchaseRate'], 0.4);
      });

      test('should deserialize from JSON', () {
        final json = {
          'totalCustomers': 200,
          'newCustomers': 60,
          'returningCustomers': 140,
          'repeatPurchaseRate': 0.5,
          'averageLifetimeValue': 300.0,
          'customersByLocation': {'Munich': 80},
          'orderFrequencyDistribution': {
            '1': 50,
            '2': 40,
            '3': 30,
          },
        };

        final insights = CustomerInsights.fromJson(json);

        expect(insights.totalCustomers, 200);
        expect(insights.newCustomers, 60);
        expect(insights.repeatPurchaseRate, 0.5);
      });
    });
  });
}
