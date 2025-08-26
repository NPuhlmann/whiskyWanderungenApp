// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Company {

 String get id; String get name; String? get description; String get contactEmail; String? get phone;// Location Information
 String get countryCode;// ISO 3166-1 alpha-2 (e.g., 'DE', 'AU', 'GB')
 String get countryName; String get city; String? get postalCode; String? get addressLine1; String? get addressLine2;// Business Information
 String? get companyRegistrationNumber; String? get vatNumber; String? get websiteUrl; String? get logoUrl;// System Fields
 bool get isActive; bool get isVerified; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyCopyWith<Company> get copyWith => _$CompanyCopyWithImpl<Company>(this as Company, _$identity);

  /// Serializes this Company to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Company&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.companyRegistrationNumber, companyRegistrationNumber) || other.companyRegistrationNumber == companyRegistrationNumber)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,contactEmail,phone,countryCode,countryName,city,postalCode,addressLine1,addressLine2,companyRegistrationNumber,vatNumber,websiteUrl,logoUrl,isActive,isVerified,createdAt,updatedAt]);

@override
String toString() {
  return 'Company(id: $id, name: $name, description: $description, contactEmail: $contactEmail, phone: $phone, countryCode: $countryCode, countryName: $countryName, city: $city, postalCode: $postalCode, addressLine1: $addressLine1, addressLine2: $addressLine2, companyRegistrationNumber: $companyRegistrationNumber, vatNumber: $vatNumber, websiteUrl: $websiteUrl, logoUrl: $logoUrl, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CompanyCopyWith<$Res>  {
  factory $CompanyCopyWith(Company value, $Res Function(Company) _then) = _$CompanyCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String contactEmail, String? phone, String countryCode, String countryName, String city, String? postalCode, String? addressLine1, String? addressLine2, String? companyRegistrationNumber, String? vatNumber, String? websiteUrl, String? logoUrl, bool isActive, bool isVerified, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CompanyCopyWithImpl<$Res>
    implements $CompanyCopyWith<$Res> {
  _$CompanyCopyWithImpl(this._self, this._then);

  final Company _self;
  final $Res Function(Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? contactEmail = null,Object? phone = freezed,Object? countryCode = null,Object? countryName = null,Object? city = null,Object? postalCode = freezed,Object? addressLine1 = freezed,Object? addressLine2 = freezed,Object? companyRegistrationNumber = freezed,Object? vatNumber = freezed,Object? websiteUrl = freezed,Object? logoUrl = freezed,Object? isActive = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,companyRegistrationNumber: freezed == companyRegistrationNumber ? _self.companyRegistrationNumber : companyRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Company].
extension CompanyPatterns on Company {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Company value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Company value)  $default,){
final _that = this;
switch (_that) {
case _Company():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Company value)?  $default,){
final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String contactEmail,  String? phone,  String countryCode,  String countryName,  String city,  String? postalCode,  String? addressLine1,  String? addressLine2,  String? companyRegistrationNumber,  String? vatNumber,  String? websiteUrl,  String? logoUrl,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.contactEmail,_that.phone,_that.countryCode,_that.countryName,_that.city,_that.postalCode,_that.addressLine1,_that.addressLine2,_that.companyRegistrationNumber,_that.vatNumber,_that.websiteUrl,_that.logoUrl,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String contactEmail,  String? phone,  String countryCode,  String countryName,  String city,  String? postalCode,  String? addressLine1,  String? addressLine2,  String? companyRegistrationNumber,  String? vatNumber,  String? websiteUrl,  String? logoUrl,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Company():
return $default(_that.id,_that.name,_that.description,_that.contactEmail,_that.phone,_that.countryCode,_that.countryName,_that.city,_that.postalCode,_that.addressLine1,_that.addressLine2,_that.companyRegistrationNumber,_that.vatNumber,_that.websiteUrl,_that.logoUrl,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String contactEmail,  String? phone,  String countryCode,  String countryName,  String city,  String? postalCode,  String? addressLine1,  String? addressLine2,  String? companyRegistrationNumber,  String? vatNumber,  String? websiteUrl,  String? logoUrl,  bool isActive,  bool isVerified,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.contactEmail,_that.phone,_that.countryCode,_that.countryName,_that.city,_that.postalCode,_that.addressLine1,_that.addressLine2,_that.companyRegistrationNumber,_that.vatNumber,_that.websiteUrl,_that.logoUrl,_that.isActive,_that.isVerified,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Company implements Company {
  const _Company({required this.id, required this.name, this.description, required this.contactEmail, this.phone, required this.countryCode, required this.countryName, required this.city, this.postalCode, this.addressLine1, this.addressLine2, this.companyRegistrationNumber, this.vatNumber, this.websiteUrl, this.logoUrl, this.isActive = true, this.isVerified = false, required this.createdAt, this.updatedAt});
  factory _Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String contactEmail;
@override final  String? phone;
// Location Information
@override final  String countryCode;
// ISO 3166-1 alpha-2 (e.g., 'DE', 'AU', 'GB')
@override final  String countryName;
@override final  String city;
@override final  String? postalCode;
@override final  String? addressLine1;
@override final  String? addressLine2;
// Business Information
@override final  String? companyRegistrationNumber;
@override final  String? vatNumber;
@override final  String? websiteUrl;
@override final  String? logoUrl;
// System Fields
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isVerified;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyCopyWith<_Company> get copyWith => __$CompanyCopyWithImpl<_Company>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Company&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.companyRegistrationNumber, companyRegistrationNumber) || other.companyRegistrationNumber == companyRegistrationNumber)&&(identical(other.vatNumber, vatNumber) || other.vatNumber == vatNumber)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,contactEmail,phone,countryCode,countryName,city,postalCode,addressLine1,addressLine2,companyRegistrationNumber,vatNumber,websiteUrl,logoUrl,isActive,isVerified,createdAt,updatedAt]);

