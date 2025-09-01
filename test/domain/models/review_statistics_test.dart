import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/review.dart';
import 'package:whisky_hikes/domain/models/review_rating.dart';
import 'package:whisky_hikes/domain/models/review_statistics.dart';

void main() {
  group('ReviewStatistics', () {
    test('should compute average rating and count from reviews', () {
      final reviews = [
        Review(id: 1, hikeId: 1, userId: 'u1', rating: 4.0, comment: 'A', createdAt: DateTime(2024, 1, 1)),
        Review(id: 2, hikeId: 1, userId: 'u2', rating: 5.0, comment: 'B', createdAt: DateTime(2024, 1, 2)),
        Review(id: 3, hikeId: 1, userId: 'u3', rating: 3.0, comment: 'C', createdAt: DateTime(2024, 1, 3)),
      ];

      final stats = ReviewStatistics.fromReviews(reviews);

      expect(stats.reviewCount, 3);
      expect(stats.averageRating, closeTo(4.0, 0.0001));
      expect(stats.roundedAverage, 4.0);
    });

    test('should compute star distribution (1..5)', () {
      final reviews = [
        Review(id: 1, hikeId: 1, userId: 'u1', rating: 1.0, comment: 'A', createdAt: DateTime(2024, 1, 1)),
        Review(id: 2, hikeId: 1, userId: 'u2', rating: 2.0, comment: 'B', createdAt: DateTime(2024, 1, 2)),
        Review(id: 3, hikeId: 1, userId: 'u3', rating: 2.0, comment: 'C', createdAt: DateTime(2024, 1, 3)),
        Review(id: 4, hikeId: 1, userId: 'u4', rating: 5.0, comment: 'D', createdAt: DateTime(2024, 1, 4)),
      ];

      final stats = ReviewStatistics.fromReviews(reviews);

      expect(stats.starCounts[1], 1);
      expect(stats.starCounts[2], 2);
      expect(stats.starCounts[3], 0);
      expect(stats.starCounts[4], 0);
      expect(stats.starCounts[5], 1);

      final percentages = stats.starPercentages;
      expect(percentages[1], closeTo(25.0, 0.0001));
      expect(percentages[2], closeTo(50.0, 0.0001));
      expect(percentages[3], closeTo(0.0, 0.0001));
      expect(percentages[4], closeTo(0.0, 0.0001));
      expect(percentages[5], closeTo(25.0, 0.0001));
    });

    test('should compute weighted average from review ratings and category weights', () {
      final ratings = [
        ReviewRating(reviewId: 1, categoryId: 1, rating: 4.0),
        ReviewRating(reviewId: 1, categoryId: 2, rating: 5.0),
      ];
      final weights = {1: 0.4, 2: 0.6};

      final weightedAverage = ReviewStatistics.weightedAverage(ratings, weights);

      expect(weightedAverage, closeTo(4.6, 0.0001));
    });

    test('should handle empty inputs gracefully', () {
      final stats = ReviewStatistics.fromReviews([]);
      expect(stats.reviewCount, 0);
      expect(stats.averageRating, 0.0);
      expect(stats.starCounts[1], 0);
      expect(stats.starCounts[5], 0);
      expect(stats.starPercentages[1], 0.0);
    });

    test('should convert to JSON and back', () {
      final reviews = [
        Review(id: 1, hikeId: 1, userId: 'u1', rating: 4.0, comment: 'A', createdAt: DateTime(2024, 1, 1)),
        Review(id: 2, hikeId: 1, userId: 'u2', rating: 5.0, comment: 'B', createdAt: DateTime(2024, 1, 2)),
      ];

      final original = ReviewStatistics.fromReviews(reviews);
      final json = original.toJson();
      final restored = ReviewStatistics.fromJson(json);

      expect(restored.reviewCount, original.reviewCount);
      expect(restored.averageRating, original.averageRating);
      expect(restored.starCounts, original.starCounts);
    });

    test('should implement equality and toString', () {
      final reviews = [
        Review(id: 1, hikeId: 1, userId: 'u1', rating: 4.0, comment: 'A', createdAt: DateTime(2024, 1, 1)),
        Review(id: 2, hikeId: 1, userId: 'u2', rating: 5.0, comment: 'B', createdAt: DateTime(2024, 1, 2)),
      ];

      final a = ReviewStatistics.fromReviews(reviews);
      final b = ReviewStatistics.fromReviews(reviews);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final s = a.toString();
      expect(s, contains('ReviewStatistics'));
      expect(s, contains('reviewCount: 2'));
      expect(s, contains('averageRating'));
    });
  });
}
