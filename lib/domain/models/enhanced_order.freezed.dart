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

 int get id; String get orderNumber;// Multi-Vendor Context
 String get companyId; Company? get company;// Populated via JOIN
// User und Hike Information
 String get userId; int get hikeId; Hike? get hike;// Populated via JOIN
// Pricing Information
 double get baseAmount;// Hike Preis ohne Versand
 double get shippingCost; double get totalAmount;// baseAmount + shippingCost + eventuelle Steuern
 double? get taxAmount;// Für zukünftige MwSt-Funktionalität
 String? get currency;// ISO 4217 Currency Code (EUR, USD, etc.)
// Delivery Information
 DeliveryType get deliveryType; DeliveryAddress? get deliveryAddress;// Strukturierte Adresse
@JsonKey(name: 'delivery_address_raw') Map<String, dynamic>? get deliveryAddressRaw;// Fallback für alte Daten
// Status und Tracking
 EnhancedOrderStatus get status; String? get trackingNumber; String? get trackingUrl; DateTime? get estimatedDelivery; DateTime? get actualDelivery;// Payment Information
 String? get paymentIntentId; String? get paymentMethodId; PaymentProvider? get paymentProvider;// Shipping Information
 ShippingCostResult? get shippingDetails; String? get shippingService;// 'Standard', 'Express', etc.
// Order Items (für zukünftige Multi-Item Bestellungen)
 List<OrderItem> get items;// Customer Notes und Instructions
 String? get customerNotes; String? get deliveryInstructions; String? get internalNotes;// Für Company-interne Notizen
// Status History (für Tracking)
 List<OrderStatusChange> get statusHistory;// System Fields
 DateTime get createdAt; DateTime? get updatedAt;// Metadata für zusätzliche Informationen
 Map<String, dynamic> get metadata;
/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnhancedOrderCopyWith<EnhancedOrder> get copyWith => _$EnhancedOrderCopyWithImpl<EnhancedOrder>(this as EnhancedOrder, _$identity);

  /// Serializes this EnhancedOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnhancedOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.hike, hike) || other.hike == hike)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&const DeepCollectionEquality().equals(other.deliveryAddressRaw, deliveryAddressRaw)&&(identical(other.status, status) || other.status == status)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.actualDelivery, actualDelivery) || other.actualDelivery == actualDelivery)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.shippingDetails, shippingDetails) || other.shippingDetails == shippingDetails)&&(identical(other.shippingService, shippingService) || other.shippingService == shippingService)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.customerNotes, customerNotes) || other.customerNotes == customerNotes)&&(identical(other.deliveryInstructions, deliveryInstructions) || other.deliveryInstructions == deliveryInstructions)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,companyId,company,userId,hikeId,hike,baseAmount,shippingCost,totalAmount,taxAmount,currency,deliveryType,deliveryAddress,const DeepCollectionEquality().hash(deliveryAddressRaw),status,trackingNumber,trackingUrl,estimatedDelivery,actualDelivery,paymentIntentId,paymentMethodId,paymentProvider,shippingDetails,shippingService,const DeepCollectionEquality().hash(items),customerNotes,deliveryInstructions,internalNotes,const DeepCollectionEquality().hash(statusHistory),createdAt,updatedAt,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'EnhancedOrder(id: $id, orderNumber: $orderNumber, companyId: $companyId, company: $company, userId: $userId, hikeId: $hikeId, hike: $hike, baseAmount: $baseAmount, shippingCost: $shippingCost, totalAmount: $totalAmount, taxAmount: $taxAmount, currency: $currency, deliveryType: $deliveryType, deliveryAddress: $deliveryAddress, deliveryAddressRaw: $deliveryAddressRaw, status: $status, trackingNumber: $trackingNumber, trackingUrl: $trackingUrl, estimatedDelivery: $estimatedDelivery, actualDelivery: $actualDelivery, paymentIntentId: $paymentIntentId, paymentMethodId: $paymentMethodId, paymentProvider: $paymentProvider, shippingDetails: $shippingDetails, shippingService: $shippingService, items: $items, customerNotes: $customerNotes, deliveryInstructions: $deliveryInstructions, internalNotes: $internalNotes, statusHistory: $statusHistory, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $EnhancedOrderCopyWith<$Res>  {
  factory $EnhancedOrderCopyWith(EnhancedOrder value, $Res Function(EnhancedOrder) _then) = _$EnhancedOrderCopyWithImpl;
