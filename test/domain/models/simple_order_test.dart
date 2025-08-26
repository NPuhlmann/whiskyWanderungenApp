import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/simple_order.dart';

void main() {
  group('SimpleOrder Model Tests (TDD - Green Phase)', () {
    
    test('should create SimpleOrder with all required fields', () {
      // Arrange & Act
      final order = SimpleOrder(
        id: 123,
        orderNumber: 'WH2025-000123',
        hikeId: 1,
        userId: 'user_456',
        totalAmount: 30.99,
        deliveryType: DeliveryType.shipping,
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(order.id, equals(123));
      expect(order.orderNumber, equals('WH2025-000123'));
      expect(order.hikeId, equals(1));
      expect(order.totalAmount, equals(30.99));
      expect(order.deliveryType, equals(DeliveryType.shipping));
      expect(order.status, equals(OrderStatus.confirmed));
      expect(order.requiresDeliveryAddress, isTrue);
    });

    test('should calculate delivery cost correctly', () {
      // Arrange & Act - Shipping order
      final shippingOrder = SimpleOrder(
        id: 1,
        orderNumber: 'WH2025-001',
        hikeId: 1,
        userId: 'user_123',
        totalAmount: 30.99,
        deliveryType: DeliveryType.shipping,
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
      final pendingOrder = SimpleOrder(
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

      // Assert
      expect(pendingOrder.canBeCancelled, isTrue);
      expect(deliveredOrder.canBeCancelled, isFalse);
      expect(pendingOrder.formattedOrderNumber, equals('#WH2025-001'));
    });

    test('should serialize to/from JSON correctly', () {
      // Arrange
      final order = SimpleOrder(
        id: 123,
        orderNumber: 'WH2025-000123',
        hikeId: 1,
        userId: 'user_456',
        totalAmount: 30.99,
        deliveryType: DeliveryType.shipping,
        status: OrderStatus.confirmed,
        createdAt: DateTime.parse('2025-01-01T12:00:00Z'),
      );

      // Act
      final json = order.toJson();
      final deserializedOrder = SimpleOrder.fromJson(json);

      // Assert
      expect(deserializedOrder.id, equals(order.id));
      expect(deserializedOrder.orderNumber, equals(order.orderNumber));
      expect(deserializedOrder.deliveryType, equals(order.deliveryType));
      expect(deserializedOrder.status, equals(order.status));
    });

    test('should handle enum serialization correctly', () {
      // Arrange
      final order = SimpleOrder(
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
      final json = order.toJson();

      // Assert - Check that enums are serialized with correct @JsonValue
      expect(json['deliveryType'], equals('pickup'));
      expect(json['status'], equals('pending'));
    });
  });
}

// ✅ GREEN PHASE: SimpleOrder Model funktioniert korrekt
// ✅ Freezed Code Generation funktioniert
// ✅ JSON Serialization funktioniert
// ✅ Business Logic Extensions funktionieren
// ✅ copyWith() funktioniert
// ✅ Enum Serialization funktioniert