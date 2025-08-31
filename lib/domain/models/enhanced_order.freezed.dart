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
 String get companyId; Company? get company;// Populated when loading with company details
// Order Details
 List<Hike> get items;@JsonKey(name: 'hike_id') int? get hikeId;// Add missing hikeId field
 double get subtotal;@JsonKey(name: 'tax_amount') double get taxAmount;@JsonKey(name: 'shipping_cost') double get shippingCost;@JsonKey(name: 'total_amount') double get totalAmount; String get currency;@JsonKey(name: 'base_amount') double get baseAmount;// Base amount without shipping
// Status & Timestamps
 EnhancedOrderStatus get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'confirmed_at') DateTime? get confirmedAt;@JsonKey(name: 'shipped_at') DateTime? get shippedAt;@JsonKey(name: 'delivered_at') DateTime? get deliveredAt;@JsonKey(name: 'cancelled_at') DateTime? get cancelledAt;// Customer Information
@JsonKey(name: 'customer_id') String get customerId;@JsonKey(name: 'customer_email') String? get customerEmail;@JsonKey(name: 'customer_phone') String? get customerPhone;// Delivery & Shipping
@JsonKey(name: 'delivery_type') DeliveryType get deliveryType;@JsonKey(name: 'delivery_address') DeliveryAddress get deliveryAddress;@JsonKey(name: 'tracking_number') String? get trackingNumber;@JsonKey(name: 'tracking_url') String? get trackingUrl;@JsonKey(name: 'shipping_carrier') String? get shippingCarrier;@JsonKey(name: 'shipping_method') String? get shippingMethod;@JsonKey(name: 'shipping_service') String? get shippingService;@JsonKey(name: 'estimated_delivery_date') String? get estimatedDeliveryDate;@JsonKey(name: 'estimated_delivery') DateTime? get estimatedDelivery;@JsonKey(name: 'actual_delivery') DateTime? get actualDelivery;@JsonKey(name: 'shipping_details') ShippingCostResult? get shippingDetails;// Payment Information
@JsonKey(name: 'payment_intent_id') String? get paymentIntentId;@JsonKey(name: 'payment_method_id') String? get paymentMethodId;@JsonKey(name: 'payment_status') String? get paymentStatus;@JsonKey(name: 'payment_date') DateTime? get paymentDate;// Additional Details
 String? get notes;@JsonKey(name: 'internal_notes') String? get internalNotes; Map<String, dynamic>? get metadata; List<String>? get tags;@JsonKey(name: 'status_history') List<OrderStatusChange> get statusHistory;// Vendor Specific
@JsonKey(name: 'vendor_order_id') String? get vendorOrderId;@JsonKey(name: 'vendor_notes') String? get vendorNotes;@JsonKey(name: 'vendor_metadata') Map<String, dynamic>? get vendorMetadata;
/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnhancedOrderCopyWith<EnhancedOrder> get copyWith => _$EnhancedOrderCopyWithImpl<EnhancedOrder>(this as EnhancedOrder, _$identity);

  /// Serializes this EnhancedOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnhancedOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.shippingCarrier, shippingCarrier) || other.shippingCarrier == shippingCarrier)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.shippingService, shippingService) || other.shippingService == shippingService)&&(identical(other.estimatedDeliveryDate, estimatedDeliveryDate) || other.estimatedDeliveryDate == estimatedDeliveryDate)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.actualDelivery, actualDelivery) || other.actualDelivery == actualDelivery)&&(identical(other.shippingDetails, shippingDetails) || other.shippingDetails == shippingDetails)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&(identical(other.vendorOrderId, vendorOrderId) || other.vendorOrderId == vendorOrderId)&&(identical(other.vendorNotes, vendorNotes) || other.vendorNotes == vendorNotes)&&const DeepCollectionEquality().equals(other.vendorMetadata, vendorMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,companyId,company,const DeepCollectionEquality().hash(items),hikeId,subtotal,taxAmount,shippingCost,totalAmount,currency,baseAmount,status,createdAt,updatedAt,confirmedAt,shippedAt,deliveredAt,cancelledAt,customerId,customerEmail,customerPhone,deliveryType,deliveryAddress,trackingNumber,trackingUrl,shippingCarrier,shippingMethod,shippingService,estimatedDeliveryDate,estimatedDelivery,actualDelivery,shippingDetails,paymentIntentId,paymentMethodId,paymentStatus,paymentDate,notes,internalNotes,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(statusHistory),vendorOrderId,vendorNotes,const DeepCollectionEquality().hash(vendorMetadata)]);

