import 'package:freezed_annotation/freezed_annotation.dart';

part 'company.freezed.dart';
part 'company.g.dart';

/// Company/Vendor Model für Multi-Vendor Whisky Hikes System
/// Repräsentiert Firmen, die Hikes erstellen und verkaufen
@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    String? description,
    required String contactEmail,
    String? phone,
    
    // Location Information
    required String countryCode, // ISO 3166-1 alpha-2 (e.g., 'DE', 'AU', 'GB')
    required String countryName,
    required String city,
    String? postalCode,
    String? addressLine1,
    String? addressLine2,
    
    // Business Information
    String? companyRegistrationNumber,
    String? vatNumber,
    String? websiteUrl,
    String? logoUrl,
    
    // System Fields
    @Default(true) bool isActive,
    @Default(false) bool isVerified,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
}

/// Extension für Business Logic auf Company
extension CompanyExtensions on Company {
  /// Prüft ob die Firma eine DACH-Adresse hat (Deutschland, Österreich, Schweiz)
  bool get isDachAddress => ['DE', 'AT', 'CH'].contains(countryCode);
  
  /// Generiert eine Anzeige-Adresse für die Firma
  String get displayAddress {
    final parts = <String>[];
    
    if (addressLine1?.isNotEmpty == true) parts.add(addressLine1!);
    if (addressLine2?.isNotEmpty == true) parts.add(addressLine2!);
    if (postalCode?.isNotEmpty == true && city.isNotEmpty) {
      parts.add('$postalCode $city');
    } else if (city.isNotEmpty) {
      parts.add(city);
    }
    if (countryName.isNotEmpty) parts.add(countryName);
    
    return parts.join(', ');
  }
  
  /// Prüft ob die Firma vollständig verifiziert ist
  bool get isFullyVerified => isActive && isVerified;
  
  /// Generiert einen Display-Namen mit Land
  String get displayNameWithCountry => '$name ($countryCode)';
  
  /// Prüft ob die Firma internationale Lieferungen macht
  /// (basierend darauf ob sie in einem anderen Land als Deutschland ist)
  bool get isInternationalVendor => countryCode != 'DE';
  
  /// Generiert einen sicheren Kontakt-String (Email wird teilweise maskiert)
  String get maskedContactEmail {
    if (contactEmail.isEmpty) return '';
    
    final atIndex = contactEmail.indexOf('@');
    if (atIndex == -1) return contactEmail;
    
    final username = contactEmail.substring(0, atIndex);
    final domain = contactEmail.substring(atIndex);
    
    if (username.length <= 3) return contactEmail;
    
    final masked = username.substring(0, 2) + 
                   '*' * (username.length - 3) +
                   username.substring(username.length - 1);
    
    return masked + domain;
  }
}

/// Shipping Rule Model für Company-spezifische Versandregeln
@freezed
abstract class CompanyShippingRule with _$CompanyShippingRule {
  const factory CompanyShippingRule({
    required int id,
    required String companyId,
    required String fromCountryCode,
    required String toCountryCode,
    String? toRegion, // 'EU', 'DACH', 'WORLDWIDE', etc.
    required double shippingCost,
    double? freeShippingThreshold,
    int? estimatedDeliveryDaysMin,
    int? estimatedDeliveryDaysMax,
    @Default('Standard') String serviceName,
    @Default(true) bool trackingAvailable,
    @Default(false) bool signatureRequired,
    @Default(true) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _CompanyShippingRule;

  factory CompanyShippingRule.fromJson(Map<String, dynamic> json) => 
      _$CompanyShippingRuleFromJson(json);
}

/// Extension für Shipping Rule Business Logic
extension CompanyShippingRuleExtensions on CompanyShippingRule {
  /// Prüft ob kostenloser Versand für einen Bestellwert verfügbar ist
  bool isFreeShippingAvailable(double orderValue) {
    return freeShippingThreshold != null && 
           orderValue >= freeShippingThreshold!;
  }
  
  /// Berechnet die tatsächlichen Versandkosten für einen Bestellwert
  double calculateActualShippingCost(double orderValue) {
    if (isFreeShippingAvailable(orderValue)) {
      return 0.0;
    }
    return shippingCost;
  }
  
  /// Generiert einen Lieferzeit-String
  String get estimatedDeliveryString {
    if (estimatedDeliveryDaysMin == null || estimatedDeliveryDaysMax == null) {
      return 'Lieferzeit auf Anfrage';
    }
    
    if (estimatedDeliveryDaysMin == estimatedDeliveryDaysMax) {
      return '$estimatedDeliveryDaysMin Werktage';
    }
    
    return '$estimatedDeliveryDaysMin-$estimatedDeliveryDaysMax Werktage';
  }
  
  /// Generiert eine Versand-Beschreibung mit allen wichtigen Infos
  String get shippingDescription {
    final parts = <String>[];
    
    parts.add('${shippingCost.toStringAsFixed(2)} €');
    
    if (freeShippingThreshold != null) {
      parts.add('(kostenlos ab ${freeShippingThreshold!.toStringAsFixed(2)} €)');
    }
    
    parts.add(estimatedDeliveryString);
    
    if (trackingAvailable) {
      parts.add('mit Sendungsverfolgung');
    }
    
    return parts.join(' • ');
  }
}