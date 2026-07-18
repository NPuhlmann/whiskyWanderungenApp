import 'package:flutter_test/flutter_test.dart';

import 'package:whisky_hikes/UI/mobile/checkout/checkout_view_model.dart';
import 'package:whisky_hikes/data/repositories/purchase_intake_repository.dart';
import 'package:whisky_hikes/data/services/payment/stripe_confirm_adapter.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart'
    show PaymentMethodType;

import '../../data/repositories/purchase_intake_repository_test.dart'
    show FakeConfirmAdapter;

const _validAddress = {
  'firstName': 'Nico',
  'lastName': 'Puhlmann',
  'street': 'Musterstraße 12',
  'city': 'Berlin',
  'postalCode': '10115',
  'country': 'Deutschland',
};

Hike _testHike({String? companyId = 'company-1'}) => Hike(
  id: 1,
  name: 'Islay Trail',
  length: 12.0,
  steep: 3.0,
  elevation: 200,
  description: 'A trail',
  difficulty: Difficulty.mid,
  price: 30.99,
  companyId: companyId,
);

void main() {
  group('CheckoutViewModel', () {
    late CheckoutViewModel viewModel;
    late FakeConfirmAdapter confirmAdapter;
    late Hike testHike;
    late int invokeCount;

    /// Builds the ViewModel over a real repository whose Edge Function call
    /// and Stripe confirm are both faked — no Supabase, no network.
    CheckoutViewModel buildViewModel({
      Hike? hike,
      Map<String, dynamic>? response,
      String? userId = 'user-1',
      Object? throws,
    }) {
      final repository = PurchaseIntakeRepository(
        confirmAdapter: confirmAdapter,
        currentUserId: () => userId,
        invoker: (name, body) async {
          invokeCount++;
          if (throws != null) throw throws;
          return response ??
              {
                'success': true,
                'clientSecret': 'pi_123_secret_abc',
                'paymentIntentId': 'pi_123',
                'orderId': 42,
                'orderNumber': 'WH2025-TEST-001',
              };
        },
      );
      return CheckoutViewModel(
        purchaseIntakeRepository: repository,
        hike: hike ?? testHike,
      );
    }

    /// Fills in everything [CheckoutViewModel.canProcessPayment] demands.
    void completeForm(CheckoutViewModel vm) {
      vm.setPaymentMethod(PaymentMethodType.card, 'pm_test_123');
      vm.setDeliveryAddress(Map<String, dynamic>.from(_validAddress));
    }

    setUp(() {
      invokeCount = 0;
      confirmAdapter = FakeConfirmAdapter();
      testHike = _testHike();
      viewModel = buildViewModel();
    });

    tearDown(() => viewModel.dispose());

    group('Initialization', () {
      test('starts from the hike with empty payment state', () {
        expect(viewModel.hike.name, equals('Islay Trail'));
        expect(viewModel.hike.price, equals(30.99));
        expect(viewModel.deliveryType, equals(DeliveryType.standardShipping));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.selectedPaymentMethod, isNull);
        expect(viewModel.deliveryAddress, isNull);
        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.completedOrderId, isNull);
      });

      test('requires a delivery address for a shipped tasting set', () {
        expect(viewModel.requiresDeliveryAddress, isTrue);
      });
    });

    group('canProcessPayment', () {
      test('is false until a payment method and address are supplied', () {
        expect(viewModel.canProcessPayment, isFalse);

        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_123');
        expect(viewModel.canProcessPayment, isFalse);

        viewModel.setDeliveryAddress(Map<String, dynamic>.from(_validAddress));
        expect(viewModel.canProcessPayment, isTrue);
      });

      test('is false for a card without a payment method id', () {
        viewModel.setPaymentMethod(PaymentMethodType.card, null);
        viewModel.setDeliveryAddress(Map<String, dynamic>.from(_validAddress));

        expect(viewModel.canProcessPayment, isFalse);
      });

      test('is false when the recipient name is missing', () {
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_123');
        final address = Map<String, dynamic>.from(_validAddress)
          ..remove('firstName');
        viewModel.setDeliveryAddress(address);

        expect(viewModel.canProcessPayment, isFalse);
      });
    });

    group('Payment method and address', () {
      test('stores the selected payment method', () {
        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_123');

        expect(viewModel.selectedPaymentMethod, PaymentMethodType.card);
        expect(viewModel.selectedPaymentMethodId, 'pm_test_123');
      });

      test('notifies listeners when the payment method changes', () {
        var notified = 0;
        viewModel.addListener(() => notified++);

        viewModel.setPaymentMethod(PaymentMethodType.card, 'pm_test_123');

        expect(notified, 1);
      });

      test('updates individual address fields', () {
        viewModel.updateAddressField('city', 'Hamburg');
        viewModel.updateAddressField('postalCode', '20095');

        expect(viewModel.deliveryAddress!['city'], 'Hamburg');
        expect(viewModel.deliveryAddress!['postalCode'], '20095');
      });

      test('validates address fields', () {
        expect(viewModel.validateAddressField('street', ''), isNotNull);
        expect(viewModel.validateAddressField('street', 'ab'), isNotNull);
        expect(
          viewModel.validateAddressField('street', 'Musterstraße 12'),
          isNull,
        );

        expect(viewModel.validateAddressField('postalCode', '123'), isNotNull);
        expect(viewModel.validateAddressField('postalCode', '10115'), isNull);

        expect(viewModel.validateAddressField('firstName', ''), isNotNull);
        expect(viewModel.validateAddressField('firstName', 'Nico'), isNull);
      });
    });

    group('processPayment', () {
      test('completes the purchase and records the created order', () async {
        completeForm(viewModel);

        await viewModel.processPayment();

        expect(viewModel.paymentSuccess, isTrue);
        expect(viewModel.completedOrderId, 42);
        expect(viewModel.completedOrderNumber, 'WH2025-TEST-001');
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.isLoading, isFalse);
        expect(confirmAdapter.seenClientSecret, 'pi_123_secret_abc');
      });

      test('reports a declined card without marking success', () async {
        confirmAdapter.result = const ConfirmResult(
          isSuccess: false,
          errorMessage: 'Ihre Karte wurde abgelehnt',
        );
        completeForm(viewModel);

        await viewModel.processPayment();

        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.errorMessage, contains('abgelehnt'));
        expect(viewModel.isLoading, isFalse);
      });

      test('reports a cancelled payment', () async {
        confirmAdapter.result = const ConfirmResult(
          isSuccess: false,
          wasCancelled: true,
        );
        completeForm(viewModel);

        await viewModel.processPayment();

        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.errorMessage, contains('abgebrochen'));
      });

      test('reports when 3D Secure is required', () async {
        confirmAdapter.result = const ConfirmResult(
          isSuccess: false,
          requiresAction: true,
        );
        completeForm(viewModel);

        await viewModel.processPayment();

        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.errorMessage, contains('Authentifizierung'));
      });

      test('refuses to pay a hike with no company', () async {
        viewModel.dispose();
        viewModel = buildViewModel(hike: _testHike(companyId: null));
        completeForm(viewModel);

        await viewModel.processPayment();

        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.errorMessage, isNotNull);
        // Never reached the Edge Function.
        expect(invokeCount, 0);
      });

      test('does nothing while the form is incomplete', () async {
        await viewModel.processPayment();

        expect(invokeCount, 0);
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.paymentSuccess, isFalse);
      });

      test('survives a thrown error from the backend', () async {
        viewModel.dispose();
        viewModel = buildViewModel(throws: Exception('network down'));
        completeForm(viewModel);

        await viewModel.processPayment();

        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.isLoading, isFalse);
      });

      test('shows a loading state while the payment is in flight', () async {
        completeForm(viewModel);

        final pending = viewModel.processPayment();
        expect(viewModel.isLoading, isTrue);

        await pending;
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('Error and state management', () {
      test('clears the error message', () async {
        await viewModel.processPayment(); // fails validation
        expect(viewModel.errorMessage, isNotNull);

        viewModel.clearError();

        expect(viewModel.errorMessage, isNull);
      });

      test('resets payment state but keeps the hike', () {
        completeForm(viewModel);

        viewModel.reset();

        expect(viewModel.selectedPaymentMethod, isNull);
        expect(viewModel.deliveryAddress, isNull);
        expect(viewModel.paymentSuccess, isFalse);
        expect(viewModel.completedOrderId, isNull);
        expect(viewModel.hike.id, 1);
      });
    });
  });
}
