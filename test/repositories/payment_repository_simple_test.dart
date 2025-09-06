import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/data/services/payment/stripe_service.dart';
import 'package:whisky_hikes/data/services/payment/multi_payment_service.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/delivery_address.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart' show PaymentMethodType;

import '../mocks/mock_repositories.mocks.dart';

void main() {
  group('PaymentRepository Tests (TDD)', () {
    late PaymentRepository paymentRepository;
    late MockSupabaseClient mockSupabaseClient;
    late MockStripeService mockStripeService;
    late MockMultiPaymentService mockMultiPaymentService;
    late MockBackendApiService mockBackendApiService;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockStripeService = MockStripeService();
      mockMultiPaymentService = MockMultiPaymentService();
      mockBackendApiService = MockBackendApiService();
      
      paymentRepository = PaymentRepository(
        supabaseClient: mockSupabaseClient,
        stripeService: mockStripeService,
        multiPaymentService: mockMultiPaymentService,
        backendApiService: mockBackendApiService,
      );
    });

    group('Order Creation', () {
      test('should create order successfully', () async {
        // Arrange
        const int hikeId = 1;
        const String userId = 'test-user-123';
        const double amount = 25.99;

        final mockOrder = BasicOrder(
          id: 1,
          orderNumber: 'ORD-123',
          hikeId: hikeId,
          userId: userId,
          totalAmount: amount,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        when(mockBackendApiService.createOrder(
          hikeId: anyNamed('hikeId'),
          userId: anyNamed('userId'),
          amount: anyNamed('amount'),
          deliveryType: anyNamed('deliveryType'),
          deliveryAddress: anyNamed('deliveryAddress'),
        )).thenAnswer((_) async => mockOrder);

        // Act
        final result = await paymentRepository.createOrder(
          hikeId: hikeId,
          userId: userId,
          amount: amount,
          deliveryType: DeliveryType.pickup,
          deliveryAddress: null,
        );

        // Assert
        expect(result, isA<BasicOrder>());
        expect(result.id, equals(1));
        expect(result.hikeId, equals(hikeId));
        expect(result.userId, equals(userId));
        expect(result.totalAmount, equals(amount));
        expect(result.deliveryType, equals(DeliveryType.pickup));
      });

      test('should create order with delivery address for shipping', () async {
        // Arrange
        const int hikeId = 1;
        const String userId = 'test-user-123';
        const double amount = 30.99; // Including delivery cost

        final deliveryAddress = {
          'street': 'Teststraße 123',
          'city': 'Hamburg',
          'postalCode': '20095',
          'country': 'DE'
        };

        final mockOrder = BasicOrder(
          id: 1,
          orderNumber: 'ORD-124',
          hikeId: hikeId,
          userId: userId,
          totalAmount: amount,
          deliveryType: DeliveryType.standardShipping,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        when(mockBackendApiService.createOrder(
          hikeId: anyNamed('hikeId'),
          userId: anyNamed('userId'),
          amount: anyNamed('amount'),
          deliveryType: anyNamed('deliveryType'),
          deliveryAddress: anyNamed('deliveryAddress'),
        )).thenAnswer((_) async => mockOrder);

        // Act
        final result = await paymentRepository.createOrder(
          hikeId: hikeId,
          userId: userId,
          amount: amount,
          deliveryType: DeliveryType.standardShipping,
          deliveryAddress: deliveryAddress,
        );

        // Assert
        expect(result, isA<BasicOrder>());
        expect(result.deliveryType, equals(DeliveryType.standardShipping));
        expect(result.totalAmount, equals(amount));
      });
    });

    group('Payment Processing', () {
      test('should process payment successfully', () async {
        // Arrange
        final order = BasicOrder(
          id: 1,
          orderNumber: 'ORD-123',
          hikeId: 1,
          userId: 'test-user-123',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final mockPaymentResult = BasicPaymentResult(
          isSuccess: true,
          order: order,
          paymentIntentId: 'pi_test_123',
        );

        when(mockMultiPaymentService.processPayment(
          amount: anyNamed('amount'),
          currency: anyNamed('currency'),
          paymentMethod: anyNamed('paymentMethod'),
          orderId: anyNamed('orderId'),
        )).thenAnswer((_) async => mockPaymentResult);

        // Act
        final result = await paymentRepository.processPayment(
          order: order,
          paymentMethod: PaymentMethodType.card,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.order, equals(order));
        expect(result.paymentIntentId, equals('pi_test_123'));
      });

      test('should handle payment failure', () async {
        // Arrange
        final order = BasicOrder(
          id: 1,
          orderNumber: 'ORD-123',
          hikeId: 1,
          userId: 'test-user-123',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        when(mockMultiPaymentService.processPayment(
          amount: anyNamed('amount'),
          currency: anyNamed('currency'),
          paymentMethod: anyNamed('paymentMethod'),
          orderId: anyNamed('orderId'),
        )).thenThrow(Exception('Payment declined'));

        // Act & Assert
        expect(
          () => paymentRepository.processPayment(
            order: order,
            paymentMethod: PaymentMethodType.card,
          ),
          throwsException,
        );
      });
    });

    group('Order Management', () {
      test('should retrieve user orders successfully', () async {
        // Arrange
        const String userId = 'user_123';
        
        final mockOrders = [
          BasicOrder(
            id: 1,
            orderNumber: 'ORD-001',
            hikeId: 1,
            userId: userId,
            totalAmount: 25.99,
            deliveryType: DeliveryType.pickup,
            status: OrderStatus.pending,
            createdAt: DateTime.now(),
          ),
          BasicOrder(
            id: 2,
            orderNumber: 'ORD-002',
            hikeId: 2,
            userId: userId,
            totalAmount: 30.99,
            deliveryType: DeliveryType.standardShipping,
            status: OrderStatus.delivered,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        when(mockBackendApiService.getUserOrders(userId))
            .thenAnswer((_) async => mockOrders);

        // Act
        final orders = await paymentRepository.getUserOrders(userId);

        // Assert
        expect(orders, isA<List<BasicOrder>>());
        expect(orders.length, equals(2));
        expect(orders[0].userId, equals(userId));
        expect(orders[1].userId, equals(userId));
      });

      test('should update order status correctly', () async {
        // Arrange
        const int orderId = 1;
        const OrderStatus newStatus = OrderStatus.processing;

        final updatedOrder = BasicOrder(
          id: orderId,
          orderNumber: 'ORD-001',
          hikeId: 1,
          userId: 'user_123',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: newStatus,
          createdAt: DateTime.now(),
        );

        when(mockBackendApiService.updateOrderStatus(
          orderId: anyNamed('orderId'),
          status: anyNamed('status'),
        )).thenAnswer((_) async => updatedOrder);

        // Act
        final result = await paymentRepository.updateOrderStatus(
          orderId: orderId,
          status: newStatus,
        );

        // Assert
        expect(result, isA<BasicOrder>());
        expect(result.id, equals(orderId));
        expect(result.status, equals(newStatus));
      });
    });

    group('Error Handling', () {
      test('should handle backend API errors during order creation', () async {
        // Arrange
        const int hikeId = 1;
        const String userId = 'test-user-123';
        const double amount = 25.99;

        when(mockBackendApiService.createOrder(
          hikeId: anyNamed('hikeId'),
          userId: anyNamed('userId'),
          amount: anyNamed('amount'),
          deliveryType: anyNamed('deliveryType'),
          deliveryAddress: anyNamed('deliveryAddress'),
        )).thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(
          () => paymentRepository.createOrder(
            hikeId: hikeId,
            userId: userId,
            amount: amount,
            deliveryType: DeliveryType.pickup,
            deliveryAddress: null,
          ),
          throwsException,
        );
      });

      test('should handle errors when retrieving user orders', () async {
        // Arrange
        const String userId = 'user_123';

        when(mockBackendApiService.getUserOrders(userId))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => paymentRepository.getUserOrders(userId),
          throwsException,
        );
      });
    });
  });
}
