// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasting_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WhiskySample {

 int get id; String get name; String get distillery; int get age; String get region;@JsonKey(name: 'tasting_notes') String get tastingNotes;@JsonKey(name: 'image_url') String get imageUrl; double get abv;// Alcohol by volume
 String? get category;// Single Malt, Blend, etc.
@JsonKey(name: 'sample_size_ml') double get sampleSizeMl;@JsonKey(name: 'order_index') int get orderIndex;
/// Create a copy of WhiskySample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhiskySampleCopyWith<WhiskySample> get copyWith => _$WhiskySampleCopyWithImpl<WhiskySample>(this as WhiskySample, _$identity);

  /// Serializes this WhiskySample to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhiskySample&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.distillery, distillery) || other.distillery == distillery)&&(identical(other.age, age) || other.age == age)&&(identical(other.region, region) || other.region == region)&&(identical(other.tastingNotes, tastingNotes) || other.tastingNotes == tastingNotes)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.abv, abv) || other.abv == abv)&&(identical(other.category, category) || other.category == category)&&(identical(other.sampleSizeMl, sampleSizeMl) || other.sampleSizeMl == sampleSizeMl)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,distillery,age,region,tastingNotes,imageUrl,abv,category,sampleSizeMl,orderIndex);

@override
String toString() {
  return 'WhiskySample(id: $id, name: $name, distillery: $distillery, age: $age, region: $region, tastingNotes: $tastingNotes, imageUrl: $imageUrl, abv: $abv, category: $category, sampleSizeMl: $sampleSizeMl, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class $WhiskySampleCopyWith<$Res>  {
  factory $WhiskySampleCopyWith(WhiskySample value, $Res Function(WhiskySample) _then) = _$WhiskySampleCopyWithImpl;
@useResult
$Res call({
 int id, String name, String distillery, int age, String region,@JsonKey(name: 'tasting_notes') String tastingNotes,@JsonKey(name: 'image_url') String imageUrl, double abv, String? category,@JsonKey(name: 'sample_size_ml') double sampleSizeMl,@JsonKey(name: 'order_index') int orderIndex
});




}
/// @nodoc
class _$WhiskySampleCopyWithImpl<$Res>
    implements $WhiskySampleCopyWith<$Res> {
  _$WhiskySampleCopyWithImpl(this._self, this._then);

  final WhiskySample _self;
  final $Res Function(WhiskySample) _then;

/// Create a copy of WhiskySample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? distillery = null,Object? age = null,Object? region = null,Object? tastingNotes = null,Object? imageUrl = null,Object? abv = null,Object? category = freezed,Object? sampleSizeMl = null,Object? orderIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,distillery: null == distillery ? _self.distillery : distillery // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,tastingNotes: null == tastingNotes ? _self.tastingNotes : tastingNotes // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,abv: null == abv ? _self.abv : abv // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,sampleSizeMl: null == sampleSizeMl ? _self.sampleSizeMl : sampleSizeMl // ignore: cast_nullable_to_non_nullable
as double,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WhiskySample].
extension WhiskySamplePatterns on WhiskySample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WhiskySample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WhiskySample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WhiskySample value)  $default,){
final _that = this;
switch (_that) {
case _WhiskySample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WhiskySample value)?  $default,){
final _that = this;
switch (_that) {
case _WhiskySample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String distillery,  int age,  String region, @JsonKey(name: 'tasting_notes')  String tastingNotes, @JsonKey(name: 'image_url')  String imageUrl,  double abv,  String? category, @JsonKey(name: 'sample_size_ml')  double sampleSizeMl, @JsonKey(name: 'order_index')  int orderIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WhiskySample() when $default != null:
return $default(_that.id,_that.name,_that.distillery,_that.age,_that.region,_that.tastingNotes,_that.imageUrl,_that.abv,_that.category,_that.sampleSizeMl,_that.orderIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String distillery,  int age,  String region, @JsonKey(name: 'tasting_notes')  String tastingNotes, @JsonKey(name: 'image_url')  String imageUrl,  double abv,  String? category, @JsonKey(name: 'sample_size_ml')  double sampleSizeMl, @JsonKey(name: 'order_index')  int orderIndex)  $default,) {final _that = this;
switch (_that) {
case _WhiskySample():
return $default(_that.id,_that.name,_that.distillery,_that.age,_that.region,_that.tastingNotes,_that.imageUrl,_that.abv,_that.category,_that.sampleSizeMl,_that.orderIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String distillery,  int age,  String region, @JsonKey(name: 'tasting_notes')  String tastingNotes, @JsonKey(name: 'image_url')  String imageUrl,  double abv,  String? category, @JsonKey(name: 'sample_size_ml')  double sampleSizeMl, @JsonKey(name: 'order_index')  int orderIndex)?  $default,) {final _that = this;
switch (_that) {
case _WhiskySample() when $default != null:
return $default(_that.id,_that.name,_that.distillery,_that.age,_that.region,_that.tastingNotes,_that.imageUrl,_that.abv,_that.category,_that.sampleSizeMl,_that.orderIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WhiskySample implements WhiskySample {
  const _WhiskySample({required this.id, required this.name, required this.distillery, required this.age, required this.region, @JsonKey(name: 'tasting_notes') required this.tastingNotes, @JsonKey(name: 'image_url') required this.imageUrl, required this.abv, this.category, @JsonKey(name: 'sample_size_ml') this.sampleSizeMl = 5.0, @JsonKey(name: 'order_index') this.orderIndex = 0});
  factory _WhiskySample.fromJson(Map<String, dynamic> json) => _$WhiskySampleFromJson(json);

@override final  int id;
@override final  String name;
@override final  String distillery;
@override final  int age;
@override final  String region;
@override@JsonKey(name: 'tasting_notes') final  String tastingNotes;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override final  double abv;
// Alcohol by volume
@override final  String? category;
// Single Malt, Blend, etc.
@override@JsonKey(name: 'sample_size_ml') final  double sampleSizeMl;
@override@JsonKey(name: 'order_index') final  int orderIndex;

/// Create a copy of WhiskySample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WhiskySampleCopyWith<_WhiskySample> get copyWith => __$WhiskySampleCopyWithImpl<_WhiskySample>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WhiskySampleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WhiskySample&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.distillery, distillery) || other.distillery == distillery)&&(identical(other.age, age) || other.age == age)&&(identical(other.region, region) || other.region == region)&&(identical(other.tastingNotes, tastingNotes) || other.tastingNotes == tastingNotes)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.abv, abv) || other.abv == abv)&&(identical(other.category, category) || other.category == category)&&(identical(other.sampleSizeMl, sampleSizeMl) || other.sampleSizeMl == sampleSizeMl)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,distillery,age,region,tastingNotes,imageUrl,abv,category,sampleSizeMl,orderIndex);

@override
String toString() {
  return 'WhiskySample(id: $id, name: $name, distillery: $distillery, age: $age, region: $region, tastingNotes: $tastingNotes, imageUrl: $imageUrl, abv: $abv, category: $category, sampleSizeMl: $sampleSizeMl, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class _$WhiskySampleCopyWith<$Res> implements $WhiskySampleCopyWith<$Res> {
  factory _$WhiskySampleCopyWith(_WhiskySample value, $Res Function(_WhiskySample) _then) = __$WhiskySampleCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String distillery, int age, String region,@JsonKey(name: 'tasting_notes') String tastingNotes,@JsonKey(name: 'image_url') String imageUrl, double abv, String? category,@JsonKey(name: 'sample_size_ml') double sampleSizeMl,@JsonKey(name: 'order_index') int orderIndex
});




}
/// @nodoc
class __$WhiskySampleCopyWithImpl<$Res>
    implements _$WhiskySampleCopyWith<$Res> {
  __$WhiskySampleCopyWithImpl(this._self, this._then);

  final _WhiskySample _self;
  final $Res Function(_WhiskySample) _then;

/// Create a copy of WhiskySample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? distillery = null,Object? age = null,Object? region = null,Object? tastingNotes = null,Object? imageUrl = null,Object? abv = null,Object? category = freezed,Object? sampleSizeMl = null,Object? orderIndex = null,}) {
  return _then(_WhiskySample(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,distillery: null == distillery ? _self.distillery : distillery // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,tastingNotes: null == tastingNotes ? _self.tastingNotes : tastingNotes // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,abv: null == abv ? _self.abv : abv // ignore: cast_nullable_to_non_nullable
as double,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,sampleSizeMl: null == sampleSizeMl ? _self.sampleSizeMl : sampleSizeMl // ignore: cast_nullable_to_non_nullable
as double,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TastingSet {

 int get id;@JsonKey(name: 'hike_id') int get hikeId; String get name; String get description; List<WhiskySample> get samples; double get price;// Always 0 since it's included in hike price
@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'is_included') bool get isIncluded;// Always true
@JsonKey(name: 'is_available') bool get isAvailable;@JsonKey(name: 'available_from') DateTime? get availableFrom;@JsonKey(name: 'available_until') DateTime? get availableUntil;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of TastingSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TastingSetCopyWith<TastingSet> get copyWith => _$TastingSetCopyWithImpl<TastingSet>(this as TastingSet, _$identity);

  /// Serializes this TastingSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TastingSet&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.samples, samples)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isIncluded, isIncluded) || other.isIncluded == isIncluded)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,name,description,const DeepCollectionEquality().hash(samples),price,imageUrl,isIncluded,isAvailable,availableFrom,availableUntil,createdAt,updatedAt);

@override
String toString() {
  return 'TastingSet(id: $id, hikeId: $hikeId, name: $name, description: $description, samples: $samples, price: $price, imageUrl: $imageUrl, isIncluded: $isIncluded, isAvailable: $isAvailable, availableFrom: $availableFrom, availableUntil: $availableUntil, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TastingSetCopyWith<$Res>  {
  factory $TastingSetCopyWith(TastingSet value, $Res Function(TastingSet) _then) = _$TastingSetCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'hike_id') int hikeId, String name, String description, List<WhiskySample> samples, double price,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'is_included') bool isIncluded,@JsonKey(name: 'is_available') bool isAvailable,@JsonKey(name: 'available_from') DateTime? availableFrom,@JsonKey(name: 'available_until') DateTime? availableUntil,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$TastingSetCopyWithImpl<$Res>
    implements $TastingSetCopyWith<$Res> {
  _$TastingSetCopyWithImpl(this._self, this._then);

  final TastingSet _self;
  final $Res Function(TastingSet) _then;

/// Create a copy of TastingSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hikeId = null,Object? name = null,Object? description = null,Object? samples = null,Object? price = null,Object? imageUrl = freezed,Object? isIncluded = null,Object? isAvailable = null,Object? availableFrom = freezed,Object? availableUntil = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,samples: null == samples ? _self.samples : samples // ignore: cast_nullable_to_non_nullable
as List<WhiskySample>,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isIncluded: null == isIncluded ? _self.isIncluded : isIncluded // ignore: cast_nullable_to_non_nullable
as bool,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,availableFrom: freezed == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,availableUntil: freezed == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TastingSet].
extension TastingSetPatterns on TastingSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TastingSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TastingSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TastingSet value)  $default,){
final _that = this;
switch (_that) {
case _TastingSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TastingSet value)?  $default,){
final _that = this;
switch (_that) {
case _TastingSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'hike_id')  int hikeId,  String name,  String description,  List<WhiskySample> samples,  double price, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'is_included')  bool isIncluded, @JsonKey(name: 'is_available')  bool isAvailable, @JsonKey(name: 'available_from')  DateTime? availableFrom, @JsonKey(name: 'available_until')  DateTime? availableUntil, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TastingSet() when $default != null:
return $default(_that.id,_that.hikeId,_that.name,_that.description,_that.samples,_that.price,_that.imageUrl,_that.isIncluded,_that.isAvailable,_that.availableFrom,_that.availableUntil,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'hike_id')  int hikeId,  String name,  String description,  List<WhiskySample> samples,  double price, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'is_included')  bool isIncluded, @JsonKey(name: 'is_available')  bool isAvailable, @JsonKey(name: 'available_from')  DateTime? availableFrom, @JsonKey(name: 'available_until')  DateTime? availableUntil, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TastingSet():
return $default(_that.id,_that.hikeId,_that.name,_that.description,_that.samples,_that.price,_that.imageUrl,_that.isIncluded,_that.isAvailable,_that.availableFrom,_that.availableUntil,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'hike_id')  int hikeId,  String name,  String description,  List<WhiskySample> samples,  double price, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'is_included')  bool isIncluded, @JsonKey(name: 'is_available')  bool isAvailable, @JsonKey(name: 'available_from')  DateTime? availableFrom, @JsonKey(name: 'available_until')  DateTime? availableUntil, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TastingSet() when $default != null:
return $default(_that.id,_that.hikeId,_that.name,_that.description,_that.samples,_that.price,_that.imageUrl,_that.isIncluded,_that.isAvailable,_that.availableFrom,_that.availableUntil,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TastingSet implements TastingSet {
  const _TastingSet({required this.id, @JsonKey(name: 'hike_id') required this.hikeId, required this.name, required this.description, required final  List<WhiskySample> samples, this.price = 0.0, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'is_included') this.isIncluded = true, @JsonKey(name: 'is_available') this.isAvailable = true, @JsonKey(name: 'available_from') this.availableFrom, @JsonKey(name: 'available_until') this.availableUntil, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _samples = samples;
  factory _TastingSet.fromJson(Map<String, dynamic> json) => _$TastingSetFromJson(json);

@override final  int id;
@override@JsonKey(name: 'hike_id') final  int hikeId;
@override final  String name;
@override final  String description;
 final  List<WhiskySample> _samples;
@override List<WhiskySample> get samples {
  if (_samples is EqualUnmodifiableListView) return _samples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_samples);
}

@override@JsonKey() final  double price;
// Always 0 since it's included in hike price
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'is_included') final  bool isIncluded;
// Always true
@override@JsonKey(name: 'is_available') final  bool isAvailable;
@override@JsonKey(name: 'available_from') final  DateTime? availableFrom;
@override@JsonKey(name: 'available_until') final  DateTime? availableUntil;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of TastingSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TastingSetCopyWith<_TastingSet> get copyWith => __$TastingSetCopyWithImpl<_TastingSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TastingSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TastingSet&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._samples, _samples)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isIncluded, isIncluded) || other.isIncluded == isIncluded)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,name,description,const DeepCollectionEquality().hash(_samples),price,imageUrl,isIncluded,isAvailable,availableFrom,availableUntil,createdAt,updatedAt);

