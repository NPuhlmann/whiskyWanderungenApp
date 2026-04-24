import 'package:freezed_annotation/freezed_annotation.dart';
import 'company.dart';

part 'hike.freezed.dart';
part 'hike.g.dart';

enum Difficulty { easy, mid, hard, veryHard }

@freezed
abstract class Hike with _$Hike {
  const factory Hike({
    // die id des hikes
    required int id,
    @Default('') String name,
    @Default(1.0) double length,
    @Default(0.2) double steep,
    @Default(100) int elevation,
    @Default('') String description,
    @Default(1.0) double price,
    @Default(Difficulty.mid) Difficulty difficulty,
    @JsonKey(name: 'thumbnail_image_url') String? thumbnailImageUrl,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,

    // Multi-Vendor System Erweiterungen
    @JsonKey(name: 'company_id') String? companyId,
    Company? company, // Populated via JOIN oder separater API call
    // Zusätzliche Felder für erweiterte Funktionalität
    @Default(true) bool isAvailable,
    DateTime? availableFrom,
    DateTime? availableUntil,

    // Kategorisierung
    @Default('Whisky') String category,
    @Default([]) List<String> tags, // z.B. ['Highland', 'Scotch', 'Premium']
    // Rating System (für zukünftige Review-Funktionalität)
    @Default(0.0) double averageRating,
    @Default(0) int reviewCount,

    // System Fields
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Hike;

  factory Hike.fromJson(Map<String, dynamic> json) => _$HikeFromJson(json);
}

/// Extension für Hike Business Logic
extension HikeExtensions on Hike {
  /// Prüft ob der Hike aktuell verfügbar ist
  bool get isCurrentlyAvailable {
    if (!isAvailable) return false;

    final now = DateTime.now();

    if (availableFrom != null && now.isBefore(availableFrom!)) {
      return false;
    }

    if (availableUntil != null && now.isAfter(availableUntil!)) {
      return false;
    }

    return true;
  }

  /// Generiert einen Display-String für die Schwierigkeit
  String get difficultyDisplayName {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Leicht';
      case Difficulty.mid:
        return 'Mittel';
      case Difficulty.hard:
        return 'Schwer';
      case Difficulty.veryHard:
        return 'Sehr schwer';
    }
  }

  /// Generiert einen Display-String für die Länge
  String get lengthDisplayText => '${length.toStringAsFixed(1)} km';

  /// Generiert einen Display-String für die Steigung
  String get steepDisplayText =>
      '${(steep * 100).toStringAsFixed(0)}% Steigung';

  /// Generiert einen Display-String für die Höhenmeter
  String get elevationDisplayText => '${elevation}m Höhenmeter';

  /// Prüft ob der Hike einen Company-Kontext hat
  bool get hasCompany => companyId?.isNotEmpty == true;

  /// Generiert einen Display-Namen mit Company-Info
  String get displayNameWithCompany {
    if (company != null) {
      return '$name (${company!.displayNameWithCountry})';
    } else if (companyId?.isNotEmpty == true) {
      return '$name (Company: $companyId)';
    }
    return name;
  }

  /// Prüft ob der Hike von einer internationalen Firma angeboten wird
  bool get isInternationalOffer {
    return company?.isInternationalVendor == true;
  }

  /// Berechnet den erwarteten Preis inkl. potentieller Versandkosten
  /// (Basis-Schätzung, echte Berechnung erfolgt über ShippingService)
  double estimatedTotalPrice(String? userCountryCode) {
    double totalPrice = price;

    // Grobe Schätzung der Versandkosten basierend auf Company-Land
    if (company != null && userCountryCode != null) {
      if (company!.countryCode != userCountryCode) {
        // Internationale Lieferung - grobe Schätzung
        if (company!.isDachAddress &&
            ['DE', 'AT', 'CH'].contains(userCountryCode)) {
          totalPrice += 8.0; // DACH-Region
        } else if (company!.countryCode == 'DE' && userCountryCode != 'DE') {
          totalPrice += 12.0; // EU-Schätzung
        } else {
          totalPrice += 20.0; // International
        }
      }
    }

    return totalPrice;
  }

  /// Generiert Tags als String für Anzeige
  String get tagsDisplayText {
    if (tags.isEmpty) return '';
    return tags.join(', ');
  }

  /// Generiert Rating-Display-Text
  String get ratingDisplayText {
    if (reviewCount == 0) return 'Noch keine Bewertungen';
    return '${averageRating.toStringAsFixed(1)} ⭐ ($reviewCount Bewertungen)';
  }

  /// Prüft ob es sich um einen Premium-Hike handelt (über einem bestimmten Preis)
  bool get isPremium => price >= 50.0;

  /// Generiert Verfügbarkeits-Status-Text
  String? get availabilityStatusText {
    if (!isAvailable) return 'Nicht verfügbar';

    final now = DateTime.now();

    if (availableFrom != null && now.isBefore(availableFrom!)) {
      return 'Verfügbar ab ${availableFrom!.day}.${availableFrom!.month}.${availableFrom!.year}';
    }

    if (availableUntil != null && now.isAfter(availableUntil!)) {
      return 'Nicht mehr verfügbar';
    }

    if (availableUntil != null) {
      return 'Verfügbar bis ${availableUntil!.day}.${availableUntil!.month}.${availableUntil!.year}';
    }

    return null; // Immer verfügbar
  }
}
