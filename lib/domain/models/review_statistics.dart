import 'review.dart';
import 'review_rating.dart';

/// Aggregierte Statistiken über Reviews eines Hikes
class ReviewStatistics {
  final int reviewCount;
  final double averageRating; // 0.0 bis 5.0
  final Map<int, int> starCounts; // 1..5 -> Anzahl

  ReviewStatistics({
    required this.reviewCount,
    required this.averageRating,
    required Map<int, int> starCounts,
  }) : starCounts = _normalizeStarCounts(starCounts);

  /// Rundet den Durchschnitt auf eine Nachkommastelle
  double get roundedAverage => (averageRating * 10).round() / 10.0;

  /// Prozentverteilung pro Stern (0..100)
  Map<int, double> get starPercentages {
    if (reviewCount == 0) {
      return {for (var s = 1; s <= 5; s++) s: 0.0};
    }
    return {
      for (var s = 1; s <= 5; s++) s: (starCounts[s]! / reviewCount) * 100.0,
    };
  }

  /// Erstellt Statistiken aus einer Liste von Reviews
  factory ReviewStatistics.fromReviews(List<Review> reviews) {
    if (reviews.isEmpty) {
      return ReviewStatistics(
        reviewCount: 0,
        averageRating: 0.0,
        starCounts: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }

    final count = reviews.length;
    final sum = reviews.fold<double>(0.0, (acc, r) => acc + r.rating);
    final avg = sum / count;

    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final star = r.rating.round().clamp(1, 5);
      counts[star] = (counts[star] ?? 0) + 1;
    }

    return ReviewStatistics(
      reviewCount: count,
      averageRating: avg,
      starCounts: counts,
    );
  }

  /// Berechnet den gewichteten Durchschnitt aus Kategorie-Bewertungen
  /// [weights] mappt categoryId -> Gewicht (0..1)
  static double weightedAverage(
    List<ReviewRating> ratings,
    Map<int, double> weights,
  ) {
    if (ratings.isEmpty || weights.isEmpty) return 0.0;

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final rr in ratings) {
      final w = weights[rr.categoryId];
      if (w == null || w <= 0) continue;
      weightedSum += rr.rating * w;
      totalWeight += w;
    }

    if (totalWeight == 0.0) return 0.0;
    return weightedSum / totalWeight;
  }

  Map<String, dynamic> toJson() {
    return {
      'review_count': reviewCount,
      'average_rating': averageRating,
      'star_counts': {
        for (final entry in starCounts.entries)
          entry.key.toString(): entry.value,
      },
    };
  }

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    final rawCounts = (json['star_counts'] as Map).cast<String, dynamic>();
    final counts = <int, int>{};
    for (final e in rawCounts.entries) {
      counts[int.parse(e.key)] = (e.value as num).toInt();
    }

    return ReviewStatistics(
      reviewCount: (json['review_count'] as num).toInt(),
      averageRating: (json['average_rating'] as num).toDouble(),
      starCounts: counts,
    );
  }

  static Map<int, int> _normalizeStarCounts(Map<int, int> input) {
    final normalized = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var s = 1; s <= 5; s++) {
      normalized[s] = input[s] ?? 0;
    }
    return normalized;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReviewStatistics) return false;
    if (reviewCount != other.reviewCount) return false;
    if (averageRating != other.averageRating) return false;

    for (var s = 1; s <= 5; s++) {
      if (starCounts[s] != other.starCounts[s]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    reviewCount,
    averageRating,
    starCounts[1],
    starCounts[2],
    starCounts[3],
    starCounts[4],
    starCounts[5],
  );

  @override
  String toString() {
    return 'ReviewStatistics(reviewCount: $reviewCount, averageRating: $averageRating, starCounts: $starCounts)';
  }
}
