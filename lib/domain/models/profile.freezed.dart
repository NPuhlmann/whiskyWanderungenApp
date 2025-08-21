// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile implements DiagnosticableTreeMixin {

 String get id; set id(String value);// ID des Benutzers
 String get first_name;// ID des Benutzers
 set first_name(String value);// Standardwert: leerer String
 String get last_name;// Standardwert: leerer String
 set last_name(String value);// Standardwert: leerer String
 DateTime? get date_of_birth;// Standardwert: leerer String
 set date_of_birth(DateTime? value); String get email; set email(String value);// Standardwert: leerer String
 String get imageUrl;// Standardwert: leerer String
 set imageUrl(String value);
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Profile'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('first_name', first_name))..add(DiagnosticsProperty('last_name', last_name))..add(DiagnosticsProperty('date_of_birth', date_of_birth))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('imageUrl', imageUrl));
}



@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Profile(id: $id, first_name: $first_name, last_name: $last_name, date_of_birth: $date_of_birth, email: $email, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String first_name, String last_name, DateTime? date_of_birth, String email, String imageUrl
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? first_name = null,Object? last_name = null,Object? date_of_birth = freezed,Object? email = null,Object? imageUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,first_name: null == first_name ? _self.first_name : first_name // ignore: cast_nullable_to_non_nullable
as String,last_name: null == last_name ? _self.last_name : last_name // ignore: cast_nullable_to_non_nullable
as String,date_of_birth: freezed == date_of_birth ? _self.date_of_birth : date_of_birth // ignore: cast_nullable_to_non_nullable
as DateTime?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String first_name,  String last_name,  DateTime? date_of_birth,  String email,  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.first_name,_that.last_name,_that.date_of_birth,_that.email,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String first_name,  String last_name,  DateTime? date_of_birth,  String email,  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.first_name,_that.last_name,_that.date_of_birth,_that.email,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String first_name,  String last_name,  DateTime? date_of_birth,  String email,  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.first_name,_that.last_name,_that.date_of_birth,_that.email,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile with DiagnosticableTreeMixin implements Profile {
   _Profile({this.id = '', this.first_name = '', this.last_name = '', this.date_of_birth = null, this.email = '', this.imageUrl = ''});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override@JsonKey()  String id;
// ID des Benutzers
@override@JsonKey()  String first_name;
// Standardwert: leerer String
@override@JsonKey()  String last_name;
// Standardwert: leerer String
@override@JsonKey()  DateTime? date_of_birth;
@override@JsonKey()  String email;
// Standardwert: leerer String
@override@JsonKey()  String imageUrl;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Profile'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('first_name', first_name))..add(DiagnosticsProperty('last_name', last_name))..add(DiagnosticsProperty('date_of_birth', date_of_birth))..add(DiagnosticsProperty('email', email))..add(DiagnosticsProperty('imageUrl', imageUrl));
}



@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Profile(id: $id, first_name: $first_name, last_name: $last_name, date_of_birth: $date_of_birth, email: $email, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String first_name, String last_name, DateTime? date_of_birth, String email, String imageUrl
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? first_name = null,Object? last_name = null,Object? date_of_birth = freezed,Object? email = null,Object? imageUrl = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,first_name: null == first_name ? _self.first_name : first_name // ignore: cast_nullable_to_non_nullable
as String,last_name: null == last_name ? _self.last_name : last_name // ignore: cast_nullable_to_non_nullable
as String,date_of_birth: freezed == date_of_birth ? _self.date_of_birth : date_of_birth // ignore: cast_nullable_to_non_nullable
as DateTime?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
