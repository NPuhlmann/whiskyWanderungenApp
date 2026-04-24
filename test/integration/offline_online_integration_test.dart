import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whisky_hikes/data/services/offline/offline_service.dart';
import 'package:whisky_hikes/data/services/connectivity/connectivity_service.dart';
import 'package:whisky_hikes/data/services/sync/data_sync_service.dart';
import 'package:whisky_hikes/data/repositories/offline_first_hike_repository.dart';
import 'package:whisky_hikes/data/repositories/offline_first_waypoint_repository.dart';

import '../test_helpers.dart';
import '../data/services/database/backend_api_test.mocks.dart';

// Create mocks for dependencies
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('Offline to Online Integration Tests', () {
    late OfflineService offlineService;
    late MockBackendApiService mockBackendApi;
    late MockConnectivityService mockConnectivityService;
    late DataSyncService dataSyncService;
    late OfflineFirstHikeRepository hikeRepository;
    late OfflineFirstWaypointRepository waypointRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      offlineService = OfflineService();
      mockBackendApi = MockBackendApiService();
      mockConnectivityService = MockConnectivityService();
      dataSyncService = DataSyncService.instance;

      hikeRepository = OfflineFirstHikeRepository(
        mockBackendApi,
        offlineService,
        mockConnectivityService,
      );

      waypointRepository = OfflineFirstWaypointRepository(
        mockBackendApi,
        offlineService,
        mockConnectivityService,
      );
    });

    tearDown(() async {
      await dataSyncService.dispose();
    });

    group('Hike Repository Offline-to-Online Flow', () {
      testWidgets('should transition from offline to online gracefully', (
        tester,
      ) async {
        // Phase 1: Offline - Use cached data
        final cachedHikes = TestHelpers.createSampleHikes();
        await offlineService.cacheHikeList(cachedHikes);

        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.disconnected);

        // Act - Get hikes while offline
        final offlineResult = await hikeRepository.getAllAvailableHikes(
          strategy: CacheStrategy.cacheFirst,
        );

        // Assert - Should return cached data
        expect(offlineResult, equals(cachedHikes));
        expect(offlineResult.length, equals(cachedHikes.length));

        // Phase 2: Online - Fetch fresh data and update cache
        final freshHikes = TestHelpers.createSampleHikes()
          ..add(TestHelpers.createTestHike(id: 999, name: 'Fresh Hike'));

        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.connectedWifi);
        when(mockBackendApi.fetchHikes()).thenAnswer((_) async => freshHikes);

        // Act - Force refresh now that we're online
        final onlineResult = await hikeRepository.getAllAvailableHikes(
          forceRefresh: true,
          strategy: CacheStrategy.cacheFirst,
        );

        // Assert - Should return fresh data and update cache
        expect(onlineResult, equals(freshHikes));
        expect(onlineResult.length, greaterThan(offlineResult.length));

        // Verify cache was updated
        final updatedCache = await offlineService.getCachedHikeList();
        expect(updatedCache, equals(freshHikes));
      });

      testWidgets(
        'should handle network failures gracefully during transition',
        (tester) async {
          // Phase 1: Setup cached data
          final cachedHikes = TestHelpers.createSampleHikes();
          await offlineService.cacheHikeList(cachedHikes);

          // Phase 2: Online but network fails
          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.connectedWifi);
          when(
            mockBackendApi.fetchHikes(),
          ).thenThrow(Exception('Network timeout'));

          // Act - Try to get fresh data but network fails
          final result = await hikeRepository.getAllAvailableHikes(
            forceRefresh: true,
            strategy: CacheStrategy.cacheFirst,
          );

          // Assert - Should fallback to cached data
          expect(result, equals(cachedHikes));
        },
      );

      testWidgets('should sync user-specific data correctly', (tester) async {
        // Phase 1: Cache user hikes offline
        const userId = 'user123';
        final cachedUserHikes = [
          TestHelpers.createTestHike(id: 1, name: 'User Hike 1'),
        ];
        await offlineService.cacheHikeList(
          cachedUserHikes,
          listKey: 'user_$userId',
        );

        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.disconnected);

        // Act - Get user hikes offline
        final offlineUserHikes = await hikeRepository.getUserHikes(userId);
        expect(offlineUserHikes, equals(cachedUserHikes));

        // Phase 2: Go online and sync
        final freshUserHikes = [
          ...cachedUserHikes,
          TestHelpers.createTestHike(id: 2, name: 'User Hike 2'),
        ];

        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.connectedWifi);
        when(
          mockBackendApi.fetchUserHikes(userId),
        ).thenAnswer((_) async => freshUserHikes);

        // Act - Refresh user hikes online
        final onlineUserHikes = await hikeRepository.getUserHikes(
          userId,
          forceRefresh: true,
        );

        // Assert - Should get fresh user hikes
        expect(onlineUserHikes, equals(freshUserHikes));
        expect(onlineUserHikes.length, greaterThan(offlineUserHikes.length));
      });
    });

    group('Waypoint Repository Offline-to-Online Flow', () {
      testWidgets(
        'should handle waypoint modifications during offline-to-online transition',
        (tester) async {
          // Phase 1: Cache waypoints offline
          const hikeId = 1;
          final cachedWaypoints = TestHelpers.createTestWaypoints(
            hikeId: hikeId,
          );
          await offlineService.cacheWaypoints(hikeId, cachedWaypoints);

          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.disconnected);

          // Act - Get waypoints offline
          final offlineWaypoints = await waypointRepository.getWaypointsForHike(
            hikeId,
            strategy: CacheStrategy.cacheFirst,
          );
          expect(offlineWaypoints, equals(cachedWaypoints));

          // Phase 2: Make offline modifications
          final newWaypoint = TestHelpers.createTestWaypoint(
            id: 999,
            name: 'Offline Added',
          );

          // This would normally queue for sync
          await waypointRepository.addWaypoint(
            newWaypoint,
            hikeId,
            syncWhenOnline: true,
          );

          // Phase 3: Go online
          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.connectedWifi);
          when(
            mockBackendApi.addWaypoint(
              any,
              any,
              orderIndex: anyNamed('orderIndex'),
            ),
          ).thenAnswer((_) async {});
          when(
            mockBackendApi.getWaypointsForHike(hikeId),
          ).thenAnswer((_) async => [...cachedWaypoints, newWaypoint]);

          // Act - Sync should happen automatically, then refresh
          final onlineWaypoints = await waypointRepository.getWaypointsForHike(
            hikeId,
            forceRefresh: true,
            strategy: CacheStrategy.networkFirst,
          );

          // Assert - Should include the new waypoint
          expect(onlineWaypoints.length, greaterThan(offlineWaypoints.length));
          expect(onlineWaypoints.any((w) => w.id == newWaypoint.id), isTrue);
        },
      );

      testWidgets(
        'should handle waypoint deletions during offline-to-online transition',
        (tester) async {
          // Phase 1: Setup waypoints
          const hikeId = 1;
          final initialWaypoints = TestHelpers.createTestWaypoints(
            hikeId: hikeId,
          );
          await offlineService.cacheWaypoints(hikeId, initialWaypoints);

          // Phase 2: Delete waypoint offline
          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.disconnected);

          final waypointToDelete = initialWaypoints.first;
          await waypointRepository.deleteWaypoint(
            waypointToDelete.id,
            hikeId,
            syncWhenOnline: true,
          );

          // Check local cache was updated
          final localWaypoints = await offlineService.getCachedWaypoints(
            hikeId,
          );
          expect(
            localWaypoints!.any((w) => w.id == waypointToDelete.id),
            isFalse,
          );

          // Phase 3: Go online and sync
          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.connectedWifi);
          when(
            mockBackendApi.deleteWaypoint(waypointToDelete.id, hikeId),
          ).thenAnswer((_) async {});

          final remainingWaypoints = initialWaypoints
              .where((w) => w.id != waypointToDelete.id)
              .toList();
          when(
            mockBackendApi.getWaypointsForHike(hikeId),
          ).thenAnswer((_) async => remainingWaypoints);

          // Act - Refresh after sync
          final onlineWaypoints = await waypointRepository.getWaypointsForHike(
            hikeId,
            forceRefresh: true,
            strategy: CacheStrategy.networkFirst,
          );

          // Assert - Deleted waypoint should not be present
          expect(
            onlineWaypoints.any((w) => w.id == waypointToDelete.id),
            isFalse,
          );
          expect(onlineWaypoints.length, equals(remainingWaypoints.length));
        },
      );
    });

    group('Data Sync Service Integration', () {
      testWidgets('should initialize and sync pending items', (tester) async {
        // Initialize sync service
        await dataSyncService.initialize(
          backendApiService: mockBackendApi,
          hikeRepository: hikeRepository,
          waypointRepository: waypointRepository,
        );

        // Add some items to sync queue
        final syncItem = SyncItem(
          type: 'waypoint',
          action: 'add',
          data: TestHelpers.createTestWaypoint().toJson(),
          hikeId: 1,
        );

        await dataSyncService.queueForSync(syncItem);

        // Check queue has items
        final queue = await dataSyncService.getSyncQueue();
        expect(queue, isNotEmpty);
        expect(queue.first.type, equals('waypoint'));
        expect(queue.first.action, equals('add'));

        // Simulate going online
        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.connectedWifi);
        when(
          mockBackendApi.addWaypoint(
            any,
            any,
            orderIndex: anyNamed('orderIndex'),
          ),
        ).thenAnswer((_) async {});

        // Trigger sync
        final result = await dataSyncService.syncNow();

        // Assert sync completed
        expect(result, anyOf([SyncResult.success, SyncResult.partialSuccess]));
      });

      testWidgets('should provide meaningful sync statistics', (tester) async {
        // Initialize sync service
        await dataSyncService.initialize(
          backendApiService: mockBackendApi,
          hikeRepository: hikeRepository,
          waypointRepository: waypointRepository,
        );

        // Get stats
        final stats = await dataSyncService.getSyncStats();

        // Assert stats structure
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('queueSize'), isTrue);
        expect(stats.containsKey('isActive'), isTrue);
        expect(stats.containsKey('isOnline'), isTrue);
        expect(stats['queueSize'], isA<int>());
        expect(stats['isActive'], isA<bool>());
      });

      testWidgets('should handle sync failures gracefully', (tester) async {
        // Initialize sync service
        await dataSyncService.initialize(
          backendApiService: mockBackendApi,
          hikeRepository: hikeRepository,
          waypointRepository: waypointRepository,
        );

        // Add sync item that will fail
        final syncItem = SyncItem(
          type: 'waypoint',
          action: 'add',
          data: TestHelpers.createTestWaypoint().toJson(),
          hikeId: 1,
        );

        await dataSyncService.queueForSync(syncItem);

        // Mock network failure
        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.connectedWifi);
        when(
          mockBackendApi.addWaypoint(
            any,
            any,
            orderIndex: anyNamed('orderIndex'),
          ),
        ).thenThrow(Exception('Network error'));

        // Trigger sync
        final result = await dataSyncService.syncNow();

        // Assert sync failed but didn't crash
        expect(result, anyOf([SyncResult.error, SyncResult.partialSuccess]));

        // Queue should still contain failed items
        final remainingQueue = await dataSyncService.getSyncQueue();
        expect(remainingQueue, isNotEmpty);
      });
    });

    group('Complex Integration Scenarios', () {
      testWidgets('should handle complete offline-to-online workflow', (
        tester,
      ) async {
        // Phase 1: Start offline with cached data
        final cachedHikes = TestHelpers.createSampleHikes();
        final cachedWaypoints = TestHelpers.createTestWaypoints(hikeId: 1);

        await offlineService.cacheHikeList(cachedHikes);
        await offlineService.cacheWaypoints(1, cachedWaypoints);

        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.disconnected);

        // Get data offline
        final offlineHikes = await hikeRepository.getAllAvailableHikes();
        final offlineWaypoints = await waypointRepository.getWaypointsForHike(
          1,
        );

        expect(offlineHikes, equals(cachedHikes));
        expect(offlineWaypoints, equals(cachedWaypoints));

        // Phase 2: Make offline modifications
        final newWaypoint = TestHelpers.createTestWaypoint(
          id: 999,
          name: 'Offline Added',
        );
        await waypointRepository.addWaypoint(
          newWaypoint,
          1,
          syncWhenOnline: true,
        );

        // Phase 3: Go online
        when(
          mockConnectivityService.currentStatus,
        ).thenReturn(NetworkStatus.connectedWifi);

        // Setup online responses
        final freshHikes = [
          ...cachedHikes,
          TestHelpers.createTestHike(id: 999, name: 'Fresh Hike'),
        ];
        final freshWaypoints = [...cachedWaypoints, newWaypoint];

        when(mockBackendApi.fetchHikes()).thenAnswer((_) async => freshHikes);
        when(
          mockBackendApi.getWaypointsForHike(1),
        ).thenAnswer((_) async => freshWaypoints);
        when(
          mockBackendApi.addWaypoint(
            any,
            any,
            orderIndex: anyNamed('orderIndex'),
          ),
        ).thenAnswer((_) async {});

        // Initialize sync service
        await dataSyncService.initialize(
          backendApiService: mockBackendApi,
          hikeRepository: hikeRepository,
          waypointRepository: waypointRepository,
        );

        // Phase 4: Sync and refresh all data
        await dataSyncService.syncNow();

        final onlineHikes = await hikeRepository.getAllAvailableHikes(
          forceRefresh: true,
        );
        final onlineWaypoints = await waypointRepository.getWaypointsForHike(
          1,
          forceRefresh: true,
        );

        // Assert everything is in sync
        expect(onlineHikes, equals(freshHikes));
        expect(onlineWaypoints, equals(freshWaypoints));
        expect(onlineHikes.length, greaterThan(offlineHikes.length));
        expect(onlineWaypoints.length, greaterThan(cachedWaypoints.length));
      });

      testWidgets(
        'should maintain data consistency during network interruptions',
        (tester) async {
          // Start online
          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.connectedWifi);

          final initialHikes = TestHelpers.createSampleHikes();
          when(
            mockBackendApi.fetchHikes(),
          ).thenAnswer((_) async => initialHikes);

          // Load data online
          final hikes = await hikeRepository.getAllAvailableHikes();
          expect(hikes, equals(initialHikes));

          // Go offline during operation
          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.disconnected);

          // Should still be able to access cached data
          final cachedHikes = await hikeRepository.getAllAvailableHikes(
            strategy: CacheStrategy.cacheFirst,
          );
          expect(cachedHikes, equals(initialHikes));

          // Come back online with different data
          when(
            mockConnectivityService.currentStatus,
          ).thenReturn(NetworkStatus.connectedWifi);

          final updatedHikes = [
            ...initialHikes,
            TestHelpers.createTestHike(id: 999, name: 'Updated'),
          ];
          when(
            mockBackendApi.fetchHikes(),
          ).thenAnswer((_) async => updatedHikes);

          // Should get updated data and cache should be refreshed
          final freshHikes = await hikeRepository.getAllAvailableHikes(
            forceRefresh: true,
          );
          expect(freshHikes, equals(updatedHikes));
          expect(freshHikes.length, greaterThan(cachedHikes.length));
        },
      );
    });
  });
}
