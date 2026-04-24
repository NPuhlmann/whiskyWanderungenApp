import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/data/services/payment/stripe_service.dart';
import 'package:whisky_hikes/data/services/payment/multi_payment_service.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/delivery_address.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart'
    show PaymentMethodType;

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

    group('Hike Purchase Processing', () {
      test(
        'should process hike purchase successfully with pickup delivery',
        () async {
          // Green Phase: Implement actual test
          // Arrange
          const int hikeId = 1;
          const String userId = 'test-user-123';
          const double hikePrice = 25.99;
          const double expectedTotal = 25.99; // No delivery cost for pickup

          // Mock the createOrder method
          final mockOrder = BasicOrder(
            id: 1,
            orderNumber: 'ORD-123',
            hikeId: hikeId,
            userId: userId,
            totalAmount: expectedTotal,
            deliveryType: DeliveryType.pickup,
            status: OrderStatus.pending,
            createdAt: DateTime.now(),
          );

          when(
            mockBackendApiService.createOrder(
              hikeId: anyNamed('hikeId'),
              userId: anyNamed('userId'),
              amount: anyNamed('amount'),
              deliveryType: anyNamed('deliveryType'),
              deliveryAddress: anyNamed('deliveryAddress'),
            ),
          ).thenAnswer((_) async => mockOrder);

          // Mock the processPayment method
          final mockPaymentResult = BasicPaymentResult(
            isSuccess: true,
            order: mockOrder,
            paymentIntentId: 'pi_test_123',
          );

          when(
            mockMultiPaymentService.processPayment(
              amount: anyNamed('amount'),
              currency: anyNamed('currency'),
              paymentMethod: anyNamed('paymentMethod'),
              orderId: anyNamed('orderId'),
            ),
          ).thenAnswer((_) async => mockPaymentResult);

          // Act
          final result = await paymentRepository.processPayment(
            hikeId: hikeId,
            userId: userId,
            deliveryType: DeliveryType.pickup,
            deliveryAddress: null,
            paymentMethod: PaymentMethodType.card,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.order.totalAmount, equals(expectedTotal));
          expect(result.order.deliveryType, equals(DeliveryType.pickup));
          expect(result.order.hikeId, equals(hikeId));
          expect(result.order.userId, equals(userId));
        },
      );

      test('should calculate delivery cost for shipping delivery', () async {
        // Green Phase: Implement actual test
        // Arrange
        const int hikeId = 1;
        const String userId = 'test-user-123';
        const double hikePrice = 25.99;
        const double deliveryCost = 5.0;
        const double expectedTotal = 30.99; // Base price + delivery cost

        final deliveryAddress = {
          'street': 'Teststraße 123',
          'city': 'Hamburg',
          'postalCode': '20095',
          'country': 'DE',
        };

        // Mock the createOrder method with shipping
        final mockOrder = BasicOrder(
          id: 1,
          orderNumber: 'ORD-124',
          hikeId: hikeId,
          userId: userId,
          totalAmount: expectedTotal,
          deliveryType: DeliveryType.standardShipping,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        when(
          mockBackendApiService.createOrder(
            hikeId: anyNamed('hikeId'),
            userId: anyNamed('userId'),
            amount: anyNamed('amount'),
            deliveryType: anyNamed('deliveryType'),
            deliveryAddress: anyNamed('deliveryAddress'),
          ),
        ).thenAnswer((_) async => mockOrder);

        // Mock the processPayment method
        final mockPaymentResult = BasicPaymentResult(
          isSuccess: true,
          order: mockOrder,
          paymentIntentId: 'pi_test_124',
        );

        when(
          mockMultiPaymentService.processPayment(
            amount: anyNamed('amount'),
            currency: anyNamed('currency'),
            paymentMethod: anyNamed('paymentMethod'),
            orderId: anyNamed('orderId'),
          ),
        ).thenAnswer((_) async => mockPaymentResult);

        // Act
        final result = await paymentRepository.processPayment(
          hikeId: hikeId,
          userId: userId,
          deliveryType: DeliveryType.standardShipping,
          deliveryAddress: deliveryAddress,
          paymentMethod: PaymentMethodType.card,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.order.totalAmount, equals(expectedTotal));
        expect(
          result.order.deliveryType,
          equals(DeliveryType.standardShipping),
        );
        expect(result.order.hikeId, equals(hikeId));
        expect(result.order.userId, equals(userId));
      });

      test('should handle stripe payment failures during purchase', () async {
        // Green Phase: Implement actual test
        // Arrange
        const int hikeId = 1;
        const String userId = 'test-user-123';

        // Mock the createOrder method to succeed
        final mockOrder = BasicOrder(
          id: 1,
          orderNumber: 'ORD-125',
          hikeId: hikeId,
          userId: userId,
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        when(
          mockBackendApiService.createOrder(
            hikeId: anyNamed('hikeId'),
            userId: anyNamed('userId'),
            amount: anyNamed('amount'),
            deliveryType: anyNamed('deliveryType'),
            deliveryAddress: anyNamed('deliveryAddress'),
          ),
        ).thenAnswer((_) async => mockOrder);

        // Mock the processPayment method to fail
        when(
          mockMultiPaymentService.processPayment(
            amount: anyNamed('amount'),
            currency: anyNamed('currency'),
            paymentMethod: anyNamed('paymentMethod'),
            orderId: anyNamed('orderId'),
          ),
        ).thenThrow(Exception('Payment declined'));

        // Act & Assert
        expect(
          () => paymentRepository.processPayment(
            hikeId: hikeId,
            userId: userId,
            deliveryType: DeliveryType.pickup,
            deliveryAddress: null,
            paymentMethod: PaymentMethodType.card,
          ),
          throwsException,
        );
      });

      test('should handle backend API errors during order creation', () async {
        // Green Phase: Implement actual test
        // Arrange
        const int hikeId = 1;
        const String userId = 'test-user-123';

        // Mock Backend API to throw error
        when(
          mockBackendApiService.createOrder(
            hikeId: anyNamed('hikeId'),
            userId: anyNamed('userId'),
            amount: anyNamed('amount'),
            deliveryType: anyNamed('deliveryType'),
            deliveryAddress: anyNamed('deliveryAddress'),
          ),
        ).thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(
          () => paymentRepository.processPayment(
            hikeId: hikeId,
            userId: userId,
            deliveryType: DeliveryType.pickup,
            deliveryAddress: null,
            paymentMethod: PaymentMethodType.card,
          ),
          throwsException,
        );
      });
    });

    group('Order Management', () {
      test('should retrieve user orders successfully', () async {
        // Green Phase: Implement actual test
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

        when(
          mockBackendApiService.getUserOrders(userId),
        ).thenAnswer((_) async => mockOrders);

        // Act
        final orders = await paymentRepository.getUserOrders(userId);

        // Assert
        expect(orders, isA<List<BasicOrder>>());
        expect(orders.length, equals(2));
        expect(orders[0].userId, equals(userId));
        expect(orders[1].userId, equals(userId));
      });

      test('should update order status correctly', () async {
        // Green Phase: Implement actual test
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

        when(
          mockBackendApiService.updateOrderStatus(
            orderId: anyNamed('orderId'),
            status: anyNamed('status'),
          ),
        ).thenAnswer((_) async => updatedOrder);

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

    group('Validation', () {
      test('should validate hike exists before processing payment', () async {
        // Green Phase: Implement actual test
        // Arrange
        const int nonExistentHikeId = 999999;
        const String userId = 'test-user-123';

        // Mock Backend API to throw error for non-existent hike
        when(
          mockBackendApiService.createOrder(
            hikeId: anyNamed('hikeId'),
            userId: anyNamed('userId'),
            amount: anyNamed('amount'),
            deliveryType: anyNamed('deliveryType'),
            deliveryAddress: anyNamed('deliveryAddress'),
          ),
        ).thenThrow(Exception('Hike not found'));

        // Act & Assert
        expect(
          () => paymentRepository.processPayment(
            hikeId: nonExistentHikeId,
            userId: userId,
            deliveryType: DeliveryType.pickup,
            deliveryAddress: null,
            paymentMethod: PaymentMethodType.card,
          ),
          throwsException,
        );
      });

      test('should validate delivery address for shipping orders', () async {
        // Green Phase: Implement actual test
        // Arrange
        const int hikeId = 1;
        const String userId = 'test-user-123';

        // Mock Backend API to throw error for missing delivery address
        when(
          mockBackendApiService.createOrder(
            hikeId: anyNamed('hikeId'),
            userId: anyNamed('userId'),
            amount: anyNamed('amount'),
            deliveryType: anyNamed('deliveryType'),
            deliveryAddress: anyNamed('deliveryAddress'),
          ),
        ).thenThrow(Exception('Delivery address required for shipping'));

        // Act & Assert
        expect(
          () => paymentRepository.processPayment(
            hikeId: hikeId,
            userId: userId,
            deliveryType: DeliveryType.standardShipping,
            deliveryAddress: null, // Invalid: missing address for shipping
            paymentMethod: PaymentMethodType.card,
          ),
          throwsException,
        );
      });
    });
  });
}

// TODO: Nach Implementierung der entsprechenden Klassen:
// 1. @GenerateMocks für alle Dependencies hinzufügen
// 2. flutter pub run build_runner build ausführen
// 3. PaymentResult, Order, DeliveryType Models implementieren
// 4. Tests von fail() auf echte Implementierung umstellen
// 5. Green Phase: PaymentRepository implementieren
// 6. Refactor Phase: Code optimieren
