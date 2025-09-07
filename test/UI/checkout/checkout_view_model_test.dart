import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:whisky_hikes/UI/mobile/checkout/checkout_view_model.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/basic_payment_result.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart' show PaymentMethodType;

import 'checkout_view_model_test.mocks.dart';

@GenerateMocks([PaymentRepository])

void main() {
  group('CheckoutViewModel Tests (TDD - Red Phase)', () {
    late CheckoutViewModel viewModel;
    late MockPaymentRepository mockPaymentRepository;
    late BasicOrder testOrder;

    setUp(() {
      mockPaymentRepository = MockPaymentRepository();
      testOrder = BasicOrder(
        id: 1,
        orderNumber: 'WH2025-TEST-001',
        hikeId: 1,
        userId: 'test-user',
        totalAmount: 30.99,
        deliveryType: DeliveryType.standardShipping,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      viewModel = CheckoutViewModel(
        paymentRepository: mockPaymentRepository,
        order: testOrder,
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initialization', () {
      test('should initialize with order data and default values', () {
        // Act & Assert
        expect(viewModel.order.orderNumber, equals('WH2025-TEST-001'));
        expect(viewModel.order.totalAmount, equals(30.99));
        expect(viewModel.order.deliveryType, equals(DeliveryType.standardShipping));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.selectedPaymentMethod, isNull);
        expect(viewModel.deliveryAddress, isNull);
        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.completedOrderId, isNull);
      });

      test('should correctly determine canProcessPayment state', () {
        // Act & Assert - Initially should be false (no payment method)
        expect(viewModel.canProcessPayment, isFalse);
        
        // Set payment method
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        expect(viewModel.canProcessPayment, isFalse); // Still false - shipping order needs address
        
        // Set delivery address
        viewModel.setDeliveryAddress({
          'street': 'Teststraße 123',
          'city': 'Hamburg',
          'postalCode': '20095',
          'country': 'Deutschland',
        });
        expect(viewModel.canProcessPayment, isTrue); // Now should be true
      });

      test('should handle pickup orders without address requirement', () {
        // Arrange - Create pickup order
        final pickupOrder = BasicOrder(
          id: 2,
          orderNumber: 'WH2025-PICKUP-001',
          hikeId: 1,
          userId: 'test-user',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final pickupViewModel = CheckoutViewModel(
          paymentRepository: mockPaymentRepository,
          order: pickupOrder,
        );

        // Act & Assert
        expect(pickupViewModel.canProcessPayment, isFalse); // No payment method yet
        pickupViewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        expect(pickupViewModel.canProcessPayment, isTrue); // Should be true - no address needed
        
        pickupViewModel.dispose();
      });
    });

    group('Payment Method Management', () {
      test('should set and update payment method', () {
        // Arrange
        expect(viewModel.selectedPaymentMethod, isNull);

        // Act
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');

        // Assert
        expect(viewModel.selectedPaymentMethod, equals(PaymentMethodType.card));
      });

      test('should notify listeners when payment method changes', () {
        // Arrange
        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_456');

        // Assert
        expect(notificationCount, equals(2));
      });

      test('should update canProcessPayment when payment method changes', () {
        // Arrange
        expect(viewModel.canProcessPayment, isFalse);

        // Act - Set payment method for shipping order (still needs address)
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');

        // Assert - Still false because shipping order needs address
        expect(viewModel.canProcessPayment, isFalse);

        // Act - Set address
        viewModel.setDeliveryAddress({
          'street': 'Test Street 123',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });

        // Assert - Now should be true
        expect(viewModel.canProcessPayment, isTrue);
      });
    });

    group('Address Management', () {
      test('should update delivery address and store fields', () {
        // Act
        viewModel.setDeliveryAddress({
          'street': 'Teststraße 123',
          'city': 'Hamburg',
          'postalCode': '20095',
          'country': 'Deutschland'
        });

        // Assert
        expect(viewModel.deliveryAddress?['street'], equals('Teststraße 123'));
        expect(viewModel.deliveryAddress?['city'], equals('Hamburg'));
        expect(viewModel.deliveryAddress?['postalCode'], equals('20095'));
        expect(viewModel.deliveryAddress?['country'], equals('Deutschland'));
      });

      test('should update individual address fields', () {
        // Act
        viewModel.updateAddressField('street', 'Updated Street 456');
        viewModel.updateAddressField('city', 'Berlin');
        viewModel.updateAddressField('postalCode', '10115');

        // Assert
        expect(viewModel.deliveryAddress?['street'], equals('Updated Street 456'));
        expect(viewModel.deliveryAddress?['city'], equals('Berlin'));
        expect(viewModel.deliveryAddress?['postalCode'], equals('10115'));
      });

      test('should validate address fields correctly', () {
        // Test empty field validation
        expect(viewModel.validateAddressField('street', ''), isNotNull);
        expect(viewModel.validateAddressField('city', ''), isNotNull);
        expect(viewModel.validateAddressField('postalCode', ''), isNotNull);

        // Test valid fields
        expect(viewModel.validateAddressField('street', 'Valid Street 123'), isNull);
        expect(viewModel.validateAddressField('city', 'Valid City'), isNull);
        expect(viewModel.validateAddressField('postalCode', '12345'), isNull);

        // Test invalid postal code
        expect(viewModel.validateAddressField('postalCode', '123'), isNotNull);
        expect(viewModel.validateAddressField('postalCode', 'abcde'), isNotNull);

        // Test short street name
        expect(viewModel.validateAddressField('street', 'St'), isNotNull);
        expect(viewModel.validateAddressField('city', 'A'), isNotNull);
      });

      test('should notify listeners when address changes', () {
        // Arrange
        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        viewModel.setDeliveryAddress({'street': 'Test Street'});
        viewModel.updateAddressField('city', 'Test City');

        // Assert
        expect(notificationCount, equals(2));
      });
    });

    group('Payment Processing', () {
      test('should process payment successfully with valid data', () async {
        // Arrange
        final successfulResult = BasicPaymentResult(
          isSuccess: true,
          status: PaymentStatus.succeeded,
          paymentIntentId: 'pi_test_123',
          clientSecret: 'pi_test_123_secret_abc',
        );

        when(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: anyNamed('paymentMethod'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => successfulResult);

        // Setup valid state
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        viewModel.setDeliveryAddress({
          'street': 'Test Street 123',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });

        // Act
        await viewModel.processPayment();

        // Assert
        expect(viewModel.paymentSuccess, isTrue);
        expect(viewModel.completedOrderId, equals(1));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);

        // Verify repository was called
        verify(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: PaymentMethodType.card,
          paymentMethodId: 'pm_test_card_123',
          metadata: anyNamed('metadata'),
        )).called(1);
      });

      test('should handle payment failures with friendly error message', () async {
        // Arrange
        final failedResult = BasicPaymentResult.failure(
          error: 'Your card was declined',
          status: PaymentStatus.failed,
        );

        when(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: anyNamed('paymentMethod'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => failedResult);

        // Setup valid state
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_declined');
        viewModel.setDeliveryAddress({
          'street': 'Test Street 123',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });

        // Act
        await viewModel.processPayment();

        // Assert
        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, contains('Karte wurde abgelehnt'));
      });

      test('should handle 3D Secure authentication required', () async {
        // Arrange
        final authRequiredResult = BasicPaymentResult.requiresAction(
          clientSecret: 'pi_test_auth_secret_abc',
          paymentIntentId: 'pi_test_auth',
        );

        when(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: anyNamed('paymentMethod'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => authRequiredResult);

        // Setup valid state
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_auth');
        viewModel.setDeliveryAddress({
          'street': 'Test Street 123',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });

        // Act
        await viewModel.processPayment();

        // Assert
        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, contains('Zusätzliche Authentifizierung erforderlich'));
      });

      test('should show loading state during payment processing', () async {
        // Arrange
        final successfulResult = BasicPaymentResult(
          isSuccess: true,
          status: PaymentStatus.succeeded,
          paymentIntentId: 'pi_test_123',
        );

        when(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: anyNamed('paymentMethod'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => successfulResult,
        ));

        // Setup valid state
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        viewModel.setDeliveryAddress({
          'street': 'Test Street 123',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });

        // Act
        final paymentFuture = viewModel.processPayment();
        
        // Assert - during processing
        expect(viewModel.isLoading, isTrue);

        // Wait for completion
        await paymentFuture;

        // Assert - after processing
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.paymentSuccess, isTrue);
      });

      test('should not process payment when form is invalid', () async {
        // Arrange - No payment method set
        expect(viewModel.canProcessPayment, isFalse);

        // Act
        await viewModel.processPayment();

        // Assert
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.errorMessage, contains('Bitte füllen Sie alle erforderlichen Felder aus'));
        expect(viewModel.paymentSuccess, isFalse);

        // Verify repository was not called
        verifyNever(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: anyNamed('paymentMethod'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        ));
      });

      test('should handle repository exceptions gracefully', () async {
        // Arrange
        when(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: anyNamed('paymentMethod'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenThrow(Exception('Network error'));

        // Setup valid state
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        viewModel.setDeliveryAddress({
          'street': 'Test Street 123',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });

        // Act
        await viewModel.processPayment();

        // Assert
        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, contains('Ein unerwarteter Fehler ist aufgetreten'));
      });
    });

    group('Error Management', () {
      test('should clear errors when requested', () {
        // Arrange - Set error state
        viewModel.processPayment(); // Will trigger error due to invalid form
        expect(viewModel.errorMessage, isNotNull);

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.errorMessage, isNull);
      });

      test('should notify listeners when error is cleared', () {
        // Arrange - Set error and add listener
        viewModel.processPayment(); // Will trigger error
        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        viewModel.clearError();

        // Assert
        expect(notificationCount, equals(1));
      });
    });

    group('State Management', () {
      test('should reset all state correctly', () {
        // Arrange - Set various state
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        viewModel.setDeliveryAddress({
          'street': 'Test Street',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });
        viewModel.processPayment(); // May set error

        // Act
        viewModel.reset();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.selectedPaymentMethod, isNull);
        expect(viewModel.deliveryAddress, isNull);
        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.completedOrderId, isNull);
      });

      test('should notify listeners when state is reset', () {
        // Arrange
        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        viewModel.reset();

        // Assert
        expect(notificationCount, equals(1));
      });

      test('should maintain order reference after reset', () {
        // Act
        viewModel.reset();

        // Assert - Order should remain unchanged
        expect(viewModel.order.orderNumber, equals('WH2025-TEST-001'));
        expect(viewModel.order.totalAmount, equals(30.99));
      });
    });

    group('Edge Cases', () {
      test('should handle null/empty payment method gracefully', () {
        // Act & Assert
        viewModel.setPaymentMethod(PaymentMethodType.card, '');
        expect(viewModel.canProcessPayment, isFalse);
        
        viewModel.setPaymentMethod(PaymentMethodType.card, 'valid_method');
        expect(viewModel.selectedPaymentMethod, equals(PaymentMethodType.card));
      });

      test('should handle partial address data correctly', () {
        // Act
        viewModel.setDeliveryAddress({'street': 'Partial Street'});

        // Assert - Should not be valid for processing (missing required fields)
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card');
        expect(viewModel.canProcessPayment, isFalse);
      });

      test('should handle concurrent payment processing attempts', () async {
        // Arrange
        final delayedResult = BasicPaymentResult(
          isSuccess: true,
          status: PaymentStatus.succeeded,
          paymentIntentId: 'pi_test_123',
        );

        when(mockPaymentRepository.processPayment(
          order: anyNamed('order'),
          paymentMethod: anyNamed('paymentMethod'),
          paymentMethodId: anyNamed('paymentMethodId'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => delayedResult,
        ));

        // Setup valid state
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_card_123');
        viewModel.setDeliveryAddress({
          'street': 'Test Street 123',
          'city': 'Test City',
          'postalCode': '12345',
          'country': 'Deutschland',
        });

        // Act - Start two concurrent payment processes
        final future1 = viewModel.processPayment();
        final future2 = viewModel.processPayment();

        await Future.wait([future1, future2]);

        // Assert - Should handle gracefully (second call should be ignored due to loading state)
        expect(viewModel.paymentSuccess, isTrue);
        expect(viewModel.isLoading, isFalse);
      });
    });
  });
}

// GREEN PHASE COMPLETE: Comprehensive CheckoutViewModel state tests
// ✅ All ViewModel functionality implemented and tested
// 🎯 Test Coverage: Initialization, payment methods, address management, 
//    payment processing, validation, error handling, state management, edge cases
// 
// Test Areas Covered:
// - Initialization and default values
// - Payment method selection and validation
// - Delivery address management for shipping orders
// - Comprehensive payment processing (success, failure, 3D Secure, loading states)
// - Form validation logic for pickup vs shipping orders
// - Error management and recovery
// - State management (reset, notifications)
// - Edge cases and concurrent operations
//
// Total: 20+ comprehensive tests covering all ViewModel state scenarios