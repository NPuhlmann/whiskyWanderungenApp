// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_intent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentIntent {

 String get id; String get clientSecret; int get amount; String get currency; String get status; List<PaymentMethodType> get paymentMethodTypes; String? get description; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get confirmedAt; String? get receiptEmail; String? get customerId; String? get paymentMethodId; String? get lastPaymentError;
/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentIntentCopyWith<PaymentIntent> get copyWith => _$PaymentIntentCopyWithImpl<PaymentIntent>(this as PaymentIntent, _$identity);

  /// Serializes this PaymentIntent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentIntent&&(identical(other.id, id) || other.id == id)&&(identical(other.clientSecret, clientSecret) || other.clientSecret == clientSecret)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.paymentMethodTypes, paymentMethodTypes)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.receiptEmail, receiptEmail) || other.receiptEmail == receiptEmail)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.lastPaymentError, lastPaymentError) || other.lastPaymentError == lastPaymentError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientSecret,amount,currency,status,const DeepCollectionEquality().hash(paymentMethodTypes),description,const DeepCollectionEquality().hash(metadata),createdAt,confirmedAt,receiptEmail,customerId,paymentMethodId,lastPaymentError);

@override
String toString() {
  return 'PaymentIntent(id: $id, clientSecret: $clientSecret, amount: $amount, currency: $currency, status: $status, paymentMethodTypes: $paymentMethodTypes, description: $description, metadata: $metadata, createdAt: $createdAt, confirmedAt: $confirmedAt, receiptEmail: $receiptEmail, customerId: $customerId, paymentMethodId: $paymentMethodId, lastPaymentError: $lastPaymentError)';
}


}

