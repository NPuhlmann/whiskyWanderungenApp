// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simple_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SimpleOrder {

 int get id; String get orderNumber; int get hikeId; String get userId; double get totalAmount; DeliveryType get deliveryType; OrderStatus get status; DateTime get createdAt;
/// Create a copy of SimpleOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimpleOrderCopyWith<SimpleOrder> get copyWith => _$SimpleOrderCopyWithImpl<SimpleOrder>(this as SimpleOrder, _$identity);

  /// Serializes this SimpleOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimpleOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,hikeId,userId,totalAmount,deliveryType,status,createdAt);

@override
String toString() {
  return 'SimpleOrder(id: $id, orderNumber: $orderNumber, hikeId: $hikeId, userId: $userId, totalAmount: $totalAmount, deliveryType: $deliveryType, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SimpleOrderCopyWith<$Res>  {
  factory $SimpleOrderCopyWith(SimpleOrder value, $Res Function(SimpleOrder) _then) = _$SimpleOrderCopyWithImpl;
@useResult
$Res call({
 int id, String orderNumber, int hikeId, String userId, double totalAmount, DeliveryType deliveryType, OrderStatus status, DateTime createdAt
});




}
/// @nodoc
class _$SimpleOrderCopyWithImpl<$Res>
    implements $SimpleOrderCopyWith<$Res> {
  _$SimpleOrderCopyWithImpl(this._self, this._then);

  final SimpleOrder _self;
  final $Res Function(SimpleOrder) _then;

/// Create a copy of SimpleOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? hikeId = null,Object? userId = null,Object? totalAmount = null,Object? deliveryType = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SimpleOrder].
extension SimpleOrderPatterns on SimpleOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimpleOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimpleOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimpleOrder value)  $default,){
final _that = this;
switch (_that) {
case _SimpleOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimpleOrder value)?  $default,){
final _that = this;
switch (_that) {
case _SimpleOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimpleOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SimpleOrder():
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SimpleOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SimpleOrder implements SimpleOrder {
  const _SimpleOrder({required this.id, required this.orderNumber, required this.hikeId, required this.userId, required this.totalAmount, required this.deliveryType, required this.status, required this.createdAt});
  factory _SimpleOrder.fromJson(Map<String, dynamic> json) => _$SimpleOrderFromJson(json);

@override final  int id;
@override final  String orderNumber;
@override final  int hikeId;
@override final  String userId;
@override final  double totalAmount;
@override final  DeliveryType deliveryType;
@override final  OrderStatus status;
@override final  DateTime createdAt;

/// Create a copy of SimpleOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimpleOrderCopyWith<_SimpleOrder> get copyWith => __$SimpleOrderCopyWithImpl<_SimpleOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SimpleOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimpleOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderNumber,hikeId,userId,totalAmount,deliveryType,status,createdAt);

@override
String toString() {
  return 'SimpleOrder(id: $id, orderNumber: $orderNumber, hikeId: $hikeId, userId: $userId, totalAmount: $totalAmount, deliveryType: $deliveryType, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SimpleOrderCopyWith<$Res> implements $SimpleOrderCopyWith<$Res> {
  factory _$SimpleOrderCopyWith(_SimpleOrder value, $Res Function(_SimpleOrder) _then) = __$SimpleOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, String orderNumber, int hikeId, String userId, double totalAmount, DeliveryType deliveryType, OrderStatus status, DateTime createdAt
});




}
/// @nodoc
class __$SimpleOrderCopyWithImpl<$Res>
    implements _$SimpleOrderCopyWith<$Res> {
  __$SimpleOrderCopyWithImpl(this._self, this._then);

  final _SimpleOrder _self;
  final $Res Function(_SimpleOrder) _then;

/// Create a copy of SimpleOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? hikeId = null,Object? userId = null,Object? totalAmount = null,Object? deliveryType = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_SimpleOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
