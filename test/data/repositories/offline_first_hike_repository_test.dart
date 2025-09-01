import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whisky_hikes/data/repositories/offline_first_hike_repository.dart';
import 'package:whisky_hikes/data/services/offline/offline_service.dart';
import 'package:whisky_hikes/data/services/connectivity/connectivity_service.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';

import '../../test_helpers.dart';
import '../services/database/backend_api_test.mocks.dart';

// Create mocks for our dependencies
class MockOfflineService extends Mock implements OfflineService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('OfflineFirstHikeRepository', () {
    late OfflineFirstHikeRepository repository;
    late MockBackendApiService mockBackendApi;
    late MockOfflineService mockOfflineService;
    late MockConnectivityService mockConnectivityService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      
      mockBackendApi = MockBackendApiService();
      mockOfflineService = MockOfflineService();
      mockConnectivityService = MockConnectivityService();
      
      repository = OfflineFirstHikeRepository(
        mockBackendApi,
        mockOfflineService,
        mockConnectivityService,
      );
    });

    group('Cache-First Strategy', () {
      test('should return cached hikes when available and skip network', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => cachedHikes);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.cacheFirst,
        );

        // Assert
        expect(result, equals(cachedHikes));
        verify(mockOfflineService.getCachedHikeList()).called(1);
        verifyNever(mockBackendApi.fetchHikes());
      });

      test('should fetch from network when cache is empty', () async {
        // Arrange
        final networkHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => null);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenAnswer((_) async => networkHikes);
        when(mockOfflineService.cacheHikeList(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.cacheFirst,
        );

        // Assert
        expect(result, equals(networkHikes));
        verify(mockBackendApi.fetchHikes()).called(1);
        verify(mockOfflineService.cacheHikeList(networkHikes)).called(1);
      });

      test('should fallback to cache when network fails', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => null).thenAnswer((_) async => cachedHikes);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.cacheFirst,
        );

        // Assert
        expect(result, equals(cachedHikes));
        verify(mockBackendApi.fetchHikes()).called(1);
        verify(mockOfflineService.getCachedHikeList()).called(2);
      });

      test('should throw exception when offline and no cache available', () async {
        // Arrange
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => null);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.disconnected);

        // Act & Assert
        expect(
          () async => await repository.getAllAvailableHikes(
            strategy: CacheStrategy.cacheFirst,
          ),
          throwsException,
        );
      });

      test('should force refresh when requested', () async {
        // Arrange
        final networkHikes = TestHelpers.createSampleHikes();
        
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenAnswer((_) async => networkHikes);
        when(mockOfflineService.cacheHikeList(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getAllAvailableHikes(
          forceRefresh: true,
          strategy: CacheStrategy.cacheFirst,
        );

        // Assert
        expect(result, equals(networkHikes));
        verify(mockBackendApi.fetchHikes()).called(1);
        verify(mockOfflineService.cacheHikeList(networkHikes)).called(1);
        verifyNever(mockOfflineService.getCachedHikeList());
      });
    });

    group('Network-First Strategy', () {
      test('should fetch from network first when online', () async {
        // Arrange
        final networkHikes = TestHelpers.createSampleHikes();
        
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenAnswer((_) async => networkHikes);
        when(mockOfflineService.cacheHikeList(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.networkFirst,
        );

        // Assert
        expect(result, equals(networkHikes));
        verify(mockBackendApi.fetchHikes()).called(1);
        verify(mockOfflineService.cacheHikeList(networkHikes)).called(1);
      });

      test('should fallback to cache when network fails', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenThrow(Exception('Network error'));
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => cachedHikes);

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.networkFirst,
        );

        // Assert
        expect(result, equals(cachedHikes));
        verify(mockBackendApi.fetchHikes()).called(1);
        verify(mockOfflineService.getCachedHikeList()).called(1);
      });

      test('should use cache when offline', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.disconnected);
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => cachedHikes);

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.networkFirst,
        );

        // Assert
        expect(result, equals(cachedHikes));
        verify(mockOfflineService.getCachedHikeList()).called(1);
        verifyNever(mockBackendApi.fetchHikes());
      });
    });

    group('Cache-Only Strategy', () {
      test('should return cached hikes when available', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => cachedHikes);

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.cacheOnly,
        );

        // Assert
        expect(result, equals(cachedHikes));
        verify(mockOfflineService.getCachedHikeList()).called(1);
        verifyNever(mockBackendApi.fetchHikes());
      });

      test('should throw exception when no cache available', () async {
        // Arrange
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () async => await repository.getAllAvailableHikes(
            strategy: CacheStrategy.cacheOnly,
          ),
          throwsException,
        );
      });
    });

    group('Network-Only Strategy', () {
      test('should fetch from network when online', () async {
        // Arrange
        final networkHikes = TestHelpers.createSampleHikes();
        
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenAnswer((_) async => networkHikes);
        when(mockOfflineService.cacheHikeList(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.networkOnly,
        );

        // Assert
        expect(result, equals(networkHikes));
        verify(mockBackendApi.fetchHikes()).called(1);
        verify(mockOfflineService.cacheHikeList(networkHikes)).called(1);
      });

      test('should throw exception when offline', () async {
        // Arrange
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.disconnected);

        // Act & Assert
        expect(
          () async => await repository.getAllAvailableHikes(
            strategy: CacheStrategy.networkOnly,
          ),
          throwsException,
        );
      });
    });

    group('Stale-While-Revalidate Strategy', () {
      test('should return cache immediately and update in background', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => cachedHikes);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.staleWhileRevalidate,
        );

        // Assert
        expect(result, equals(cachedHikes));
        verify(mockOfflineService.getCachedHikeList()).called(1);
        // Note: Background update is fire-and-forget, so we don't verify it here
      });

      test('should fallback to cache-first when no immediate cache', () async {
        // Arrange
        final networkHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => null);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenAnswer((_) async => networkHikes);
        when(mockOfflineService.cacheHikeList(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getAllAvailableHikes(
          strategy: CacheStrategy.staleWhileRevalidate,
        );

        // Assert
        expect(result, equals(networkHikes));
        verify(mockBackendApi.fetchHikes()).called(1);
      });
    });

    group('User Hikes', () {
      test('should cache and retrieve user-specific hikes', () async {
        // Arrange
        const userId = 'user123';
        final userHikes = [TestHelpers.createTestHike(id: 1, name: 'User Hike')];
        
        when(mockOfflineService.getCachedHikeList(listKey: 'user_$userId'))
            .thenAnswer((_) async => userHikes);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);

        // Act
        final result = await repository.getUserHikes(userId);

        // Assert
        expect(result, equals(userHikes));
        verify(mockOfflineService.getCachedHikeList(listKey: 'user_$userId')).called(1);
      });

      test('should fetch user hikes from network when cache empty', () async {
        // Arrange
        const userId = 'user123';
        final networkUserHikes = [TestHelpers.createTestHike(id: 1, name: 'Network User Hike')];
        
        when(mockOfflineService.getCachedHikeList(listKey: 'user_$userId'))
            .thenAnswer((_) async => null);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchUserHikes(userId))
            .thenAnswer((_) async => networkUserHikes);
        when(mockOfflineService.cacheHikeList(any, listKey: anyNamed('listKey')))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getUserHikes(userId);

        // Assert
        expect(result, equals(networkUserHikes));
        verify(mockBackendApi.fetchUserHikes(userId)).called(1);
        verify(mockOfflineService.cacheHikeList(networkUserHikes, listKey: 'user_$userId')).called(1);
      });
    });

    group('Single Hike Retrieval', () {
      test('should retrieve single hike from cache', () async {
        // Arrange
        const hikeId = 1;
        final cachedHike = TestHelpers.createTestHike(id: hikeId, name: 'Cached Hike');
        
        when(mockOfflineService.getCachedHike(hikeId))
            .thenAnswer((_) async => cachedHike);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);

        // Act
        final result = await repository.getHike(hikeId);

        // Assert
        expect(result, equals(cachedHike));
        verify(mockOfflineService.getCachedHike(hikeId)).called(1);
      });

      test('should fetch single hike from network when not in cache', () async {
        // Arrange
        const hikeId = 1;
        final networkHikes = TestHelpers.createSampleHikes();
        final targetHike = networkHikes.firstWhere((h) => h.id == hikeId);
        
        when(mockOfflineService.getCachedHike(hikeId))
            .thenAnswer((_) async => null);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenAnswer((_) async => networkHikes);
        when(mockOfflineService.cacheHike(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getHike(hikeId);

        // Assert
        expect(result, equals(targetHike));
        verify(mockBackendApi.fetchHikes()).called(1);
        verify(mockOfflineService.cacheHike(targetHike)).called(1);
      });
    });

    group('Cache Management', () {
      test('should clear hike cache', () async {
        // Arrange
        when(mockOfflineService.clearCache(type: 'hike'))
            .thenAnswer((_) async {});

        // Act
        await repository.clearHikeCache();

        // Assert
        verify(mockOfflineService.clearCache(type: 'hike')).called(1);
      });

      test('should check offline hike availability', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => cachedHikes);

        // Act
        final hasOfflineHikes = await repository.hasOfflineHikes();

        // Assert
        expect(hasOfflineHikes, isTrue);
        verify(mockOfflineService.getCachedHikeList()).called(1);
      });

      test('should check offline user hike availability', () async {
        // Arrange
        const userId = 'user123';
        final cachedUserHikes = [TestHelpers.createTestHike()];
        
        when(mockOfflineService.getCachedHikeList(listKey: 'user_$userId'))
            .thenAnswer((_) async => cachedUserHikes);

        // Act
        final hasOfflineUserHikes = await repository.hasOfflineUserHikes(userId);

        // Assert
        expect(hasOfflineUserHikes, isTrue);
        verify(mockOfflineService.getCachedHikeList(listKey: 'user_$userId')).called(1);
      });

      test('should provide repository statistics', () async {
        // Arrange
        final cacheStats = {'totalFiles': 10, 'totalSizeMB': 5.0};
        final networkStats = {'isOnline': true, 'networkType': 'wifi'};
        
        when(mockOfflineService.getCacheStats())
            .thenAnswer((_) async => cacheStats);
        when(mockConnectivityService.getNetworkStats())
            .thenReturn(networkStats);
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => TestHelpers.createSampleHikes());

        // Act
        final stats = await repository.getRepositoryStats();

        // Assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['cache'], equals(cacheStats));
        expect(stats['network'], equals(networkStats));
        expect(stats['hasOfflineHikes'], equals(true));
        expect(stats['repositoryType'], equals('OfflineFirstHikeRepository'));
      });
    });

    group('Error Handling', () {
      test('should handle cache errors gracefully', () async {
        // Arrange
        when(mockOfflineService.getCachedHikeList())
            .thenThrow(Exception('Cache error'));
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenAnswer((_) async => TestHelpers.createSampleHikes());
        when(mockOfflineService.cacheHikeList(any))
            .thenAnswer((_) async {});

        // Act & Assert - Should not throw and fallback to network
        final result = await repository.getAllAvailableHikes();
        expect(result, isNotNull);
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        final cachedHikes = TestHelpers.createSampleHikes();
        
        when(mockOfflineService.getCachedHikeList())
            .thenAnswer((_) async => null).thenAnswer((_) async => cachedHikes);
        when(mockConnectivityService.currentStatus)
            .thenReturn(NetworkStatus.connected_wifi);
        when(mockBackendApi.fetchHikes())
            .thenThrow(Exception('Network error'));

        // Act - Should fallback to cache
        final result = await repository.getAllAvailableHikes();

        // Assert
        expect(result, equals(cachedHikes));
      });
    });
  });
}