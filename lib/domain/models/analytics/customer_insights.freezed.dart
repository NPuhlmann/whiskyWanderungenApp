// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_insights.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerInsights {

 int get totalCustomers; int get newCustomers; int get returningCustomers; double get repeatPurchaseRate; double get averageLifetimeValue; Map<String, int> get customersByLocation; Map<int, int> get orderFrequencyDistribution;
/// Create a copy of CustomerInsights
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerInsightsCopyWith<CustomerInsights> get copyWith => _$CustomerInsightsCopyWithImpl<CustomerInsights>(this as CustomerInsights, _$identity);

  /// Serializes this CustomerInsights to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerInsights&&(identical(other.totalCustomers, totalCustomers) || other.totalCustomers == totalCustomers)&&(identical(other.newCustomers, newCustomers) || other.newCustomers == newCustomers)&&(identical(other.returningCustomers, returningCustomers) || other.returningCustomers == returningCustomers)&&(identical(other.repeatPurchaseRate, repeatPurchaseRate) || other.repeatPurchaseRate == repeatPurchaseRate)&&(identical(other.averageLifetimeValue, averageLifetimeValue) || other.averageLifetimeValue == averageLifetimeValue)&&const DeepCollectionEquality().equals(other.customersByLocation, customersByLocation)&&const DeepCollectionEquality().equals(other.orderFrequencyDistribution, orderFrequencyDistribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCustomers,newCustomers,returningCustomers,repeatPurchaseRate,averageLifetimeValue,const DeepCollectionEquality().hash(customersByLocation),const DeepCollectionEquality().hash(orderFrequencyDistribution));

@override
String toString() {
  return 'CustomerInsights(totalCustomers: $totalCustomers, newCustomers: $newCustomers, returningCustomers: $returningCustomers, repeatPurchaseRate: $repeatPurchaseRate, averageLifetimeValue: $averageLifetimeValue, customersByLocation: $customersByLocation, orderFrequencyDistribution: $orderFrequencyDistribution)';
}


}

