import 'package:freezed_annotation/freezed_annotation.dart';
import 'company.dart';
import 'delivery_address.dart';
import 'hike.dart';
import 'delivery_address.dart' show ShippingCostResult;

part 'enhanced_order.freezed.dart';
part 'enhanced_order.g.dart';

/// Enhanced Order Status für erweiterte Funktionalität
enum EnhancedOrderStatus {
  pending,
  paymentPending, // Waiting for payment confirmation
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
  failed, // Payment or processing failed
}

/// Delivery Type enum
enum DeliveryType {
  pickup,
  standardShipping,
  expressShipping,
  premiumShipping,
}

/// Enhanced Order Model für Multi-Vendor System
/// Unterstützt komplexe Bestellungen mit Company-Kontext und detaillierter Adressverwaltung
@freezed
abstract class EnhancedOrder with _$EnhancedOrder {
  const factory EnhancedOrder({
    required int id,
    required String orderNumber,
    
    // Multi-Vendor Context
    required String companyId,
    Company? company, // Populated when loading with company details
    
    // Order Details
    @Default([]) List<Hike> items,
    @JsonKey(name: 'hike_id') int? hikeId, // Add missing hikeId field
    required double subtotal,
    @JsonKey(name: 'tax_amount') @Default(0.0) double taxAmount,
    @JsonKey(name: 'shipping_cost') @Default(0.0) double shippingCost,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @Default('EUR') String currency,
    @JsonKey(name: 'base_amount') @Default(0.0) double baseAmount, // Base amount without shipping
    
    // Status & Timestamps
    @Default(EnhancedOrderStatus.pending) EnhancedOrderStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'confirmed_at') DateTime? confirmedAt,
    @JsonKey(name: 'shipped_at') DateTime? shippedAt,
    @JsonKey(name: 'delivered_at') DateTime? deliveredAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    
    // Customer Information
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'customer_email') String? customerEmail,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    
    // Delivery & Shipping
    @JsonKey(name: 'delivery_type') @Default(DeliveryType.standardShipping) DeliveryType deliveryType,
    @JsonKey(name: 'delivery_address') required DeliveryAddress deliveryAddress,
    @JsonKey(name: 'tracking_number') String? trackingNumber,
    @JsonKey(name: 'tracking_url') String? trackingUrl,
    @JsonKey(name: 'shipping_carrier') String? shippingCarrier,
    @JsonKey(name: 'shipping_method') String? shippingMethod,
    @JsonKey(name: 'shipping_service') String? shippingService,
    @JsonKey(name: 'estimated_delivery_date') String? estimatedDeliveryDate,
    @JsonKey(name: 'estimated_delivery') DateTime? estimatedDelivery,
    @JsonKey(name: 'actual_delivery') DateTime? actualDelivery,
    @JsonKey(name: 'shipping_details') ShippingCostResult? shippingDetails,
    
    // Payment Information
    @JsonKey(name: 'payment_intent_id') String? paymentIntentId,
    @JsonKey(name: 'payment_method_id') String? paymentMethodId,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'payment_date') DateTime? paymentDate,
    
    // Additional Details
    String? notes,
    @JsonKey(name: 'internal_notes') String? internalNotes,
    Map<String, dynamic>? metadata,
    @Default([]) List<String>? tags,
    @JsonKey(name: 'status_history') @Default([]) List<OrderStatusChange> statusHistory,
    
    // Vendor Specific
    @JsonKey(name: 'vendor_order_id') String? vendorOrderId,
    @JsonKey(name: 'vendor_notes') String? vendorNotes,
    @JsonKey(name: 'vendor_metadata') Map<String, dynamic>? vendorMetadata,
  }) = _EnhancedOrder;

  factory EnhancedOrder.fromJson(Map<String, dynamic> json) => _$EnhancedOrderFromJson(json);
}

/// Extensions for computed properties (can't be part of Freezed class)
extension EnhancedOrderExtensions on EnhancedOrder {
  String get formattedOrderNumber => '#$orderNumber';
  
  bool get requiresDeliveryAddress => deliveryType != DeliveryType.pickup;
  
