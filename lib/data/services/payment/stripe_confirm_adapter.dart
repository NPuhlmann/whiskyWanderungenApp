import 'dart:developer' as dev;

import 'package:flutter_stripe/flutter_stripe.dart';

/// Outcome of confirming a payment intent on the client.
class ConfirmResult {
  final bool isSuccess;
  final bool wasCancelled;
  final bool requiresAction;
  final String? paymentIntentId;
  final String? errorMessage;

  const ConfirmResult({
    required this.isSuccess,
    this.wasCancelled = false,
    this.requiresAction = false,
    this.paymentIntentId,
    this.errorMessage,
  });
}

/// Seam for confirming a payment intent.
///
/// Two implementations justify it: [FlutterStripeConfirmAdapter] in the app,
/// an in-memory fake in tests.
abstract class StripeConfirmAdapter {
  Future<ConfirmResult> confirm({
    required String clientSecret,
    String? paymentMethodId,
    Map<String, dynamic>? metadata,
  });
}

/// Confirms via the `flutter_stripe` SDK.
class FlutterStripeConfirmAdapter implements StripeConfirmAdapter {
  const FlutterStripeConfirmAdapter();

  @override
  Future<ConfirmResult> confirm({
    required String clientSecret,
    String? paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!clientSecret.contains('_secret_')) {
      return const ConfirmResult(
        isSuccess: false,
        errorMessage: 'Invalid client secret format',
      );
    }

    try {
      final intent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      switch (intent.status) {
        case PaymentIntentsStatus.Succeeded:
          return ConfirmResult(isSuccess: true, paymentIntentId: intent.id);
        case PaymentIntentsStatus.RequiresAction:
          return ConfirmResult(
            isSuccess: false,
            requiresAction: true,
            paymentIntentId: intent.id,
          );
        case PaymentIntentsStatus.Canceled:
          return ConfirmResult(
            isSuccess: false,
            wasCancelled: true,
            paymentIntentId: intent.id,
            errorMessage: 'Payment was canceled',
          );
        default:
          return ConfirmResult(
            isSuccess: false,
            paymentIntentId: intent.id,
            errorMessage: 'Payment failed with status: ${intent.status}',
          );
      }
    } on StripeException catch (e) {
      dev.log('❌ Stripe confirm error: ${e.error.message}');
      return ConfirmResult(
        isSuccess: false,
        wasCancelled: e.error.code == FailureCode.Canceled,
        errorMessage: e.error.message ?? 'Payment failed',
      );
    } catch (e) {
      dev.log('❌ Stripe confirm error: $e');
      return ConfirmResult(
        isSuccess: false,
        errorMessage: 'Payment failed: $e',
      );
    }
  }
}
