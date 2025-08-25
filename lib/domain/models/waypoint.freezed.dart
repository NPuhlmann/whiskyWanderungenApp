// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'waypoint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Waypoint {

 int get id;@JsonKey(name: 'hike_id') int get hikeId; String get name; String get description; double get latitude; double get longitude;@JsonKey(name: 'order_index') int get orderIndex; List<String> get images;@JsonKey(name: 'is_visited') bool get isVisited;
/// Create a copy of Waypoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaypointCopyWith<Waypoint> get copyWith => _$WaypointCopyWithImpl<Waypoint>(this as Waypoint, _$identity);

  /// Serializes this Waypoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Waypoint&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.isVisited, isVisited) || other.isVisited == isVisited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,name,description,latitude,longitude,orderIndex,const DeepCollectionEquality().hash(images),isVisited);

@override
String toString() {
  return 'Waypoint(id: $id, hikeId: $hikeId, name: $name, description: $description, latitude: $latitude, longitude: $longitude, orderIndex: $orderIndex, images: $images, isVisited: $isVisited)';
}


}

/// @nodoc
abstract mixin class $WaypointCopyWith<$Res>  {
  factory $WaypointCopyWith(Waypoint value, $Res Function(Waypoint) _then) = _$WaypointCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'hike_id') int hikeId, String name, String description, double latitude, double longitude,@JsonKey(name: 'order_index') int orderIndex, List<String> images,@JsonKey(name: 'is_visited') bool isVisited
});




}
/// @nodoc
class _$WaypointCopyWithImpl<$Res>
    implements $WaypointCopyWith<$Res> {
  _$WaypointCopyWithImpl(this._self, this._then);

  final Waypoint _self;
  final $Res Function(Waypoint) _then;

/// Create a copy of Waypoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hikeId = null,Object? name = null,Object? description = null,Object? latitude = null,Object? longitude = null,Object? orderIndex = null,Object? images = null,Object? isVisited = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,isVisited: null == isVisited ? _self.isVisited : isVisited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Waypoint].
extension WaypointPatterns on Waypoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Waypoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Waypoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Waypoint value)  $default,){
final _that = this;
switch (_that) {
case _Waypoint():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Waypoint value)?  $default,){
final _that = this;
switch (_that) {
case _Waypoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'hike_id')  int hikeId,  String name,  String description,  double latitude,  double longitude, @JsonKey(name: 'order_index')  int orderIndex,  List<String> images, @JsonKey(name: 'is_visited')  bool isVisited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Waypoint() when $default != null:
return $default(_that.id,_that.hikeId,_that.name,_that.description,_that.latitude,_that.longitude,_that.orderIndex,_that.images,_that.isVisited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'hike_id')  int hikeId,  String name,  String description,  double latitude,  double longitude, @JsonKey(name: 'order_index')  int orderIndex,  List<String> images, @JsonKey(name: 'is_visited')  bool isVisited)  $default,) {final _that = this;
switch (_that) {
case _Waypoint():
return $default(_that.id,_that.hikeId,_that.name,_that.description,_that.latitude,_that.longitude,_that.orderIndex,_that.images,_that.isVisited);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'hike_id')  int hikeId,  String name,  String description,  double latitude,  double longitude, @JsonKey(name: 'order_index')  int orderIndex,  List<String> images, @JsonKey(name: 'is_visited')  bool isVisited)?  $default,) {final _that = this;
switch (_that) {
case _Waypoint() when $default != null:
return $default(_that.id,_that.hikeId,_that.name,_that.description,_that.latitude,_that.longitude,_that.orderIndex,_that.images,_that.isVisited);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Waypoint implements Waypoint {
  const _Waypoint({required this.id, @JsonKey(name: 'hike_id') required this.hikeId, required this.name, required this.description, required this.latitude, required this.longitude, @JsonKey(name: 'order_index') this.orderIndex = 0, final  List<String> images = const [], @JsonKey(name: 'is_visited') this.isVisited = false}): _images = images;
  factory _Waypoint.fromJson(Map<String, dynamic> json) => _$WaypointFromJson(json);

@override final  int id;
@override@JsonKey(name: 'hike_id') final  int hikeId;
@override final  String name;
@override final  String description;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey(name: 'order_index') final  int orderIndex;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'is_visited') final  bool isVisited;

/// Create a copy of Waypoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaypointCopyWith<_Waypoint> get copyWith => __$WaypointCopyWithImpl<_Waypoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaypointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Waypoint&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.isVisited, isVisited) || other.isVisited == isVisited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,name,description,latitude,longitude,orderIndex,const DeepCollectionEquality().hash(_images),isVisited);

@override
String toString() {
  return 'Waypoint(id: $id, hikeId: $hikeId, name: $name, description: $description, latitude: $latitude, longitude: $longitude, orderIndex: $orderIndex, images: $images, isVisited: $isVisited)';
}


}

/// @nodoc
abstract mixin class _$WaypointCopyWith<$Res> implements $WaypointCopyWith<$Res> {
  factory _$WaypointCopyWith(_Waypoint value, $Res Function(_Waypoint) _then) = __$WaypointCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'hike_id') int hikeId, String name, String description, double latitude, double longitude,@JsonKey(name: 'order_index') int orderIndex, List<String> images,@JsonKey(name: 'is_visited') bool isVisited
});




}
/// @nodoc
class __$WaypointCopyWithImpl<$Res>
    implements _$WaypointCopyWith<$Res> {
  __$WaypointCopyWithImpl(this._self, this._then);

  final _Waypoint _self;
  final $Res Function(_Waypoint) _then;

/// Create a copy of Waypoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hikeId = null,Object? name = null,Object? description = null,Object? latitude = null,Object? longitude = null,Object? orderIndex = null,Object? images = null,Object? isVisited = null,}) {
  return _then(_Waypoint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,isVisited: null == isVisited ? _self.isVisited : isVisited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