@override
String toString() {
  return 'EnhancedOrder(id: $id, orderNumber: $orderNumber, companyId: $companyId, company: $company, items: $items, hikeId: $hikeId, subtotal: $subtotal, taxAmount: $taxAmount, shippingCost: $shippingCost, totalAmount: $totalAmount, currency: $currency, baseAmount: $baseAmount, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, confirmedAt: $confirmedAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, customerId: $customerId, customerEmail: $customerEmail, customerPhone: $customerPhone, deliveryType: $deliveryType, deliveryAddress: $deliveryAddress, trackingNumber: $trackingNumber, trackingUrl: $trackingUrl, shippingCarrier: $shippingCarrier, shippingMethod: $shippingMethod, shippingService: $shippingService, estimatedDeliveryDate: $estimatedDeliveryDate, estimatedDelivery: $estimatedDelivery, actualDelivery: $actualDelivery, shippingDetails: $shippingDetails, paymentIntentId: $paymentIntentId, paymentMethodId: $paymentMethodId, paymentStatus: $paymentStatus, paymentDate: $paymentDate, notes: $notes, internalNotes: $internalNotes, metadata: $metadata, tags: $tags, statusHistory: $statusHistory, vendorOrderId: $vendorOrderId, vendorNotes: $vendorNotes, vendorMetadata: $vendorMetadata)';
}


}

/// @nodoc
abstract mixin class $EnhancedOrderCopyWith<$Res>  {
  factory $EnhancedOrderCopyWith(EnhancedOrder value, $Res Function(EnhancedOrder) _then) = _$EnhancedOrderCopyWithImpl;
@useResult
$Res call({
 int id, String orderNumber, String companyId, Company? company, List<Hike> items,@JsonKey(name: 'hike_id') int? hikeId, double subtotal,@JsonKey(name: 'tax_amount') double taxAmount,@JsonKey(name: 'shipping_cost') double shippingCost,@JsonKey(name: 'total_amount') double totalAmount, String currency,@JsonKey(name: 'base_amount') double baseAmount, EnhancedOrderStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'confirmed_at') DateTime? confirmedAt,@JsonKey(name: 'shipped_at') DateTime? shippedAt,@JsonKey(name: 'delivered_at') DateTime? deliveredAt,@JsonKey(name: 'cancelled_at') DateTime? cancelledAt,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'customer_email') String? customerEmail,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'delivery_type') DeliveryType deliveryType,@JsonKey(name: 'delivery_address') DeliveryAddress deliveryAddress,@JsonKey(name: 'tracking_number') String? trackingNumber,@JsonKey(name: 'tracking_url') String? trackingUrl,@JsonKey(name: 'shipping_carrier') String? shippingCarrier,@JsonKey(name: 'shipping_method') String? shippingMethod,@JsonKey(name: 'shipping_service') String? shippingService,@JsonKey(name: 'estimated_delivery_date') String? estimatedDeliveryDate,@JsonKey(name: 'estimated_delivery') DateTime? estimatedDelivery,@JsonKey(name: 'actual_delivery') DateTime? actualDelivery,@JsonKey(name: 'shipping_details') ShippingCostResult? shippingDetails,@JsonKey(name: 'payment_intent_id') String? paymentIntentId,@JsonKey(name: 'payment_method_id') String? paymentMethodId,@JsonKey(name: 'payment_status') String? paymentStatus,@JsonKey(name: 'payment_date') DateTime? paymentDate, String? notes,@JsonKey(name: 'internal_notes') String? internalNotes, Map<String, dynamic>? metadata, List<String>? tags,@JsonKey(name: 'status_history') List<OrderStatusChange> statusHistory,@JsonKey(name: 'vendor_order_id') String? vendorOrderId,@JsonKey(name: 'vendor_notes') String? vendorNotes,@JsonKey(name: 'vendor_metadata') Map<String, dynamic>? vendorMetadata
});