@override
String toString() {
  return 'Company(id: $id, name: $name, description: $description, contactEmail: $contactEmail, phone: $phone, countryCode: $countryCode, countryName: $countryName, city: $city, postalCode: $postalCode, addressLine1: $addressLine1, addressLine2: $addressLine2, companyRegistrationNumber: $companyRegistrationNumber, vatNumber: $vatNumber, websiteUrl: $websiteUrl, logoUrl: $logoUrl, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CompanyCopyWith<$Res> implements $CompanyCopyWith<$Res> {
  factory _$CompanyCopyWith(_Company value, $Res Function(_Company) _then) = __$CompanyCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String contactEmail, String? phone, String countryCode, String countryName, String city, String? postalCode, String? addressLine1, String? addressLine2, String? companyRegistrationNumber, String? vatNumber, String? websiteUrl, String? logoUrl, bool isActive, bool isVerified, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CompanyCopyWithImpl<$Res>
    implements _$CompanyCopyWith<$Res> {
  __$CompanyCopyWithImpl(this._self, this._then);

  final _Company _self;
  final $Res Function(_Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? contactEmail = null,Object? phone = freezed,Object? countryCode = null,Object? countryName = null,Object? city = null,Object? postalCode = freezed,Object? addressLine1 = freezed,Object? addressLine2 = freezed,Object? companyRegistrationNumber = freezed,Object? vatNumber = freezed,Object? websiteUrl = freezed,Object? logoUrl = freezed,Object? isActive = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Company(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,companyRegistrationNumber: freezed == companyRegistrationNumber ? _self.companyRegistrationNumber : companyRegistrationNumber // ignore: cast_nullable_to_non_nullable
as String?,vatNumber: freezed == vatNumber ? _self.vatNumber : vatNumber // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CompanyShippingRule {

 int get id; String get companyId; String get fromCountryCode; String get toCountryCode; String? get toRegion;// 'EU', 'DACH', 'WORLDWIDE', etc.
 double get shippingCost; double? get freeShippingThreshold; int? get estimatedDeliveryDaysMin; int? get estimatedDeliveryDaysMax; String get serviceName; bool get trackingAvailable; bool get signatureRequired; bool get isActive; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of CompanyShippingRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyShippingRuleCopyWith<CompanyShippingRule> get copyWith => _$CompanyShippingRuleCopyWithImpl<CompanyShippingRule>(this as CompanyShippingRule, _$identity);

  /// Serializes this CompanyShippingRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyShippingRule&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.fromCountryCode, fromCountryCode) || other.fromCountryCode == fromCountryCode)&&(identical(other.toCountryCode, toCountryCode) || other.toCountryCode == toCountryCode)&&(identical(other.toRegion, toRegion) || other.toRegion == toRegion)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.freeShippingThreshold, freeShippingThreshold) || other.freeShippingThreshold == freeShippingThreshold)&&(identical(other.estimatedDeliveryDaysMin, estimatedDeliveryDaysMin) || other.estimatedDeliveryDaysMin == estimatedDeliveryDaysMin)&&(identical(other.estimatedDeliveryDaysMax, estimatedDeliveryDaysMax) || other.estimatedDeliveryDaysMax == estimatedDeliveryDaysMax)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.trackingAvailable, trackingAvailable) || other.trackingAvailable == trackingAvailable)&&(identical(other.signatureRequired, signatureRequired) || other.signatureRequired == signatureRequired)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,fromCountryCode,toCountryCode,toRegion,shippingCost,freeShippingThreshold,estimatedDeliveryDaysMin,estimatedDeliveryDaysMax,serviceName,trackingAvailable,signatureRequired,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'CompanyShippingRule(id: $id, companyId: $companyId, fromCountryCode: $fromCountryCode, toCountryCode: $toCountryCode, toRegion: $toRegion, shippingCost: $shippingCost, freeShippingThreshold: $freeShippingThreshold, estimatedDeliveryDaysMin: $estimatedDeliveryDaysMin, estimatedDeliveryDaysMax: $estimatedDeliveryDaysMax, serviceName: $serviceName, trackingAvailable: $trackingAvailable, signatureRequired: $signatureRequired, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CompanyShippingRuleCopyWith<$Res>  {
  factory $CompanyShippingRuleCopyWith(CompanyShippingRule value, $Res Function(CompanyShippingRule) _then) = _$CompanyShippingRuleCopyWithImpl;
@useResult
$Res call({
 int id, String companyId, String fromCountryCode, String toCountryCode, String? toRegion, double shippingCost, double? freeShippingThreshold, int? estimatedDeliveryDaysMin, int? estimatedDeliveryDaysMax, String serviceName, bool trackingAvailable, bool signatureRequired, bool isActive, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CompanyShippingRuleCopyWithImpl<$Res>
    implements $CompanyShippingRuleCopyWith<$Res> {
  _$CompanyShippingRuleCopyWithImpl(this._self, this._then);

  final CompanyShippingRule _self;
  final $Res Function(CompanyShippingRule) _then;

/// Create a copy of CompanyShippingRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? companyId = null,Object? fromCountryCode = null,Object? toCountryCode = null,Object? toRegion = freezed,Object? shippingCost = null,Object? freeShippingThreshold = freezed,Object? estimatedDeliveryDaysMin = freezed,Object? estimatedDeliveryDaysMax = freezed,Object? serviceName = null,Object? trackingAvailable = null,Object? signatureRequired = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,fromCountryCode: null == fromCountryCode ? _self.fromCountryCode : fromCountryCode // ignore: cast_nullable_to_non_nullable
as String,toCountryCode: null == toCountryCode ? _self.toCountryCode : toCountryCode // ignore: cast_nullable_to_non_nullable
as String,toRegion: freezed == toRegion ? _self.toRegion : toRegion // ignore: cast_nullable_to_non_nullable
as String?,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,freeShippingThreshold: freezed == freeShippingThreshold ? _self.freeShippingThreshold : freeShippingThreshold // ignore: cast_nullable_to_non_nullable
as double?,estimatedDeliveryDaysMin: freezed == estimatedDeliveryDaysMin ? _self.estimatedDeliveryDaysMin : estimatedDeliveryDaysMin // ignore: cast_nullable_to_non_nullable
as int?,estimatedDeliveryDaysMax: freezed == estimatedDeliveryDaysMax ? _self.estimatedDeliveryDaysMax : estimatedDeliveryDaysMax // ignore: cast_nullable_to_non_nullable
as int?,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,trackingAvailable: null == trackingAvailable ? _self.trackingAvailable : trackingAvailable // ignore: cast_nullable_to_non_nullable
as bool,signatureRequired: null == signatureRequired ? _self.signatureRequired : signatureRequired // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyShippingRule].
extension CompanyShippingRulePatterns on CompanyShippingRule {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyShippingRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyShippingRule() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyShippingRule value)  $default,){
final _that = this;
switch (_that) {
case _CompanyShippingRule():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyShippingRule value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyShippingRule() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String companyId,  String fromCountryCode,  String toCountryCode,  String? toRegion,  double shippingCost,  double? freeShippingThreshold,  int? estimatedDeliveryDaysMin,  int? estimatedDeliveryDaysMax,  String serviceName,  bool trackingAvailable,  bool signatureRequired,  bool isActive,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyShippingRule() when $default != null:
return $default(_that.id,_that.companyId,_that.fromCountryCode,_that.toCountryCode,_that.toRegion,_that.shippingCost,_that.freeShippingThreshold,_that.estimatedDeliveryDaysMin,_that.estimatedDeliveryDaysMax,_that.serviceName,_that.trackingAvailable,_that.signatureRequired,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String companyId,  String fromCountryCode,  String toCountryCode,  String? toRegion,  double shippingCost,  double? freeShippingThreshold,  int? estimatedDeliveryDaysMin,  int? estimatedDeliveryDaysMax,  String serviceName,  bool trackingAvailable,  bool signatureRequired,  bool isActive,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CompanyShippingRule():
return $default(_that.id,_that.companyId,_that.fromCountryCode,_that.toCountryCode,_that.toRegion,_that.shippingCost,_that.freeShippingThreshold,_that.estimatedDeliveryDaysMin,_that.estimatedDeliveryDaysMax,_that.serviceName,_that.trackingAvailable,_that.signatureRequired,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String companyId,  String fromCountryCode,  String toCountryCode,  String? toRegion,  double shippingCost,  double? freeShippingThreshold,  int? estimatedDeliveryDaysMin,  int? estimatedDeliveryDaysMax,  String serviceName,  bool trackingAvailable,  bool signatureRequired,  bool isActive,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CompanyShippingRule() when $default != null:
return $default(_that.id,_that.companyId,_that.fromCountryCode,_that.toCountryCode,_that.toRegion,_that.shippingCost,_that.freeShippingThreshold,_that.estimatedDeliveryDaysMin,_that.estimatedDeliveryDaysMax,_that.serviceName,_that.trackingAvailable,_that.signatureRequired,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanyShippingRule implements CompanyShippingRule {
  const _CompanyShippingRule({required this.id, required this.companyId, required this.fromCountryCode, required this.toCountryCode, this.toRegion, required this.shippingCost, this.freeShippingThreshold, this.estimatedDeliveryDaysMin, this.estimatedDeliveryDaysMax, this.serviceName = 'Standard', this.trackingAvailable = true, this.signatureRequired = false, this.isActive = true, required this.createdAt, this.updatedAt});
  factory _CompanyShippingRule.fromJson(Map<String, dynamic> json) => _$CompanyShippingRuleFromJson(json);

@override final  int id;
@override final  String companyId;
@override final  String fromCountryCode;
@override final  String toCountryCode;
@override final  String? toRegion;
// 'EU', 'DACH', 'WORLDWIDE', etc.
@override final  double shippingCost;
@override final  double? freeShippingThreshold;
@override final  int? estimatedDeliveryDaysMin;
@override final  int? estimatedDeliveryDaysMax;
@override@JsonKey() final  String serviceName;
@override@JsonKey() final  bool trackingAvailable;
@override@JsonKey() final  bool signatureRequired;
@override@JsonKey() final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of CompanyShippingRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyShippingRuleCopyWith<_CompanyShippingRule> get copyWith => __$CompanyShippingRuleCopyWithImpl<_CompanyShippingRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyShippingRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyShippingRule&&(identical(other.id, id) || other.id == id)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.fromCountryCode, fromCountryCode) || other.fromCountryCode == fromCountryCode)&&(identical(other.toCountryCode, toCountryCode) || other.toCountryCode == toCountryCode)&&(identical(other.toRegion, toRegion) || other.toRegion == toRegion)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.freeShippingThreshold, freeShippingThreshold) || other.freeShippingThreshold == freeShippingThreshold)&&(identical(other.estimatedDeliveryDaysMin, estimatedDeliveryDaysMin) || other.estimatedDeliveryDaysMin == estimatedDeliveryDaysMin)&&(identical(other.estimatedDeliveryDaysMax, estimatedDeliveryDaysMax) || other.estimatedDeliveryDaysMax == estimatedDeliveryDaysMax)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.trackingAvailable, trackingAvailable) || other.trackingAvailable == trackingAvailable)&&(identical(other.signatureRequired, signatureRequired) || other.signatureRequired == signatureRequired)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,companyId,fromCountryCode,toCountryCode,toRegion,shippingCost,freeShippingThreshold,estimatedDeliveryDaysMin,estimatedDeliveryDaysMax,serviceName,trackingAvailable,signatureRequired,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'CompanyShippingRule(id: $id, companyId: $companyId, fromCountryCode: $fromCountryCode, toCountryCode: $toCountryCode, toRegion: $toRegion, shippingCost: $shippingCost, freeShippingThreshold: $freeShippingThreshold, estimatedDeliveryDaysMin: $estimatedDeliveryDaysMin, estimatedDeliveryDaysMax: $estimatedDeliveryDaysMax, serviceName: $serviceName, trackingAvailable: $trackingAvailable, signatureRequired: $signatureRequired, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CompanyShippingRuleCopyWith<$Res> implements $CompanyShippingRuleCopyWith<$Res> {
  factory _$CompanyShippingRuleCopyWith(_CompanyShippingRule value, $Res Function(_CompanyShippingRule) _then) = __$CompanyShippingRuleCopyWithImpl;
@override @useResult
$Res call({
 int id, String companyId, String fromCountryCode, String toCountryCode, String? toRegion, double shippingCost, double? freeShippingThreshold, int? estimatedDeliveryDaysMin, int? estimatedDeliveryDaysMax, String serviceName, bool trackingAvailable, bool signatureRequired, bool isActive, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CompanyShippingRuleCopyWithImpl<$Res>
    implements _$CompanyShippingRuleCopyWith<$Res> {
  __$CompanyShippingRuleCopyWithImpl(this._self, this._then);

  final _CompanyShippingRule _self;
  final $Res Function(_CompanyShippingRule) _then;

/// Create a copy of CompanyShippingRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? companyId = null,Object? fromCountryCode = null,Object? toCountryCode = null,Object? toRegion = freezed,Object? shippingCost = null,Object? freeShippingThreshold = freezed,Object? estimatedDeliveryDaysMin = freezed,Object? estimatedDeliveryDaysMax = freezed,Object? serviceName = null,Object? trackingAvailable = null,Object? signatureRequired = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_CompanyShippingRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,fromCountryCode: null == fromCountryCode ? _self.fromCountryCode : fromCountryCode // ignore: cast_nullable_to_non_nullable
as String,toCountryCode: null == toCountryCode ? _self.toCountryCode : toCountryCode // ignore: cast_nullable_to_non_nullable
as String,toRegion: freezed == toRegion ? _self.toRegion : toRegion // ignore: cast_nullable_to_non_nullable
as String?,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,freeShippingThreshold: freezed == freeShippingThreshold ? _self.freeShippingThreshold : freeShippingThreshold // ignore: cast_nullable_to_non_nullable
as double?,estimatedDeliveryDaysMin: freezed == estimatedDeliveryDaysMin ? _self.estimatedDeliveryDaysMin : estimatedDeliveryDaysMin // ignore: cast_nullable_to_non_nullable
as int?,estimatedDeliveryDaysMax: freezed == estimatedDeliveryDaysMax ? _self.estimatedDeliveryDaysMax : estimatedDeliveryDaysMax // ignore: cast_nullable_to_non_nullable
as int?,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,trackingAvailable: null == trackingAvailable ? _self.trackingAvailable : trackingAvailable // ignore: cast_nullable_to_non_nullable
as bool,signatureRequired: null == signatureRequired ? _self.signatureRequired : signatureRequired // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
