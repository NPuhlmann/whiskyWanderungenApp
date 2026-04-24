import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

import '../../../domain/models/delivery_address.dart';
import '../database/backend_api.dart';

/// Service für die Berechnung von Versandkosten
/// Kommuniziert mit der calculate-shipping Edge Function
class ShippingCalculationService {
  final BackendApiService _backendApi;

  // Cache für Versandkosten-Berechnungen (5 Minuten TTL)
  final Map<String, _CachedShippingResult> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 5);

  ShippingCalculationService(this._backendApi);

  /// Berechnet Versandkosten für eine spezifische Company und Lieferadresse
  Future<ShippingCostResult> calculateShippingCost({
    required String companyId,
    required DeliveryAddress deliveryAddress,
    required double orderValue,
    int? hikeId,
  }) async {
    try {
      // Cache-Key generieren
      final cacheKey = _generateCacheKey(
        companyId,
        deliveryAddress,
        orderValue,
      );

      // Prüfe Cache
      if (_cache.containsKey(cacheKey)) {
        final cached = _cache[cacheKey]!;
        if (cached.isValid) {
          dev.log('📦 Using cached shipping calculation');
          return cached.result;
        } else {
          _cache.remove(cacheKey);
        }
      }

      dev.log(
        '🚚 Calculating shipping cost for company $companyId to ${deliveryAddress.countryCode}',
      );

      // Edge Function aufrufen
      final result = await _callCalculateShippingFunction(
        companyId: companyId,
        deliveryAddress: deliveryAddress,
        orderValue: orderValue,
        hikeId: hikeId,
      );

      // Ergebnis cachen
      _cache[cacheKey] = _CachedShippingResult(
        result: result,
        cachedAt: DateTime.now(),
      );

      return result;
    } catch (e) {
      dev.log('❌ Error calculating shipping cost: $e');

      // Fallback-Berechnung
      return _calculateFallbackShipping(deliveryAddress, orderValue);
    }
  }

  /// Berechnet Versandkosten für mehrere Companies gleichzeitig
  /// Nützlich für Vergleiche oder Multi-Vendor-Carts
  Future<Map<String, ShippingCostResult>>
  calculateShippingForMultipleCompanies({
    required List<String> companyIds,
    required DeliveryAddress deliveryAddress,
    required double orderValue,
  }) async {
    final results = <String, ShippingCostResult>{};

    // Parallel requests für bessere Performance
    final futures = companyIds.map(
      (companyId) => calculateShippingCost(
        companyId: companyId,
        deliveryAddress: deliveryAddress,
        orderValue: orderValue,
      ).then((result) => MapEntry(companyId, result)),
    );

    try {
      final completedResults = await Future.wait(futures);
      for (final entry in completedResults) {
        results[entry.key] = entry.value;
      }
    } catch (e) {
      dev.log('❌ Error in batch shipping calculation: $e');
    }

    return results;
  }

  /// Validiert eine Lieferadresse für Versandkostenberechnung
  AddressValidationResult validateDeliveryAddress(DeliveryAddress address) {
    return address.validate();
  }

  /// Schätzt Versandkosten basierend auf Ländern (ohne spezifische Company-Regeln)
  ShippingCostResult estimateShippingCost({
    required String fromCountryCode,
    required String toCountryCode,
    required double orderValue,
  }) {
    // Einfache Schätzlogik basierend auf Regionen
    double estimatedCost = 25.0; // International default
    int estimatedDaysMin = 7;
    int estimatedDaysMax = 14;
    String region = 'INTERNATIONAL';

    if (fromCountryCode == toCountryCode) {
      estimatedCost = 5.0;
      estimatedDaysMin = 1;
      estimatedDaysMax = 3;
      region = 'DOMESTIC';
    } else if (_isDachRegion(fromCountryCode) && _isDachRegion(toCountryCode)) {
      estimatedCost = 8.0;
      estimatedDaysMin = 2;
      estimatedDaysMax = 5;
      region = 'DACH';
    } else if (_isEuRegion(fromCountryCode) && _isEuRegion(toCountryCode)) {
      estimatedCost = 12.0;
      estimatedDaysMin = 4;
      estimatedDaysMax = 8;
      region = 'EU';
    }

    return ShippingCostResult(
      cost: estimatedCost,
      isFreeShipping: false,
      serviceName: 'Standard (geschätzt)',
      estimatedDaysMin: estimatedDaysMin,
      estimatedDaysMax: estimatedDaysMax,
      region: region,
      description:
          'Geschätzte Versandkosten • ${estimatedCost.toStringAsFixed(2)} € • $estimatedDaysMin-$estimatedDaysMax Werktage',
      trackingAvailable: true,
      signatureRequired: false,
    );
  }

  /// Ruft die calculate-shipping Edge Function auf
  Future<ShippingCostResult> _callCalculateShippingFunction({
    required String companyId,
    required DeliveryAddress deliveryAddress,
    required double orderValue,
    int? hikeId,
  }) async {
    final supabaseUrl = _backendApi.supabaseUrl;
    final edgeFunctionUrl = '$supabaseUrl/functions/v1/calculate-shipping';

    final requestData = {
      'companyId': companyId,
      'deliveryAddress': {
        'firstName': deliveryAddress.firstName,
        'lastName': deliveryAddress.lastName,
        'addressLine1': deliveryAddress.addressLine1,
        'addressLine2': deliveryAddress.addressLine2,
        'city': deliveryAddress.city,
        'postalCode': deliveryAddress.postalCode,
        'countryCode': deliveryAddress.countryCode,
        'countryName': deliveryAddress.countryName,
        'state': deliveryAddress.state,
      },
      'orderValue': orderValue,
      'hikeId': ?hikeId,
    };

    final response = await http.post(
      Uri.parse(edgeFunctionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_backendApi.supabaseAnonKey}',
      },
      body: json.encode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Edge function returned status ${response.statusCode}: ${response.body}',
      );
    }

    final responseData = json.decode(response.body);

    if (responseData['success'] != true) {
      throw Exception('Edge function error: ${responseData['error']}');
    }

    final result = responseData['result'];

    return ShippingCostResult(
      cost: (result['cost'] as num).toDouble(),
      isFreeShipping: result['isFreeShipping'] as bool,
      serviceName: result['serviceName'] as String,
      estimatedDaysMin: result['estimatedDaysMin'] as int?,
      estimatedDaysMax: result['estimatedDaysMax'] as int?,
      region: result['region'] as String?,
      description: result['description'] as String,
      trackingAvailable: result['trackingAvailable'] as bool? ?? true,
      signatureRequired: result['signatureRequired'] as bool? ?? false,
    );
  }

  /// Fallback-Berechnung wenn Edge Function nicht verfügbar ist
  ShippingCostResult _calculateFallbackShipping(
    DeliveryAddress deliveryAddress,
    double orderValue,
  ) {
    dev.log('🔄 Using fallback shipping calculation');

    // Einfache Fallback-Logik
    double cost = 15.0; // Moderate internationale Schätzung
    int daysMin = 5;
    int daysMax = 10;

    // Deutschland als Basis-Versender angenommen
    if (deliveryAddress.countryCode == 'DE') {
      cost = 4.90;
      daysMin = 1;
      daysMax = 3;
    } else if (_isDachRegion(deliveryAddress.countryCode)) {
      cost = 8.90;
      daysMin = 2;
      daysMax = 5;
    } else if (_isEuRegion(deliveryAddress.countryCode)) {
      cost = 12.90;
      daysMin = 4;
      daysMax = 8;
    }

    return ShippingCostResult(
      cost: cost,
      isFreeShipping: false,
      serviceName: 'Standard (Fallback)',
      estimatedDaysMin: daysMin,
      estimatedDaysMax: daysMax,
      description:
          'Geschätzte Versandkosten (Fallback) • ${cost.toStringAsFixed(2)} € • $daysMin-$daysMax Werktage',
      trackingAvailable: true,
      signatureRequired: false,
    );
  }

  /// Generiert einen Cache-Key für die Versandkostenberechnung
  String _generateCacheKey(
    String companyId,
    DeliveryAddress deliveryAddress,
    double orderValue,
  ) {
    return '$companyId|${deliveryAddress.countryCode}|${deliveryAddress.postalCode}|${orderValue.toStringAsFixed(2)}';
  }

  /// Prüft ob ein Land zur DACH-Region gehört
  bool _isDachRegion(String countryCode) {
    return ['DE', 'AT', 'CH'].contains(countryCode);
  }

  /// Prüft ob ein Land zur EU gehört
  bool _isEuRegion(String countryCode) {
    const euCountries = {
      'AT',
      'BE',
      'BG',
      'HR',
      'CY',
      'CZ',
      'DK',
      'EE',
      'FI',
      'FR',
      'DE',
      'GR',
      'HU',
      'IE',
      'IT',
      'LV',
      'LT',
      'LU',
      'MT',
      'NL',
      'PL',
      'PT',
      'RO',
      'SK',
      'SI',
      'ES',
      'SE',
    };
    return euCountries.contains(countryCode);
  }

  /// Leert den Versandkosten-Cache
  void clearCache() {
    _cache.clear();
    dev.log('🧹 Shipping calculation cache cleared');
  }

  /// Gibt Cache-Statistiken zurück
  Map<String, dynamic> getCacheStats() {
    final validEntries = _cache.values.where((entry) => entry.isValid).length;
    return {
      'total_entries': _cache.length,
      'valid_entries': validEntries,
      'expired_entries': _cache.length - validEntries,
      'cache_ttl_minutes': _cacheTtl.inMinutes,
    };
  }
}

/// Gecachtes Versandkosten-Ergebnis mit TTL
class _CachedShippingResult {
  final ShippingCostResult result;
  final DateTime cachedAt;

  _CachedShippingResult({required this.result, required this.cachedAt});

  bool get isValid {
    return DateTime.now().difference(cachedAt) <
        ShippingCalculationService._cacheTtl;
  }
}

/// Extension für DeliveryAddress zur Vereinfachung von Shipping-Operationen
extension DeliveryAddressShippingExtensions on DeliveryAddress {
  /// Prüft ob die Adresse für Versandkostenberechnung gültig ist
  bool get isValidForShipping {
    final validation = validate();
    return validation.isValid;
  }

  /// Generiert einen Shipping-Hash für Cache-Zwecke
  String get shippingHash {
    return '$countryCode-${postalCode.replaceAll(' ', '')}-${city.toLowerCase()}';
  }
}

/// Service-Factory für Dependency Injection
class ShippingCalculationServiceFactory {
  static ShippingCalculationService create(BackendApiService backendApi) {
    return ShippingCalculationService(backendApi);
  }
}
