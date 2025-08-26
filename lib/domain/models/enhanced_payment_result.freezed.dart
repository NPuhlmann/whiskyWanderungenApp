// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enhanced_payment_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EnhancedPaymentResult {

 bool get isSuccess; EnhancedPaymentStatus get status;// Order Information
 EnhancedOrder? get order;// Payment Information
 String? get paymentIntentId; String? get clientSecret; String? get paymentMethodId; PaymentProvider? get paymentProvider;// Multi-Vendor Context
 String? get companyId; Company? get company;// Shipping Context
 ShippingCostResult? get shippingResult; DeliveryAddress? get deliveryAddress;// Error Information
 String? get errorMessage; String? get errorCode; PaymentErrorType? get errorType;// Financial Information
 double? get amount;// In Euros
 int? get amountInCents;// Stripe format
 String? get currency;// Metadata und Additional Info
 Map<String, dynamic> get metadata;// Timing Information
 DateTime? get createdAt; DateTime? get processedAt;// Customer Information (for context)
 String? get customerEmail; String? get customerId;// Next Actions (für requires_action status)
 PaymentNextAction? get nextAction;
/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnhancedPaymentResultCopyWith<EnhancedPaymentResult> get copyWith => _$EnhancedPaymentResultCopyWithImpl<EnhancedPaymentResult>(this as EnhancedPaymentResult, _$identity);

  /// Serializes this EnhancedPaymentResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnhancedPaymentResult&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.status, status) || other.status == status)&&(identical(other.order, order) || other.order == order)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.clientSecret, clientSecret) || other.clientSecret == clientSecret)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.shippingResult, shippingResult) || other.shippingResult == shippingResult)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processedAt, processedAt) || other.processedAt == processedAt)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,isSuccess,status,order,paymentIntentId,clientSecret,paymentMethodId,paymentProvider,companyId,company,shippingResult,deliveryAddress,errorMessage,errorCode,errorType,amount,amountInCents,currency,const DeepCollectionEquality().hash(metadata),createdAt,processedAt,customerEmail,customerId,nextAction]);

@override
String toString() {
  return 'EnhancedPaymentResult(isSuccess: $isSuccess, status: $status, order: $order, paymentIntentId: $paymentIntentId, clientSecret: $clientSecret, paymentMethodId: $paymentMethodId, paymentProvider: $paymentProvider, companyId: $companyId, company: $company, shippingResult: $shippingResult, deliveryAddress: $deliveryAddress, errorMessage: $errorMessage, errorCode: $errorCode, errorType: $errorType, amount: $amount, amountInCents: $amountInCents, currency: $currency, metadata: $metadata, createdAt: $createdAt, processedAt: $processedAt, customerEmail: $customerEmail, customerId: $customerId, nextAction: $nextAction)';
}


}

