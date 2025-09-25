// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Commission {

 int get id;@JsonKey(name: 'hike_id') int get hikeId;@JsonKey(name: 'company_id') String get companyId;@JsonKey(name: 'order_id') String get orderId;@JsonKey(name: 'commission_rate') double get commissionRate;@JsonKey(name: 'base_amount') double get baseAmount;@JsonKey(name: 'commission_amount') double get commissionAmount; CommissionStatus get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'paid_at') DateTime? get paidAt;@JsonKey(name: 'billing_period_id') String? get billingPeriodId; String? get notes;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of Commission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionCopyWith<Commission> get copyWith => _$CommissionCopyWithImpl<Commission>(this as Commission, _$identity);

  /// Serializes this Commission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Commission&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.commissionAmount, commissionAmount) || other.commissionAmount == commissionAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.billingPeriodId, billingPeriodId) || other.billingPeriodId == billingPeriodId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,companyId,orderId,commissionRate,baseAmount,commissionAmount,status,createdAt,paidAt,billingPeriodId,notes,updatedAt);

@override
String toString() {
  return 'Commission(id: $id, hikeId: $hikeId, companyId: $companyId, orderId: $orderId, commissionRate: $commissionRate, baseAmount: $baseAmount, commissionAmount: $commissionAmount, status: $status, createdAt: $createdAt, paidAt: $paidAt, billingPeriodId: $billingPeriodId, notes: $notes, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CommissionCopyWith<$Res>  {
  factory $CommissionCopyWith(Commission value, $Res Function(Commission) _then) = _$CommissionCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'hike_id') int hikeId,@JsonKey(name: 'company_id') String companyId,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'commission_rate') double commissionRate,@JsonKey(name: 'base_amount') double baseAmount,@JsonKey(name: 'commission_amount') double commissionAmount, CommissionStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'paid_at') DateTime? paidAt,@JsonKey(name: 'billing_period_id') String? billingPeriodId, String? notes,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$CommissionCopyWithImpl<$Res>
    implements $CommissionCopyWith<$Res> {
  _$CommissionCopyWithImpl(this._self, this._then);

  final Commission _self;
  final $Res Function(Commission) _then;

/// Create a copy of Commission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hikeId = null,Object? companyId = null,Object? orderId = null,Object? commissionRate = null,Object? baseAmount = null,Object? commissionAmount = null,Object? status = null,Object? createdAt = null,Object? paidAt = freezed,Object? billingPeriodId = freezed,Object? notes = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,commissionAmount: null == commissionAmount ? _self.commissionAmount : commissionAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommissionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,billingPeriodId: freezed == billingPeriodId ? _self.billingPeriodId : billingPeriodId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Commission].
extension CommissionPatterns on Commission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Commission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Commission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Commission value)  $default,){
final _that = this;
switch (_that) {
case _Commission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Commission value)?  $default,){
final _that = this;
switch (_that) {
case _Commission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'hike_id')  int hikeId, @JsonKey(name: 'company_id')  String companyId, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'commission_rate')  double commissionRate, @JsonKey(name: 'base_amount')  double baseAmount, @JsonKey(name: 'commission_amount')  double commissionAmount,  CommissionStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'paid_at')  DateTime? paidAt, @JsonKey(name: 'billing_period_id')  String? billingPeriodId,  String? notes, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Commission() when $default != null:
return $default(_that.id,_that.hikeId,_that.companyId,_that.orderId,_that.commissionRate,_that.baseAmount,_that.commissionAmount,_that.status,_that.createdAt,_that.paidAt,_that.billingPeriodId,_that.notes,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'hike_id')  int hikeId, @JsonKey(name: 'company_id')  String companyId, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'commission_rate')  double commissionRate, @JsonKey(name: 'base_amount')  double baseAmount, @JsonKey(name: 'commission_amount')  double commissionAmount,  CommissionStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'paid_at')  DateTime? paidAt, @JsonKey(name: 'billing_period_id')  String? billingPeriodId,  String? notes, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Commission():
return $default(_that.id,_that.hikeId,_that.companyId,_that.orderId,_that.commissionRate,_that.baseAmount,_that.commissionAmount,_that.status,_that.createdAt,_that.paidAt,_that.billingPeriodId,_that.notes,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'hike_id')  int hikeId, @JsonKey(name: 'company_id')  String companyId, @JsonKey(name: 'order_id')  String orderId, @JsonKey(name: 'commission_rate')  double commissionRate, @JsonKey(name: 'base_amount')  double baseAmount, @JsonKey(name: 'commission_amount')  double commissionAmount,  CommissionStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'paid_at')  DateTime? paidAt, @JsonKey(name: 'billing_period_id')  String? billingPeriodId,  String? notes, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Commission() when $default != null:
return $default(_that.id,_that.hikeId,_that.companyId,_that.orderId,_that.commissionRate,_that.baseAmount,_that.commissionAmount,_that.status,_that.createdAt,_that.paidAt,_that.billingPeriodId,_that.notes,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Commission implements Commission {
  const _Commission({required this.id, @JsonKey(name: 'hike_id') required this.hikeId, @JsonKey(name: 'company_id') required this.companyId, @JsonKey(name: 'order_id') required this.orderId, @JsonKey(name: 'commission_rate') required this.commissionRate, @JsonKey(name: 'base_amount') required this.baseAmount, @JsonKey(name: 'commission_amount') required this.commissionAmount, required this.status, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'paid_at') this.paidAt, @JsonKey(name: 'billing_period_id') this.billingPeriodId, this.notes, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _Commission.fromJson(Map<String, dynamic> json) => _$CommissionFromJson(json);

@override final  int id;
@override@JsonKey(name: 'hike_id') final  int hikeId;
@override@JsonKey(name: 'company_id') final  String companyId;
@override@JsonKey(name: 'order_id') final  String orderId;
@override@JsonKey(name: 'commission_rate') final  double commissionRate;
@override@JsonKey(name: 'base_amount') final  double baseAmount;
@override@JsonKey(name: 'commission_amount') final  double commissionAmount;
@override final  CommissionStatus status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'paid_at') final  DateTime? paidAt;
@override@JsonKey(name: 'billing_period_id') final  String? billingPeriodId;
@override final  String? notes;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of Commission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionCopyWith<_Commission> get copyWith => __$CommissionCopyWithImpl<_Commission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Commission&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.commissionAmount, commissionAmount) || other.commissionAmount == commissionAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.billingPeriodId, billingPeriodId) || other.billingPeriodId == billingPeriodId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,companyId,orderId,commissionRate,baseAmount,commissionAmount,status,createdAt,paidAt,billingPeriodId,notes,updatedAt);

