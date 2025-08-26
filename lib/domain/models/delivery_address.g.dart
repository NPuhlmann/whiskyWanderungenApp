// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryAddress _$DeliveryAddressFromJson(Map<String, dynamic> json) =>
    _DeliveryAddress(
      id: json['id'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      company: json['company'] as String?,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      countryCode: json['countryCode'] as String,
      countryName: json['countryName'] as String,
      state: json['state'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
      isBusinessAddress: json['isBusinessAddress'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DeliveryAddressToJson(_DeliveryAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'company': instance.company,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'countryCode': instance.countryCode,
      'countryName': instance.countryName,
      'state': instance.state,
      'phone': instance.phone,
      'email': instance.email,
      'deliveryInstructions': instance.deliveryInstructions,
      'isBusinessAddress': instance.isBusinessAddress,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_AddressValidationResult _$AddressValidationResultFromJson(
  Map<String, dynamic> json,
) => _AddressValidationResult(
  isValid: json['isValid'] as bool,
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$AddressValidationResultToJson(
  _AddressValidationResult instance,
) => <String, dynamic>{'isValid': instance.isValid, 'errors': instance.errors};

_ShippingCostResult _$ShippingCostResultFromJson(Map<String, dynamic> json) =>
    _ShippingCostResult(
      cost: (json['cost'] as num).toDouble(),
      isFreeShipping: json['isFreeShipping'] as bool,
      serviceName: json['serviceName'] as String,
      estimatedDaysMin: (json['estimatedDaysMin'] as num?)?.toInt(),
      estimatedDaysMax: (json['estimatedDaysMax'] as num?)?.toInt(),
      region: json['region'] as String?,
      description: json['description'] as String?,
      trackingAvailable: json['trackingAvailable'] as bool? ?? true,
      signatureRequired: json['signatureRequired'] as bool? ?? false,
    );

Map<String, dynamic> _$ShippingCostResultToJson(_ShippingCostResult instance) =>
    <String, dynamic>{
      'cost': instance.cost,
      'isFreeShipping': instance.isFreeShipping,
      'serviceName': instance.serviceName,
      'estimatedDaysMin': instance.estimatedDaysMin,
      'estimatedDaysMax': instance.estimatedDaysMax,
      'region': instance.region,
      'description': instance.description,
      'trackingAvailable': instance.trackingAvailable,
      'signatureRequired': instance.signatureRequired,
    };
