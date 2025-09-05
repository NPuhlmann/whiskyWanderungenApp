// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enhanced_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EnhancedOrder {

 int get id; String get orderNumber; int get hikeId; String get userId; double get totalAmount; DeliveryType get deliveryType; OrderStatus get status; DateTime get createdAt; DateTime? get estimatedDelivery; String? get trackingNumber; Map<String, dynamic>? get deliveryAddress; String? get paymentIntentId; DateTime? get updatedAt;// Enhanced fields
 String? get companyId; String? get customerEmail; String? get customerPhone; List<OrderStatusChange>? get statusHistory; Map<String, dynamic>? get shippingDetails; bool? get canBeTracked;
/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnhancedOrderCopyWith<EnhancedOrder> get copyWith => _$EnhancedOrderCopyWithImpl<EnhancedOrder>(this as EnhancedOrder, _$identity);

  /// Serializes this EnhancedOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnhancedOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&const DeepCollectionEquality().equals(other.deliveryAddress, deliveryAddress)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&const DeepCollectionEquality().equals(other.shippingDetails, shippingDetails)&&(identical(other.canBeTracked, canBeTracked) || other.canBeTracked == canBeTracked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,hikeId,userId,totalAmount,deliveryType,status,createdAt,estimatedDelivery,trackingNumber,const DeepCollectionEquality().hash(deliveryAddress),paymentIntentId,updatedAt,companyId,customerEmail,customerPhone,const DeepCollectionEquality().hash(statusHistory),const DeepCollectionEquality().hash(shippingDetails),canBeTracked]);

@override
String toString() {
  return 'EnhancedOrder(id: $id, orderNumber: $orderNumber, hikeId: $hikeId, userId: $userId, totalAmount: $totalAmount, deliveryType: $deliveryType, status: $status, createdAt: $createdAt, estimatedDelivery: $estimatedDelivery, trackingNumber: $trackingNumber, deliveryAddress: $deliveryAddress, paymentIntentId: $paymentIntentId, updatedAt: $updatedAt, companyId: $companyId, customerEmail: $customerEmail, customerPhone: $customerPhone, statusHistory: $statusHistory, shippingDetails: $shippingDetails, canBeTracked: $canBeTracked)';
}


}

