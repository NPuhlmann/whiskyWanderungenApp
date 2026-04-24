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
 int get id; String get name; double get length; double get steep; int get elevation; String get description; double get price; Difficulty get difficulty;@JsonKey(name: 'thumbnail_image_url') String? get thumbnailImageUrl;@JsonKey(name: 'is_favorite') bool get isFavorite;// Multi-Vendor System Erweiterungen
@JsonKey(name: 'company_id') String? get companyId; Company? get company;// Populated via JOIN oder separater API call
// Zusätzliche Felder für erweiterte Funktionalität
 bool get isAvailable; DateTime? get availableFrom; DateTime? get availableUntil;// Kategorisierung
 String get category; List<String> get tags;// z.B. ['Highland', 'Scotch', 'Premium']
// Rating System (für zukünftige Review-Funktionalität)
 double get averageRating; int get reviewCount;// System Fields
@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HikeCopyWith<Hike> get copyWith => _$HikeCopyWithImpl<Hike>(this as Hike, _$identity);

  /// Serializes this Hike to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hike&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.length, length) || other.length == length)&&(identical(other.steep, steep) || other.steep == steep)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.thumbnailImageUrl, thumbnailImageUrl) || other.thumbnailImageUrl == thumbnailImageUrl)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,length,steep,elevation,description,price,difficulty,thumbnailImageUrl,isFavorite,companyId,company,isAvailable,availableFrom,availableUntil,category,const DeepCollectionEquality().hash(tags),averageRating,reviewCount,createdAt,updatedAt]);

@override
String toString() {
  return 'Hike(id: $id, name: $name, length: $length, steep: $steep, elevation: $elevation, description: $description, price: $price, difficulty: $difficulty, thumbnailImageUrl: $thumbnailImageUrl, isFavorite: $isFavorite, companyId: $companyId, company: $company, isAvailable: $isAvailable, availableFrom: $availableFrom, availableUntil: $availableUntil, category: $category, tags: $tags, averageRating: $averageRating, reviewCount: $reviewCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HikeCopyWith<$Res>  {
  factory $HikeCopyWith(Hike value, $Res Function(Hike) _then) = _$HikeCopyWithImpl;
@useResult
$Res call({
 int id, String name, double length, double steep, int elevation, String description, double price, Difficulty difficulty,@JsonKey(name: 'thumbnail_image_url') String? thumbnailImageUrl,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'company_id') String? companyId, Company? company, bool isAvailable, DateTime? availableFrom, DateTime? availableUntil, String category, List<String> tags, double averageRating, int reviewCount,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});


