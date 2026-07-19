import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/basic_order.dart';
import '../../domain/models/hike.dart';
import '../../domain/models/payment_intent.dart';
import '../../domain/models/purchase_result.dart';
import '../services/payment/multi_payment_service.dart';
import '../services/payment/stripe_confirm_adapter.dart';

/// Calls a Supabase Edge Function and returns its decoded JSON body.
typedef EdgeFunctionInvoker =
    Future<Map<String, dynamic>> Function(
      String name,
      Map<String, dynamic> body,
    );

/// Shipping cost per delivery type, in euros.
const _shippingCosts = {
  DeliveryType.pickup: 0.0,
  DeliveryType.standardShipping: 5.0,
  DeliveryType.expressShipping: 10.0,
};

/// Wire values expected by the `create-payment-intent` Edge Function.
const _deliveryTypeWire = {
  DeliveryType.pickup: 'pickup',
  DeliveryType.standardShipping: 'standard_shipping',
  DeliveryType.expressShipping: 'express_shipping',
};

// ponytail: the checkout form asks for a country name, the Edge Function wants
// ISO-3166 alpha-2. Three countries cover every hike we sell today; swap for a
// country picker that yields codes directly when that stops being true.
const _countryCodes = {
  'deutschland': 'DE',
  'germany': 'DE',
  'österreich': 'AT',
  'oesterreich': 'AT',
  'austria': 'AT',
  'schweiz': 'CH',
  'switzerland': 'CH',
};

String _countryCode(String? country) {
  final value = (country ?? '').trim();
  if (RegExp(r'^[A-Za-z]{2}$').hasMatch(value)) return value.toUpperCase();
  return _countryCodes[value.toLowerCase()] ?? 'DE';
}

/// Translates Flutter domain types into the Edge Function's wire format.
///
/// Pure and top-level so the mapping is testable without a Supabase client.
Map<String, dynamic> buildPaymentIntentBody({
  required Hike hike,
  required String userId,
  required DeliveryType deliveryType,
  Map<String, dynamic>? deliveryAddress,
  Map<String, dynamic>? metadata,
}) {
  final body = <String, dynamic>{
    'companyId': hike.companyId,
    'hikeId': hike.id,
    'userId': userId,
    'deliveryType': _deliveryTypeWire[deliveryType],
    'orderValue': hike.price,
    'shippingCost': _shippingCosts[deliveryType] ?? 0.0,
    'currency': 'eur',
    if (metadata != null)
      'metadata': metadata.map((k, v) => MapEntry(k, v.toString())),
  };

  if (deliveryType != DeliveryType.pickup && deliveryAddress != null) {
    body['deliveryAddress'] = {
      'firstName': deliveryAddress['firstName'],
      'lastName': deliveryAddress['lastName'],
      'addressLine1': deliveryAddress['street'],
      'city': deliveryAddress['city'],
      'postalCode': deliveryAddress['postalCode'],
      'countryCode': _countryCode(deliveryAddress['country'] as String?),
    };
  }

  return body;
}

/// An in-flight `create-payment-intent` attempt, kept so a retry of the same
/// purchase reuses the order and PaymentIntent it already created.
class _PendingIntent {
  /// Fingerprint of the request body, minus the idempotency key.
  final String fingerprint;
  final String idempotencyKey;

  /// The Edge Function response, once one has come back successfully.
  Map<String, dynamic>? data;

  _PendingIntent(this.fingerprint, this.idempotencyKey);
}

final _random = Random();

String _newIdempotencyKey() =>
    'wh_${DateTime.now().microsecondsSinceEpoch}_'
    '${_random.nextInt(1 << 32).toRadixString(16)}';

/// Takes a purchase from "user tapped Buy" to "order paid".
///
/// Creates the payment intent server-side via the `create-payment-intent`
/// Edge Function (ADR-0006: no Stripe secret key ever reaches the client),
/// then confirms it through [StripeConfirmAdapter].
class PurchaseIntakeRepository {
  final StripeConfirmAdapter _confirmAdapter;
  final MultiPaymentService _multiPaymentService;
  final EdgeFunctionInvoker _invoke;
  final String? Function() _currentUserId;

  // ponytail: one attempt at a time is all checkout can produce — the user
  // pays for one hike from one screen. Key it by user too if a background
  // purchase queue ever lands.
  _PendingIntent? _pending;

