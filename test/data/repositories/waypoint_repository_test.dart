import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/waypoint_repository.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import '../../mocks/mock_backend_api_service.dart';

void main() {
  group('WaypointRepository Tests', () {
    late MockBackendApiService mockBackendApiService;
    late WaypointRepository waypointRepository;

    setUp(() {
      mockBackendApiService = MockBackendApiService();
      waypointRepository = WaypointRepository(mockBackendApiService);
    });

    group('getWaypointsForHike', () {
      const testHikeId = 1;

      test('should return list of waypoints when backend service succeeds', () async {
        // Arrange
        final expectedWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Start Point',
            description: 'Beginning of the trail',
            latitude: 47.3769,
            longitude: 8.5417,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'Viewpoint',
            description: 'Great mountain view',
            latitude: 47.3800,
            longitude: 8.5450,
            images: ['view1.jpg', 'view2.jpg'],
          ),
          const Waypoint(
            id: 3,
            hikeId: testHikeId,
            name: 'End Point',
            description: 'End of the trail',
            latitude: 47.3850,
            longitude: 8.5500,
            isVisited: true,
          ),
        ];

        when(mockBackendApiService.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => expectedWaypoints);

        // Act
        final result = await waypointRepository.getWaypointsForHike(testHikeId);

        // Assert
        expect(result, equals(expectedWaypoints));
        expect(result.length, 3);
        expect(result[0].name, 'Start Point');
        expect(result[1].images.length, 2);
        expect(result[2].isVisited, true);

        verify(mockBackendApiService.getWaypointsForHike(testHikeId)).called(1);
      });

      test('should return empty list when no waypoints exist', () async {
        // Arrange
        when(mockBackendApiService.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => []);

        // Act
        final result = await waypointRepository.getWaypointsForHike(testHikeId);

        // Assert
        expect(result, isEmpty);
        verify(mockBackendApiService.getWaypointsForHike(testHikeId)).called(1);
      });

      test('should throw custom exception when backend service fails', () async {
        // Arrange
        const originalError = 'Network timeout';
        when(mockBackendApiService.getWaypointsForHike(testHikeId))
            .thenThrow(Exception(originalError));

        // Act & Assert
        try {
          await waypointRepository.getWaypointsForHike(testHikeId);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e.toString(), contains('Fehler beim Abrufen der Wegpunkte für Wanderung $testHikeId'));
          expect(e.toString(), contains(originalError));
        }

        verify(mockBackendApiService.getWaypointsForHike(testHikeId)).called(1);
      });

      test('should handle different hike IDs correctly', () async {
        // Arrange
        const hikeId1 = 1;
        const hikeId2 = 2;
        
        final waypoints1 = [
          const Waypoint(id: 1, hikeId: hikeId1, name: 'Hike 1 Point', description: 'Point 1', latitude: 47.0, longitude: 8.0),
        ];
        final waypoints2 = [
          const Waypoint(id: 2, hikeId: hikeId2, name: 'Hike 2 Point A', description: 'Point A', latitude: 46.0, longitude: 7.0),
          const Waypoint(id: 3, hikeId: hikeId2, name: 'Hike 2 Point B', description: 'Point B', latitude: 46.1, longitude: 7.1),
        ];

        when(mockBackendApiService.getWaypointsForHike(hikeId1))
            .thenAnswer((_) async => waypoints1);
        when(mockBackendApiService.getWaypointsForHike(hikeId2))
            .thenAnswer((_) async => waypoints2);

        // Act
        final result1 = await waypointRepository.getWaypointsForHike(hikeId1);
        final result2 = await waypointRepository.getWaypointsForHike(hikeId2);

        // Assert
        expect(result1.length, 1);
        expect(result2.length, 2);
        expect(result1[0].name, 'Hike 1 Point');
        expect(result2[0].name, 'Hike 2 Point A');

        verify(mockBackendApiService.getWaypointsForHike(hikeId1)).called(1);
        verify(mockBackendApiService.getWaypointsForHike(hikeId2)).called(1);
      });
    });

    group('addWaypoint', () {
      const testHikeId = 1;
      const testWaypoint = Waypoint(
        id: 1,
        hikeId: testHikeId,
        name: 'New Waypoint',
        description: 'A new waypoint',
        latitude: 47.3769,
        longitude: 8.5417,
      );

      test('should add waypoint successfully', () async {
        // Arrange
        when(mockBackendApiService.addWaypoint(testWaypoint, testHikeId))
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await waypointRepository.addWaypoint(testWaypoint, testHikeId);

        verify(mockBackendApiService.addWaypoint(testWaypoint, testHikeId)).called(1);
      });

      test('should throw custom exception when backend service fails', () async {
        // Arrange
        const originalError = 'Database constraint violation';
        when(mockBackendApiService.addWaypoint(testWaypoint, testHikeId))
            .thenThrow(Exception(originalError));

        // Act & Assert
        try {
          await waypointRepository.addWaypoint(testWaypoint, testHikeId);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e.toString(), contains('Fehler beim Hinzufügen des Wegpunkts'));
          expect(e.toString(), contains(originalError));
        }

        verify(mockBackendApiService.addWaypoint(testWaypoint, testHikeId)).called(1);
      });

      test('should handle waypoint with images', () async {
        // Arrange
        const waypointWithImages = Waypoint(
          id: 2,
          hikeId: testHikeId,
          name: 'Image Waypoint',
          description: 'Waypoint with images',
          latitude: 47.3800,
          longitude: 8.5450,
          images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
        );

        when(mockBackendApiService.addWaypoint(waypointWithImages, testHikeId))
            .thenAnswer((_) async => {});

        // Act & Assert
        await waypointRepository.addWaypoint(waypointWithImages, testHikeId);

        verify(mockBackendApiService.addWaypoint(waypointWithImages, testHikeId)).called(1);
      });
    });

    group('updateWaypoint', () {
      const testWaypoint = Waypoint(
        id: 1,
        hikeId: 1,
        name: 'Updated Waypoint',
        description: 'An updated waypoint',
        latitude: 47.3769,
        longitude: 8.5417,
        isVisited: true,
      );

      test('should update waypoint successfully', () async {
        // Arrange
        when(mockBackendApiService.updateWaypoint(testWaypoint))
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await waypointRepository.updateWaypoint(testWaypoint);

        verify(mockBackendApiService.updateWaypoint(testWaypoint)).called(1);
      });

      test('should throw custom exception when backend service fails', () async {
        // Arrange
        const originalError = 'Waypoint not found';
        when(mockBackendApiService.updateWaypoint(testWaypoint))
            .thenThrow(Exception(originalError));

        // Act & Assert
        try {
          await waypointRepository.updateWaypoint(testWaypoint);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e.toString(), contains('Fehler beim Aktualisieren des Wegpunkts'));
          expect(e.toString(), contains(originalError));
        }

        verify(mockBackendApiService.updateWaypoint(testWaypoint)).called(1);
      });

      test('should handle updating visited status', () async {
        // Arrange
        const visitedWaypoint = Waypoint(
          id: 2,
          hikeId: 1,
          name: 'Visited Point',
          description: 'Now visited',
          latitude: 47.0,
          longitude: 8.0,
          isVisited: true,
        );

        when(mockBackendApiService.updateWaypoint(visitedWaypoint))
            .thenAnswer((_) async => {});

        // Act & Assert
        await waypointRepository.updateWaypoint(visitedWaypoint);

        verify(mockBackendApiService.updateWaypoint(visitedWaypoint)).called(1);
      });
    });

    group('deleteWaypoint', () {
      const testWaypointId = 1;
      const testHikeId = 10;

      test('should delete waypoint successfully', () async {
        // Arrange
        when(mockBackendApiService.deleteWaypoint(testWaypointId, testHikeId))
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await waypointRepository.deleteWaypoint(testWaypointId, testHikeId);

        verify(mockBackendApiService.deleteWaypoint(testWaypointId, testHikeId)).called(1);
      });

      test('should throw custom exception when backend service fails', () async {
        // Arrange
        const originalError = 'Foreign key constraint violation';
        when(mockBackendApiService.deleteWaypoint(testWaypointId, testHikeId))
            .thenThrow(Exception(originalError));

        // Act & Assert
        try {
          await waypointRepository.deleteWaypoint(testWaypointId, testHikeId);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e.toString(), contains('Fehler beim Löschen des Wegpunkts'));
          expect(e.toString(), contains(originalError));
        }

        verify(mockBackendApiService.deleteWaypoint(testWaypointId, testHikeId)).called(1);
      });

      test('should handle deleting non-existent waypoint', () async {
        // Arrange
        const nonExistentId = 999;
        when(mockBackendApiService.deleteWaypoint(nonExistentId, testHikeId))
            .thenThrow(Exception('Waypoint not found'));

        // Act & Assert
        try {
          await waypointRepository.deleteWaypoint(nonExistentId, testHikeId);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e.toString(), contains('Fehler beim Löschen des Wegpunkts'));
          expect(e.toString(), contains('Waypoint not found'));
        }

        verify(mockBackendApiService.deleteWaypoint(nonExistentId, testHikeId)).called(1);
      });

      test('should handle different waypoint and hike ID combinations', () async {
        // Arrange
        const combinations = [
          [1, 10],
          [2, 20],
          [3, 30],
        ];

        for (final combo in combinations) {
          when(mockBackendApiService.deleteWaypoint(combo[0], combo[1]))
              .thenAnswer((_) async => {});
        }

        // Act & Assert
        for (final combo in combinations) {
          await waypointRepository.deleteWaypoint(combo[0], combo[1]);
          verify(mockBackendApiService.deleteWaypoint(combo[0], combo[1])).called(1);
        }
      });
    });

    group('Error Handling and Logging', () {
      test('should wrap all exceptions with German error messages', () async {
        // Test all methods wrap exceptions appropriately
        const hikeId = 1;
        const waypointId = 1;
        const waypoint = Waypoint(
          id: waypointId,
          hikeId: hikeId,
          name: 'Test',
          description: 'Test',
          latitude: 47.0,
          longitude: 8.0,
        );

        // Setup all methods to throw
        when(mockBackendApiService.getWaypointsForHike(hikeId))
            .thenThrow(Exception('Test error'));
        when(mockBackendApiService.addWaypoint(waypoint, hikeId))
            .thenThrow(Exception('Test error'));
        when(mockBackendApiService.updateWaypoint(waypoint))
            .thenThrow(Exception('Test error'));
        when(mockBackendApiService.deleteWaypoint(waypointId, hikeId))
            .thenThrow(Exception('Test error'));

        // Test each method wraps the exception
        final methods = [
          () => waypointRepository.getWaypointsForHike(hikeId),
          () => waypointRepository.addWaypoint(waypoint, hikeId),
          () => waypointRepository.updateWaypoint(waypoint),
          () => waypointRepository.deleteWaypoint(waypointId, hikeId),
        ];

        for (final method in methods) {
          try {
            await method();
            fail('Expected exception was not thrown');
          } catch (e) {
            expect(e.toString(), contains('Fehler'));
            expect(e.toString(), contains('Test error'));
          }
        }
      });

      test('should preserve original error information', () async {
        // Arrange
        const originalError = 'Specific network timeout after 30 seconds';
        const hikeId = 1;
        
        when(mockBackendApiService.getWaypointsForHike(hikeId))
            .thenThrow(Exception(originalError));

        // Act & Assert
        try {
          await waypointRepository.getWaypointsForHike(hikeId);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e.toString(), contains(originalError));
          expect(e.toString(), contains('Fehler beim Abrufen der Wegpunkte für Wanderung $hikeId'));
        }
      });
    });

    group('Concurrent Operations', () {
      test('should handle multiple concurrent read operations', () async {
        // Arrange
        const hikeIds = [1, 2, 3, 4, 5];
        final waypointLists = hikeIds.map((id) => [
          Waypoint(id: id, hikeId: id, name: 'Point $id', description: 'Description $id', latitude: 47.0, longitude: 8.0),
        ]).toList();

        for (int i = 0; i < hikeIds.length; i++) {
          when(mockBackendApiService.getWaypointsForHike(hikeIds[i]))
              .thenAnswer((_) async => waypointLists[i]);
        }

        // Act
        final futures = hikeIds.map((id) => waypointRepository.getWaypointsForHike(id));
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, 5);
        for (int i = 0; i < results.length; i++) {
          expect(results[i][0].name, 'Point ${hikeIds[i]}');
          verify(mockBackendApiService.getWaypointsForHike(hikeIds[i])).called(1);
        }
      });

      test('should handle mixed concurrent operations', () async {
        // Arrange
        const hikeId = 1;
        const waypoint = Waypoint(
          id: 1,
          hikeId: hikeId,
          name: 'Concurrent Point',
          description: 'Test concurrent ops',
          latitude: 47.0,
          longitude: 8.0,
        );

        when(mockBackendApiService.getWaypointsForHike(hikeId))
            .thenAnswer((_) async => [waypoint]);
        when(mockBackendApiService.addWaypoint(waypoint, hikeId))
            .thenAnswer((_) async => {});
        when(mockBackendApiService.updateWaypoint(waypoint))
            .thenAnswer((_) async => {});

        // Act
        final futures = [
          waypointRepository.getWaypointsForHike(hikeId),
          waypointRepository.addWaypoint(waypoint, hikeId).then((_) => <Waypoint>[]),
          waypointRepository.updateWaypoint(waypoint).then((_) => <Waypoint>[]),
        ];

        final results = await Future.wait(futures);

        // Assert
        expect(results[0], isA<List<Waypoint>>());
        expect(results[0].length, 1);
        
        verify(mockBackendApiService.getWaypointsForHike(hikeId)).called(1);
        verify(mockBackendApiService.addWaypoint(waypoint, hikeId)).called(1);
        verify(mockBackendApiService.updateWaypoint(waypoint)).called(1);
      });
    });
  });
}