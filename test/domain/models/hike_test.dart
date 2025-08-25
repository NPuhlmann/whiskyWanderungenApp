import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

void main() {
  group('Hike Model Tests', () {
    group('Constructor and Default Values', () {
      test('should create hike with required id', () {
        const hike = Hike(id: 1);
        
        expect(hike.id, 1);
        expect(hike.name, '');
        expect(hike.length, 1.0);
        expect(hike.steep, 0.2);
        expect(hike.elevation, 100);
        expect(hike.description, '');
        expect(hike.price, 1.0);
        expect(hike.difficulty, Difficulty.mid);
        expect(hike.thumbnailImageUrl, null);
        expect(hike.isFavorite, false);
      });

      test('should create hike with all custom values', () {
        const hike = Hike(
          id: 2,
          name: 'Test Hike',
          length: 5.5,
          steep: 0.8,
          elevation: 500,
          description: 'A challenging mountain hike',
          price: 29.99,
          difficulty: Difficulty.hard,
          thumbnailImageUrl: 'https://example.com/image.jpg',
          isFavorite: true,
        );
        
        expect(hike.id, 2);
        expect(hike.name, 'Test Hike');
        expect(hike.length, 5.5);
        expect(hike.steep, 0.8);
        expect(hike.elevation, 500);
        expect(hike.description, 'A challenging mountain hike');
        expect(hike.price, 29.99);
        expect(hike.difficulty, Difficulty.hard);
        expect(hike.thumbnailImageUrl, 'https://example.com/image.jpg');
        expect(hike.isFavorite, true);
      });
    });

    group('copyWith Tests', () {
      const baseHike = Hike(
        id: 1,
        name: 'Base Hike',
        length: 3.0,
        price: 15.0,
      );

      test('should copy with new name', () {
        final updatedHike = baseHike.copyWith(name: 'Updated Hike');
        
        expect(updatedHike.id, 1);
        expect(updatedHike.name, 'Updated Hike');
        expect(updatedHike.length, 3.0);
        expect(updatedHike.price, 15.0);
      });

      test('should copy with new favorite status', () {
        final favoriteHike = baseHike.copyWith(isFavorite: true);
        
        expect(favoriteHike.isFavorite, true);
        expect(favoriteHike.id, baseHike.id);
        expect(favoriteHike.name, baseHike.name);
      });

      test('should copy with new difficulty', () {
        final hardHike = baseHike.copyWith(difficulty: Difficulty.veryHard);
        
        expect(hardHike.difficulty, Difficulty.veryHard);
        expect(hardHike.id, baseHike.id);
      });

      test('should copy with multiple changes', () {
        final updatedHike = baseHike.copyWith(
          name: 'Multi Update',
          price: 25.0,
          isFavorite: true,
          difficulty: Difficulty.easy,
        );
        
        expect(updatedHike.name, 'Multi Update');
        expect(updatedHike.price, 25.0);
        expect(updatedHike.isFavorite, true);
        expect(updatedHike.difficulty, Difficulty.easy);
        expect(updatedHike.id, baseHike.id);
        expect(updatedHike.length, baseHike.length);
      });
    });

    group('JSON Serialization Tests', () {
      test('should serialize to JSON correctly', () {
        const hike = Hike(
          id: 1,
          name: 'Test Hike',
          length: 5.0,
          steep: 0.3,
          elevation: 200,
          description: 'Test description',
          price: 19.99,
          difficulty: Difficulty.easy,
          thumbnailImageUrl: 'https://example.com/image.jpg',
          isFavorite: true,
        );

        final json = hike.toJson();

        expect(json['id'], 1);
        expect(json['name'], 'Test Hike');
        expect(json['length'], 5.0);
        expect(json['steep'], 0.3);
        expect(json['elevation'], 200);
        expect(json['description'], 'Test description');
        expect(json['price'], 19.99);
        expect(json['difficulty'], 'easy');
        expect(json['thumbnail_image_url'], 'https://example.com/image.jpg');
        expect(json['is_favorite'], true);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 2,
          'name': 'JSON Hike',
          'length': 7.5,
          'steep': 0.5,
          'elevation': 300,
          'description': 'From JSON',
          'price': 24.99,
          'difficulty': 'hard',
          'thumbnail_image_url': 'https://example.com/json.jpg',
          'is_favorite': false,
        };

        final hike = Hike.fromJson(json);

        expect(hike.id, 2);
        expect(hike.name, 'JSON Hike');
        expect(hike.length, 7.5);
        expect(hike.steep, 0.5);
        expect(hike.elevation, 300);
        expect(hike.description, 'From JSON');
        expect(hike.price, 24.99);
        expect(hike.difficulty, Difficulty.hard);
        expect(hike.thumbnailImageUrl, 'https://example.com/json.jpg');
        expect(hike.isFavorite, false);
      });

      test('should handle null thumbnailImageUrl in JSON', () {
        final json = {
          'id': 3,
          'name': 'No Image Hike',
          'thumbnail_image_url': null,
        };

        final hike = Hike.fromJson(json);

        expect(hike.id, 3);
        expect(hike.name, 'No Image Hike');
        expect(hike.thumbnailImageUrl, null);
      });

      test('should use defaults for missing JSON fields', () {
        final json = {'id': 4};

        final hike = Hike.fromJson(json);

        expect(hike.id, 4);
        expect(hike.name, '');
        expect(hike.length, 1.0);
        expect(hike.difficulty, Difficulty.mid);
        expect(hike.isFavorite, false);
      });
    });

    group('Difficulty Enum Tests', () {
      test('should handle all difficulty levels', () {
        const difficulties = [
          Difficulty.easy,
          Difficulty.mid,
          Difficulty.hard,
          Difficulty.veryHard,
        ];

        for (final difficulty in difficulties) {
          final hike = Hike(id: 1, difficulty: difficulty);
          expect(hike.difficulty, difficulty);
        }
      });

      test('should serialize difficulty enum correctly', () {
        const easyHike = Hike(id: 1, difficulty: Difficulty.easy);
        const hardHike = Hike(id: 2, difficulty: Difficulty.veryHard);

        expect(easyHike.toJson()['difficulty'], 'easy');
        expect(hardHike.toJson()['difficulty'], 'veryHard');
      });
    });

    group('Equality Tests', () {
      test('should be equal when all fields match', () {
        const hike1 = Hike(
          id: 1,
          name: 'Same Hike',
          length: 5.0,
          price: 20.0,
        );
        const hike2 = Hike(
          id: 1,
          name: 'Same Hike',
          length: 5.0,
          price: 20.0,
        );

        expect(hike1, equals(hike2));
        expect(hike1.hashCode, equals(hike2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const hike1 = Hike(id: 1, name: 'Hike 1');
        const hike2 = Hike(id: 1, name: 'Hike 2');

        expect(hike1, isNot(equals(hike2)));
      });

      test('should not be equal when id differs', () {
        const hike1 = Hike(id: 1, name: 'Same Name');
        const hike2 = Hike(id: 2, name: 'Same Name');

        expect(hike1, isNot(equals(hike2)));
      });
    });
  });
}