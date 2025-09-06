import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/services/shipping/shipping_calculation_service.dart';
import 'package:whisky_hikes/domain/models/delivery_address.dart';

void main() {
  group('ShippingCalculationService Tests', () {
    late ShippingCalculationService service;

    setUp(() {
      service = ShippingCalculationService();
    });

    group('Standard Shipping Costs', () {
      test('should calculate correct standard shipping for Germany', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final cost = service.calculateStandardShipping(address);

        expect(cost, equals(4.99));
      });

      test('should calculate correct standard shipping for Austria', () {
        const address = DeliveryAddress(
          firstName: 'Franz',
          lastName: 'Schmidt',
          street: 'Ringstraße 1',
          city: 'Vienna',
          postalCode: '1010',
          country: 'Austria',
        );

        final cost = service.calculateStandardShipping(address);

        expect(cost, equals(6.99));
      });

      test('should calculate correct standard shipping for Switzerland', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Zimmermann',
          street: 'Bahnhofstraße 50',
          city: 'Zurich',
          postalCode: '8001',
          country: 'Switzerland',
        );

        final cost = service.calculateStandardShipping(address);

        expect(cost, equals(9.99));
      });

      test('should calculate correct standard shipping for other EU countries', () {
        const address = DeliveryAddress(
          firstName: 'Jean',
          lastName: 'Dubois',
          street: 'Rue de la Paix 10',
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        );

        final cost = service.calculateStandardShipping(address);

        expect(cost, equals(8.99));
      });

      test('should calculate correct standard shipping for non-EU countries', () {
        const address = DeliveryAddress(
          firstName: 'John',
          lastName: 'Smith',
          street: '123 Main St',
          city: 'New York',
          postalCode: '10001',
          country: 'USA',
        );

        final cost = service.calculateStandardShipping(address);

        expect(cost, equals(15.99));
      });
    });

    group('Express Shipping Costs', () {
      test('should calculate correct express shipping for Germany', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final cost = service.calculateExpressShipping(address);

        expect(cost, equals(8.99));
      });

      test('should calculate correct express shipping for Austria', () {
        const address = DeliveryAddress(
          firstName: 'Franz',
          lastName: 'Schmidt',
          street: 'Ringstraße 1',
          city: 'Vienna',
          postalCode: '1010',
          country: 'Austria',
        );

        final cost = service.calculateExpressShipping(address);

        expect(cost, equals(12.99));
      });

      test('should calculate correct express shipping for Switzerland', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Zimmermann',
          street: 'Bahnhofstraße 50',
          city: 'Zurich',
          postalCode: '8001',
          country: 'Switzerland',
        );

        final cost = service.calculateExpressShipping(address);

        expect(cost, equals(18.99));
      });

      test('should calculate correct express shipping for other EU countries', () {
        const address = DeliveryAddress(
          firstName: 'Jean',
          lastName: 'Dubois',
          street: 'Rue de la Paix 10',
          city: 'Paris',
          postalCode: '75001',
          country: 'France',
        );

        final cost = service.calculateExpressShipping(address);

        expect(cost, equals(16.99));
      });

      test('should calculate correct express shipping for non-EU countries', () {
        const address = DeliveryAddress(
          firstName: 'John',
          lastName: 'Smith',
          street: '123 Main St',
          city: 'New York',
          postalCode: '10001',
          country: 'USA',
        );

        final cost = service.calculateExpressShipping(address);

        expect(cost, equals(29.99));
      });
    });

    group('Free Shipping Eligibility', () {
      test('should offer free shipping for orders over threshold in Germany', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final isEligible = service.isEligibleForFreeShipping(address, 75.00);

        expect(isEligible, isTrue);
      });

      test('should not offer free shipping for orders under threshold', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final isEligible = service.isEligibleForFreeShipping(address, 40.00);

        expect(isEligible, isFalse);
      });

      test('should have higher free shipping threshold for non-EU countries', () {
        const address = DeliveryAddress(
          firstName: 'John',
          lastName: 'Smith',
          street: '123 Main St',
          city: 'New York',
          postalCode: '10001',
          country: 'USA',
        );

        final isEligibleLow = service.isEligibleForFreeShipping(address, 75.00);
        final isEligibleHigh = service.isEligibleForFreeShipping(address, 150.00);

        expect(isEligibleLow, isFalse);
        expect(isEligibleHigh, isTrue);
      });
    });

    group('Delivery Time Estimates', () {
      test('should estimate correct standard delivery time for Germany', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final estimate = service.estimateStandardDeliveryDays(address);

        expect(estimate, equals(2));
      });

      test('should estimate correct express delivery time for Germany', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final estimate = service.estimateExpressDeliveryDays(address);

        expect(estimate, equals(1));
      });

      test('should estimate longer delivery times for non-EU countries', () {
        const address = DeliveryAddress(
          firstName: 'John',
          lastName: 'Smith',
          street: '123 Main St',
          city: 'New York',
          postalCode: '10001',
          country: 'USA',
        );

        final standardEstimate = service.estimateStandardDeliveryDays(address);
        final expressEstimate = service.estimateExpressDeliveryDays(address);

        expect(standardEstimate, greaterThan(5));
        expect(expressEstimate, greaterThan(3));
      });
    });

    group('Address Validation', () {
      test('should validate complete address as valid', () {
        const validAddress = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final isValid = service.validateAddress(validAddress);

        expect(isValid, isTrue);
      });

      test('should invalidate address with missing required fields', () {
        const invalidAddress = DeliveryAddress(
          firstName: 'Hans',
          lastName: '', // Missing last name
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final isValid = service.validateAddress(invalidAddress);

        expect(isValid, isFalse);
      });

      test('should invalidate address with invalid postal code format', () {
        const invalidAddress = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: 'INVALID', // Invalid postal code
          country: 'Germany',
        );

        final isValid = service.validateAddress(invalidAddress);

        expect(isValid, isFalse);
      });
    });

    group('Special Shipping Rules', () {
      test('should apply island surcharge for certain regions', () {
        const islandAddress = DeliveryAddress(
          firstName: 'Maria',
          lastName: 'Gonzalez',
          street: 'Calle Principal 1',
          city: 'Las Palmas',
          postalCode: '35001',
          country: 'Spain',
          region: 'Canary Islands',
        );

        final cost = service.calculateStandardShipping(islandAddress);
        final surcharge = service.getIslandSurcharge(islandAddress);

        expect(surcharge, greaterThan(0));
        expect(cost, greaterThan(8.99)); // Base EU rate + surcharge
      });

      test('should handle remote area surcharges', () {
        const remoteAddress = DeliveryAddress(
          firstName: 'Olaf',
          lastName: 'Hansen',
          street: 'Fjellveien 10',
          city: 'Tromsø',
          postalCode: '9008',
          country: 'Norway',
        );

        final cost = service.calculateStandardShipping(remoteAddress);
        final isRemote = service.isRemoteArea(remoteAddress);

        expect(isRemote, isTrue);
        expect(cost, greaterThan(15.99)); // Higher cost for remote areas
      });
    });

    group('Bulk Order Discounts', () {
      test('should apply bulk discount for large orders', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final standardCost = service.calculateStandardShipping(address);
        final bulkCost = service.calculateBulkShipping(address, itemCount: 10);

        expect(bulkCost, lessThan(standardCost * 10));
      });

      test('should not apply bulk discount for small orders', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final standardCost = service.calculateStandardShipping(address);
        final bulkCost = service.calculateBulkShipping(address, itemCount: 2);

        expect(bulkCost, equals(standardCost));
      });
    });

    group('Error Handling', () {
      test('should handle null address gracefully', () {
        expect(() => service.validateAddress(null as DeliveryAddress?), 
               throwsA(isA<ArgumentError>()));
      });

      test('should handle unknown countries with default rates', () {
        const unknownCountryAddress = DeliveryAddress(
          firstName: 'Test',
          lastName: 'User',
          street: 'Test Street 1',
          city: 'Test City',
          postalCode: '12345',
          country: 'Unknown Country',
        );

        final cost = service.calculateStandardShipping(unknownCountryAddress);

        expect(cost, equals(15.99)); // Default non-EU rate
      });

      test('should handle empty address fields', () {
        const emptyFieldsAddress = DeliveryAddress(
          firstName: '',
          lastName: '',
          street: '',
          city: '',
          postalCode: '',
          country: '',
        );

        final isValid = service.validateAddress(emptyFieldsAddress);

        expect(isValid, isFalse);
      });
    });

    group('Currency and Pricing', () {
      test('should return costs in correct currency format', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final cost = service.calculateStandardShipping(address);
        final formattedCost = service.formatShippingCost(cost);

        expect(formattedCost, matches(RegExp(r'€\d+\.\d{2}')));
      });

      test('should handle different currency zones', () {
        const swissAddress = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Zimmermann',
          street: 'Bahnhofstraße 50',
          city: 'Zurich',
          postalCode: '8001',
          country: 'Switzerland',
        );

        final cost = service.calculateStandardShipping(swissAddress);
        final currency = service.getShippingCurrency(swissAddress);

        expect(currency, equals('CHF'));
        expect(cost, greaterThan(0));
      });
    });

    group('Performance and Caching', () {
      test('should cache shipping calculations for repeated requests', () {
        const address = DeliveryAddress(
          firstName: 'Hans',
          lastName: 'Mueller',
          street: 'Hauptstraße 123',
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
        );

        final startTime = DateTime.now();
        service.calculateStandardShipping(address);
        service.calculateStandardShipping(address); // Should use cache
        final endTime = DateTime.now();

        final duration = endTime.difference(startTime);
        expect(duration.inMilliseconds, lessThan(100)); // Should be fast due to caching
      });
    });
  });
}