@override
String toString() {
  return 'TastingSet(id: $id, hikeId: $hikeId, name: $name, description: $description, samples: $samples, price: $price, imageUrl: $imageUrl, isIncluded: $isIncluded, isAvailable: $isAvailable, availableFrom: $availableFrom, availableUntil: $availableUntil, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TastingSetCopyWith<$Res> implements $TastingSetCopyWith<$Res> {
  factory _$TastingSetCopyWith(_TastingSet value, $Res Function(_TastingSet) _then) = __$TastingSetCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'hike_id') int hikeId, String name, String description, List<WhiskySample> samples, double price,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'is_included') bool isIncluded,@JsonKey(name: 'is_available') bool isAvailable,@JsonKey(name: 'available_from') DateTime? availableFrom,@JsonKey(name: 'available_until') DateTime? availableUntil,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$TastingSetCopyWithImpl<$Res>
    implements _$TastingSetCopyWith<$Res> {
  __$TastingSetCopyWithImpl(this._self, this._then);

  final _TastingSet _self;
  final $Res Function(_TastingSet) _then;

/// Create a copy of TastingSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hikeId = null,Object? name = null,Object? description = null,Object? samples = null,Object? price = null,Object? imageUrl = freezed,Object? isIncluded = null,Object? isAvailable = null,Object? availableFrom = freezed,Object? availableUntil = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_TastingSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,samples: null == samples ? _self._samples : samples // ignore: cast_nullable_to_non_nullable
as List<WhiskySample>,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isIncluded: null == isIncluded ? _self.isIncluded : isIncluded // ignore: cast_nullable_to_non_nullable
as bool,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,availableFrom: freezed == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,availableUntil: freezed == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
