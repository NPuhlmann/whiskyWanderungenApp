import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/admin/route_management_service.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import 'route_management_service_test.mocks.dart';

@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder,
  PostgrestFilterBuilder,
  PostgrestTransformBuilder,
  SupabaseStorageClient,
  StorageFileApi,
])
void main() {
  group('RouteManagementService Tests', () {
    late RouteManagementService service;
    late MockSupabaseClient mockClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockPostgrestTransformBuilder mockTransformBuilder;
    late MockSupabaseStorageClient mockStorageClient;
    late MockStorageFileApi mockStorageFileApi;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockTransformBuilder = MockPostgrestTransformBuilder();
      mockStorageClient = MockSupabaseStorageClient();
      mockStorageFileApi = MockStorageFileApi();

      service = RouteManagementService(client: mockClient);
    });

    group('Route CRUD Operations', () {
      test('should create new route successfully', () async {
        // Arrange
        final routeData = {
          'name': 'Test Route',
          'description': 'Test Description',
          'difficulty': 'moderate',
          'distance': 10.5,
          'duration': 4,
          'price': 89.99,
          'max_participants': 12,
          'is_active': true,
        };

        final mockResponse = [
          {
            'id': 123,
            'name': 'Test Route',
            'description': 'Test Description',
            'difficulty': 'moderate',
            'distance': 10.5,
            'duration': 4,
            'price': 89.99,
            'max_participants': 12,
            'is_active': true,
            'created_at': '2024-01-01T10:00:00Z',
            'updated_at': '2024-01-01T10:00:00Z',
          }
        ];

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(routeData)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single()).thenAnswer((_) async => mockResponse[0]);

        // Act
        final result = await service.createRoute(routeData);

        // Assert
        expect(result, isNotNull);
        expect(result['id'], equals(123));
        expect(result['name'], equals('Test Route'));
        verify(mockClient.from('hikes')).called(1);
        verify(mockQueryBuilder.insert(routeData)).called(1);
      });

      test('should get route by id successfully', () async {
        // Arrange
        const routeId = 123;
        final mockResponse = [
          {
            'id': 123,
            'name': 'Test Route',
            'description': 'Test Description',
            'difficulty': 'moderate',
            'distance': 10.5,
            'duration': 4,
            'price': 89.99,
            'max_participants': 12,
            'is_active': true,
            'created_at': '2024-01-01T10:00:00Z',
            'updated_at': '2024-01-01T10:00:00Z',
          }
        ];

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', routeId)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single()).thenAnswer((_) async => mockResponse[0]);

        // Act
        final result = await service.getRouteById(routeId);

        // Assert
        expect(result, isNotNull);
        expect(result['id'], equals(123));
        expect(result['name'], equals('Test Route'));
        verify(mockClient.from('hikes')).called(1);
        verify(mockFilterBuilder.eq('id', routeId)).called(1);
      });

      test('should update route successfully', () async {
        // Arrange
        const routeId = 123;
        final updateData = {
          'name': 'Updated Route',
          'price': 99.99,
          'updated_at': '2024-01-02T10:00:00Z',
        };

        final mockResponse = [
          {
            'id': 123,
            'name': 'Updated Route',
            'description': 'Test Description',
            'difficulty': 'moderate',
            'distance': 10.5,
            'duration': 4,
            'price': 99.99,
            'max_participants': 12,
            'is_active': true,
            'created_at': '2024-01-01T10:00:00Z',
            'updated_at': '2024-01-02T10:00:00Z',
          }
        ];

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(updateData)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', routeId)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.select()).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single()).thenAnswer((_) async => mockResponse[0]);

        // Act
        final result = await service.updateRoute(routeId, updateData);

        // Assert
        expect(result, isNotNull);
        expect(result['id'], equals(123));
        expect(result['name'], equals('Updated Route'));
        expect(result['price'], equals(99.99));
        verify(mockQueryBuilder.update(updateData)).called(1);
        verify(mockFilterBuilder.eq('id', routeId)).called(1);
      });

      test('should delete route successfully', () async {
        // Arrange
        const routeId = 123;

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', routeId)).thenAnswer((_) async => null);

        // Act
        await service.deleteRoute(routeId);

        // Assert
        verify(mockClient.from('hikes')).called(1);
        verify(mockQueryBuilder.delete()).called(1);
        verify(mockFilterBuilder.eq('id', routeId)).called(1);
      });

      test('should get all routes for admin successfully', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 123,
            'name': 'Route 1',
            'description': 'Description 1',
            'difficulty': 'easy',
            'price': 79.99,
            'is_active': true,
            'created_at': '2024-01-01T10:00:00Z',
          },
          {
            'id': 124,
            'name': 'Route 2',
            'description': 'Description 2',
            'difficulty': 'moderate',
            'price': 89.99,
            'is_active': false,
            'created_at': '2024-01-02T10:00:00Z',
          },
        ];

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getAllRoutesForAdmin();

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['name'], equals('Route 1'));
        expect(result[1]['name'], equals('Route 2'));
        verify(mockFilterBuilder.order('created_at', ascending: false)).called(1);
      });
    });

    group('Waypoint Management', () {
      test('should add waypoint to route successfully', () async {
        // Arrange
        const routeId = 123;
        final waypointData = {
          'name': 'Test Waypoint',
          'description': 'Test Description',
          'latitude': 52.5200,
          'longitude': 13.4050,
          'order_index': 1,
          'whisky_info': 'Glenfiddich 12 Year Old',
        };

        final mockResponse = [
          {
            'id': 456,
            'name': 'Test Waypoint',
            'description': 'Test Description',
            'latitude': 52.5200,
            'longitude': 13.4050,
            'order_index': 1,
            'whisky_info': 'Glenfiddich 12 Year Old',
            'created_at': '2024-01-01T10:00:00Z',
          }
        ];

        // Mock waypoint insertion
        when(mockClient.from('waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(waypointData)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single()).thenAnswer((_) async => mockResponse[0]);

        // Mock hike-waypoint relationship
        when(mockClient.from('hikes_waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert({
          'hike_id': routeId,
          'waypoint_id': 456,
          'order_index': 1,
        })).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockTransformBuilder);

        // Act
        final result = await service.addWaypointToRoute(routeId, waypointData);

        // Assert
        expect(result, isNotNull);
        expect(result['id'], equals(456));
        expect(result['name'], equals('Test Waypoint'));
        verify(mockClient.from('waypoints')).called(1);
        verify(mockClient.from('hikes_waypoints')).called(1);
      });

      test('should update waypoint order successfully', () async {
        // Arrange
        const routeId = 123;
        final newOrder = [
          {'waypointId': 456, 'orderIndex': 2},
          {'waypointId': 457, 'orderIndex': 1},
          {'waypointId': 458, 'orderIndex': 3},
        ];

        when(mockClient.from('hikes_waypoints')).thenReturn(mockQueryBuilder);

        // Mock each update call
        for (final order in newOrder) {
          when(mockQueryBuilder.update({'order_index': order['orderIndex']}))
              .thenReturn(mockFilterBuilder);
          when(mockFilterBuilder.eq('hike_id', routeId)).thenReturn(mockFilterBuilder);
          when(mockFilterBuilder.eq('waypoint_id', order['waypointId']))
              .thenAnswer((_) async => null);
        }

        // Act
        await service.updateWaypointOrder(routeId, newOrder);

        // Assert
        verify(mockClient.from('hikes_waypoints')).called(newOrder.length);
        for (final order in newOrder) {
          verify(mockQueryBuilder.update({'order_index': order['orderIndex']}))
              .called(1);
        }
      });

      test('should remove waypoint from route successfully', () async {
        // Arrange
        const routeId = 123;
        const waypointId = 456;

        when(mockClient.from('hikes_waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', routeId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('waypoint_id', waypointId))
            .thenAnswer((_) async => null);

        // Act
        await service.removeWaypointFromRoute(routeId, waypointId);

        // Assert
        verify(mockClient.from('hikes_waypoints')).called(1);
        verify(mockQueryBuilder.delete()).called(1);
        verify(mockFilterBuilder.eq('hike_id', routeId)).called(1);
        verify(mockFilterBuilder.eq('waypoint_id', waypointId)).called(1);
      });

      test('should get route waypoints successfully', () async {
        // Arrange
        const routeId = 123;
        final mockResponse = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Waypoint 1',
              'description': 'Description 1',
              'latitude': 52.5200,
              'longitude': 13.4050,
              'whisky_info': 'Glenfiddich 12',
            }
          },
          {
            'waypoint_id': 457,
            'order_index': 2,
            'waypoints': {
              'id': 457,
              'name': 'Waypoint 2',
              'description': 'Description 2',
              'latitude': 52.5300,
              'longitude': 13.4150,
              'whisky_info': 'Macallan 15',
            }
          },
        ];

        when(mockClient.from('hikes_waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('waypoint_id, order_index, waypoints(*)'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', routeId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('order_index')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await service.getRouteWaypoints(routeId);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(2));
        expect(result[0]['waypoints']['name'], equals('Waypoint 1'));
        expect(result[1]['waypoints']['name'], equals('Waypoint 2'));
        verify(mockFilterBuilder.order('order_index')).called(1);
      });
    });

    group('Image Management', () {
      test('should upload route image successfully', () async {
        // Arrange
        const routeId = 123;
        const fileName = 'route_123_image.jpg';
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]); // Mock image data
        const publicUrl = 'https://storage.supabase.co/route_images/route_123_image.jpg';

        when(mockClient.storage).thenReturn(mockStorageClient);
        when(mockStorageClient.from('route_images')).thenReturn(mockStorageFileApi);
        when(mockStorageFileApi.uploadBinary(
          'route_$routeId/$fileName',
          imageBytes,
          fileOptions: anyNamed('fileOptions'),
        )).thenAnswer((_) async => 'path/to/uploaded/file');
        when(mockStorageFileApi.getPublicUrl('route_$routeId/$fileName'))
            .thenReturn(publicUrl);

        // Act
        final result = await service.uploadRouteImage(routeId, imageBytes, fileName);

        // Assert
        expect(result, equals(publicUrl));
        verify(mockStorageFileApi.uploadBinary(
          'route_$routeId/$fileName',
          imageBytes,
          fileOptions: anyNamed('fileOptions'),
        )).called(1);
        verify(mockStorageFileApi.getPublicUrl('route_$routeId/$fileName')).called(1);
      });

      test('should delete route image successfully', () async {
        // Arrange
        const routeId = 123;
        const fileName = 'route_123_image.jpg';

        when(mockClient.storage).thenReturn(mockStorageClient);
        when(mockStorageClient.from('route_images')).thenReturn(mockStorageFileApi);
        when(mockStorageFileApi.remove(['route_$routeId/$fileName']))
            .thenAnswer((_) async => []);

        // Act
        await service.deleteRouteImage(routeId, fileName);

        // Assert
        verify(mockStorageFileApi.remove(['route_$routeId/$fileName'])).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle route creation error gracefully', () async {
        // Arrange
        final routeData = {
          'name': 'Test Route',
          'description': 'Test Description',
        };

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(routeData)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single())
            .thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(
          () async => await service.createRoute(routeData),
          throwsException,
        );
      });

      test('should handle route not found error', () async {
        // Arrange
        const routeId = 999; // Non-existent route

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', routeId)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single())
            .thenThrow(Exception('Route not found'));

        // Act & Assert
        expect(
          () async => await service.getRouteById(routeId),
          throwsException,
        );
      });

      test('should handle image upload error gracefully', () async {
        // Arrange
        const routeId = 123;
        const fileName = 'route_123_image.jpg';
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(mockClient.storage).thenReturn(mockStorageClient);
        when(mockStorageClient.from('route_images')).thenReturn(mockStorageFileApi);
        when(mockStorageFileApi.uploadBinary(
          any,
          any,
          fileOptions: anyNamed('fileOptions'),
        )).thenThrow(Exception('Storage upload failed'));

        // Act & Assert
        expect(
          () async => await service.uploadRouteImage(routeId, imageBytes, fileName),
          throwsException,
        );
      });
    });
  });
}