/// @nodoc
abstract mixin class $PaymentIntentCopyWith<$Res>  {
  factory $PaymentIntentCopyWith(PaymentIntent value, $Res Function(PaymentIntent) _then) = _$PaymentIntentCopyWithImpl;
@useResult
$Res call({
 String id, String clientSecret, int amount, String currency, String status, List<PaymentMethodType> paymentMethodTypes, String? description, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? confirmedAt, String? receiptEmail, String? customerId, String? paymentMethodId, String? lastPaymentError
});




}
/// @nodoc
class _$PaymentIntentCopyWithImpl<$Res>
    implements $PaymentIntentCopyWith<$Res> {
  _$PaymentIntentCopyWithImpl(this._self, this._then);

  final PaymentIntent _self;
  final $Res Function(PaymentIntent) _then;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clientSecret = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paymentMethodTypes = null,Object? description = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? confirmedAt = freezed,Object? receiptEmail = freezed,Object? customerId = freezed,Object? paymentMethodId = freezed,Object? lastPaymentError = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientSecret: null == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentMethodTypes: null == paymentMethodTypes ? _self.paymentMethodTypes : paymentMethodTypes // ignore: cast_nullable_to_non_nullable
as List<PaymentMethodType>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receiptEmail: freezed == receiptEmail ? _self.receiptEmail : receiptEmail // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,lastPaymentError: freezed == lastPaymentError ? _self.lastPaymentError : lastPaymentError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentIntent].
extension PaymentIntentPatterns on PaymentIntent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentIntent value)  $default,){
final _that = this;
switch (_that) {
case _PaymentIntent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentIntent value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String clientSecret,  int amount,  String currency,  String status,  List<PaymentMethodType> paymentMethodTypes,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? confirmedAt,  String? receiptEmail,  String? customerId,  String? paymentMethodId,  String? lastPaymentError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that.id,_that.clientSecret,_that.amount,_that.currency,_that.status,_that.paymentMethodTypes,_that.description,_that.metadata,_that.createdAt,_that.confirmedAt,_that.receiptEmail,_that.customerId,_that.paymentMethodId,_that.lastPaymentError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String clientSecret,  int amount,  String currency,  String status,  List<PaymentMethodType> paymentMethodTypes,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? confirmedAt,  String? receiptEmail,  String? customerId,  String? paymentMethodId,  String? lastPaymentError)  $default,) {final _that = this;
switch (_that) {
case _PaymentIntent():
return $default(_that.id,_that.clientSecret,_that.amount,_that.currency,_that.status,_that.paymentMethodTypes,_that.description,_that.metadata,_that.createdAt,_that.confirmedAt,_that.receiptEmail,_that.customerId,_that.paymentMethodId,_that.lastPaymentError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String clientSecret,  int amount,  String currency,  String status,  List<PaymentMethodType> paymentMethodTypes,  String? description,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? confirmedAt,  String? receiptEmail,  String? customerId,  String? paymentMethodId,  String? lastPaymentError)?  $default,) {final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that.id,_that.clientSecret,_that.amount,_that.currency,_that.status,_that.paymentMethodTypes,_that.description,_that.metadata,_that.createdAt,_that.confirmedAt,_that.receiptEmail,_that.customerId,_that.paymentMethodId,_that.lastPaymentError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentIntent implements PaymentIntent {
  const _PaymentIntent({required this.id, required this.clientSecret, required this.amount, required this.currency, required this.status, final  List<PaymentMethodType> paymentMethodTypes = const [], this.description, final  Map<String, dynamic>? metadata, this.createdAt, this.confirmedAt, this.receiptEmail, this.customerId, this.paymentMethodId, this.lastPaymentError}): _paymentMethodTypes = paymentMethodTypes,_metadata = metadata;
  factory _PaymentIntent.fromJson(Map<String, dynamic> json) => _$PaymentIntentFromJson(json);

@override final  String id;
@override final  String clientSecret;
@override final  int amount;
@override final  String currency;
@override final  String status;
 final  List<PaymentMethodType> _paymentMethodTypes;
@override@JsonKey() List<PaymentMethodType> get paymentMethodTypes {
  if (_paymentMethodTypes is EqualUnmodifiableListView) return _paymentMethodTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paymentMethodTypes);
}

@override final  String? description;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? confirmedAt;
@override final  String? receiptEmail;
@override final  String? customerId;
@override final  String? paymentMethodId;
@override final  String? lastPaymentError;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentIntentCopyWith<_PaymentIntent> get copyWith => __$PaymentIntentCopyWithImpl<_PaymentIntent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentIntentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentIntent&&(identical(other.id, id) || other.id == id)&&(identical(other.clientSecret, clientSecret) || other.clientSecret == clientSecret)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._paymentMethodTypes, _paymentMethodTypes)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.receiptEmail, receiptEmail) || other.receiptEmail == receiptEmail)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.lastPaymentError, lastPaymentError) || other.lastPaymentError == lastPaymentError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientSecret,amount,currency,status,const DeepCollectionEquality().hash(_paymentMethodTypes),description,const DeepCollectionEquality().hash(_metadata),createdAt,confirmedAt,receiptEmail,customerId,paymentMethodId,lastPaymentError);

@override
String toString() {
  return 'PaymentIntent(id: $id, clientSecret: $clientSecret, amount: $amount, currency: $currency, status: $status, paymentMethodTypes: $paymentMethodTypes, description: $description, metadata: $metadata, createdAt: $createdAt, confirmedAt: $confirmedAt, receiptEmail: $receiptEmail, customerId: $customerId, paymentMethodId: $paymentMethodId, lastPaymentError: $lastPaymentError)';
}


}

