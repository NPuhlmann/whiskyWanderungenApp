import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/review.dart';

void main() {
  group('Review', () {
    test('should create Review with required fields', () {
      final review = Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.5,
        comment: 'Ein fantastischer Whisky-Hike!',
        createdAt: DateTime(2024, 8, 31),
        userFirstName: 'Max',
        userLastName: 'Mustermann',
      );

      expect(review.id, equals(1));
      expect(review.hikeId, equals(123));
      expect(review.userId, equals('user-123'));
      expect(review.rating, equals(4.5));
      expect(review.comment, equals('Ein fantastischer Whisky-Hike!'));
      expect(review.createdAt, equals(DateTime(2024, 8, 31)));
      expect(review.userFirstName, equals('Max'));
      expect(review.userLastName, equals('Mustermann'));
    });

    test('should create Review with optional fields as null', () {
      final review = Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.5,
        comment: 'Ein fantastischer Whisky-Hike!',
        createdAt: DateTime(2024, 8, 31),
      );

      expect(review.userFirstName, isNull);
      expect(review.userLastName, isNull);
    });

    test('should validate rating range (1.0 to 5.0)', () {
      expect(() => Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 0.5, // Unter 1.0
        comment: 'Test',
        createdAt: DateTime(2024, 8, 31),
      ), throwsA(isA<AssertionError>()));

      expect(() => Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 5.5, // Über 5.0
        comment: 'Test',
        createdAt: DateTime(2024, 8, 31),
      ), throwsA(isA<AssertionError>()));

      // Gültige Bewertungen
      expect(() => Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 1.0,
        comment: 'Test',
        createdAt: DateTime(2024, 8, 31),
      ), returnsNormally);

      expect(() => Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 5.0,
        comment: 'Test',
        createdAt: DateTime(2024, 8, 31),
      ), returnsNormally);
    });

    test('should validate comment length', () {
      expect(() => Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.0,
        comment: '', // Leerer Kommentar
        createdAt: DateTime(2024, 8, 31),
      ), throwsA(isA<AssertionError>()));

      expect(() => Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.0,
        comment: 'A' * 1001, // Zu lang (über 1000 Zeichen)
        createdAt: DateTime(2024, 8, 31),
      ), throwsA(isA<AssertionError>()));

      // Gültige Kommentare
      expect(() => Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.0,
        comment: 'Ein guter Kommentar',
        createdAt: DateTime(2024, 8, 31),
      ), returnsNormally);
    });

    test('should convert to JSON and back', () {
      final originalReview = Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.5,
        comment: 'Ein fantastischer Whisky-Hike!',
        createdAt: DateTime(2024, 8, 31, 12, 30, 0),
        userFirstName: 'Max',
        userLastName: 'Mustermann',
      );

      final json = originalReview.toJson();
      final restoredReview = Review.fromJson(json);

      expect(restoredReview.id, equals(originalReview.id));
      expect(restoredReview.hikeId, equals(originalReview.hikeId));
      expect(restoredReview.userId, equals(originalReview.userId));
      expect(restoredReview.rating, equals(originalReview.rating));
      expect(restoredReview.comment, equals(originalReview.comment));
      expect(restoredReview.createdAt, equals(originalReview.createdAt));
      expect(restoredReview.userFirstName, equals(originalReview.userFirstName));
      expect(restoredReview.userLastName, equals(originalReview.userLastName));
    });

    test('should handle copyWith operations', () {
      final originalReview = Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.0,
        comment: 'Originaler Kommentar',
        createdAt: DateTime(2024, 8, 31),
        userFirstName: 'Max',
        userLastName: 'Mustermann',
      );

      final updatedReview = originalReview.copyWith(
        rating: 5.0,
        comment: 'Aktualisierter Kommentar',
      );

      expect(updatedReview.id, equals(originalReview.id));
      expect(updatedReview.hikeId, equals(originalReview.hikeId));
      expect(updatedReview.userId, equals(originalReview.userId));
      expect(updatedReview.rating, equals(5.0));
      expect(updatedReview.comment, equals('Aktualisierter Kommentar'));
      expect(updatedReview.createdAt, equals(originalReview.createdAt));
      expect(updatedReview.userFirstName, equals(originalReview.userFirstName));
      expect(updatedReview.userLastName, equals(originalReview.userLastName));
    });

    test('should implement equality correctly', () {
      final review1 = Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.0,
        comment: 'Test',
        createdAt: DateTime(2024, 8, 31),
      );

      final review2 = Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.0,
        comment: 'Test',
        createdAt: DateTime(2024, 8, 31),
      );

      final review3 = Review(
        id: 2, // Unterschiedliche ID
        hikeId: 123,
        userId: 'user-123',
        rating: 4.0,
        comment: 'Test',
        createdAt: DateTime(2024, 8, 31),
      );

      expect(review1, equals(review2));
      expect(review1, isNot(equals(review3)));
      expect(review1.hashCode, equals(review2.hashCode));
      expect(review1.hashCode, isNot(equals(review3.hashCode)));
    });

    test('should provide meaningful toString representation', () {
      final review = Review(
        id: 1,
        hikeId: 123,
        userId: 'user-123',
        rating: 4.5,
        comment: 'Test Kommentar',
        createdAt: DateTime(2024, 8, 31),
        userFirstName: 'Max',
        userLastName: 'Mustermann',
      );

      final stringRepresentation = review.toString();
      
      expect(stringRepresentation, contains('Review'));
      expect(stringRepresentation, contains('id: 1'));
      expect(stringRepresentation, contains('hikeId: 123'));
      expect(stringRepresentation, contains('rating: 4.5'));
      expect(stringRepresentation, contains('Max'));
      expect(stringRepresentation, contains('Mustermann'));
    });
  });
}
