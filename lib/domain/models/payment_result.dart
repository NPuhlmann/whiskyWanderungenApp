import 'package:freezed_annotation/freezed_annotation.dart';
import 'order.dart';

part 'payment_result.freezed.dart';
part 'payment_result.g.dart';

/// Payment status enum for tracking payment state
enum PaymentStatus {
  @JsonValue('succeeded')
  succeeded,
  @JsonValue('failed')
  failed,
  @JsonValue('pending')
  pending,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('requires_action')
  requiresAction,
}

/// Result of a payment operation
@freezed
abstract class PaymentResult with _$PaymentResult {
  const factory PaymentResult({
    required bool isSuccess,
    Order? order,
    String? clientSecret,
    String? errorMessage,
    PaymentStatus? status,
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) = _PaymentResult;

  factory PaymentResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultFromJson(json);

  /// Factory constructor for successful payment
  factory PaymentResult.success({
    required Order order,
    String? clientSecret,
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      isSuccess: true,
      order: order,
      clientSecret: clientSecret,
      status: PaymentStatus.succeeded,
      paymentIntentId: paymentIntentId,
      metadata: metadata,
    );
  }

  /// Factory constructor for failed payment
  factory PaymentResult.failure({
    required String error,
    PaymentStatus? status,
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      isSuccess: false,
      errorMessage: error,
      status: status ?? PaymentStatus.failed,
      paymentIntentId: paymentIntentId,
      metadata: metadata,
    );
  }

  /// Factory constructor for cancelled payment
  factory PaymentResult.cancelled({String? message, String? paymentIntentId}) {
    return PaymentResult(
      isSuccess: false,
      errorMessage: message ?? 'Payment was cancelled by user',
      status: PaymentStatus.cancelled,
      paymentIntentId: paymentIntentId,
    );
  }

  /// Factory constructor for pending payment (requires additional action)
  factory PaymentResult.requiresAction({
    required String clientSecret,
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      isSuccess: false,
      clientSecret: clientSecret,
      status: PaymentStatus.requiresAction,
      paymentIntentId: paymentIntentId,
      metadata: metadata,
      errorMessage: 'Additional authentication required',
    );
  }
}

/// Extension for business logic on PaymentResult
extension PaymentResultExtensions on PaymentResult {
  /// Check if payment requires additional user action (3D Secure, etc.)
  bool get requiresUserAction => status == PaymentStatus.requiresAction;

  /// Check if payment was cancelled by user
  bool get wasCancelled => status == PaymentStatus.cancelled;

  /// Check if payment is still processing
  bool get isPending => status == PaymentStatus.pending;

  /// Get user-friendly error message
  String get friendlyErrorMessage {
    if (errorMessage == null) return 'Unknown error occurred';

    final message = errorMessage!.toLowerCase();

    if (message.contains('declined') || message.contains('insufficient')) {
      return 'Ihre Karte wurde abgelehnt. Bitte versuchen Sie eine andere Zahlungsmethode.';
    }

    if (message.contains('expired')) {
      return 'Ihre Karte ist abgelaufen. Bitte verwenden Sie eine aktuelle Karte.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';
    }

    if (message.contains('invalid') || message.contains('incorrect')) {
      return 'Ungültige Kartendaten. Bitte überprüfen Sie Ihre Eingaben.';
    }

    if (message.contains('cancelled')) {
      return 'Zahlung wurde abgebrochen.';
    }

    // Fallback für unbekannte Fehler
    return 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut oder kontaktieren Sie den Support.';
  }
}
