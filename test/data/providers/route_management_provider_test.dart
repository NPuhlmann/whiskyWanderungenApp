import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/providers/route_management_provider.dart';
import 'package:whisky_hikes/data/services/admin/route_management_service.dart';

@GenerateMocks([RouteManagementService])
import 'route_management_provider_test.mocks.dart';

void main() {
  group('RouteManagementProvider Tests', () {
    late RouteManagementProvider provider;
    late MockRouteManagementService mockService;

    setUp(() {
      mockService = MockRouteManagementService();
      provider = RouteManagementProvider(routeManagementService: mockService);
    });

    group('State Management', () {
      test('should initialize with correct default values', () {
        // Assert
        expect(provider.routes, isEmpty);
        expect(provider.selectedRoute, isNull);
        expect(provider.waypoints, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.isUploading, isFalse);
        expect(provider.errorMessage, isNull);
      });

      test('should set loading state correctly', () {
        // Act
        provider.setLoading(true);

        // Assert
        expect(provider.isLoading, isTrue);
      });

      test('should set error message correctly', () {
        // Arrange
        const errorMessage = 'Something went wrong';

        // Act
        provider.setError(errorMessage);

        // Assert
        expect(provider.errorMessage, equals(errorMessage));
      });

      test('should clear error message', () {
        // Arrange
        provider.setError('Initial error');

        // Act
        provider.clearError();

        // Assert
        expect(provider.errorMessage, isNull);
      });
    });

    group('Route Management', () {
      test('should load routes successfully', () async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Route 1',
            'description': 'Description 1',
            'difficulty': 'easy',
            'price': 79.99,
            'is_active': true,
          },
          {
            'id': 124,
            'name': 'Route 2',
            'description': 'Description 2',
            'difficulty': 'moderate',
            'price': 89.99,
            'is_active': false,
          },
        ];

        when(mockService.getAllRoutesForAdmin())
            .thenAnswer((_) async => mockRoutes);

        // Act
        await provider.loadRoutes();

        // Assert
        expect(provider.routes.length, equals(2));
        expect(provider.routes[0]['name'], equals('Route 1'));
        expect(provider.routes[1]['name'], equals('Route 2'));
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        verify(mockService.getAllRoutesForAdmin()).called(1);
      });

      test('should handle load routes error', () async {
        // Arrange
        const errorMessage = 'Failed to load routes';
        when(mockService.getAllRoutesForAdmin())
            .thenThrow(Exception(errorMessage));

        // Act
        await provider.loadRoutes();

        // Assert
        expect(provider.routes, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, contains(errorMessage));
        verify(mockService.getAllRoutesForAdmin()).called(1);
      });

      test('should create route successfully', () async {
        // Arrange
        final routeData = {
          'name': 'New Route',
          'description': 'New Description',
          'difficulty': 'hard',
          'price': 99.99,
        };

        final createdRoute = {
          'id': 125,
          'name': 'New Route',
          'description': 'New Description',
          'difficulty': 'hard',
          'price': 99.99,
          'is_active': true,
        };

        when(mockService.createRoute(routeData))
            .thenAnswer((_) async => createdRoute);
        when(mockService.getAllRoutesForAdmin())
            .thenAnswer((_) async => [createdRoute]);

        // Act
        await provider.createRoute(routeData);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.routes.length, equals(1));
        expect(provider.routes[0]['id'], equals(125));
        verify(mockService.createRoute(routeData)).called(1);
        verify(mockService.getAllRoutesForAdmin()).called(1);
      });

      test('should handle create route error', () async {
        // Arrange
        final routeData = {
          'name': 'New Route',
          'description': 'New Description',
        };
        const errorMessage = 'Failed to create route';

        when(mockService.createRoute(routeData))
            .thenThrow(Exception(errorMessage));

        // Act
        await provider.createRoute(routeData);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, contains(errorMessage));
        verify(mockService.createRoute(routeData)).called(1);
        verifyNever(mockService.getAllRoutesForAdmin());
      });

      test('should update route successfully', () async {
        // Arrange
        const routeId = 123;
        final updateData = {
          'name': 'Updated Route',
          'price': 109.99,
        };

        final updatedRoute = {
          'id': 123,
          'name': 'Updated Route',
          'description': 'Original Description',
          'difficulty': 'moderate',
          'price': 109.99,
          'is_active': true,
        };

        when(mockService.updateRoute(routeId, updateData))
            .thenAnswer((_) async => updatedRoute);
        when(mockService.getAllRoutesForAdmin())
            .thenAnswer((_) async => [updatedRoute]);

        // Act
        await provider.updateRoute(routeId, updateData);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        verify(mockService.updateRoute(routeId, updateData)).called(1);
        verify(mockService.getAllRoutesForAdmin()).called(1);
      });

      test('should delete route successfully', () async {
        // Arrange
        const routeId = 123;

        // Set up initial state with a route
        provider.routes.add({
          'id': 123,
          'name': 'Route to Delete',
        });

        when(mockService.deleteRoute(routeId))
            .thenAnswer((_) async => {});
        when(mockService.getAllRoutesForAdmin())
            .thenAnswer((_) async => []);

        // Act
        await provider.deleteRoute(routeId);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.routes, isEmpty);
        verify(mockService.deleteRoute(routeId)).called(1);
        verify(mockService.getAllRoutesForAdmin()).called(1);
      });

      test('should select route and load waypoints', () async {
        // Arrange
        final route = {
          'id': 123,
          'name': 'Selected Route',
          'description': 'Route Description',
        };

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Waypoint 1',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
          {
            'waypoint_id': 457,
            'order_index': 2,
            'waypoints': {
              'id': 457,
              'name': 'Waypoint 2',
              'latitude': 52.5300,
              'longitude': 13.4150,
            }
          },
        ];

        when(mockService.getRouteWaypoints(123))
            .thenAnswer((_) async => mockWaypoints);

        // Act
        await provider.selectRoute(route);

        // Assert
        expect(provider.selectedRoute, equals(route));
        expect(provider.waypoints.length, equals(2));
        expect(provider.waypoints[0]['waypoints']['name'], equals('Waypoint 1'));
        expect(provider.waypoints[1]['waypoints']['name'], equals('Waypoint 2'));
        verify(mockService.getRouteWaypoints(123)).called(1);
      });
    });

    group('Waypoint Management', () {
      test('should add waypoint successfully', () async {
        // Arrange
        const routeId = 123;
        final waypointData = {
          'name': 'New Waypoint',
          'description': 'Waypoint Description',
          'latitude': 52.5200,
          'longitude': 13.4050,
          'order_index': 1,
        };

        final createdWaypoint = {
          'id': 456,
          'name': 'New Waypoint',
          'description': 'Waypoint Description',
          'latitude': 52.5200,
          'longitude': 13.4050,
        };

        when(mockService.addWaypointToRoute(routeId, waypointData))
            .thenAnswer((_) async => createdWaypoint);
        when(mockService.getRouteWaypoints(routeId))
            .thenAnswer((_) async => [
              {
                'waypoint_id': 456,
                'order_index': 1,
                'waypoints': createdWaypoint,
              }
            ]);

        // Set selected route
        provider.selectedRoute = {'id': routeId, 'name': 'Test Route'};

        // Act
        await provider.addWaypoint(routeId, waypointData);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.waypoints.length, equals(1));
        verify(mockService.addWaypointToRoute(routeId, waypointData)).called(1);
        verify(mockService.getRouteWaypoints(routeId)).called(1);
      });

      test('should reorder waypoints successfully', () async {
        // Arrange
        const routeId = 123;
        final newOrder = [
          {'waypointId': 457, 'orderIndex': 1},
          {'waypointId': 456, 'orderIndex': 2},
        ];

        when(mockService.updateWaypointOrder(routeId, newOrder))
            .thenAnswer((_) async => {});
        when(mockService.getRouteWaypoints(routeId))
            .thenAnswer((_) async => [
              {
                'waypoint_id': 457,
                'order_index': 1,
                'waypoints': {'id': 457, 'name': 'Waypoint 2'},
              },
              {
                'waypoint_id': 456,
                'order_index': 2,
                'waypoints': {'id': 456, 'name': 'Waypoint 1'},
              },
            ]);

        // Set selected route
        provider.selectedRoute = {'id': routeId, 'name': 'Test Route'};

        // Act
        await provider.reorderWaypoints(routeId, newOrder);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.waypoints.length, equals(2));
        expect(provider.waypoints[0]['waypoints']['id'], equals(457)); // Reordered
        expect(provider.waypoints[1]['waypoints']['id'], equals(456));
        verify(mockService.updateWaypointOrder(routeId, newOrder)).called(1);
        verify(mockService.getRouteWaypoints(routeId)).called(1);
      });

      test('should remove waypoint successfully', () async {
        // Arrange
        const routeId = 123;
        const waypointId = 456;

        when(mockService.removeWaypointFromRoute(routeId, waypointId))
            .thenAnswer((_) async => {});
        when(mockService.getRouteWaypoints(routeId))
            .thenAnswer((_) async => []); // Empty after removal

        // Set selected route and initial waypoints
        provider.selectedRoute = {'id': routeId, 'name': 'Test Route'};
        provider.waypoints.add({
          'waypoint_id': waypointId,
          'order_index': 1,
          'waypoints': {'id': waypointId, 'name': 'Waypoint to Remove'},
        });

        // Act
        await provider.removeWaypoint(routeId, waypointId);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.waypoints, isEmpty);
        verify(mockService.removeWaypointFromRoute(routeId, waypointId)).called(1);
        verify(mockService.getRouteWaypoints(routeId)).called(1);
      });
    });

    group('Image Management', () {
      test('should upload route image successfully', () async {
        // Arrange
        const routeId = 123;
        const fileName = 'route_image.jpg';
        final imageBytes = [1, 2, 3, 4, 5];
        const imageUrl = 'https://storage.supabase.co/route_images/route_123_image.jpg';

        when(mockService.uploadRouteImage(routeId, imageBytes, fileName))
            .thenAnswer((_) async => imageUrl);

        // Act
        final result = await provider.uploadRouteImage(routeId, imageBytes, fileName);

        // Assert
        expect(result, equals(imageUrl));
        expect(provider.isUploading, isFalse);
        expect(provider.errorMessage, isNull);
        verify(mockService.uploadRouteImage(routeId, imageBytes, fileName)).called(1);
      });

      test('should handle image upload error', () async {
        // Arrange
        const routeId = 123;
        const fileName = 'route_image.jpg';
        final imageBytes = [1, 2, 3, 4, 5];
        const errorMessage = 'Upload failed';

        when(mockService.uploadRouteImage(routeId, imageBytes, fileName))
            .thenThrow(Exception(errorMessage));

        // Act
        final result = await provider.uploadRouteImage(routeId, imageBytes, fileName);

        // Assert
        expect(result, isNull);
        expect(provider.isUploading, isFalse);
        expect(provider.errorMessage, contains(errorMessage));
        verify(mockService.uploadRouteImage(routeId, imageBytes, fileName)).called(1);
      });

      test('should delete route image successfully', () async {
        // Arrange
        const routeId = 123;
        const fileName = 'route_image.jpg';

        when(mockService.deleteRouteImage(routeId, fileName))
            .thenAnswer((_) async => {});

        // Act
        await provider.deleteRouteImage(routeId, fileName);

        // Assert
        expect(provider.errorMessage, isNull);
        verify(mockService.deleteRouteImage(routeId, fileName)).called(1);
      });
    });

    group('Loading States', () {
      test('should set loading state during route operations', () async {
        // Arrange
        when(mockService.getAllRoutesForAdmin())
            .thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = provider.loadRoutes();

        // Assert loading state is true during operation
        expect(provider.isLoading, isTrue);

        await future;

        // Assert loading state is false after completion
        expect(provider.isLoading, isFalse);
      });

      test('should set uploading state during image upload', () async {
        // Arrange
        const routeId = 123;
        const fileName = 'route_image.jpg';
        final imageBytes = [1, 2, 3, 4, 5];

        when(mockService.uploadRouteImage(routeId, imageBytes, fileName))
            .thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(Duration(milliseconds: 100));
          return 'image_url';
        });

        // Act
        final future = provider.uploadRouteImage(routeId, imageBytes, fileName);

        // Assert uploading state is true during operation
        expect(provider.isUploading, isTrue);

        await future;

        // Assert uploading state is false after completion
        expect(provider.isUploading, isFalse);
      });
    });

    group('Error Recovery', () {
      test('should clear error when starting new operation', () async {
        // Arrange
        provider.setError('Previous error');
        when(mockService.getAllRoutesForAdmin())
            .thenAnswer((_) async => []);

        // Act
        await provider.loadRoutes();

        // Assert
        expect(provider.errorMessage, isNull);
      });

      test('should retry failed operations', () async {
        // Arrange
        when(mockService.getAllRoutesForAdmin())
            .thenThrow(Exception('Network error'))
            .thenAnswer((_) async => []); // Success on retry

        // Act - First call fails
        await provider.loadRoutes();
        expect(provider.errorMessage, isNotNull);

        // Act - Retry succeeds
        await provider.loadRoutes();

        // Assert
        expect(provider.errorMessage, isNull);
        verify(mockService.getAllRoutesForAdmin()).called(2);
      });
    });
  });
}