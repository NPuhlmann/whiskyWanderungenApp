// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'payment_intent.freezed.dart';
// part 'payment_intent.g.dart';

/// Payment method types supported by the app
enum PaymentMethodType {
  card,
  sepaDebit,
  sofort,
  giropay,
  ideal,
  applePay,
  googlePay,
}

/// Payment providers supported by the app
enum PaymentProvider { stripe, paypal, applePay, googlePay }

/// Payment intent model for Stripe integration
class PaymentIntent {
  final String id;
  final String clientSecret;
  final int amount;
  final String currency;
  final String status;
  final List<PaymentMethodType> paymentMethodTypes;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethodTypes,
    this.description,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'] as String,
      clientSecret: json['client_secret'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethodTypes:
          (json['payment_method_types'] as List<dynamic>?)
              ?.map(
                (e) => PaymentMethodType.values.firstWhere(
                  (type) => type.name == e.toString(),
                  orElse: () => PaymentMethodType.card,
                ),
              )
              .toList() ??
          [],
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_secret': clientSecret,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method_types': paymentMethodTypes.map((e) => e.name).toList(),
      'description': description,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PaymentIntent copyWith({
    String? id,
    String? clientSecret,
    int? amount,
    String? currency,
    String? status,
    List<PaymentMethodType>? paymentMethodTypes,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentIntent(
      id: id ?? this.id,
      clientSecret: clientSecret ?? this.clientSecret,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethodTypes: paymentMethodTypes ?? this.paymentMethodTypes,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Payment intent result for handling payment responses
class PaymentIntentResult {
  final bool isSuccess;
  final PaymentIntent? paymentIntent;
  final String? transactionId;
  final String? receiptUrl;
  final String? errorCode;
  final String? errorMessage;
  final String? declineCode;
  final Map<String, dynamic>? additionalData;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final bool isCancelled;

  const PaymentIntentResult({
    required this.isSuccess,
    this.paymentIntent,
    this.transactionId,
    this.receiptUrl,
    this.errorCode,
    this.errorMessage,
    this.declineCode,
    this.additionalData,
    this.actionType,
    this.actionData,
    this.isCancelled = false,
  });

  factory PaymentIntentResult.success({
    required PaymentIntent paymentIntent,
    required String transactionId,
    String? receiptUrl,
  }) {
    return PaymentIntentResult(
      isSuccess: true,
      paymentIntent: paymentIntent,
      transactionId: transactionId,
      receiptUrl: receiptUrl,
    );
  }

  factory PaymentIntentResult.failure({
    required String errorCode,
    required String errorMessage,
    String? declineCode,
    Map<String, dynamic>? additionalData,
  }) {
    return PaymentIntentResult(
      isSuccess: false,
      errorCode: errorCode,
      errorMessage: errorMessage,
      declineCode: declineCode,
      additionalData: additionalData,
    );
  }

  factory PaymentIntentResult.requiresAction({
    required PaymentIntent paymentIntent,
    required String actionType,
    Map<String, dynamic>? actionData,
  }) {
    return PaymentIntentResult(
      isSuccess: false,
      paymentIntent: paymentIntent,
      actionType: actionType,
      actionData: actionData,
    );
  }

  factory PaymentIntentResult.cancelled() {
    return PaymentIntentResult(isSuccess: false, isCancelled: true);
  }
}

/// Stripe card details for payment
class CardDetails {
  final String number;
  final int expMonth;
  final int expYear;
  final String cvc;
  final String? name;
  final String? addressLine1;
  final String? addressLine2;
  final String? addressCity;
  final String? addressState;
  final String? addressZip;
  final String? addressCountry;

  const CardDetails({
    required this.number,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
    this.name,
    this.addressLine1,
    this.addressLine2,
    this.addressCity,
    this.addressState,
    this.addressZip,
    this.addressCountry,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      number: json['number'] as String,
      expMonth: json['exp_month'] as int,
      expYear: json['exp_year'] as int,
      cvc: json['cvc'] as String,
      name: json['name'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      addressCity: json['address_city'] as String?,
      addressState: json['address_state'] as String?,
      addressZip: json['address_zip'] as String?,
      addressCountry: json['address_country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'exp_month': expMonth,
      'exp_year': expYear,
      'cvc': cvc,
      'name': name,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'address_city': addressCity,
      'address_state': addressState,
      'address_zip': addressZip,
      'address_country': addressCountry,
    };
  }
}

/// Payment method parameters for Stripe
class PaymentMethodParams {
  final PaymentMethodType type;
  final CardDetails? card;
  final BillingDetails? billingDetails;
  final Map<String, dynamic>? metadata;

  const PaymentMethodParams({
    required this.type,
    this.card,
    this.billingDetails,
    this.metadata,
  });

  factory PaymentMethodParams.fromJson(Map<String, dynamic> json) {
    return PaymentMethodParams(
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => PaymentMethodType.card,
      ),
      card: json['card'] != null
          ? CardDetails.fromJson(json['card'] as Map<String, dynamic>)
          : null,
      billingDetails: json['billing_details'] != null
          ? BillingDetails.fromJson(
              json['billing_details'] as Map<String, dynamic>,
            )
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

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

  /// Factory constructor for SEPA debit payment method
  factory PaymentMethodParams.sepaDebit({
    BillingDetails? billingDetails,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentMethodParams(
      type: PaymentMethodType.sepaDebit,
      billingDetails: billingDetails,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'card': card?.toJson(),
      'billing_details': billingDetails?.toJson(),
      'metadata': metadata,
    };
  }
}

/// Billing details for payment method
class BillingDetails {
  final String? name;
  final String? email;
  final String? phone;
  final Address? address;

  const BillingDetails({this.name, this.email, this.phone, this.address});

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address?.toJson(),
    };
  }
}

/// Address model for billing/shipping
class Address {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  const Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json['line1'] as String?,
      line2: json['line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }
}

/// Extensions for business logic on PaymentIntent
extension PaymentIntentExtensions on PaymentIntent {
  /// Check if payment intent is in a succeeded state
  bool get isSucceeded => status == 'succeeded';

  /// Check if payment intent requires action
  bool get requiresAction =>
      status == 'requires_action' || status == 'requires_source_action';

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
