import 'package:freezed_annotation/freezed_annotation.dart';
import 'company.dart';
import 'delivery_address.dart';
import 'hike.dart';

part 'enhanced_order.freezed.dart';
part 'enhanced_order.g.dart';

/// Enhanced Order Status für erweiterte Funktionalität
enum EnhancedOrderStatus {
  @JsonValue('pending') pending,
  @JsonValue('payment_pending') paymentPending, // Waiting for payment confirmation
  @JsonValue('confirmed') confirmed,
  @JsonValue('processing') processing,
  @JsonValue('shipped') shipped,
  @JsonValue('out_for_delivery') outForDelivery,
  @JsonValue('delivered') delivered,
  @JsonValue('cancelled') cancelled,
  @JsonValue('refunded') refunded,
  @JsonValue('failed') failed, // Payment or processing failed
}

/// Enhanced Order Model für Multi-Vendor System
/// Unterstützt komplexe Bestellungen mit Company-Kontext und detaillierter Adressverwaltung
@freezed
class EnhancedOrder with _$EnhancedOrder {
  const factory EnhancedOrder({
    required int id,
    required String orderNumber,
    
    // Multi-Vendor Context
    required String companyId,
    Company? company, // Populated via JOIN
    
    // User und Hike Information
    required String userId,
    required int hikeId,
    Hike? hike, // Populated via JOIN
    
    // Pricing Information
    required double baseAmount, // Hike Preis ohne Versand
    required double shippingCost,
    required double totalAmount, // baseAmount + shippingCost + eventuelle Steuern
    double? taxAmount, // Für zukünftige MwSt-Funktionalität
    String? currency, // ISO 4217 Currency Code (EUR, USD, etc.)
    
    // Delivery Information
    required DeliveryType deliveryType,
    DeliveryAddress? deliveryAddress, // Strukturierte Adresse
    @JsonKey(name: 'delivery_address_raw') Map<String, dynamic>? deliveryAddressRaw, // Fallback für alte Daten
    
    // Status und Tracking
    required EnhancedOrderStatus status,
    String? trackingNumber,
    String? trackingUrl,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    
    // Payment Information
    String? paymentIntentId,
    String? paymentMethodId,
    PaymentProvider? paymentProvider,
    
    // Shipping Information
    ShippingCostResult? shippingDetails,
    String? shippingService, // 'Standard', 'Express', etc.
    
    // Order Items (für zukünftige Multi-Item Bestellungen)
    @Default([]) List<OrderItem> items,
    
    // Customer Notes und Instructions
    String? customerNotes,
    String? deliveryInstructions,
    String? internalNotes, // Für Company-interne Notizen
    
    // Status History (für Tracking)
    @Default([]) List<OrderStatusChange> statusHistory,
    
    // System Fields
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // Metadata für zusätzliche Informationen
    @Default({}) Map<String, dynamic> metadata,
  }) = _EnhancedOrder;

  factory EnhancedOrder.fromJson(Map<String, dynamic> json) => 
      _$EnhancedOrderFromJson(json);
}

/// Delivery Type enum (erweitert)
enum DeliveryType {
  @JsonValue('pickup') pickup,
  @JsonValue('standard_shipping') standardShipping,
  @JsonValue('express_shipping') expressShipping,
  @JsonValue('premium_shipping') premiumShipping,
}

/// Payment Provider enum
enum PaymentProvider {
  @JsonValue('stripe') stripe,
  @JsonValue('paypal') paypal,
  @JsonValue('apple_pay') applePay,
  @JsonValue('google_pay') googlePay,
}

/// Order Item Model für Multi-Item Orders (zukünftige Erweiterung)
@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required int id,
    required int hikeId,
    Hike? hike,
    @Default(1) int quantity,
    required double unitPrice,
    required double totalPrice,
    String? notes,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) => 
      _$OrderItemFromJson(json);
}

/// Order Status Change für History Tracking
@freezed
class OrderStatusChange with _$OrderStatusChange {
  const factory OrderStatusChange({
    required EnhancedOrderStatus fromStatus,
    required EnhancedOrderStatus toStatus,
    required DateTime changedAt,
    String? reason,
    String? notes,
    String? changedBy, // User ID oder 'system'
  }) = _OrderStatusChange;

  factory OrderStatusChange.fromJson(Map<String, dynamic> json) => 
      _$OrderStatusChangeFromJson(json);
}

/// Extension für Enhanced Order Business Logic
extension EnhancedOrderExtensions on EnhancedOrder {
  /// Prüft ob die Bestellung eine Lieferadresse benötigt
  bool get requiresDeliveryAddress => 
      deliveryType != DeliveryType.pickup;
  
  /// Prüft ob die Bestellung in einem finalen Status ist
  bool get isFinalStatus => [
    EnhancedOrderStatus.delivered,
    EnhancedOrderStatus.cancelled,
    EnhancedOrderStatus.refunded,
    EnhancedOrderStatus.failed,
  ].contains(status);
  
