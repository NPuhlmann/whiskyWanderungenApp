import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

void main() {
  group('Hike smoke', () {
    test('constructs with required id only and applies defaults', () {
      const hike = Hike(id: 1);

      expect(hike.id, 1);
      expect(hike.name, '');
      expect(hike.length, 1.0);
      expect(hike.steep, 0.2);
      expect(hike.elevation, 100);
      expect(hike.difficulty, Difficulty.mid);
      expect(hike.isFavorite, false);
      expect(hike.isAvailable, true);
      expect(hike.category, 'Whisky');
      expect(hike.tags, isEmpty);
    });

    test('copyWith produces an updated immutable instance', () {
      const original = Hike(id: 7, name: 'Highland Walk');
      final updated = original.copyWith(name: 'Highland Hike', length: 12.5);

      expect(updated.id, 7);
      expect(updated.name, 'Highland Hike');
      expect(updated.length, 12.5);
      expect(original.name, 'Highland Walk');
    });

    test('survives a fromJson / toJson round-trip', () {
      const hike = Hike(
        id: 42,
        name: 'Skye Loop',
        length: 18.4,
        difficulty: Difficulty.hard,
        isFavorite: true,
        category: 'Whisky',
        tags: ['Island', 'Scotch'],
      );

      final rehydrated = Hike.fromJson(hike.toJson());

      expect(rehydrated, hike);
    });
  });
}
