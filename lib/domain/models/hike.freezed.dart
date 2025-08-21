// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hike.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Hike {

// die id des hikes
 int get id; String get name; double get length; double get steep; int get elevation; String get description; double get price; Difficulty get difficulty; String? get thumbnail_image_url; bool get isFavorite;
/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HikeCopyWith<Hike> get copyWith => _$HikeCopyWithImpl<Hike>(this as Hike, _$identity);

  /// Serializes this Hike to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hike&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.length, length) || other.length == length)&&(identical(other.steep, steep) || other.steep == steep)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.thumbnail_image_url, thumbnail_image_url) || other.thumbnail_image_url == thumbnail_image_url)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,length,steep,elevation,description,price,difficulty,thumbnail_image_url,isFavorite);

@override
String toString() {
  return 'Hike(id: $id, name: $name, length: $length, steep: $steep, elevation: $elevation, description: $description, price: $price, difficulty: $difficulty, thumbnail_image_url: $thumbnail_image_url, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class $HikeCopyWith<$Res>  {
  factory $HikeCopyWith(Hike value, $Res Function(Hike) _then) = _$HikeCopyWithImpl;
@useResult
$Res call({
 int id, String name, double length, double steep, int elevation, String description, double price, Difficulty difficulty, String? thumbnail_image_url, bool isFavorite
});




}
/// @nodoc
class _$HikeCopyWithImpl<$Res>
    implements $HikeCopyWith<$Res> {
  _$HikeCopyWithImpl(this._self, this._then);

  final Hike _self;
  final $Res Function(Hike) _then;

/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? length = null,Object? steep = null,Object? elevation = null,Object? description = null,Object? price = null,Object? difficulty = null,Object? thumbnail_image_url = freezed,Object? isFavorite = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as double,steep: null == steep ? _self.steep : steep // ignore: cast_nullable_to_non_nullable
as double,elevation: null == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,thumbnail_image_url: freezed == thumbnail_image_url ? _self.thumbnail_image_url : thumbnail_image_url // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Hike].
extension HikePatterns on Hike {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hike value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hike() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hike value)  $default,){
final _that = this;
switch (_that) {
case _Hike():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hike value)?  $default,){
final _that = this;
switch (_that) {
case _Hike() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  double length,  double steep,  int elevation,  String description,  double price,  Difficulty difficulty,  String? thumbnail_image_url,  bool isFavorite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hike() when $default != null:
return $default(_that.id,_that.name,_that.length,_that.steep,_that.elevation,_that.description,_that.price,_that.difficulty,_that.thumbnail_image_url,_that.isFavorite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  double length,  double steep,  int elevation,  String description,  double price,  Difficulty difficulty,  String? thumbnail_image_url,  bool isFavorite)  $default,) {final _that = this;
switch (_that) {
case _Hike():
return $default(_that.id,_that.name,_that.length,_that.steep,_that.elevation,_that.description,_that.price,_that.difficulty,_that.thumbnail_image_url,_that.isFavorite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  double length,  double steep,  int elevation,  String description,  double price,  Difficulty difficulty,  String? thumbnail_image_url,  bool isFavorite)?  $default,) {final _that = this;
switch (_that) {
case _Hike() when $default != null:
return $default(_that.id,_that.name,_that.length,_that.steep,_that.elevation,_that.description,_that.price,_that.difficulty,_that.thumbnail_image_url,_that.isFavorite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hike implements Hike {
   _Hike({required this.id, this.name = '', this.length = 1.0, this.steep = 0.2, this.elevation = 100, this.description = '', this.price = 1.0, this.difficulty = Difficulty.mid, this.thumbnail_image_url, this.isFavorite = false});
  factory _Hike.fromJson(Map<String, dynamic> json) => _$HikeFromJson(json);

// die id des hikes
@override final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  double length;
@override@JsonKey() final  double steep;
@override@JsonKey() final  int elevation;
@override@JsonKey() final  String description;
@override@JsonKey() final  double price;
@override@JsonKey() final  Difficulty difficulty;
@override final  String? thumbnail_image_url;
@override@JsonKey() final  bool isFavorite;

/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HikeCopyWith<_Hike> get copyWith => __$HikeCopyWithImpl<_Hike>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HikeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hike&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.length, length) || other.length == length)&&(identical(other.steep, steep) || other.steep == steep)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.thumbnail_image_url, thumbnail_image_url) || other.thumbnail_image_url == thumbnail_image_url)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,length,steep,elevation,description,price,difficulty,thumbnail_image_url,isFavorite);

@override
String toString() {
  return 'Hike(id: $id, name: $name, length: $length, steep: $steep, elevation: $elevation, description: $description, price: $price, difficulty: $difficulty, thumbnail_image_url: $thumbnail_image_url, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class _$HikeCopyWith<$Res> implements $HikeCopyWith<$Res> {
  factory _$HikeCopyWith(_Hike value, $Res Function(_Hike) _then) = __$HikeCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, double length, double steep, int elevation, String description, double price, Difficulty difficulty, String? thumbnail_image_url, bool isFavorite
});




}
/// @nodoc
class __$HikeCopyWithImpl<$Res>
    implements _$HikeCopyWith<$Res> {
  __$HikeCopyWithImpl(this._self, this._then);

  final _Hike _self;
  final $Res Function(_Hike) _then;

/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? length = null,Object? steep = null,Object? elevation = null,Object? description = null,Object? price = null,Object? difficulty = null,Object? thumbnail_image_url = freezed,Object? isFavorite = null,}) {
  return _then(_Hike(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as double,steep: null == steep ? _self.steep : steep // ignore: cast_nullable_to_non_nullable
as double,elevation: null == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,thumbnail_image_url: freezed == thumbnail_image_url ? _self.thumbnail_image_url : thumbnail_image_url // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