$CompanyCopyWith<$Res>? get company;

}
/// @nodoc
class _$EnhancedOrderCopyWithImpl<$Res>
    implements $EnhancedOrderCopyWith<$Res> {
  _$EnhancedOrderCopyWithImpl(this._self, this._then);

  final EnhancedOrder _self;
  final $Res Function(EnhancedOrder) _then;

/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? companyId = null,Object? company = freezed,Object? items = null,Object? hikeId = freezed,Object? subtotal = null,Object? taxAmount = null,Object? shippingCost = null,Object? totalAmount = null,Object? currency = null,Object? baseAmount = null,Object? status = null,Object? createdAt = null,Object? updatedAt = freezed,Object? confirmedAt = freezed,Object? shippedAt = freezed,Object? deliveredAt = freezed,Object? cancelledAt = freezed,Object? customerId = null,Object? customerEmail = freezed,Object? customerPhone = freezed,Object? deliveryType = null,Object? deliveryAddress = null,Object? trackingNumber = freezed,Object? trackingUrl = freezed,Object? shippingCarrier = freezed,Object? shippingMethod = freezed,Object? shippingService = freezed,Object? estimatedDeliveryDate = freezed,Object? estimatedDelivery = freezed,Object? actualDelivery = freezed,Object? shippingDetails = freezed,Object? paymentIntentId = freezed,Object? paymentMethodId = freezed,Object? paymentStatus = freezed,Object? paymentDate = freezed,Object? notes = freezed,Object? internalNotes = freezed,Object? metadata = freezed,Object? tags = freezed,Object? statusHistory = null,Object? vendorOrderId = freezed,Object? vendorNotes = freezed,Object? vendorMetadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Hike>,hikeId: freezed == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,shippingCarrier: freezed == shippingCarrier ? _self.shippingCarrier : shippingCarrier // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,shippingService: freezed == shippingService ? _self.shippingService : shippingService // ignore: cast_nullable_to_non_nullable
as String?,estimatedDeliveryDate: freezed == estimatedDeliveryDate ? _self.estimatedDeliveryDate : estimatedDeliveryDate // ignore: cast_nullable_to_non_nullable
as String?,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDelivery: freezed == actualDelivery ? _self.actualDelivery : actualDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,shippingDetails: freezed == shippingDetails ? _self.shippingDetails : shippingDetails // ignore: cast_nullable_to_non_nullable
as ShippingCostResult?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusChange>,vendorOrderId: freezed == vendorOrderId ? _self.vendorOrderId : vendorOrderId // ignore: cast_nullable_to_non_nullable
as String?,vendorNotes: freezed == vendorNotes ? _self.vendorNotes : vendorNotes // ignore: cast_nullable_to_non_nullable
as String?,vendorMetadata: freezed == vendorMetadata ? _self.vendorMetadata : vendorMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String orderNumber,  String companyId,  Company? company,  List<Hike> items, @JsonKey(name: 'hike_id')  int? hikeId,  double subtotal, @JsonKey(name: 'tax_amount')  double taxAmount, @JsonKey(name: 'shipping_cost')  double shippingCost, @JsonKey(name: 'total_amount')  double totalAmount,  String currency, @JsonKey(name: 'base_amount')  double baseAmount,  EnhancedOrderStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'confirmed_at')  DateTime? confirmedAt, @JsonKey(name: 'shipped_at')  DateTime? shippedAt, @JsonKey(name: 'delivered_at')  DateTime? deliveredAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'delivery_type')  DeliveryType deliveryType, @JsonKey(name: 'delivery_address')  DeliveryAddress deliveryAddress, @JsonKey(name: 'tracking_number')  String? trackingNumber, @JsonKey(name: 'tracking_url')  String? trackingUrl, @JsonKey(name: 'shipping_carrier')  String? shippingCarrier, @JsonKey(name: 'shipping_method')  String? shippingMethod, @JsonKey(name: 'shipping_service')  String? shippingService, @JsonKey(name: 'estimated_delivery_date')  String? estimatedDeliveryDate, @JsonKey(name: 'estimated_delivery')  DateTime? estimatedDelivery, @JsonKey(name: 'actual_delivery')  DateTime? actualDelivery, @JsonKey(name: 'shipping_details')  ShippingCostResult? shippingDetails, @JsonKey(name: 'payment_intent_id')  String? paymentIntentId, @JsonKey(name: 'payment_method_id')  String? paymentMethodId, @JsonKey(name: 'payment_status')  String? paymentStatus, @JsonKey(name: 'payment_date')  DateTime? paymentDate,  String? notes, @JsonKey(name: 'internal_notes')  String? internalNotes,  Map<String, dynamic>? metadata,  List<String>? tags, @JsonKey(name: 'status_history')  List<OrderStatusChange> statusHistory, @JsonKey(name: 'vendor_order_id')  String? vendorOrderId, @JsonKey(name: 'vendor_notes')  String? vendorNotes, @JsonKey(name: 'vendor_metadata')  Map<String, dynamic>? vendorMetadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.companyId,_that.company,_that.items,_that.hikeId,_that.subtotal,_that.taxAmount,_that.shippingCost,_that.totalAmount,_that.currency,_that.baseAmount,_that.status,_that.createdAt,_that.updatedAt,_that.confirmedAt,_that.shippedAt,_that.deliveredAt,_that.cancelledAt,_that.customerId,_that.customerEmail,_that.customerPhone,_that.deliveryType,_that.deliveryAddress,_that.trackingNumber,_that.trackingUrl,_that.shippingCarrier,_that.shippingMethod,_that.shippingService,_that.estimatedDeliveryDate,_that.estimatedDelivery,_that.actualDelivery,_that.shippingDetails,_that.paymentIntentId,_that.paymentMethodId,_that.paymentStatus,_that.paymentDate,_that.notes,_that.internalNotes,_that.metadata,_that.tags,_that.statusHistory,_that.vendorOrderId,_that.vendorNotes,_that.vendorMetadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String orderNumber,  String companyId,  Company? company,  List<Hike> items, @JsonKey(name: 'hike_id')  int? hikeId,  double subtotal, @JsonKey(name: 'tax_amount')  double taxAmount, @JsonKey(name: 'shipping_cost')  double shippingCost, @JsonKey(name: 'total_amount')  double totalAmount,  String currency, @JsonKey(name: 'base_amount')  double baseAmount,  EnhancedOrderStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'confirmed_at')  DateTime? confirmedAt, @JsonKey(name: 'shipped_at')  DateTime? shippedAt, @JsonKey(name: 'delivered_at')  DateTime? deliveredAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'delivery_type')  DeliveryType deliveryType, @JsonKey(name: 'delivery_address')  DeliveryAddress deliveryAddress, @JsonKey(name: 'tracking_number')  String? trackingNumber, @JsonKey(name: 'tracking_url')  String? trackingUrl, @JsonKey(name: 'shipping_carrier')  String? shippingCarrier, @JsonKey(name: 'shipping_method')  String? shippingMethod, @JsonKey(name: 'shipping_service')  String? shippingService, @JsonKey(name: 'estimated_delivery_date')  String? estimatedDeliveryDate, @JsonKey(name: 'estimated_delivery')  DateTime? estimatedDelivery, @JsonKey(name: 'actual_delivery')  DateTime? actualDelivery, @JsonKey(name: 'shipping_details')  ShippingCostResult? shippingDetails, @JsonKey(name: 'payment_intent_id')  String? paymentIntentId, @JsonKey(name: 'payment_method_id')  String? paymentMethodId, @JsonKey(name: 'payment_status')  String? paymentStatus, @JsonKey(name: 'payment_date')  DateTime? paymentDate,  String? notes, @JsonKey(name: 'internal_notes')  String? internalNotes,  Map<String, dynamic>? metadata,  List<String>? tags, @JsonKey(name: 'status_history')  List<OrderStatusChange> statusHistory, @JsonKey(name: 'vendor_order_id')  String? vendorOrderId, @JsonKey(name: 'vendor_notes')  String? vendorNotes, @JsonKey(name: 'vendor_metadata')  Map<String, dynamic>? vendorMetadata)  $default,) {final _that = this;
switch (_that) {
case _EnhancedOrder():
return $default(_that.id,_that.orderNumber,_that.companyId,_that.company,_that.items,_that.hikeId,_that.subtotal,_that.taxAmount,_that.shippingCost,_that.totalAmount,_that.currency,_that.baseAmount,_that.status,_that.createdAt,_that.updatedAt,_that.confirmedAt,_that.shippedAt,_that.deliveredAt,_that.cancelledAt,_that.customerId,_that.customerEmail,_that.customerPhone,_that.deliveryType,_that.deliveryAddress,_that.trackingNumber,_that.trackingUrl,_that.shippingCarrier,_that.shippingMethod,_that.shippingService,_that.estimatedDeliveryDate,_that.estimatedDelivery,_that.actualDelivery,_that.shippingDetails,_that.paymentIntentId,_that.paymentMethodId,_that.paymentStatus,_that.paymentDate,_that.notes,_that.internalNotes,_that.metadata,_that.tags,_that.statusHistory,_that.vendorOrderId,_that.vendorNotes,_that.vendorMetadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String orderNumber,  String companyId,  Company? company,  List<Hike> items, @JsonKey(name: 'hike_id')  int? hikeId,  double subtotal, @JsonKey(name: 'tax_amount')  double taxAmount, @JsonKey(name: 'shipping_cost')  double shippingCost, @JsonKey(name: 'total_amount')  double totalAmount,  String currency, @JsonKey(name: 'base_amount')  double baseAmount,  EnhancedOrderStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'confirmed_at')  DateTime? confirmedAt, @JsonKey(name: 'shipped_at')  DateTime? shippedAt, @JsonKey(name: 'delivered_at')  DateTime? deliveredAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customer_email')  String? customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'delivery_type')  DeliveryType deliveryType, @JsonKey(name: 'delivery_address')  DeliveryAddress deliveryAddress, @JsonKey(name: 'tracking_number')  String? trackingNumber, @JsonKey(name: 'tracking_url')  String? trackingUrl, @JsonKey(name: 'shipping_carrier')  String? shippingCarrier, @JsonKey(name: 'shipping_method')  String? shippingMethod, @JsonKey(name: 'shipping_service')  String? shippingService, @JsonKey(name: 'estimated_delivery_date')  String? estimatedDeliveryDate, @JsonKey(name: 'estimated_delivery')  DateTime? estimatedDelivery, @JsonKey(name: 'actual_delivery')  DateTime? actualDelivery, @JsonKey(name: 'shipping_details')  ShippingCostResult? shippingDetails, @JsonKey(name: 'payment_intent_id')  String? paymentIntentId, @JsonKey(name: 'payment_method_id')  String? paymentMethodId, @JsonKey(name: 'payment_status')  String? paymentStatus, @JsonKey(name: 'payment_date')  DateTime? paymentDate,  String? notes, @JsonKey(name: 'internal_notes')  String? internalNotes,  Map<String, dynamic>? metadata,  List<String>? tags, @JsonKey(name: 'status_history')  List<OrderStatusChange> statusHistory, @JsonKey(name: 'vendor_order_id')  String? vendorOrderId, @JsonKey(name: 'vendor_notes')  String? vendorNotes, @JsonKey(name: 'vendor_metadata')  Map<String, dynamic>? vendorMetadata)?  $default,) {final _that = this;
switch (_that) {
case _EnhancedOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.companyId,_that.company,_that.items,_that.hikeId,_that.subtotal,_that.taxAmount,_that.shippingCost,_that.totalAmount,_that.currency,_that.baseAmount,_that.status,_that.createdAt,_that.updatedAt,_that.confirmedAt,_that.shippedAt,_that.deliveredAt,_that.cancelledAt,_that.customerId,_that.customerEmail,_that.customerPhone,_that.deliveryType,_that.deliveryAddress,_that.trackingNumber,_that.trackingUrl,_that.shippingCarrier,_that.shippingMethod,_that.shippingService,_that.estimatedDeliveryDate,_that.estimatedDelivery,_that.actualDelivery,_that.shippingDetails,_that.paymentIntentId,_that.paymentMethodId,_that.paymentStatus,_that.paymentDate,_that.notes,_that.internalNotes,_that.metadata,_that.tags,_that.statusHistory,_that.vendorOrderId,_that.vendorNotes,_that.vendorMetadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnhancedOrder implements EnhancedOrder {
  const _EnhancedOrder({required this.id, required this.orderNumber, required this.companyId, this.company, final  List<Hike> items = const [], @JsonKey(name: 'hike_id') this.hikeId, required this.subtotal, @JsonKey(name: 'tax_amount') this.taxAmount = 0.0, @JsonKey(name: 'shipping_cost') this.shippingCost = 0.0, @JsonKey(name: 'total_amount') required this.totalAmount, this.currency = 'EUR', @JsonKey(name: 'base_amount') this.baseAmount = 0.0, this.status = EnhancedOrderStatus.pending, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'confirmed_at') this.confirmedAt, @JsonKey(name: 'shipped_at') this.shippedAt, @JsonKey(name: 'delivered_at') this.deliveredAt, @JsonKey(name: 'cancelled_at') this.cancelledAt, @JsonKey(name: 'customer_id') required this.customerId, @JsonKey(name: 'customer_email') this.customerEmail, @JsonKey(name: 'customer_phone') this.customerPhone, @JsonKey(name: 'delivery_type') this.deliveryType = DeliveryType.standardShipping, @JsonKey(name: 'delivery_address') required this.deliveryAddress, @JsonKey(name: 'tracking_number') this.trackingNumber, @JsonKey(name: 'tracking_url') this.trackingUrl, @JsonKey(name: 'shipping_carrier') this.shippingCarrier, @JsonKey(name: 'shipping_method') this.shippingMethod, @JsonKey(name: 'shipping_service') this.shippingService, @JsonKey(name: 'estimated_delivery_date') this.estimatedDeliveryDate, @JsonKey(name: 'estimated_delivery') this.estimatedDelivery, @JsonKey(name: 'actual_delivery') this.actualDelivery, @JsonKey(name: 'shipping_details') this.shippingDetails, @JsonKey(name: 'payment_intent_id') this.paymentIntentId, @JsonKey(name: 'payment_method_id') this.paymentMethodId, @JsonKey(name: 'payment_status') this.paymentStatus, @JsonKey(name: 'payment_date') this.paymentDate, this.notes, @JsonKey(name: 'internal_notes') this.internalNotes, final  Map<String, dynamic>? metadata, final  List<String>? tags = const [], @JsonKey(name: 'status_history') final  List<OrderStatusChange> statusHistory = const [], @JsonKey(name: 'vendor_order_id') this.vendorOrderId, @JsonKey(name: 'vendor_notes') this.vendorNotes, @JsonKey(name: 'vendor_metadata') final  Map<String, dynamic>? vendorMetadata}): _items = items,_metadata = metadata,_tags = tags,_statusHistory = statusHistory,_vendorMetadata = vendorMetadata;
  factory _EnhancedOrder.fromJson(Map<String, dynamic> json) => _$EnhancedOrderFromJson(json);

@override final  int id;
@override final  String orderNumber;
// Multi-Vendor Context
@override final  String companyId;
@override final  Company? company;
// Populated when loading with company details
// Order Details
 final  List<Hike> _items;
// Populated when loading with company details
// Order Details
@override@JsonKey() List<Hike> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'hike_id') final  int? hikeId;
// Add missing hikeId field
@override final  double subtotal;
@override@JsonKey(name: 'tax_amount') final  double taxAmount;
@override@JsonKey(name: 'shipping_cost') final  double shippingCost;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey() final  String currency;
@override@JsonKey(name: 'base_amount') final  double baseAmount;
// Base amount without shipping
// Status & Timestamps
@override@JsonKey() final  EnhancedOrderStatus status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'confirmed_at') final  DateTime? confirmedAt;
@override@JsonKey(name: 'shipped_at') final  DateTime? shippedAt;
@override@JsonKey(name: 'delivered_at') final  DateTime? deliveredAt;
@override@JsonKey(name: 'cancelled_at') final  DateTime? cancelledAt;
// Customer Information
@override@JsonKey(name: 'customer_id') final  String customerId;
@override@JsonKey(name: 'customer_email') final  String? customerEmail;
@override@JsonKey(name: 'customer_phone') final  String? customerPhone;
// Delivery & Shipping
@override@JsonKey(name: 'delivery_type') final  DeliveryType deliveryType;
@override@JsonKey(name: 'delivery_address') final  DeliveryAddress deliveryAddress;
@override@JsonKey(name: 'tracking_number') final  String? trackingNumber;
@override@JsonKey(name: 'tracking_url') final  String? trackingUrl;
@override@JsonKey(name: 'shipping_carrier') final  String? shippingCarrier;
@override@JsonKey(name: 'shipping_method') final  String? shippingMethod;
@override@JsonKey(name: 'shipping_service') final  String? shippingService;
@override@JsonKey(name: 'estimated_delivery_date') final  String? estimatedDeliveryDate;
@override@JsonKey(name: 'estimated_delivery') final  DateTime? estimatedDelivery;
@override@JsonKey(name: 'actual_delivery') final  DateTime? actualDelivery;
@override@JsonKey(name: 'shipping_details') final  ShippingCostResult? shippingDetails;
// Payment Information
@override@JsonKey(name: 'payment_intent_id') final  String? paymentIntentId;
@override@JsonKey(name: 'payment_method_id') final  String? paymentMethodId;
@override@JsonKey(name: 'payment_status') final  String? paymentStatus;
@override@JsonKey(name: 'payment_date') final  DateTime? paymentDate;
// Additional Details
@override final  String? notes;
@override@JsonKey(name: 'internal_notes') final  String? internalNotes;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _tags;
@override@JsonKey() List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<OrderStatusChange> _statusHistory;
@override@JsonKey(name: 'status_history') List<OrderStatusChange> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

// Vendor Specific
@override@JsonKey(name: 'vendor_order_id') final  String? vendorOrderId;
@override@JsonKey(name: 'vendor_notes') final  String? vendorNotes;
 final  Map<String, dynamic>? _vendorMetadata;
@override@JsonKey(name: 'vendor_metadata') Map<String, dynamic>? get vendorMetadata {
  final value = _vendorMetadata;
  if (value == null) return null;
  if (_vendorMetadata is EqualUnmodifiableMapView) return _vendorMetadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnhancedOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hikeId, hikeId) || other.hikeId == hikeId)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.baseAmount, baseAmount) || other.baseAmount == baseAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl)&&(identical(other.shippingCarrier, shippingCarrier) || other.shippingCarrier == shippingCarrier)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.shippingService, shippingService) || other.shippingService == shippingService)&&(identical(other.estimatedDeliveryDate, estimatedDeliveryDate) || other.estimatedDeliveryDate == estimatedDeliveryDate)&&(identical(other.estimatedDelivery, estimatedDelivery) || other.estimatedDelivery == estimatedDelivery)&&(identical(other.actualDelivery, actualDelivery) || other.actualDelivery == actualDelivery)&&(identical(other.shippingDetails, shippingDetails) || other.shippingDetails == shippingDetails)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.internalNotes, internalNotes) || other.internalNotes == internalNotes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&(identical(other.vendorOrderId, vendorOrderId) || other.vendorOrderId == vendorOrderId)&&(identical(other.vendorNotes, vendorNotes) || other.vendorNotes == vendorNotes)&&const DeepCollectionEquality().equals(other._vendorMetadata, _vendorMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,orderNumber,companyId,company,const DeepCollectionEquality().hash(_items),hikeId,subtotal,taxAmount,shippingCost,totalAmount,currency,baseAmount,status,createdAt,updatedAt,confirmedAt,shippedAt,deliveredAt,cancelledAt,customerId,customerEmail,customerPhone,deliveryType,deliveryAddress,trackingNumber,trackingUrl,shippingCarrier,shippingMethod,shippingService,estimatedDeliveryDate,estimatedDelivery,actualDelivery,shippingDetails,paymentIntentId,paymentMethodId,paymentStatus,paymentDate,notes,internalNotes,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_statusHistory),vendorOrderId,vendorNotes,const DeepCollectionEquality().hash(_vendorMetadata)]);