@useResult
$Res call({
 int id, String orderNumber, String companyId, Company? company, String userId, int hikeId, Hike? hike, double baseAmount, double shippingCost, double totalAmount, double? taxAmount, String? currency, DeliveryType deliveryType, DeliveryAddress? deliveryAddress,@JsonKey(name: 'delivery_address_raw') Map<String, dynamic>? deliveryAddressRaw, EnhancedOrderStatus status, String? trackingNumber, String? trackingUrl, DateTime? estimatedDelivery, DateTime? actualDelivery, String? paymentIntentId, String? paymentMethodId, PaymentProvider? paymentProvider, ShippingCostResult? shippingDetails, String? shippingService, List<OrderItem> items, String? customerNotes, String? deliveryInstructions, String? internalNotes, List<OrderStatusChange> statusHistory, DateTime createdAt, DateTime? updatedAt, Map<String, dynamic> metadata
});


$CompanyCopyWith<$Res>? get company;$HikeCopyWith<$Res>? get hike;$DeliveryAddressCopyWith<$Res>? get deliveryAddress;$ShippingCostResultCopyWith<$Res>? get shippingDetails;

}
/// @nodoc
class _$EnhancedOrderCopyWithImpl<$Res>
    implements $EnhancedOrderCopyWith<$Res> {
  _$EnhancedOrderCopyWithImpl(this._self, this._then);

  final EnhancedOrder _self;
  final $Res Function(EnhancedOrder) _then;

/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? companyId = null,Object? company = freezed,Object? userId = null,Object? hikeId = null,Object? hike = freezed,Object? baseAmount = null,Object? shippingCost = null,Object? totalAmount = null,Object? taxAmount = freezed,Object? currency = freezed,Object? deliveryType = null,Object? deliveryAddress = freezed,Object? deliveryAddressRaw = freezed,Object? status = null,Object? trackingNumber = freezed,Object? trackingUrl = freezed,Object? estimatedDelivery = freezed,Object? actualDelivery = freezed,Object? paymentIntentId = freezed,Object? paymentMethodId = freezed,Object? paymentProvider = freezed,Object? shippingDetails = freezed,Object? shippingService = freezed,Object? items = null,Object? customerNotes = freezed,Object? deliveryInstructions = freezed,Object? internalNotes = freezed,Object? statusHistory = null,Object? createdAt = null,Object? updatedAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,hike: freezed == hike ? _self.hike : hike // ignore: cast_nullable_to_non_nullable
as Hike?,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,taxAmount: freezed == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress?,deliveryAddressRaw: freezed == deliveryAddressRaw ? _self.deliveryAddressRaw : deliveryAddressRaw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDelivery: freezed == actualDelivery ? _self.actualDelivery : actualDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as PaymentProvider?,shippingDetails: freezed == shippingDetails ? _self.shippingDetails : shippingDetails // ignore: cast_nullable_to_non_nullable
as ShippingCostResult?,shippingService: freezed == shippingService ? _self.shippingService : shippingService // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,deliveryInstructions: freezed == deliveryInstructions ? _self.deliveryInstructions : deliveryInstructions // ignore: cast_nullable_to_non_nullable
as String?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusChange>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of EnhancedOrder
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
}/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HikeCopyWith<$Res>? get hike {
    if (_self.hike == null) {
    return null;
  }

  return $HikeCopyWith<$Res>(_self.hike!, (value) {
    return _then(_self.copyWith(hike: value));
  });
}/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $DeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingCostResultCopyWith<$Res>? get shippingDetails {
    if (_self.shippingDetails == null) {
    return null;
  }

  return $ShippingCostResultCopyWith<$Res>(_self.shippingDetails!, (value) {
    return _then(_self.copyWith(shippingDetails: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String orderNumber,  String companyId,  Company? company,  String userId,  int hikeId,  Hike? hike,  double baseAmount,  double shippingCost,  double totalAmount,  double? taxAmount,  String? currency,  DeliveryType deliveryType,  DeliveryAddress? deliveryAddress, @JsonKey(name: 'delivery_address_raw')  Map<String, dynamic>? deliveryAddressRaw,  EnhancedOrderStatus status,  String? trackingNumber,  String? trackingUrl,  DateTime? estimatedDelivery,  DateTime? actualDelivery,  String? paymentIntentId,  String? paymentMethodId,  PaymentProvider? paymentProvider,  ShippingCostResult? shippingDetails,  String? shippingService,  List<OrderItem> items,  String? customerNotes,  String? deliveryInstructions,  String? internalNotes,  List<OrderStatusChange> statusHistory,  DateTime createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.companyId,_that.company,_that.userId,_that.hikeId,_that.hike,_that.baseAmount,_that.shippingCost,_that.totalAmount,_that.taxAmount,_that.currency,_that.deliveryType,_that.deliveryAddress,_that.deliveryAddressRaw,_that.status,_that.trackingNumber,_that.trackingUrl,_that.estimatedDelivery,_that.actualDelivery,_that.paymentIntentId,_that.paymentMethodId,_that.paymentProvider,_that.shippingDetails,_that.shippingService,_that.items,_that.customerNotes,_that.deliveryInstructions,_that.internalNotes,_that.statusHistory,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String orderNumber,  String companyId,  Company? company,  String userId,  int hikeId,  Hike? hike,  double baseAmount,  double shippingCost,  double totalAmount,  double? taxAmount,  String? currency,  DeliveryType deliveryType,  DeliveryAddress? deliveryAddress, @JsonKey(name: 'delivery_address_raw')  Map<String, dynamic>? deliveryAddressRaw,  EnhancedOrderStatus status,  String? trackingNumber,  String? trackingUrl,  DateTime? estimatedDelivery,  DateTime? actualDelivery,  String? paymentIntentId,  String? paymentMethodId,  PaymentProvider? paymentProvider,  ShippingCostResult? shippingDetails,  String? shippingService,  List<OrderItem> items,  String? customerNotes,  String? deliveryInstructions,  String? internalNotes,  List<OrderStatusChange> statusHistory,  DateTime createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _EnhancedOrder():
return $default(_that.id,_that.orderNumber,_that.companyId,_that.company,_that.userId,_that.hikeId,_that.hike,_that.baseAmount,_that.shippingCost,_that.totalAmount,_that.taxAmount,_that.currency,_that.deliveryType,_that.deliveryAddress,_that.deliveryAddressRaw,_that.status,_that.trackingNumber,_that.trackingUrl,_that.estimatedDelivery,_that.actualDelivery,_that.paymentIntentId,_that.paymentMethodId,_that.paymentProvider,_that.shippingDetails,_that.shippingService,_that.items,_that.customerNotes,_that.deliveryInstructions,_that.internalNotes,_that.statusHistory,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String orderNumber,  String companyId,  Company? company,  String userId,  int hikeId,  Hike? hike,  double baseAmount,  double shippingCost,  double totalAmount,  double? taxAmount,  String? currency,  DeliveryType deliveryType,  DeliveryAddress? deliveryAddress, @JsonKey(name: 'delivery_address_raw')  Map<String, dynamic>? deliveryAddressRaw,  EnhancedOrderStatus status,  String? trackingNumber,  String? trackingUrl,  DateTime? estimatedDelivery,  DateTime? actualDelivery,  String? paymentIntentId,  String? paymentMethodId,  PaymentProvider? paymentProvider,  ShippingCostResult? shippingDetails,  String? shippingService,  List<OrderItem> items,  String? customerNotes,  String? deliveryInstructions,  String? internalNotes,  List<OrderStatusChange> statusHistory,  DateTime createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.companyId,_that.company,_that.userId,_that.hikeId,_that.hike,_that.baseAmount,_that.shippingCost,_that.totalAmount,_that.taxAmount,_that.currency,_that.deliveryType,_that.deliveryAddress,_that.deliveryAddressRaw,_that.status,_that.trackingNumber,_that.trackingUrl,_that.estimatedDelivery,_that.actualDelivery,_that.paymentIntentId,_that.paymentMethodId,_that.paymentProvider,_that.shippingDetails,_that.shippingService,_that.items,_that.customerNotes,_that.deliveryInstructions,_that.internalNotes,_that.statusHistory,_that.createdAt,_that.updatedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnhancedOrder implements EnhancedOrder {
  const _EnhancedOrder({required this.id, required this.orderNumber, required this.companyId, this.company, required this.userId, required this.hikeId, this.hike, required this.baseAmount, required this.shippingCost, required this.totalAmount, this.taxAmount, this.currency, required this.deliveryType, this.deliveryAddress, @JsonKey(name: 'delivery_address_raw') final  Map<String, dynamic>? deliveryAddressRaw, required this.status, this.trackingNumber, this.trackingUrl, this.estimatedDelivery, this.actualDelivery, this.paymentIntentId, this.paymentMethodId, this.paymentProvider, this.shippingDetails, this.shippingService, final  List<OrderItem> items = const [], this.customerNotes, this.deliveryInstructions, this.internalNotes, final  List<OrderStatusChange> statusHistory = const [], required this.createdAt, this.updatedAt, final  Map<String, dynamic> metadata = const {}}): _deliveryAddressRaw = deliveryAddressRaw,_items = items,_statusHistory = statusHistory,_metadata = metadata;
  factory _EnhancedOrder.fromJson(Map<String, dynamic> json) => _$EnhancedOrderFromJson(json);

@override final  int id;
@override final  String orderNumber;
// Multi-Vendor Context
@override final  String companyId;
@override final  Company? company;
// Populated via JOIN
// User und Hike Information
@override final  String userId;
@override final  int hikeId;
@override final  Hike? hike;
// Populated via JOIN
// Pricing Information
@override final  double baseAmount;
// Hike Preis ohne Versand
@override final  double shippingCost;
@override final  double totalAmount;
// baseAmount + shippingCost + eventuelle Steuern
@override final  double? taxAmount;
// Für zukünftige MwSt-Funktionalität
@override final  String? currency;
// ISO 4217 Currency Code (EUR, USD, etc.)
// Delivery Information
@override final  DeliveryType deliveryType;
@override final  DeliveryAddress? deliveryAddress;
// Strukturierte Adresse
 final  Map<String, dynamic>? _deliveryAddressRaw;
// Strukturierte Adresse
@override@JsonKey(name: 'delivery_address_raw') Map<String, dynamic>? get deliveryAddressRaw {
  final value = _deliveryAddressRaw;
  if (value == null) return null;
  if (_deliveryAddressRaw is EqualUnmodifiableMapView) return _deliveryAddressRaw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Fallback für alte Daten
// Status und Tracking
@override final  EnhancedOrderStatus status;
@override final  String? trackingNumber;
@override final  String? trackingUrl;
@override final  DateTime? estimatedDelivery;
@override final  DateTime? actualDelivery;
// Payment Information
@override final  String? paymentIntentId;
@override final  String? paymentMethodId;
@override final  PaymentProvider? paymentProvider;
// Shipping Information
@override final  ShippingCostResult? shippingDetails;
@override final  String? shippingService;
// 'Standard', 'Express', etc.
// Order Items (für zukünftige Multi-Item Bestellungen)
 final  List<OrderItem> _items;
// 'Standard', 'Express', etc.
// Order Items (für zukünftige Multi-Item Bestellungen)
@override@JsonKey() List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

// Customer Notes und Instructions
@override final  String? customerNotes;
@override final  String? deliveryInstructions;
@override final  String? internalNotes;
// Für Company-interne Notizen
// Status History (für Tracking)
 final  List<OrderStatusChange> _statusHistory;
// Für Company-interne Notizen
// Status History (für Tracking)
@override@JsonKey() List<OrderStatusChange> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

// System Fields
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
// Metadata für zusätzliche Informationen
 final  Map<String, dynamic> _metadata;
// Metadata für zusätzliche Informationen
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnhancedOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.hike, hike) || other.hike == hike)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&const DeepCollectionEquality().equals(other._deliveryAddressRaw, _deliveryAddressRaw)&&(identical(other.status, status) || other.status == status)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.actualDelivery, actualDelivery) || other.actualDelivery == actualDelivery)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentProvider, paymentProvider) || other.paymentProvider == paymentProvider)&&(identical(other.shippingDetails, shippingDetails) || other.shippingDetails == shippingDetails)&&(identical(other.shippingService, shippingService) || other.shippingService == shippingService)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.customerNotes, customerNotes) || other.customerNotes == customerNotes)&&(identical(other.deliveryInstructions, deliveryInstructions) || other.deliveryInstructions == deliveryInstructions)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,companyId,company,userId,hikeId,hike,baseAmount,shippingCost,totalAmount,taxAmount,currency,deliveryType,deliveryAddress,const DeepCollectionEquality().hash(_deliveryAddressRaw),status,trackingNumber,trackingUrl,estimatedDelivery,actualDelivery,paymentIntentId,paymentMethodId,paymentProvider,shippingDetails,shippingService,const DeepCollectionEquality().hash(_items),customerNotes,deliveryInstructions,internalNotes,const DeepCollectionEquality().hash(_statusHistory),createdAt,updatedAt,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'EnhancedOrder(id: $id, orderNumber: $orderNumber, companyId: $companyId, company: $company, userId: $userId, hikeId: $hikeId, hike: $hike, baseAmount: $baseAmount, shippingCost: $shippingCost, totalAmount: $totalAmount, taxAmount: $taxAmount, currency: $currency, deliveryType: $deliveryType, deliveryAddress: $deliveryAddress, deliveryAddressRaw: $deliveryAddressRaw, status: $status, trackingNumber: $trackingNumber, trackingUrl: $trackingUrl, estimatedDelivery: $estimatedDelivery, actualDelivery: $actualDelivery, paymentIntentId: $paymentIntentId, paymentMethodId: $paymentMethodId, paymentProvider: $paymentProvider, shippingDetails: $shippingDetails, shippingService: $shippingService, items: $items, customerNotes: $customerNotes, deliveryInstructions: $deliveryInstructions, internalNotes: $internalNotes, statusHistory: $statusHistory, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$EnhancedOrderCopyWith<$Res> implements $EnhancedOrderCopyWith<$Res> {
  factory _$EnhancedOrderCopyWith(_EnhancedOrder value, $Res Function(_EnhancedOrder) _then) = __$EnhancedOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, String orderNumber, String companyId, Company? company, String userId, int hikeId, Hike? hike, double baseAmount, double shippingCost, double totalAmount, double? taxAmount, String? currency, DeliveryType deliveryType, DeliveryAddress? deliveryAddress,@JsonKey(name: 'delivery_address_raw') Map<String, dynamic>? deliveryAddressRaw, EnhancedOrderStatus status, String? trackingNumber, String? trackingUrl, DateTime? estimatedDelivery, DateTime? actualDelivery, String? paymentIntentId, String? paymentMethodId, PaymentProvider? paymentProvider, ShippingCostResult? shippingDetails, String? shippingService, List<OrderItem> items, String? customerNotes, String? deliveryInstructions, String? internalNotes, List<OrderStatusChange> statusHistory, DateTime createdAt, DateTime? updatedAt, Map<String, dynamic> metadata
});


