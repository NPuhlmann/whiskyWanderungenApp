import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_address.freezed.dart';
part 'delivery_address.g.dart';

/// Delivery Address Model für Checkout und Versandkostenberechnung
/// Unterstützt internationale Adressen mit Validierung
@freezed
class DeliveryAddress with _$DeliveryAddress {
  const factory DeliveryAddress({
    String? id, // Optional für gespeicherte Adressen
    
    // Persönliche Daten
    required String firstName,
    required String lastName,
    String? company, // Optional für Firmenadressen
    
    // Adressdaten
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String postalCode,
    required String countryCode, // ISO 3166-1 alpha-2
    required String countryName,
    String? state, // Für USA, Australien, etc.
    
    // Kontaktdaten
    String? phone,
    String? email,
    
    // Zusatzinformationen
    String? deliveryInstructions,
    @Default(false) bool isBusinessAddress,
    @Default(false) bool isDefault, // Standardadresse des Users
    
    // System Fields
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DeliveryAddress;

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => 
      _$DeliveryAddressFromJson(json);
}

/// Extension für Address Business Logic und Validierung
extension DeliveryAddressExtensions on DeliveryAddress {
  /// Generiert einen vollständigen Anzeige-Namen
  String get fullName => '$firstName $lastName';
  
  /// Generiert eine formatierte Adresse für Anzeige
  String get formattedAddress {
    final lines = <String>[];
    
    // Name
    if (company?.isNotEmpty == true) {
      lines.add(company!);
      lines.add(fullName);
    } else {
      lines.add(fullName);
    }
    
    // Adresse
    lines.add(addressLine1);
    if (addressLine2?.isNotEmpty == true) {
      lines.add(addressLine2!);
    }
    
    // Stadt, PLZ, Staat (falls vorhanden)
    String cityLine = postalCode.isNotEmpty ? '$postalCode $city' : city;
    if (state?.isNotEmpty == true) {
      cityLine += ', $state';
    }
    lines.add(cityLine);
    
    // Land
    lines.add(countryName);
    
    return lines.join('\n');
  }
  
  /// Generiert eine kompakte einzeilige Adresse
  String get compactAddress {
    final parts = <String>[];
    
    parts.add(fullName);
    parts.add(addressLine1);
    if (postalCode.isNotEmpty) {
      parts.add('$postalCode $city');
    } else {
      parts.add(city);
    }
    parts.add(countryCode);
    
    return parts.join(', ');
  }
  
  /// Validiert die Adresse auf Vollständigkeit
  AddressValidationResult validate() {
    final errors = <String>[];
    
    // Pflichtfelder prüfen
    if (firstName.trim().isEmpty) {
      errors.add('Vorname ist erforderlich');
    }
    
    if (lastName.trim().isEmpty) {
      errors.add('Nachname ist erforderlich');
    }
    
    if (addressLine1.trim().isEmpty) {
      errors.add('Straße und Hausnummer sind erforderlich');
    }
    
    if (city.trim().isEmpty) {
      errors.add('Stadt ist erforderlich');
    }
    
    if (postalCode.trim().isEmpty) {
      errors.add('Postleitzahl ist erforderlich');
    }
    
    if (countryCode.trim().isEmpty) {
      errors.add('Land ist erforderlich');
    }
    
    // Format-Validierungen
    if (countryCode.length != 2 || !countryCode.contains(RegExp(r'^[A-Z]{2}$'))) {
      errors.add('Ungültiger Ländercode');
    }
    
    // Länderspezifische Validierungen
    if (countryCode == 'US' || countryCode == 'CA') {
      if (state?.trim().isEmpty == true) {
        errors.add('Staat/Provinz ist für ${countryName} erforderlich');
      }
    }
    
    // PLZ-Format-Validierung (beispielhaft)
    if (!_isValidPostalCode(postalCode, countryCode)) {
      errors.add('Ungültiges Postleitzahl-Format für $countryName');
    }
    
    // Email-Validierung (falls angegeben)
    if (email?.isNotEmpty == true && !_isValidEmail(email!)) {
      errors.add('Ungültige E-Mail-Adresse');
    }
    
    return AddressValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Prüft ob es sich um eine EU-Adresse handelt
  bool get isEuAddress {
    const euCountries = {
      'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR',
      'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
      'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE'
    };
    return euCountries.contains(countryCode);
  }
  
  /// Prüft ob es sich um eine DACH-Region handelt
  bool get isDachAddress => ['DE', 'AT', 'CH'].contains(countryCode);
  
  /// Bestimmt die Versandregion für Kostenberechnung
  String get shippingRegion {
    if (countryCode == 'DE') return 'DOMESTIC_DE';
    if (isDachAddress) return 'DACH';
    if (isEuAddress) return 'EU';
    if (['GB', 'NO', 'IS'].contains(countryCode)) return 'EUROPE';
    if (['US', 'CA'].contains(countryCode)) return 'NORTH_AMERICA';
    if (['AU', 'NZ'].contains(countryCode)) return 'OCEANIA';
    if (['JP', 'KR', 'SG', 'HK'].contains(countryCode)) return 'ASIA';
    return 'INTERNATIONAL';
  }
  
  /// Validiert PLZ-Format für verschiedene Länder
  bool _isValidPostalCode(String postalCode, String countryCode) {
    final code = postalCode.trim().replaceAll(' ', '');
    
    switch (countryCode) {
      case 'DE':
        return RegExp(r'^\d{5}$').hasMatch(code);
      case 'AT':
        return RegExp(r'^\d{4}$').hasMatch(code);
      case 'CH':
        return RegExp(r'^\d{4}$').hasMatch(code);
      case 'US':
        return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(code);
      case 'GB':
        return RegExp(r'^[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2}$', caseSensitive: false).hasMatch(code);
      case 'FR':
        return RegExp(r'^\d{5}$').hasMatch(code);
      case 'AU':
        return RegExp(r'^\d{4}$').hasMatch(code);
      default:
        return code.isNotEmpty; // Basic validation for other countries
    }
  }
  
  /// Validiert E-Mail-Format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}

/// Validation Result für Address Validation
@freezed
class AddressValidationResult with _$AddressValidationResult {
  const factory AddressValidationResult({
    required bool isValid,
    @Default([]) List<String> errors,
  }) = _AddressValidationResult;
  
  factory AddressValidationResult.fromJson(Map<String, dynamic> json) => 
      _$AddressValidationResultFromJson(json);
}

/// Shipping Cost Calculation Result
@freezed
class ShippingCostResult with _$ShippingCostResult {
  const factory ShippingCostResult({
    required double cost,
    required bool isFreeShipping,
    required String serviceName,
    int? estimatedDaysMin,
    int? estimatedDaysMax,
    String? region,
    String? description,
    @Default(true) bool trackingAvailable,
    @Default(false) bool signatureRequired,
  }) = _ShippingCostResult;
  
  factory ShippingCostResult.fromJson(Map<String, dynamic> json) => 
      _$ShippingCostResultFromJson(json);
}

/// Extension für ShippingCostResult
extension ShippingCostResultExtensions on ShippingCostResult {
  /// Generiert einen Anzeige-String für die Versandkosten
  String get displayText {
    if (isFreeShipping) {
      return 'Kostenloser Versand';
    }
    return '${cost.toStringAsFixed(2)} € Versandkosten';
  }
  
  /// Generiert einen vollständigen Beschreibungstext
  String get fullDescription {
    final parts = <String>[displayText];
    
    if (estimatedDaysMin != null && estimatedDaysMax != null) {
      if (estimatedDaysMin == estimatedDaysMax) {
        parts.add('Lieferzeit: $estimatedDaysMin Werktage');
      } else {
        parts.add('Lieferzeit: $estimatedDaysMin-$estimatedDaysMax Werktage');
      }
    }
    
    if (trackingAvailable) {
      parts.add('mit Sendungsverfolgung');
    }
    
    return parts.join(' • ');
  }
}