@override
String toString() {
  return 'EnhancedOrder(id: $id, orderNumber: $orderNumber, companyId: $companyId, company: $company, items: $items, hikeId: $hikeId, subtotal: $subtotal, taxAmount: $taxAmount, shippingCost: $shippingCost, totalAmount: $totalAmount, currency: $currency, baseAmount: $baseAmount, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, confirmedAt: $confirmedAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, customerId: $customerId, customerEmail: $customerEmail, customerPhone: $customerPhone, deliveryType: $deliveryType, deliveryAddress: $deliveryAddress, trackingNumber: $trackingNumber, trackingUrl: $trackingUrl, shippingCarrier: $shippingCarrier, shippingMethod: $shippingMethod, shippingService: $shippingService, estimatedDeliveryDate: $estimatedDeliveryDate, estimatedDelivery: $estimatedDelivery, actualDelivery: $actualDelivery, shippingDetails: $shippingDetails, paymentIntentId: $paymentIntentId, paymentMethodId: $paymentMethodId, paymentStatus: $paymentStatus, paymentDate: $paymentDate, notes: $notes, internalNotes: $internalNotes, metadata: $metadata, tags: $tags, statusHistory: $statusHistory, vendorOrderId: $vendorOrderId, vendorNotes: $vendorNotes, vendorMetadata: $vendorMetadata)';
}


}

