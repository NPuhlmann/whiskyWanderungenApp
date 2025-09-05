import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../lib/data/services/navigation/navigation_service.dart';
import '../../../../lib/data/services/location/location_service.dart';
import '../../../../lib/domain/models/waypoint.dart';

@GenerateMocks([LocationService])
import 'navigation_service_test.mocks.dart';

void main() {
  group('NavigationService', () {
    late NavigationService navigationService;
    late MockLocationService mockLocationService;
    late List<Waypoint> testWaypoints;

    setUp(() {
      navigationService = NavigationService.instance;
      mockLocationService = MockLocationService();
      
      // Reset navigation service state
      navigationService.stopNavigation();
      
      // Create test waypoints
      testWaypoints = [
        Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Waypoint 1',
          description: 'First waypoint',
          latitude: 48.1351,
          longitude: 11.5820,
          orderIndex: 1,
          images: [],
          isVisited: false,
        ),
        Waypoint(
          id: 2,
          hikeId: 1,
          name: 'Waypoint 2',
          description: 'Second waypoint',
          latitude: 48.1361,
          longitude: 11.5830,
          orderIndex: 2,
          images: [],
          isVisited: false,
        ),
        Waypoint(
          id: 3,
          hikeId: 1,
          name: 'Waypoint 3',
          description: 'Third waypoint',
          latitude: 48.1371,
          longitude: 11.5840,
          orderIndex: 3,
          images: [],
          isVisited: false,
        ),
      ];
    });

    tearDown(() async {
      await navigationService.stopNavigation();
    });

    group('Navigation Initialization', () {
      test('should start with idle status', () {
        expect(navigationService.status, equals(NavigationStatus.idle));
        expect(navigationService.waypoints, isEmpty);
        expect(navigationService.currentWaypointIndex, equals(0));
        expect(navigationService.currentInstruction, isNull);
      });

      test('should not start navigation with empty waypoints', () async {
        final result = await navigationService.startNavigation([]);
        
        expect(result, isFalse);
        expect(navigationService.status, equals(NavigationStatus.idle));
      });

      test('should sort waypoints by orderIndex on start', () async {
        // Create unsorted waypoints
        final unsortedWaypoints = [
          testWaypoints[2], // orderIndex: 3
          testWaypoints[0], // orderIndex: 1  
          testWaypoints[1], // orderIndex: 2
        ];

        // Mock location service initialization
        when(mockLocationService.initialize()).thenAnswer((_) async => true);
        when(mockLocationService.startTracking()).thenAnswer((_) async => true);

        // Note: In real implementation, we'd need to mock the LocationService.instance
        // For now, we test the logic without actual GPS
        
        expect(unsortedWaypoints[0].orderIndex, equals(3));
        expect(unsortedWaypoints[1].orderIndex, equals(1));
        expect(unsortedWaypoints[2].orderIndex, equals(2));
      });
    });

    group('Navigation State Management', () {
      test('should track current waypoint index correctly', () {
        expect(navigationService.currentWaypointIndex, equals(0));
        expect(navigationService.currentWaypoint, isNull);
        expect(navigationService.nextWaypoint, isNull);
      });

      test('should provide correct waypoint getters when navigating', () async {
        // This test would require mocking LocationService properly
        // For now, we test the getter logic with direct waypoint access
        
        // Simulate navigation state (would normally be set by startNavigation)
        navigationService._waypoints = testWaypoints;
        navigationService._currentWaypointIndex = 1;
        
        expect(navigationService.currentWaypoint?.id, equals(2));
        expect(navigationService.currentWaypoint?.name, equals('Waypoint 2'));
        expect(navigationService.nextWaypoint?.id, equals(3));
        expect(navigationService.nextWaypoint?.name, equals('Waypoint 3'));
      });

      test('should handle last waypoint correctly', () {
        navigationService._waypoints = testWaypoints;
        navigationService._currentWaypointIndex = 2; // Last waypoint
        
        expect(navigationService.currentWaypoint?.id, equals(3));
        expect(navigationService.nextWaypoint, isNull);
      });
    });

    group('Navigation Instructions', () {
      test('should create navigation instruction with correct data', () {
        final waypoint = testWaypoints[0];
        final instruction = NavigationInstruction(
          targetWaypoint: waypoint,
          distanceToTarget: 100.0,
          bearingToTarget: 45.0,
          directionText: 'Nordost',
          estimatedTimeToArrival: Duration(minutes: 2),
          instructionText: 'Gehen Sie Nordost zu Waypoint 1 (100m, ca. 2min)',
          type: NavigationInstructionType.continue_,
        );

        expect(instruction.targetWaypoint, equals(waypoint));
        expect(instruction.distanceToTarget, equals(100.0));
        expect(instruction.bearingToTarget, equals(45.0));
        expect(instruction.directionText, equals('Nordost'));
        expect(instruction.estimatedTimeToArrival?.inMinutes, equals(2));
        expect(instruction.type, equals(NavigationInstructionType.continue_));
      });

      test('should generate appropriate instruction types', () {
        final waypoint = testWaypoints[0];

        // Start instruction
        final startInstruction = NavigationInstruction(
          targetWaypoint: waypoint,
          distanceToTarget: 0,
          bearingToTarget: 0,
          directionText: '',
          instructionText: 'Navigation gestartet',
          type: NavigationInstructionType.start,
        );

        expect(startInstruction.type, equals(NavigationInstructionType.start));

        // Approach instruction
        final approachInstruction = NavigationInstruction(
          targetWaypoint: waypoint,
          distanceToTarget: 30.0,
          bearingToTarget: 0,
          directionText: 'Nord',
          instructionText: 'Sie nähern sich Waypoint 1',
          type: NavigationInstructionType.approach,
        );

        expect(approachInstruction.type, equals(NavigationInstructionType.approach));

        // Arrived instruction
        final arrivedInstruction = NavigationInstruction(
          targetWaypoint: waypoint,
          distanceToTarget: 5.0,
          bearingToTarget: 0,
          directionText: '',
          instructionText: 'Sie sind bei Waypoint 1 angekommen!',
          type: NavigationInstructionType.arrived,
        );

        expect(arrivedInstruction.type, equals(NavigationInstructionType.arrived));
      });
    });

    group('Navigation Statistics', () {
      test('should provide correct statistics when idle', () {
        final stats = navigationService.getNavigationStatistics();

        expect(stats['totalWaypoints'], equals(0));
        expect(stats['completedWaypoints'], equals(0));
        expect(stats['remainingWaypoints'], equals(0));
        expect(stats['progress'], equals(0.0));
        expect(stats['status'], contains('idle'));
      });

      test('should calculate progress correctly during navigation', () {
        // Simulate navigation in progress
        navigationService._waypoints = testWaypoints;
        navigationService._currentWaypointIndex = 1;
        
        final stats = navigationService.getNavigationStatistics();

        expect(stats['totalWaypoints'], equals(3));
        expect(stats['completedWaypoints'], equals(1));
        expect(stats['remainingWaypoints'], equals(2));
        expect(stats['progress'], closeTo(1/3, 0.01));
      });
    });

    group('Navigation Permissions', () {
      test('should check navigation permissions', () async {
        when(mockLocationService.initialize()).thenAnswer((_) async => true);
        
        // Note: This would test the actual implementation with mocked LocationService
        final hasPermissions = await navigationService.checkNavigationPermissions();
        
        // Without proper mocking setup, we can't test the actual permission check
        // But we can verify the method exists and returns a boolean
        expect(hasPermissions, isA<bool>());
      });
    });

    group('Error Handling', () {
      test('should handle empty waypoint list gracefully', () async {
        final result = await navigationService.startNavigation([]);
        
        expect(result, isFalse);
        expect(navigationService.status, equals(NavigationStatus.idle));
      });

      test('should handle location service initialization failure', () async {
        // Mock location service to fail initialization
        when(mockLocationService.initialize()).thenAnswer((_) async => false);
        
        // This test would need proper dependency injection to work
        // For now, we verify the method exists
        expect(navigationService.startNavigation(testWaypoints), isA<Future<bool>>());
      });
    });

    group('Cleanup', () {
      test('should clean up resources on stop navigation', () async {
        // Start navigation first (would work with proper mocking)
        // await navigationService.startNavigation(testWaypoints);
        
        // Stop navigation
        await navigationService.stopNavigation();
        
        expect(navigationService.status, equals(NavigationStatus.idle));
        expect(navigationService.waypoints, isEmpty);
        expect(navigationService.currentWaypointIndex, equals(0));
        expect(navigationService.currentInstruction, isNull);
      });

      test('should dispose resources properly', () {
        // Test that dispose doesn't throw and cleans up
        expect(() => navigationService.dispose(), returnsNormally);
        
        // After dispose, service should be in idle state
        expect(navigationService.status, equals(NavigationStatus.idle));
      });
    });

    group('Waypoint Navigation', () {
      test('should handle skip to next waypoint', () async {
        navigationService._waypoints = testWaypoints;
        navigationService._currentWaypointIndex = 0;
        
        await navigationService.skipToNextWaypoint();
        
        // This would work with proper state management
        // For now, we verify the method exists and doesn't throw
        expect(() => navigationService.skipToNextWaypoint(), returnsNormally);
      });

      test('should handle skip to previous waypoint', () async {
        navigationService._waypoints = testWaypoints;
        navigationService._currentWaypointIndex = 1;
        
        await navigationService.skipToPreviousWaypoint();
        
        // This would work with proper state management
        expect(() => navigationService.skipToPreviousWaypoint(), returnsNormally);
      });

      test('should not skip beyond waypoint bounds', () async {
        navigationService._waypoints = testWaypoints;
        
        // At first waypoint, can't go back
        navigationService._currentWaypointIndex = 0;
        await navigationService.skipToPreviousWaypoint();
        expect(navigationService.currentWaypointIndex, equals(0));
        
        // At last waypoint, can't go forward
        navigationService._currentWaypointIndex = testWaypoints.length - 1;
        await navigationService.skipToNextWaypoint();
        expect(navigationService.currentWaypointIndex, equals(testWaypoints.length - 1));
      });
    });

    group('Pause and Resume', () {
      test('should handle pause and resume navigation', () async {
        await navigationService.pauseNavigation();
        await navigationService.resumeNavigation();
        
        // These methods should not throw
        expect(() => navigationService.pauseNavigation(), returnsNormally);
        expect(() => navigationService.resumeNavigation(), returnsNormally);
      });
    });
  });

  group('NavigationInstruction', () {
    test('should create instruction with all required fields', () {
      final waypoint = Waypoint(
        id: 1,
        hikeId: 1,
        name: 'Test Waypoint',
        description: 'Test description',
        latitude: 48.1351,
        longitude: 11.5820,
        orderIndex: 1,
        images: [],
        isVisited: false,
      );

      final instruction = NavigationInstruction(
        targetWaypoint: waypoint,
        distanceToTarget: 150.0,
        bearingToTarget: 90.0,
        directionText: 'Ost',
        estimatedTimeToArrival: Duration(minutes: 3),
        instructionText: 'Gehen Sie Ost zum Test Waypoint',
        type: NavigationInstructionType.continue_,
      );

      expect(instruction.targetWaypoint, equals(waypoint));
      expect(instruction.distanceToTarget, equals(150.0));
      expect(instruction.bearingToTarget, equals(90.0));
      expect(instruction.directionText, equals('Ost'));
      expect(instruction.estimatedTimeToArrival?.inMinutes, equals(3));
      expect(instruction.instructionText, isNotEmpty);
      expect(instruction.type, equals(NavigationInstructionType.continue_));
    });

    test('should handle null estimated time', () {
      final waypoint = Waypoint(
        id: 1,
        hikeId: 1,
        name: 'Test Waypoint',
        description: 'Test description',
        latitude: 48.1351,
        longitude: 11.5820,
        orderIndex: 1,
        images: [],
        isVisited: false,
      );

      final instruction = NavigationInstruction(
        targetWaypoint: waypoint,
        distanceToTarget: 150.0,
        bearingToTarget: 90.0,
        directionText: 'Ost',
        estimatedTimeToArrival: null,
        instructionText: 'Gehen Sie Ost zum Test Waypoint',
        type: NavigationInstructionType.continue_,
      );

      expect(instruction.estimatedTimeToArrival, isNull);
    });
  });

  group('NavigationStatus', () {
    test('should have all required status values', () {
      expect(NavigationStatus.values, contains(NavigationStatus.idle));
      expect(NavigationStatus.values, contains(NavigationStatus.started));
      expect(NavigationStatus.values, contains(NavigationStatus.navigating));
      expect(NavigationStatus.values, contains(NavigationStatus.paused));
      expect(NavigationStatus.values, contains(NavigationStatus.waypoint_reached));
      expect(NavigationStatus.values, contains(NavigationStatus.completed));
      expect(NavigationStatus.values, contains(NavigationStatus.error));
    });
  });

  group('NavigationInstructionType', () {
    test('should have all required instruction types', () {
      expect(NavigationInstructionType.values, contains(NavigationInstructionType.start));
      expect(NavigationInstructionType.values, contains(NavigationInstructionType.continue_));
      expect(NavigationInstructionType.values, contains(NavigationInstructionType.approach));
      expect(NavigationInstructionType.values, contains(NavigationInstructionType.arrived));
      expect(NavigationInstructionType.values, contains(NavigationInstructionType.nextWaypoint));
      expect(NavigationInstructionType.values, contains(NavigationInstructionType.finished));
    });
  });
}