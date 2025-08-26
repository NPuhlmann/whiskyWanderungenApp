import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_intent.freezed.dart';
part 'payment_intent.g.dart';

/// Payment method types supported by the app
enum PaymentMethodType {
  @JsonValue('card')
  card,
  @JsonValue('sepa_debit')
  sepaDebit,
  @JsonValue('sofort')
  sofort,
  @JsonValue('giropay')
  giropay,
  @JsonValue('ideal')
  ideal,
  @JsonValue('paypal')
  paypal,
  @JsonValue('apple_pay')
  applePay,
  @JsonValue('google_pay')
  googlePay,
}

/// Payment intent model for Stripe integration
@freezed
class PaymentIntent with _$PaymentIntent {
  const factory PaymentIntent({
    required String id,
    required String clientSecret,
    required int amount,
    required String currency,
    required String status,
    @Default([]) List<PaymentMethodType> paymentMethodTypes,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? confirmedAt,
    String? receiptEmail,
    String? customerId,
    String? paymentMethodId,
    String? lastPaymentError,
  }) = _PaymentIntent;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) => _$PaymentIntentFromJson(json);
}

/// Stripe card details for payment
@freezed
class CardDetails with _$CardDetails {
  const factory CardDetails({
    required String number,
    required int expMonth,
    required int expYear,
    required String cvc,
    String? name,
    @JsonKey(name: 'address_line1') String? addressLine1,
    @JsonKey(name: 'address_line2') String? addressLine2,
    @JsonKey(name: 'address_city') String? addressCity,
    @JsonKey(name: 'address_state') String? addressState,
    @JsonKey(name: 'address_zip') String? addressZip,
    @JsonKey(name: 'address_country') String? addressCountry,
  }) = _CardDetails;

  factory CardDetails.fromJson(Map<String, dynamic> json) => _$CardDetailsFromJson(json);
}

/// Payment method parameters for Stripe
@freezed
class PaymentMethodParams with _$PaymentMethodParams {
  const factory PaymentMethodParams({
    required PaymentMethodType type,
    CardDetails? card,
    @JsonKey(name: 'billing_details') BillingDetails? billingDetails,
    Map<String, dynamic>? metadata,
  }) = _PaymentMethodParams;

  factory PaymentMethodParams.fromJson(Map<String, dynamic> json) => _$PaymentMethodParamsFromJson(json);
  
  /// Factory constructor for card payment method
  factory PaymentMethodParams.card({
    required CardDetails card,
    BillingDetails? billingDetails,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentMethodParams(
      type: PaymentMethodType.card,
      card: card,
      billingDetails: billingDetails,
      metadata: metadata,
    );
  }
}

/// Billing details for payment method
@freezed
class BillingDetails with _$BillingDetails {
  const factory BillingDetails({
    String? name,
    String? email,
    String? phone,
    Address? address,
  }) = _BillingDetails;

  factory BillingDetails.fromJson(Map<String, dynamic> json) => _$BillingDetailsFromJson(json);
}

/// Address model for billing/shipping
@freezed
class Address with _$Address {
  const factory Address({
    @JsonKey(name: 'line1') String? line1,
    @JsonKey(name: 'line2') String? line2,
    String? city,
    String? state,
    @JsonKey(name: 'postal_code') String? postalCode,
    String? country,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}

/// Extensions for business logic on PaymentIntent
extension PaymentIntentExtensions on PaymentIntent {
  /// Check if payment intent is in a succeeded state
  bool get isSucceeded => status == 'succeeded';
  
  /// Check if payment intent requires action
  bool get requiresAction => status == 'requires_action' || status == 'requires_source_action';
  
  /// Check if payment intent requires payment method
  bool get requiresPaymentMethod => status == 'requires_payment_method';
  
  /// Check if payment intent requires confirmation
  bool get requiresConfirmation => status == 'requires_confirmation';
  
  /// Check if payment intent is processing
  bool get isProcessing => status == 'processing';
  
  /// Check if payment intent is cancelled
  bool get isCancelled => status == 'canceled';
  
  /// Get amount in euros (converting from cents)
  double get amountInEuros => amount / 100.0;
  
  /// Check if payment method type is supported
  bool supportsPaymentMethod(PaymentMethodType type) {
    return paymentMethodTypes.contains(type);
  }
}