/// @nodoc
abstract mixin class _$EnhancedOrderCopyWith<$Res> implements $EnhancedOrderCopyWith<$Res> {
  factory _$EnhancedOrderCopyWith(_EnhancedOrder value, $Res Function(_EnhancedOrder) _then) = __$EnhancedOrderCopyWithImpl;
@override @useResult
$Res call({
 int id, String orderNumber, String companyId, Company? company, List<Hike> items,@JsonKey(name: 'hike_id') int? hikeId, double subtotal,@JsonKey(name: 'tax_amount') double taxAmount,@JsonKey(name: 'shipping_cost') double shippingCost,@JsonKey(name: 'total_amount') double totalAmount, String currency,@JsonKey(name: 'base_amount') double baseAmount, EnhancedOrderStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'confirmed_at') DateTime? confirmedAt,@JsonKey(name: 'shipped_at') DateTime? shippedAt,@JsonKey(name: 'delivered_at') DateTime? deliveredAt,@JsonKey(name: 'cancelled_at') DateTime? cancelledAt,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'customer_email') String? customerEmail,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'delivery_type') DeliveryType deliveryType,@JsonKey(name: 'delivery_address') DeliveryAddress deliveryAddress,@JsonKey(name: 'tracking_number') String? trackingNumber,@JsonKey(name: 'tracking_url') String? trackingUrl,@JsonKey(name: 'shipping_carrier') String? shippingCarrier,@JsonKey(name: 'shipping_method') String? shippingMethod,@JsonKey(name: 'shipping_service') String? shippingService,@JsonKey(name: 'estimated_delivery_date') String? estimatedDeliveryDate,@JsonKey(name: 'estimated_delivery') DateTime? estimatedDelivery,@JsonKey(name: 'actual_delivery') DateTime? actualDelivery,@JsonKey(name: 'shipping_details') ShippingCostResult? shippingDetails,@JsonKey(name: 'payment_intent_id') String? paymentIntentId,@JsonKey(name: 'payment_method_id') String? paymentMethodId,@JsonKey(name: 'payment_status') String? paymentStatus,@JsonKey(name: 'payment_date') DateTime? paymentDate, String? notes,@JsonKey(name: 'internal_notes') String? internalNotes, Map<String, dynamic>? metadata, List<String>? tags,@JsonKey(name: 'status_history') List<OrderStatusChange> statusHistory,@JsonKey(name: 'vendor_order_id') String? vendorOrderId,@JsonKey(name: 'vendor_notes') String? vendorNotes,@JsonKey(name: 'vendor_metadata') Map<String, dynamic>? vendorMetadata
});


