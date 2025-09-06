import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/order.dart';
import 'package:whisky_hikes/domain/models/payment_result.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

void main() {
  group('Payment Models Tests (TDD - Green Phase)', () {
    
    group('Order Model', () {
      test('should create Order with all required fields', () {
        // Arrange & Act
        final order = Order(
          id: 123,
          orderNumber: 'WH2025-000123',
          hikeId: 1,
          userId: 'user_456',
          totalAmount: 30.99,
          deliveryType: DeliveryType.standardShipping,
          status: OrderStatus.confirmed,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(order.id, equals(123));
        expect(order.orderNumber, equals('WH2025-000123'));
        expect(order.hikeId, equals(1));
        expect(order.totalAmount, equals(30.99));
        expect(order.deliveryType, equals(DeliveryType.standardShipping));
        expect(order.status, equals(OrderStatus.confirmed));
        expect(order.requiresDeliveryAddress, isTrue);
      });

      test('should calculate delivery cost correctly', () {
        // Arrange & Act - Shipping order
        final shippingOrder = Order(
          id: 1,
          orderNumber: 'WH2025-001',
          hikeId: 1,
          userId: 'user_123',
          totalAmount: 30.99,
          deliveryType: DeliveryType.standardShipping,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        // Pickup order
        final pickupOrder = shippingOrder.copyWith(
          deliveryType: DeliveryType.pickup,
          totalAmount: 25.99,
        );

        // Assert
        expect(shippingOrder.deliveryCost, equals(5.0));
        expect(shippingOrder.basePrice, equals(25.99));
        expect(pickupOrder.deliveryCost, equals(0.0));
        expect(pickupOrder.basePrice, equals(25.99));
      });

      test('should handle order status logic correctly', () {
        // Arrange & Act
        final pendingOrder = Order(
          id: 1,
          orderNumber: 'WH2025-001',
          hikeId: 1,
          userId: 'user_123',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final deliveredOrder = pendingOrder.copyWith(status: OrderStatus.delivered);
        final cancelledOrder = pendingOrder.copyWith(status: OrderStatus.cancelled);

        // Assert
        expect(pendingOrder.canBeCancelled, isTrue);
        expect(pendingOrder.isFinalStatus, isFalse);
        
        expect(deliveredOrder.canBeCancelled, isFalse);
        expect(deliveredOrder.isFinalStatus, isTrue);
        
        expect(cancelledOrder.isFinalStatus, isTrue);
        expect(pendingOrder.formattedOrderNumber, equals('#WH2025-001'));
      });

      test('should serialize to/from JSON correctly', () {
        // Arrange
        final order = Order(
          id: 123,
          orderNumber: 'WH2025-000123',
          hikeId: 1,
          userId: 'user_456',
          totalAmount: 30.99,
          deliveryType: DeliveryType.standardShipping,
          status: OrderStatus.confirmed,
          createdAt: DateTime.parse('2025-01-01T12:00:00Z'),
          deliveryAddress: {
            'street': 'Teststraße 123',
            'city': 'Hamburg',
            'postalCode': '20095',
            'country': 'DE'
          },
        );

        // Act
        final json = order.toJson();
        final deserializedOrder = Order.fromJson(json);

        // Assert
        expect(deserializedOrder.id, equals(order.id));
        expect(deserializedOrder.orderNumber, equals(order.orderNumber));
        expect(deserializedOrder.deliveryType, equals(order.deliveryType));
        expect(deserializedOrder.status, equals(order.status));
        expect(deserializedOrder.deliveryAddress?['street'], equals('Teststraße 123'));
      });
    });

    group('PaymentResult Model', () {
      test('should create successful PaymentResult', () {
        // Arrange
        final order = Order(
          id: 123,
          orderNumber: 'WH2025-000123',
          hikeId: 1,
          userId: 'user_456',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.confirmed,
          createdAt: DateTime.now(),
        );

        // Act
        final result = PaymentResult.success(
          order: order,
          clientSecret: 'pi_test_123_secret_456',
          paymentIntentId: 'pi_test_123',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.order?.id, equals(123));
        expect(result.status, equals(PaymentStatus.succeeded));
        expect(result.clientSecret, equals('pi_test_123_secret_456'));
        expect(result.wasCancelled, isFalse);
        expect(result.requiresUserAction, isFalse);
      });

      test('should create failed PaymentResult', () {
        // Act
        final result = PaymentResult.failure(
          error: 'Your card was declined',
          status: PaymentStatus.failed,
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, equals(PaymentStatus.failed));
        expect(result.errorMessage, equals('Your card was declined'));
        expect(result.friendlyErrorMessage, contains('Karte wurde abgelehnt'));
      });

      test('should create cancelled PaymentResult', () {
        // Act
        final result = PaymentResult.cancelled(
          message: 'Payment cancelled by user',
          paymentIntentId: 'pi_test_123',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, equals(PaymentStatus.cancelled));
        expect(result.wasCancelled, isTrue);
        expect(result.friendlyErrorMessage, equals('Zahlung wurde abgebrochen.'));
      });

      test('should provide friendly error messages in German', () {
        // Test various error scenarios
        final declinedResult = PaymentResult.failure(error: 'Card was declined');
        final networkResult = PaymentResult.failure(error: 'Network connection failed');
        final expiredResult = PaymentResult.failure(error: 'Your card has expired');
        final invalidResult = PaymentResult.failure(error: 'Invalid card number');

        expect(declinedResult.friendlyErrorMessage, contains('Karte wurde abgelehnt'));
        expect(networkResult.friendlyErrorMessage, contains('Netzwerkfehler'));
        expect(expiredResult.friendlyErrorMessage, contains('Karte ist abgelaufen'));
        expect(invalidResult.friendlyErrorMessage, contains('Ungültige Kartendaten'));
      });
    });

    group('PaymentIntent Model', () {
      test('should create PaymentIntent with correct properties', () {
        // Arrange & Act
        final paymentIntent = PaymentIntent(
          id: 'pi_test_123',
          clientSecret: 'pi_test_123_secret_456',
          amount: 2599, // 25.99 EUR in cents
          currency: 'eur',
          status: 'requires_payment_method',
          paymentMethodTypes: [PaymentMethodType.card],
          description: 'Black Forest Whisky Trail',
        );

        // Assert
        expect(paymentIntent.id, equals('pi_test_123'));
        expect(paymentIntent.amount, equals(2599));
        expect(paymentIntent.amountInEuros, equals(25.99));
        expect(paymentIntent.requiresPaymentMethod, isTrue);
        expect(paymentIntent.isSucceeded, isFalse);
        expect(paymentIntent.supportsPaymentMethod(PaymentMethodType.card), isTrue);
      });

      test('should handle different payment intent statuses', () {
        // Base payment intent
        final basePaymentIntent = PaymentIntent(
          id: 'pi_test_123',
          clientSecret: 'pi_test_123_secret_456',
          amount: 2599,
          currency: 'eur',
          status: 'requires_payment_method',
          paymentMethodTypes: [PaymentMethodType.card],
        );

        // Test different statuses
        final succeededIntent = basePaymentIntent.copyWith(status: 'succeeded');
        final requiresActionIntent = basePaymentIntent.copyWith(status: 'requires_action');
        final processingIntent = basePaymentIntent.copyWith(status: 'processing');
        final cancelledIntent = basePaymentIntent.copyWith(status: 'canceled');

        expect(succeededIntent.isSucceeded, isTrue);
        expect(requiresActionIntent.requiresAction, isTrue);
        expect(processingIntent.isProcessing, isTrue);
        expect(cancelledIntent.isCancelled, isTrue);
      });
    });

    group('CardDetails Model', () {
      test('should create CardDetails with validation data', () {
        // Arrange & Act
        final cardDetails = CardDetails(
          number: '4242424242424242',
          expMonth: 12,
          expYear: 2026,
          cvc: '123',
          name: 'Max Mustermann',
          addressLine1: 'Teststraße 123',
          addressCity: 'Hamburg',
          addressZip: '20095',
          addressCountry: 'DE',
        );

        // Assert
        expect(cardDetails.number, equals('4242424242424242'));
        expect(cardDetails.expMonth, equals(12));
        expect(cardDetails.expYear, equals(2026));
        expect(cardDetails.cvc, equals('123'));
        expect(cardDetails.name, equals('Max Mustermann'));
      });
    });

    group('PaymentMethodParams Model', () {
      test('should create card payment method params', () {
        // Arrange
        final cardDetails = CardDetails(
          number: '4242424242424242',
          expMonth: 12,
          expYear: 2026,
          cvc: '123',
        );

        final billingDetails = BillingDetails(
          name: 'Max Mustermann',
          email: 'max@example.com',
        );

        // Act
        final params = PaymentMethodParams.card(
          card: cardDetails,
          billingDetails: billingDetails,
        );

        // Assert
        expect(params.type, equals(PaymentMethodType.card));
        expect(params.card?.number, equals('4242424242424242'));
        expect(params.billingDetails?.name, equals('Max Mustermann'));
        expect(params.billingDetails?.email, equals('max@example.com'));
      });
    });
  });
}

// Diese Tests überprüfen die GREEN PHASE unseres TDD-Ansatzes:
// ✅ Models sind implementiert
// ✅ Serialisierung funktioniert
// ✅ Business Logic Extensions funktionieren
// ✅ Factory Constructors funktionieren
// ✅ Error Handling ist implementiert