/// @nodoc
abstract mixin class _$PaymentIntentCopyWith<$Res> implements $PaymentIntentCopyWith<$Res> {
  factory _$PaymentIntentCopyWith(_PaymentIntent value, $Res Function(_PaymentIntent) _then) = __$PaymentIntentCopyWithImpl;
@override @useResult
$Res call({
 String id, String clientSecret, int amount, String currency, String status, List<PaymentMethodType> paymentMethodTypes, String? description, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? confirmedAt, String? receiptEmail, String? customerId, String? paymentMethodId, String? lastPaymentError
});




}
/// @nodoc
class __$PaymentIntentCopyWithImpl<$Res>
    implements _$PaymentIntentCopyWith<$Res> {
  __$PaymentIntentCopyWithImpl(this._self, this._then);

  final _PaymentIntent _self;
  final $Res Function(_PaymentIntent) _then;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clientSecret = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paymentMethodTypes = null,Object? description = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? confirmedAt = freezed,Object? receiptEmail = freezed,Object? customerId = freezed,Object? paymentMethodId = freezed,Object? lastPaymentError = freezed,}) {
  return _then(_PaymentIntent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientSecret: null == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentMethodTypes: null == paymentMethodTypes ? _self._paymentMethodTypes : paymentMethodTypes // ignore: cast_nullable_to_non_nullable
as List<PaymentMethodType>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receiptEmail: freezed == receiptEmail ? _self.receiptEmail : receiptEmail // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,lastPaymentError: freezed == lastPaymentError ? _self.lastPaymentError : lastPaymentError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CardDetails {

 String get number; int get expMonth; int get expYear; String get cvc; String? get name;@JsonKey(name: 'address_line1') String? get addressLine1;@JsonKey(name: 'address_line2') String? get addressLine2;@JsonKey(name: 'address_city') String? get addressCity;@JsonKey(name: 'address_state') String? get addressState;@JsonKey(name: 'address_zip') String? get addressZip;@JsonKey(name: 'address_country') String? get addressCountry;
/// Create a copy of CardDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardDetailsCopyWith<CardDetails> get copyWith => _$CardDetailsCopyWithImpl<CardDetails>(this as CardDetails, _$identity);

  /// Serializes this CardDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardDetails&&(identical(other.number, number) || other.number == number)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear)&&(identical(other.cvc, cvc) || other.cvc == cvc)&&(identical(other.name, name) || other.name == name)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.addressCity, addressCity) || other.addressCity == addressCity)&&(identical(other.addressState, addressState) || other.addressState == addressState)&&(identical(other.addressZip, addressZip) || other.addressZip == addressZip)&&(identical(other.addressCountry, addressCountry) || other.addressCountry == addressCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,expMonth,expYear,cvc,name,addressLine1,addressLine2,addressCity,addressState,addressZip,addressCountry);

@override
String toString() {
  return 'CardDetails(number: $number, expMonth: $expMonth, expYear: $expYear, cvc: $cvc, name: $name, addressLine1: $addressLine1, addressLine2: $addressLine2, addressCity: $addressCity, addressState: $addressState, addressZip: $addressZip, addressCountry: $addressCountry)';
}


}

/// @nodoc
abstract mixin class $CardDetailsCopyWith<$Res>  {
  factory $CardDetailsCopyWith(CardDetails value, $Res Function(CardDetails) _then) = _$CardDetailsCopyWithImpl;
@useResult
$Res call({
 String number, int expMonth, int expYear, String cvc, String? name,@JsonKey(name: 'address_line1') String? addressLine1,@JsonKey(name: 'address_line2') String? addressLine2,@JsonKey(name: 'address_city') String? addressCity,@JsonKey(name: 'address_state') String? addressState,@JsonKey(name: 'address_zip') String? addressZip,@JsonKey(name: 'address_country') String? addressCountry
});




}
/// @nodoc
class _$CardDetailsCopyWithImpl<$Res>
    implements $CardDetailsCopyWith<$Res> {
  _$CardDetailsCopyWithImpl(this._self, this._then);

  final CardDetails _self;
  final $Res Function(CardDetails) _then;

/// Create a copy of CardDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? expMonth = null,Object? expYear = null,Object? cvc = null,Object? name = freezed,Object? addressLine1 = freezed,Object? addressLine2 = freezed,Object? addressCity = freezed,Object? addressState = freezed,Object? addressZip = freezed,Object? addressCountry = freezed,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,cvc: null == cvc ? _self.cvc : cvc // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,addressCity: freezed == addressCity ? _self.addressCity : addressCity // ignore: cast_nullable_to_non_nullable
as String?,addressState: freezed == addressState ? _self.addressState : addressState // ignore: cast_nullable_to_non_nullable
as String?,addressZip: freezed == addressZip ? _self.addressZip : addressZip // ignore: cast_nullable_to_non_nullable
as String?,addressCountry: freezed == addressCountry ? _self.addressCountry : addressCountry // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardDetails].
extension CardDetailsPatterns on CardDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardDetails value)  $default,){
final _that = this;
switch (_that) {
case _CardDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardDetails value)?  $default,){
final _that = this;
switch (_that) {
case _CardDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String number,  int expMonth,  int expYear,  String cvc,  String? name, @JsonKey(name: 'address_line1')  String? addressLine1, @JsonKey(name: 'address_line2')  String? addressLine2, @JsonKey(name: 'address_city')  String? addressCity, @JsonKey(name: 'address_state')  String? addressState, @JsonKey(name: 'address_zip')  String? addressZip, @JsonKey(name: 'address_country')  String? addressCountry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardDetails() when $default != null:
return $default(_that.number,_that.expMonth,_that.expYear,_that.cvc,_that.name,_that.addressLine1,_that.addressLine2,_that.addressCity,_that.addressState,_that.addressZip,_that.addressCountry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String number,  int expMonth,  int expYear,  String cvc,  String? name, @JsonKey(name: 'address_line1')  String? addressLine1, @JsonKey(name: 'address_line2')  String? addressLine2, @JsonKey(name: 'address_city')  String? addressCity, @JsonKey(name: 'address_state')  String? addressState, @JsonKey(name: 'address_zip')  String? addressZip, @JsonKey(name: 'address_country')  String? addressCountry)  $default,) {final _that = this;
switch (_that) {
case _CardDetails():
return $default(_that.number,_that.expMonth,_that.expYear,_that.cvc,_that.name,_that.addressLine1,_that.addressLine2,_that.addressCity,_that.addressState,_that.addressZip,_that.addressCountry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String number,  int expMonth,  int expYear,  String cvc,  String? name, @JsonKey(name: 'address_line1')  String? addressLine1, @JsonKey(name: 'address_line2')  String? addressLine2, @JsonKey(name: 'address_city')  String? addressCity, @JsonKey(name: 'address_state')  String? addressState, @JsonKey(name: 'address_zip')  String? addressZip, @JsonKey(name: 'address_country')  String? addressCountry)?  $default,) {final _that = this;
switch (_that) {
case _CardDetails() when $default != null:
return $default(_that.number,_that.expMonth,_that.expYear,_that.cvc,_that.name,_that.addressLine1,_that.addressLine2,_that.addressCity,_that.addressState,_that.addressZip,_that.addressCountry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardDetails implements CardDetails {
  const _CardDetails({required this.number, required this.expMonth, required this.expYear, required this.cvc, this.name, @JsonKey(name: 'address_line1') this.addressLine1, @JsonKey(name: 'address_line2') this.addressLine2, @JsonKey(name: 'address_city') this.addressCity, @JsonKey(name: 'address_state') this.addressState, @JsonKey(name: 'address_zip') this.addressZip, @JsonKey(name: 'address_country') this.addressCountry});
  factory _CardDetails.fromJson(Map<String, dynamic> json) => _$CardDetailsFromJson(json);

@override final  String number;
@override final  int expMonth;
@override final  int expYear;
@override final  String cvc;
@override final  String? name;
@override@JsonKey(name: 'address_line1') final  String? addressLine1;
@override@JsonKey(name: 'address_line2') final  String? addressLine2;
@override@JsonKey(name: 'address_city') final  String? addressCity;
@override@JsonKey(name: 'address_state') final  String? addressState;
@override@JsonKey(name: 'address_zip') final  String? addressZip;
@override@JsonKey(name: 'address_country') final  String? addressCountry;

/// Create a copy of CardDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardDetailsCopyWith<_CardDetails> get copyWith => __$CardDetailsCopyWithImpl<_CardDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardDetails&&(identical(other.number, number) || other.number == number)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear)&&(identical(other.cvc, cvc) || other.cvc == cvc)&&(identical(other.name, name) || other.name == name)&&(identical(other.addressLine1, addressLine1) || other.addressLine1 == addressLine1)&&(identical(other.addressLine2, addressLine2) || other.addressLine2 == addressLine2)&&(identical(other.addressCity, addressCity) || other.addressCity == addressCity)&&(identical(other.addressState, addressState) || other.addressState == addressState)&&(identical(other.addressZip, addressZip) || other.addressZip == addressZip)&&(identical(other.addressCountry, addressCountry) || other.addressCountry == addressCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,expMonth,expYear,cvc,name,addressLine1,addressLine2,addressCity,addressState,addressZip,addressCountry);

@override
String toString() {
  return 'CardDetails(number: $number, expMonth: $expMonth, expYear: $expYear, cvc: $cvc, name: $name, addressLine1: $addressLine1, addressLine2: $addressLine2, addressCity: $addressCity, addressState: $addressState, addressZip: $addressZip, addressCountry: $addressCountry)';
}


}

/// @nodoc
abstract mixin class _$CardDetailsCopyWith<$Res> implements $CardDetailsCopyWith<$Res> {
  factory _$CardDetailsCopyWith(_CardDetails value, $Res Function(_CardDetails) _then) = __$CardDetailsCopyWithImpl;
@override @useResult
$Res call({
 String number, int expMonth, int expYear, String cvc, String? name,@JsonKey(name: 'address_line1') String? addressLine1,@JsonKey(name: 'address_line2') String? addressLine2,@JsonKey(name: 'address_city') String? addressCity,@JsonKey(name: 'address_state') String? addressState,@JsonKey(name: 'address_zip') String? addressZip,@JsonKey(name: 'address_country') String? addressCountry
});




}
/// @nodoc
class __$CardDetailsCopyWithImpl<$Res>
    implements _$CardDetailsCopyWith<$Res> {
  __$CardDetailsCopyWithImpl(this._self, this._then);

  final _CardDetails _self;
  final $Res Function(_CardDetails) _then;

/// Create a copy of CardDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? expMonth = null,Object? expYear = null,Object? cvc = null,Object? name = freezed,Object? addressLine1 = freezed,Object? addressLine2 = freezed,Object? addressCity = freezed,Object? addressState = freezed,Object? addressZip = freezed,Object? addressCountry = freezed,}) {
  return _then(_CardDetails(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,cvc: null == cvc ? _self.cvc : cvc // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,addressLine1: freezed == addressLine1 ? _self.addressLine1 : addressLine1 // ignore: cast_nullable_to_non_nullable
as String?,addressLine2: freezed == addressLine2 ? _self.addressLine2 : addressLine2 // ignore: cast_nullable_to_non_nullable
as String?,addressCity: freezed == addressCity ? _self.addressCity : addressCity // ignore: cast_nullable_to_non_nullable
as String?,addressState: freezed == addressState ? _self.addressState : addressState // ignore: cast_nullable_to_non_nullable
as String?,addressZip: freezed == addressZip ? _self.addressZip : addressZip // ignore: cast_nullable_to_non_nullable
as String?,addressCountry: freezed == addressCountry ? _self.addressCountry : addressCountry // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PaymentMethodParams {

 PaymentMethodType get type; CardDetails? get card;@JsonKey(name: 'billing_details') BillingDetails? get billingDetails; Map<String, dynamic>? get metadata;
/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodParamsCopyWith<PaymentMethodParams> get copyWith => _$PaymentMethodParamsCopyWithImpl<PaymentMethodParams>(this as PaymentMethodParams, _$identity);

  /// Serializes this PaymentMethodParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodParams&&(identical(other.type, type) || other.type == type)&&(identical(other.card, card) || other.card == card)&&(identical(other.billingDetails, billingDetails) || other.billingDetails == billingDetails)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,card,billingDetails,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'PaymentMethodParams(type: $type, card: $card, billingDetails: $billingDetails, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PaymentMethodParamsCopyWith<$Res>  {
  factory $PaymentMethodParamsCopyWith(PaymentMethodParams value, $Res Function(PaymentMethodParams) _then) = _$PaymentMethodParamsCopyWithImpl;
@useResult
$Res call({
 PaymentMethodType type, CardDetails? card,@JsonKey(name: 'billing_details') BillingDetails? billingDetails, Map<String, dynamic>? metadata
});


$CardDetailsCopyWith<$Res>? get card;$BillingDetailsCopyWith<$Res>? get billingDetails;

}
/// @nodoc
class _$PaymentMethodParamsCopyWithImpl<$Res>
    implements $PaymentMethodParamsCopyWith<$Res> {
  _$PaymentMethodParamsCopyWithImpl(this._self, this._then);

  final PaymentMethodParams _self;
  final $Res Function(PaymentMethodParams) _then;

/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? card = freezed,Object? billingDetails = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentMethodType,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as CardDetails?,billingDetails: freezed == billingDetails ? _self.billingDetails : billingDetails // ignore: cast_nullable_to_non_nullable
as BillingDetails?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDetailsCopyWith<$Res>? get card {
    if (_self.card == null) {
    return null;
  }

  return $CardDetailsCopyWith<$Res>(_self.card!, (value) {
    return _then(_self.copyWith(card: value));
  });
}/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingDetailsCopyWith<$Res>? get billingDetails {
    if (_self.billingDetails == null) {
    return null;
  }

  return $BillingDetailsCopyWith<$Res>(_self.billingDetails!, (value) {
    return _then(_self.copyWith(billingDetails: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentMethodParams].
extension PaymentMethodParamsPatterns on PaymentMethodParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethodParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethodParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethodParams value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethodParams value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentMethodType type,  CardDetails? card, @JsonKey(name: 'billing_details')  BillingDetails? billingDetails,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethodParams() when $default != null:
return $default(_that.type,_that.card,_that.billingDetails,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentMethodType type,  CardDetails? card, @JsonKey(name: 'billing_details')  BillingDetails? billingDetails,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodParams():
return $default(_that.type,_that.card,_that.billingDetails,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentMethodType type,  CardDetails? card, @JsonKey(name: 'billing_details')  BillingDetails? billingDetails,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodParams() when $default != null:
return $default(_that.type,_that.card,_that.billingDetails,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentMethodParams implements PaymentMethodParams {
  const _PaymentMethodParams({required this.type, this.card, @JsonKey(name: 'billing_details') this.billingDetails, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _PaymentMethodParams.fromJson(Map<String, dynamic> json) => _$PaymentMethodParamsFromJson(json);

@override final  PaymentMethodType type;
@override final  CardDetails? card;
@override@JsonKey(name: 'billing_details') final  BillingDetails? billingDetails;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodParamsCopyWith<_PaymentMethodParams> get copyWith => __$PaymentMethodParamsCopyWithImpl<_PaymentMethodParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentMethodParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethodParams&&(identical(other.type, type) || other.type == type)&&(identical(other.card, card) || other.card == card)&&(identical(other.billingDetails, billingDetails) || other.billingDetails == billingDetails)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,card,billingDetails,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PaymentMethodParams(type: $type, card: $card, billingDetails: $billingDetails, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodParamsCopyWith<$Res> implements $PaymentMethodParamsCopyWith<$Res> {
  factory _$PaymentMethodParamsCopyWith(_PaymentMethodParams value, $Res Function(_PaymentMethodParams) _then) = __$PaymentMethodParamsCopyWithImpl;
@override @useResult
$Res call({
 PaymentMethodType type, CardDetails? card,@JsonKey(name: 'billing_details') BillingDetails? billingDetails, Map<String, dynamic>? metadata
});


@override $CardDetailsCopyWith<$Res>? get card;@override $BillingDetailsCopyWith<$Res>? get billingDetails;

}
/// @nodoc
class __$PaymentMethodParamsCopyWithImpl<$Res>
    implements _$PaymentMethodParamsCopyWith<$Res> {
  __$PaymentMethodParamsCopyWithImpl(this._self, this._then);

  final _PaymentMethodParams _self;
  final $Res Function(_PaymentMethodParams) _then;

/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? card = freezed,Object? billingDetails = freezed,Object? metadata = freezed,}) {
  return _then(_PaymentMethodParams(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentMethodType,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as CardDetails?,billingDetails: freezed == billingDetails ? _self.billingDetails : billingDetails // ignore: cast_nullable_to_non_nullable
as BillingDetails?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardDetailsCopyWith<$Res>? get card {
    if (_self.card == null) {
    return null;
  }

  return $CardDetailsCopyWith<$Res>(_self.card!, (value) {
    return _then(_self.copyWith(card: value));
  });
}/// Create a copy of PaymentMethodParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingDetailsCopyWith<$Res>? get billingDetails {
    if (_self.billingDetails == null) {
    return null;
  }

  return $BillingDetailsCopyWith<$Res>(_self.billingDetails!, (value) {
    return _then(_self.copyWith(billingDetails: value));
  });
}
}


/// @nodoc
mixin _$BillingDetails {

 String? get name; String? get email; String? get phone; Address? get address;
/// Create a copy of BillingDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingDetailsCopyWith<BillingDetails> get copyWith => _$BillingDetailsCopyWithImpl<BillingDetails>(this as BillingDetails, _$identity);

  /// Serializes this BillingDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingDetails&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,address);

@override
String toString() {
  return 'BillingDetails(name: $name, email: $email, phone: $phone, address: $address)';
}


}

/// @nodoc
abstract mixin class $BillingDetailsCopyWith<$Res>  {
  factory $BillingDetailsCopyWith(BillingDetails value, $Res Function(BillingDetails) _then) = _$BillingDetailsCopyWithImpl;
@useResult
$Res call({
 String? name, String? email, String? phone, Address? address
});


$AddressCopyWith<$Res>? get address;

}
/// @nodoc
class _$BillingDetailsCopyWithImpl<$Res>
    implements $BillingDetailsCopyWith<$Res> {
  _$BillingDetailsCopyWithImpl(this._self, this._then);

  final BillingDetails _self;
  final $Res Function(BillingDetails) _then;

/// Create a copy of BillingDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? email = freezed,Object? phone = freezed,Object? address = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,
  ));
}
/// Create a copy of BillingDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [BillingDetails].
extension BillingDetailsPatterns on BillingDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingDetails value)  $default,){
final _that = this;
switch (_that) {
case _BillingDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingDetails value)?  $default,){
final _that = this;
switch (_that) {
case _BillingDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? email,  String? phone,  Address? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingDetails() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? email,  String? phone,  Address? address)  $default,) {final _that = this;
switch (_that) {
case _BillingDetails():
return $default(_that.name,_that.email,_that.phone,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? email,  String? phone,  Address? address)?  $default,) {final _that = this;
switch (_that) {
case _BillingDetails() when $default != null:
return $default(_that.name,_that.email,_that.phone,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillingDetails implements BillingDetails {
  const _BillingDetails({this.name, this.email, this.phone, this.address});
  factory _BillingDetails.fromJson(Map<String, dynamic> json) => _$BillingDetailsFromJson(json);

@override final  String? name;
@override final  String? email;
@override final  String? phone;
@override final  Address? address;

/// Create a copy of BillingDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingDetailsCopyWith<_BillingDetails> get copyWith => __$BillingDetailsCopyWithImpl<_BillingDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingDetails&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phone,address);

@override
String toString() {
  return 'BillingDetails(name: $name, email: $email, phone: $phone, address: $address)';
}


}

/// @nodoc
abstract mixin class _$BillingDetailsCopyWith<$Res> implements $BillingDetailsCopyWith<$Res> {
  factory _$BillingDetailsCopyWith(_BillingDetails value, $Res Function(_BillingDetails) _then) = __$BillingDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? email, String? phone, Address? address
});


@override $AddressCopyWith<$Res>? get address;

}
/// @nodoc
class __$BillingDetailsCopyWithImpl<$Res>
    implements _$BillingDetailsCopyWith<$Res> {
  __$BillingDetailsCopyWithImpl(this._self, this._then);

  final _BillingDetails _self;
  final $Res Function(_BillingDetails) _then;

/// Create a copy of BillingDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? email = freezed,Object? phone = freezed,Object? address = freezed,}) {
  return _then(_BillingDetails(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address?,
  ));
}

/// Create a copy of BillingDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// @nodoc
mixin _$Address {

@JsonKey(name: 'line1') String? get line1;@JsonKey(name: 'line2') String? get line2; String? get city; String? get state;@JsonKey(name: 'postal_code') String? get postalCode; String? get country;
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCopyWith<Address> get copyWith => _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Address&&(identical(other.line1, line1) || other.line1 == line1)&&(identical(other.line2, line2) || other.line2 == line2)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,line1,line2,city,state,postalCode,country);

@override
String toString() {
  return 'Address(line1: $line1, line2: $line2, city: $city, state: $state, postalCode: $postalCode, country: $country)';
}


}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res>  {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) = _$AddressCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'line1') String? line1,@JsonKey(name: 'line2') String? line2, String? city, String? state,@JsonKey(name: 'postal_code') String? postalCode, String? country
});




}
/// @nodoc
class _$AddressCopyWithImpl<$Res>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? line1 = freezed,Object? line2 = freezed,Object? city = freezed,Object? state = freezed,Object? postalCode = freezed,Object? country = freezed,}) {
  return _then(_self.copyWith(
line1: freezed == line1 ? _self.line1 : line1 // ignore: cast_nullable_to_non_nullable
as String?,line2: freezed == line2 ? _self.line2 : line2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Address].
extension AddressPatterns on Address {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Address value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Address value)  $default,){
final _that = this;
switch (_that) {
case _Address():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Address value)?  $default,){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'line1')  String? line1, @JsonKey(name: 'line2')  String? line2,  String? city,  String? state, @JsonKey(name: 'postal_code')  String? postalCode,  String? country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.line1,_that.line2,_that.city,_that.state,_that.postalCode,_that.country);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'line1')  String? line1, @JsonKey(name: 'line2')  String? line2,  String? city,  String? state, @JsonKey(name: 'postal_code')  String? postalCode,  String? country)  $default,) {final _that = this;
switch (_that) {
case _Address():
return $default(_that.line1,_that.line2,_that.city,_that.state,_that.postalCode,_that.country);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'line1')  String? line1, @JsonKey(name: 'line2')  String? line2,  String? city,  String? state, @JsonKey(name: 'postal_code')  String? postalCode,  String? country)?  $default,) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.line1,_that.line2,_that.city,_that.state,_that.postalCode,_that.country);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Address implements Address {
  const _Address({@JsonKey(name: 'line1') this.line1, @JsonKey(name: 'line2') this.line2, this.city, this.state, @JsonKey(name: 'postal_code') this.postalCode, this.country});
  factory _Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

@override@JsonKey(name: 'line1') final  String? line1;
@override@JsonKey(name: 'line2') final  String? line2;
@override final  String? city;
@override final  String? state;
@override@JsonKey(name: 'postal_code') final  String? postalCode;
@override final  String? country;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCopyWith<_Address> get copyWith => __$AddressCopyWithImpl<_Address>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Address&&(identical(other.line1, line1) || other.line1 == line1)&&(identical(other.line2, line2) || other.line2 == line2)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,line1,line2,city,state,postalCode,country);

@override
String toString() {
  return 'Address(line1: $line1, line2: $line2, city: $city, state: $state, postalCode: $postalCode, country: $country)';
}


}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) = __$AddressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'line1') String? line1,@JsonKey(name: 'line2') String? line2, String? city, String? state,@JsonKey(name: 'postal_code') String? postalCode, String? country
});




}
/// @nodoc
class __$AddressCopyWithImpl<$Res>
    implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? line1 = freezed,Object? line2 = freezed,Object? city = freezed,Object? state = freezed,Object? postalCode = freezed,Object? country = freezed,}) {
  return _then(_Address(
line1: freezed == line1 ? _self.line1 : line1 // ignore: cast_nullable_to_non_nullable
as String?,line2: freezed == line2 ? _self.line2 : line2 // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