@override $CompanyCopyWith<$Res>? get company;

}
/// @nodoc
class __$EnhancedOrderCopyWithImpl<$Res>
    implements _$EnhancedOrderCopyWith<$Res> {
  __$EnhancedOrderCopyWithImpl(this._self, this._then);

  final _EnhancedOrder _self;
  final $Res Function(_EnhancedOrder) _then;

/// Create a copy of EnhancedOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? companyId = null,Object? company = freezed,Object? items = null,Object? hikeId = freezed,Object? subtotal = null,Object? taxAmount = null,Object? shippingCost = null,Object? totalAmount = null,Object? currency = null,Object? baseAmount = null,Object? status = null,Object? createdAt = null,Object? updatedAt = freezed,Object? confirmedAt = freezed,Object? shippedAt = freezed,Object? deliveredAt = freezed,Object? cancelledAt = freezed,Object? customerId = null,Object? customerEmail = freezed,Object? customerPhone = freezed,Object? deliveryType = null,Object? deliveryAddress = null,Object? trackingNumber = freezed,Object? trackingUrl = freezed,Object? shippingCarrier = freezed,Object? shippingMethod = freezed,Object? shippingService = freezed,Object? estimatedDeliveryDate = freezed,Object? estimatedDelivery = freezed,Object? actualDelivery = freezed,Object? shippingDetails = freezed,Object? paymentIntentId = freezed,Object? paymentMethodId = freezed,Object? paymentStatus = freezed,Object? paymentDate = freezed,Object? notes = freezed,Object? internalNotes = freezed,Object? metadata = freezed,Object? tags = freezed,Object? statusHistory = null,Object? vendorOrderId = freezed,Object? vendorNotes = freezed,Object? vendorMetadata = freezed,}) {
  return _then(_EnhancedOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Hike>,hikeId: freezed == hikeId ? _self.hikeId : hikeId // ignore: cast_nullable_to_non_nullable
as int?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,baseAmount: null == baseAmount ? _self.baseAmount : baseAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnhancedOrderStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,deliveryType: null == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as DeliveryType,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as DeliveryAddress,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,shippingCarrier: freezed == shippingCarrier ? _self.shippingCarrier : shippingCarrier // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,shippingService: freezed == shippingService ? _self.shippingService : shippingService // ignore: cast_nullable_to_non_nullable
as String?,estimatedDeliveryDate: freezed == estimatedDeliveryDate ? _self.estimatedDeliveryDate : estimatedDeliveryDate // ignore: cast_nullable_to_non_nullable
as String?,estimatedDelivery: freezed == estimatedDelivery ? _self.estimatedDelivery : estimatedDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDelivery: freezed == actualDelivery ? _self.actualDelivery : actualDelivery // ignore: cast_nullable_to_non_nullable
as DateTime?,shippingDetails: freezed == shippingDetails ? _self.shippingDetails : shippingDetails // ignore: cast_nullable_to_non_nullable
as ShippingCostResult?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethodId: freezed == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentDate: freezed == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,internalNotes: freezed == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusChange>,vendorOrderId: freezed == vendorOrderId ? _self.vendorOrderId : vendorOrderId // ignore: cast_nullable_to_non_nullable
as String?,vendorNotes: freezed == vendorNotes ? _self.vendorNotes : vendorNotes // ignore: cast_nullable_to_non_nullable
as String?,vendorMetadata: freezed == vendorMetadata ? _self._vendorMetadata : vendorMetadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
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
}
}


