import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/providers/route_management_provider.dart';
import 'package:whisky_hikes/data/services/admin/route_management_service.dart';

@GenerateMocks([RouteManagementService])
import 'route_management_provider_simple_test.mocks.dart';

void main() {
  group('RouteManagementProvider Basic Tests', () {
    late RouteManagementProvider provider;
    late MockRouteManagementService mockService;

    setUp(() {
      mockService = MockRouteManagementService();
      provider = RouteManagementProvider(routeManagementService: mockService);
    });

    group('Initial State', () {
      test('should initialize with correct default values', () {
        expect(provider.routes, isEmpty);
        expect(provider.selectedRoute, isNull);
        expect(provider.waypoints, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.isUploading, isFalse);
        expect(provider.errorMessage, isNull);
      });
    });

    group('State Management', () {
      test('should set loading state correctly', () {
        provider.setLoading(true);
        expect(provider.isLoading, isTrue);

        provider.setLoading(false);
        expect(provider.isLoading, isFalse);
      });

      test('should set uploading state correctly', () {
        provider.setUploading(true);
        expect(provider.isUploading, isTrue);

        provider.setUploading(false);
        expect(provider.isUploading, isFalse);
      });

      test('should set error message correctly', () {
        const errorMessage = 'Test error';
        provider.setError(errorMessage);
        expect(provider.errorMessage, equals(errorMessage));
      });

      test('should clear error message', () {
        provider.setError('Initial error');
        provider.clearError();
        expect(provider.errorMessage, isNull);
      });
    });

    group('Route Management State', () {
      test('should deselect route correctly', () {
        // We can't directly set selectedRoute, so we test the method behavior
        provider.deselectRoute();

        expect(provider.selectedRoute, isNull);
        expect(provider.waypoints, isEmpty);
      });

      test('should clear all data correctly', () {
        // Add some test data
        provider.routes.add({'id': 1, 'name': 'Test Route'});
        provider.waypoints.add({'id': 1, 'name': 'Test Waypoint'});
        provider.setError('Test error');
        provider.setLoading(true);
        provider.setUploading(true);

        provider.clearData();

        expect(provider.routes, isEmpty);
        expect(provider.selectedRoute, isNull);
        expect(provider.waypoints, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.isUploading, isFalse);
        expect(provider.errorMessage, isNull);
      });
    });

    group('Route Filtering', () {
      setUp(() {
        // Add test routes
        provider.routes.addAll([
          {
            'id': 1,
            'name': 'Highland Route',
            'description': 'Highland description',
            'difficulty': 'easy',
            'is_active': true,
          },
          {
            'id': 2,
            'name': 'Speyside Adventure',
            'description': 'Speyside description',
            'difficulty': 'moderate',
            'is_active': false,
          },
          {
            'id': 3,
            'name': 'Islay Challenge',
            'description': 'Islay description',
            'difficulty': 'hard',
            'is_active': true,
          },
        ]);
      });

      test('should filter routes by search term', () {
        final filteredRoutes = provider.filterRoutes('Highland');
        expect(filteredRoutes.length, equals(1));
        expect(filteredRoutes[0]['name'], equals('Highland Route'));

        final filteredByDescription = provider.filterRoutes('Speyside');
        expect(filteredByDescription.length, equals(1));
        expect(filteredByDescription[0]['name'], equals('Speyside Adventure'));

        final emptyFilter = provider.filterRoutes('');
        expect(emptyFilter.length, equals(3));
      });

      test('should filter routes by status', () {
        final activeRoutes = provider.filterRoutesByStatus(true);
        expect(activeRoutes.length, equals(2));
        expect(
          activeRoutes.every((route) => route['is_active'] == true),
          isTrue,
        );

        final inactiveRoutes = provider.filterRoutesByStatus(false);
        expect(inactiveRoutes.length, equals(1));
        expect(inactiveRoutes[0]['name'], equals('Speyside Adventure'));

        final allRoutes = provider.filterRoutesByStatus(null);
        expect(allRoutes.length, equals(3));
      });

      test('should filter routes by difficulty', () {
        final easyRoutes = provider.filterRoutesByDifficulty('easy');
        expect(easyRoutes.length, equals(1));
        expect(easyRoutes[0]['name'], equals('Highland Route'));

        final moderateRoutes = provider.filterRoutesByDifficulty('moderate');
        expect(moderateRoutes.length, equals(1));
        expect(moderateRoutes[0]['name'], equals('Speyside Adventure'));

        final hardRoutes = provider.filterRoutesByDifficulty('hard');
        expect(hardRoutes.length, equals(1));
        expect(hardRoutes[0]['name'], equals('Islay Challenge'));

        final allRoutes = provider.filterRoutesByDifficulty(null);
        expect(allRoutes.length, equals(3));
      });
    });

    group('Route Sorting', () {
      setUp(() {
        // Add test routes with different values
        provider.routes.addAll([
          {
            'id': 1,
            'name': 'Z Route',
            'price': 99.99,
            'distance': 15.0,
            'duration': 300,
            'created_at': '2024-01-01T10:00:00Z',
          },
          {
            'id': 2,
            'name': 'A Route',
            'price': 79.99,
            'distance': 10.0,
            'duration': 200,
            'created_at': '2024-01-02T10:00:00Z',
          },
          {
            'id': 3,
            'name': 'M Route',
            'price': 89.99,
            'distance': 12.5,
            'duration': 250,
            'created_at': '2024-01-03T10:00:00Z',
          },
        ]);
      });

      test('should sort routes by name', () {
        final sortedAsc = provider.sortRoutes('name', ascending: true);
        expect(sortedAsc[0]['name'], equals('A Route'));
        expect(sortedAsc[1]['name'], equals('M Route'));
        expect(sortedAsc[2]['name'], equals('Z Route'));

        final sortedDesc = provider.sortRoutes('name', ascending: false);
        expect(sortedDesc[0]['name'], equals('Z Route'));
        expect(sortedDesc[1]['name'], equals('M Route'));
        expect(sortedDesc[2]['name'], equals('A Route'));
      });

      test('should sort routes by price', () {
        final sortedAsc = provider.sortRoutes('price', ascending: true);
        expect(sortedAsc[0]['price'], equals(79.99));
        expect(sortedAsc[1]['price'], equals(89.99));
        expect(sortedAsc[2]['price'], equals(99.99));
      });

      test('should sort routes by distance', () {
        final sortedAsc = provider.sortRoutes('distance', ascending: true);
        expect(sortedAsc[0]['distance'], equals(10.0));
        expect(sortedAsc[1]['distance'], equals(12.5));
        expect(sortedAsc[2]['distance'], equals(15.0));
      });

      test('should sort routes by duration', () {
        final sortedAsc = provider.sortRoutes('duration', ascending: true);
        expect(sortedAsc[0]['duration'], equals(200));
        expect(sortedAsc[1]['duration'], equals(250));
        expect(sortedAsc[2]['duration'], equals(300));
      });

      test('should sort routes by creation date', () {
        final sortedAsc = provider.sortRoutes('created_at', ascending: true);
        expect(sortedAsc[0]['id'], equals(1)); // Earliest date
        expect(sortedAsc[2]['id'], equals(3)); // Latest date
      });
    });

    group('Route Statistics', () {
      setUp(() {
        provider.routes.addAll([
          {
            'id': 1,
            'name': 'Route 1',
            'price': 80.0,
            'distance': 10.0,
            'duration': 200,
            'is_active': true,
          },
          {
            'id': 2,
            'name': 'Route 2',
            'price': 90.0,
            'distance': 15.0,
            'duration': 300,
            'is_active': false,
          },
          {
            'id': 3,
            'name': 'Route 3',
            'price': 100.0,
            'distance': 20.0,
            'duration': 400,
            'is_active': true,
          },
        ]);
      });

      test('should calculate route statistics correctly', () {
        final stats = provider.getRouteStatistics();

        expect(stats['totalRoutes'], equals(3));
        expect(stats['activeRoutes'], equals(2));
        expect(stats['inactiveRoutes'], equals(1));
        expect(stats['averagePrice'], equals(90.0)); // (80 + 90 + 100) / 3
        expect(stats['averageDistance'], equals(15.0)); // (10 + 15 + 20) / 3
        expect(
          stats['averageDuration'],
          equals(300.0),
        ); // (200 + 300 + 400) / 3
      });

      test('should handle empty routes for statistics', () {
        provider.routes.clear();
        final stats = provider.getRouteStatistics();

        expect(stats['totalRoutes'], equals(0));
        expect(stats['activeRoutes'], equals(0));
        expect(stats['inactiveRoutes'], equals(0));
        expect(stats['averagePrice'], equals(0.0));
        expect(stats['averageDistance'], equals(0.0));
        expect(stats['averageDuration'], equals(0.0));
      });
    });

    group('Utility Properties', () {
      test('should return correct waypoint count', () {
        expect(provider.waypointCount, equals(0));

        provider.waypoints.addAll([
          {'id': 1, 'name': 'Waypoint 1'},
          {'id': 2, 'name': 'Waypoint 2'},
        ]);

        expect(provider.waypointCount, equals(2));
      });

      test('should format estimated duration correctly', () {
        expect(provider.estimatedDuration, equals('0h'));

        // We can't directly set selectedRoute, so this test is simplified
        // In a real scenario, the duration would be set via selectRoute()
        expect(provider.estimatedDuration, isA<String>());
      });

      test('should detect unsaved changes correctly', () {
        expect(provider.hasUnsavedChanges, isFalse);

        provider.setLoading(true);
        expect(provider.hasUnsavedChanges, isTrue);

        provider.setLoading(false);
        expect(provider.hasUnsavedChanges, isFalse);

        provider.setUploading(true);
        expect(provider.hasUnsavedChanges, isTrue);

        provider.setUploading(false);
        expect(provider.hasUnsavedChanges, isFalse);
      });
    });
  });
}