/// @nodoc
abstract mixin class $EnhancedPaymentResultCopyWith<$Res>  {
  factory $EnhancedPaymentResultCopyWith(EnhancedPaymentResult value, $Res Function(EnhancedPaymentResult) _then) = _$EnhancedPaymentResultCopyWithImpl;
@useResult
$Res call({
 bool isSuccess, EnhancedPaymentStatus status, EnhancedOrder? order, String? paymentIntentId, String? clientSecret, String? paymentMethodId, PaymentProvider? paymentProvider, String? companyId, Company? company, ShippingCostResult? shippingResult, DeliveryAddress? deliveryAddress, String? errorMessage, String? errorCode, PaymentErrorType? errorType, double? amount, int? amountInCents, String? currency, Map<String, dynamic> metadata, DateTime? createdAt, DateTime? processedAt, String? customerEmail, String? customerId, PaymentNextAction? nextAction
});


$EnhancedOrderCopyWith<$Res>? get order;$CompanyCopyWith<$Res>? get company;$ShippingCostResultCopyWith<$Res>? get shippingResult;$DeliveryAddressCopyWith<$Res>? get deliveryAddress;$PaymentNextActionCopyWith<$Res>? get nextAction;

}
/// @nodoc
class _$EnhancedPaymentResultCopyWithImpl<$Res>
    implements $EnhancedPaymentResultCopyWith<$Res> {
  _$EnhancedPaymentResultCopyWithImpl(this._self, this._then);

  final EnhancedPaymentResult _self;
  final $Res Function(EnhancedPaymentResult) _then;

/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSuccess = null,Object? status = null,Object? order = freezed,Object? paymentIntentId = freezed,Object? clientSecret = freezed,Object? paymentMethodId = freezed,Object? paymentProvider = freezed,Object? companyId = freezed,Object? company = freezed,Object? shippingResult = freezed,Object? deliveryAddress = freezed,Object? errorMessage = freezed,Object? errorCode = freezed,Object? errorType = freezed,Object? amount = freezed,Object? amountInCents = freezed,Object? currency = freezed,Object? metadata = null,Object? createdAt = freezed,Object? processedAt = freezed,Object? customerEmail = freezed,Object? customerId = freezed,Object? nextAction = freezed,}) {
  return _then(_self.copyWith(
isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnhancedPaymentStatus,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as EnhancedOrder?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,clientSecret: freezed == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as PaymentProvider?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,shippingResult: freezed == shippingResult ? _self.shippingResult : shippingResult // ignore: cast_nullable_to_non_nullable
as ShippingCostResult?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as PaymentErrorType?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,amountInCents: freezed == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,processedAt: freezed == processedAt ? _self.processedAt : processedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,nextAction: freezed == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as PaymentNextAction?,
  ));
}
/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnhancedOrderCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $EnhancedOrderCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res>? get company {
    if (_self.company == null) {
    return null;
  }

  return $CompanyCopyWith<$Res>(_self.company!, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingCostResultCopyWith<$Res>? get shippingResult {
    if (_self.shippingResult == null) {
    return null;
  }

  return $ShippingCostResultCopyWith<$Res>(_self.shippingResult!, (value) {
    return _then(_self.copyWith(shippingResult: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $DeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentNextActionCopyWith<$Res>? get nextAction {
    if (_self.nextAction == null) {
    return null;
  }

  return $PaymentNextActionCopyWith<$Res>(_self.nextAction!, (value) {
    return _then(_self.copyWith(nextAction: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnhancedPaymentResult].
extension EnhancedPaymentResultPatterns on EnhancedPaymentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnhancedPaymentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnhancedPaymentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnhancedPaymentResult value)  $default,){
final _that = this;
switch (_that) {
case _EnhancedPaymentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnhancedPaymentResult value)?  $default,){
final _that = this;
switch (_that) {
case _EnhancedPaymentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSuccess,  EnhancedPaymentStatus status,  EnhancedOrder? order,  String? paymentIntentId,  String? clientSecret,  String? paymentMethodId,  PaymentProvider? paymentProvider,  String? companyId,  Company? company,  ShippingCostResult? shippingResult,  DeliveryAddress? deliveryAddress,  String? errorMessage,  String? errorCode,  PaymentErrorType? errorType,  double? amount,  int? amountInCents,  String? currency,  Map<String, dynamic> metadata,  DateTime? createdAt,  DateTime? processedAt,  String? customerEmail,  String? customerId,  PaymentNextAction? nextAction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnhancedPaymentResult() when $default != null:
return $default(_that.isSuccess,_that.status,_that.order,_that.paymentIntentId,_that.clientSecret,_that.paymentMethodId,_that.paymentProvider,_that.companyId,_that.company,_that.shippingResult,_that.deliveryAddress,_that.errorMessage,_that.errorCode,_that.errorType,_that.amount,_that.amountInCents,_that.currency,_that.metadata,_that.createdAt,_that.processedAt,_that.customerEmail,_that.customerId,_that.nextAction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSuccess,  EnhancedPaymentStatus status,  EnhancedOrder? order,  String? paymentIntentId,  String? clientSecret,  String? paymentMethodId,  PaymentProvider? paymentProvider,  String? companyId,  Company? company,  ShippingCostResult? shippingResult,  DeliveryAddress? deliveryAddress,  String? errorMessage,  String? errorCode,  PaymentErrorType? errorType,  double? amount,  int? amountInCents,  String? currency,  Map<String, dynamic> metadata,  DateTime? createdAt,  DateTime? processedAt,  String? customerEmail,  String? customerId,  PaymentNextAction? nextAction)  $default,) {final _that = this;
switch (_that) {
case _EnhancedPaymentResult():
return $default(_that.isSuccess,_that.status,_that.order,_that.paymentIntentId,_that.clientSecret,_that.paymentMethodId,_that.paymentProvider,_that.companyId,_that.company,_that.shippingResult,_that.deliveryAddress,_that.errorMessage,_that.errorCode,_that.errorType,_that.amount,_that.amountInCents,_that.currency,_that.metadata,_that.createdAt,_that.processedAt,_that.customerEmail,_that.customerId,_that.nextAction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSuccess,  EnhancedPaymentStatus status,  EnhancedOrder? order,  String? paymentIntentId,  String? clientSecret,  String? paymentMethodId,  PaymentProvider? paymentProvider,  String? companyId,  Company? company,  ShippingCostResult? shippingResult,  DeliveryAddress? deliveryAddress,  String? errorMessage,  String? errorCode,  PaymentErrorType? errorType,  double? amount,  int? amountInCents,  String? currency,  Map<String, dynamic> metadata,  DateTime? createdAt,  DateTime? processedAt,  String? customerEmail,  String? customerId,  PaymentNextAction? nextAction)?  $default,) {final _that = this;
switch (_that) {
case _EnhancedPaymentResult() when $default != null:
return $default(_that.isSuccess,_that.status,_that.order,_that.paymentIntentId,_that.clientSecret,_that.paymentMethodId,_that.paymentProvider,_that.companyId,_that.company,_that.shippingResult,_that.deliveryAddress,_that.errorMessage,_that.errorCode,_that.errorType,_that.amount,_that.amountInCents,_that.currency,_that.metadata,_that.createdAt,_that.processedAt,_that.customerEmail,_that.customerId,_that.nextAction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnhancedPaymentResult implements EnhancedPaymentResult {
  const _EnhancedPaymentResult({required this.isSuccess, required this.status, this.order, this.paymentIntentId, this.clientSecret, this.paymentMethodId, this.paymentProvider, this.companyId, this.company, this.shippingResult, this.deliveryAddress, this.errorMessage, this.errorCode, this.errorType, this.amount, this.amountInCents, this.currency, final  Map<String, dynamic> metadata = const {}, this.createdAt, this.processedAt, this.customerEmail, this.customerId, this.nextAction}): _metadata = metadata;
  factory _EnhancedPaymentResult.fromJson(Map<String, dynamic> json) => _$EnhancedPaymentResultFromJson(json);

@override final  bool isSuccess;
@override final  EnhancedPaymentStatus status;
// Order Information
@override final  EnhancedOrder? order;
// Payment Information
@override final  String? paymentIntentId;
@override final  String? clientSecret;
@override final  String? paymentMethodId;
@override final  PaymentProvider? paymentProvider;
// Multi-Vendor Context
@override final  String? companyId;
@override final  Company? company;
// Shipping Context
@override final  ShippingCostResult? shippingResult;
@override final  DeliveryAddress? deliveryAddress;
// Error Information
@override final  String? errorMessage;
@override final  String? errorCode;
@override final  PaymentErrorType? errorType;
// Financial Information
@override final  double? amount;
// In Euros
@override final  int? amountInCents;
// Stripe format
@override final  String? currency;
// Metadata und Additional Info
 final  Map<String, dynamic> _metadata;
// Metadata und Additional Info
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

// Timing Information
@override final  DateTime? createdAt;
@override final  DateTime? processedAt;
// Customer Information (for context)
@override final  String? customerEmail;
@override final  String? customerId;
// Next Actions (für requires_action status)
@override final  PaymentNextAction? nextAction;

/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnhancedPaymentResultCopyWith<_EnhancedPaymentResult> get copyWith => __$EnhancedPaymentResultCopyWithImpl<_EnhancedPaymentResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnhancedPaymentResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnhancedPaymentResult&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.status, status) || other.status == status)&&(identical(other.order, order) || other.order == order)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.clientSecret, clientSecret) || other.clientSecret == clientSecret)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.shippingResult, shippingResult) || other.shippingResult == shippingResult)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processedAt, processedAt) || other.processedAt == processedAt)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.nextAction, nextAction) || other.nextAction == nextAction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,isSuccess,status,order,paymentIntentId,clientSecret,paymentMethodId,paymentProvider,companyId,company,shippingResult,deliveryAddress,errorMessage,errorCode,errorType,amount,amountInCents,currency,const DeepCollectionEquality().hash(_metadata),createdAt,processedAt,customerEmail,customerId,nextAction]);

@override
String toString() {
  return 'EnhancedPaymentResult(isSuccess: $isSuccess, status: $status, order: $order, paymentIntentId: $paymentIntentId, clientSecret: $clientSecret, paymentMethodId: $paymentMethodId, paymentProvider: $paymentProvider, companyId: $companyId, company: $company, shippingResult: $shippingResult, deliveryAddress: $deliveryAddress, errorMessage: $errorMessage, errorCode: $errorCode, errorType: $errorType, amount: $amount, amountInCents: $amountInCents, currency: $currency, metadata: $metadata, createdAt: $createdAt, processedAt: $processedAt, customerEmail: $customerEmail, customerId: $customerId, nextAction: $nextAction)';
}


}

/// @nodoc
abstract mixin class _$EnhancedPaymentResultCopyWith<$Res> implements $EnhancedPaymentResultCopyWith<$Res> {
  factory _$EnhancedPaymentResultCopyWith(_EnhancedPaymentResult value, $Res Function(_EnhancedPaymentResult) _then) = __$EnhancedPaymentResultCopyWithImpl;
@override @useResult
$Res call({
 bool isSuccess, EnhancedPaymentStatus status, EnhancedOrder? order, String? paymentIntentId, String? clientSecret, String? paymentMethodId, PaymentProvider? paymentProvider, String? companyId, Company? company, ShippingCostResult? shippingResult, DeliveryAddress? deliveryAddress, String? errorMessage, String? errorCode, PaymentErrorType? errorType, double? amount, int? amountInCents, String? currency, Map<String, dynamic> metadata, DateTime? createdAt, DateTime? processedAt, String? customerEmail, String? customerId, PaymentNextAction? nextAction
});


@override $EnhancedOrderCopyWith<$Res>? get order;@override $CompanyCopyWith<$Res>? get company;@override $ShippingCostResultCopyWith<$Res>? get shippingResult;@override $DeliveryAddressCopyWith<$Res>? get deliveryAddress;@override $PaymentNextActionCopyWith<$Res>? get nextAction;

}
/// @nodoc
class __$EnhancedPaymentResultCopyWithImpl<$Res>
    implements _$EnhancedPaymentResultCopyWith<$Res> {
  __$EnhancedPaymentResultCopyWithImpl(this._self, this._then);

  final _EnhancedPaymentResult _self;
  final $Res Function(_EnhancedPaymentResult) _then;

/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSuccess = null,Object? status = null,Object? order = freezed,Object? paymentIntentId = freezed,Object? clientSecret = freezed,Object? paymentMethodId = freezed,Object? paymentProvider = freezed,Object? companyId = freezed,Object? company = freezed,Object? shippingResult = freezed,Object? deliveryAddress = freezed,Object? errorMessage = freezed,Object? errorCode = freezed,Object? errorType = freezed,Object? amount = freezed,Object? amountInCents = freezed,Object? currency = freezed,Object? metadata = null,Object? createdAt = freezed,Object? processedAt = freezed,Object? customerEmail = freezed,Object? customerId = freezed,Object? nextAction = freezed,}) {
  return _then(_EnhancedPaymentResult(
isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnhancedPaymentStatus,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as EnhancedOrder?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,clientSecret: freezed == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as PaymentProvider?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,shippingResult: freezed == shippingResult ? _self.shippingResult : shippingResult // ignore: cast_nullable_to_non_nullable
as ShippingCostResult?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as PaymentErrorType?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,amountInCents: freezed == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,processedAt: freezed == processedAt ? _self.processedAt : processedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,nextAction: freezed == nextAction ? _self.nextAction : nextAction // ignore: cast_nullable_to_non_nullable
as PaymentNextAction?,
  ));
}

/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnhancedOrderCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $EnhancedOrderCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res>? get company {
    if (_self.company == null) {
    return null;
  }

  return $CompanyCopyWith<$Res>(_self.company!, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingCostResultCopyWith<$Res>? get shippingResult {
    if (_self.shippingResult == null) {
    return null;
  }

  return $ShippingCostResultCopyWith<$Res>(_self.shippingResult!, (value) {
    return _then(_self.copyWith(shippingResult: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $DeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of EnhancedPaymentResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentNextActionCopyWith<$Res>? get nextAction {
    if (_self.nextAction == null) {
    return null;
  }

  return $PaymentNextActionCopyWith<$Res>(_self.nextAction!, (value) {
    return _then(_self.copyWith(nextAction: value));
  });
}
}


/// @nodoc
mixin _$PaymentNextAction {

 PaymentActionType get type; String? get redirectUrl; Map<String, dynamic>? get actionData; String? get instructions;
/// Create a copy of PaymentNextAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentNextActionCopyWith<PaymentNextAction> get copyWith => _$PaymentNextActionCopyWithImpl<PaymentNextAction>(this as PaymentNextAction, _$identity);

  /// Serializes this PaymentNextAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentNextAction&&(identical(other.type, type) || other.type == type)&&(identical(other.redirectUrl, redirectUrl) || other.redirectUrl == redirectUrl)&&const DeepCollectionEquality().equals(other.actionData, actionData)&&(identical(other.instructions, instructions) || other.instructions == instructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,redirectUrl,const DeepCollectionEquality().hash(actionData),instructions);

@override
String toString() {
  return 'PaymentNextAction(type: $type, redirectUrl: $redirectUrl, actionData: $actionData, instructions: $instructions)';
}


}

/// @nodoc
abstract mixin class $PaymentNextActionCopyWith<$Res>  {
  factory $PaymentNextActionCopyWith(PaymentNextAction value, $Res Function(PaymentNextAction) _then) = _$PaymentNextActionCopyWithImpl;
@useResult
$Res call({
 PaymentActionType type, String? redirectUrl, Map<String, dynamic>? actionData, String? instructions
});




}
/// @nodoc
class _$PaymentNextActionCopyWithImpl<$Res>
    implements $PaymentNextActionCopyWith<$Res> {
  _$PaymentNextActionCopyWithImpl(this._self, this._then);

  final PaymentNextAction _self;
  final $Res Function(PaymentNextAction) _then;

/// Create a copy of PaymentNextAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? redirectUrl = freezed,Object? actionData = freezed,Object? instructions = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentActionType,redirectUrl: freezed == redirectUrl ? _self.redirectUrl : redirectUrl // ignore: cast_nullable_to_non_nullable
as String?,actionData: freezed == actionData ? _self.actionData : actionData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentNextAction].
extension PaymentNextActionPatterns on PaymentNextAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentNextAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentNextAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentNextAction value)  $default,){
final _that = this;
switch (_that) {
case _PaymentNextAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentNextAction value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentNextAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentActionType type,  String? redirectUrl,  Map<String, dynamic>? actionData,  String? instructions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentNextAction() when $default != null:
return $default(_that.type,_that.redirectUrl,_that.actionData,_that.instructions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentActionType type,  String? redirectUrl,  Map<String, dynamic>? actionData,  String? instructions)  $default,) {final _that = this;
switch (_that) {
case _PaymentNextAction():
return $default(_that.type,_that.redirectUrl,_that.actionData,_that.instructions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentActionType type,  String? redirectUrl,  Map<String, dynamic>? actionData,  String? instructions)?  $default,) {final _that = this;
switch (_that) {
case _PaymentNextAction() when $default != null:
return $default(_that.type,_that.redirectUrl,_that.actionData,_that.instructions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentNextAction implements PaymentNextAction {
  const _PaymentNextAction({required this.type, this.redirectUrl, final  Map<String, dynamic>? actionData, this.instructions}): _actionData = actionData;
  factory _PaymentNextAction.fromJson(Map<String, dynamic> json) => _$PaymentNextActionFromJson(json);

@override final  PaymentActionType type;
@override final  String? redirectUrl;
 final  Map<String, dynamic>? _actionData;
@override Map<String, dynamic>? get actionData {
  final value = _actionData;
  if (value == null) return null;
  if (_actionData is EqualUnmodifiableMapView) return _actionData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? instructions;

/// Create a copy of PaymentNextAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentNextActionCopyWith<_PaymentNextAction> get copyWith => __$PaymentNextActionCopyWithImpl<_PaymentNextAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentNextActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentNextAction&&(identical(other.type, type) || other.type == type)&&(identical(other.redirectUrl, redirectUrl) || other.redirectUrl == redirectUrl)&&const DeepCollectionEquality().equals(other._actionData, _actionData)&&(identical(other.instructions, instructions) || other.instructions == instructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,redirectUrl,const DeepCollectionEquality().hash(_actionData),instructions);

@override
String toString() {
  return 'PaymentNextAction(type: $type, redirectUrl: $redirectUrl, actionData: $actionData, instructions: $instructions)';
}


}

/// @nodoc
abstract mixin class _$PaymentNextActionCopyWith<$Res> implements $PaymentNextActionCopyWith<$Res> {
  factory _$PaymentNextActionCopyWith(_PaymentNextAction value, $Res Function(_PaymentNextAction) _then) = __$PaymentNextActionCopyWithImpl;
@override @useResult
$Res call({
 PaymentActionType type, String? redirectUrl, Map<String, dynamic>? actionData, String? instructions
});




}
/// @nodoc
class __$PaymentNextActionCopyWithImpl<$Res>
    implements _$PaymentNextActionCopyWith<$Res> {
  __$PaymentNextActionCopyWithImpl(this._self, this._then);

  final _PaymentNextAction _self;
  final $Res Function(_PaymentNextAction) _then;

/// Create a copy of PaymentNextAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? redirectUrl = freezed,Object? actionData = freezed,Object? instructions = freezed,}) {
  return _then(_PaymentNextAction(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentActionType,redirectUrl: freezed == redirectUrl ? _self.redirectUrl : redirectUrl // ignore: cast_nullable_to_non_nullable
as String?,actionData: freezed == actionData ? _self._actionData : actionData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
