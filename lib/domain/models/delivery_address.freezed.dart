// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryAddress {

 String? get id;// Optional für gespeicherte Adressen
// Persönliche Daten
 String get firstName; String get lastName; String? get company;// Optional für Firmenadressen
// Adressdaten
 String get addressLine1; String? get addressLine2; String get city; String get postalCode; String get countryCode;// ISO 3166-1 alpha-2
 String get countryName; String? get state;// Für USA, Australien, etc.
// Kontaktdaten
 String? get phone; String? get email;// Zusatzinformationen
 String? get deliveryInstructions; bool get isBusinessAddress; bool get isDefault;// Standardadresse des Users
// System Fields
 DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<DeliveryAddress> get copyWith => _$DeliveryAddressCopyWithImpl<DeliveryAddress>(this as DeliveryAddress, _$identity);

  /// Serializes this DeliveryAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.company, company) || other.company == company)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.state, state) || other.state == state)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.deliveryInstructions, deliveryInstructions) || other.deliveryInstructions == deliveryInstructions)&&(identical(other.isBusinessAddress, isBusinessAddress) || other.isBusinessAddress == isBusinessAddress)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,company,addressLine1,addressLine2,city,postalCode,countryCode,countryName,state,phone,email,deliveryInstructions,isBusinessAddress,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'DeliveryAddress(id: $id, firstName: $firstName, lastName: $lastName, company: $company, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, postalCode: $postalCode, countryCode: $countryCode, countryName: $countryName, state: $state, phone: $phone, email: $email, deliveryInstructions: $deliveryInstructions, isBusinessAddress: $isBusinessAddress, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DeliveryAddressCopyWith<$Res>  {
  factory $DeliveryAddressCopyWith(DeliveryAddress value, $Res Function(DeliveryAddress) _then) = _$DeliveryAddressCopyWithImpl;