/// @nodoc
abstract mixin class $EnhancedOrderCopyWith<$Res>  {
  factory $EnhancedOrderCopyWith(EnhancedOrder value, $Res Function(EnhancedOrder) _then) = _$EnhancedOrderCopyWithImpl;
@useResult
$Res call({
 int id, String orderNumber, int hikeId, String userId, double totalAmount, DeliveryType deliveryType, OrderStatus status, DateTime createdAt, DateTime? estimatedDelivery, String? trackingNumber, Map<String, dynamic>? deliveryAddress, String? paymentIntentId, DateTime? updatedAt, String? companyId, String? customerEmail, String? customerPhone, List<OrderStatusChange>? statusHistory, Map<String, dynamic>? shippingDetails, bool? canBeTracked
});




}
/// @nodoc
class _$EnhancedOrderCopyWithImpl<$Res>
    implements $EnhancedOrderCopyWith<$Res> {
  _$EnhancedOrderCopyWithImpl(this._self, this._then);

  final EnhancedOrder _self;
  final $Res Function(EnhancedOrder) _then;

/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? hikeId = null,Object? userId = null,Object? totalAmount = null,Object? deliveryType = null,Object? status = null,Object? createdAt = null,Object? estimatedDelivery = freezed,Object? trackingNumber = freezed,Object? deliveryAddress = freezed,Object? paymentIntentId = freezed,Object? updatedAt = freezed,Object? companyId = freezed,Object? customerEmail = freezed,Object? customerPhone = freezed,Object? statusHistory = freezed,Object? shippingDetails = freezed,Object? canBeTracked = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: freezed == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusChange>?,shippingDetails: freezed == shippingDetails ? _self.shippingDetails : shippingDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,canBeTracked: freezed == canBeTracked ? _self.canBeTracked : canBeTracked // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [EnhancedOrder].
extension EnhancedOrderPatterns on EnhancedOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnhancedOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnhancedOrder value)  $default,){
final _that = this;
switch (_that) {
case _EnhancedOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnhancedOrder value)?  $default,){
final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt,  DateTime? estimatedDelivery,  String? trackingNumber,  Map<String, dynamic>? deliveryAddress,  String? paymentIntentId,  DateTime? updatedAt,  String? companyId,  String? customerEmail,  String? customerPhone,  List<OrderStatusChange>? statusHistory,  Map<String, dynamic>? shippingDetails,  bool? canBeTracked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt,_that.estimatedDelivery,_that.trackingNumber,_that.deliveryAddress,_that.paymentIntentId,_that.updatedAt,_that.companyId,_that.customerEmail,_that.customerPhone,_that.statusHistory,_that.shippingDetails,_that.canBeTracked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt,  DateTime? estimatedDelivery,  String? trackingNumber,  Map<String, dynamic>? deliveryAddress,  String? paymentIntentId,  DateTime? updatedAt,  String? companyId,  String? customerEmail,  String? customerPhone,  List<OrderStatusChange>? statusHistory,  Map<String, dynamic>? shippingDetails,  bool? canBeTracked)  $default,) {final _that = this;
switch (_that) {
case _EnhancedOrder():
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt,_that.estimatedDelivery,_that.trackingNumber,_that.deliveryAddress,_that.paymentIntentId,_that.updatedAt,_that.companyId,_that.customerEmail,_that.customerPhone,_that.statusHistory,_that.shippingDetails,_that.canBeTracked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String orderNumber,  int hikeId,  String userId,  double totalAmount,  DeliveryType deliveryType,  OrderStatus status,  DateTime createdAt,  DateTime? estimatedDelivery,  String? trackingNumber,  Map<String, dynamic>? deliveryAddress,  String? paymentIntentId,  DateTime? updatedAt,  String? companyId,  String? customerEmail,  String? customerPhone,  List<OrderStatusChange>? statusHistory,  Map<String, dynamic>? shippingDetails,  bool? canBeTracked)?  $default,) {final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.hikeId,_that.userId,_that.totalAmount,_that.deliveryType,_that.status,_that.createdAt,_that.estimatedDelivery,_that.trackingNumber,_that.deliveryAddress,_that.paymentIntentId,_that.updatedAt,_that.companyId,_that.customerEmail,_that.customerPhone,_that.statusHistory,_that.shippingDetails,_that.canBeTracked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnhancedOrder implements EnhancedOrder {
  const _EnhancedOrder({required this.id, required this.orderNumber, required this.hikeId, required this.userId, required this.totalAmount, required this.deliveryType, required this.status, required this.createdAt, this.estimatedDelivery, this.trackingNumber, final  Map<String, dynamic>? deliveryAddress, this.paymentIntentId, this.updatedAt, this.companyId, this.customerEmail, this.customerPhone, final  List<OrderStatusChange>? statusHistory, final  Map<String, dynamic>? shippingDetails, this.canBeTracked}): _deliveryAddress = deliveryAddress,_statusHistory = statusHistory,_shippingDetails = shippingDetails;
  factory _EnhancedOrder.fromJson(Map<String, dynamic> json) => _$EnhancedOrderFromJson(json);

@override final  int id;
@override final  String orderNumber;
@override final  int hikeId;
@override final  String userId;
@override final  double totalAmount;
@override final  DeliveryType deliveryType;
@override final  OrderStatus status;
@override final  DateTime createdAt;
@override final  DateTime? estimatedDelivery;
@override final  String? trackingNumber;
 final  Map<String, dynamic>? _deliveryAddress;
@override Map<String, dynamic>? get deliveryAddress {
  final value = _deliveryAddress;
  if (value == null) return null;
  if (_deliveryAddress is EqualUnmodifiableMapView) return _deliveryAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? paymentIntentId;
@override final  DateTime? updatedAt;
// Enhanced fields
@override final  String? companyId;
@override final  String? customerEmail;
@override final  String? customerPhone;
 final  List<OrderStatusChange>? _statusHistory;
@override List<OrderStatusChange>? get statusHistory {
  final value = _statusHistory;
  if (value == null) return null;
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _shippingDetails;
@override Map<String, dynamic>? get shippingDetails {
  final value = _shippingDetails;
  if (value == null) return null;
  if (_shippingDetails is EqualUnmodifiableMapView) return _shippingDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  bool? canBeTracked;

/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnhancedOrderCopyWith<_EnhancedOrder> get copyWith => __$EnhancedOrderCopyWithImpl<_EnhancedOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnhancedOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnhancedOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&const DeepCollectionEquality().equals(other._deliveryAddress, _deliveryAddress)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&const DeepCollectionEquality().equals(other._shippingDetails, _shippingDetails)&&(identical(other.canBeTracked, canBeTracked) || other.canBeTracked == canBeTracked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,hikeId,userId,totalAmount,deliveryType,status,createdAt,estimatedDelivery,trackingNumber,const DeepCollectionEquality().hash(_deliveryAddress),paymentIntentId,updatedAt,companyId,customerEmail,customerPhone,const DeepCollectionEquality().hash(_statusHistory),const DeepCollectionEquality().hash(_shippingDetails),canBeTracked]);

@override
String toString() {
  return 'EnhancedOrder(id: $id, orderNumber: $orderNumber, hikeId: $hikeId, userId: $userId, totalAmount: $totalAmount, deliveryType: $deliveryType, status: $status, createdAt: $createdAt, estimatedDelivery: $estimatedDelivery, trackingNumber: $trackingNumber, deliveryAddress: $deliveryAddress, paymentIntentId: $paymentIntentId, updatedAt: $updatedAt, companyId: $companyId, customerEmail: $customerEmail, customerPhone: $customerPhone, statusHistory: $statusHistory, shippingDetails: $shippingDetails, canBeTracked: $canBeTracked)';
}


}

/// @nodoc
abstract mixin class _$EnhancedOrderCopyWith<$Res> implements $EnhancedOrderCopyWith<$Res> {
  factory _$EnhancedOrderCopyWith(_EnhancedOrder value, $Res Function(_EnhancedOrder) _then) = __$EnhancedOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, String orderNumber, int hikeId, String userId, double totalAmount, DeliveryType deliveryType, OrderStatus status, DateTime createdAt, DateTime? estimatedDelivery, String? trackingNumber, Map<String, dynamic>? deliveryAddress, String? paymentIntentId, DateTime? updatedAt, String? companyId, String? customerEmail, String? customerPhone, List<OrderStatusChange>? statusHistory, Map<String, dynamic>? shippingDetails, bool? canBeTracked
});




}
/// @nodoc
class __$EnhancedOrderCopyWithImpl<$Res>
    implements _$EnhancedOrderCopyWith<$Res> {
  __$EnhancedOrderCopyWithImpl(this._self, this._then);

  final _EnhancedOrder _self;
  final $Res Function(_EnhancedOrder) _then;

/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? hikeId = null,Object? userId = null,Object? totalAmount = null,Object? deliveryType = null,Object? status = null,Object? createdAt = null,Object? estimatedDelivery = freezed,Object? trackingNumber = freezed,Object? deliveryAddress = freezed,Object? paymentIntentId = freezed,Object? updatedAt = freezed,Object? companyId = freezed,Object? customerEmail = freezed,Object? customerPhone = freezed,Object? statusHistory = freezed,Object? shippingDetails = freezed,Object? canBeTracked = freezed,}) {
  return _then(_EnhancedOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self._deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: freezed == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusChange>?,shippingDetails: freezed == shippingDetails ? _self._shippingDetails : shippingDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,canBeTracked: freezed == canBeTracked ? _self.canBeTracked : canBeTracked // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$OrderStatusChange {

 int get id; int get orderId; OrderStatus get oldStatus; OrderStatus get newStatus; DateTime get changedAt; String? get reason; String? get changedBy;
/// Create a copy of OrderStatusChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderStatusChangeCopyWith<OrderStatusChange> get copyWith => _$OrderStatusChangeCopyWithImpl<OrderStatusChange>(this as OrderStatusChange, _$identity);

  /// Serializes this OrderStatusChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderStatusChange&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.oldStatus, oldStatus) || other.oldStatus == oldStatus)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,oldStatus,newStatus,changedAt,reason,changedBy);

@override
String toString() {
  return 'OrderStatusChange(id: $id, orderId: $orderId, oldStatus: $oldStatus, newStatus: $newStatus, changedAt: $changedAt, reason: $reason, changedBy: $changedBy)';
}


}

/// @nodoc
abstract mixin class $OrderStatusChangeCopyWith<$Res>  {
  factory $OrderStatusChangeCopyWith(OrderStatusChange value, $Res Function(OrderStatusChange) _then) = _$OrderStatusChangeCopyWithImpl;
@useResult
$Res call({
 int id, int orderId, OrderStatus oldStatus, OrderStatus newStatus, DateTime changedAt, String? reason, String? changedBy
});




}
/// @nodoc
class _$OrderStatusChangeCopyWithImpl<$Res>
    implements $OrderStatusChangeCopyWith<$Res> {
  _$OrderStatusChangeCopyWithImpl(this._self, this._then);

  final OrderStatusChange _self;
  final $Res Function(OrderStatusChange) _then;

/// Create a copy of OrderStatusChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? oldStatus = null,Object? newStatus = null,Object? changedAt = null,Object? reason = freezed,Object? changedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,oldStatus: null == oldStatus ? _self.oldStatus : oldStatus // ignore: cast_nullable_to_non_nullable
as OrderStatus,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as OrderStatus,changedAt: null == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderStatusChange].
extension OrderStatusChangePatterns on OrderStatusChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderStatusChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderStatusChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderStatusChange value)  $default,){
final _that = this;
switch (_that) {
case _OrderStatusChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderStatusChange value)?  $default,){
final _that = this;
switch (_that) {
case _OrderStatusChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int orderId,  OrderStatus oldStatus,  OrderStatus newStatus,  DateTime changedAt,  String? reason,  String? changedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderStatusChange() when $default != null:
return $default(_that.id,_that.orderId,_that.oldStatus,_that.newStatus,_that.changedAt,_that.reason,_that.changedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int orderId,  OrderStatus oldStatus,  OrderStatus newStatus,  DateTime changedAt,  String? reason,  String? changedBy)  $default,) {final _that = this;
switch (_that) {
case _OrderStatusChange():
return $default(_that.id,_that.orderId,_that.oldStatus,_that.newStatus,_that.changedAt,_that.reason,_that.changedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int orderId,  OrderStatus oldStatus,  OrderStatus newStatus,  DateTime changedAt,  String? reason,  String? changedBy)?  $default,) {final _that = this;
switch (_that) {
case _OrderStatusChange() when $default != null:
return $default(_that.id,_that.orderId,_that.oldStatus,_that.newStatus,_that.changedAt,_that.reason,_that.changedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderStatusChange implements OrderStatusChange {
  const _OrderStatusChange({required this.id, required this.orderId, required this.oldStatus, required this.newStatus, required this.changedAt, this.reason, this.changedBy});
  factory _OrderStatusChange.fromJson(Map<String, dynamic> json) => _$OrderStatusChangeFromJson(json);

@override final  int id;
@override final  int orderId;
@override final  OrderStatus oldStatus;
@override final  OrderStatus newStatus;
@override final  DateTime changedAt;
@override final  String? reason;
@override final  String? changedBy;

/// Create a copy of OrderStatusChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderStatusChangeCopyWith<_OrderStatusChange> get copyWith => __$OrderStatusChangeCopyWithImpl<_OrderStatusChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderStatusChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderStatusChange&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.oldStatus, oldStatus) || other.oldStatus == oldStatus)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,oldStatus,newStatus,changedAt,reason,changedBy);

@override
String toString() {
  return 'OrderStatusChange(id: $id, orderId: $orderId, oldStatus: $oldStatus, newStatus: $newStatus, changedAt: $changedAt, reason: $reason, changedBy: $changedBy)';
}


}

/// @nodoc
abstract mixin class _$OrderStatusChangeCopyWith<$Res> implements $OrderStatusChangeCopyWith<$Res> {
  factory _$OrderStatusChangeCopyWith(_OrderStatusChange value, $Res Function(_OrderStatusChange) _then) = __$OrderStatusChangeCopyWithImpl;
@override @useResult
$Res call({
 int id, int orderId, OrderStatus oldStatus, OrderStatus newStatus, DateTime changedAt, String? reason, String? changedBy
});




}
/// @nodoc
class __$OrderStatusChangeCopyWithImpl<$Res>
    implements _$OrderStatusChangeCopyWith<$Res> {
  __$OrderStatusChangeCopyWithImpl(this._self, this._then);

  final _OrderStatusChange _self;
  final $Res Function(_OrderStatusChange) _then;

/// Create a copy of OrderStatusChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? oldStatus = null,Object? newStatus = null,Object? changedAt = null,Object? reason = freezed,Object? changedBy = freezed,}) {
  return _then(_OrderStatusChange(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,oldStatus: null == oldStatus ? _self.oldStatus : oldStatus // ignore: cast_nullable_to_non_nullable
as OrderStatus,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as OrderStatus,changedAt: null == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