/// @nodoc
mixin _$OrderStatusChange {

@JsonKey(name: 'from_status') EnhancedOrderStatus get fromStatus;@JsonKey(name: 'to_status') EnhancedOrderStatus get toStatus;@JsonKey(name: 'changed_at') DateTime get changedAt; String? get reason; String? get notes;@JsonKey(name: 'changed_by') String? get changedBy;
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
@JsonKey(name: 'from_status') EnhancedOrderStatus fromStatus,@JsonKey(name: 'to_status') EnhancedOrderStatus toStatus,@JsonKey(name: 'changed_at') DateTime changedAt, String? reason, String? notes,@JsonKey(name: 'changed_by') String? changedBy
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'from_status')  EnhancedOrderStatus fromStatus, @JsonKey(name: 'to_status')  EnhancedOrderStatus toStatus, @JsonKey(name: 'changed_at')  DateTime changedAt,  String? reason,  String? notes, @JsonKey(name: 'changed_by')  String? changedBy)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'from_status')  EnhancedOrderStatus fromStatus, @JsonKey(name: 'to_status')  EnhancedOrderStatus toStatus, @JsonKey(name: 'changed_at')  DateTime changedAt,  String? reason,  String? notes, @JsonKey(name: 'changed_by')  String? changedBy)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'from_status')  EnhancedOrderStatus fromStatus, @JsonKey(name: 'to_status')  EnhancedOrderStatus toStatus, @JsonKey(name: 'changed_at')  DateTime changedAt,  String? reason,  String? notes, @JsonKey(name: 'changed_by')  String? changedBy)?  $default,) {final _that = this;
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
  const _OrderStatusChange({@JsonKey(name: 'from_status') required this.fromStatus, @JsonKey(name: 'to_status') required this.toStatus, @JsonKey(name: 'changed_at') required this.changedAt, this.reason, this.notes, @JsonKey(name: 'changed_by') this.changedBy});
  factory _OrderStatusChange.fromJson(Map<String, dynamic> json) => _$OrderStatusChangeFromJson(json);

@override@JsonKey(name: 'from_status') final  EnhancedOrderStatus fromStatus;
@override@JsonKey(name: 'to_status') final  EnhancedOrderStatus toStatus;
@override@JsonKey(name: 'changed_at') final  DateTime changedAt;
@override final  String? reason;
@override final  String? notes;
@override@JsonKey(name: 'changed_by') final  String? changedBy;

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
@JsonKey(name: 'from_status') EnhancedOrderStatus fromStatus,@JsonKey(name: 'to_status') EnhancedOrderStatus toStatus,@JsonKey(name: 'changed_at') DateTime changedAt, String? reason, String? notes,@JsonKey(name: 'changed_by') String? changedBy
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
