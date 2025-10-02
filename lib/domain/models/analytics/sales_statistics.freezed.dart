// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesStatistics {

 int get totalOrders; double get totalRevenue; double get averageOrderValue; Map<String, int> get ordersByRoute; Map<String, double> get revenueByRoute; Map<String, int> get ordersByDate; Map<String, double> get revenueByDate;
/// Create a copy of SalesStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesStatisticsCopyWith<SalesStatistics> get copyWith => _$SalesStatisticsCopyWithImpl<SalesStatistics>(this as SalesStatistics, _$identity);

  /// Serializes this SalesStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesStatistics&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.averageOrderValue, averageOrderValue) || other.averageOrderValue == averageOrderValue)&&const DeepCollectionEquality().equals(other.ordersByRoute, ordersByRoute)&&const DeepCollectionEquality().equals(other.revenueByRoute, revenueByRoute)&&const DeepCollectionEquality().equals(other.ordersByDate, ordersByDate)&&const DeepCollectionEquality().equals(other.revenueByDate, revenueByDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalOrders,totalRevenue,averageOrderValue,const DeepCollectionEquality().hash(ordersByRoute),const DeepCollectionEquality().hash(revenueByRoute),const DeepCollectionEquality().hash(ordersByDate),const DeepCollectionEquality().hash(revenueByDate));

@override
String toString() {
  return 'SalesStatistics(totalOrders: $totalOrders, totalRevenue: $totalRevenue, averageOrderValue: $averageOrderValue, ordersByRoute: $ordersByRoute, revenueByRoute: $revenueByRoute, ordersByDate: $ordersByDate, revenueByDate: $revenueByDate)';
}


}