@useResult
$Res call({
 String? id, String firstName, String lastName, String? company, String addressLine1, String? addressLine2, String city, String postalCode, String countryCode, String countryName, String? state, String? phone, String? email, String? deliveryInstructions, bool isBusinessAddress, bool isDefault, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$DeliveryAddressCopyWithImpl<$Res>
    implements $DeliveryAddressCopyWith<$Res> {
  _$DeliveryAddressCopyWithImpl(this._self, this._then);

  final DeliveryAddress _self;
  final $Res Function(DeliveryAddress) _then;

/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? firstName = null,Object? lastName = null,Object? company = freezed,Object? addressLine1 = null,Object? addressLine2 = freezed,Object? city = null,Object? postalCode = null,Object? countryCode = null,Object? countryName = null,Object? state = freezed,Object? phone = freezed,Object? email = freezed,Object? deliveryInstructions = freezed,Object? isBusinessAddress = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,deliveryInstructions: freezed == deliveryInstructions ? _self.deliveryInstructions : deliveryInstructions // ignore: cast_nullable_to_non_nullable
as String?,isBusinessAddress: null == isBusinessAddress ? _self.isBusinessAddress : isBusinessAddress // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryAddress].
extension DeliveryAddressPatterns on DeliveryAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryAddress value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryAddress value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String firstName,  String lastName,  String? company,  String addressLine1,  String? addressLine2,  String city,  String postalCode,  String countryCode,  String countryName,  String? state,  String? phone,  String? email,  String? deliveryInstructions,  bool isBusinessAddress,  bool isDefault,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.company,_that.addressLine1,_that.addressLine2,_that.city,_that.postalCode,_that.countryCode,_that.countryName,_that.state,_that.phone,_that.email,_that.deliveryInstructions,_that.isBusinessAddress,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String firstName,  String lastName,  String? company,  String addressLine1,  String? addressLine2,  String city,  String postalCode,  String countryCode,  String countryName,  String? state,  String? phone,  String? email,  String? deliveryInstructions,  bool isBusinessAddress,  bool isDefault,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DeliveryAddress():
return $default(_that.id,_that.firstName,_that.lastName,_that.company,_that.addressLine1,_that.addressLine2,_that.city,_that.postalCode,_that.countryCode,_that.countryName,_that.state,_that.phone,_that.email,_that.deliveryInstructions,_that.isBusinessAddress,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String firstName,  String lastName,  String? company,  String addressLine1,  String? addressLine2,  String city,  String postalCode,  String countryCode,  String countryName,  String? state,  String? phone,  String? email,  String? deliveryInstructions,  bool isBusinessAddress,  bool isDefault,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryAddress() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.company,_that.addressLine1,_that.addressLine2,_that.city,_that.postalCode,_that.countryCode,_that.countryName,_that.state,_that.phone,_that.email,_that.deliveryInstructions,_that.isBusinessAddress,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryAddress implements DeliveryAddress {
  const _DeliveryAddress({this.id, required this.firstName, required this.lastName, this.company, required this.addressLine1, this.addressLine2, required this.city, required this.postalCode, required this.countryCode, required this.countryName, this.state, this.phone, this.email, this.deliveryInstructions, this.isBusinessAddress = false, this.isDefault = false, this.createdAt, this.updatedAt});
  factory _DeliveryAddress.fromJson(Map<String, dynamic> json) => _$DeliveryAddressFromJson(json);

@override final  String? id;
// Optional für gespeicherte Adressen
// Persönliche Daten
@override final  String firstName;
@override final  String lastName;
@override final  String? company;
// Optional für Firmenadressen
// Adressdaten
@override final  String addressLine1;
@override final  String? addressLine2;
@override final  String city;
@override final  String postalCode;
@override final  String countryCode;
// ISO 3166-1 alpha-2
@override final  String countryName;
@override final  String? state;
// Für USA, Australien, etc.
// Kontaktdaten
@override final  String? phone;
@override final  String? email;
// Zusatzinformationen
@override final  String? deliveryInstructions;
@override@JsonKey() final  bool isBusinessAddress;
@override@JsonKey() final  bool isDefault;
// Standardadresse des Users
// System Fields
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryAddressCopyWith<_DeliveryAddress> get copyWith => __$DeliveryAddressCopyWithImpl<_DeliveryAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryAddress&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.company, company) || other.company == company)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.state, state) || other.state == state)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.deliveryInstructions, deliveryInstructions) || other.deliveryInstructions == deliveryInstructions)&&(identical(other.isBusinessAddress, isBusinessAddress) || other.isBusinessAddress == isBusinessAddress)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,company,addressLine1,addressLine2,city,postalCode,countryCode,countryName,state,phone,email,deliveryInstructions,isBusinessAddress,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'DeliveryAddress(id: $id, firstName: $firstName, lastName: $lastName, company: $company, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, postalCode: $postalCode, countryCode: $countryCode, countryName: $countryName, state: $state, phone: $phone, email: $email, deliveryInstructions: $deliveryInstructions, isBusinessAddress: $isBusinessAddress, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DeliveryAddressCopyWith<$Res> implements $DeliveryAddressCopyWith<$Res> {
  factory _$DeliveryAddressCopyWith(_DeliveryAddress value, $Res Function(_DeliveryAddress) _then) = __$DeliveryAddressCopyWithImpl;
