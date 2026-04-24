import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/review_category.dart';

void main() {
  group('ReviewCategory', () {
    test('should create ReviewCategory with required fields', () {
      final category = ReviewCategory(
        id: 1,
        name: 'Whisky-Qualität',
        description: 'Bewertung der Qualität der Whisky-Proben',
        weight: 0.4,
        isActive: true,
      );

      expect(category.id, equals(1));
      expect(category.name, equals('Whisky-Qualität'));
      expect(
        category.description,
        equals('Bewertung der Qualität der Whisky-Proben'),
      );
      expect(category.weight, equals(0.4));
      expect(category.isActive, isTrue);
    });

    test('should create ReviewCategory with default values', () {
      final category = ReviewCategory(
        id: 1,
        name: 'Test Kategorie',
        description: 'Test Beschreibung',
        weight: 0.5,
      );

      expect(category.isActive, isTrue);
      expect(category.createdAt, isNotNull);
      expect(category.updatedAt, isNotNull);
    });

    test('should validate weight range (0.0 to 1.0)', () {
      expect(
        () => ReviewCategory(
          id: 1,
          name: 'Test',
          description: 'Test',
          weight: -0.1, // Unter 0.0
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ReviewCategory(
          id: 1,
          name: 'Test',
          description: 'Test',
          weight: 1.1, // Über 1.0
        ),
        throwsA(isA<AssertionError>()),
      );

      // Gültige Gewichtungen
      expect(
        () => ReviewCategory(
          id: 1,
          name: 'Test',
          description: 'Test',
          weight: 0.0,
        ),
        returnsNormally,
      );

      expect(
        () => ReviewCategory(
          id: 1,
          name: 'Test',
          description: 'Test',
          weight: 1.0,
        ),
        returnsNormally,
      );

      expect(
        () => ReviewCategory(
          id: 1,
          name: 'Test',
          description: 'Test',
          weight: 0.5,
        ),
        returnsNormally,
      );
    });

    test('should validate name length', () {
      expect(
        () => ReviewCategory(
          id: 1,
          name: '', // Leerer Name
          description: 'Test',
          weight: 0.5,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ReviewCategory(
          id: 1,
          name: 'A' * 101, // Zu lang (über 100 Zeichen)
          description: 'Test',
          weight: 0.5,
        ),
        throwsA(isA<AssertionError>()),
      );

      // Gültige Namen
      expect(
        () => ReviewCategory(
          id: 1,
          name: 'Kategorie',
          description: 'Test',
          weight: 0.5,
        ),
        returnsNormally,
      );
    });

    test('should convert to JSON and back', () {
      final originalCategory = ReviewCategory(
        id: 1,
        name: 'Whisky-Qualität',
        description: 'Bewertung der Qualität der Whisky-Proben',
        weight: 0.4,
        isActive: true,
        createdAt: DateTime(2024, 8, 31, 12, 30, 0),
        updatedAt: DateTime(2024, 8, 31, 12, 30, 0),
      );

      final json = originalCategory.toJson();
      final restoredCategory = ReviewCategory.fromJson(json);

      expect(restoredCategory.id, equals(originalCategory.id));
      expect(restoredCategory.name, equals(originalCategory.name));
      expect(
        restoredCategory.description,
        equals(originalCategory.description),
      );
      expect(restoredCategory.weight, equals(originalCategory.weight));
      expect(restoredCategory.isActive, equals(originalCategory.isActive));
      expect(restoredCategory.createdAt, equals(originalCategory.createdAt));
      expect(restoredCategory.updatedAt, equals(originalCategory.updatedAt));
    });

    test('should handle copyWith operations', () {
      final originalCategory = ReviewCategory(
        id: 1,
        name: 'Original Name',
        description: 'Original Beschreibung',
        weight: 0.5,
        isActive: true,
      );

      final updatedCategory = originalCategory.copyWith(
        name: 'Aktualisierter Name',
        weight: 0.7,
      );

      expect(updatedCategory.id, equals(originalCategory.id));
      expect(updatedCategory.name, equals('Aktualisierter Name'));
      expect(updatedCategory.description, equals(originalCategory.description));
      expect(updatedCategory.weight, equals(0.7));
      expect(updatedCategory.isActive, equals(originalCategory.isActive));
    });

    test('should implement equality correctly', () {
      final now = DateTime.now();
      final category1 = ReviewCategory(
        id: 1,
        name: 'Test',
        description: 'Test',
        weight: 0.5,
        createdAt: now,
        updatedAt: now,
      );

      final category2 = ReviewCategory(
        id: 1,
        name: 'Test',
        description: 'Test',
        weight: 0.5,
        createdAt: now,
        updatedAt: now,
      );

      final category3 = ReviewCategory(
        id: 2, // Unterschiedliche ID
        name: 'Test',
        description: 'Test',
        weight: 0.5,
        createdAt: now,
        updatedAt: now,
      );

      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
      expect(category1.hashCode, equals(category2.hashCode));
      expect(category1.hashCode, isNot(equals(category3.hashCode)));
    });

    test('should provide meaningful toString representation', () {
      final category = ReviewCategory(
        id: 1,
        name: 'Whisky-Qualität',
        description: 'Test Beschreibung',
        weight: 0.4,
        isActive: true,
      );

      final stringRepresentation = category.toString();

      expect(stringRepresentation, contains('ReviewCategory'));
      expect(stringRepresentation, contains('id: 1'));
      expect(stringRepresentation, contains('name: Whisky-Qualität'));
      expect(stringRepresentation, contains('weight: 0.4'));
      expect(stringRepresentation, contains('isActive: true'));
    });

    test('should calculate weighted score correctly', () {
      final category = ReviewCategory(
        id: 1,
        name: 'Test',
        description: 'Test',
        weight: 0.6,
      );

      final score = 4.0;
      final weightedScore = category.calculateWeightedScore(score);

      expect(weightedScore, equals(4.0 * 0.6));
      expect(weightedScore, equals(2.4));
    });

    test('should validate weight sum for multiple categories', () {
      final categories = [
        ReviewCategory(
          id: 1,
          name: 'Kategorie 1',
          description: 'Test',
          weight: 0.4,
        ),
        ReviewCategory(
          id: 2,
          name: 'Kategorie 2',
          description: 'Test',
          weight: 0.6,
        ),
      ];

      final totalWeight = categories.fold<double>(
        0.0,
        (sum, cat) => sum + cat.weight,
      );
      expect(totalWeight, equals(1.0));
    });
  });
}
