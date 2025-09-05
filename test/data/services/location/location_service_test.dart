import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../lib/data/services/location/location_service.dart';
import '../../../../lib/domain/models/waypoint.dart';

// Mock generation for Geolocator static methods is complex
// For now, we'll test the business logic methods that don't rely on static calls

@GenerateMocks([])
class MockLocationService extends Mock implements LocationService {}

void main() {
  group('LocationService', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService.instance;
    });

    group('Distance and Bearing Calculations', () {
      test('should calculate distance between positions correctly', () {
        // Create test waypoint (Berlin)
        final waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Test Waypoint',
          description: 'Test Description',
          latitude: 52.5200, // Berlin
          longitude: 13.4050,
          orderIndex: 1,
          images: [],
          isVisited: false,
        );

        // Mock current position (Munich)
        final currentPosition = Position(
          longitude: 11.5820, // Munich
          latitude: 48.1351,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        // Set last known position
        locationService._lastKnownPosition = currentPosition;

        // Calculate distance
        final distance = locationService.calculateDistanceToWaypoint(waypoint);

        // Munich to Berlin is approximately 504 km
        expect(distance, isNotNull);
        expect(distance!, greaterThan(500000)); // > 500km
        expect(distance, lessThan(600000)); // < 600km
      });

      test('should return null distance when no current position', () {
        final waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Test Waypoint',
          description: 'Test Description',
          latitude: 52.5200,
          longitude: 13.4050,
          orderIndex: 1,
          images: [],
          isVisited: false,
        );

        // Clear position
        locationService._lastKnownPosition = null;

        final distance = locationService.calculateDistanceToWaypoint(waypoint);
        expect(distance, isNull);
      });

      test('should calculate bearing to waypoint correctly', () {
        final waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'North Waypoint',
          description: 'Test Description',
          latitude: 48.2351, // Slightly north of current position
          longitude: 11.5820, // Same longitude
          orderIndex: 1,
          images: [],
          isVisited: false,
        );

        final currentPosition = Position(
          longitude: 11.5820,
          latitude: 48.1351,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        locationService._lastKnownPosition = currentPosition;

        final bearing = locationService.calculateBearingToWaypoint(waypoint);

        expect(bearing, isNotNull);
        // Should be approximately 0 degrees (north)
        expect(bearing!.abs(), lessThan(5)); // Within 5 degrees of north
      });
    });

    group('Waypoint Reach Detection', () {
      test('should detect waypoint as reached when within radius', () {
        final waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Close Waypoint',
          description: 'Test Description',
          latitude: 48.1352, // Very close to current position
          longitude: 11.5821,
          orderIndex: 1,
          images: [],
          isVisited: false,
        );

        final currentPosition = Position(
          longitude: 11.5820,
          latitude: 48.1351,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        locationService._lastKnownPosition = currentPosition;

        final isReached = locationService.isWaypointReached(waypoint);
        expect(isReached, isTrue);
      });

      test('should not detect distant waypoint as reached', () {
        final waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Distant Waypoint',
          description: 'Test Description',
          latitude: 52.5200, // Berlin - very far
          longitude: 13.4050,
          orderIndex: 1,
          images: [],
          isVisited: false,
        );

        final currentPosition = Position(
          longitude: 11.5820, // Munich
          latitude: 48.1351,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        locationService._lastKnownPosition = currentPosition;

        final isReached = locationService.isWaypointReached(waypoint);
        expect(isReached, isFalse);
      });
    });

    group('Nearest Waypoint Finding', () {
      test('should find nearest waypoint from list', () {
        final waypoints = [
          Waypoint(
            id: 1,
            hikeId: 1,
            name: 'Far Waypoint',
            description: 'Test Description',
            latitude: 52.5200, // Berlin
            longitude: 13.4050,
            orderIndex: 1,
            images: [],
            isVisited: false,
          ),
          Waypoint(
            id: 2,
            hikeId: 1,
            name: 'Close Waypoint',
            description: 'Test Description',
            latitude: 48.1355, // Very close to Munich
            longitude: 11.5825,
            orderIndex: 2,
            images: [],
            isVisited: false,
          ),
          Waypoint(
            id: 3,
            hikeId: 1,
            name: 'Medium Waypoint',
            description: 'Test Description',
            latitude: 49.4521, // Nuremberg
            longitude: 11.0767,
            orderIndex: 3,
            images: [],
            isVisited: false,
          ),
        ];

        final currentPosition = Position(
          longitude: 11.5820, // Munich
          latitude: 48.1351,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        locationService._lastKnownPosition = currentPosition;

        final nearestWaypoint = locationService.findNearestWaypoint(waypoints);

        expect(nearestWaypoint, isNotNull);
        expect(nearestWaypoint!.id, equals(2)); // Should be the close waypoint
        expect(nearestWaypoint.name, equals('Close Waypoint'));
      });

      test('should return null when no waypoints provided', () {
        final currentPosition = Position(
          longitude: 11.5820,
          latitude: 48.1351,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        locationService._lastKnownPosition = currentPosition;

        final nearestWaypoint = locationService.findNearestWaypoint([]);
        expect(nearestWaypoint, isNull);
      });

      test('should return null when no current position', () {
        final waypoints = [
          Waypoint(
            id: 1,
            hikeId: 1,
            name: 'Test Waypoint',
            description: 'Test Description',
            latitude: 48.1351,
            longitude: 11.5820,
            orderIndex: 1,
            images: [],
            isVisited: false,
          ),
        ];

        locationService._lastKnownPosition = null;

        final nearestWaypoint = locationService.findNearestWaypoint(waypoints);
        expect(nearestWaypoint, isNull);
      });
    });

    group('ETA Calculation', () {
      test('should calculate reasonable ETA for waypoint', () {
        final waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Test Waypoint',
          description: 'Test Description',
          latitude: 48.1361, // ~1km north
          longitude: 11.5820,
          orderIndex: 1,
          images: [],
          isVisited: false,
        );

        final currentPosition = Position(
          longitude: 11.5820,
          latitude: 48.1351,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        locationService._lastKnownPosition = currentPosition;

        final eta = locationService.calculateEstimatedTimeToWaypoint(waypoint);

        expect(eta, isNotNull);
        // For ~1km at 4km/h walking speed, should be ~15 minutes
        expect(eta!.inMinutes, greaterThan(10));
        expect(eta.inMinutes, lessThan(25));
      });

      test('should return null ETA when no current position', () {
        final waypoint = Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Test Waypoint',
          description: 'Test Description',
          latitude: 48.1361,
          longitude: 11.5820,
          orderIndex: 1,
          images: [],
          isVisited: false,
        );

        locationService._lastKnownPosition = null;

        final eta = locationService.calculateEstimatedTimeToWaypoint(waypoint);
        expect(eta, isNull);
      });
    });

    group('Formatting Functions', () {
      test('should format bearing to direction text correctly', () {
        expect(locationService.bearingToDirectionText(0), equals('Nord'));
        expect(locationService.bearingToDirectionText(45), equals('Nordost'));
        expect(locationService.bearingToDirectionText(90), equals('Ost'));
        expect(locationService.bearingToDirectionText(135), equals('Südost'));
        expect(locationService.bearingToDirectionText(180), equals('Süd'));
        expect(locationService.bearingToDirectionText(225), equals('Südwest'));
        expect(locationService.bearingToDirectionText(270), equals('West'));
        expect(locationService.bearingToDirectionText(315), equals('Nordwest'));
        expect(locationService.bearingToDirectionText(360), equals('Nord'));
      });

      test('should format negative bearings correctly', () {
        expect(locationService.bearingToDirectionText(-45), equals('Nordwest'));
        expect(locationService.bearingToDirectionText(-90), equals('West'));
      });

      test('should format distance correctly', () {
        expect(locationService.formatDistance(500), equals('500m'));
        expect(locationService.formatDistance(1000), equals('1.0km'));
        expect(locationService.formatDistance(1500), equals('1.5km'));
        expect(locationService.formatDistance(12345), equals('12.3km'));
      });

      test('should format duration correctly', () {
        expect(locationService.formatDuration(Duration(seconds: 30)), equals('30s'));
        expect(locationService.formatDuration(Duration(minutes: 5)), equals('5min'));
        expect(locationService.formatDuration(Duration(minutes: 5, seconds: 30)), equals('5min'));
        expect(locationService.formatDuration(Duration(hours: 1, minutes: 30)), equals('1h 30min'));
        expect(locationService.formatDuration(Duration(hours: 2)), equals('2h 0min'));
      });
    });

    group('Service State', () {
      test('should initialize with correct default state', () {
        expect(locationService.lastKnownPosition, isNull);
        expect(locationService.isTracking, isFalse);
      });
    });
  });
}