$CompanyCopyWith<$Res>? get company;

}
/// @nodoc
class _$HikeCopyWithImpl<$Res>
    implements $HikeCopyWith<$Res> {
  _$HikeCopyWithImpl(this._self, this._then);

  final Hike _self;
  final $Res Function(Hike) _then;

/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? length = null,Object? steep = null,Object? elevation = null,Object? description = null,Object? price = null,Object? difficulty = null,Object? thumbnailImageUrl = freezed,Object? isFavorite = null,Object? companyId = freezed,Object? company = freezed,Object? isAvailable = null,Object? availableFrom = freezed,Object? availableUntil = freezed,Object? category = null,Object? tags = null,Object? averageRating = null,Object? reviewCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as double,steep: null == steep ? _self.steep : steep // ignore: cast_nullable_to_non_nullable
as double,elevation: null == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,thumbnailImageUrl: freezed == thumbnailImageUrl ? _self.thumbnailImageUrl : thumbnailImageUrl // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,availableFrom: freezed == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,availableUntil: freezed == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res>? get company {
    if (_self.company == null) {
    return null;
  }

  return $CompanyCopyWith<$Res>(_self.company!, (value) {
    return _then(_self.copyWith(company: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  double length,  double steep,  int elevation,  String description,  double price,  Difficulty difficulty, @JsonKey(name: 'thumbnail_image_url')  String? thumbnailImageUrl, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'company_id')  String? companyId,  Company? company,  bool isAvailable,  DateTime? availableFrom,  DateTime? availableUntil,  String category,  List<String> tags,  double averageRating,  int reviewCount, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hike() when $default != null:
return $default(_that.id,_that.name,_that.length,_that.steep,_that.elevation,_that.description,_that.price,_that.difficulty,_that.thumbnailImageUrl,_that.isFavorite,_that.companyId,_that.company,_that.isAvailable,_that.availableFrom,_that.availableUntil,_that.category,_that.tags,_that.averageRating,_that.reviewCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  double length,  double steep,  int elevation,  String description,  double price,  Difficulty difficulty, @JsonKey(name: 'thumbnail_image_url')  String? thumbnailImageUrl, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'company_id')  String? companyId,  Company? company,  bool isAvailable,  DateTime? availableFrom,  DateTime? availableUntil,  String category,  List<String> tags,  double averageRating,  int reviewCount, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Hike():
return $default(_that.id,_that.name,_that.length,_that.steep,_that.elevation,_that.description,_that.price,_that.difficulty,_that.thumbnailImageUrl,_that.isFavorite,_that.companyId,_that.company,_that.isAvailable,_that.availableFrom,_that.availableUntil,_that.category,_that.tags,_that.averageRating,_that.reviewCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  double length,  double steep,  int elevation,  String description,  double price,  Difficulty difficulty, @JsonKey(name: 'thumbnail_image_url')  String? thumbnailImageUrl, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'company_id')  String? companyId,  Company? company,  bool isAvailable,  DateTime? availableFrom,  DateTime? availableUntil,  String category,  List<String> tags,  double averageRating,  int reviewCount, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Hike() when $default != null:
return $default(_that.id,_that.name,_that.length,_that.steep,_that.elevation,_that.description,_that.price,_that.difficulty,_that.thumbnailImageUrl,_that.isFavorite,_that.companyId,_that.company,_that.isAvailable,_that.availableFrom,_that.availableUntil,_that.category,_that.tags,_that.averageRating,_that.reviewCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hike implements Hike {
  const _Hike({required this.id, this.name = '', this.length = 1.0, this.steep = 0.2, this.elevation = 100, this.description = '', this.price = 1.0, this.difficulty = Difficulty.mid, @JsonKey(name: 'thumbnail_image_url') this.thumbnailImageUrl, @JsonKey(name: 'is_favorite') this.isFavorite = false, @JsonKey(name: 'company_id') this.companyId, this.company, this.isAvailable = true, this.availableFrom, this.availableUntil, this.category = 'Whisky', final  List<String> tags = const [], this.averageRating = 0.0, this.reviewCount = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _tags = tags;
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
@override@JsonKey(name: 'thumbnail_image_url') final  String? thumbnailImageUrl;
@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
// Multi-Vendor System Erweiterungen
@override@JsonKey(name: 'company_id') final  String? companyId;
@override final  Company? company;
// Populated via JOIN oder separater API call
// Zusätzliche Felder für erweiterte Funktionalität
@override@JsonKey() final  bool isAvailable;
@override final  DateTime? availableFrom;
@override final  DateTime? availableUntil;
// Kategorisierung
@override@JsonKey() final  String category;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

// z.B. ['Highland', 'Scotch', 'Premium']
// Rating System (für zukünftige Review-Funktionalität)
@override@JsonKey() final  double averageRating;
@override@JsonKey() final  int reviewCount;
// System Fields
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hike&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.length, length) || other.length == length)&&(identical(other.steep, steep) || other.steep == steep)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.thumbnailImageUrl, thumbnailImageUrl) || other.thumbnailImageUrl == thumbnailImageUrl)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.availableFrom, availableFrom) || other.availableFrom == availableFrom)&&(identical(other.availableUntil, availableUntil) || other.availableUntil == availableUntil)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,length,steep,elevation,description,price,difficulty,thumbnailImageUrl,isFavorite,companyId,company,isAvailable,availableFrom,availableUntil,category,const DeepCollectionEquality().hash(_tags),averageRating,reviewCount,createdAt,updatedAt]);

@override
String toString() {
  return 'Hike(id: $id, name: $name, length: $length, steep: $steep, elevation: $elevation, description: $description, price: $price, difficulty: $difficulty, thumbnailImageUrl: $thumbnailImageUrl, isFavorite: $isFavorite, companyId: $companyId, company: $company, isAvailable: $isAvailable, availableFrom: $availableFrom, availableUntil: $availableUntil, category: $category, tags: $tags, averageRating: $averageRating, reviewCount: $reviewCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HikeCopyWith<$Res> implements $HikeCopyWith<$Res> {
  factory _$HikeCopyWith(_Hike value, $Res Function(_Hike) _then) = __$HikeCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, double length, double steep, int elevation, String description, double price, Difficulty difficulty,@JsonKey(name: 'thumbnail_image_url') String? thumbnailImageUrl,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'company_id') String? companyId, Company? company, bool isAvailable, DateTime? availableFrom, DateTime? availableUntil, String category, List<String> tags, double averageRating, int reviewCount,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});


@override $CompanyCopyWith<$Res>? get company;

}
/// @nodoc
class __$HikeCopyWithImpl<$Res>
    implements _$HikeCopyWith<$Res> {
  __$HikeCopyWithImpl(this._self, this._then);

  final _Hike _self;
  final $Res Function(_Hike) _then;

/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? length = null,Object? steep = null,Object? elevation = null,Object? description = null,Object? price = null,Object? difficulty = null,Object? thumbnailImageUrl = freezed,Object? isFavorite = null,Object? companyId = freezed,Object? company = freezed,Object? isAvailable = null,Object? availableFrom = freezed,Object? availableUntil = freezed,Object? category = null,Object? tags = null,Object? averageRating = null,Object? reviewCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Hike(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as double,steep: null == steep ? _self.steep : steep // ignore: cast_nullable_to_non_nullable
as double,elevation: null == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,thumbnailImageUrl: freezed == thumbnailImageUrl ? _self.thumbnailImageUrl : thumbnailImageUrl // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,availableFrom: freezed == availableFrom ? _self.availableFrom : availableFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,availableUntil: freezed == availableUntil ? _self.availableUntil : availableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Hike
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res>? get company {
    if (_self.company == null) {
    return null;
  }

  return $CompanyCopyWith<$Res>(_self.company!, (value) {
    return _then(_self.copyWith(company: value));
  });
}
}

// dart format on
