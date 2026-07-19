// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Company _$CompanyFromJson(Map<String, dynamic> json) => _Company(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  contactEmail: json['contactEmail'] as String,
  phone: json['phone'] as String?,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  city: json['city'] as String,
  postalCode: json['postalCode'] as String?,
  addressLine1: json['addressLine1'] as String?,
  addressLine2: json['addressLine2'] as String?,
  companyRegistrationNumber: json['companyRegistrationNumber'] as String?,
  vatNumber: json['vatNumber'] as String?,
  websiteUrl: json['websiteUrl'] as String?,
  logoUrl: json['logoUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isVerified: json['isVerified'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CompanyToJson(_Company instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'contactEmail': instance.contactEmail,
  'phone': instance.phone,
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'city': instance.city,
  'postalCode': instance.postalCode,
  'addressLine1': instance.addressLine1,
  'addressLine2': instance.addressLine2,
  'companyRegistrationNumber': instance.companyRegistrationNumber,
  'vatNumber': instance.vatNumber,
  'websiteUrl': instance.websiteUrl,
  'logoUrl': instance.logoUrl,
  'isActive': instance.isActive,
  'isVerified': instance.isVerified,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
