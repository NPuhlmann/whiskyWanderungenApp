import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/review_rating.dart';

void main() {
  group('ReviewRating', () {
    test('should create ReviewRating with required fields', () {
      final rating = ReviewRating(
        reviewId: 10,
        categoryId: 1,
        rating: 4.0,
        createdAt: DateTime(2024, 8, 31),
      );

      expect(rating.reviewId, 10);
      expect(rating.categoryId, 1);
      expect(rating.rating, 4.0);
      expect(rating.notes, isNull);
      expect(rating.createdAt, DateTime(2024, 8, 31));
    });

    test('should validate rating range (1.0 to 5.0)', () {
      expect(
        () => ReviewRating(
          reviewId: 1,
          categoryId: 1,
          rating: 0.9,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ReviewRating(
          reviewId: 1,
          categoryId: 1,
          rating: 5.1,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ReviewRating(
          reviewId: 1,
          categoryId: 1,
          rating: 1.0,
        ),
        returnsNormally,
      );

      expect(
        () => ReviewRating(
          reviewId: 1,
          categoryId: 1,
          rating: 5.0,
        ),
        returnsNormally,
      );
    });

    test('should validate notes max length', () {
      expect(
        () => ReviewRating(
          reviewId: 1,
          categoryId: 1,
          rating: 4.0,
          notes: 'A' * 501,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ReviewRating(
          reviewId: 1,
          categoryId: 1,
          rating: 4.0,
          notes: 'Kurz',
        ),
        returnsNormally,
      );
    });

    test('should convert to JSON and back', () {
      final original = ReviewRating(
        reviewId: 10,
        categoryId: 2,
        rating: 3.5,
        notes: 'Gute Balance',
        createdAt: DateTime(2024, 8, 31, 12, 0, 0),
      );

      final json = original.toJson();
      final restored = ReviewRating.fromJson(json);

      expect(restored.reviewId, original.reviewId);
      expect(restored.categoryId, original.categoryId);
      expect(restored.rating, original.rating);
      expect(restored.notes, original.notes);
      expect(restored.createdAt, original.createdAt);
    });

    test('should handle copyWith operations', () {
      final original = ReviewRating(
        reviewId: 10,
        categoryId: 1,
        rating: 4.0,
      );

      final updated = original.copyWith(rating: 4.5, notes: 'Sehr gut');

      expect(updated.reviewId, original.reviewId);
      expect(updated.categoryId, original.categoryId);
      expect(updated.rating, 4.5);
      expect(updated.notes, 'Sehr gut');
    });

    test('should implement equality and hashCode', () {
      final a = ReviewRating(reviewId: 10, categoryId: 1, rating: 4.0);
      final b = ReviewRating(reviewId: 10, categoryId: 1, rating: 4.0);
      final c = ReviewRating(reviewId: 10, categoryId: 2, rating: 4.0);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('should calculate weighted score', () {
      final rr = ReviewRating(reviewId: 1, categoryId: 1, rating: 4.0);
      final weighted = rr.calculateWeightedScore(0.6);
      expect(weighted, 2.4);
    });

    test('toString contains important fields', () {
      final rr = ReviewRating(
        reviewId: 7,
        categoryId: 3,
        rating: 4.5,
        notes: 'Top',
        createdAt: DateTime(2024, 8, 31),
      );

      final s = rr.toString();
      expect(s, contains('ReviewRating'));
      expect(s, contains('reviewId: 7'));
      expect(s, contains('categoryId: 3'));
      expect(s, contains('rating: 4.5'));
      expect(s, contains('Top'));
    });
  });
}