/// @nodoc
abstract mixin class $SalesStatisticsCopyWith<$Res>  {
  factory $SalesStatisticsCopyWith(SalesStatistics value, $Res Function(SalesStatistics) _then) = _$SalesStatisticsCopyWithImpl;
@useResult
$Res call({
 int totalOrders, double totalRevenue, double averageOrderValue, Map<String, int> ordersByRoute, Map<String, double> revenueByRoute, Map<String, int> ordersByDate, Map<String, double> revenueByDate
});




}
/// @nodoc
class _$SalesStatisticsCopyWithImpl<$Res>
    implements $SalesStatisticsCopyWith<$Res> {
  _$SalesStatisticsCopyWithImpl(this._self, this._then);

  final SalesStatistics _self;
  final $Res Function(SalesStatistics) _then;

/// Create a copy of SalesStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalOrders = null,Object? totalRevenue = null,Object? averageOrderValue = null,Object? ordersByRoute = null,Object? revenueByRoute = null,Object? ordersByDate = null,Object? revenueByDate = null,}) {
  return _then(_self.copyWith(
totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as double,ordersByRoute: null == ordersByRoute ? _self.ordersByRoute : ordersByRoute // ignore: cast_nullable_to_non_nullable
as Map<String, int>,revenueByRoute: null == revenueByRoute ? _self.revenueByRoute : revenueByRoute // ignore: cast_nullable_to_non_nullable
as Map<String, double>,ordersByDate: null == ordersByDate ? _self.ordersByDate : ordersByDate // ignore: cast_nullable_to_non_nullable
as Map<String, int>,revenueByDate: null == revenueByDate ? _self.revenueByDate : revenueByDate // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesStatistics].
extension SalesStatisticsPatterns on SalesStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesStatistics value)  $default,){
final _that = this;
switch (_that) {
case _SalesStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _SalesStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalOrders,  double totalRevenue,  double averageOrderValue,  Map<String, int> ordersByRoute,  Map<String, double> revenueByRoute,  Map<String, int> ordersByDate,  Map<String, double> revenueByDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesStatistics() when $default != null:
return $default(_that.totalOrders,_that.totalRevenue,_that.averageOrderValue,_that.ordersByRoute,_that.revenueByRoute,_that.ordersByDate,_that.revenueByDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalOrders,  double totalRevenue,  double averageOrderValue,  Map<String, int> ordersByRoute,  Map<String, double> revenueByRoute,  Map<String, int> ordersByDate,  Map<String, double> revenueByDate)  $default,) {final _that = this;
switch (_that) {
case _SalesStatistics():
return $default(_that.totalOrders,_that.totalRevenue,_that.averageOrderValue,_that.ordersByRoute,_that.revenueByRoute,_that.ordersByDate,_that.revenueByDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalOrders,  double totalRevenue,  double averageOrderValue,  Map<String, int> ordersByRoute,  Map<String, double> revenueByRoute,  Map<String, int> ordersByDate,  Map<String, double> revenueByDate)?  $default,) {final _that = this;
switch (_that) {
case _SalesStatistics() when $default != null:
return $default(_that.totalOrders,_that.totalRevenue,_that.averageOrderValue,_that.ordersByRoute,_that.revenueByRoute,_that.ordersByDate,_that.revenueByDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesStatistics extends SalesStatistics {
  const _SalesStatistics({required this.totalOrders, required this.totalRevenue, required this.averageOrderValue, final  Map<String, int> ordersByRoute = const {}, final  Map<String, double> revenueByRoute = const {}, final  Map<String, int> ordersByDate = const {}, final  Map<String, double> revenueByDate = const {}}): _ordersByRoute = ordersByRoute,_revenueByRoute = revenueByRoute,_ordersByDate = ordersByDate,_revenueByDate = revenueByDate,super._();
  factory _SalesStatistics.fromJson(Map<String, dynamic> json) => _$SalesStatisticsFromJson(json);

@override final  int totalOrders;
@override final  double totalRevenue;
@override final  double averageOrderValue;
 final  Map<String, int> _ordersByRoute;
@override@JsonKey() Map<String, int> get ordersByRoute {
  if (_ordersByRoute is EqualUnmodifiableMapView) return _ordersByRoute;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ordersByRoute);
}

 final  Map<String, double> _revenueByRoute;
@override@JsonKey() Map<String, double> get revenueByRoute {
  if (_revenueByRoute is EqualUnmodifiableMapView) return _revenueByRoute;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_revenueByRoute);
}

 final  Map<String, int> _ordersByDate;
@override@JsonKey() Map<String, int> get ordersByDate {
  if (_ordersByDate is EqualUnmodifiableMapView) return _ordersByDate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ordersByDate);
}

 final  Map<String, double> _revenueByDate;
@override@JsonKey() Map<String, double> get revenueByDate {
  if (_revenueByDate is EqualUnmodifiableMapView) return _revenueByDate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_revenueByDate);
}


/// Create a copy of SalesStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesStatisticsCopyWith<_SalesStatistics> get copyWith => __$SalesStatisticsCopyWithImpl<_SalesStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesStatistics&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.averageOrderValue, averageOrderValue) || other.averageOrderValue == averageOrderValue)&&const DeepCollectionEquality().equals(other._ordersByRoute, _ordersByRoute)&&const DeepCollectionEquality().equals(other._revenueByRoute, _revenueByRoute)&&const DeepCollectionEquality().equals(other._ordersByDate, _ordersByDate)&&const DeepCollectionEquality().equals(other._revenueByDate, _revenueByDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalOrders,totalRevenue,averageOrderValue,const DeepCollectionEquality().hash(_ordersByRoute),const DeepCollectionEquality().hash(_revenueByRoute),const DeepCollectionEquality().hash(_ordersByDate),const DeepCollectionEquality().hash(_revenueByDate));

@override
String toString() {
  return 'SalesStatistics(totalOrders: $totalOrders, totalRevenue: $totalRevenue, averageOrderValue: $averageOrderValue, ordersByRoute: $ordersByRoute, revenueByRoute: $revenueByRoute, ordersByDate: $ordersByDate, revenueByDate: $revenueByDate)';
}


}

/// @nodoc
abstract mixin class _$SalesStatisticsCopyWith<$Res> implements $SalesStatisticsCopyWith<$Res> {
  factory _$SalesStatisticsCopyWith(_SalesStatistics value, $Res Function(_SalesStatistics) _then) = __$SalesStatisticsCopyWithImpl;
@override @useResult
$Res call({
 int totalOrders, double totalRevenue, double averageOrderValue, Map<String, int> ordersByRoute, Map<String, double> revenueByRoute, Map<String, int> ordersByDate, Map<String, double> revenueByDate
});




}
/// @nodoc
class __$SalesStatisticsCopyWithImpl<$Res>
    implements _$SalesStatisticsCopyWith<$Res> {
  __$SalesStatisticsCopyWithImpl(this._self, this._then);

  final _SalesStatistics _self;
  final $Res Function(_SalesStatistics) _then;

/// Create a copy of SalesStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalOrders = null,Object? totalRevenue = null,Object? averageOrderValue = null,Object? ordersByRoute = null,Object? revenueByRoute = null,Object? ordersByDate = null,Object? revenueByDate = null,}) {
  return _then(_SalesStatistics(
totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as double,ordersByRoute: null == ordersByRoute ? _self._ordersByRoute : ordersByRoute // ignore: cast_nullable_to_non_nullable
as Map<String, int>,revenueByRoute: null == revenueByRoute ? _self._revenueByRoute : revenueByRoute // ignore: cast_nullable_to_non_nullable
as Map<String, double>,ordersByDate: null == ordersByDate ? _self._ordersByDate : ordersByDate // ignore: cast_nullable_to_non_nullable
as Map<String, int>,revenueByDate: null == revenueByDate ? _self._revenueByDate : revenueByDate // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