@override
String toString() {
  return 'Commission(id: $id, hikeId: $hikeId, companyId: $companyId, orderId: $orderId, commissionRate: $commissionRate, baseAmount: $baseAmount, commissionAmount: $commissionAmount, status: $status, createdAt: $createdAt, paidAt: $paidAt, billingPeriodId: $billingPeriodId, notes: $notes, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CommissionCopyWith<$Res> implements $CommissionCopyWith<$Res> {
  factory _$CommissionCopyWith(_Commission value, $Res Function(_Commission) _then) = __$CommissionCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'hike_id') int hikeId,@JsonKey(name: 'company_id') String companyId,@JsonKey(name: 'order_id') String orderId,@JsonKey(name: 'commission_rate') double commissionRate,@JsonKey(name: 'base_amount') double baseAmount,@JsonKey(name: 'commission_amount') double commissionAmount, CommissionStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'paid_at') DateTime? paidAt,@JsonKey(name: 'billing_period_id') String? billingPeriodId, String? notes,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$CommissionCopyWithImpl<$Res>
    implements _$CommissionCopyWith<$Res> {
  __$CommissionCopyWithImpl(this._self, this._then);

  final _Commission _self;
  final $Res Function(_Commission) _then;

/// Create a copy of Commission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hikeId = null,Object? companyId = null,Object? orderId = null,Object? commissionRate = null,Object? baseAmount = null,Object? commissionAmount = null,Object? status = null,Object? createdAt = null,Object? paidAt = freezed,Object? billingPeriodId = freezed,Object? notes = freezed,Object? updatedAt = freezed,}) {
  return _then(_Commission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,commissionAmount: null == commissionAmount ? _self.commissionAmount : commissionAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommissionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,billingPeriodId: freezed == billingPeriodId ? _self.billingPeriodId : billingPeriodId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