  /// Prüft ob die Bestellung storniert werden kann
  bool get canBeCancelled => [
    EnhancedOrderStatus.pending,
    EnhancedOrderStatus.paymentPending,
    EnhancedOrderStatus.confirmed,
  ].contains(status);
  
  /// Prüft ob die Bestellung verfolgt werden kann
  bool get canBeTracked => 
      trackingNumber?.isNotEmpty == true && 
      [EnhancedOrderStatus.shipped, EnhancedOrderStatus.outForDelivery]
          .contains(status);
  
  /// Generiert eine formatierte Bestellnummer
  String get formattedOrderNumber => '#$orderNumber';
  
  /// Generiert einen Status-Display-Text auf Deutsch
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
  
  /// Generiert einen Delivery-Type-Display-Text
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
  
  /// Berechnet die Gesamtsumme aus Einzelposten (falls vorhanden)
  double get calculatedTotal {
    if (items.isEmpty) {
      return baseAmount + shippingCost + (taxAmount ?? 0.0);
    }
    
    final itemsTotal = items.fold<double>(
      0.0, 
      (sum, item) => sum + item.totalPrice,
    );
    
    return itemsTotal + shippingCost + (taxAmount ?? 0.0);
  }
  
  /// Prüft ob die berechnete Gesamtsumme mit der gespeicherten übereinstimmt
  bool get totalAmountIsConsistent {
    return (calculatedTotal - totalAmount).abs() < 0.01; // 1 Cent Toleranz
  }
  
  /// Generiert eine Preis-Aufschlüsselung
  String get priceBreakdown {
    final lines = <String>[];
    
    if (items.isEmpty) {
      lines.add('Hike: ${baseAmount.toStringAsFixed(2)} €');
    } else {
      for (final item in items) {
        final hikeName = item.hike?.name ?? 'Hike #${item.hikeId}';
        if (item.quantity > 1) {
          lines.add('$hikeName (${item.quantity}x): ${item.totalPrice.toStringAsFixed(2)} €');
        } else {
          lines.add('$hikeName: ${item.totalPrice.toStringAsFixed(2)} €');
        }
      }
    }
    
    if (shippingCost > 0) {
      lines.add('Versand: ${shippingCost.toStringAsFixed(2)} €');
    }
    
    if (taxAmount != null && taxAmount! > 0) {
      lines.add('MwSt.: ${taxAmount!.toStringAsFixed(2)} €');
    }
    
    lines.add('Gesamt: ${totalAmount.toStringAsFixed(2)} €');
    
    return lines.join('\n');
  }
  
  /// Generiert eine kompakte Lieferadresse
  String? get compactDeliveryAddress {
    if (deliveryAddress != null) {
      return deliveryAddress!.compactAddress;
    }
    
    // Fallback für alte JSON-Adressen
    if (deliveryAddressRaw != null) {
      final name = deliveryAddressRaw!['name'] ?? '';
      final street = deliveryAddressRaw!['street'] ?? '';
      final city = deliveryAddressRaw!['city'] ?? '';
      final country = deliveryAddressRaw!['country'] ?? '';
      
      return [name, street, city, country]
          .where((s) => s.isNotEmpty)
          .join(', ');
    }
    
    return null;
  }
  
  /// Prüft ob die Bestellung von einer internationalen Firma stammt
  bool get isFromInternationalVendor {
    return company?.isInternationalVendor == true;
  }
  
  /// Generiert einen Lieferstatus-Text mit geschätzter/tatsächlicher Lieferzeit
  String? get deliveryStatusText {
    if (actualDelivery != null) {
      return 'Zugestellt am ${_formatDate(actualDelivery!)}';
    }
    
    if (estimatedDelivery != null) {
      final now = DateTime.now();
      if (estimatedDelivery!.isBefore(now)) {
        return 'Lieferung überfällig (erwartet: ${_formatDate(estimatedDelivery!)})';
      } else {
        return 'Geschätzte Lieferung: ${_formatDate(estimatedDelivery!)}';
      }
    }
    
    return null;
  }
  
  /// Formatiert ein Datum für die Anzeige
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
  
  /// Generiert Tracking-Informationen
  String? get trackingInfo {
    if (!canBeTracked) return null;
    
    final info = <String>[];
    info.add('Sendungsnummer: $trackingNumber');
    
    if (trackingUrl?.isNotEmpty == true) {
      info.add('Tracking-URL: $trackingUrl');
    }
    
    return info.join('\n');
  }
  
  /// Prüft ob die Bestellung Tasting-Sets enthält (für zukünftige Erweiterung)
  bool get includesTastingSets {
    // Placeholder für zukünftige Tasting-Set-Funktionalität
    return metadata.containsKey('tasting_sets') || 
           metadata.containsKey('includes_tasting');
  }
}