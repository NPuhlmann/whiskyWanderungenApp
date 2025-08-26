// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_payment_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnhancedPaymentResult _$EnhancedPaymentResultFromJson(
  Map<String, dynamic> json,
) => _EnhancedPaymentResult(
  isSuccess: json['isSuccess'] as bool,
  status: $enumDecode(_$EnhancedPaymentStatusEnumMap, json['status']),
  order:
      json['order'] == null
          ? null
          : EnhancedOrder.fromJson(json['order'] as Map<String, dynamic>),
  paymentIntentId: json['paymentIntentId'] as String?,
  clientSecret: json['clientSecret'] as String?,
  paymentMethodId: json['paymentMethodId'] as String?,
  paymentProvider: $enumDecodeNullable(
    _$PaymentProviderEnumMap,
    json['paymentProvider'],
  ),
  companyId: json['companyId'] as String?,
  company:
      json['company'] == null
          ? null
          : Company.fromJson(json['company'] as Map<String, dynamic>),
  shippingResult:
      json['shippingResult'] == null
          ? null
          : ShippingCostResult.fromJson(
            json['shippingResult'] as Map<String, dynamic>,
          ),
  deliveryAddress:
      json['deliveryAddress'] == null
          ? null
          : DeliveryAddress.fromJson(
            json['deliveryAddress'] as Map<String, dynamic>,
          ),
  errorMessage: json['errorMessage'] as String?,
  errorCode: json['errorCode'] as String?,
  errorType: $enumDecodeNullable(_$PaymentErrorTypeEnumMap, json['errorType']),
  amount: (json['amount'] as num?)?.toDouble(),
  amountInCents: (json['amountInCents'] as num?)?.toInt(),
  currency: json['currency'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  processedAt:
      json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
  customerEmail: json['customerEmail'] as String?,
  customerId: json['customerId'] as String?,
  nextAction:
      json['nextAction'] == null
          ? null
          : PaymentNextAction.fromJson(
            json['nextAction'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$EnhancedPaymentResultToJson(
  _EnhancedPaymentResult instance,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'status': _$EnhancedPaymentStatusEnumMap[instance.status]!,
  'order': instance.order,
  'paymentIntentId': instance.paymentIntentId,
  'clientSecret': instance.clientSecret,
  'paymentMethodId': instance.paymentMethodId,
  'paymentProvider': _$PaymentProviderEnumMap[instance.paymentProvider],
  'companyId': instance.companyId,
  'company': instance.company,
  'shippingResult': instance.shippingResult,
  'deliveryAddress': instance.deliveryAddress,
  'errorMessage': instance.errorMessage,
  'errorCode': instance.errorCode,
  'errorType': _$PaymentErrorTypeEnumMap[instance.errorType],
  'amount': instance.amount,
  'amountInCents': instance.amountInCents,
  'currency': instance.currency,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'processedAt': instance.processedAt?.toIso8601String(),
  'customerEmail': instance.customerEmail,
  'customerId': instance.customerId,
  'nextAction': instance.nextAction,
};

const _$EnhancedPaymentStatusEnumMap = {
  EnhancedPaymentStatus.succeeded: 'succeeded',
  EnhancedPaymentStatus.failed: 'failed',
  EnhancedPaymentStatus.pending: 'pending',
  EnhancedPaymentStatus.cancelled: 'cancelled',
  EnhancedPaymentStatus.requiresAction: 'requires_action',
  EnhancedPaymentStatus.requiresPaymentMethod: 'requires_payment_method',
  EnhancedPaymentStatus.processing: 'processing',
  EnhancedPaymentStatus.partiallyRefunded: 'partially_refunded',
  EnhancedPaymentStatus.fullyRefunded: 'fully_refunded',
};

const _$PaymentProviderEnumMap = {
  PaymentProvider.stripe: 'stripe',
  PaymentProvider.paypal: 'paypal',
  PaymentProvider.applePay: 'apple_pay',
  PaymentProvider.googlePay: 'google_pay',
};

const _$PaymentErrorTypeEnumMap = {
  PaymentErrorType.cardDeclined: 'card_declined',
  PaymentErrorType.insufficientFunds: 'insufficient_funds',
  PaymentErrorType.cardExpired: 'card_expired',
  PaymentErrorType.invalidCard: 'invalid_card',
  PaymentErrorType.networkError: 'network_error',
  PaymentErrorType.authenticationRequired: 'authentication_required',
  PaymentErrorType.userCancelled: 'user_cancelled',
  PaymentErrorType.processingError: 'processing_error',
  PaymentErrorType.invalidAmount: 'invalid_amount',
  PaymentErrorType.shippingError: 'shipping_error',
  PaymentErrorType.companyError: 'company_error',
  PaymentErrorType.systemError: 'system_error',
  PaymentErrorType.unknown: 'unknown',
};

_PaymentNextAction _$PaymentNextActionFromJson(Map<String, dynamic> json) =>
    _PaymentNextAction(
      type: $enumDecode(_$PaymentActionTypeEnumMap, json['type']),
      redirectUrl: json['redirectUrl'] as String?,
      actionData: json['actionData'] as Map<String, dynamic>?,
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$PaymentNextActionToJson(_PaymentNextAction instance) =>
    <String, dynamic>{
      'type': _$PaymentActionTypeEnumMap[instance.type]!,
      'redirectUrl': instance.redirectUrl,
      'actionData': instance.actionData,
      'instructions': instance.instructions,
    };

const _$PaymentActionTypeEnumMap = {
  PaymentActionType.redirectToUrl: 'redirect_to_url',
  PaymentActionType.useStripeSdk: 'use_stripe_sdk',
  PaymentActionType.verifyWithMicrodeposits: 'verify_with_microdeposits',
  PaymentActionType.oxxoDisplayDetails: 'oxxo_display_details',
};
