import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:whisky_hikes/data/services/payment/multi_payment_service.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart';

void main() {
  group('MultiPaymentService - Basic Tests', () {
    late MultiPaymentService service;

    setUp(() async {
      // Initialize environment for testing
      try {
        await dotenv.load();
      } catch (e) {
        // If .env file doesn't exist, set minimal test values
        dotenv.load(mergeWith: {
          'DEV_MODE': 'true',
          'STRIPE_PUBLISHABLE_KEY_TEST': 'pk_test_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
          'APPLE_PAY_MERCHANT_ID_TEST': 'merchant.com.whiskyhikes.test',
          'APPLE_MERCHANT_DISPLAY_NAME_TEST': 'Whisky Hikes Test',
          'GOOGLE_PAY_MERCHANT_ID_TEST': 'BCR2DN6TR5XMERKV',
          'GOOGLE_PAY_MERCHANT_NAME_TEST': 'Whisky Hikes Test Merchant',
        });
      }
      service = MultiPaymentService.instance;
    });

    group('Service Initialization', () {
      test('should initialize without throwing errors', () async {
        // Act & Assert
        expect(() => service.initialize(), returnsNormally);
      });
    });

    group('Display Names and Icons', () {
      test('should return correct German display names', () {
        // Act & Assert
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.card), 'Kreditkarte');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.applePay), 'Apple Pay');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.googlePay), 'Google Pay');
        // PayPal not in enum yet - future implementation
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.sepaDebit), 'SEPA Lastschrift');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.sofort), 'Sofort');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.giropay), 'Giropay');
        expect(service.getPaymentMethodDisplayName(PaymentMethodType.ideal), 'iDEAL');
      });

      test('should return appropriate icons for payment methods', () {
        // Act & Assert
        expect(service.getPaymentMethodIcon(PaymentMethodType.card), 'credit_card');
        expect(service.getPaymentMethodIcon(PaymentMethodType.applePay), 'apple');
        expect(service.getPaymentMethodIcon(PaymentMethodType.googlePay), 'google');
        // PayPal icon test - future implementation
        expect(service.getPaymentMethodIcon(PaymentMethodType.sepaDebit), 'account_balance');
        expect(service.getPaymentMethodIcon(PaymentMethodType.sofort), 'flash_on');
        expect(service.getPaymentMethodIcon(PaymentMethodType.giropay), 'euro_symbol');
        expect(service.getPaymentMethodIcon(PaymentMethodType.ideal), 'euro_symbol');
      });
    });

    group('Payment Method Availability', () {
      test('should always return true for basic payment methods', () async {
        // Arrange
        await service.initialize();
        
        // Act & Assert
        expect(await service.isPaymentMethodAvailable(PaymentMethodType.card), isTrue);
        expect(await service.isPaymentMethodAvailable(PaymentMethodType.applePay), isTrue);
      });

      test('should return list of available payment methods', () async {
        // Arrange
        await service.initialize();
        
        // Act
        final availableMethods = await service.getAvailablePaymentMethods();
        
        // Assert
        expect(availableMethods, isNotEmpty);
        expect(availableMethods, contains(PaymentMethodType.card));
        expect(availableMethods, contains(PaymentMethodType.applePay));
      });
    });

    group('Basic Service Functionality', () {
      test('should handle service lifecycle correctly', () async {
        // Test that service can be initialized multiple times without issues
        await service.initialize();
        await service.initialize(); // Should not throw
        
        expect(true, isTrue);
      });

      test('should handle invalid payment method gracefully', () async {
        // Arrange
        await service.initialize();
        
        // Act & Assert - should return false for unavailable methods
        expect(await service.isPaymentMethodAvailable(PaymentMethodType.sofort), isFalse);
      });
    });
  });
}