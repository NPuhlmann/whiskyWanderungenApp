// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'basic_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BasicOrder {

 int get id; String get orderNumber; int get hikeId; String get userId; double get totalAmount; DeliveryType get deliveryType; OrderStatus get status; DateTime get createdAt; DateTime? get estimatedDelivery; String? get trackingNumber; Map<String, dynamic>? get deliveryAddress; String? get paymentIntentId; DateTime? get updatedAt;
/// Create a copy of BasicOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BasicOrderCopyWith<BasicOrder> get copyWith => _$BasicOrderCopyWithImpl<BasicOrder>(this as BasicOrder, _$identity);

  /// Serializes this BasicOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BasicOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&const DeepCollectionEquality().equals(other.deliveryAddress, deliveryAddress)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,hikeId,userId,totalAmount,deliveryType,status,createdAt,estimatedDelivery,trackingNumber,const DeepCollectionEquality().hash(deliveryAddress),paymentIntentId,updatedAt);

@override
String toString() {
  return 'BasicOrder(id: $id, orderNumber: $orderNumber, hikeId: $hikeId, userId: $userId, totalAmount: $totalAmount, deliveryType: $deliveryType, status: $status, createdAt: $createdAt, estimatedDelivery: $estimatedDelivery, trackingNumber: $trackingNumber, deliveryAddress: $deliveryAddress, paymentIntentId: $paymentIntentId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BasicOrderCopyWith<$Res>  {
  factory $BasicOrderCopyWith(BasicOrder value, $Res Function(BasicOrder) _then) = _$BasicOrderCopyWithImpl;
@useResult
$Res call({
 int id, String orderNumber, int hikeId, String userId, double totalAmount, DeliveryType deliveryType, OrderStatus status, DateTime createdAt, DateTime? estimatedDelivery, String? trackingNumber, Map<String, dynamic>? deliveryAddress, String? paymentIntentId, DateTime? updatedAt
});




}
/// @nodoc
class _$BasicOrderCopyWithImpl<$Res>
    implements $BasicOrderCopyWith<$Res> {
  _$BasicOrderCopyWithImpl(this._self, this._then);

  final BasicOrder _self;
  final $Res Function(BasicOrder) _then;

/// Create a copy of BasicOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? hikeId = null,Object? userId = null,Object? totalAmount = null,Object? deliveryType = null,Object? status = null,Object? createdAt = null,Object? estimatedDelivery = freezed,Object? trackingNumber = freezed,Object? deliveryAddress = freezed,Object? paymentIntentId = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BasicOrder].
extension BasicOrderPatterns on BasicOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BasicOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BasicOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BasicOrder value)  $default,){
final _that = this;
switch (_that) {
case _BasicOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BasicOrder value)?  $default,){
final _that = this;
switch (_that) {
case _BasicOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt,  DateTime? estimatedDelivery,  String? trackingNumber,  Map<String, dynamic>? deliveryAddress,  String? paymentIntentId,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BasicOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt,_that.estimatedDelivery,_that.trackingNumber,_that.deliveryAddress,_that.paymentIntentId,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt,  DateTime? estimatedDelivery,  String? trackingNumber,  Map<String, dynamic>? deliveryAddress,  String? paymentIntentId,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BasicOrder():
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt,_that.estimatedDelivery,_that.trackingNumber,_that.deliveryAddress,_that.paymentIntentId,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt,  DateTime? estimatedDelivery,  String? trackingNumber,  Map<String, dynamic>? deliveryAddress,  String? paymentIntentId,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BasicOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt,_that.estimatedDelivery,_that.trackingNumber,_that.deliveryAddress,_that.paymentIntentId,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BasicOrder implements BasicOrder {
  const _BasicOrder({required this.id, required this.orderNumber, required this.hikeId, required this.userId, required this.totalAmount, required this.deliveryType, required this.status, required this.createdAt, this.estimatedDelivery, this.trackingNumber, final  Map<String, dynamic>? deliveryAddress, this.paymentIntentId, this.updatedAt}): _deliveryAddress = deliveryAddress;
  factory _BasicOrder.fromJson(Map<String, dynamic> json) => _$BasicOrderFromJson(json);

@override final  int id;
@override final  String orderNumber;
@override final  int hikeId;
@override final  String userId;
@override final  double totalAmount;
@override final  DeliveryType deliveryType;
@override final  OrderStatus status;
@override final  DateTime createdAt;
@override final  DateTime? estimatedDelivery;
@override final  String? trackingNumber;
 final  Map<String, dynamic>? _deliveryAddress;
@override Map<String, dynamic>? get deliveryAddress {
  final value = _deliveryAddress;
  if (value == null) return null;
  if (_deliveryAddress is EqualUnmodifiableMapView) return _deliveryAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? paymentIntentId;
@override final  DateTime? updatedAt;

/// Create a copy of BasicOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BasicOrderCopyWith<_BasicOrder> get copyWith => __$BasicOrderCopyWithImpl<_BasicOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BasicOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BasicOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&const DeepCollectionEquality().equals(other._deliveryAddress, _deliveryAddress)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,hikeId,userId,totalAmount,deliveryType,status,createdAt,estimatedDelivery,trackingNumber,const DeepCollectionEquality().hash(_deliveryAddress),paymentIntentId,updatedAt);

@override
String toString() {
  return 'BasicOrder(id: $id, orderNumber: $orderNumber, hikeId: $hikeId, userId: $userId, totalAmount: $totalAmount, deliveryType: $deliveryType, status: $status, createdAt: $createdAt, estimatedDelivery: $estimatedDelivery, trackingNumber: $trackingNumber, deliveryAddress: $deliveryAddress, paymentIntentId: $paymentIntentId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BasicOrderCopyWith<$Res> implements $BasicOrderCopyWith<$Res> {
  factory _$BasicOrderCopyWith(_BasicOrder value, $Res Function(_BasicOrder) _then) = __$BasicOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, String orderNumber, int hikeId, String userId, double totalAmount, DeliveryType deliveryType, OrderStatus status, DateTime createdAt, DateTime? estimatedDelivery, String? trackingNumber, Map<String, dynamic>? deliveryAddress, String? paymentIntentId, DateTime? updatedAt
});




}
/// @nodoc
class __$BasicOrderCopyWithImpl<$Res>
    implements _$BasicOrderCopyWith<$Res> {
  __$BasicOrderCopyWithImpl(this._self, this._then);

  final _BasicOrder _self;
  final $Res Function(_BasicOrder) _then;

/// Create a copy of BasicOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? hikeId = null,Object? userId = null,Object? totalAmount = null,Object? deliveryType = null,Object? status = null,Object? createdAt = null,Object? estimatedDelivery = freezed,Object? trackingNumber = freezed,Object? deliveryAddress = freezed,Object? paymentIntentId = freezed,Object? updatedAt = freezed,}) {
  return _then(_BasicOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self._deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
