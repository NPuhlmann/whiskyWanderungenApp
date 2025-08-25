import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import '../../mocks/mock_supabase.dart';

void main() {
  group('BackendApiService Tests', () {
    late BackendApiService backendApiService;
    late MockSupabaseClient mockSupabaseClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockSupabaseStorageClient mockStorageClient;
    late MockStorageFileApi mockStorageFileApi;
    late MockGoTrueClient mockAuthClient;
    late MockUser mockUser;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockStorageClient = MockSupabaseStorageClient();
      mockStorageFileApi = MockStorageFileApi();
      mockAuthClient = MockGoTrueClient();
      mockUser = MockUser();

      // Create BackendApiService instance with reflection to access private client
      backendApiService = BackendApiService();
      
      // Setup basic mocks
      when(mockSupabaseClient.from(any)).thenReturn(mockQueryBuilder);
      when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(mockSupabaseClient.auth).thenReturn(mockAuthClient);
      when(mockStorageClient.from(any)).thenReturn(mockStorageFileApi);
    });

    group('Profile Management', () {
      test('getUserProfileById should return profile when found', () async {
        // Arrange
        final profileData = {
          'id': 'user123',
          'first_name': 'John',
          'last_name': 'Doe',
          'date_of_birth': '1990-05-15T00:00:00.000Z',
        };
        
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'user123'))
            .thenAnswer((_) async => [profileData]);

        // Mock Supabase.instance.client
        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getUserProfileById('user123');

        // Assert
        expect(result.id, 'user123');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        verify(mockQueryBuilder.select()).called(1);
        verify(mockFilterBuilder.eq('id', 'user123')).called(1);
      });

      test('getUserProfileById should return empty profile when not found', () async {
        // Arrange
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'user123'))
            .thenAnswer((_) async => []);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getUserProfileById('user123');

        // Assert
        expect(result.id, 'user123');
        expect(result.firstName, isEmpty);
        expect(result.lastName, isEmpty);
      });

      test('updateUserProfile should update profile correctly', () async {
        // Arrange
        final profile = Profile(
          id: 'user123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com', // Should be removed
          imageUrl: 'https://example.com/avatar.jpg', // Should be removed
        );

        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'user123'))
            .thenAnswer((_) async => null);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.updateUserProfile(profile);

        // Assert
        final capturedData = verify(mockQueryBuilder.update(captureAny)).captured.single;
        expect(capturedData['email'], isNull);
        expect(capturedData['imageUrl'], isNull);
        expect(capturedData['first_name'], 'John');
        expect(capturedData['last_name'], 'Doe');
        verify(mockFilterBuilder.eq('id', 'user123')).called(1);
      });

      test('updateUserProfile should set user ID from auth when missing', () async {
        // Arrange
        final profile = Profile(
          id: '', // Empty ID
          firstName: 'John',
          lastName: 'Doe',
        );

        when(mockAuthClient.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('auth_user_123');
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 'auth_user_123'))
            .thenAnswer((_) async => null);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.updateUserProfile(profile);

        // Assert
        final capturedData = verify(mockQueryBuilder.update(captureAny)).captured.single;
        expect(capturedData['id'], 'auth_user_123');
        verify(mockFilterBuilder.eq('id', 'auth_user_123')).called(1);
      });

      test('updateUserProfile should throw when no user ID available', () async {
        // Arrange
        final profile = Profile(id: '', firstName: 'John', lastName: 'Doe');

        when(mockAuthClient.currentUser).thenReturn(null);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.updateUserProfile(profile),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('Benutzer-ID konnte nicht ermittelt werden'))),
        );
      });
    });

    group('Hike Management', () {
      test('fetchHikes should return list of hikes', () async {
        // Arrange
        final hikesData = [
          {
            'id': 1,
            'name': 'Mountain Trail',
            'length': 5.5,
            'price': 19.99,
            'difficulty': 'mid',
          },
          {
            'id': 2,
            'name': 'Forest Path',
            'length': 3.2,
            'price': 15.99,
            'difficulty': 'easy',
          }
        ];

        when(mockQueryBuilder.select()).thenAnswer((_) async => hikesData);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.fetchHikes();

        // Assert
        expect(result.length, 2);
        expect(result[0].name, 'Mountain Trail');
        expect(result[0].difficulty, Difficulty.mid);
        expect(result[1].name, 'Forest Path');
        expect(result[1].difficulty, Difficulty.easy);
        verify(mockQueryBuilder.select()).called(1);
      });

      test('fetchHikes should return empty list when no hikes found', () async {
        // Arrange
        when(mockQueryBuilder.select()).thenAnswer((_) async => []);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.fetchHikes();

        // Assert
        expect(result, isEmpty);
      });

      test('fetchUserHikes should return user purchased hikes', () async {
        // Arrange
        final purchasedHikesData = [
          {'hike_id': '1'},
          {'hike_id': 2},
        ];

        final hikeData = {
          'id': 1,
          'name': 'User Hike',
          'length': 4.0,
          'price': 20.0,
          'difficulty': 'mid',
        };

        // Mock purchased hikes query
        when(mockQueryBuilder.select('hike_id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', 'user123'))
            .thenAnswer((_) async => purchasedHikesData);

        // Mock individual hike queries
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 1))
            .thenAnswer((_) async => [hikeData]);
        when(mockFilterBuilder.eq('id', 2))
            .thenAnswer((_) async => [hikeData]);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.fetchUserHikes('user123');

        // Assert
        expect(result.length, 2);
        expect(result[0].name, 'User Hike');
        verify(mockQueryBuilder.select('hike_id')).called(1);
        verify(mockFilterBuilder.eq('user_id', 'user123')).called(1);
      });

      test('fetchUserHikes should handle empty purchased hikes', () async {
        // Arrange
        when(mockQueryBuilder.select('hike_id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', 'user123'))
            .thenAnswer((_) async => []);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.fetchUserHikes('user123');

        // Assert
        expect(result, isEmpty);
      });

      test('fetchUserHikes should handle errors gracefully', () async {
        // Arrange
        when(mockQueryBuilder.select('hike_id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', 'user123'))
            .thenThrow(Exception('Database error'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.fetchUserHikes('user123');

        // Assert
        expect(result, isEmpty);
      });

      test('fetchUserHikes should skip invalid hike IDs', () async {
        // Arrange
        final purchasedHikesData = [
          {'hike_id': '1'},
          {'hike_id': null}, // Should be filtered out
          {'hike_id': '2'},
        ];

        when(mockQueryBuilder.select('hike_id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', 'user123'))
            .thenAnswer((_) async => purchasedHikesData);

        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 1))
            .thenAnswer((_) async => [{'id': 1, 'name': 'Hike 1'}]);
        when(mockFilterBuilder.eq('id', 2))
            .thenThrow(Exception('Hike not found'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.fetchUserHikes('user123');

        // Assert
        expect(result.length, 1);
        expect(result[0].name, 'Hike 1');
      });
    });

    group('Hike Images Management', () {
      test('getHikeImages should return list of image URLs', () async {
        // Arrange
        final imagesData = [
          {'image_url': 'https://example.com/image1.jpg'},
          {'image_url': 'https://example.com/image2.png'},
        ];

        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1))
            .thenAnswer((_) async => imagesData);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getHikeImages(1);

        // Assert
        expect(result.length, 2);
        expect(result[0], 'https://example.com/image1.jpg');
        expect(result[1], 'https://example.com/image2.png');
        verify(mockFilterBuilder.eq('hike_id', 1)).called(1);
      });

      test('getHikeImages should return empty list when no images', () async {
        // Arrange
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1))
            .thenAnswer((_) async => []);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getHikeImages(1);

        // Assert
        expect(result, isEmpty);
      });

      test('uploadHikeImages should upload images correctly', () async {
        // Arrange
        final imageUrls = [
          'https://example.com/image1.jpg',
          'https://example.com/image2.png',
        ];

        when(mockQueryBuilder.upsert(any)).thenAnswer((_) async => null);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.uploadHikeImages(1, imageUrls);

        // Assert
        final capturedData = verify(mockQueryBuilder.upsert(captureAny)).captured.single;
        expect(capturedData.length, 2);
        expect(capturedData[0]['hike_id'], 1);
        expect(capturedData[0]['image_url'], 'https://example.com/image1.jpg');
        expect(capturedData[1]['hike_id'], 1);
        expect(capturedData[1]['image_url'], 'https://example.com/image2.png');
      });
    });

    group('Profile Image Management', () {
      test('uploadProfileImage should upload image successfully', () async {
        // Arrange
        final fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const userId = 'user123';
        const fileExt = 'jpg';
        const expectedUrl = 'https://example.com/avatars/user123/profile.jpg';

        when(mockStorageClient.listBuckets())
            .thenAnswer((_) async => [Bucket(id: 'avatars-bucket-id', name: 'avatars', owner: 'owner-id', public: true, createdAt: DateTime.now().toIso8601String(), updatedAt: DateTime.now().toIso8601String())]);
        when(mockStorageFileApi.uploadBinary(any, any, fileOptions: anyNamed('fileOptions')))
            .thenAnswer((_) async => 'path');
        when(mockStorageFileApi.getPublicUrl(any))
            .thenReturn(expectedUrl);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.uploadProfileImage(userId, fileBytes, fileExt);

        // Assert
        expect(result, expectedUrl);
        verify(mockStorageFileApi.uploadBinary(
          'user123/profile.jpg',
          fileBytes,
          fileOptions: anyNamed('fileOptions'),
        )).called(1);
      });

      test('uploadProfileImage should handle bucket not found', () async {
        // Arrange
        final fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(mockStorageClient.listBuckets())
            .thenAnswer((_) async => []); // No avatars bucket

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.uploadProfileImage('user123', fileBytes, 'jpg'),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('avatars') && 
            e.toString().contains('existiert nicht'))),
        );
      });

      test('uploadProfileImage should handle permission denied', () async {
        // Arrange
        final fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(mockStorageClient.listBuckets())
            .thenAnswer((_) async => [Bucket(id: 'avatars-bucket-id', name: 'avatars', owner: 'owner-id', public: true, createdAt: DateTime.now().toIso8601String(), updatedAt: DateTime.now().toIso8601String())]);
        when(mockStorageFileApi.uploadBinary(any, any, fileOptions: anyNamed('fileOptions')))
            .thenThrow(Exception('permission denied'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.uploadProfileImage('user123', fileBytes, 'jpg'),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('Berechtigung'))),
        );
      });

      test('getProfileImageUrl should return URL when image exists', () async {
        // Arrange
        const userId = 'user123';
        final files = [
          FileObject(bucketId: 'avatars', name: 'profile.jpg', id: 'profile-id', owner: 'owner-id', metadata: {'size': 1024}, updatedAt: DateTime.now().toIso8601String(), createdAt: DateTime.now().toIso8601String()),
          FileObject(bucketId: 'avatars', name: 'other.png', id: 'other-id', owner: 'owner-id', metadata: {'size': 512}, updatedAt: DateTime.now().toIso8601String(), createdAt: DateTime.now().toIso8601String()),
        ];
        const expectedUrl = 'https://example.com/avatars/user123/profile.jpg';

        when(mockStorageFileApi.list(path: userId))
            .thenAnswer((_) async => files);
        when(mockStorageFileApi.getPublicUrl('user123/profile.jpg'))
            .thenReturn(expectedUrl);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getProfileImageUrl(userId);

        // Assert
        expect(result, expectedUrl);
        verify(mockStorageFileApi.list(path: userId)).called(1);
      });

      test('getProfileImageUrl should return null when no profile image', () async {
        // Arrange
        const userId = 'user123';
        final files = [
          FileObject(bucketId: 'avatars', name: 'other.png', id: 'other-id-2', owner: 'owner-id', metadata: {'size': 512}, updatedAt: DateTime.now().toIso8601String(), createdAt: DateTime.now().toIso8601String()),
        ];

        when(mockStorageFileApi.list(path: userId))
            .thenAnswer((_) async => files);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getProfileImageUrl(userId);

        // Assert
        expect(result, isNull);
      });

      test('getProfileImageUrl should handle storage errors gracefully', () async {
        // Arrange
        when(mockStorageFileApi.list(path: 'user123'))
            .thenThrow(Exception('permission error'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getProfileImageUrl('user123');

        // Assert
        expect(result, isNull);
      });
    });

    group('Waypoint Management', () {
      test('getWaypointsForHike should return waypoints in order', () async {
        // Arrange
        final waypointDataList = [
          {'waypoint_id': '2', 'order_index': '1'},
          {'waypoint_id': '1', 'order_index': '0'},
        ];

        final waypointsResponse = [
          {
            'id': 1,
            'name': 'First Waypoint',
            'description': 'Description 1',
            'latitude': '47.3769',
            'longitude': '8.5417',
          },
          {
            'id': 2,
            'name': 'Second Waypoint',
            'description': 'Description 2',
            'latitude': '47.3800',
            'longitude': '8.5500',
          }
        ];

        // Mock waypoint data query
        when(mockQueryBuilder.select('waypoint_id, order_index'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('order_index', ascending: true))
            .thenAnswer((_) async => waypointDataList);

        // Mock waypoints query
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.inFilter('id', [2, 1]))
            .thenAnswer((_) async => waypointsResponse);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getWaypointsForHike(1);

        // Assert
        expect(result.length, 2);
        expect(result[0].orderIndex, 0); // Should be sorted
        expect(result[1].orderIndex, 1);
        expect(result[0].name, 'First Waypoint');
        expect(result[1].name, 'Second Waypoint');
      });

      test('getWaypointsForHike should handle empty waypoints', () async {
        // Arrange
        when(mockQueryBuilder.select('waypoint_id, order_index'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('order_index', ascending: true))
            .thenAnswer((_) async => []);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getWaypointsForHike(1);

        // Assert
        expect(result, isEmpty);
      });

      test('getWaypointsForHike should handle coordinate conversion', () async {
        // Arrange
        final waypointDataList = [
          {'waypoint_id': '1', 'order_index': '0'},
        ];

        final waypointsResponse = [
          {
            'id': 1,
            'name': 'Test Waypoint',
            'description': 'Test Description',
            'latitude': null, // Should default to 0.0
            'longitude': '8.5417', // String to be converted
          }
        ];

        when(mockQueryBuilder.select('waypoint_id, order_index'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('order_index', ascending: true))
            .thenAnswer((_) async => waypointDataList);

        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.inFilter('id', [1]))
            .thenAnswer((_) async => waypointsResponse);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        final result = await service.getWaypointsForHike(1);

        // Assert
        expect(result.length, 1);
        expect(result[0].latitude, 0.0); // Should default from null
        expect(result[0].longitude, 8.5417); // Should convert from string
      });

      test('addWaypoint should create waypoint with association', () async {
        // Arrange
        final waypoint = Waypoint(
          id: 0, // Will be generated
          hikeId: 1,
          name: 'New Waypoint',
          description: 'New Description',
          latitude: 47.3769,
          longitude: 8.5417,
        );

        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {'id': 123});

        // Mock for order index check
        when(mockQueryBuilder.select('order_index')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('order_index', ascending: false))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(1)).thenAnswer((_) async => []);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.addWaypoint(waypoint, 1);

        // Assert
        // Verify waypoint insertion
        final waypointData = verify(mockQueryBuilder.insert(captureAny)).captured.first;
        expect(waypointData['name'], 'New Waypoint');
        expect(waypointData['description'], 'New Description');
        expect(waypointData['latitude'], 47.3769);
        expect(waypointData['longitude'], 8.5417);

        // Verify association insertion
        final associationData = verify(mockQueryBuilder.insert(captureAny)).captured.last;
        expect(associationData['hike_id'], 1);
        expect(associationData['waypoint_id'], 123);
        expect(associationData['order_index'], 1); // Should be 1 for first waypoint
      });

      test('addWaypoint should use next order index when waypoints exist', () async {
        // Arrange
        final waypoint = Waypoint(
          id: 0,
          hikeId: 1,
          name: 'New Waypoint',
          description: 'New Description',
          latitude: 47.3769,
          longitude: 8.5417,
        );

        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {'id': 123});

        // Mock for order index check - return existing max order
        when(mockQueryBuilder.select('order_index')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('order_index', ascending: false))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(1))
            .thenAnswer((_) async => [{'order_index': '5'}]);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.addWaypoint(waypoint, 1);

        // Assert
        final associationData = verify(mockQueryBuilder.insert(captureAny)).captured.last;
        expect(associationData['order_index'], 6); // Should be max + 1
      });

      test('updateWaypoint should update waypoint correctly', () async {
        // Arrange
        final waypoint = Waypoint(
          id: 123,
          hikeId: 1,
          name: 'Updated Waypoint',
          description: 'Updated Description',
          latitude: 47.4000,
          longitude: 8.6000,
        );

        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', 123)).thenAnswer((_) async => null);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.updateWaypoint(waypoint);

        // Assert
        final updateData = verify(mockQueryBuilder.update(captureAny)).captured.single;
        expect(updateData['name'], 'Updated Waypoint');
        expect(updateData['description'], 'Updated Description');
        expect(updateData['latitude'], 47.4000);
        expect(updateData['longitude'], 8.6000);
        verify(mockFilterBuilder.eq('id', 123)).called(1);
      });

      test('deleteWaypoint should delete waypoint and association', () async {
        // Arrange
        when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq(any, any)).thenAnswer((_) async => null);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.deleteWaypoint(123, 1);

        // Assert
        verify(mockQueryBuilder.delete()).called(2); // Association and waypoint
        verify(mockFilterBuilder.eq('waypoint_id', 123)).called(1);
        verify(mockFilterBuilder.eq('hike_id', 1)).called(1);
        verify(mockFilterBuilder.eq('id', 123)).called(1);
      });

      test('updateWaypointOrder should update order correctly', () async {
        // Arrange
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('waypoint_id', 123)).thenAnswer((_) async => null);

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act
        await service.updateWaypointOrder(1, 123, 5);

        // Assert
        final updateData = verify(mockQueryBuilder.update(captureAny)).captured.single;
        expect(updateData['order_index'], 5);
        verify(mockFilterBuilder.eq('hike_id', 1)).called(1);
        verify(mockFilterBuilder.eq('waypoint_id', 123)).called(1);
      });
    });

    group('Error Handling', () {
      test('getWaypointsForHike should throw meaningful error on failure', () async {
        // Arrange
        when(mockQueryBuilder.select('waypoint_id, order_index'))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('order_index', ascending: true))
            .thenThrow(Exception('Database connection failed'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.getWaypointsForHike(1),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('Fehler beim Abrufen der Wegpunkt-Daten für Wanderung 1'))),
        );
      });

      test('addWaypoint should throw meaningful error on failure', () async {
        // Arrange
        final waypoint = Waypoint(
          id: 0,
          hikeId: 1,
          name: 'Test',
          description: 'Test',
          latitude: 47.3769,
          longitude: 8.5417,
        );

        when(mockQueryBuilder.insert(any))
            .thenThrow(Exception('Insert failed'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.addWaypoint(waypoint, 1),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('Fehler beim Hinzufügen des Wegpunkts'))),
        );
      });

      test('updateWaypoint should throw meaningful error on failure', () async {
        // Arrange
        final waypoint = Waypoint(
          id: 123,
          hikeId: 1,
          name: 'Test',
          description: 'Test',
          latitude: 47.3769,
          longitude: 8.5417,
        );

        when(mockQueryBuilder.update(any))
            .thenThrow(Exception('Update failed'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.updateWaypoint(waypoint),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('Fehler beim Aktualisieren des Wegpunkts'))),
        );
      });

      test('deleteWaypoint should throw meaningful error on failure', () async {
        // Arrange
        when(mockQueryBuilder.delete())
            .thenThrow(Exception('Delete failed'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.deleteWaypoint(123, 1),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('Fehler beim Löschen des Wegpunkts'))),
        );
      });

      test('updateWaypointOrder should throw meaningful error on failure', () async {
        // Arrange
        when(mockQueryBuilder.update(any))
            .thenThrow(Exception('Update order failed'));

        final service = MockedBackendApiService(mockSupabaseClient);

        // Act & Assert
        expect(
          () => service.updateWaypointOrder(1, 123, 5),
          throwsA(predicate((e) => e is Exception && 
            e.toString().contains('Fehler beim Aktualisieren der Wegpunkt-Reihenfolge'))),
        );
      });
    });
  });
}

/// Test wrapper class that allows injecting a mocked SupabaseClient
class MockedBackendApiService extends BackendApiService {
  final SupabaseClient mockClient;

  MockedBackendApiService(this.mockClient);

  @override
  SupabaseClient get client => mockClient;
}