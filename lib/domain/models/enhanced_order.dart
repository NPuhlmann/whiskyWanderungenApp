import 'package:freezed_annotation/freezed_annotation.dart';
import 'company.dart';
import 'delivery_address.dart';
import 'hike.dart';
import 'delivery_address.dart' show ShippingCostResult;

// part 'enhanced_order.freezed.dart';
// part 'enhanced_order.g.dart';

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
class EnhancedOrder {
  final int id;
  final String orderNumber;
  
  // Multi-Vendor Context
  final String companyId;
  final Company? company; // Populated when loading with company details
  
  // Order Details
  final List<Hike> items;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double totalAmount;
  final String currency;
  final double baseAmount; // Base amount without shipping
  
  // Status & Timestamps
  final EnhancedOrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  
  // Customer Information
  final String customerId;
  final String? customerEmail;
  final String? customerPhone;
  
  // Delivery & Shipping
  final DeliveryType deliveryType;
  final DeliveryAddress deliveryAddress;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? shippingCarrier;
  final String? shippingMethod;
  final String? shippingService;
  final String? estimatedDeliveryDate;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final ShippingCostResult? shippingDetails;
  
  // Payment Information
  final String? paymentIntentId;
  final String? paymentMethodId;
  final String? paymentStatus;
  final DateTime? paymentDate;
  
  // Additional Details
  final String? notes;
  final String? internalNotes;
  final Map<String, dynamic>? metadata;
  final List<String>? tags;
  final List<OrderStatusChange> statusHistory;
  
  // Vendor Specific
  final String? vendorOrderId;
  final String? vendorNotes;
  final Map<String, dynamic>? vendorMetadata;

  const EnhancedOrder({
    required this.id,
    required this.orderNumber,
    required this.companyId,
    this.company,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingCost,
    required this.totalAmount,
    required this.currency,
    required this.baseAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.customerId,
    this.customerEmail,
    this.customerPhone,
    required this.deliveryType,
    required this.deliveryAddress,
    this.trackingNumber,
    this.trackingUrl,
    this.shippingCarrier,
    this.shippingMethod,
    this.shippingService,
    this.estimatedDeliveryDate,
    this.estimatedDelivery,
    this.actualDelivery,
    this.shippingDetails,
    this.paymentIntentId,
    this.paymentMethodId,
    this.paymentStatus,
    this.paymentDate,
    this.notes,
    this.internalNotes,
    this.metadata,
    this.tags,
    this.statusHistory = const [],
    this.vendorOrderId,
    this.vendorNotes,
    this.vendorMetadata,
  });

  factory EnhancedOrder.fromJson(Map<String, dynamic> json) {
    // Simple JSON parsing for now
    return EnhancedOrder(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      companyId: json['company_id'] as String,
      items: [], // TODO: Parse items
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String,
      baseAmount: (json['base_amount'] as num?)?.toDouble() ?? 0.0,
      status: EnhancedOrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EnhancedOrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      customerId: json['customer_id'] as String,
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == json['delivery_type'],
        orElse: () => DeliveryType.standardShipping,
      ),
      deliveryAddress: DeliveryAddress(
        firstName: 'John',
        lastName: 'Doe',
        addressLine1: 'Sample Address',
        city: 'Sample City',
        postalCode: '12345',
        countryCode: 'DE',
        countryName: 'Germany',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'company_id': companyId,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'shipping_cost': shippingCost,
      'total_amount': totalAmount,
      'currency': currency,
      'base_amount': baseAmount,
      'status': status.name,
      'delivery_type': deliveryType.name,
      'created_at': createdAt.toIso8601String(),
      'customer_id': customerId,
    };
  }

  // Computed properties
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
class OrderStatusChange {
  final EnhancedOrderStatus fromStatus;
  final EnhancedOrderStatus toStatus;
  final DateTime changedAt;
  final String? reason;
  final String? notes;
  final String? changedBy;

  const OrderStatusChange({
    required this.fromStatus,
    required this.toStatus,
    required this.changedAt,
    this.reason,
    this.notes,
    this.changedBy,
  });

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) {
    return OrderStatusChange(
      fromStatus: EnhancedOrderStatus.values.firstWhere(
        (e) => e.name == json['from_status'],
        orElse: () => EnhancedOrderStatus.pending,
      ),
      toStatus: EnhancedOrderStatus.values.firstWhere(
        (e) => e.name == json['to_status'],
        orElse: () => EnhancedOrderStatus.pending,
      ),
      changedAt: DateTime.parse(json['changed_at'] as String),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      changedBy: json['changed_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_status': fromStatus.name,
      'to_status': toStatus.name,
      'changed_at': changedAt.toIso8601String(),
      'reason': reason,
      'notes': notes,
      'changed_by': changedBy,
    };
  }
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