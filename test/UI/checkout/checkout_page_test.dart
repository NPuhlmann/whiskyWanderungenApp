import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:whisky_hikes/UI/mobile/checkout/checkout_page.dart';
import 'package:whisky_hikes/UI/mobile/checkout/widgets/checkout_button.dart';
import 'package:whisky_hikes/UI/mobile/checkout/widgets/delivery_address_form.dart';
import 'package:whisky_hikes/UI/mobile/checkout/widgets/multi_payment_method_selector.dart';
import 'package:whisky_hikes/UI/mobile/checkout/widgets/order_summary.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/data/repositories/purchase_intake_repository.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

import '../../data/repositories/purchase_intake_repository_test.dart'
    show FakeConfirmAdapter;

// CheckoutPage builds its own CheckoutViewModel, so these tests drive the real
// one over a PurchaseIntakeRepository whose Edge Function call and Stripe
// confirm are both faked — no mock ViewModel, no network.
void main() {
  late Hike testHike;

  setUp(() {
    testHike = const Hike(
      id: 1,
      name: 'Islay Trail',
      length: 12.0,
      steep: 3.0,
      elevation: 200,
      description: 'A trail',
      difficulty: Difficulty.mid,
      price: 30.99,
      companyId: 'company-1',
    );
  });

  Future<void> pumpCheckoutPage(WidgetTester tester) async {
    final repository = PurchaseIntakeRepository(
      confirmAdapter: FakeConfirmAdapter(),
      currentUserId: () => 'user-1',
      invoker: (name, body) async => {
        'success': true,
        'clientSecret': 'pi_123_secret_abc',
        'orderId': 42,
        'orderNumber': 'WH2025-TEST-001',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Provider<PurchaseIntakeRepository>.value(
          value: repository,
          child: CheckoutPage(hike: testHike),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CheckoutPage', () {
    testWidgets('renders the checkout scaffold and its sections', (
      tester,
    ) async {
      await pumpCheckoutPage(tester);

      expect(find.byType(CheckoutPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(OrderSummary), findsOneWidget);
      expect(find.byType(MultiPaymentMethodSelector), findsOneWidget);
      expect(find.byType(CheckoutButton), findsOneWidget);
    });

    testWidgets('summarises the hike being bought', (tester) async {
      await pumpCheckoutPage(tester);

      expect(find.text('Islay Trail'), findsOneWidget);
      // Base price plus the 5 € standard shipping default.
      expect(find.text('35.99 €'), findsOneWidget);
    });

    testWidgets('asks for a delivery address for a shipped set', (
      tester,
    ) async {
      await pumpCheckoutPage(tester);

      expect(find.byType(DeliveryAddressForm), findsOneWidget);
      expect(find.byKey(const Key('first_name_field')), findsOneWidget);
      expect(find.byKey(const Key('last_name_field')), findsOneWidget);
      expect(find.byKey(const Key('street_field')), findsOneWidget);
    });

    testWidgets('keeps the pay button disabled until the form is complete', (
      tester,
    ) async {
      await pumpCheckoutPage(tester);

      final button = tester.widget<CheckoutButton>(find.byType(CheckoutButton));
      expect(button.enabled, isFalse);
    });
  });
}