@override $CompanyCopyWith<$Res>? get company;@override $HikeCopyWith<$Res>? get hike;@override $DeliveryAddressCopyWith<$Res>? get deliveryAddress;@override $ShippingCostResultCopyWith<$Res>? get shippingDetails;

}
/// @nodoc
class __$EnhancedOrderCopyWithImpl<$Res>
    implements _$EnhancedOrderCopyWith<$Res> {
  __$EnhancedOrderCopyWithImpl(this._self, this._then);

  final _EnhancedOrder _self;
  final $Res Function(_EnhancedOrder) _then;

/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? companyId = null,Object? company = freezed,Object? userId = null,Object? hikeId = null,Object? hike = freezed,Object? baseAmount = null,Object? shippingCost = null,Object? totalAmount = null,Object? taxAmount = freezed,Object? currency = freezed,Object? deliveryType = null,Object? deliveryAddress = freezed,Object? deliveryAddressRaw = freezed,Object? status = null,Object? trackingNumber = freezed,Object? trackingUrl = freezed,Object? estimatedDelivery = freezed,Object? actualDelivery = freezed,Object? paymentIntentId = freezed,Object? paymentMethodId = freezed,Object? paymentProvider = freezed,Object? shippingDetails = freezed,Object? shippingService = freezed,Object? items = null,Object? customerNotes = freezed,Object? deliveryInstructions = freezed,Object? internalNotes = freezed,Object? statusHistory = null,Object? createdAt = null,Object? updatedAt = freezed,Object? metadata = null,}) {
  return _then(_EnhancedOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,hike: freezed == hike ? _self.hike : hike // ignore: cast_nullable_to_non_nullable
as Hike?,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,taxAmount: freezed == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress?,deliveryAddressRaw: freezed == deliveryAddressRaw ? _self._deliveryAddressRaw : deliveryAddressRaw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDelivery: freezed == actualDelivery ? _self.actualDelivery : actualDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,paymentProvider: freezed == paymentProvider ? _self.paymentProvider : paymentProvider // ignore: cast_nullable_to_non_nullable
as PaymentProvider?,shippingDetails: freezed == shippingDetails ? _self.shippingDetails : shippingDetails // ignore: cast_nullable_to_non_nullable
as ShippingCostResult?,shippingService: freezed == shippingService ? _self.shippingService : shippingService // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,deliveryInstructions: freezed == deliveryInstructions ? _self.deliveryInstructions : deliveryInstructions // ignore: cast_nullable_to_non_nullable
as String?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusChange>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of EnhancedOrder
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
}/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HikeCopyWith<$Res>? get hike {
    if (_self.hike == null) {
    return null;
  }

  return $HikeCopyWith<$Res>(_self.hike!, (value) {
    return _then(_self.copyWith(hike: value));
  });
}/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $DeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingCostResultCopyWith<$Res>? get shippingDetails {
    if (_self.shippingDetails == null) {
    return null;
  }

  return $ShippingCostResultCopyWith<$Res>(_self.shippingDetails!, (value) {
    return _then(_self.copyWith(shippingDetails: value));
  });
}
}