/// @nodoc
abstract mixin class $CustomerInsightsCopyWith<$Res>  {
  factory $CustomerInsightsCopyWith(CustomerInsights value, $Res Function(CustomerInsights) _then) = _$CustomerInsightsCopyWithImpl;
@useResult
$Res call({
 int totalCustomers, int newCustomers, int returningCustomers, double repeatPurchaseRate, double averageLifetimeValue, Map<String, int> customersByLocation, Map<int, int> orderFrequencyDistribution
});




}
/// @nodoc
class _$CustomerInsightsCopyWithImpl<$Res>
    implements $CustomerInsightsCopyWith<$Res> {
  _$CustomerInsightsCopyWithImpl(this._self, this._then);

  final CustomerInsights _self;
  final $Res Function(CustomerInsights) _then;

/// Create a copy of CustomerInsights
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCustomers = null,Object? newCustomers = null,Object? returningCustomers = null,Object? repeatPurchaseRate = null,Object? averageLifetimeValue = null,Object? customersByLocation = null,Object? orderFrequencyDistribution = null,}) {
  return _then(_self.copyWith(
totalCustomers: null == totalCustomers ? _self.totalCustomers : totalCustomers // ignore: cast_nullable_to_non_nullable
as int,newCustomers: null == newCustomers ? _self.newCustomers : newCustomers // ignore: cast_nullable_to_non_nullable
as int,returningCustomers: null == returningCustomers ? _self.returningCustomers : returningCustomers // ignore: cast_nullable_to_non_nullable
as int,repeatPurchaseRate: null == repeatPurchaseRate ? _self.repeatPurchaseRate : repeatPurchaseRate // ignore: cast_nullable_to_non_nullable
as double,averageLifetimeValue: null == averageLifetimeValue ? _self.averageLifetimeValue : averageLifetimeValue // ignore: cast_nullable_to_non_nullable
as double,customersByLocation: null == customersByLocation ? _self.customersByLocation : customersByLocation // ignore: cast_nullable_to_non_nullable
as Map<String, int>,orderFrequencyDistribution: null == orderFrequencyDistribution ? _self.orderFrequencyDistribution : orderFrequencyDistribution // ignore: cast_nullable_to_non_nullable
as Map<int, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerInsights].
extension CustomerInsightsPatterns on CustomerInsights {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerInsights value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerInsights() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerInsights value)  $default,){
final _that = this;
switch (_that) {
case _CustomerInsights():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerInsights value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerInsights() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCustomers,  int newCustomers,  int returningCustomers,  double repeatPurchaseRate,  double averageLifetimeValue,  Map<String, int> customersByLocation,  Map<int, int> orderFrequencyDistribution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerInsights() when $default != null:
return $default(_that.totalCustomers,_that.newCustomers,_that.returningCustomers,_that.repeatPurchaseRate,_that.averageLifetimeValue,_that.customersByLocation,_that.orderFrequencyDistribution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCustomers,  int newCustomers,  int returningCustomers,  double repeatPurchaseRate,  double averageLifetimeValue,  Map<String, int> customersByLocation,  Map<int, int> orderFrequencyDistribution)  $default,) {final _that = this;
switch (_that) {
case _CustomerInsights():
return $default(_that.totalCustomers,_that.newCustomers,_that.returningCustomers,_that.repeatPurchaseRate,_that.averageLifetimeValue,_that.customersByLocation,_that.orderFrequencyDistribution);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCustomers,  int newCustomers,  int returningCustomers,  double repeatPurchaseRate,  double averageLifetimeValue,  Map<String, int> customersByLocation,  Map<int, int> orderFrequencyDistribution)?  $default,) {final _that = this;
switch (_that) {
case _CustomerInsights() when $default != null:
return $default(_that.totalCustomers,_that.newCustomers,_that.returningCustomers,_that.repeatPurchaseRate,_that.averageLifetimeValue,_that.customersByLocation,_that.orderFrequencyDistribution);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerInsights extends CustomerInsights {
  const _CustomerInsights({required this.totalCustomers, required this.newCustomers, required this.returningCustomers, required this.repeatPurchaseRate, required this.averageLifetimeValue, final  Map<String, int> customersByLocation = const {}, final  Map<int, int> orderFrequencyDistribution = const {}}): _customersByLocation = customersByLocation,_orderFrequencyDistribution = orderFrequencyDistribution,super._();
  factory _CustomerInsights.fromJson(Map<String, dynamic> json) => _$CustomerInsightsFromJson(json);

@override final  int totalCustomers;
@override final  int newCustomers;
@override final  int returningCustomers;
@override final  double repeatPurchaseRate;
@override final  double averageLifetimeValue;
 final  Map<String, int> _customersByLocation;
@override@JsonKey() Map<String, int> get customersByLocation {
  if (_customersByLocation is EqualUnmodifiableMapView) return _customersByLocation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customersByLocation);
}

 final  Map<int, int> _orderFrequencyDistribution;
@override@JsonKey() Map<int, int> get orderFrequencyDistribution {
  if (_orderFrequencyDistribution is EqualUnmodifiableMapView) return _orderFrequencyDistribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_orderFrequencyDistribution);
}


/// Create a copy of CustomerInsights
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerInsightsCopyWith<_CustomerInsights> get copyWith => __$CustomerInsightsCopyWithImpl<_CustomerInsights>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerInsightsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerInsights&&(identical(other.totalCustomers, totalCustomers) || other.totalCustomers == totalCustomers)&&(identical(other.newCustomers, newCustomers) || other.newCustomers == newCustomers)&&(identical(other.returningCustomers, returningCustomers) || other.returningCustomers == returningCustomers)&&(identical(other.repeatPurchaseRate, repeatPurchaseRate) || other.repeatPurchaseRate == repeatPurchaseRate)&&(identical(other.averageLifetimeValue, averageLifetimeValue) || other.averageLifetimeValue == averageLifetimeValue)&&const DeepCollectionEquality().equals(other._customersByLocation, _customersByLocation)&&const DeepCollectionEquality().equals(other._orderFrequencyDistribution, _orderFrequencyDistribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCustomers,newCustomers,returningCustomers,repeatPurchaseRate,averageLifetimeValue,const DeepCollectionEquality().hash(_customersByLocation),const DeepCollectionEquality().hash(_orderFrequencyDistribution));

@override
String toString() {
  return 'CustomerInsights(totalCustomers: $totalCustomers, newCustomers: $newCustomers, returningCustomers: $returningCustomers, repeatPurchaseRate: $repeatPurchaseRate, averageLifetimeValue: $averageLifetimeValue, customersByLocation: $customersByLocation, orderFrequencyDistribution: $orderFrequencyDistribution)';
}


}

/// @nodoc
abstract mixin class _$CustomerInsightsCopyWith<$Res> implements $CustomerInsightsCopyWith<$Res> {
  factory _$CustomerInsightsCopyWith(_CustomerInsights value, $Res Function(_CustomerInsights) _then) = __$CustomerInsightsCopyWithImpl;
@override @useResult
$Res call({
 int totalCustomers, int newCustomers, int returningCustomers, double repeatPurchaseRate, double averageLifetimeValue, Map<String, int> customersByLocation, Map<int, int> orderFrequencyDistribution
});




}
/// @nodoc
class __$CustomerInsightsCopyWithImpl<$Res>
    implements _$CustomerInsightsCopyWith<$Res> {
  __$CustomerInsightsCopyWithImpl(this._self, this._then);

  final _CustomerInsights _self;
  final $Res Function(_CustomerInsights) _then;

/// Create a copy of CustomerInsights
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCustomers = null,Object? newCustomers = null,Object? returningCustomers = null,Object? repeatPurchaseRate = null,Object? averageLifetimeValue = null,Object? customersByLocation = null,Object? orderFrequencyDistribution = null,}) {
  return _then(_CustomerInsights(
totalCustomers: null == totalCustomers ? _self.totalCustomers : totalCustomers // ignore: cast_nullable_to_non_nullable
as int,newCustomers: null == newCustomers ? _self.newCustomers : newCustomers // ignore: cast_nullable_to_non_nullable
as int,returningCustomers: null == returningCustomers ? _self.returningCustomers : returningCustomers // ignore: cast_nullable_to_non_nullable
as int,repeatPurchaseRate: null == repeatPurchaseRate ? _self.repeatPurchaseRate : repeatPurchaseRate // ignore: cast_nullable_to_non_nullable
as double,averageLifetimeValue: null == averageLifetimeValue ? _self.averageLifetimeValue : averageLifetimeValue // ignore: cast_nullable_to_non_nullable
as double,customersByLocation: null == customersByLocation ? _self._customersByLocation : customersByLocation // ignore: cast_nullable_to_non_nullable
as Map<String, int>,orderFrequencyDistribution: null == orderFrequencyDistribution ? _self._orderFrequencyDistribution : orderFrequencyDistribution // ignore: cast_nullable_to_non_nullable
as Map<int, int>,
  ));
}


}

// dart format on
