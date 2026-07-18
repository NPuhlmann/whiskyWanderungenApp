import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:whisky_hikes/data/repositories/offline_first_waypoint_repository.dart';
import 'package:whisky_hikes/data/services/connectivity/connectivity_service.dart';
import 'package:whisky_hikes/data/services/offline/offline_service.dart';

import '../../mocks/mock_repositories.dart';
import '../../test_helpers.dart';

void main() {
  group('OfflineFirstWaypointRepository', () {
    const hikeId = 42;

    late OfflineService offlineService;
    late MockBackendApiService mockBackendApi;
    late MockConnectivityService mockConnectivity;
    late OfflineFirstWaypointRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      offlineService = OfflineService();
      mockBackendApi = MockBackendApiService();
      mockConnectivity = MockConnectivityService();
      repository = OfflineFirstWaypointRepository(
        mockBackendApi,
        offlineService,
        mockConnectivity,
      );
    });

    void goOnline() {
      when(
        mockConnectivity.currentStatus,
      ).thenReturn(NetworkStatus.connectedWifi);
    }

    void goOffline() {
      when(
        mockConnectivity.currentStatus,
      ).thenReturn(NetworkStatus.disconnected);
    }

    test('should serve network data and cache it when online', () async {
      final networkWaypoints = TestHelpers.createSampleWaypoints(hikeId);
      goOnline();
      when(
        mockBackendApi.getWaypointsForHike(hikeId),
      ).thenAnswer((_) async => networkWaypoints);

      final result = await repository.getWaypointsForHike(hikeId);

      expect(result, equals(networkWaypoints));
      expect(
        await offlineService.getCachedWaypoints(hikeId),
        equals(networkWaypoints),
      );
    });

    test('should fall back to cache when the network call fails', () async {
      final cachedWaypoints = TestHelpers.createSampleWaypoints(hikeId);
      await offlineService.cacheWaypoints(hikeId, cachedWaypoints);

      goOnline();
      when(
        mockBackendApi.getWaypointsForHike(hikeId),
      ).thenThrow(Exception('Network timeout'));

      expect(
        await repository.getWaypointsForHike(hikeId),
        equals(cachedWaypoints),
      );
    });

    test(
      'should serve cache while offline without hitting the network',
      () async {
        final cachedWaypoints = TestHelpers.createSampleWaypoints(hikeId);
        await offlineService.cacheWaypoints(hikeId, cachedWaypoints);
        goOffline();

        expect(
          await repository.getWaypointsForHike(hikeId),
          equals(cachedWaypoints),
        );
        verifyNever(mockBackendApi.getWaypointsForHike(any));
      },
    );

    test('should throw when offline with an empty cache', () async {
      goOffline();

      expect(() => repository.getWaypointsForHike(hikeId), throwsException);
    });

    test('should drop cached waypoints on clearWaypointCache', () async {
      await offlineService.cacheWaypoints(
        hikeId,
        TestHelpers.createSampleWaypoints(hikeId),
      );

      await repository.clearWaypointCache();

      expect(await offlineService.getCachedWaypoints(hikeId), isNull);
    });
  });
}
