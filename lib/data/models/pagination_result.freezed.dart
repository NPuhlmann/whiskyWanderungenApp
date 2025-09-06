// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pagination_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginationResult<T> {

 List<T> get items; int get currentPage; int get totalPages; int get totalItems; int get pageSize; bool get hasNextPage; bool get hasPreviousPage;
/// Create a copy of PaginationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationResultCopyWith<T, PaginationResult<T>> get copyWith => _$PaginationResultCopyWithImpl<T, PaginationResult<T>>(this as PaginationResult<T>, _$identity);

  /// Serializes this PaginationResult to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginationResult<T>&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.hasNextPage, hasNextPage) || other.hasNextPage == hasNextPage)&&(identical(other.hasPreviousPage, hasPreviousPage) || other.hasPreviousPage == hasPreviousPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),currentPage,totalPages,totalItems,pageSize,hasNextPage,hasPreviousPage);

@override
String toString() {
  return 'PaginationResult<$T>(items: $items, currentPage: $currentPage, totalPages: $totalPages, totalItems: $totalItems, pageSize: $pageSize, hasNextPage: $hasNextPage, hasPreviousPage: $hasPreviousPage)';
}


}

/// @nodoc
abstract mixin class $PaginationResultCopyWith<T,$Res>  {
  factory $PaginationResultCopyWith(PaginationResult<T> value, $Res Function(PaginationResult<T>) _then) = _$PaginationResultCopyWithImpl;
@useResult
$Res call({
 List<T> items, int currentPage, int totalPages, int totalItems, int pageSize, bool hasNextPage, bool hasPreviousPage
});




}
/// @nodoc
class _$PaginationResultCopyWithImpl<T,$Res>
    implements $PaginationResultCopyWith<T, $Res> {
  _$PaginationResultCopyWithImpl(this._self, this._then);

  final PaginationResult<T> _self;
  final $Res Function(PaginationResult<T>) _then;

/// Create a copy of PaginationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? currentPage = null,Object? totalPages = null,Object? totalItems = null,Object? pageSize = null,Object? hasNextPage = null,Object? hasPreviousPage = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasNextPage: null == hasNextPage ? _self.hasNextPage : hasNextPage // ignore: cast_nullable_to_non_nullable
as bool,hasPreviousPage: null == hasPreviousPage ? _self.hasPreviousPage : hasPreviousPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginationResult].
extension PaginationResultPatterns<T> on PaginationResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginationResult<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginationResult<T> value)  $default,){
final _that = this;
switch (_that) {
case _PaginationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginationResult<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PaginationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  int currentPage,  int totalPages,  int totalItems,  int pageSize,  bool hasNextPage,  bool hasPreviousPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginationResult() when $default != null:
return $default(_that.items,_that.currentPage,_that.totalPages,_that.totalItems,_that.pageSize,_that.hasNextPage,_that.hasPreviousPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  int currentPage,  int totalPages,  int totalItems,  int pageSize,  bool hasNextPage,  bool hasPreviousPage)  $default,) {final _that = this;
switch (_that) {
case _PaginationResult():
return $default(_that.items,_that.currentPage,_that.totalPages,_that.totalItems,_that.pageSize,_that.hasNextPage,_that.hasPreviousPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  int currentPage,  int totalPages,  int totalItems,  int pageSize,  bool hasNextPage,  bool hasPreviousPage)?  $default,) {final _that = this;
switch (_that) {
case _PaginationResult() when $default != null:
return $default(_that.items,_that.currentPage,_that.totalPages,_that.totalItems,_that.pageSize,_that.hasNextPage,_that.hasPreviousPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _PaginationResult<T> implements PaginationResult<T> {
  const _PaginationResult({required final  List<T> items, required this.currentPage, required this.totalPages, required this.totalItems, required this.pageSize, required this.hasNextPage, required this.hasPreviousPage}): _items = items;
  factory _PaginationResult.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$PaginationResultFromJson(json,fromJsonT);

 final  List<T> _items;
@override List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int currentPage;
@override final  int totalPages;
@override final  int totalItems;
@override final  int pageSize;
@override final  bool hasNextPage;
@override final  bool hasPreviousPage;

/// Create a copy of PaginationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationResultCopyWith<T, _PaginationResult<T>> get copyWith => __$PaginationResultCopyWithImpl<T, _PaginationResult<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$PaginationResultToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginationResult<T>&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.hasNextPage, hasNextPage) || other.hasNextPage == hasNextPage)&&(identical(other.hasPreviousPage, hasPreviousPage) || other.hasPreviousPage == hasPreviousPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),currentPage,totalPages,totalItems,pageSize,hasNextPage,hasPreviousPage);

@override
String toString() {
  return 'PaginationResult<$T>(items: $items, currentPage: $currentPage, totalPages: $totalPages, totalItems: $totalItems, pageSize: $pageSize, hasNextPage: $hasNextPage, hasPreviousPage: $hasPreviousPage)';
}


}

/// @nodoc
abstract mixin class _$PaginationResultCopyWith<T,$Res> implements $PaginationResultCopyWith<T, $Res> {
  factory _$PaginationResultCopyWith(_PaginationResult<T> value, $Res Function(_PaginationResult<T>) _then) = __$PaginationResultCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, int currentPage, int totalPages, int totalItems, int pageSize, bool hasNextPage, bool hasPreviousPage
});




}
/// @nodoc
class __$PaginationResultCopyWithImpl<T,$Res>
    implements _$PaginationResultCopyWith<T, $Res> {
  __$PaginationResultCopyWithImpl(this._self, this._then);

  final _PaginationResult<T> _self;
  final $Res Function(_PaginationResult<T>) _then;

/// Create a copy of PaginationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? currentPage = null,Object? totalPages = null,Object? totalItems = null,Object? pageSize = null,Object? hasNextPage = null,Object? hasPreviousPage = null,}) {
  return _then(_PaginationResult<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,hasNextPage: null == hasNextPage ? _self.hasNextPage : hasNextPage // ignore: cast_nullable_to_non_nullable
as bool,hasPreviousPage: null == hasPreviousPage ? _self.hasPreviousPage : hasPreviousPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PaginationParams {

 int get page; int get pageSize; String get orderBy; bool get ascending; Map<String, dynamic>? get filters;
/// Create a copy of PaginationParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationParamsCopyWith<PaginationParams> get copyWith => _$PaginationParamsCopyWithImpl<PaginationParams>(this as PaginationParams, _$identity);

  /// Serializes this PaginationParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginationParams&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.orderBy, orderBy) || other.orderBy == orderBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&const DeepCollectionEquality().equals(other.filters, filters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,pageSize,orderBy,ascending,const DeepCollectionEquality().hash(filters));

@override
String toString() {
  return 'PaginationParams(page: $page, pageSize: $pageSize, orderBy: $orderBy, ascending: $ascending, filters: $filters)';
}


}

/// @nodoc
abstract mixin class $PaginationParamsCopyWith<$Res>  {
  factory $PaginationParamsCopyWith(PaginationParams value, $Res Function(PaginationParams) _then) = _$PaginationParamsCopyWithImpl;
@useResult
$Res call({
 int page, int pageSize, String orderBy, bool ascending, Map<String, dynamic>? filters
});




}
/// @nodoc
class _$PaginationParamsCopyWithImpl<$Res>
    implements $PaginationParamsCopyWith<$Res> {
  _$PaginationParamsCopyWithImpl(this._self, this._then);

  final PaginationParams _self;
  final $Res Function(PaginationParams) _then;

/// Create a copy of PaginationParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? pageSize = null,Object? orderBy = null,Object? ascending = null,Object? filters = freezed,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,orderBy: null == orderBy ? _self.orderBy : orderBy // ignore: cast_nullable_to_non_nullable
as String,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,filters: freezed == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginationParams].
extension PaginationParamsPatterns on PaginationParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginationParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginationParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginationParams value)  $default,){
final _that = this;
switch (_that) {
case _PaginationParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginationParams value)?  $default,){
final _that = this;
switch (_that) {
case _PaginationParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page,  int pageSize,  String orderBy,  bool ascending,  Map<String, dynamic>? filters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginationParams() when $default != null:
return $default(_that.page,_that.pageSize,_that.orderBy,_that.ascending,_that.filters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page,  int pageSize,  String orderBy,  bool ascending,  Map<String, dynamic>? filters)  $default,) {final _that = this;
switch (_that) {
case _PaginationParams():
return $default(_that.page,_that.pageSize,_that.orderBy,_that.ascending,_that.filters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page,  int pageSize,  String orderBy,  bool ascending,  Map<String, dynamic>? filters)?  $default,) {final _that = this;
switch (_that) {
case _PaginationParams() when $default != null:
return $default(_that.page,_that.pageSize,_that.orderBy,_that.ascending,_that.filters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginationParams implements PaginationParams {
  const _PaginationParams({this.page = 1, this.pageSize = 20, this.orderBy = 'created_at', this.ascending = false, final  Map<String, dynamic>? filters}): _filters = filters;
  factory _PaginationParams.fromJson(Map<String, dynamic> json) => _$PaginationParamsFromJson(json);

@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  String orderBy;
@override@JsonKey() final  bool ascending;
 final  Map<String, dynamic>? _filters;
@override Map<String, dynamic>? get filters {
  final value = _filters;
  if (value == null) return null;
  if (_filters is EqualUnmodifiableMapView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PaginationParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationParamsCopyWith<_PaginationParams> get copyWith => __$PaginationParamsCopyWithImpl<_PaginationParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginationParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginationParams&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.orderBy, orderBy) || other.orderBy == orderBy)&&(identical(other.ascending, ascending) || other.ascending == ascending)&&const DeepCollectionEquality().equals(other._filters, _filters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,pageSize,orderBy,ascending,const DeepCollectionEquality().hash(_filters));

@override
String toString() {
  return 'PaginationParams(page: $page, pageSize: $pageSize, orderBy: $orderBy, ascending: $ascending, filters: $filters)';
}


}

/// @nodoc
abstract mixin class _$PaginationParamsCopyWith<$Res> implements $PaginationParamsCopyWith<$Res> {
  factory _$PaginationParamsCopyWith(_PaginationParams value, $Res Function(_PaginationParams) _then) = __$PaginationParamsCopyWithImpl;
@override @useResult
$Res call({
 int page, int pageSize, String orderBy, bool ascending, Map<String, dynamic>? filters
});




}
/// @nodoc
class __$PaginationParamsCopyWithImpl<$Res>
    implements _$PaginationParamsCopyWith<$Res> {
  __$PaginationParamsCopyWithImpl(this._self, this._then);

  final _PaginationParams _self;
  final $Res Function(_PaginationParams) _then;

/// Create a copy of PaginationParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? pageSize = null,Object? orderBy = null,Object? ascending = null,Object? filters = freezed,}) {
  return _then(_PaginationParams(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,orderBy: null == orderBy ? _self.orderBy : orderBy // ignore: cast_nullable_to_non_nullable
as String,ascending: null == ascending ? _self.ascending : ascending // ignore: cast_nullable_to_non_nullable
as bool,filters: freezed == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