@override @useResult
$Res call({
 String? id, String firstName, String lastName, String? company, String addressLine1, String? addressLine2, String city, String postalCode, String countryCode, String countryName, String? state, String? phone, String? email, String? deliveryInstructions, bool isBusinessAddress, bool isDefault, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$DeliveryAddressCopyWithImpl<$Res>
    implements _$DeliveryAddressCopyWith<$Res> {
  __$DeliveryAddressCopyWithImpl(this._self, this._then);

  final _DeliveryAddress _self;
  final $Res Function(_DeliveryAddress) _then;

/// Create a copy of DeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? firstName = null,Object? lastName = null,Object? company = freezed,Object? addressLine1 = null,Object? addressLine2 = freezed,Object? city = null,Object? postalCode = null,Object? countryCode = null,Object? countryName = null,Object? state = freezed,Object? phone = freezed,Object? email = freezed,Object? deliveryInstructions = freezed,Object? isBusinessAddress = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_DeliveryAddress(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: null == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,deliveryInstructions: freezed == deliveryInstructions ? _self.deliveryInstructions : deliveryInstructions // ignore: cast_nullable_to_non_nullable
as String?,isBusinessAddress: null == isBusinessAddress ? _self.isBusinessAddress : isBusinessAddress // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$AddressValidationResult {

 bool get isValid; List<String> get errors;
/// Create a copy of AddressValidationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressValidationResultCopyWith<AddressValidationResult> get copyWith => _$AddressValidationResultCopyWithImpl<AddressValidationResult>(this as AddressValidationResult, _$identity);

  /// Serializes this AddressValidationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressValidationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other.errors, errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'AddressValidationResult(isValid: $isValid, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $AddressValidationResultCopyWith<$Res>  {
  factory $AddressValidationResultCopyWith(AddressValidationResult value, $Res Function(AddressValidationResult) _then) = _$AddressValidationResultCopyWithImpl;
@useResult
$Res call({
 bool isValid, List<String> errors
});




}
/// @nodoc
class _$AddressValidationResultCopyWithImpl<$Res>
    implements $AddressValidationResultCopyWith<$Res> {
  _$AddressValidationResultCopyWithImpl(this._self, this._then);

  final AddressValidationResult _self;
  final $Res Function(AddressValidationResult) _then;

/// Create a copy of AddressValidationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isValid = null,Object? errors = null,}) {
  return _then(_self.copyWith(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressValidationResult].
extension AddressValidationResultPatterns on AddressValidationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressValidationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressValidationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressValidationResult value)  $default,){
final _that = this;
switch (_that) {
case _AddressValidationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressValidationResult value)?  $default,){
final _that = this;
switch (_that) {
case _AddressValidationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isValid,  List<String> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressValidationResult() when $default != null:
return $default(_that.isValid,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isValid,  List<String> errors)  $default,) {final _that = this;
switch (_that) {
case _AddressValidationResult():
return $default(_that.isValid,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isValid,  List<String> errors)?  $default,) {final _that = this;
switch (_that) {
case _AddressValidationResult() when $default != null:
return $default(_that.isValid,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressValidationResult implements AddressValidationResult {
  const _AddressValidationResult({required this.isValid, final  List<String> errors = const []}): _errors = errors;
  factory _AddressValidationResult.fromJson(Map<String, dynamic> json) => _$AddressValidationResultFromJson(json);

@override final  bool isValid;
 final  List<String> _errors;
@override@JsonKey() List<String> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of AddressValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressValidationResultCopyWith<_AddressValidationResult> get copyWith => __$AddressValidationResultCopyWithImpl<_AddressValidationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressValidationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressValidationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&const DeepCollectionEquality().equals(other._errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'AddressValidationResult(isValid: $isValid, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$AddressValidationResultCopyWith<$Res> implements $AddressValidationResultCopyWith<$Res> {
  factory _$AddressValidationResultCopyWith(_AddressValidationResult value, $Res Function(_AddressValidationResult) _then) = __$AddressValidationResultCopyWithImpl;
@override @useResult
$Res call({
 bool isValid, List<String> errors
});




}
/// @nodoc
class __$AddressValidationResultCopyWithImpl<$Res>
    implements _$AddressValidationResultCopyWith<$Res> {
  __$AddressValidationResultCopyWithImpl(this._self, this._then);

  final _AddressValidationResult _self;
  final $Res Function(_AddressValidationResult) _then;

/// Create a copy of AddressValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isValid = null,Object? errors = null,}) {
  return _then(_AddressValidationResult(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ShippingCostResult {

 double get cost; bool get isFreeShipping; String get serviceName; int? get estimatedDaysMin; int? get estimatedDaysMax; String? get region; String? get description; bool get trackingAvailable; bool get signatureRequired;
/// Create a copy of ShippingCostResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShippingCostResultCopyWith<ShippingCostResult> get copyWith => _$ShippingCostResultCopyWithImpl<ShippingCostResult>(this as ShippingCostResult, _$identity);

  /// Serializes this ShippingCostResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShippingCostResult&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.isFreeShipping, isFreeShipping) || other.isFreeShipping == isFreeShipping)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.estimatedDaysMin, estimatedDaysMin) || other.estimatedDaysMin == estimatedDaysMin)&&(identical(other.estimatedDaysMax, estimatedDaysMax) || other.estimatedDaysMax == estimatedDaysMax)&&(identical(other.region, region) || other.region == region)&&(identical(other.description, description) || other.description == description)&&(identical(other.trackingAvailable, trackingAvailable) || other.trackingAvailable == trackingAvailable)&&(identical(other.signatureRequired, signatureRequired) || other.signatureRequired == signatureRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cost,isFreeShipping,serviceName,estimatedDaysMin,estimatedDaysMax,region,description,trackingAvailable,signatureRequired);

@override
String toString() {
  return 'ShippingCostResult(cost: $cost, isFreeShipping: $isFreeShipping, serviceName: $serviceName, estimatedDaysMin: $estimatedDaysMin, estimatedDaysMax: $estimatedDaysMax, region: $region, description: $description, trackingAvailable: $trackingAvailable, signatureRequired: $signatureRequired)';
}


}

/// @nodoc
abstract mixin class $ShippingCostResultCopyWith<$Res>  {
  factory $ShippingCostResultCopyWith(ShippingCostResult value, $Res Function(ShippingCostResult) _then) = _$ShippingCostResultCopyWithImpl;
@useResult
$Res call({
 double cost, bool isFreeShipping, String serviceName, int? estimatedDaysMin, int? estimatedDaysMax, String? region, String? description, bool trackingAvailable, bool signatureRequired
});




}
/// @nodoc
class _$ShippingCostResultCopyWithImpl<$Res>
    implements $ShippingCostResultCopyWith<$Res> {
  _$ShippingCostResultCopyWithImpl(this._self, this._then);

  final ShippingCostResult _self;
  final $Res Function(ShippingCostResult) _then;

/// Create a copy of ShippingCostResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cost = null,Object? isFreeShipping = null,Object? serviceName = null,Object? estimatedDaysMin = freezed,Object? estimatedDaysMax = freezed,Object? region = freezed,Object? description = freezed,Object? trackingAvailable = null,Object? signatureRequired = null,}) {
  return _then(_self.copyWith(
cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,isFreeShipping: null == isFreeShipping ? _self.isFreeShipping : isFreeShipping // ignore: cast_nullable_to_non_nullable
as bool,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,estimatedDaysMin: freezed == estimatedDaysMin ? _self.estimatedDaysMin : estimatedDaysMin // ignore: cast_nullable_to_non_nullable
as int?,estimatedDaysMax: freezed == estimatedDaysMax ? _self.estimatedDaysMax : estimatedDaysMax // ignore: cast_nullable_to_non_nullable
as int?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,trackingAvailable: null == trackingAvailable ? _self.trackingAvailable : trackingAvailable // ignore: cast_nullable_to_non_nullable
as bool,signatureRequired: null == signatureRequired ? _self.signatureRequired : signatureRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShippingCostResult].
extension ShippingCostResultPatterns on ShippingCostResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShippingCostResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShippingCostResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShippingCostResult value)  $default,){
final _that = this;
switch (_that) {
case _ShippingCostResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShippingCostResult value)?  $default,){
final _that = this;
switch (_that) {
case _ShippingCostResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double cost,  bool isFreeShipping,  String serviceName,  int? estimatedDaysMin,  int? estimatedDaysMax,  String? region,  String? description,  bool trackingAvailable,  bool signatureRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShippingCostResult() when $default != null:
return $default(_that.cost,_that.isFreeShipping,_that.serviceName,_that.estimatedDaysMin,_that.estimatedDaysMax,_that.region,_that.description,_that.trackingAvailable,_that.signatureRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double cost,  bool isFreeShipping,  String serviceName,  int? estimatedDaysMin,  int? estimatedDaysMax,  String? region,  String? description,  bool trackingAvailable,  bool signatureRequired)  $default,) {final _that = this;
switch (_that) {
case _ShippingCostResult():
return $default(_that.cost,_that.isFreeShipping,_that.serviceName,_that.estimatedDaysMin,_that.estimatedDaysMax,_that.region,_that.description,_that.trackingAvailable,_that.signatureRequired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double cost,  bool isFreeShipping,  String serviceName,  int? estimatedDaysMin,  int? estimatedDaysMax,  String? region,  String? description,  bool trackingAvailable,  bool signatureRequired)?  $default,) {final _that = this;
switch (_that) {
case _ShippingCostResult() when $default != null:
return $default(_that.cost,_that.isFreeShipping,_that.serviceName,_that.estimatedDaysMin,_that.estimatedDaysMax,_that.region,_that.description,_that.trackingAvailable,_that.signatureRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShippingCostResult implements ShippingCostResult {
  const _ShippingCostResult({required this.cost, required this.isFreeShipping, required this.serviceName, this.estimatedDaysMin, this.estimatedDaysMax, this.region, this.description, this.trackingAvailable = true, this.signatureRequired = false});
  factory _ShippingCostResult.fromJson(Map<String, dynamic> json) => _$ShippingCostResultFromJson(json);

@override final  double cost;
@override final  bool isFreeShipping;
@override final  String serviceName;
@override final  int? estimatedDaysMin;
@override final  int? estimatedDaysMax;
@override final  String? region;
@override final  String? description;
@override@JsonKey() final  bool trackingAvailable;
@override@JsonKey() final  bool signatureRequired;

/// Create a copy of ShippingCostResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShippingCostResultCopyWith<_ShippingCostResult> get copyWith => __$ShippingCostResultCopyWithImpl<_ShippingCostResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShippingCostResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShippingCostResult&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.isFreeShipping, isFreeShipping) || other.isFreeShipping == isFreeShipping)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.estimatedDaysMin, estimatedDaysMin) || other.estimatedDaysMin == estimatedDaysMin)&&(identical(other.estimatedDaysMax, estimatedDaysMax) || other.estimatedDaysMax == estimatedDaysMax)&&(identical(other.region, region) || other.region == region)&&(identical(other.description, description) || other.description == description)&&(identical(other.trackingAvailable, trackingAvailable) || other.trackingAvailable == trackingAvailable)&&(identical(other.signatureRequired, signatureRequired) || other.signatureRequired == signatureRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cost,isFreeShipping,serviceName,estimatedDaysMin,estimatedDaysMax,region,description,trackingAvailable,signatureRequired);

@override
String toString() {
  return 'ShippingCostResult(cost: $cost, isFreeShipping: $isFreeShipping, serviceName: $serviceName, estimatedDaysMin: $estimatedDaysMin, estimatedDaysMax: $estimatedDaysMax, region: $region, description: $description, trackingAvailable: $trackingAvailable, signatureRequired: $signatureRequired)';
}


}

/// @nodoc
abstract mixin class _$ShippingCostResultCopyWith<$Res> implements $ShippingCostResultCopyWith<$Res> {
  factory _$ShippingCostResultCopyWith(_ShippingCostResult value, $Res Function(_ShippingCostResult) _then) = __$ShippingCostResultCopyWithImpl;
@override @useResult
$Res call({
 double cost, bool isFreeShipping, String serviceName, int? estimatedDaysMin, int? estimatedDaysMax, String? region, String? description, bool trackingAvailable, bool signatureRequired
});




}
/// @nodoc
class __$ShippingCostResultCopyWithImpl<$Res>
    implements _$ShippingCostResultCopyWith<$Res> {
  __$ShippingCostResultCopyWithImpl(this._self, this._then);

  final _ShippingCostResult _self;
  final $Res Function(_ShippingCostResult) _then;

/// Create a copy of ShippingCostResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cost = null,Object? isFreeShipping = null,Object? serviceName = null,Object? estimatedDaysMin = freezed,Object? estimatedDaysMax = freezed,Object? region = freezed,Object? description = freezed,Object? trackingAvailable = null,Object? signatureRequired = null,}) {
  return _then(_ShippingCostResult(
cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,isFreeShipping: null == isFreeShipping ? _self.isFreeShipping : isFreeShipping // ignore: cast_nullable_to_non_nullable
as bool,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,estimatedDaysMin: freezed == estimatedDaysMin ? _self.estimatedDaysMin : estimatedDaysMin // ignore: cast_nullable_to_non_nullable
as int?,estimatedDaysMax: freezed == estimatedDaysMax ? _self.estimatedDaysMax : estimatedDaysMax // ignore: cast_nullable_to_non_nullable
as int?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,trackingAvailable: null == trackingAvailable ? _self.trackingAvailable : trackingAvailable // ignore: cast_nullable_to_non_nullable
as bool,signatureRequired: null == signatureRequired ? _self.signatureRequired : signatureRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