/// @nodoc
mixin _$OrderItem {

 int get id; int get hikeId; Hike? get hike; int get quantity; double get unitPrice; double get totalPrice; String? get notes;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.hike, hike) || other.hike == hike)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,hike,quantity,unitPrice,totalPrice,notes);

@override
String toString() {
  return 'OrderItem(id: $id, hikeId: $hikeId, hike: $hike, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 int id, int hikeId, Hike? hike, int quantity, double unitPrice, double totalPrice, String? notes
});


$HikeCopyWith<$Res>? get hike;

}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hikeId = null,Object? hike = freezed,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,hike: freezed == hike ? _self.hike : hike // ignore: cast_nullable_to_non_nullable
as Hike?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HikeCopyWith<$Res>? get hike {
    if (_self.hike == null) {
    return null;
  }

  return $HikeCopyWith<$Res>(_self.hike!, (value) {
    return _then(_self.copyWith(hike: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int hikeId,  Hike? hike,  int quantity,  double unitPrice,  double totalPrice,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.hikeId,_that.hike,_that.quantity,_that.unitPrice,_that.totalPrice,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int hikeId,  Hike? hike,  int quantity,  double unitPrice,  double totalPrice,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.id,_that.hikeId,_that.hike,_that.quantity,_that.unitPrice,_that.totalPrice,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int hikeId,  Hike? hike,  int quantity,  double unitPrice,  double totalPrice,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.hikeId,_that.hike,_that.quantity,_that.unitPrice,_that.totalPrice,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({required this.id, required this.hikeId, this.hike, this.quantity = 1, required this.unitPrice, required this.totalPrice, this.notes});
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override final  int id;
@override final  int hikeId;
@override final  Hike? hike;
@override@JsonKey() final  int quantity;
@override final  double unitPrice;
@override final  double totalPrice;
@override final  String? notes;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.hike, hike) || other.hike == hike)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hikeId,hike,quantity,unitPrice,totalPrice,notes);

@override
String toString() {
  return 'OrderItem(id: $id, hikeId: $hikeId, hike: $hike, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 int id, int hikeId, Hike? hike, int quantity, double unitPrice, double totalPrice, String? notes
});


@override $HikeCopyWith<$Res>? get hike;

}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hikeId = null,Object? hike = freezed,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? notes = freezed,}) {
  return _then(_OrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,hikeId: null == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int,hike: freezed == hike ? _self.hike : hike // ignore: cast_nullable_to_non_nullable
as Hike?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HikeCopyWith<$Res>? get hike {
    if (_self.hike == null) {
    return null;
  }

  return $HikeCopyWith<$Res>(_self.hike!, (value) {
    return _then(_self.copyWith(hike: value));
  });
}
}


/// @nodoc
mixin _$OrderStatusChange {

 EnhancedOrderStatus get fromStatus; EnhancedOrderStatus get toStatus; DateTime get changedAt; String? get reason; String? get notes; String? get changedBy;
/// Create a copy of OrderStatusChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderStatusChangeCopyWith<OrderStatusChange> get copyWith => _$OrderStatusChangeCopyWithImpl<OrderStatusChange>(this as OrderStatusChange, _$identity);

  /// Serializes this OrderStatusChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderStatusChange&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromStatus,toStatus,changedAt,reason,notes,changedBy);

@override
String toString() {
  return 'OrderStatusChange(fromStatus: $fromStatus, toStatus: $toStatus, changedAt: $changedAt, reason: $reason, notes: $notes, changedBy: $changedBy)';
}


}

/// @nodoc
abstract mixin class $OrderStatusChangeCopyWith<$Res>  {
  factory $OrderStatusChangeCopyWith(OrderStatusChange value, $Res Function(OrderStatusChange) _then) = _$OrderStatusChangeCopyWithImpl;
@useResult
$Res call({
 EnhancedOrderStatus fromStatus, EnhancedOrderStatus toStatus, DateTime changedAt, String? reason, String? notes, String? changedBy
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
@pragma('vm:prefer-inline') @override $Res call({Object? fromStatus = null,Object? toStatus = null,Object? changedAt = null,Object? reason = freezed,Object? notes = freezed,Object? changedBy = freezed,}) {
  return _then(_self.copyWith(
fromStatus: null == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,changedAt: null == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EnhancedOrderStatus fromStatus,  EnhancedOrderStatus toStatus,  DateTime changedAt,  String? reason,  String? notes,  String? changedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderStatusChange() when $default != null:
return $default(_that.fromStatus,_that.toStatus,_that.changedAt,_that.reason,_that.notes,_that.changedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EnhancedOrderStatus fromStatus,  EnhancedOrderStatus toStatus,  DateTime changedAt,  String? reason,  String? notes,  String? changedBy)  $default,) {final _that = this;
switch (_that) {
case _OrderStatusChange():
return $default(_that.fromStatus,_that.toStatus,_that.changedAt,_that.reason,_that.notes,_that.changedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EnhancedOrderStatus fromStatus,  EnhancedOrderStatus toStatus,  DateTime changedAt,  String? reason,  String? notes,  String? changedBy)?  $default,) {final _that = this;
switch (_that) {
case _OrderStatusChange() when $default != null:
return $default(_that.fromStatus,_that.toStatus,_that.changedAt,_that.reason,_that.notes,_that.changedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderStatusChange implements OrderStatusChange {
  const _OrderStatusChange({required this.fromStatus, required this.toStatus, required this.changedAt, this.reason, this.notes, this.changedBy});
  factory _OrderStatusChange.fromJson(Map<String, dynamic> json) => _$OrderStatusChangeFromJson(json);

@override final  EnhancedOrderStatus fromStatus;
@override final  EnhancedOrderStatus toStatus;
@override final  DateTime changedAt;
@override final  String? reason;
@override final  String? notes;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderStatusChange&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromStatus,toStatus,changedAt,reason,notes,changedBy);

@override
String toString() {
  return 'OrderStatusChange(fromStatus: $fromStatus, toStatus: $toStatus, changedAt: $changedAt, reason: $reason, notes: $notes, changedBy: $changedBy)';
}


}

/// @nodoc
abstract mixin class _$OrderStatusChangeCopyWith<$Res> implements $OrderStatusChangeCopyWith<$Res> {
  factory _$OrderStatusChangeCopyWith(_OrderStatusChange value, $Res Function(_OrderStatusChange) _then) = __$OrderStatusChangeCopyWithImpl;
@override @useResult
$Res call({
 EnhancedOrderStatus fromStatus, EnhancedOrderStatus toStatus, DateTime changedAt, String? reason, String? notes, String? changedBy
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
@override @pragma('vm:prefer-inline') $Res call({Object? fromStatus = null,Object? toStatus = null,Object? changedAt = null,Object? reason = freezed,Object? notes = freezed,Object? changedBy = freezed,}) {
  return _then(_OrderStatusChange(
fromStatus: null == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,changedAt: null == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
