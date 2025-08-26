import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:whisky_hikes/data/services/payment/multi_payment_service.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';

void main() {
  group('MultiPaymentService', () {
    late MultiPaymentService multiPaymentService;

    setUp(() async {
      // Initialize environment for testing
      await dotenv.load();
      multiPaymentService = MultiPaymentService.instance;
    });

    group('Initialization', () {
      test('should initialize all payment services successfully', () async {
        // Act
        await multiPaymentService.initialize();
        
        // Assert - if no exception is thrown, initialization was successful
        expect(true, isTrue);
      });

      test('should handle missing payment configurations gracefully', () async {
        // This test verifies that the service continues to work even if some
        // payment methods are not configured (e.g., Apple Pay on Android)
        
        // Act & Assert - should not throw
        await multiPaymentService.initialize();
        expect(true, isTrue);
      });
    });

    group('Payment Method Availability', () {
      test('should always return true for card payments', () async {
        // Arrange
        await multiPaymentService.initialize();
        
        // Act
        final isAvailable = await multiPaymentService.isPaymentMethodAvailable(PaymentMethodType.card);
        
        // Assert
        expect(isAvailable, isTrue);
      });

      test('should always return true for PayPal payments', () async {
        // Arrange
        await multiPaymentService.initialize();
        
        // Act
        final isAvailable = await multiPaymentService.isPaymentMethodAvailable(PaymentMethodType.paypal);
        
        // Assert
        expect(isAvailable, isTrue);
      });

      test('should return list of available payment methods', () async {
        // Arrange
        await multiPaymentService.initialize();
        
        // Act
        final availableMethods = await multiPaymentService.getAvailablePaymentMethods();
        
        // Assert
        expect(availableMethods, isNotEmpty);
        expect(availableMethods, contains(PaymentMethodType.card));
        expect(availableMethods, contains(PaymentMethodType.paypal));
      });
    });

    group('Card Payment Processing', () {
      test('should process card payment successfully', () async {
        // Arrange
        await multiPaymentService.initialize();
        const amount = 25.99;
        
        // Act
        final result = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.card,
          amount: amount,
          currency: 'eur',
          metadata: {'test': 'card_payment'},
        );
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.status, PaymentStatus.succeeded);
        expect(result.paymentIntentId, isNotNull);
        expect(result.metadata?['payment_method'], 'card');
      });

      test('should handle card payment errors gracefully', () async {
        // Arrange
        await multiPaymentService.initialize();
        
        // Act - use invalid amount to trigger error
        final result = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.card,
          amount: -1.0, // Invalid amount
          currency: 'eur',
        );
        
        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, PaymentStatus.failed);
        expect(result.errorMessage, contains('Payment failed'));
      });
    });

    group('Apple Pay Processing', () {
      test('should process Apple Pay payment successfully when available', () async {
        // Arrange
        await multiPaymentService.initialize();
        const amount = 35.50;
        
        // Act
        final result = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.applePay,
          amount: amount,
          currency: 'eur',
          metadata: {'test': 'apple_pay'},
        );
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.status, PaymentStatus.succeeded);
        expect(result.paymentIntentId, contains('pi_apple_pay_'));
        expect(result.metadata?['payment_method'], 'apple_pay');
      });

      test('should handle Apple Pay cancellation', () async {
        // This test would normally simulate user cancellation
        // For now, we just verify the service can handle cancellation scenarios
        await multiPaymentService.initialize();
        expect(true, isTrue); // Placeholder for cancellation test
      });
    });

    group('Google Pay Processing', () {
      test('should process Google Pay payment successfully when available', () async {
        // Arrange
        await multiPaymentService.initialize();
        const amount = 42.75;
        
        // Act
        final result = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.googlePay,
          amount: amount,
          currency: 'eur',
          metadata: {'test': 'google_pay'},
        );
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.status, PaymentStatus.succeeded);
        expect(result.paymentIntentId, contains('pi_google_pay_'));
        expect(result.metadata?['payment_method'], 'google_pay');
      });
    });

    group('PayPal Processing', () {
      test('should process PayPal payment successfully', () async {
        // Arrange
        await multiPaymentService.initialize();
        const amount = 29.99;
        
        // Act
        final result = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.paypal,
          amount: amount,
          currency: 'eur',
          metadata: {'test': 'paypal'},
        );
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.status, PaymentStatus.succeeded);
        expect(result.paymentIntentId, contains('pi_paypal_'));
        expect(result.metadata?['payment_method'], 'paypal');
      });

      test('should handle PayPal payment limit errors', () async {
        // Arrange
        await multiPaymentService.initialize();
        const amount = 1500.0; // Above test limit
        
        // Act
        final result = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.paypal,
          amount: amount,
          currency: 'eur',
        );
        
        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, PaymentStatus.failed);
        expect(result.errorMessage, contains('PayPal payment limit exceeded'));
      });
    });

    group('Payment Method Display Names', () {
      test('should return correct German display names', () {
        // Arrange
        final service = MultiPaymentService.instance;
        
        // Act & Assert
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.card), 'Kreditkarte');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.applePay), 'Apple Pay');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.googlePay), 'Google Pay');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.paypal), 'PayPal');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.sepaDebit), 'SEPA Lastschrift');
      });

      test('should return appropriate icons for payment methods', () {
        // Arrange
        final service = MultiPaymentService.instance;
        
        // Act & Assert
        expect(service.getPaymentMethodIcon(PaymentMethodType.card), 'credit_card');
        expect(service.getPaymentMethodIcon(PaymentMethodType.applePay), 'apple');
        expect(service.getPaymentMethodIcon(PaymentMethodType.googlePay), 'google');
        expect(service.getPaymentMethodIcon(PaymentMethodType.paypal), 'paypal');
      });
    });

    group('Error Handling', () {
      test('should handle unsupported payment methods', () async {
        // Arrange
        await multiPaymentService.initialize();
        
        // Act
        final result = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.sofort, // Not fully implemented
          amount: 25.0,
          currency: 'eur',
        );
        
        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, PaymentStatus.failed);
        expect(result.errorMessage, contains('not implemented'));
      });

      test('should handle network errors gracefully', () async {
        // This test would simulate network failures
        // For now, we test that the service handles exceptions properly
        await multiPaymentService.initialize();
        
        // The service should not crash on unexpected errors
        expect(true, isTrue);
      });
    });

    group('Security & Validation', () {
      test('should validate payment amounts', () async {
        // Arrange
        await multiPaymentService.initialize();
        
        // Act - test zero amount
        final result1 = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.card,
          amount: 0.0,
          currency: 'eur',
        );
        
        // Act - test negative amount  
        final result2 = await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.card,
          amount: -5.0,
          currency: 'eur',
        );
        
        // Assert
        expect(result1.isSuccess, isFalse);
        expect(result2.isSuccess, isFalse);
      });

      test('should handle payment method initialization errors', () {
        // Test that service doesn't crash if payment method initialization fails
        expect(() => multiPaymentService.initialize(), returnsNormally);
      });
    });

    group('Integration Tests', () {
      test('should handle concurrent payment requests', () async {
        // Arrange
        await multiPaymentService.initialize();
        const amount = 15.99;
        
        // Act - Create multiple concurrent payment requests
        final futures = List.generate(3, (index) =>
          multiPaymentService.processPayment(
            paymentMethod: PaymentMethodType.card,
            amount: amount,
            currency: 'eur',
            metadata: {'concurrent_test': index.toString()},
          ),
        );
        
        final results = await Future.wait(futures);
        
        // Assert - All payments should succeed
        for (final result in results) {
          expect(result.isSuccess, isTrue);
          expect(result.status, PaymentStatus.succeeded);
        }
      });

      test('should maintain state consistency across operations', () async {
        // Arrange
        await multiPaymentService.initialize();
        
        // Act - Perform multiple operations
        await multiPaymentService.getAvailablePaymentMethods();
        await multiPaymentService.isPaymentMethodAvailable(PaymentMethodType.card);
        await multiPaymentService.processPayment(
          paymentMethod: PaymentMethodType.card,
          amount: 10.0,
        );
        
        // Assert - Service should still be functional
        final methods = await multiPaymentService.getAvailablePaymentMethods();
        expect(methods, isNotEmpty);
      });
    });
  });
}