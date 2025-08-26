import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/data/services/payment/stripe_service.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';

import 'payment_repository_test.mocks.dart';

@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder,
  StripeService,
])
void main() {
  group('PaymentRepository Tests (TDD - Red Phase)', () {
    late PaymentRepository repository;
    late MockSupabaseClient mockSupabaseClient;
    late MockPostgrestClient mockPostgrestClient;
    late MockPostgrestQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockStripeService mockStripeService;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockPostgrestClient = MockPostgrestClient();
      mockQueryBuilder = MockPostgrestQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockStripeService = MockStripeService();
      
      // Setup Supabase client mock chain
      when(mockSupabaseClient.from(any)).thenReturn(mockQueryBuilder);
      
      repository = PaymentRepository(
        supabaseClient: mockSupabaseClient,
        stripeService: mockStripeService,
      );
    });

    group('Order Creation', () {
      test('should create order with order items successfully', () async {
        // Arrange
        final hikeId = 1;
        final userId = 'test-user-123';
        final amount = 30.99;
        final deliveryType = DeliveryType.shipping;
        
        final orderResponse = {
          'id': 123,
          'order_number': 'WH2025-000123',
          'hike_id': hikeId,
          'user_id': userId,
          'total_amount': amount,
          'delivery_type': 'shipping',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };

        final orderItemResponse = {
          'id': 1,
          'order_id': 123,
          'hike_id': hikeId,
          'quantity': 1,
          'unit_price': 25.99,
          'total_price': 25.99,
        };

        // Mock order creation
        when(mockQueryBuilder.insert(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single())
            .thenAnswer((_) async => orderResponse);

        // Mock order item creation
        when(mockSupabaseClient.from('order_items'))
            .thenReturn(mockQueryBuilder);

        // Act
        final result = await repository.createOrder(
          hikeId: hikeId,
          userId: userId,
          amount: amount,
          deliveryType: deliveryType,
        );

        // Assert
        expect(result.id, equals(123));
        expect(result.orderNumber, equals('WH2025-000123'));
        expect(result.hikeId, equals(hikeId));
        expect(result.userId, equals(userId));
        expect(result.totalAmount, equals(amount));
        expect(result.deliveryType, equals(deliveryType));
        expect(result.status, equals(OrderStatus.pending));
        
        // Verify Supabase calls
        verify(mockSupabaseClient.from('orders')).called(1);
        verify(mockQueryBuilder.insert(any)).called(1);
      });

      test('should generate unique order numbers', () async {
        // Arrange
        final orderResponse1 = {
          'id': 123,
          'order_number': 'WH2025-000123',
          'hike_id': 1,
          'user_id': 'user-1',
          'total_amount': 25.99,
          'delivery_type': 'pickup',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };

        final orderResponse2 = {
          'id': 124,
          'order_number': 'WH2025-000124',
          'hike_id': 1,
          'user_id': 'user-2',
          'total_amount': 30.99,
          'delivery_type': 'shipping',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };

        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single())
            .thenAnswer((_) async => orderResponse1)
            .thenAnswer((_) async => orderResponse2);

        // Act
        final order1 = await repository.createOrder(
          hikeId: 1,
          userId: 'user-1', 
          amount: 25.99,
          deliveryType: DeliveryType.pickup,
        );
        
        final order2 = await repository.createOrder(
          hikeId: 1,
          userId: 'user-2',
          amount: 30.99, 
          deliveryType: DeliveryType.shipping,
        );

        // Assert
        expect(order1.orderNumber, isNot(equals(order2.orderNumber)));
        expect(order1.orderNumber, startsWith('WH2025-'));
        expect(order2.orderNumber, startsWith('WH2025-'));
      });

      test('should handle order creation failure', () async {
        // Arrange
        when(mockQueryBuilder.insert(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single())
            .thenThrow(PostgrestException(
              message: 'Insert failed',
              code: 'PGRST001',
            ));

        // Act & Assert
        expect(() async => await repository.createOrder(
          hikeId: 1,
          userId: 'test-user',
          amount: 25.99,
          deliveryType: DeliveryType.pickup,
        ), throwsA(isA<Exception>()));
      });

      test('should validate order amount constraints', () async {
        // Arrange & Act & Assert - Negative amount
        expect(() async => await repository.createOrder(
          hikeId: 1,
          userId: 'test-user',
          amount: -10.0,
          deliveryType: DeliveryType.pickup,
        ), throwsA(isA<ArgumentError>()));

        // Zero amount
        expect(() async => await repository.createOrder(
          hikeId: 1,
          userId: 'test-user',
          amount: 0.0,
          deliveryType: DeliveryType.pickup,
        ), throwsA(isA<ArgumentError>()));

        // Excessive amount
        expect(() async => await repository.createOrder(
          hikeId: 1,
          userId: 'test-user',
          amount: 1000000.0,
          deliveryType: DeliveryType.pickup,
        ), throwsA(isA<ArgumentError>()));
      });
    });

    group('Payment Processing', () {
      test('should process payment successfully', () async {
        // Arrange
        final order = BasicOrder(
          id: 123,
          orderNumber: 'WH2025-000123',
          hikeId: 1,
          userId: 'test-user',
          totalAmount: 30.99,
          deliveryType: DeliveryType.shipping,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final paymentIntentResult = PaymentIntentResult(
          id: 'pi_test_123',
          clientSecret: 'pi_test_123_secret_abc',
          amount: 3099,
          currency: 'eur',
          status: 'requires_payment_method',
        );

        final paymentResult = BasicPaymentResult(
          isSuccess: true,
          status: PaymentStatus.succeeded,
          paymentIntentId: 'pi_test_123',
          clientSecret: 'pi_test_123_secret_abc',
        );

        final paymentRecord = {
          'id': 1,
          'order_id': 123,
          'payment_intent_id': 'pi_test_123',
          'amount': 3099,
          'currency': 'eur',
          'status': 'succeeded',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Mock Stripe service
        when(mockStripeService.createPaymentIntent(
          amount: anyNamed('amount'),
          currency: anyNamed('currency'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => paymentIntentResult);

        when(mockStripeService.confirmPayment(
          clientSecret: anyNamed('clientSecret'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => paymentResult);

        // Mock payment record creation
        when(mockSupabaseClient.from('payments'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single())
            .thenAnswer((_) async => paymentRecord);

        // Mock order status update
        when(mockSupabaseClient.from('orders'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any))
            .thenReturn(mockFilterBuilder);

        // Act
        final result = await repository.processPayment(
          order: order,
          paymentMethodId: 'pm_test_card',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.status, equals(PaymentStatus.succeeded));
        expect(result.paymentIntentId, equals('pi_test_123'));
        
        // Verify interactions
        verify(mockStripeService.createPaymentIntent(
          amount: 30.99,
          currency: 'eur',
          metadata: any,
        )).called(1);
        
        verify(mockStripeService.confirmPayment(
          clientSecret: 'pi_test_123_secret_abc',
          paymentMethodId: 'pm_test_card',
          metadata: any,
        )).called(1);
      });

      test('should handle payment declined scenario', () async {
        // Arrange
        final order = BasicOrder(
          id: 123,
          orderNumber: 'WH2025-000123',
          hikeId: 1,
          userId: 'test-user',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final paymentIntentResult = PaymentIntentResult(
          id: 'pi_test_declined',
          clientSecret: 'pi_test_declined_secret_abc',
          amount: 2599,
          currency: 'eur',
          status: 'requires_payment_method',
        );

        final declinedResult = BasicPaymentResult.failure(
          error: 'Your card was declined',
          status: PaymentStatus.failed,
          paymentIntentId: 'pi_test_declined',
        );

        // Mock Stripe responses
        when(mockStripeService.createPaymentIntent(
          amount: anyNamed('amount'),
          currency: anyNamed('currency'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => paymentIntentResult);

        when(mockStripeService.confirmPayment(
          clientSecret: anyNamed('clientSecret'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => declinedResult);

        // Act
        final result = await repository.processPayment(
          order: order,
          paymentMethodId: 'pm_test_card_declined',
        );

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.status, equals(PaymentStatus.failed));
        expect(result.errorMessage, contains('declined'));
      });

      test('should handle 3D Secure authentication required', () async {
        // Arrange
        final order = BasicOrder(
          id: 123,
          orderNumber: 'WH2025-000123',
          hikeId: 1,
          userId: 'test-user',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final authRequiredResult = BasicPaymentResult.requiresAction(
          clientSecret: 'pi_test_auth_secret_abc',
          paymentIntentId: 'pi_test_auth',
        );

        when(mockStripeService.createPaymentIntent(
          amount: anyNamed('amount'),
          currency: anyNamed('currency'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => PaymentIntentResult(
          id: 'pi_test_auth',
          clientSecret: 'pi_test_auth_secret_abc',
          amount: 2599,
          currency: 'eur',
          status: 'requires_payment_method',
        ));

        when(mockStripeService.confirmPayment(
          clientSecret: anyNamed('clientSecret'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => authRequiredResult);

        // Act
        final result = await repository.processPayment(
          order: order,
          paymentMethodId: 'pm_test_card_authentication',
        );

        // Assert
        expect(result.requiresUserAction, isTrue);
        expect(result.status, equals(PaymentStatus.requiresAction));
        expect(result.clientSecret, equals('pi_test_auth_secret_abc'));
      });
    });

    group('Order Retrieval', () {
      test('should get order by id successfully', () async {
        // Arrange
        final orderId = 123;
        final orderData = {
          'id': orderId,
          'order_number': 'WH2025-000123',
          'hike_id': 1,
          'user_id': 'test-user',
          'total_amount': 30.99,
          'delivery_type': 'shipping',
          'status': 'confirmed',
          'created_at': DateTime.now().toIso8601String(),
        };

        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => orderData);

        // Act
        final order = await repository.getOrderById(orderId);

        // Assert
        expect(order.id, equals(orderId));
        expect(order.orderNumber, equals('WH2025-000123'));
        expect(order.status, equals(OrderStatus.confirmed));
      });

      test('should get user orders successfully', () async {
        // Arrange
        final userId = 'test-user-123';
        final ordersData = [
          {
            'id': 123,
            'order_number': 'WH2025-000123',
            'hike_id': 1,
            'user_id': userId,
            'total_amount': 30.99,
            'delivery_type': 'shipping',
            'status': 'delivered',
            'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          },
          {
            'id': 124,
            'order_number': 'WH2025-000124',
            'hike_id': 2,
            'user_id': userId,
            'total_amount': 25.99,
            'delivery_type': 'pickup',
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          },
        ];

        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => ordersData);

        // Act
        final orders = await repository.getUserOrders(userId);

        // Assert
        expect(orders, hasLength(2));
        expect(orders.first.id, equals(124)); // Most recent first
        expect(orders.last.id, equals(123));
        expect(orders.every((o) => o.userId == userId), isTrue);
      });

      test('should handle order not found error', () async {
        // Arrange
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 999)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(PostgrestException(
          message: 'No rows returned',
          code: 'PGRST116',
        ));

        // Act & Assert
        expect(() async => await repository.getOrderById(999), 
               throwsA(isA<Exception>()));
      });
    });

    group('Order Status Updates', () {
      test('should update order status successfully', () async {
        // Arrange
        final orderId = 123;
        final newStatus = OrderStatus.confirmed;
        
        final updatedOrderData = {
          'id': orderId,
          'order_number': 'WH2025-000123',
          'hike_id': 1,
          'user_id': 'test-user',
          'total_amount': 30.99,
          'delivery_type': 'shipping',
          'status': 'confirmed',
          'updated_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        };

        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedOrderData);

        // Act
        final updatedOrder = await repository.updateOrderStatus(
          orderId: orderId, 
          status: newStatus,
        );

        // Assert
        expect(updatedOrder.status, equals(OrderStatus.confirmed));
        expect(updatedOrder.id, equals(orderId));
        
        // Verify update call
        verify(mockQueryBuilder.update({
          'status': 'confirmed',
          'updated_at': any,
        })).called(1);
      });

      test('should update order with tracking information', () async {
        // Arrange
        final orderId = 123;
        final trackingNumber = 'DHL123456789';
        final estimatedDelivery = DateTime.now().add(const Duration(days: 3));
        
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => {
          'id': orderId,
          'status': 'shipped',
          'tracking_number': trackingNumber,
          'estimated_delivery': estimatedDelivery.toIso8601String(),
        });

        // Act
        final updatedOrder = await repository.updateOrderStatus(
          orderId: orderId,
          status: OrderStatus.shipped,
          trackingNumber: trackingNumber,
          estimatedDelivery: estimatedDelivery,
        );

        // Assert
        expect(updatedOrder.status, equals(OrderStatus.shipped));
        expect(updatedOrder.trackingNumber, equals(trackingNumber));
        expect(updatedOrder.estimatedDelivery?.day, equals(estimatedDelivery.day));
      });
    });

    group('Error Handling', () {
      test('should handle network connectivity issues', () async {
        // Arrange
        when(mockQueryBuilder.insert(any))
            .thenThrow(const SocketException('Network unreachable'));

        // Act & Assert
        expect(() async => await repository.createOrder(
          hikeId: 1,
          userId: 'test-user',
          amount: 25.99,
          deliveryType: DeliveryType.pickup,
        ), throwsA(isA<SocketException>()));
      });

      test('should handle Supabase service errors gracefully', () async {
        // Arrange
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single())
            .thenThrow(PostgrestException(
              message: 'Internal server error',
              code: 'PGRST000',
            ));

        // Act & Assert
        expect(() async => await repository.getOrderById(123), 
               throwsA(isA<PostgrestException>()));
      });

      test('should validate input parameters', () async {
        // Act & Assert - Empty user ID
        expect(() async => await repository.createOrder(
          hikeId: 1,
          userId: '',
          amount: 25.99,
          deliveryType: DeliveryType.pickup,
        ), throwsA(isA<ArgumentError>()));

        // Invalid hike ID
        expect(() async => await repository.createOrder(
          hikeId: 0,
          userId: 'test-user',
          amount: 25.99,
          deliveryType: DeliveryType.pickup,
        ), throwsA(isA<ArgumentError>()));
      });
    });
  });
}

// RED PHASE COMPLETE: Comprehensive PaymentRepository tests
// ❌ All tests should FAIL - PaymentRepository doesn't exist yet
// 📝 Next: Create PaymentRepository implementation to make tests GREEN  
// 🎯 Test Coverage: Order creation, payment processing, retrieval, status updates, error handling