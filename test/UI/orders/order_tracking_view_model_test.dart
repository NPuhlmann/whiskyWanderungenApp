import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/UI/orders/order_tracking_view_model.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

import 'order_tracking_view_model_test.mocks.dart';

@GenerateMocks([PaymentRepository])
void main() {
  group('OrderTrackingViewModel', () {
    late MockPaymentRepository mockPaymentRepository;
    late OrderTrackingViewModel viewModel;
    
    const orderId = 123;
    
    final testOrder = BasicOrder(
      id: orderId,
      orderNumber: 'WH2024-12345',
      hikeId: 1,
      userId: 'test-user-id',
      totalAmount: 49.99,
      deliveryType: DeliveryType.shipping,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockPaymentRepository = MockPaymentRepository();
      viewModel = OrderTrackingViewModel(
        orderId: orderId,
        useEnhancedOrder: false,
        paymentRepository: mockPaymentRepository,
      );
    });

    group('initialization', () {
      test('should start with loading state', () {
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.error, isNull);
        expect(viewModel.order, isNull);
      });

      test('should load order successfully', () async {
        // Arrange
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder);

        // Act
        await viewModel.initialize();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
        expect(viewModel.order, equals(testOrder));
        verify(mockPaymentRepository.getOrderById(orderId)).called(1);
      });

      test('should handle loading error', () async {
        // Arrange
        const errorMessage = 'Network error';
        when(mockPaymentRepository.getOrderById(orderId))
            .thenThrow(Exception(errorMessage));

        // Act
        await viewModel.initialize();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, contains(errorMessage));
        expect(viewModel.order, isNull);
      });
    });

    group('retry functionality', () {
      test('should retry loading after error', () async {
        // Arrange - first call fails, second succeeds
        when(mockPaymentRepository.getOrderById(orderId))
            .thenThrow(Exception('First error'))
            .thenAnswer((_) async => testOrder);

        // Act - first attempt fails
        await viewModel.initialize();
        expect(viewModel.error, isNotNull);

        // Act - retry succeeds
        await viewModel.retry();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
        expect(viewModel.order, equals(testOrder));
        verify(mockPaymentRepository.getOrderById(orderId)).called(2);
      });
    });

    group('order cancellation', () {
      test('should cancel order successfully', () async {
        // Arrange
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder);
        when(mockPaymentRepository.updateOrderStatus(
          orderId: orderId,
          status: OrderStatus.cancelled,
        )).thenAnswer((_) async => testOrder.copyWith(status: OrderStatus.cancelled));

        await viewModel.initialize();

        // Act
        await viewModel.cancelOrder();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
        verify(mockPaymentRepository.updateOrderStatus(
          orderId: orderId,
          status: OrderStatus.cancelled,
        )).called(1);
      });

      test('should handle cancellation error', () async {
        // Arrange
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder);
        when(mockPaymentRepository.updateOrderStatus(
          orderId: orderId,
          status: OrderStatus.cancelled,
        )).thenThrow(Exception('Cancellation failed'));

        await viewModel.initialize();

        // Act
        await viewModel.cancelOrder();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, contains('Stornieren'));
      });

      test('should not cancel order that cannot be cancelled', () async {
        // Arrange
        final deliveredOrder = testOrder.copyWith(status: OrderStatus.delivered);
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => deliveredOrder);

        await viewModel.initialize();

        // Act
        await viewModel.cancelOrder();

        // Assert
        expect(viewModel.error, contains('kann nicht mehr storniert werden'));
        verifyNever(mockPaymentRepository.updateOrderStatus(
          orderId: anyNamed('orderId'),
          status: anyNamed('status'),
        ));
      });
    });

    group('status updates', () {
      test('should update order status successfully', () async {
        // Arrange
        const newStatus = OrderStatus.shipped;
        final updatedOrder = testOrder.copyWith(status: newStatus);
        
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder)
            .thenAnswer((_) async => updatedOrder);
        when(mockPaymentRepository.updateOrderStatus(
          orderId: orderId,
          status: newStatus,
        )).thenAnswer((_) async => updatedOrder);

        await viewModel.initialize();

        // Act
        await viewModel.updateOrderStatus(newStatus);

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
        expect(viewModel.order?.status, equals(newStatus));
        verify(mockPaymentRepository.updateOrderStatus(
          orderId: orderId,
          status: newStatus,
        )).called(1);
      });
    });

    group('business logic properties', () {
      test('should determine if order can be cancelled', () async {
        // Arrange - pending order can be cancelled
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder.copyWith(status: OrderStatus.pending));
        
        await viewModel.initialize();
        
        // Assert
        expect(viewModel.canCancelOrder, isTrue);
      });

      test('should determine if order can be tracked', () async {
        // Arrange - shipped order with tracking number can be tracked
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder.copyWith(
              status: OrderStatus.shipped,
              trackingNumber: 'TN123456789',
            ));
        
        await viewModel.initialize();
        
        // Assert
        expect(viewModel.canTrackOrder, isTrue);
      });

      test('should provide estimated delivery date', () async {
        // Arrange
        final estimatedDelivery = DateTime.now().add(const Duration(days: 3));
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder.copyWith(
              estimatedDelivery: estimatedDelivery,
            ));
        
        await viewModel.initialize();
        
        // Assert
        expect(viewModel.estimatedDelivery, equals(estimatedDelivery));
      });

      test('should provide tracking number', () async {
        // Arrange
        const trackingNumber = 'TN123456789';
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder.copyWith(
              trackingNumber: trackingNumber,
            ));
        
        await viewModel.initialize();
        
        // Assert
        expect(viewModel.trackingNumber, equals(trackingNumber));
      });
    });

    group('status history', () {
      test('should provide order status history for basic orders', () async {
        // Arrange
        when(mockPaymentRepository.getOrderById(orderId))
            .thenAnswer((_) async => testOrder);
        
        await viewModel.initialize();
        
        // Act
        final history = viewModel.getOrderStatusHistory();
        
        // Assert
        expect(history, isNotEmpty);
        expect(history.first.toStatus.name, equals('confirmed'));
      });
    });

    tearDown(() {
      viewModel.dispose();
    });
  });
}