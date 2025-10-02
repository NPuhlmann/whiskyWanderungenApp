// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_performance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutePerformance {

 int get routeId; String get routeName; int get totalSales; double get totalRevenue; double get averageRating; int get reviewCount; double get conversionRate; int get totalViews; Map<String, int> get salesByMonth;
/// Create a copy of RoutePerformance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutePerformanceCopyWith<RoutePerformance> get copyWith => _$RoutePerformanceCopyWithImpl<RoutePerformance>(this as RoutePerformance, _$identity);

  /// Serializes this RoutePerformance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutePerformance&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&(identical(other.totalViews, totalViews) || other.totalViews == totalViews)&&const DeepCollectionEquality().equals(other.salesByMonth, salesByMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routeId,routeName,totalSales,totalRevenue,averageRating,reviewCount,conversionRate,totalViews,const DeepCollectionEquality().hash(salesByMonth));

@override
String toString() {
  return 'RoutePerformance(routeId: $routeId, routeName: $routeName, totalSales: $totalSales, totalRevenue: $totalRevenue, averageRating: $averageRating, reviewCount: $reviewCount, conversionRate: $conversionRate, totalViews: $totalViews, salesByMonth: $salesByMonth)';
}


}

/// @nodoc
abstract mixin class $RoutePerformanceCopyWith<$Res>  {
  factory $RoutePerformanceCopyWith(RoutePerformance value, $Res Function(RoutePerformance) _then) = _$RoutePerformanceCopyWithImpl;
@useResult
$Res call({
 int routeId, String routeName, int totalSales, double totalRevenue, double averageRating, int reviewCount, double conversionRate, int totalViews, Map<String, int> salesByMonth
});




}
/// @nodoc
class _$RoutePerformanceCopyWithImpl<$Res>
    implements $RoutePerformanceCopyWith<$Res> {
  _$RoutePerformanceCopyWithImpl(this._self, this._then);

  final RoutePerformance _self;
  final $Res Function(RoutePerformance) _then;

/// Create a copy of RoutePerformance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routeId = null,Object? routeName = null,Object? totalSales = null,Object? totalRevenue = null,Object? averageRating = null,Object? reviewCount = null,Object? conversionRate = null,Object? totalViews = null,Object? salesByMonth = null,}) {
  return _then(_self.copyWith(
routeId: null == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as int,routeName: null == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String,totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,totalViews: null == totalViews ? _self.totalViews : totalViews // ignore: cast_nullable_to_non_nullable
as int,salesByMonth: null == salesByMonth ? _self.salesByMonth : salesByMonth // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutePerformance].
extension RoutePerformancePatterns on RoutePerformance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutePerformance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutePerformance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutePerformance value)  $default,){
final _that = this;
switch (_that) {
case _RoutePerformance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutePerformance value)?  $default,){
final _that = this;
switch (_that) {
case _RoutePerformance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int routeId,  String routeName,  int totalSales,  double totalRevenue,  double averageRating,  int reviewCount,  double conversionRate,  int totalViews,  Map<String, int> salesByMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutePerformance() when $default != null:
return $default(_that.routeId,_that.routeName,_that.totalSales,_that.totalRevenue,_that.averageRating,_that.reviewCount,_that.conversionRate,_that.totalViews,_that.salesByMonth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int routeId,  String routeName,  int totalSales,  double totalRevenue,  double averageRating,  int reviewCount,  double conversionRate,  int totalViews,  Map<String, int> salesByMonth)  $default,) {final _that = this;
switch (_that) {
case _RoutePerformance():
return $default(_that.routeId,_that.routeName,_that.totalSales,_that.totalRevenue,_that.averageRating,_that.reviewCount,_that.conversionRate,_that.totalViews,_that.salesByMonth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int routeId,  String routeName,  int totalSales,  double totalRevenue,  double averageRating,  int reviewCount,  double conversionRate,  int totalViews,  Map<String, int> salesByMonth)?  $default,) {final _that = this;
switch (_that) {
case _RoutePerformance() when $default != null:
return $default(_that.routeId,_that.routeName,_that.totalSales,_that.totalRevenue,_that.averageRating,_that.reviewCount,_that.conversionRate,_that.totalViews,_that.salesByMonth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutePerformance extends RoutePerformance {
  const _RoutePerformance({required this.routeId, required this.routeName, required this.totalSales, required this.totalRevenue, required this.averageRating, required this.reviewCount, required this.conversionRate, required this.totalViews, final  Map<String, int> salesByMonth = const {}}): _salesByMonth = salesByMonth,super._();
  factory _RoutePerformance.fromJson(Map<String, dynamic> json) => _$RoutePerformanceFromJson(json);

@override final  int routeId;
@override final  String routeName;
@override final  int totalSales;
@override final  double totalRevenue;
@override final  double averageRating;
@override final  int reviewCount;
@override final  double conversionRate;
@override final  int totalViews;
 final  Map<String, int> _salesByMonth;
@override@JsonKey() Map<String, int> get salesByMonth {
  if (_salesByMonth is EqualUnmodifiableMapView) return _salesByMonth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_salesByMonth);
}


/// Create a copy of RoutePerformance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutePerformanceCopyWith<_RoutePerformance> get copyWith => __$RoutePerformanceCopyWithImpl<_RoutePerformance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutePerformanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutePerformance&&(identical(other.routeId, routeId) || other.routeId == routeId)&&(identical(other.routeName, routeName) || other.routeName == routeName)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.conversionRate, conversionRate) || other.conversionRate == conversionRate)&&(identical(other.totalViews, totalViews) || other.totalViews == totalViews)&&const DeepCollectionEquality().equals(other._salesByMonth, _salesByMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routeId,routeName,totalSales,totalRevenue,averageRating,reviewCount,conversionRate,totalViews,const DeepCollectionEquality().hash(_salesByMonth));

@override
String toString() {
  return 'RoutePerformance(routeId: $routeId, routeName: $routeName, totalSales: $totalSales, totalRevenue: $totalRevenue, averageRating: $averageRating, reviewCount: $reviewCount, conversionRate: $conversionRate, totalViews: $totalViews, salesByMonth: $salesByMonth)';
}


}

/// @nodoc
abstract mixin class _$RoutePerformanceCopyWith<$Res> implements $RoutePerformanceCopyWith<$Res> {
  factory _$RoutePerformanceCopyWith(_RoutePerformance value, $Res Function(_RoutePerformance) _then) = __$RoutePerformanceCopyWithImpl;
@override @useResult
$Res call({
 int routeId, String routeName, int totalSales, double totalRevenue, double averageRating, int reviewCount, double conversionRate, int totalViews, Map<String, int> salesByMonth
});




}
/// @nodoc
class __$RoutePerformanceCopyWithImpl<$Res>
    implements _$RoutePerformanceCopyWith<$Res> {
  __$RoutePerformanceCopyWithImpl(this._self, this._then);

  final _RoutePerformance _self;
  final $Res Function(_RoutePerformance) _then;

/// Create a copy of RoutePerformance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routeId = null,Object? routeName = null,Object? totalSales = null,Object? totalRevenue = null,Object? averageRating = null,Object? reviewCount = null,Object? conversionRate = null,Object? totalViews = null,Object? salesByMonth = null,}) {
  return _then(_RoutePerformance(
routeId: null == routeId ? _self.routeId : routeId // ignore: cast_nullable_to_non_nullable
as int,routeName: null == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String,totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,conversionRate: null == conversionRate ? _self.conversionRate : conversionRate // ignore: cast_nullable_to_non_nullable
as double,totalViews: null == totalViews ? _self.totalViews : totalViews // ignore: cast_nullable_to_non_nullable
as int,salesByMonth: null == salesByMonth ? _self._salesByMonth : salesByMonth // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
