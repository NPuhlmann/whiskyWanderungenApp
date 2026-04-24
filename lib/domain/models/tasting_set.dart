import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasting_set.freezed.dart';
part 'tasting_set.g.dart';

/// Represents a single whisky sample within a tasting set
@freezed
abstract class WhiskySample with _$WhiskySample {
  const factory WhiskySample({
    required int id,
    required String name,
    required String distillery,
    required int age,
    required String region,
    @JsonKey(name: 'tasting_notes') required String tastingNotes,
    @JsonKey(name: 'image_url') required String imageUrl,
    required double abv, // Alcohol by volume
    String? category, // Single Malt, Blend, etc.
    @JsonKey(name: 'sample_size_ml') @Default(5.0) double sampleSizeMl,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
  }) = _WhiskySample;

  factory WhiskySample.fromJson(Map<String, dynamic> json) =>
      _$WhiskySampleFromJson(json);
}

/// Represents a tasting set that is automatically included with a hike (1:1 relationship)
@freezed
abstract class TastingSet with _$TastingSet {
  const factory TastingSet({
    required int id,
    @JsonKey(name: 'hike_id') required int hikeId,
    required String name,
    required String description,
    required List<WhiskySample> samples,
    @Default(0.0) double price, // Always 0 since it's included in hike price
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'is_included') @Default(true) bool isIncluded, // Always true
    @JsonKey(name: 'is_available') @Default(true) bool isAvailable,
    @JsonKey(name: 'available_from') DateTime? availableFrom,
    @JsonKey(name: 'available_until') DateTime? availableUntil,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _TastingSet;

  factory TastingSet.fromJson(Map<String, dynamic> json) =>
      _$TastingSetFromJson(json);
}

/// Extension for business logic on TastingSet
extension TastingSetExtensions on TastingSet {
  /// Check if the tasting set is currently available based on date constraints
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

  /// Get the total number of samples in the set
  int get sampleCount => samples.length;

  /// Check if the set contains any samples
  bool get hasSamples => samples.isNotEmpty;

  /// Get the total volume of all samples in milliliters
  double get totalVolumeMl =>
      samples.fold(0.0, (sum, sample) => sum + sample.sampleSizeMl);

  /// Get a formatted price string (always "Inklusive" since price is 0)
  String get formattedPrice => 'Inklusive';

  /// Get a short description (first 100 characters)
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  /// Get the main region of the tasting set (most common region among samples)
  String get mainRegion {
    if (samples.isEmpty) return 'Unbekannt';

    final regionCounts = <String, int>{};
    for (final sample in samples) {
      regionCounts[sample.region] = (regionCounts[sample.region] ?? 0) + 1;
    }

    return regionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get the average age of all samples
  double get averageAge {
    if (samples.isEmpty) return 0.0;

    final totalAge = samples.fold(0, (sum, sample) => sum + sample.age);
    return totalAge / samples.length;
  }

  /// Get the average ABV of all samples
  double get averageAbv {
    if (samples.isEmpty) return 0.0;

    final totalAbv = samples.fold(0.0, (sum, sample) => sum + sample.abv);
    return totalAbv / samples.length;
  }
}

/// Extension for business logic on WhiskySample
extension WhiskySampleExtensions on WhiskySample {
  /// Get a formatted age string
  String get formattedAge => '$age Jahre';

  /// Get a formatted ABV string
  String get formattedAbv => '${abv.toStringAsFixed(1)}%';

  /// Get a formatted sample size string
  String get formattedSampleSize => '${sampleSizeMl.toStringAsFixed(0)}ml';

  /// Check if the sample has a category
  bool get hasCategory => category != null && category!.isNotEmpty;

  /// Get a display name with distillery
  String get displayName => '$name ($distillery)';

  /// Get a short display name (just the name)
  String get shortName => name;
}
