// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentIntent _$PaymentIntentFromJson(Map<String, dynamic> json) =>
    _PaymentIntent(
      id: json['id'] as String,
      clientSecret: json['clientSecret'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethodTypes:
          (json['paymentMethodTypes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$PaymentMethodTypeEnumMap, e))
              .toList() ??
          const [],
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      confirmedAt:
          json['confirmedAt'] == null
              ? null
              : DateTime.parse(json['confirmedAt'] as String),
      receiptEmail: json['receiptEmail'] as String?,
      customerId: json['customerId'] as String?,
      paymentMethodId: json['paymentMethodId'] as String?,
      lastPaymentError: json['lastPaymentError'] as String?,
    );

Map<String, dynamic> _$PaymentIntentToJson(_PaymentIntent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientSecret': instance.clientSecret,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'paymentMethodTypes':
          instance.paymentMethodTypes
              .map((e) => _$PaymentMethodTypeEnumMap[e]!)
              .toList(),
      'description': instance.description,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'receiptEmail': instance.receiptEmail,
      'customerId': instance.customerId,
      'paymentMethodId': instance.paymentMethodId,
      'lastPaymentError': instance.lastPaymentError,
    };

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.card: 'card',
  PaymentMethodType.sepaDebit: 'sepa_debit',
  PaymentMethodType.sofort: 'sofort',
  PaymentMethodType.giropay: 'giropay',
  PaymentMethodType.ideal: 'ideal',
};

_CardDetails _$CardDetailsFromJson(Map<String, dynamic> json) => _CardDetails(
  number: json['number'] as String,
  expMonth: (json['expMonth'] as num).toInt(),
  expYear: (json['expYear'] as num).toInt(),
  cvc: json['cvc'] as String,
  name: json['name'] as String?,
  addressLine1: json['address_line1'] as String?,
  addressLine2: json['address_line2'] as String?,
  addressCity: json['address_city'] as String?,
  addressState: json['address_state'] as String?,
  addressZip: json['address_zip'] as String?,
  addressCountry: json['address_country'] as String?,
);

Map<String, dynamic> _$CardDetailsToJson(_CardDetails instance) =>
    <String, dynamic>{
      'number': instance.number,
      'expMonth': instance.expMonth,
      'expYear': instance.expYear,
      'cvc': instance.cvc,
      'name': instance.name,
      'address_line1': instance.addressLine1,
      'address_line2': instance.addressLine2,
      'address_city': instance.addressCity,
      'address_state': instance.addressState,
      'address_zip': instance.addressZip,
      'address_country': instance.addressCountry,
    };

_PaymentMethodParams _$PaymentMethodParamsFromJson(Map<String, dynamic> json) =>
    _PaymentMethodParams(
      type: $enumDecode(_$PaymentMethodTypeEnumMap, json['type']),
      card:
          json['card'] == null
              ? null
              : CardDetails.fromJson(json['card'] as Map<String, dynamic>),
      billingDetails:
          json['billing_details'] == null
              ? null
              : BillingDetails.fromJson(
                json['billing_details'] as Map<String, dynamic>,
              ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentMethodParamsToJson(
  _PaymentMethodParams instance,
) => <String, dynamic>{
  'type': _$PaymentMethodTypeEnumMap[instance.type]!,
  'card': instance.card,
  'billing_details': instance.billingDetails,
  'metadata': instance.metadata,
};

_BillingDetails _$BillingDetailsFromJson(Map<String, dynamic> json) =>
    _BillingDetails(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address:
          json['address'] == null
              ? null
              : Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BillingDetailsToJson(_BillingDetails instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
    };

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  line1: json['line1'] as String?,
  line2: json['line2'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  postalCode: json['postal_code'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'line1': instance.line1,
  'line2': instance.line2,
  'city': instance.city,
  'state': instance.state,
  'postal_code': instance.postalCode,
  'country': instance.country,
};
