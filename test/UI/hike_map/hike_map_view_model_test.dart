import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/hike_map/hike_map_view_model.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('HikeMapViewModel Tests', () {
    late HikeMapViewModel viewModel;
    late MockWaypointRepository mockWaypointRepository;
    const testHikeId = 1;

    setUp(() {
      mockWaypointRepository = MockWaypointRepository();
      viewModel = HikeMapViewModel(
        hikeId: testHikeId,
        waypointRepository: mockWaypointRepository,
      );
    });

    group('Initialization', () {
      test('should initialize with correct default values', () {
        expect(viewModel.hikeId, testHikeId);
        expect(viewModel.waypoints, isEmpty);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNull);
      });

      test('should provide access to repositories', () {
        expect(viewModel.waypointRepository, equals(mockWaypointRepository));
      });
    });

    group('loadWaypoints', () {
      test('should load waypoints successfully with distinct coordinates', () async {
        // Arrange
        final testWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Start Point',
            description: 'Beginning',
            latitude: 47.3769,
            longitude: 8.5417,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'Mid Point',
            description: 'Middle',
            latitude: 47.3800,
            longitude: 8.5500,
          ),
          const Waypoint(
            id: 3,
            hikeId: testHikeId,
            name: 'End Point',
            description: 'End',
            latitude: 47.3850,
            longitude: 8.5600,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => testWaypoints);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints, equals(testWaypoints));
        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNull);
        verify(mockWaypointRepository.getWaypointsForHike(testHikeId)).called(1);
      });

      test('should generate test waypoints when no waypoints exist', () async {
        // Arrange
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => []);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints.length, 5); // Should generate 5 test waypoints
        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNull);
        
        // Verify test waypoints have different coordinates
        final firstWaypoint = viewModel.waypoints.first;
        final lastWaypoint = viewModel.waypoints.last;
        expect(firstWaypoint.latitude, isNot(equals(lastWaypoint.latitude)));
        expect(firstWaypoint.longitude, isNot(equals(lastWaypoint.longitude)));
      });

      test('should generate test waypoints when coordinates overlap', () async {
        // Arrange - all waypoints at same location (overlapping coordinates)
        final overlappingWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Point 1',
            description: 'First',
            latitude: 47.3769,
            longitude: 8.5417,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'Point 2',
            description: 'Second',
            latitude: 47.3769, // Same latitude
            longitude: 8.5417, // Same longitude
          ),
          const Waypoint(
            id: 3,
            hikeId: testHikeId,
            name: 'Point 3',
            description: 'Third',
            latitude: 47.3769, // Same latitude
            longitude: 8.5417, // Same longitude
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => overlappingWaypoints);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints.length, 5); // Should generate test waypoints
        expect(viewModel.isLoading, false);
        expect(viewModel.error, isNull);
        
        // Verify generated waypoints use original names but different coordinates
        expect(viewModel.waypoints[0].name, 'Point 1');
        expect(viewModel.waypoints[1].name, 'Point 2');
        expect(viewModel.waypoints[2].name, 'Point 3');
        
        // But coordinates should be different
        expect(viewModel.waypoints[0].latitude, isNot(equals(47.3769)));
        expect(viewModel.waypoints[1].latitude, isNot(equals(47.3769)));
      });

      test('should preserve original waypoint data when generating test coordinates', () async {
        // Arrange
        final originalWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Original Point',
            description: 'Original description',
            latitude: 47.3769,
            longitude: 8.5417,
            images: ['image1.jpg', 'image2.jpg'],
            isVisited: true,
            orderIndex: 5,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => originalWaypoints);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints.length, 5);
        final firstWaypoint = viewModel.waypoints[0];
        
        // Original data should be preserved
        expect(firstWaypoint.id, 1);
        expect(firstWaypoint.name, 'Original Point');
        expect(firstWaypoint.description, 'Original description');
        expect(firstWaypoint.images, ['image1.jpg', 'image2.jpg']);
        expect(firstWaypoint.isVisited, true);
        expect(firstWaypoint.orderIndex, 5);
        
        // But coordinates should be different
        expect(firstWaypoint.latitude, isNot(equals(47.3769)));
        expect(firstWaypoint.longitude, isNot(equals(8.5417)));
      });

      test('should handle repository errors', () async {
        // Arrange
        const errorMessage = 'Database connection failed';
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenThrow(Exception(errorMessage));

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints, isEmpty);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, contains(errorMessage));
      });

      test('should set loading state correctly during operation', () async {
        // Arrange
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async {
              expect(viewModel.isLoading, true); // Should be loading during call
              return [];
            });

        expect(viewModel.isLoading, false); // Initially false

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.isLoading, false); // Should be false after completion
      });

      test('should clear previous error when loading succeeds', () async {
        // Arrange - Set initial error state
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenThrow(Exception('Initial error'));
        await viewModel.loadWaypoints();
        expect(viewModel.error, isNotNull);

        // Now make it succeed
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => []);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.error, isNull); // Error should be cleared
      });
    });

    group('toggleWaypointVisited', () {
      setUp(() async {
        // Setup with some waypoints first
        final waypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Test Point',
            description: 'Test',
            latitude: 47.3769,
            longitude: 8.5417,
            isVisited: false,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'Another Point',
            description: 'Another',
            latitude: 47.3800,
            longitude: 8.5500,
            isVisited: true,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => waypoints);
        await viewModel.loadWaypoints();
      });

      test('should toggle waypoint visited status from false to true', () async {
        // Arrange
        final waypoint = viewModel.waypoints[0];
        expect(waypoint.isVisited, false);

        // Act
        await viewModel.toggleWaypointVisited(waypoint);

        // Assert
        final updatedWaypoint = viewModel.waypoints[0];
        expect(updatedWaypoint.isVisited, true);
        expect(updatedWaypoint.id, waypoint.id);
        expect(updatedWaypoint.name, waypoint.name);
        expect(updatedWaypoint.description, waypoint.description);
      });

      test('should toggle waypoint visited status from true to false', () async {
        // Arrange
        final waypoint = viewModel.waypoints[1];
        expect(waypoint.isVisited, true);

        // Act
        await viewModel.toggleWaypointVisited(waypoint);

        // Assert
        final updatedWaypoint = viewModel.waypoints[1];
        expect(updatedWaypoint.isVisited, false);
      });

      test('should preserve all other waypoint properties when toggling', () async {
        // Arrange
        final originalWaypoint = viewModel.waypoints[0];

        // Act
        await viewModel.toggleWaypointVisited(originalWaypoint);

        // Assert
        final updatedWaypoint = viewModel.waypoints[0];
        expect(updatedWaypoint.id, originalWaypoint.id);
        expect(updatedWaypoint.hikeId, originalWaypoint.hikeId);
        expect(updatedWaypoint.name, originalWaypoint.name);
        expect(updatedWaypoint.description, originalWaypoint.description);
        expect(updatedWaypoint.latitude, originalWaypoint.latitude);
        expect(updatedWaypoint.longitude, originalWaypoint.longitude);
        expect(updatedWaypoint.orderIndex, originalWaypoint.orderIndex);
        expect(updatedWaypoint.images, originalWaypoint.images);
        expect(updatedWaypoint.isVisited, !originalWaypoint.isVisited); // Only this should change
      });

      test('should handle toggling non-existent waypoint gracefully', () async {
        // Arrange
        const nonExistentWaypoint = Waypoint(
          id: 999,
          hikeId: testHikeId,
          name: 'Non-existent',
          description: 'Does not exist',
          latitude: 0.0,
          longitude: 0.0,
        );

        // Act
        await viewModel.toggleWaypointVisited(nonExistentWaypoint);

        // Assert - should not change existing waypoints
        expect(viewModel.waypoints.length, 2);
        expect(viewModel.error, isNull);
      });

      test('should handle multiple rapid toggles correctly', () async {
        // Arrange
        final waypoint = viewModel.waypoints[0];
        final originalVisitedStatus = waypoint.isVisited;

        // Act - toggle multiple times rapidly
        await viewModel.toggleWaypointVisited(waypoint);
        await viewModel.toggleWaypointVisited(viewModel.waypoints[0]); // Use updated reference
        await viewModel.toggleWaypointVisited(viewModel.waypoints[0]);

        // Assert - should end up with opposite of original after odd number of toggles
        expect(viewModel.waypoints[0].isVisited, !originalVisitedStatus);
      });
    });

    group('getCurrentCenter', () {
      test('should return default center when no waypoints', () {
        // Act
        final center = viewModel.getCurrentCenter();

        // Assert
        expect(center.latitude, 51.1657);
        expect(center.longitude, 10.4515);
      });

      test('should calculate center from waypoints', () async {
        // Arrange
        final waypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Point 1',
            description: 'First',
            latitude: 47.0,
            longitude: 8.0,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'Point 2',
            description: 'Second',
            latitude: 48.0,
            longitude: 9.0,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => waypoints);
        await viewModel.loadWaypoints();

        // Act
        final center = viewModel.getCurrentCenter();

        // Assert
        expect(center.latitude, 47.5); // Average of 47.0 and 48.0
        expect(center.longitude, 8.5);  // Average of 8.0 and 9.0
      });

      test('should handle single waypoint', () async {
        // Arrange
        final waypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Single Point',
            description: 'Only one',
            latitude: 46.5,
            longitude: 7.5,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => waypoints);
        await viewModel.loadWaypoints();

        // Act
        final center = viewModel.getCurrentCenter();

        // Assert
        expect(center.latitude, 46.5);
        expect(center.longitude, 7.5);
      });

      test('should handle calculation errors gracefully', () async {
        // Arrange - Create waypoints that might cause calculation issues
        final problematicWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Point 1',
            description: 'First',
            latitude: double.infinity,
            longitude: 8.0,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => problematicWaypoints);
        await viewModel.loadWaypoints();

        // Act
        final center = viewModel.getCurrentCenter();

        // Assert - should return fallback coordinates
        expect(center.latitude, 51.1657);
        expect(center.longitude, 10.4515);
      });

      test('should calculate center correctly with many waypoints', () async {
        // Arrange
        final manyWaypoints = List.generate(100, (index) => Waypoint(
          id: index,
          hikeId: testHikeId,
          name: 'Point $index',
          description: 'Description $index',
          latitude: 47.0 + (index * 0.01), // Range from 47.0 to 47.99
          longitude: 8.0 + (index * 0.01),  // Range from 8.0 to 8.99
        ));

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => manyWaypoints);
        await viewModel.loadWaypoints();

        // Act
        final center = viewModel.getCurrentCenter();

        // Assert
        expect(center.latitude, closeTo(47.495, 0.01)); // Middle of range
        expect(center.longitude, closeTo(8.495, 0.01));  // Middle of range
      });
    });

    group('Coordinate Overlap Detection', () {
      test('should detect overlapping coordinates correctly', () async {
        // Arrange - waypoints with very similar coordinates (within threshold)
        final overlappingWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Point 1',
            description: 'First',
            latitude: 47.3769,
            longitude: 8.5417,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'Point 2',
            description: 'Second',
            latitude: 47.3769, // Exactly same
            longitude: 8.5417, // Exactly same
          ),
          const Waypoint(
            id: 3,
            hikeId: testHikeId,
            name: 'Point 3',
            description: 'Third',
            latitude: 47.37691, // Very slightly different
            longitude: 8.54171, // Very slightly different
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => overlappingWaypoints);

        // Act
        await viewModel.loadWaypoints();

        // Assert - should generate test waypoints due to overlap detection
        expect(viewModel.waypoints.length, 5); // Generated test waypoints
      });

      test('should not detect overlap with sufficiently different coordinates', () async {
        // Arrange - waypoints with significantly different coordinates
        final distinctWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Point 1',
            description: 'First',
            latitude: 47.0,
            longitude: 8.0,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'Point 2',
            description: 'Second',
            latitude: 48.0,
            longitude: 9.0,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => distinctWaypoints);

        // Act
        await viewModel.loadWaypoints();

        // Assert - should keep original waypoints
        expect(viewModel.waypoints, equals(distinctWaypoints));
      });

      test('should handle single waypoint as non-overlapping', () async {
        // Arrange
        final singleWaypoint = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Only Point',
            description: 'Single',
            latitude: 47.3769,
            longitude: 8.5417,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => singleWaypoint);

        // Act
        await viewModel.loadWaypoints();

        // Assert - should keep original single waypoint
        expect(viewModel.waypoints, equals(singleWaypoint));
      });
    });

    group('Test Waypoint Generation', () {
      test('should generate 5 test waypoints with unique coordinates', () async {
        // Arrange
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => []);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints.length, 5);
        
        // Check that all waypoints have different coordinates
        final coordinates = viewModel.waypoints
            .map((w) => '${w.latitude},${w.longitude}')
            .toSet();
        expect(coordinates.length, 5); // All unique
        
        // Check that waypoints have expected names
        expect(viewModel.waypoints[0].name, 'Wegpunkt 1');
        expect(viewModel.waypoints[4].name, 'Wegpunkt 5');
        
        // Check alternating visited status
        expect(viewModel.waypoints[0].isVisited, true);  // i % 2 == 0
        expect(viewModel.waypoints[1].isVisited, false); // i % 2 != 0
        expect(viewModel.waypoints[2].isVisited, true);  // i % 2 == 0
      });

      test('should generate test waypoints with correct base coordinates', () async {
        // Arrange
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => []);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        final baseLat = 51.1657;
        final baseLng = 10.4515;
        
        // Check that coordinates are based around German coordinates
        for (int i = 0; i < viewModel.waypoints.length; i++) {
          final waypoint = viewModel.waypoints[i];
          final expectedLatOffset = (i - 2) * 0.01;
          final expectedLngOffset = (i - 2) * 0.02;
          
          expect(waypoint.latitude, closeTo(baseLat + expectedLatOffset, 0.001));
          expect(waypoint.longitude, closeTo(baseLng + expectedLngOffset, 0.001));
        }
      });

      test('should assign correct hike ID to generated waypoints', () async {
        // Arrange
        const customHikeId = 42;
        final customViewModel = HikeMapViewModel(
          hikeId: customHikeId,
          waypointRepository: mockWaypointRepository,
        );

        when(mockWaypointRepository.getWaypointsForHike(customHikeId))
            .thenAnswer((_) async => []);

        // Act
        await customViewModel.loadWaypoints();

        // Assert
        for (final waypoint in customViewModel.waypoints) {
          expect(waypoint.hikeId, customHikeId);
        }
      });
    });

    group('Error Handling', () {
      test('should handle various error types', () async {
        // Arrange
        final errorTypes = [
          'Network timeout',
          'Database connection failed',
          'Permission denied',
          'Invalid hike ID',
        ];

        for (final error in errorTypes) {
          when(mockWaypointRepository.getWaypointsForHike(testHikeId))
              .thenThrow(Exception(error));

          // Act
          await viewModel.loadWaypoints();

          // Assert
          expect(viewModel.error, contains(error));
          expect(viewModel.isLoading, false);
          
          // Reset for next iteration
          reset(mockWaypointRepository);
        }
      });

      test('should maintain state consistency on errors', () async {
        // Arrange - load waypoints successfully first
        final waypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Valid Point',
            description: 'Valid',
            latitude: 47.0,
            longitude: 8.0,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => waypoints);
        await viewModel.loadWaypoints();
        
        expect(viewModel.waypoints, equals(waypoints));
        expect(viewModel.error, isNull);

        // Now cause an error
        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenThrow(Exception('Subsequent error'));

        // Act
        await viewModel.loadWaypoints();

        // Assert - waypoints should be cleared, error should be set
        expect(viewModel.waypoints, isEmpty);
        expect(viewModel.error, isNotNull);
        expect(viewModel.isLoading, false);
      });
    });

    group('Notification Behavior', () {
      test('should notify listeners during loadWaypoints', () async {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => []);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(notificationCount, greaterThanOrEqualTo(2)); // At least start and end notifications
      });

      test('should notify listeners when toggling waypoint visited', () async {
        // Arrange
        final waypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Test Point',
            description: 'Test',
            latitude: 47.3769,
            longitude: 8.5417,
            isVisited: false,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => waypoints);
        await viewModel.loadWaypoints();

        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        // Act
        await viewModel.toggleWaypointVisited(viewModel.waypoints[0]);

        // Assert
        expect(notificationCount, 1);
      });
    });

    group('Edge Cases', () {
      test('should handle extreme coordinate values', () async {
        // Arrange
        final extremeWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'North Pole',
            description: 'Extreme north',
            latitude: 90.0,
            longitude: 0.0,
          ),
          const Waypoint(
            id: 2,
            hikeId: testHikeId,
            name: 'South Pole',
            description: 'Extreme south',
            latitude: -90.0,
            longitude: 180.0,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => extremeWaypoints);

        // Act
        await viewModel.loadWaypoints();
        final center = viewModel.getCurrentCenter();

        // Assert
        expect(viewModel.waypoints, equals(extremeWaypoints));
        expect(center.latitude, 0.0); // Average of 90 and -90
        expect(center.longitude, 90.0); // Average of 0 and 180
      });

      test('should handle waypoints with zero coordinates', () async {
        // Arrange
        final zeroWaypoints = [
          const Waypoint(
            id: 1,
            hikeId: testHikeId,
            name: 'Zero Point',
            description: 'At origin',
            latitude: 0.0,
            longitude: 0.0,
          ),
        ];

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => zeroWaypoints);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints, equals(zeroWaypoints));
        final center = viewModel.getCurrentCenter();
        expect(center.latitude, 0.0);
        expect(center.longitude, 0.0);
      });

      test('should handle very large number of waypoints', () async {
        // Arrange
        final manyWaypoints = List.generate(1000, (index) => Waypoint(
          id: index,
          hikeId: testHikeId,
          name: 'Point $index',
          description: 'Description $index',
          latitude: 47.0 + (index * 0.001),
          longitude: 8.0 + (index * 0.001),
        ));

        when(mockWaypointRepository.getWaypointsForHike(testHikeId))
            .thenAnswer((_) async => manyWaypoints);

        // Act
        await viewModel.loadWaypoints();

        // Assert
        expect(viewModel.waypoints.length, 1000);
        expect(viewModel.error, isNull);
      });
    });
  });
}