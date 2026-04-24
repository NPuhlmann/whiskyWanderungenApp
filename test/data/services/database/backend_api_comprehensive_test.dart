import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/delivery_address.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:whisky_hikes/domain/models/review.dart';
import 'package:whisky_hikes/data/models/pagination_result.dart';
import 'dart:typed_data';

import '../../test_helpers.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

void main() {
  group('BackendApiService Comprehensive Tests', () {
    late BackendApiService backendApi;
    late MockSupabaseClient mockClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockPostgrestTransformBuilder mockTransformBuilder;
    late MockGoTrueClient mockAuth;
    late MockSupabaseStorageClient mockStorage;
    late MockStorageFileApi mockBucket;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockTransformBuilder = MockPostgrestTransformBuilder();
      mockAuth = MockGoTrueClient();
      mockStorage = MockSupabaseStorageClient();
      mockBucket = MockStorageFileApi();

      // Setup basic client mocks
      when(mockClient.auth).thenReturn(mockAuth);
      when(mockClient.storage).thenReturn(mockStorage);
      when(mockStorage.from('avatars')).thenReturn(mockBucket);
      when(mockStorage.from('hike_images')).thenReturn(mockBucket);

      backendApi = BackendApiService(client: mockClient);
    });

    group('Hike Operations Tests', () {
      test('fetchHikes should return list of hikes successfully', () async {
        // Arrange
        final hikeData = [
          TestHelpers.createTestHikeJson(id: 1, name: 'Hike 1'),
          TestHelpers.createTestHikeJson(id: 2, name: 'Hike 2'),
        ];

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => hikeData);

        // Act
        final result = await backendApi.fetchHikes();

        // Assert
        expect(result, isA<List<Hike>>());
        expect(result.length, equals(2));
        expect(result[0].name, equals('Hike 1'));
        verify(mockClient.from('hikes')).called(1);
      });

      test('fetchHikes should handle empty response', () async {
        // Arrange
        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

        // Act
        final result = await backendApi.fetchHikes();

        // Assert
        expect(result, isA<List<Hike>>());
        expect(result, isEmpty);
      });

      test('fetchHikes should handle database error', () async {
        // Arrange
        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.then(any),
        ).thenThrow(PostgrestException(message: 'Database error', code: '500'));

        // Act & Assert
        expect(
          () => backendApi.fetchHikes(),
          throwsA(isA<PostgrestException>()),
        );
      });

      test('fetchUserHikes should return user specific hikes', () async {
        // Arrange
        const userId = 'user123';
        final hikeData = [
          TestHelpers.createTestHikeJson(id: 1, name: 'User Hike 1'),
        ];

        when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', userId),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => hikeData);

        // Act
        final result = await backendApi.fetchUserHikes(userId);

        // Assert
        expect(result, isA<List<Hike>>());
        expect(result.length, equals(1));
        verify(mockFilterBuilder.eq('user_id', userId)).called(1);
      });

      test('getHikeImages should return list of image URLs', () async {
        // Arrange
        const hikeId = 1;
        final imageData = [
          {'image_url': 'https://example.com/image1.jpg'},
          {'image_url': 'https://example.com/image2.jpg'},
        ];

        when(mockClient.from('hike_images')).thenReturn(mockQueryBuilder);
        when(
          mockQueryBuilder.select('image_url'),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('hike_id', hikeId),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: true),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => imageData);

        // Act
        final result = await backendApi.getHikeImages(hikeId);

        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, equals(2));
        expect(result[0], equals('https://example.com/image1.jpg'));
        expect(result[1], equals('https://example.com/image2.jpg'));
      });

      test(
        'hasUserPurchasedHike should return true for purchased hikes',
        () async {
          // Arrange
          const userId = 'user123';
          const hikeId = 1;
          final purchaseData = [
            {'id': 1, 'user_id': userId, 'hike_id': hikeId},
          ];

          when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
          when(
            mockFilterBuilder.eq('user_id', userId),
          ).thenReturn(mockFilterBuilder);
          when(
            mockFilterBuilder.eq('hike_id', hikeId),
          ).thenReturn(mockTransformBuilder);
          when(
            mockTransformBuilder.then(any),
          ).thenAnswer((_) async => purchaseData);

          // Act
          final result = await backendApi.hasUserPurchasedHike(userId, hikeId);

          // Assert
          expect(result, true);
        },
      );

      test(
        'hasUserPurchasedHike should return false for unpurchased hikes',
        () async {
          // Arrange
          const userId = 'user123';
          const hikeId = 1;

          when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
          when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
          when(
            mockFilterBuilder.eq('user_id', userId),
          ).thenReturn(mockFilterBuilder);
          when(
            mockFilterBuilder.eq('hike_id', hikeId),
          ).thenReturn(mockTransformBuilder);
          when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

          // Act
          final result = await backendApi.hasUserPurchasedHike(userId, hikeId);

          // Assert
          expect(result, false);
        },
      );
    });

    group('Profile Operations Tests', () {
      test('updateUserProfile should update profile successfully', () async {
        // Arrange
        final profile = TestHelpers.createTestProfile(
          userId: 'user123',
          firstName: 'John',
        );

        when(mockClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', profile.userId),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

        // Act & Assert - should not throw
        await backendApi.updateUserProfile(profile);
        verify(mockQueryBuilder.update(any)).called(1);
        verify(mockFilterBuilder.eq('user_id', profile.userId)).called(1);
      });

      test('uploadProfileImage should upload image and return URL', () async {
        // Arrange
        const userId = 'user123';
        const fileExt = 'jpg';
        final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
        const expectedUrl = 'https://storage.supabase.com/image.jpg';

        when(
          mockBucket.uploadBinary(
            any,
            imageBytes,
            fileOptions: anyNamed('fileOptions'),
          ),
        ).thenAnswer((_) async => 'success');
        when(mockBucket.getPublicUrl(any)).thenReturn(expectedUrl);

        // Act
        final result = await backendApi.uploadProfileImage(
          userId,
          imageBytes,
          fileExt,
        );

        // Assert
        expect(result, equals(expectedUrl));
        verify(
          mockBucket.uploadBinary(
            any,
            imageBytes,
            fileOptions: anyNamed('fileOptions'),
          ),
        ).called(1);
        verify(mockBucket.getPublicUrl(any)).called(1);
      });

      test('getProfileImageUrl should return image URL for user', () async {
        // Arrange
        const userId = 'user123';
        const expectedUrl = 'https://storage.supabase.com/profile.jpg';

        when(mockBucket.list(path: '$userId/')).thenAnswer(
          (_) async => [
            FileObject(
              bucketId: 'avatars',
              name: 'profile.jpg',
              id: 'profile-id',
              owner: userId,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
              lastAccessedAt: DateTime.now().toIso8601String(),
              metadata: {'size': 1024},
            ),
          ],
        );
        when(
          mockBucket.getPublicUrl('$userId/profile.jpg'),
        ).thenReturn(expectedUrl);

        // Act
        final result = await backendApi.getProfileImageUrl(userId);

        // Assert
        expect(result, equals(expectedUrl));
      });

      test(
        'getProfileImageUrl should return null when no image exists',
        () async {
          // Arrange
          const userId = 'user123';

          when(mockBucket.list(path: '$userId/')).thenAnswer((_) async => []);

          // Act
          final result = await backendApi.getProfileImageUrl(userId);

          // Assert
          expect(result, isNull);
        },
      );
    });

    group('Waypoint Operations Tests', () {
      test('getWaypointsForHike should return waypoints for hike', () async {
        // Arrange
        const hikeId = 1;
        final waypointData = [
          TestHelpers.createTestWaypointJson(id: 1, name: 'Start Point'),
          TestHelpers.createTestWaypointJson(id: 2, name: 'End Point'),
        ];

        when(mockClient.from('hikes_waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('hike_id', hikeId),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('order_index', ascending: true),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.then(any),
        ).thenAnswer((_) async => waypointData);

        // Act
        final result = await backendApi.getWaypointsForHike(hikeId);

        // Assert
        expect(result, isA<List<Waypoint>>());
        expect(result.length, equals(2));
        verify(mockFilterBuilder.eq('hike_id', hikeId)).called(1);
      });

      test('addWaypoint should insert waypoint successfully', () async {
        // Arrange
        final waypoint = TestHelpers.createTestWaypoint(
          id: 1,
          name: 'New Point',
        );
        const hikeId = 1;

        when(mockClient.from('waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.select()).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single()).thenAnswer((_) async => {'id': 1});

        when(mockClient.from('hikes_waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

        // Act & Assert - should not throw
        await backendApi.addWaypoint(waypoint, hikeId);
        verify(mockClient.from('waypoints')).called(1);
        verify(mockClient.from('hikes_waypoints')).called(1);
      });

      test('updateWaypoint should update waypoint successfully', () async {
        // Arrange
        final waypoint = TestHelpers.createTestWaypoint(
          id: 1,
          name: 'Updated Point',
        );

        when(mockClient.from('waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('id', waypoint.id),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

        // Act & Assert - should not throw
        await backendApi.updateWaypoint(waypoint);
        verify(mockFilterBuilder.eq('id', waypoint.id)).called(1);
      });

      test('deleteWaypoint should delete waypoint and associations', () async {
        // Arrange
        const waypointId = 1;
        const hikeId = 1;

        when(mockClient.from('hikes_waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('waypoint_id', waypointId),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('hike_id', hikeId),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

        when(mockClient.from('waypoints')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('id', waypointId),
        ).thenReturn(mockTransformBuilder);

        // Act & Assert - should not throw
        await backendApi.deleteWaypoint(waypointId, hikeId);
        verify(mockClient.from('hikes_waypoints')).called(1);
        verify(mockClient.from('waypoints')).called(1);
      });
    });

    group('Order Operations Tests', () {
      test('fetchUserOrders should return user orders', () async {
        // Arrange
        const userId = 'user123';
        final orderData = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: userId),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: userId),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', userId),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => orderData);

        // Act
        final result = await backendApi.fetchUserOrders(userId);

        // Assert
        expect(result, isA<List<BasicOrder>>());
        expect(result.length, equals(2));
        verify(mockFilterBuilder.eq('user_id', userId)).called(1);
      });

      test('fetchOrderById should return specific order', () async {
        // Arrange
        const orderId = 1;
        final orderData = TestHelpers.createTestBasicOrderJson(
          id: orderId,
          userId: 'user123',
        );

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('id', orderId),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single()).thenAnswer((_) async => orderData);

        // Act
        final result = await backendApi.fetchOrderById(orderId);

        // Assert
        expect(result, isA<BasicOrder>());
        expect(result.id, equals(orderId));
        verify(mockFilterBuilder.eq('id', orderId)).called(1);
      });

      test('recordHikePurchase should create purchase record', () async {
        // Arrange
        const userId = 'user123';
        const hikeId = 1;
        const orderId = 1;

        when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

        // Act & Assert - should not throw
        await backendApi.recordHikePurchase(userId, hikeId, orderId);
        verify(
          mockQueryBuilder.insert({
            'user_id': userId,
            'hike_id': hikeId,
            'order_id': orderId,
            'purchased_at': anyNamed('purchased_at'),
          }),
        ).called(1);
      });
    });

    group('Tasting Set Operations Tests', () {
      test('getTastingSetForHike should return tasting set', () async {
        // Arrange
        const hikeId = 1;
        final tastingSetData = TestHelpers.createTestTastingSetJson(
          id: 1,
          hikeId: hikeId,
        );

        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('hike_id', hikeId),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.single(),
        ).thenAnswer((_) async => tastingSetData);

        // Act
        final result = await backendApi.getTastingSetForHike(hikeId);

        // Assert
        expect(result, isA<TastingSet>());
        expect(result.hikeId, equals(hikeId));
        verify(mockFilterBuilder.eq('hike_id', hikeId)).called(1);
      });

      test('getTastingSetForHike should handle not found', () async {
        // Arrange
        const hikeId = 1;

        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('hike_id', hikeId),
        ).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.single()).thenThrow(
          PostgrestException(message: 'No rows found', code: 'PGRST116'),
        );

        // Act & Assert
        expect(
          () => backendApi.getTastingSetForHike(hikeId),
          throwsA(isA<PostgrestException>()),
        );
      });
    });

    group('Review Operations Tests', () {
      test('submitHikeReview should submit review successfully', () async {
        // Arrange
        final review = TestHelpers.createTestReview(
          id: 1,
          hikeId: 1,
          userId: 'user123',
          rating: 5,
          comment: 'Great hike!',
        );

        when(mockClient.from('reviews')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then(any)).thenAnswer((_) async => []);

        // Act & Assert - should not throw
        await backendApi.submitHikeReview(review);
        verify(mockQueryBuilder.insert(any)).called(1);
      });

      test('getHikeReviews should return hike reviews', () async {
        // Arrange
        const hikeId = 1;
        final reviewData = [
          TestHelpers.createTestReviewJson(hikeId: hikeId, rating: 5),
          TestHelpers.createTestReviewJson(hikeId: hikeId, rating: 4),
        ];

        when(mockClient.from('reviews')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('hike_id', hikeId),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.then(any),
        ).thenAnswer((_) async => reviewData);

        // Act
        final result = await backendApi.getHikeReviews(hikeId);

        // Assert
        expect(result, isA<List<Review>>());
        expect(result.length, equals(2));
        verify(mockFilterBuilder.eq('hike_id', hikeId)).called(1);
      });
    });

    group('Error Handling Tests', () {
      test('should handle network timeouts gracefully', () async {
        // Arrange
        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.then(any),
        ).thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(() => backendApi.fetchHikes(), throwsA(isA<Exception>()));
      });

      test('should handle malformed data gracefully', () async {
        // Arrange
        final malformedData = [
          {'invalid': 'data'},
        ]; // Missing required fields

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.then(any),
        ).thenAnswer((_) async => malformedData);

        // Act & Assert
        expect(() => backendApi.fetchHikes(), throwsA(isA<Exception>()));
      });
    });

    group('Performance Tests', () {
      test('should handle large datasets efficiently', () async {
        // Arrange
        final largeDataset = List.generate(
          1000,
          (index) =>
              TestHelpers.createTestHikeJson(id: index, name: 'Hike $index'),
        );

        when(mockClient.from('hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.order('created_at', ascending: false),
        ).thenReturn(mockTransformBuilder);
        when(
          mockTransformBuilder.then(any),
        ).thenAnswer((_) async => largeDataset);

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await backendApi.fetchHikes();
        stopwatch.stop();

        // Assert
        expect(result.length, equals(1000));
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5000),
        ); // Should complete within 5 seconds
      });
    });
  });
}