  bool get canBeTracked => trackingNumber?.isNotEmpty == true && 
      [EnhancedOrderStatus.shipped, EnhancedOrderStatus.outForDelivery].contains(status);
  
  bool get canBeCancelled => [EnhancedOrderStatus.pending, EnhancedOrderStatus.paymentPending, 
      EnhancedOrderStatus.confirmed].contains(status);
  
  bool get isFinalStatus => [EnhancedOrderStatus.delivered, EnhancedOrderStatus.cancelled, 
      EnhancedOrderStatus.refunded, EnhancedOrderStatus.failed].contains(status);
  
  String get statusDisplayText {
    switch (status) {
      case EnhancedOrderStatus.pending:
        return 'Ausstehend';
      case EnhancedOrderStatus.paymentPending:
        return 'Zahlung ausstehend';
      case EnhancedOrderStatus.confirmed:
        return 'Bestätigt';
      case EnhancedOrderStatus.processing:
        return 'In Bearbeitung';
      case EnhancedOrderStatus.shipped:
        return 'Versendet';
      case EnhancedOrderStatus.outForDelivery:
        return 'Zustellung unterwegs';
      case EnhancedOrderStatus.delivered:
        return 'Zugestellt';
      case EnhancedOrderStatus.cancelled:
        return 'Storniert';
      case EnhancedOrderStatus.refunded:
        return 'Erstattet';
      case EnhancedOrderStatus.failed:
        return 'Fehlgeschlagen';
    }
  }
  
  String get deliveryTypeDisplayText {
    switch (deliveryType) {
      case DeliveryType.pickup:
        return 'Abholung vor Ort';
      case DeliveryType.standardShipping:
        return 'Standard-Versand';
      case DeliveryType.expressShipping:
        return 'Express-Versand';
      case DeliveryType.premiumShipping:
        return 'Premium-Versand';
    }
  }
}

/// Order Status Change für Status History
@freezed
abstract class OrderStatusChange with _$OrderStatusChange {
  const factory OrderStatusChange({
    @JsonKey(name: 'from_status') required EnhancedOrderStatus fromStatus,
    @JsonKey(name: 'to_status') required EnhancedOrderStatus toStatus,
    @JsonKey(name: 'changed_at') required DateTime changedAt,
    String? reason,
    String? notes,
    @JsonKey(name: 'changed_by') String? changedBy,
  }) = _OrderStatusChange;

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) => _$OrderStatusChangeFromJson(json);
}

/// Enhanced Order Summary für Listen und Übersichten
class EnhancedOrderSummary {
  final int id;
  final String orderNumber;
  final String companyId;
  final String companyName;
  final int itemCount;
  final double totalAmount;
  final String currency;
  final EnhancedOrderStatus status;
  final DateTime createdAt;
  final String customerName;
  final String? trackingNumber;
  final String? estimatedDeliveryDate;

  const EnhancedOrderSummary({
    required this.id,
    required this.orderNumber,
    required this.companyId,
    required this.companyName,
    required this.itemCount,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.customerName,
    this.trackingNumber,
    this.estimatedDeliveryDate,
  });
}

/// Enhanced Order Filter für erweiterte Suchfunktionen
class EnhancedOrderFilter {
  final List<EnhancedOrderStatus>? statuses;
  final String? companyId;
  final String? customerId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final double? minAmount;
  final double? maxAmount;
  final String? searchTerm;
  final List<String>? tags;
  final bool? hasTracking;
  final String? shippingCarrier;

  const EnhancedOrderFilter({
    this.statuses,
    this.companyId,
    this.customerId,
    this.dateFrom,
    this.dateTo,
    this.minAmount,
    this.maxAmount,
    this.searchTerm,
    this.tags,
    this.hasTracking,
    this.shippingCarrier,
  });
}

/// Enhanced Order Statistics für Dashboard und Berichte
class EnhancedOrderStats {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final Map<EnhancedOrderStatus, int> statusCounts;
  final Map<String, int> companyOrderCounts;
  final Map<String, double> monthlyRevenue;
  final Map<String, int> monthlyOrders;

  const EnhancedOrderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.statusCounts,
    required this.companyOrderCounts,
    required this.monthlyRevenue,
    required this.monthlyOrders,
  });
}