import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/repositories/purchase_intake_repository.dart';
import 'package:whisky_hikes/data/services/payment/stripe_confirm_adapter.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/payment_intent.dart';

/// In-memory [StripeConfirmAdapter] — the second implementation that
/// justifies the seam.
class FakeConfirmAdapter implements StripeConfirmAdapter {
  ConfirmResult result;
  String? seenClientSecret;

  FakeConfirmAdapter({
    this.result = const ConfirmResult(
      isSuccess: true,
      paymentIntentId: 'pi_fake',
    ),
  });

  @override
  Future<ConfirmResult> confirm({
    required String clientSecret,
    String? paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    seenClientSecret = clientSecret;
    return result;
  }
}

Hike testHike({String? companyId = 'company-1', double price = 45.0}) => Hike(
  id: 7,
  name: 'Islay Trail',
  length: 12.0,
  steep: 3.0,
  elevation: 200,
  description: 'A trail',
  difficulty: Difficulty.mid,
  price: price,
  companyId: companyId,
);

const address = {
  'firstName': 'Nico',
  'lastName': 'Puhlmann',
  'street': 'Hauptstraße 1',
  'city': 'Berlin',
  'postalCode': '10115',
  'country': 'Deutschland',
};

void main() {
  group('buildPaymentIntentBody', () {
    test('maps DeliveryType to Edge Function wire strings', () {
      String wireFor(DeliveryType type) =>
          buildPaymentIntentBody(
                hike: testHike(),
                userId: 'user-1',
                deliveryType: type,
                deliveryAddress: type == DeliveryType.pickup ? null : address,
              )['deliveryType']
              as String;

      expect(wireFor(DeliveryType.pickup), 'pickup');
      expect(wireFor(DeliveryType.standardShipping), 'standard_shipping');
      expect(wireFor(DeliveryType.expressShipping), 'express_shipping');
    });

    test('maps hike and shipping cost onto the wire params', () {
      final body = buildPaymentIntentBody(
        hike: testHike(price: 45.0),
        userId: 'user-1',
        deliveryType: DeliveryType.expressShipping,
        deliveryAddress: address,
      );

      expect(body['companyId'], 'company-1');
      expect(body['hikeId'], 7);
      expect(body['userId'], 'user-1');
      expect(body['orderValue'], 45.0);
      expect(body['shippingCost'], 10.0);
    });

    test('pickup carries no address and no shipping cost', () {
      final body = buildPaymentIntentBody(
        hike: testHike(),
        userId: 'user-1',
        deliveryType: DeliveryType.pickup,
        deliveryAddress: address,
      );

      expect(body.containsKey('deliveryAddress'), isFalse);
      expect(body['shippingCost'], 0.0);
    });

    test('translates the address form fields to Edge Function fields', () {
      final body = buildPaymentIntentBody(
        hike: testHike(),
        userId: 'user-1',
        deliveryType: DeliveryType.standardShipping,
        deliveryAddress: address,
      );

      final wire = body['deliveryAddress'] as Map<String, dynamic>;
      expect(wire['firstName'], 'Nico');
      expect(wire['lastName'], 'Puhlmann');
      expect(wire['addressLine1'], 'Hauptstraße 1');
      expect(wire['city'], 'Berlin');
      expect(wire['postalCode'], '10115');
      expect(wire['countryCode'], 'DE');
    });

    test('accepts an ISO country code as-is', () {
      final body = buildPaymentIntentBody(
        hike: testHike(),
        userId: 'user-1',
        deliveryType: DeliveryType.standardShipping,
        deliveryAddress: {...address, 'country': 'AT'},
      );

      expect((body['deliveryAddress'] as Map)['countryCode'], 'AT');
    });
  });

  group('intakePurchase', () {
    PurchaseIntakeRepository build({
      required FakeConfirmAdapter adapter,
      Map<String, dynamic>? response,
      String? userId = 'user-1',
      Object? throws,
    }) => PurchaseIntakeRepository(
      confirmAdapter: adapter,
      currentUserId: () => userId,
      invoker: (name, body) async {
        if (throws != null) throw throws;
        return response ??
            {
              'success': true,
              'clientSecret': 'pi_123_secret_abc',
              'paymentIntentId': 'pi_123',
              'orderId': 42,
              'orderNumber': 'WH-2026-0001',
            };
      },
    );

    test('fails fast with noCompany when the hike has no company', () async {
      final adapter = FakeConfirmAdapter();
      final repo = build(adapter: adapter);

      final result = await repo.intakePurchase(
        hike: testHike(companyId: null),
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethodType.card,
      );

      expect(result.isSuccess, isFalse);
      expect(result.reason, 'noCompany');
      // Never reached the Edge Function or the confirm adapter.
      expect(adapter.seenClientSecret, isNull);
    });

    test('fails with notAuthenticated when there is no user', () async {
      final repo = build(adapter: FakeConfirmAdapter(), userId: null);

      final result = await repo.intakePurchase(
        hike: testHike(),
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethodType.card,
      );

      expect(result.reason, 'notAuthenticated');
    });

    test('confirms with the clientSecret and returns the order', () async {
      final adapter = FakeConfirmAdapter();
      final repo = build(adapter: adapter);

      final result = await repo.intakePurchase(
        hike: testHike(),
        deliveryType: DeliveryType.standardShipping,
        deliveryAddress: address,
        paymentMethod: PaymentMethodType.card,
      );

      expect(adapter.seenClientSecret, 'pi_123_secret_abc');
      expect(result.isSuccess, isTrue);
      expect(result.orderId, 42);
      expect(result.orderNumber, 'WH-2026-0001');
      expect(result.paymentIntentId, 'pi_fake');
    });

    test('surfaces an Edge Function error without confirming', () async {
      final adapter = FakeConfirmAdapter();
      final repo = build(
        adapter: adapter,
        response: {'error': 'Company not found'},
      );

      final result = await repo.intakePurchase(
        hike: testHike(),
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethodType.card,
      );

      expect(result.isSuccess, isFalse);
      expect(result.reason, 'intentFailed');
      expect(result.message, contains('Company not found'));
      expect(adapter.seenClientSecret, isNull);
    });

    test('maps a cancelled confirm to reason cancelled', () async {
      final adapter = FakeConfirmAdapter(
        result: const ConfirmResult(isSuccess: false, wasCancelled: true),
      );
      final repo = build(adapter: adapter);

      final result = await repo.intakePurchase(
        hike: testHike(),
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethodType.card,
      );

      expect(result.reason, 'cancelled');
    });

    test('turns an invoke exception into a failure result', () async {
      final repo = build(
        adapter: FakeConfirmAdapter(),
        throws: Exception('boom'),
      );

      final result = await repo.intakePurchase(
        hike: testHike(),
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethodType.card,
      );

      expect(result.isSuccess, isFalse);
      expect(result.reason, 'error');
    });
  });
}
