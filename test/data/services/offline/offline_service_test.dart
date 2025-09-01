import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisky_hikes/data/services/offline/offline_service.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import '../../../test_helpers.dart';

void main() {
  group('OfflineService', () {
    late OfflineService offlineService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      offlineService = OfflineService();
    });

    group('Generic Cache Operations', () {
      test('should cache and retrieve data successfully', () async {
        // Arrange
        final testData = {'name': 'Test', 'value': 42};
        
        // Act
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'test',
          id: '1',
          data: testData,
          toJson: (data) => data,
        );
        
        final retrieved = await offlineService.getCachedData<Map<String, dynamic>>(
          type: 'test',
          id: '1',
          fromJson: (json) => json,
        );
        
        // Assert
        expect(retrieved, equals(testData));
      });

      test('should return null for non-existent cache', () async {
        // Act
        final result = await offlineService.getCachedData<Map<String, dynamic>>(
          type: 'test',
          id: 'non-existent',
          fromJson: (json) => json,
        );
        
        // Assert
        expect(result, isNull);
      });

      test('should handle cache expiration', () async {
        // Arrange
        final testData = {'name': 'Test'};
        
        // Act - Cache with very short TTL
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'test',
          id: '1',
          data: testData,
          toJson: (data) => data,
          ttl: const Duration(milliseconds: 1),
        );
        
        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 2));
        
        final result = await offlineService.getCachedData<Map<String, dynamic>>(
          type: 'test',
          id: '1',
          fromJson: (json) => json,
          ttl: const Duration(milliseconds: 1),
        );
        
        // Assert
        expect(result, isNull);
      });

      test('should cache and retrieve data lists', () async {
        // Arrange
        final testDataList = [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
          {'id': 3, 'name': 'Item 3'},
        ];
        
        // Act
        await offlineService.cacheDataList<Map<String, dynamic>>(
          type: 'test',
          listKey: 'all',
          data: testDataList,
          toJson: (data) => data,
        );
        
        final retrieved = await offlineService.getCachedDataList<Map<String, dynamic>>(
          type: 'test',
          listKey: 'all',
          fromJson: (json) => json,
        );
        
        // Assert
        expect(retrieved, equals(testDataList));
      });
    });

    group('Hike-specific Operations', () {
      test('should cache and retrieve single hike', () async {
        // Arrange
        final hike = TestHelpers.createTestHike(id: 1, name: 'Test Hike');
        
        // Act
        await offlineService.cacheHike(hike);
        final retrieved = await offlineService.getCachedHike(1);
        
        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(hike.id));
        expect(retrieved.name, equals(hike.name));
      });

      test('should cache and retrieve hike lists', () async {
        // Arrange
        final hikes = TestHelpers.createSampleHikes();
        
        // Act
        await offlineService.cacheHikeList(hikes);
        final retrieved = await offlineService.getCachedHikeList();
        
        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.length, equals(hikes.length));
        expect(retrieved.first.id, equals(hikes.first.id));
      });

      test('should cache multiple hike lists with different keys', () async {
        // Arrange
        final allHikes = TestHelpers.createSampleHikes();
        final userHikes = [allHikes.first];
        
        // Act
        await offlineService.cacheHikeList(allHikes, listKey: 'all');
        await offlineService.cacheHikeList(userHikes, listKey: 'user_123');
        
        final retrievedAll = await offlineService.getCachedHikeList(listKey: 'all');
        final retrievedUser = await offlineService.getCachedHikeList(listKey: 'user_123');
        
        // Assert
        expect(retrievedAll!.length, equals(allHikes.length));
        expect(retrievedUser!.length, equals(1));
        expect(retrievedUser.first.id, equals(userHikes.first.id));
      });
    });

    group('Waypoint-specific Operations', () {
      test('should cache and retrieve waypoints for hike', () async {
        // Arrange
        final waypoints = TestHelpers.createTestWaypoints(hikeId: 1);
        
        // Act
        await offlineService.cacheWaypoints(1, waypoints);
        final retrieved = await offlineService.getCachedWaypoints(1);
        
        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.length, equals(waypoints.length));
        expect(retrieved.first.id, equals(waypoints.first.id));
      });

      test('should return null for waypoints of non-cached hike', () async {
        // Act
        final result = await offlineService.getCachedWaypoints(999);
        
        // Assert
        expect(result, isNull);
      });
    });

    group('Cache Validation', () {
      test('should correctly validate cache existence and freshness', () async {
        // Arrange
        final testData = {'test': 'data'};
        
        // Act - Cache data
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'test',
          id: '1',
          data: testData,
          toJson: (data) => data,
        );
        
        // Assert - Should exist
        final hasCache = await offlineService.hasCachedData('test', '1');
        expect(hasCache, isTrue);
        
        // Assert - Should not exist for different ID
        final hasWrongCache = await offlineService.hasCachedData('test', '2');
        expect(hasWrongCache, isFalse);
      });

      test('should correctly validate list cache existence', () async {
        // Arrange
        final testDataList = [{'test': 'data'}];
        
        // Act
        await offlineService.cacheDataList<Map<String, dynamic>>(
          type: 'test',
          listKey: 'all',
          data: testDataList,
          toJson: (data) => data,
        );
        
        // Assert
        final hasCache = await offlineService.hasCachedDataList('test', 'all');
        expect(hasCache, isTrue);
        
        final hasWrongCache = await offlineService.hasCachedDataList('test', 'other');
        expect(hasWrongCache, isFalse);
      });
    });

    group('Cache Management', () {
      test('should clear cache by type', () async {
        // Arrange
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'test1',
          id: '1',
          data: {'data': 1},
          toJson: (data) => data,
        );
        
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'test2',
          id: '1',
          data: {'data': 2},
          toJson: (data) => data,
        );
        
        // Act
        await offlineService.clearCache(type: 'test1');
        
        // Assert
        final result1 = await offlineService.getCachedData<Map<String, dynamic>>(
          type: 'test1',
          id: '1',
          fromJson: (json) => json,
        );
        
        final result2 = await offlineService.getCachedData<Map<String, dynamic>>(
          type: 'test2',
          id: '1',
          fromJson: (json) => json,
        );
        
        expect(result1, isNull);
        expect(result2, isNotNull);
      });

      test('should clear all cache', () async {
        // Arrange
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'test1',
          id: '1',
          data: {'data': 1},
          toJson: (data) => data,
        );
        
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'test2',
          id: '1',
          data: {'data': 2},
          toJson: (data) => data,
        );
        
        // Act
        await offlineService.clearCache();
        
        // Assert
        final result1 = await offlineService.getCachedData<Map<String, dynamic>>(
          type: 'test1',
          id: '1',
          fromJson: (json) => json,
        );
        
        final result2 = await offlineService.getCachedData<Map<String, dynamic>>(
          type: 'test2',
          id: '1',
          fromJson: (json) => json,
        );
        
        expect(result1, isNull);
        expect(result2, isNull);
      });

      test('should provide cache statistics', () async {
        // Arrange
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'hike',
          id: '1',
          data: {'name': 'Hike 1'},
          toJson: (data) => data,
        );
        
        await offlineService.cacheData<Map<String, dynamic>>(
          type: 'waypoint',
          id: '1',
          data: {'name': 'Waypoint 1'},
          toJson: (data) => data,
        );
        
        // Act
        final stats = await offlineService.getCacheStats();
        
        // Assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['totalCacheKeys'], isA<int>());
        expect(stats['typeStats'], isA<Map<String, int>>());
        expect(stats['typeStats']['hike'], equals(1));
        expect(stats['typeStats']['waypoint'], equals(1));
      });
    });

    group('Error Handling', () {
      test('should handle invalid JSON gracefully', () async {
        // Act & Assert - Should not throw
        expect(
          () async => await offlineService.getCachedData<Map<String, dynamic>>(
            type: 'invalid',
            id: '1',
            fromJson: (json) => throw Exception('Invalid JSON'),
          ),
          isNot(throwsException),
        );
      });

      test('should return empty stats on error', () async {
        // This test is more about ensuring the service doesn't crash
        // Act
        final stats = await offlineService.getCacheStats();
        
        // Assert - Should return valid structure even if empty
        expect(stats, isA<Map<String, dynamic>>());
      });
    });
  });
}