  PurchaseIntakeRepository({
    required StripeConfirmAdapter confirmAdapter,
    SupabaseClient? supabaseClient,
    MultiPaymentService? multiPaymentService,
    EdgeFunctionInvoker? invoker,
    String? Function()? currentUserId,
  }) : _confirmAdapter = confirmAdapter,
       _multiPaymentService =
           multiPaymentService ?? MultiPaymentService.instance,
       _invoke =
           invoker ??
           _supabaseInvoker(supabaseClient ?? Supabase.instance.client),
       _currentUserId =
           currentUserId ??
           (() => (supabaseClient ?? Supabase.instance.client)
               .auth
               .currentUser
               ?.id);

  static EdgeFunctionInvoker _supabaseInvoker(SupabaseClient client) =>
      (name, body) async {
        final response = await client.functions.invoke(name, body: body);
        final data = response.data;
        return data is Map<String, dynamic>
            ? data
            : {'error': 'Invalid response'};
      };

  Future<PurchaseResult> intakePurchase({
    required Hike hike,
    required DeliveryType deliveryType,
    Map<String, dynamic>? deliveryAddress,
    required PaymentMethodType paymentMethod,
    String? paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    // Fail fast rather than sending the Edge Function data it will reject.
    if (hike.companyId == null || hike.companyId!.isEmpty) {
      dev.log('❌ Hike ${hike.id} has no company — cannot create an order');
      return const PurchaseResult.failure(
        reason: 'noCompany',
        message: 'Diese Wanderung kann derzeit nicht gekauft werden.',
      );
    }

    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      return const PurchaseResult.failure(
        reason: 'notAuthenticated',
        message: 'Bitte melden Sie sich an, um zu kaufen.',
      );
    }

    try {
      final body = buildPaymentIntentBody(
        hike: hike,
        userId: userId,
        deliveryType: deliveryType,
        deliveryAddress: deliveryAddress,
        metadata: metadata,
      );

      // A retry of the same purchase — declined card, 3DS, or the user
      // dismissing the Stripe sheet — must not leave a second pending order
      // and a second PaymentIntent behind (#39).
      final fingerprint = jsonEncode(body);
      var pending = _pending;
      if (pending == null || pending.fingerprint != fingerprint) {
        pending = _PendingIntent(fingerprint, _newIdempotencyKey());
        _pending = pending;
      }

      var data = pending.data;
      if (data == null) {
        data = await _invoke('create-payment-intent', {
          ...body,
          'idempotencyKey': pending.idempotencyKey,
        });

        if (data['success'] != true || data['clientSecret'] == null) {
          final error =
              data['error'] ?? 'Zahlung konnte nicht gestartet werden';
          dev.log('❌ create-payment-intent failed: $error');
          // Keep the idempotency key so the next attempt is a retry of this
          // intent, not a new one.
          return PurchaseResult.failure(
            reason: 'intentFailed',
            message: error.toString(),
          );
        }
        pending.data = data;
      } else {
        dev.log('♻️ Reusing pending order ${data['orderNumber']}');
      }

      final clientSecret = data['clientSecret'] as String;

      final confirmation = await _confirmAdapter.confirm(
        clientSecret: clientSecret,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );

      if (confirmation.isSuccess) {
        _pending = null;
        dev.log('✅ Purchase completed for order ${data['orderNumber']}');
        return PurchaseResult.success(
          orderId: data['orderId'] as int,
          orderNumber: data['orderNumber'] as String,
          paymentIntentId:
              confirmation.paymentIntentId ??
              data['paymentIntentId'] as String?,
        );
      }

      if (confirmation.wasCancelled) {
        return const PurchaseResult.failure(
          reason: 'cancelled',
          message: 'Zahlung wurde abgebrochen',
        );
      }
      if (confirmation.requiresAction) {
        return const PurchaseResult.failure(
          reason: 'requiresAction',
          message:
              'Zusätzliche Authentifizierung erforderlich. '
              'Bitte versuchen Sie es erneut.',
        );
      }
      return PurchaseResult.failure(
        reason: 'confirmFailed',
        message: confirmation.errorMessage ?? 'Zahlung fehlgeschlagen',
      );
    } catch (e) {
      dev.log('❌ Purchase intake error: $e');
      return const PurchaseResult.failure(
        reason: 'error',
        message:
            'Ein unerwarteter Fehler ist aufgetreten. '
            'Bitte versuchen Sie es erneut.',
      );
    }
  }

  Future<List<PaymentMethodType>> getAvailablePaymentMethods() =>
      _multiPaymentService.getAvailablePaymentMethods();

  Future<bool> isPaymentMethodAvailable(PaymentMethodType paymentMethod) =>
      _multiPaymentService.isPaymentMethodAvailable(paymentMethod);
}
