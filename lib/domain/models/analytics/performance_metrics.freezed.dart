// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performance_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerformanceMetrics {

 double get conversionRate; double get averageOrderValue; double get customerLifetimeValue; int get totalViews; int get totalPurchases; Map<String, double> get metricsByPeriod;
/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceMetricsCopyWith<PerformanceMetrics> get copyWith => _$PerformanceMetricsCopyWithImpl<PerformanceMetrics>(this as PerformanceMetrics, _$identity);

  /// Serializes this PerformanceMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceMetrics&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&(identical(other.averageOrderValue, averageOrderValue) || other.averageOrderValue == averageOrderValue)&&(identical(other.customerLifetimeValue, customerLifetimeValue) || other.customerLifetimeValue == customerLifetimeValue)&&(identical(other.totalViews, totalViews) || other.totalViews == totalViews)&&(identical(other.totalPurchases, totalPurchases) || other.totalPurchases == totalPurchases)&&const DeepCollectionEquality().equals(other.metricsByPeriod, metricsByPeriod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversionRate,averageOrderValue,customerLifetimeValue,totalViews,totalPurchases,const DeepCollectionEquality().hash(metricsByPeriod));

@override
String toString() {
  return 'PerformanceMetrics(conversionRate: $conversionRate, averageOrderValue: $averageOrderValue, customerLifetimeValue: $customerLifetimeValue, totalViews: $totalViews, totalPurchases: $totalPurchases, metricsByPeriod: $metricsByPeriod)';
}


}

