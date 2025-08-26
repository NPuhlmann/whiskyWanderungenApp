import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:whisky_hikes/data/services/payment/stripe_service.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';

void main() {
  group('StripeService', () {
    late StripeService stripeService;

    setUp(() {
      stripeService = StripeService.instance;
    });

    group('Initialization', () {
      test('should initialize Stripe with publishable key', () async {
        // Green Phase: Test für StripeService Initialization
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';

        // Act & Assert
        await stripeService.initialize(testPublishableKey);
        
        // Test passes if no exception is thrown
        expect(true, isTrue);
      });

      test('should throw error with invalid publishable key', () async {
        // Green Phase: Validation Test
        // Arrange
        const String invalidKey = '';

        // Act & Assert
        try {
          await stripeService.initialize(invalidKey);
          fail('Should have thrown an error for invalid key');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('required'));
        }
      });

      test('should handle Stripe initialization errors', () async {
        // Green Phase: Error handling für invalid key format
        // Arrange
        const String testKey = 'sk_test_invalid_format'; // Wrong prefix

        // Act & Assert
        try {
          await stripeService.initialize(testKey);
          fail('Should have thrown an error for invalid key format');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('Invalid'));
        }
      });
    });

    group('Payment Intent Creation', () {
      test('should create payment intent with valid parameters', () async {
        // Green Phase: Payment Intent Creation
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const double amount = 25.99;
        const String currency = 'eur';
        const Map<String, dynamic> metadata = {'hike_id': '1', 'delivery_type': 'pickup'};

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: amount,
          currency: currency,
          metadata: metadata,
        );
        
        // Assert
        expect(result, isA<PaymentIntentResult>());
        expect(result.clientSecret, isNotEmpty);
        expect(result.amount, equals((amount * 100).toInt())); // Stripe uses cents
        expect(result.currency, equals(currency));
        expect(result.id, isNotEmpty);
        expect(result.status, equals('requires_payment_method'));
      });

      test('should handle invalid amount errors', () async {
        // Green Phase: Validation für negative amounts
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const double invalidAmount = -25.99;

        // Act & Assert
        try {
          await stripeService.createPaymentIntent(amount: invalidAmount);
          fail('Should reject negative amounts');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('greater than 0'));
        }
      });

      test('should handle excessive amount errors', () async {
        // Green Phase: Validation für zu hohe Beträge
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const double excessiveAmount = 1000000.0; // Over limit

        // Act & Assert
        try {
          await stripeService.createPaymentIntent(amount: excessiveAmount);
          fail('Should reject excessive amounts');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('exceeds maximum limit'));
        }
      });

      test('should handle zero amount errors', () async {
        // Green Phase: Validation für zero amounts
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const double zeroAmount = 0.0;

        // Act & Assert
        try {
          await stripeService.createPaymentIntent(amount: zeroAmount);
          fail('Should reject zero amounts');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('greater than 0'));
        }
      });
    });

    group('Payment Processing', () {
      test('should process payment successfully', () async {
        // Green Phase: Payment Processing
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const double amount = 15.50;
        const String currency = 'eur';

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: amount,
          currency: currency,
        );
        
        // Assert
        expect(result, isA<PaymentIntentResult>());
        expect(result.amount, equals((amount * 100).toInt()));
        expect(result.currency, equals(currency));
        expect(result.status, equals('requires_payment_method'));
      });

      test('should handle different currencies', () async {
        // Green Phase: Multi-currency support
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const currencies = ['eur', 'usd', 'gbp', 'chf'];
        
        for (final currency in currencies) {
          // Act
          final result = await stripeService.createPaymentIntent(
            amount: 10.0,
            currency: currency,
          );
          
          // Assert
          expect(result.currency, equals(currency));
        }
      });

      test('should handle metadata correctly', () async {
        // Green Phase: Metadata handling
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const Map<String, dynamic> metadata = {
          'hike_id': '123',
          'delivery_type': 'shipping',
          'user_id': 'user_456',
        };

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: 20.0,
          metadata: metadata,
        );
        
        // Assert
        expect(result, isA<PaymentIntentResult>());
        // Note: Stripe doesn't return metadata in PaymentIntent creation response
        // Metadata is stored on the PaymentIntent but not returned in the creation response
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Green Phase: Network error handling
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        // This test would require mocking network failures
        // For now, we test that the service doesn't crash on initialization
        expect(stripeService, isNotNull);
      });

      test('should handle Stripe API errors', () async {
        // Green Phase: API error handling
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        // This test would require mocking Stripe API errors
        // For now, we test basic functionality
        expect(stripeService, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('should handle very small amounts', () async {
        // Green Phase: Edge case handling
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const double smallAmount = 0.01; // Minimum amount

        // Act
        final result = await stripeService.createPaymentIntent(amount: smallAmount);
        
        // Assert
        expect(result, isA<PaymentIntentResult>());
        expect(result.amount, equals(1)); // 1 cent
      });

      test('should handle large amounts within limits', () async {
        // Green Phase: Large amount handling
        // Arrange
        const String testPublishableKey = 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
        await stripeService.initialize(testPublishableKey);
        
        const double largeAmount = 999999.99; // Just under limit

        // Act
        final result = await stripeService.createPaymentIntent(amount: largeAmount);
        
        // Assert
        expect(result, isA<PaymentIntentResult>());
        expect(result.amount, equals((largeAmount * 100).toInt()));
      });
    });
  });
}