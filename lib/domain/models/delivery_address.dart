// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'delivery_address.freezed.dart';
// part 'delivery_address.g.dart';

/// Delivery Address Model für strukturierte Adressverwaltung
/// Unterstützt sowohl private als auch Geschäftsadressen
class DeliveryAddress {
  final String? id; // Optional für gespeicherte Adressen
  final String firstName;
  final String lastName;
  final String? company; // Optional für Firmenadressen
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String postalCode;
  final String countryCode; // ISO 3166-1 alpha-2
  final String countryName;
  final String? state; // Für USA, Australien, etc.
  final String? phone;
  final String? email; // Zusatzinformationen
  final String? deliveryInstructions;
  final bool isBusinessAddress;
  final bool isDefaultAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeliveryAddress({
    this.id,
    required this.firstName,
    required this.lastName,
    this.company,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.countryName,
    this.state,
    this.phone,
    this.email,
    this.deliveryInstructions,
    this.isBusinessAddress = false,
    this.isDefaultAddress = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      company: json['company'] as String?,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      countryCode: json['country_code'] as String,
      countryName: json['country_name'] as String,
      state: json['state'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      deliveryInstructions: json['delivery_instructions'] as String?,
      isBusinessAddress: json['is_business_address'] as bool? ?? false,
      isDefaultAddress: json['is_default_address'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'company': company,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'postal_code': postalCode,
      'country_code': countryCode,
      'country_name': countryName,
      'state': state,
      'phone': phone,
      'email': email,
      'delivery_instructions': deliveryInstructions,
      'is_business_address': isBusinessAddress,
      'is_default_address': isDefaultAddress,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get full name (firstName + lastName)
  String get fullName => '$firstName $lastName'.trim();

  /// Get compact address for display
  String get compactAddress {
    final parts = <String>[];

    parts.add(fullName);
    parts.add(addressLine1);

    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      parts.add(addressLine2!);
    }

    parts.add('$postalCode $city');

    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }

    parts.add(countryName);

    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  /// Validate the address for completeness and correctness
  AddressValidationResult validate() {
    final errors = <String>[];
    final suggestions = <String>[];

    // Required field validation
    if (firstName.trim().isEmpty) {
      errors.add('First name is required');
    }
    if (lastName.trim().isEmpty) {
      errors.add('Last name is required');
    }
    if (addressLine1.trim().isEmpty) {
      errors.add('Address line 1 is required');
    }
    if (city.trim().isEmpty) {
      errors.add('City is required');
    }
    if (postalCode.trim().isEmpty) {
      errors.add('Postal code is required');
    }
    if (countryCode.trim().isEmpty) {
      errors.add('Country code is required');
    }
    if (countryName.trim().isEmpty) {
      errors.add('Country name is required');
    }

    // Country-specific validation
    if (countryCode.length != 2) {
      errors.add('Country code must be 2 characters (ISO 3166-1 alpha-2)');
    }

    // Postal code format validation (basic)
    if (postalCode.isNotEmpty) {
      switch (countryCode.toUpperCase()) {
        case 'DE':
          if (!RegExp(r'^\d{5}$').hasMatch(postalCode)) {
            errors.add('German postal codes must be 5 digits');
          }
          break;
        case 'US':
          if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(postalCode)) {
            errors.add('US postal codes must be 5 digits or ZIP+4 format');
          }
          break;
        case 'UK':
        case 'GB':
          if (!RegExp(
            r'^[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}$',
            caseSensitive: false,
          ).hasMatch(postalCode)) {
            errors.add('UK postal codes must follow the correct format');
          }
          break;
      }
    }

    // Business address validation
    if (isBusinessAddress && (company?.trim().isEmpty ?? true)) {
      suggestions.add('Business addresses should include a company name');
    }

    // Phone number basic validation
    if (phone != null && phone!.isNotEmpty) {
      if (!RegExp(r'^[\+]?[\d\s\-\(\)]{7,15}$').hasMatch(phone!)) {
        errors.add('Phone number format appears invalid');
      }
    }

    // Email basic validation
    if (email != null && email!.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
        errors.add('Email format appears invalid');
      }
    }

    return AddressValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      suggestions: suggestions,
    );
  }
}

/// Address Type für verschiedene Adressarten
enum AddressType { residential, business, shipping, billing, pickup }

/// Address Validation Result für Adressvalidierung
class AddressValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> suggestions;
  final Map<String, dynamic>? validationData;

  const AddressValidationResult({
    required this.isValid,
    required this.errors,
    this.suggestions = const [],
    this.validationData,
  });
}

/// Address Format für verschiedene Länder
class AddressFormat {
  final String countryCode;
  final String countryName;
  final List<String> requiredFields;
  final List<String> optionalFields;
  final String displayFormat;
  final String? postalCodeFormat;
  final String? phoneFormat;
  final Map<String, dynamic>? countrySpecificRules;

  const AddressFormat({
    required this.countryCode,
    required this.countryName,
    required this.requiredFields,
    required this.optionalFields,
    required this.displayFormat,
    this.postalCodeFormat,
    this.phoneFormat,
    this.countrySpecificRules,
  });
}

/// Shipping Cost Calculation Result
class ShippingCostResult {
  final double cost;
  final bool isFreeShipping;
  final String serviceName;
  final int? estimatedDaysMin;
  final int? estimatedDaysMax;
  final String? region;
  final String? description;
  final bool trackingAvailable;
  final bool signatureRequired;

  const ShippingCostResult({
    required this.cost,
    required this.isFreeShipping,
    required this.serviceName,
    this.estimatedDaysMin,
    this.estimatedDaysMax,
    this.region,
    this.description,
    this.trackingAvailable = true,
    this.signatureRequired = false,
  });

  factory ShippingCostResult.fromJson(Map<String, dynamic> json) {
    return ShippingCostResult(
      cost: (json['cost'] as num).toDouble(),
      isFreeShipping: json['is_free_shipping'] as bool,
      serviceName: json['service_name'] as String,
      estimatedDaysMin: json['estimated_days_min'] as int?,
      estimatedDaysMax: json['estimated_days_max'] as int?,
      region: json['region'] as String?,
      description: json['description'] as String?,
      trackingAvailable: json['tracking_available'] as bool? ?? true,
      signatureRequired: json['signature_required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cost': cost,
      'is_free_shipping': isFreeShipping,
      'service_name': serviceName,
      'estimated_days_min': estimatedDaysMin,
      'estimated_days_max': estimatedDaysMax,
      'region': region,
      'description': description,
      'tracking_available': trackingAvailable,
      'signature_required': signatureRequired,
    };
  }
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