/// @nodoc
abstract mixin class $PerformanceMetricsCopyWith<$Res>  {
  factory $PerformanceMetricsCopyWith(PerformanceMetrics value, $Res Function(PerformanceMetrics) _then) = _$PerformanceMetricsCopyWithImpl;
@useResult
$Res call({
 double conversionRate, double averageOrderValue, double customerLifetimeValue, int totalViews, int totalPurchases, Map<String, double> metricsByPeriod
});




}
/// @nodoc
class _$PerformanceMetricsCopyWithImpl<$Res>
    implements $PerformanceMetricsCopyWith<$Res> {
  _$PerformanceMetricsCopyWithImpl(this._self, this._then);

  final PerformanceMetrics _self;
  final $Res Function(PerformanceMetrics) _then;

/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversionRate = null,Object? averageOrderValue = null,Object? customerLifetimeValue = null,Object? totalViews = null,Object? totalPurchases = null,Object? metricsByPeriod = null,}) {
  return _then(_self.copyWith(
conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as double,customerLifetimeValue: null == customerLifetimeValue ? _self.customerLifetimeValue : customerLifetimeValue // ignore: cast_nullable_to_non_nullable
as double,totalViews: null == totalViews ? _self.totalViews : totalViews // ignore: cast_nullable_to_non_nullable
as int,totalPurchases: null == totalPurchases ? _self.totalPurchases : totalPurchases // ignore: cast_nullable_to_non_nullable
as int,metricsByPeriod: null == metricsByPeriod ? _self.metricsByPeriod : metricsByPeriod // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceMetrics].
extension PerformanceMetricsPatterns on PerformanceMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceMetrics value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double conversionRate,  double averageOrderValue,  double customerLifetimeValue,  int totalViews,  int totalPurchases,  Map<String, double> metricsByPeriod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that.conversionRate,_that.averageOrderValue,_that.customerLifetimeValue,_that.totalViews,_that.totalPurchases,_that.metricsByPeriod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double conversionRate,  double averageOrderValue,  double customerLifetimeValue,  int totalViews,  int totalPurchases,  Map<String, double> metricsByPeriod)  $default,) {final _that = this;
switch (_that) {
case _PerformanceMetrics():
return $default(_that.conversionRate,_that.averageOrderValue,_that.customerLifetimeValue,_that.totalViews,_that.totalPurchases,_that.metricsByPeriod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double conversionRate,  double averageOrderValue,  double customerLifetimeValue,  int totalViews,  int totalPurchases,  Map<String, double> metricsByPeriod)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceMetrics() when $default != null:
return $default(_that.conversionRate,_that.averageOrderValue,_that.customerLifetimeValue,_that.totalViews,_that.totalPurchases,_that.metricsByPeriod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformanceMetrics extends PerformanceMetrics {
  const _PerformanceMetrics({required this.conversionRate, required this.averageOrderValue, required this.customerLifetimeValue, required this.totalViews, required this.totalPurchases, final  Map<String, double> metricsByPeriod = const {}}): _metricsByPeriod = metricsByPeriod,super._();
  factory _PerformanceMetrics.fromJson(Map<String, dynamic> json) => _$PerformanceMetricsFromJson(json);

@override final  double conversionRate;
@override final  double averageOrderValue;
@override final  double customerLifetimeValue;
@override final  int totalViews;
@override final  int totalPurchases;
 final  Map<String, double> _metricsByPeriod;
@override@JsonKey() Map<String, double> get metricsByPeriod {
  if (_metricsByPeriod is EqualUnmodifiableMapView) return _metricsByPeriod;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metricsByPeriod);
}


/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceMetricsCopyWith<_PerformanceMetrics> get copyWith => __$PerformanceMetricsCopyWithImpl<_PerformanceMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformanceMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceMetrics&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&(identical(other.averageOrderValue, averageOrderValue) || other.averageOrderValue == averageOrderValue)&&(identical(other.customerLifetimeValue, customerLifetimeValue) || other.customerLifetimeValue == customerLifetimeValue)&&(identical(other.totalViews, totalViews) || other.totalViews == totalViews)&&(identical(other.totalPurchases, totalPurchases) || other.totalPurchases == totalPurchases)&&const DeepCollectionEquality().equals(other._metricsByPeriod, _metricsByPeriod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conversionRate,averageOrderValue,customerLifetimeValue,totalViews,totalPurchases,const DeepCollectionEquality().hash(_metricsByPeriod));

@override
String toString() {
  return 'PerformanceMetrics(conversionRate: $conversionRate, averageOrderValue: $averageOrderValue, customerLifetimeValue: $customerLifetimeValue, totalViews: $totalViews, totalPurchases: $totalPurchases, metricsByPeriod: $metricsByPeriod)';
}


}

/// @nodoc
abstract mixin class _$PerformanceMetricsCopyWith<$Res> implements $PerformanceMetricsCopyWith<$Res> {
  factory _$PerformanceMetricsCopyWith(_PerformanceMetrics value, $Res Function(_PerformanceMetrics) _then) = __$PerformanceMetricsCopyWithImpl;
@override @useResult
$Res call({
 double conversionRate, double averageOrderValue, double customerLifetimeValue, int totalViews, int totalPurchases, Map<String, double> metricsByPeriod
});




}
/// @nodoc
class __$PerformanceMetricsCopyWithImpl<$Res>
    implements _$PerformanceMetricsCopyWith<$Res> {
  __$PerformanceMetricsCopyWithImpl(this._self, this._then);

  final _PerformanceMetrics _self;
  final $Res Function(_PerformanceMetrics) _then;

/// Create a copy of PerformanceMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversionRate = null,Object? averageOrderValue = null,Object? customerLifetimeValue = null,Object? totalViews = null,Object? totalPurchases = null,Object? metricsByPeriod = null,}) {
  return _then(_PerformanceMetrics(
conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,averageOrderValue: null == averageOrderValue ? _self.averageOrderValue : averageOrderValue // ignore: cast_nullable_to_non_nullable
as double,customerLifetimeValue: null == customerLifetimeValue ? _self.customerLifetimeValue : customerLifetimeValue // ignore: cast_nullable_to_non_nullable
as double,totalViews: null == totalViews ? _self.totalViews : totalViews // ignore: cast_nullable_to_non_nullable
as int,totalPurchases: null == totalPurchases ? _self.totalPurchases : totalPurchases // ignore: cast_nullable_to_non_nullable
as int,metricsByPeriod: null == metricsByPeriod ? _self._metricsByPeriod : metricsByPeriod // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
