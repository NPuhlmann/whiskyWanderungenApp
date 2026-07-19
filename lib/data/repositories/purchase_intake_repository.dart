import 'dart:developer' as dev;

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
      final data = await _invoke(
        'create-payment-intent',
        buildPaymentIntentBody(
          hike: hike,
          userId: userId,
          deliveryType: deliveryType,
          deliveryAddress: deliveryAddress,
          metadata: metadata,
        ),
      );

      final clientSecret = data['clientSecret'] as String?;
      if (data['success'] != true || clientSecret == null) {
        final error = data['error'] ?? 'Zahlung konnte nicht gestartet werden';
        dev.log('❌ create-payment-intent failed: $error');
        return PurchaseResult.failure(
          reason: 'intentFailed',
          message: error.toString(),
        );
      }

      final confirmation = await _confirmAdapter.confirm(
        clientSecret: clientSecret,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );

      if (confirmation.isSuccess) {
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
