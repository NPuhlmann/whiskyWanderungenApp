import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

void main() {
  group('Waypoint Model Tests', () {
    group('Constructor Tests', () {
      test('should create waypoint with required fields', () {
        const waypoint = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Test Waypoint',
          description: 'A test waypoint',
          latitude: 47.3769,
          longitude: 8.5417,
        );

        expect(waypoint.id, 1);
        expect(waypoint.hikeId, 10);
        expect(waypoint.name, 'Test Waypoint');
        expect(waypoint.description, 'A test waypoint');
        expect(waypoint.latitude, 47.3769);
        expect(waypoint.longitude, 8.5417);
        expect(waypoint.orderIndex, 0);
        expect(waypoint.images, isEmpty);
        expect(waypoint.isVisited, false);
      });

      test('should create waypoint with all fields', () {
        const waypoint = Waypoint(
          id: 2,
          hikeId: 20,
          name: 'Full Waypoint',
          description: 'Complete waypoint with all data',
          latitude: 46.9481,
          longitude: 7.4474,
          orderIndex: 3,
          images: ['image1.jpg', 'image2.jpg'],
          isVisited: true,
        );

        expect(waypoint.id, 2);
        expect(waypoint.hikeId, 20);
        expect(waypoint.name, 'Full Waypoint');
        expect(waypoint.description, 'Complete waypoint with all data');
        expect(waypoint.latitude, 46.9481);
        expect(waypoint.longitude, 7.4474);
        expect(waypoint.orderIndex, 3);
        expect(waypoint.images, ['image1.jpg', 'image2.jpg']);
        expect(waypoint.isVisited, true);
      });
    });

    group('copyWith Tests', () {
      const baseWaypoint = Waypoint(
        id: 1,
        hikeId: 10,
        name: 'Base Waypoint',
        description: 'Base description',
        latitude: 47.0,
        longitude: 8.0,
      );

      test('should copy with new name', () {
        final updated = baseWaypoint.copyWith(name: 'Updated Name');

        expect(updated.name, 'Updated Name');
        expect(updated.id, baseWaypoint.id);
        expect(updated.hikeId, baseWaypoint.hikeId);
        expect(updated.latitude, baseWaypoint.latitude);
        expect(updated.longitude, baseWaypoint.longitude);
      });

      test('should copy with new visited status', () {
        final visited = baseWaypoint.copyWith(isVisited: true);

        expect(visited.isVisited, true);
        expect(visited.id, baseWaypoint.id);
        expect(visited.name, baseWaypoint.name);
      });

      test('should copy with new coordinates', () {
        final relocated = baseWaypoint.copyWith(
          latitude: 48.0,
          longitude: 9.0,
        );

        expect(relocated.latitude, 48.0);
        expect(relocated.longitude, 9.0);
        expect(relocated.id, baseWaypoint.id);
        expect(relocated.name, baseWaypoint.name);
      });

      test('should copy with new order index', () {
        final reordered = baseWaypoint.copyWith(orderIndex: 5);

        expect(reordered.orderIndex, 5);
        expect(reordered.id, baseWaypoint.id);
        expect(reordered.name, baseWaypoint.name);
        expect(reordered.latitude, baseWaypoint.latitude);
      });

      test('should copy with new images', () {
        final withImages = baseWaypoint.copyWith(
          images: ['new1.jpg', 'new2.jpg', 'new3.jpg'],
        );

        expect(withImages.images, ['new1.jpg', 'new2.jpg', 'new3.jpg']);
        expect(withImages.id, baseWaypoint.id);
      });

      test('should copy with multiple changes', () {
        final updated = baseWaypoint.copyWith(
          name: 'Multi Update',
          description: 'New description',
          isVisited: true,
          images: ['updated.jpg'],
        );

        expect(updated.name, 'Multi Update');
        expect(updated.description, 'New description');
        expect(updated.isVisited, true);
        expect(updated.images, ['updated.jpg']);
        expect(updated.id, baseWaypoint.id);
        expect(updated.hikeId, baseWaypoint.hikeId);
        expect(updated.latitude, baseWaypoint.latitude);
        expect(updated.longitude, baseWaypoint.longitude);
      });
    });

    group('JSON Serialization Tests', () {
      test('should serialize to JSON correctly', () {
        const waypoint = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'JSON Test',
          description: 'Test JSON serialization',
          latitude: 47.3769,
          longitude: 8.5417,
          orderIndex: 2,
          images: ['test1.jpg', 'test2.jpg'],
          isVisited: true,
        );

        final json = waypoint.toJson();

        expect(json['id'], 1);
        expect(json['hike_id'], 10);
        expect(json['name'], 'JSON Test');
        expect(json['description'], 'Test JSON serialization');
        expect(json['latitude'], 47.3769);
        expect(json['longitude'], 8.5417);
        expect(json['order_index'], 2);
        expect(json['images'], ['test1.jpg', 'test2.jpg']);
        expect(json['is_visited'], true);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 2,
          'hike_id': 20,
          'name': 'From JSON',
          'description': 'Deserialized waypoint',
          'latitude': 46.9481,
          'longitude': 7.4474,
          'order_index': 4,
          'images': ['json1.jpg', 'json2.jpg'],
          'is_visited': false,
        };

        final waypoint = Waypoint.fromJson(json);

        expect(waypoint.id, 2);
        expect(waypoint.hikeId, 20);
        expect(waypoint.name, 'From JSON');
        expect(waypoint.description, 'Deserialized waypoint');
        expect(waypoint.latitude, 46.9481);
        expect(waypoint.longitude, 7.4474);
        expect(waypoint.orderIndex, 4);
        expect(waypoint.images, ['json1.jpg', 'json2.jpg']);
        expect(waypoint.isVisited, false);
      });

      test('should handle empty images array in JSON', () {
        final json = {
          'id': 3,
          'hike_id': 30,
          'name': 'No Images',
          'description': 'No images waypoint',
          'latitude': 45.0,
          'longitude': 6.0,
          'order_index': 1,
          'images': <String>[],
          'is_visited': false,
        };

        final waypoint = Waypoint.fromJson(json);

        expect(waypoint.images, isEmpty);
        expect(waypoint.id, 3);
        expect(waypoint.name, 'No Images');
        expect(waypoint.orderIndex, 1);
      });

      test('should use defaults for optional fields in JSON', () {
        final json = {
          'id': 4,
          'hike_id': 40,
          'name': 'Minimal',
          'description': 'Minimal waypoint',
          'latitude': 44.0,
          'longitude': 5.0,
        };

        final waypoint = Waypoint.fromJson(json);

        expect(waypoint.id, 4);
        expect(waypoint.hikeId, 40);
        expect(waypoint.name, 'Minimal');
        expect(waypoint.description, 'Minimal waypoint');
        expect(waypoint.latitude, 44.0);
        expect(waypoint.longitude, 5.0);
        expect(waypoint.orderIndex, 0);
        expect(waypoint.images, isEmpty);
        expect(waypoint.isVisited, false);
      });
    });

    group('Coordinate Validation Tests', () {
      test('should accept valid coordinates', () {
        const waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Valid Coords',
          description: 'Valid coordinates',
          latitude: 47.3769, // Zurich
          longitude: 8.5417,
        );

        expect(waypoint.latitude, 47.3769);
        expect(waypoint.longitude, 8.5417);
      });

      test('should accept boundary coordinates', () {
        const northPole = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'North Pole',
          description: 'North pole',
          latitude: 90.0,
          longitude: 0.0,
        );

        const southPole = Waypoint(
          id: 2,
          hikeId: 1,
          name: 'South Pole',
          description: 'South pole',
          latitude: -90.0,
          longitude: 180.0,
        );

        expect(northPole.latitude, 90.0);
        expect(southPole.latitude, -90.0);
        expect(southPole.longitude, 180.0);
      });

      test('should accept negative coordinates', () {
        const waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Southern Hemisphere',
          description: 'Below equator',
          latitude: -33.8688, // Sydney
          longitude: 151.2093,
        );

        expect(waypoint.latitude, -33.8688);
        expect(waypoint.longitude, 151.2093);
      });
    });

    group('Image List Tests', () {
      test('should handle empty images list', () {
        const waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'No Images',
          description: 'No images',
          latitude: 47.0,
          longitude: 8.0,
          images: [],
        );

        expect(waypoint.images, isEmpty);
        expect(waypoint.images.length, 0);
      });

      test('should handle multiple images', () {
        const images = [
          'image1.jpg',
          'image2.png',
          'image3.webp',
          'https://example.com/image4.jpg',
        ];

        const waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Multiple Images',
          description: 'Has multiple images',
          latitude: 47.0,
          longitude: 8.0,
          images: images,
        );

        expect(waypoint.images, images);
        expect(waypoint.images.length, 4);
        expect(waypoint.images[0], 'image1.jpg');
        expect(waypoint.images[3], 'https://example.com/image4.jpg');
      });
    });

    group('Equality Tests', () {
      test('should be equal when all fields match', () {
        const waypoint1 = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Same Waypoint',
          description: 'Same description',
          latitude: 47.0,
          longitude: 8.0,
        );
        const waypoint2 = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Same Waypoint',
          description: 'Same description',
          latitude: 47.0,
          longitude: 8.0,
        );

        expect(waypoint1, equals(waypoint2));
        expect(waypoint1.hashCode, equals(waypoint2.hashCode));
      });

      test('should not be equal when id differs', () {
        const waypoint1 = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Same Name',
          description: 'Same desc',
          latitude: 47.0,
          longitude: 8.0,
        );
        const waypoint2 = Waypoint(
          id: 2,
          hikeId: 10,
          name: 'Same Name',
          description: 'Same desc',
          latitude: 47.0,
          longitude: 8.0,
        );

        expect(waypoint1, isNot(equals(waypoint2)));
      });

      test('should not be equal when coordinates differ', () {
        const waypoint1 = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Same Name',
          description: 'Same desc',
          latitude: 47.0,
          longitude: 8.0,
        );
        const waypoint2 = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Same Name',
          description: 'Same desc',
          latitude: 47.1,
          longitude: 8.0,
        );

        expect(waypoint1, isNot(equals(waypoint2)));
      });
    });
  });
}