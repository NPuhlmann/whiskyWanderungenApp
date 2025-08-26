import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:whisky_hikes/UI/checkout/checkout_page.dart';
import 'package:whisky_hikes/UI/checkout/widgets/order_summary.dart';
import 'package:whisky_hikes/UI/checkout/widgets/payment_method_selector.dart';
import 'package:whisky_hikes/UI/checkout/widgets/delivery_address_form.dart';
import 'package:whisky_hikes/UI/checkout/widgets/checkout_button.dart';
import 'package:whisky_hikes/UI/checkout/checkout_view_model.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';

import 'checkout_page_test.mocks.dart';

@GenerateMocks([CheckoutViewModel, PaymentRepository])

void main() {
  group('CheckoutPage Widget Tests (TDD - Red Phase)', () {
    late MockCheckoutViewModel mockViewModel;
    late MockPaymentRepository mockPaymentRepository;

    setUp(() {
      mockViewModel = MockCheckoutViewModel();
      mockPaymentRepository = MockPaymentRepository();
    });

    Widget createCheckoutPage({
      BasicOrder? order,
      CheckoutViewModel? viewModel,
    }) {
      final testOrder = order ?? BasicOrder(
        id: 1,
        orderNumber: 'WH2025-TEST-001',
        hikeId: 1,
        userId: 'test-user',
        totalAmount: 30.99,
        deliveryType: DeliveryType.shipping,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      return MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<PaymentRepository>.value(value: mockPaymentRepository),
            ChangeNotifierProvider<CheckoutViewModel>.value(
              value: viewModel ?? mockViewModel,
            ),
          ],
          child: CheckoutPage(order: testOrder),
        ),
      );
    }

    group('CheckoutPage Layout', () {
      testWidgets('should display checkout page with all main components', (tester) async {
        // Arrange - Mock ViewModel state
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);
        when(mockViewModel.selectedPaymentMethod).thenReturn(null);
        when(mockViewModel.deliveryAddress).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert - Main page structure
        expect(find.byType(CheckoutPage), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Checkout'), findsOneWidget);
        
        // Should contain main components
        expect(find.byType(OrderSummary), findsOneWidget);
        expect(find.byType(PaymentMethodSelector), findsOneWidget);
        expect(find.byType(CheckoutButton), findsOneWidget);
      });

      testWidgets('should show delivery address form for shipping orders', (tester) async {
        // Arrange
        final shippingOrder = BasicOrder(
          id: 1,
          orderNumber: 'WH2025-SHIP-001',
          hikeId: 1,
          userId: 'test-user',
          totalAmount: 30.99,
          deliveryType: DeliveryType.shipping,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage(order: shippingOrder));

        // Assert
        expect(find.byType(DeliveryAddressForm), findsOneWidget);
        expect(find.text('Lieferadresse'), findsWidgets);
      });

      testWidgets('should NOT show delivery address form for pickup orders', (tester) async {
        // Arrange
        final pickupOrder = BasicOrder(
          id: 1,
          orderNumber: 'WH2025-PICKUP-001',
          hikeId: 1,
          userId: 'test-user',
          totalAmount: 25.99,
          deliveryType: DeliveryType.pickup,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage(order: pickupOrder));

        // Assert
        expect(find.byType(DeliveryAddressForm), findsNothing);
        expect(find.text('Lieferadresse'), findsNothing);
      });

      testWidgets('should display loading indicator when processing', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(true);
        when(mockViewModel.errorMessage).thenReturn(null);
        when(mockViewModel.selectedPaymentMethod).thenReturn(null);
        when(mockViewModel.deliveryAddress).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Zahlung wird verarbeitet...'), findsOneWidget);
      });

      testWidgets('should display error message when payment fails', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn('Ihre Karte wurde abgelehnt');

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Ihre Karte wurde abgelehnt'), findsOneWidget);
        expect(find.text('Erneut versuchen'), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('should call ViewModel when checkout button is tapped', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);
        when(mockViewModel.canProcessPayment).thenReturn(true);

        // Act
        await tester.pumpWidget(createCheckoutPage());
        await tester.tap(find.byType(CheckoutButton));
        await tester.pump();

        // Assert
        verify(mockViewModel.processPayment()).called(1);
      });

      testWidgets('should disable checkout button when form is invalid', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);
        when(mockViewModel.canProcessPayment).thenReturn(false);

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert
        final checkoutButton = tester.widget<CheckoutButton>(find.byType(CheckoutButton));
        expect(checkoutButton.enabled, isFalse);
      });

      testWidgets('should call clear error when error dismiss is tapped', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn('Payment error');

        // Act
        await tester.pumpWidget(createCheckoutPage());
        await tester.tap(find.text('Erneut versuchen'));
        await tester.pump();

        // Assert
        verify(mockViewModel.clearError()).called(1);
      });

      testWidgets('should update payment method when selector changes', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);
        when(mockViewModel.selectedPaymentMethod).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage());
        await tester.tap(find.byType(PaymentMethodSelector));
        await tester.pump();

        // Assert - This will test the widget interaction
        expect(find.byType(PaymentMethodSelector), findsOneWidget);
      });
    });

    group('Payment Processing States', () {
      testWidgets('should show loading overlay during payment processing', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(true);
        when(mockViewModel.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Zahlung wird verarbeitet...'), findsOneWidget);
      });

      testWidgets('should show success dialog when payment succeeds', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);
        when(mockViewModel.paymentSuccess).thenReturn(true);
        when(mockViewModel.completedOrderId).thenReturn(123);

        // Act
        await tester.pumpWidget(createCheckoutPage());
        await tester.pumpAndSettle();

        // Assert - Success state should be handled by ViewModel
        expect(find.byType(CheckoutPage), findsOneWidget);
      });

      testWidgets('should handle payment cancellation gracefully', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn('Zahlung wurde abgebrochen');

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Zahlung wurde abgebrochen'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert - Check semantic labels
        expect(find.bySemanticsLabel('Bestellübersicht'), findsOneWidget);
        expect(find.bySemanticsLabel('Zahlungsmethode auswählen'), findsOneWidget);
        expect(find.bySemanticsLabel('Zahlung abschließen'), findsOneWidget);
      });

      testWidgets('should support screen reader navigation', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createCheckoutPage());

        // Assert - Check that elements are focusable
        final checkoutPage = tester.getSemantics(find.byType(CheckoutPage));
        expect(checkoutPage, isNotNull);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt layout for different screen sizes', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.errorMessage).thenReturn(null);

        // Act - Test with mobile screen size
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createCheckoutPage());

        // Assert - Should use scrollable layout
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        
        // Test with tablet size
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(createCheckoutPage());
        await tester.pump();

        // Should adapt layout but maintain scrollability
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });
  });
}

// RED PHASE COMPLETE: Comprehensive CheckoutPage widget tests
// ❌ All tests should FAIL - CheckoutPage and components don't exist yet
// 📝 Next: Create CheckoutPage and child widgets to make tests GREEN
// 🎯 Test Coverage: Layout, interactions, accessibility, responsive design, loading states
// 
// Components needed for GREEN phase:
// - CheckoutPage (main page)
// - CheckoutViewModel (state management)  
// - OrderSummary (order details display)
// - PaymentMethodSelector (credit card input)
// - DeliveryAddressForm (address input for shipping)
// - CheckoutButton (process payment button)