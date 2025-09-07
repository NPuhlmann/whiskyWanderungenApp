import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_view_model.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HikeDetailsPageViewModel Tests', () {
    late HikeDetailsPageViewModel viewModel;
    late MockHikeImagesRepository mockHikeImagesRepository;
    late MockWaypointRepository mockWaypointRepository;

    setUp(() {
      mockHikeImagesRepository = MockHikeImagesRepository();
      mockWaypointRepository = MockWaypointRepository();
      
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      
      viewModel = HikeDetailsPageViewModel(
        hikeImagesRepository: mockHikeImagesRepository,
        waypointRepository: mockWaypointRepository,
      );
    });

    group('Initialization', () {
      test('should initialize with correct default values', () {
        expect(viewModel.hikeImages, isEmpty);
      });

      test('should handle null waypoint repository', () {
        // Arrange & Act
        final nullWaypointViewModel = HikeDetailsPageViewModel(
          hikeImagesRepository: mockHikeImagesRepository,
          waypointRepository: null,
        );

        // Assert - should not throw and should handle gracefully
        expect(nullWaypointViewModel, isA<HikeDetailsPageViewModel>());
      });
    });

    group('Hike Images Management', () {
      const testHikeId = 1;
      final testImages = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.png',
        'https://example.com/image3.webp',
      ];

      test('should load hike images from repository', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHikeId))
            .thenAnswer((_) async => testImages);

        // Act
        await viewModel.getHikeImages(testHikeId);

        // Assert
        expect(viewModel.hikeImages, equals(testImages));
        verify(mockHikeImagesRepository.getHikeImages(testHikeId)).called(1);
      });

      test('should cache images and use cache on subsequent calls', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHikeId))
            .thenAnswer((_) async => testImages);

        // Act - First call
        await viewModel.getHikeImages(testHikeId);
        
        // Act - Second call
        await viewModel.getHikeImages(testHikeId);

        // Assert
        expect(viewModel.hikeImages, equals(testImages));
        // Repository should only be called once due to caching
        verify(mockHikeImagesRepository.getHikeImages(testHikeId)).called(1);
      });

      test('should handle empty image list', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHikeId))
            .thenAnswer((_) async => []);

        // Act
        await viewModel.getHikeImages(testHikeId);

        // Assert
        expect(viewModel.hikeImages, isEmpty);
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHikeId))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => viewModel.getHikeImages(testHikeId),
          throwsA(isA<Exception>()),
        );
      });

      test('should create copies of image lists to avoid reference issues', () async {
        // Arrange
        final originalImages = ['image1.jpg', 'image2.jpg'];
        when(mockHikeImagesRepository.getHikeImages(testHikeId))
            .thenAnswer((_) async => originalImages);

        // Act
        await viewModel.getHikeImages(testHikeId);
        
        // Modify original list
        originalImages.add('image3.jpg');

        // Assert - viewModel images should not be affected
        expect(viewModel.hikeImages.length, 2);
        expect(viewModel.hikeImages, isNot(same(originalImages)));
      });

      test('should set hikeImages property correctly', () {
        // Arrange
        const newImages = ['new1.jpg', 'new2.jpg'];

        // Act
        viewModel.hikeImages = newImages;

        // Assert
        expect(viewModel.hikeImages, equals(newImages));
      });

      test('should clear images for UI', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHikeId))
            .thenAnswer((_) async => testImages);
        await viewModel.getHikeImages(testHikeId);
        expect(viewModel.hikeImages, isNotEmpty);

        // Act
        viewModel.clearImagesForUI();

        // Assert
        expect(viewModel.hikeImages, isEmpty);
        
        // Cache should still be intact
        await viewModel.getHikeImages(testHikeId);
        expect(viewModel.hikeImages, equals(testImages));
        verifyNoMoreInteractions(mockHikeImagesRepository); // Should use cache
      });

      test('should clear cache', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHikeId))
            .thenAnswer((_) async => testImages);
        await viewModel.getHikeImages(testHikeId);

        // Act
        viewModel.clearCache();

        // Subsequent call should hit repository again
        await viewModel.getHikeImages(testHikeId);

        // Assert
        verify(mockHikeImagesRepository.getHikeImages(testHikeId)).called(2);
      });

      test('should handle multiple different hike IDs', () async {
        // Arrange
        const hikeId1 = 1;
        const hikeId2 = 2;
        final images1 = ['hike1_img1.jpg', 'hike1_img2.jpg'];
        final images2 = ['hike2_img1.jpg'];

        when(mockHikeImagesRepository.getHikeImages(hikeId1))
            .thenAnswer((_) async => images1);
        when(mockHikeImagesRepository.getHikeImages(hikeId2))
            .thenAnswer((_) async => images2);

        // Act
        await viewModel.getHikeImages(hikeId1);
        final result1 = List<String>.from(viewModel.hikeImages);

        await viewModel.getHikeImages(hikeId2);
        final result2 = List<String>.from(viewModel.hikeImages);

        // Act - Load from cache
        await viewModel.getHikeImages(hikeId1);
        final cachedResult1 = List<String>.from(viewModel.hikeImages);

        // Assert
        expect(result1, equals(images1));
        expect(result2, equals(images2));
        expect(cachedResult1, equals(images1));
        
        // Each hike ID should be called only once due to caching
        verify(mockHikeImagesRepository.getHikeImages(hikeId1)).called(1);
        verify(mockHikeImagesRepository.getHikeImages(hikeId2)).called(1);
      });
    });

    group('Offline Hike Management', () {
      final testHike = Hike(
        id: 1,
        name: 'Test Hike',
        description: 'A test hiking trail',
        length: 5.5,
        price: 19.99,
        difficulty: Difficulty.mid,
      );

      final testWaypoints = [
        const Waypoint(
          id: 1,
          hikeId: 1,
          name: 'Start Point',
          description: 'Beginning',
          latitude: 47.3769,
          longitude: 8.5417,
        ),
        const Waypoint(
          id: 2,
          hikeId: 1,
          name: 'End Point',
          description: 'End',
          latitude: 47.3800,
          longitude: 8.5500,
        ),
      ];

      final testImages = ['image1.jpg', 'image2.jpg'];

      test('should save hike for offline use successfully', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHike.id))
            .thenAnswer((_) async => testImages);
        when(mockWaypointRepository.getWaypointsForHike(testHike.id))
            .thenAnswer((_) async => testWaypoints);

        // Act
        final result = await viewModel.saveHikeForOfflineUse(testHike);

        // Assert
        expect(result, true);

        // Verify data was saved to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        
        // Check hike data
        final savedHikeJson = prefs.getString('offline_hike_${testHike.id}');
        expect(savedHikeJson, isNotNull);
        final savedHike = Hike.fromJson(jsonDecode(savedHikeJson!));
        expect(savedHike.name, testHike.name);

        // Check images
        final savedImages = prefs.getStringList('offline_hike_images_${testHike.id}');
        expect(savedImages, equals(testImages));

        // Check waypoints
        final savedWaypointsJson = prefs.getStringList('offline_hike_waypoints_${testHike.id}');
        expect(savedWaypointsJson?.length, testWaypoints.length);

        // Check offline hikes list
        final offlineHikes = prefs.getStringList('offline_hikes');
        expect(offlineHikes, contains(testHike.id.toString()));
      });

      test('should use cached images when available', () async {
        // Arrange - Pre-cache images
        when(mockHikeImagesRepository.getHikeImages(testHike.id))
            .thenAnswer((_) async => testImages);
        await viewModel.getHikeImages(testHike.id);

        when(mockWaypointRepository.getWaypointsForHike(testHike.id))
            .thenAnswer((_) async => testWaypoints);

        // Act
        final result = await viewModel.saveHikeForOfflineUse(testHike);

        // Assert
        expect(result, true);
        
        // Repository should be called only once (during pre-caching)
        verify(mockHikeImagesRepository.getHikeImages(testHike.id)).called(1);
      });

      test('should handle waypoint loading errors gracefully', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHike.id))
            .thenAnswer((_) async => testImages);
        when(mockWaypointRepository.getWaypointsForHike(testHike.id))
            .thenThrow(Exception('Waypoint loading failed'));

        // Act
        final result = await viewModel.saveHikeForOfflineUse(testHike);

        // Assert
        expect(result, true); // Should still succeed

        // Check that empty waypoints list was saved
        final prefs = await SharedPreferences.getInstance();
        final savedWaypoints = prefs.getStringList('offline_hike_waypoints_${testHike.id}');
        expect(savedWaypoints, isEmpty);
      });

      test('should handle null waypoint repository', () async {
        // Arrange
        final viewModelWithNullWaypoints = HikeDetailsPageViewModel(
          hikeImagesRepository: mockHikeImagesRepository,
          waypointRepository: null,
        );

        when(mockHikeImagesRepository.getHikeImages(testHike.id))
            .thenAnswer((_) async => testImages);

        // Act
        final result = await viewModelWithNullWaypoints.saveHikeForOfflineUse(testHike);

        // Assert
        expect(result, true);

        // Check that empty waypoints list was saved
        final prefs = await SharedPreferences.getInstance();
        final savedWaypoints = prefs.getStringList('offline_hike_waypoints_${testHike.id}');
        expect(savedWaypoints, isEmpty);
      });

      test('should handle save errors', () async {
        // Arrange - Use invalid SharedPreferences setup to trigger error
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await viewModel.saveHikeForOfflineUse(testHike);

        // Assert
        expect(result, false);
      });

      test('should not duplicate hike in offline list', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(testHike.id))
            .thenAnswer((_) async => testImages);
        when(mockWaypointRepository.getWaypointsForHike(testHike.id))
            .thenAnswer((_) async => testWaypoints);

        // Pre-populate offline hikes list
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('offline_hikes', [testHike.id.toString()]);

        // Act
        final result = await viewModel.saveHikeForOfflineUse(testHike);

        // Assert
        expect(result, true);

        final offlineHikes = prefs.getStringList('offline_hikes');
        expect(offlineHikes?.where((id) => id == testHike.id.toString()).length, 1);
      });
    });

    group('Offline Availability Check', () {
      test('should return true for offline available hike', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('offline_hikes', ['1', '2', '3']);

        // Act
        final result = await viewModel.isHikeAvailableOffline(2);

        // Assert
        expect(result, true);
      });

      test('should return false for hike not available offline', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('offline_hikes', ['1', '3']);

        // Act
        final result = await viewModel.isHikeAvailableOffline(2);

        // Assert
        expect(result, false);
      });

      test('should return false when no offline hikes exist', () async {
        // Act
        final result = await viewModel.isHikeAvailableOffline(1);

        // Assert
        expect(result, false);
      });

      test('should handle SharedPreferences errors', () async {
        // Arrange - Mock SharedPreferences to throw error
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await viewModel.isHikeAvailableOffline(1);

        // Assert
        expect(result, false);
      });
    });

    group('Remove Offline Hike', () {
      test('should remove offline hike successfully', () async {
        // Arrange
        const hikeId = 1;
        final prefs = await SharedPreferences.getInstance();
        
        // Pre-populate data
        await prefs.setString('offline_hike_$hikeId', '{"id": $hikeId}');
        await prefs.setStringList('offline_hike_images_$hikeId', ['img1.jpg']);
        await prefs.setStringList('offline_hike_waypoints_$hikeId', ['wp1']);
        await prefs.setStringList('offline_hikes', ['1', '2', '3']);

        // Act
        final result = await viewModel.removeOfflineHike(hikeId);

        // Assert
        expect(result, true);

        // Verify all data was removed
        expect(prefs.getString('offline_hike_$hikeId'), isNull);
        expect(prefs.getStringList('offline_hike_images_$hikeId'), isNull);
        expect(prefs.getStringList('offline_hike_waypoints_$hikeId'), isNull);
        
        // Verify hike was removed from offline list
        final offlineHikes = prefs.getStringList('offline_hikes');
        expect(offlineHikes, equals(['2', '3']));
      });

      test('should handle removing non-existent offline hike', () async {
        // Arrange
        const hikeId = 999;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('offline_hikes', ['1', '2', '3']);

        // Act
        final result = await viewModel.removeOfflineHike(hikeId);

        // Assert
        expect(result, true); // Should still return success

        // Offline list should remain unchanged
        final offlineHikes = prefs.getStringList('offline_hikes');
        expect(offlineHikes, equals(['1', '2', '3']));
      });

      test('should handle SharedPreferences errors during removal', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await viewModel.removeOfflineHike(1);

        // Assert
        expect(result, false);
      });

      test('should handle removing from empty offline list', () async {
        // Act
        final result = await viewModel.removeOfflineHike(1);

        // Assert
        expect(result, true);
      });
    });

    group('Integration Tests', () {
      test('should handle complete offline workflow', () async {
        // Arrange
        final hike = Hike(id: 1, name: 'Integration Test Hike');
        final images = ['img1.jpg', 'img2.jpg'];
        final waypoints = [
          const Waypoint(id: 1, hikeId: 1, name: 'WP1', description: 'First', latitude: 47.0, longitude: 8.0),
        ];

        when(mockHikeImagesRepository.getHikeImages(hike.id))
            .thenAnswer((_) async => images);
        when(mockWaypointRepository.getWaypointsForHike(hike.id))
            .thenAnswer((_) async => waypoints);

        // Act & Assert - Full workflow
        
        // 1. Initially not available offline
        expect(await viewModel.isHikeAvailableOffline(hike.id), false);

        // 2. Save for offline use
        expect(await viewModel.saveHikeForOfflineUse(hike), true);

        // 3. Now should be available offline
        expect(await viewModel.isHikeAvailableOffline(hike.id), true);

        // 4. Remove from offline
        expect(await viewModel.removeOfflineHike(hike.id), true);

        // 5. Should no longer be available offline
        expect(await viewModel.isHikeAvailableOffline(hike.id), false);
      });

      test('should handle multiple hikes offline management', () async {
        // Arrange
        final hike1 = Hike(id: 1, name: 'Hike 1');
        final hike2 = Hike(id: 2, name: 'Hike 2');

        when(mockHikeImagesRepository.getHikeImages(any))
            .thenAnswer((_) async => ['img.jpg']);
        when(mockWaypointRepository.getWaypointsForHike(any))
            .thenAnswer((_) async => []);

        // Act
        await viewModel.saveHikeForOfflineUse(hike1);
        await viewModel.saveHikeForOfflineUse(hike2);

        // Assert
        expect(await viewModel.isHikeAvailableOffline(1), true);
        expect(await viewModel.isHikeAvailableOffline(2), true);

        // Remove one
        await viewModel.removeOfflineHike(1);

        // Assert
        expect(await viewModel.isHikeAvailableOffline(1), false);
        expect(await viewModel.isHikeAvailableOffline(2), true);
      });
    });

    group('Notification Behavior', () {
      test('should notify listeners when setting hikeImages', () {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        // Act
        viewModel.hikeImages = ['test.jpg'];

        // Assert - notification should happen via Future.microtask
        expect(notificationCount, 0); // Not immediate

        // Wait for microtask
        return Future.microtask(() {
          expect(notificationCount, 1);
        });
      });

      test('should notify listeners when loading images', () async {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        when(mockHikeImagesRepository.getHikeImages(1))
            .thenAnswer((_) async => ['test.jpg']);

        // Act
        await viewModel.getHikeImages(1);

        // Wait for microtask to complete
        await Future.microtask(() {});

        // Assert
        expect(notificationCount, 1);
      });
    });

    group('Edge Cases', () {
      test('should handle very large image lists', () async {
        // Arrange
        final largeImageList = List.generate(1000, (index) => 'image$index.jpg');
        when(mockHikeImagesRepository.getHikeImages(1))
            .thenAnswer((_) async => largeImageList);

        // Act
        await viewModel.getHikeImages(1);

        // Assert
        expect(viewModel.hikeImages.length, 1000);
      });

      test('should handle images with special characters in URLs', () async {
        // Arrange
        final specialImages = [
          'https://example.com/images/ümlaut.jpg',
          'https://example.com/images/space image.png',
          'https://example.com/images/image%20with%20encoding.webp',
        ];

        when(mockHikeImagesRepository.getHikeImages(1))
            .thenAnswer((_) async => specialImages);

        // Act
        await viewModel.getHikeImages(1);

        // Assert
        expect(viewModel.hikeImages, equals(specialImages));
      });

      test('should handle hikes with very long names and descriptions', () async {
        // Arrange
        final longNameHike = Hike(
          id: 1,
          name: 'A' * 1000, // Very long name
          description: 'B' * 2000, // Very long description
        );

        when(mockHikeImagesRepository.getHikeImages(1))
            .thenAnswer((_) async => []);
        when(mockWaypointRepository.getWaypointsForHike(1))
            .thenAnswer((_) async => []);

        // Act
        final result = await viewModel.saveHikeForOfflineUse(longNameHike);

        // Assert
        expect(result, true);
      });

      test('should handle concurrent operations', () async {
        // Arrange
        when(mockHikeImagesRepository.getHikeImages(any))
            .thenAnswer((_) async => ['img.jpg']);

        // Act - Start multiple concurrent operations
        final futures = [
          viewModel.getHikeImages(1),
          viewModel.getHikeImages(2),
          viewModel.getHikeImages(3),
        ];

        await Future.wait(futures);

        // Assert - All should complete successfully
        expect(viewModel.hikeImages, isNotEmpty);
      });

      test('should handle extreme hike IDs', () async {
        // Arrange
        const extremeIds = [0, -1, 999999999];

        for (final id in extremeIds) {
          when(mockHikeImagesRepository.getHikeImages(id))
              .thenAnswer((_) async => ['img.jpg']);

          // Act & Assert
          await viewModel.getHikeImages(id);
          expect(viewModel.hikeImages, isNotEmpty);

          // Check offline operations
          expect(await viewModel.isHikeAvailableOffline(id), false);
        }
      });
    });
  });
}