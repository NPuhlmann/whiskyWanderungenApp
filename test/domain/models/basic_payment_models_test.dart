import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';

void main() {
  group('Basic Payment Models Tests (TDD - Green Phase)', () {
    group('BasicOrder Model', () {
      test('should create BasicOrder with all required fields', () {
        // Arrange & Act
        final order = BasicOrder(
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
        final shippingOrder = BasicOrder(
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
        final pendingOrder = BasicOrder(
          id: 1,
          orderNumber: 'WH2025-001',
          hikeId: 1,
          userId: 'user_123',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final deliveredOrder = pendingOrder.copyWith(
          status: OrderStatus.delivered,
        );
        final cancelledOrder = pendingOrder.copyWith(
          status: OrderStatus.cancelled,
        );

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
        final order = BasicOrder(
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
            'country': 'DE',
          },
        );

        // Act
        final json = order.toJson();
        final deserializedOrder = BasicOrder.fromJson(json);

        // Assert
        expect(deserializedOrder.id, equals(order.id));
        expect(deserializedOrder.orderNumber, equals(order.orderNumber));
        expect(deserializedOrder.deliveryType, equals(order.deliveryType));
        expect(deserializedOrder.status, equals(order.status));
        expect(
          deserializedOrder.deliveryAddress?['street'],
          equals('Teststraße 123'),
        );
        expect(deserializedOrder, equals(order));
      });

      test('should handle copyWith correctly', () {
        // Arrange
        final originalOrder = BasicOrder(
          id: 1,
          orderNumber: 'WH2025-001',
          hikeId: 1,
          userId: 'user_123',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act
        final updatedOrder = originalOrder.copyWith(
          status: OrderStatus.confirmed,
          totalAmount: 30.99,
        );

        // Assert
        expect(updatedOrder.status, equals(OrderStatus.confirmed));
        expect(updatedOrder.totalAmount, equals(30.99));
        expect(updatedOrder.id, equals(originalOrder.id)); // Unchanged
        expect(
          updatedOrder.orderNumber,
          equals(originalOrder.orderNumber),
        ); // Unchanged
      });
    });

    group('BasicPaymentResult Model', () {
      test('should create successful BasicPaymentResult', () {
        // Arrange
        final order = BasicOrder(
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
        final result = BasicPaymentResult.success(
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

      test('should create failed BasicPaymentResult', () {
        // Act
        final result = BasicPaymentResult.failure(
          error: 'Your card was declined',
          status: PaymentStatus.failed,
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, equals(PaymentStatus.failed));
        expect(result.errorMessage, equals('Your card was declined'));
        expect(result.friendlyErrorMessage, contains('Karte wurde abgelehnt'));
      });

      test('should create cancelled BasicPaymentResult', () {
        // Act
        final result = BasicPaymentResult.cancelled(
          message: 'Payment cancelled by user',
          paymentIntentId: 'pi_test_123',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, equals(PaymentStatus.cancelled));
        expect(result.wasCancelled, isTrue);
        expect(
          result.friendlyErrorMessage,
          equals('Zahlung wurde abgebrochen.'),
        );
      });

      test('should create requiresAction BasicPaymentResult', () {
        // Act
        final result = BasicPaymentResult.requiresAction(
          clientSecret: 'pi_test_123_secret_456',
          paymentIntentId: 'pi_test_123',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, equals(PaymentStatus.requiresAction));
        expect(result.requiresUserAction, isTrue);
        expect(result.clientSecret, equals('pi_test_123_secret_456'));
      });

      test('should provide friendly error messages in German', () {
        // Test various error scenarios
        final declinedResult = BasicPaymentResult.failure(
          error: 'Card was declined',
        );
        final networkResult = BasicPaymentResult.failure(
          error: 'Network connection failed',
        );
        final expiredResult = BasicPaymentResult.failure(
          error: 'Your card has expired',
        );
        final invalidResult = BasicPaymentResult.failure(
          error: 'Invalid card number',
        );

        expect(
          declinedResult.friendlyErrorMessage,
          contains('Karte wurde abgelehnt'),
        );
        expect(networkResult.friendlyErrorMessage, contains('Netzwerkfehler'));
        expect(
          expiredResult.friendlyErrorMessage,
          contains('Karte ist abgelaufen'),
        );
        expect(
          invalidResult.friendlyErrorMessage,
          contains('Ungültige Kartendaten'),
        );
      });

      test('should serialize to/from JSON correctly', () {
        // Arrange
        final order = BasicOrder(
          id: 123,
          orderNumber: 'WH2025-000123',
          hikeId: 1,
          userId: 'user_456',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.confirmed,
          createdAt: DateTime.now(),
        );

        final result = BasicPaymentResult.success(
          order: order,
          clientSecret: 'pi_test_123_secret_456',
          paymentIntentId: 'pi_test_123',
        );

        // Act
        final json = result.toJson();
        final deserializedResult = BasicPaymentResult.fromJson(json);

        // Assert
        expect(deserializedResult.isSuccess, equals(result.isSuccess));
        expect(deserializedResult.status, equals(result.status));
        expect(deserializedResult.clientSecret, equals(result.clientSecret));
        expect(deserializedResult.order?.id, equals(result.order?.id));
      });
    });

    group('Enum Serialization', () {
      test('should serialize OrderStatus correctly', () {
        final order = BasicOrder(
          id: 1,
          orderNumber: 'WH2025-001',
          hikeId: 1,
          userId: 'user_123',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final json = order.toJson();
        expect(json['status'], equals('pending'));
        expect(json['deliveryType'], equals('pickup'));
      });

      test('should deserialize OrderStatus correctly', () {
        final json = {
          'id': 1,
          'orderNumber': 'WH2025-001',
          'hikeId': 1,
          'userId': 'user_123',
          'totalAmount': 25.99,
          'deliveryType': 'standardShipping',
          'status': 'confirmed',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final order = BasicOrder.fromJson(json);
        expect(order.status, equals(OrderStatus.confirmed));
        expect(order.deliveryType, equals(DeliveryType.standardShipping));
      });
    });
  });
}

// ✅ GREEN PHASE: Basic Payment Models funktionieren!
// ✅ JSON Serialization funktioniert
// ✅ Business Logic Extensions funktionieren
// ✅ Factory Constructors funktionieren
// ✅ copyWith() funktioniert
// ✅ Enum Serialization funktioniert
// ✅ Error Handling funktioniert
// ✅ Equals/HashCode funktioniert
