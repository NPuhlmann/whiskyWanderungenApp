import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/hike_map/hike_map_view_model.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HikeMapViewModel', () {
    late MockWaypointRepository mockRepository;

    final testWaypoints = [
      const Waypoint(
        id: 1,
        hikeId: 42,
        name: 'Glen Ord Station',
        description: 'A peaty highland dram awaits.',
        latitude: 51.16,
        longitude: 10.44,
        orderIndex: 0,
        images: [],
        isVisited: false,
      ),
      const Waypoint(
        id: 2,
        hikeId: 42,
        name: 'Glenmorangie Outlook',
        description: 'Floral and fruity views.',
        latitude: 51.17,
        longitude: 10.46,
        orderIndex: 1,
        images: [],
        isVisited: true,
      ),
      const Waypoint(
        id: 3,
        hikeId: 42,
        name: 'Dalmore Crossing',
        description: 'Rich and sherried finish.',
        latitude: 51.18,
        longitude: 10.48,
        orderIndex: 2,
        images: [],
        isVisited: false,
      ),
    ];

    setUp(() {
      mockRepository = MockWaypointRepository();
    });

    HikeMapViewModel buildViewModel() {
      return HikeMapViewModel(hikeId: 42, waypointRepository: mockRepository);
    }

    group('Initial state', () {
      test('starts with no selected waypoint', () {
        final vm = buildViewModel();
        expect(vm.selectedWaypoint, isNull);
      });

      test('starts with unknown location permission status', () {
        final vm = buildViewModel();
        expect(vm.locationPermissionStatus, LocationPermissionStatus.unknown);
      });

      test('starts not loading', () {
        final vm = buildViewModel();
        expect(vm.isLoading, isFalse);
      });

      test('starts with no error', () {
        final vm = buildViewModel();
        expect(vm.error, isNull);
      });

      test('starts with empty waypoints', () {
        final vm = buildViewModel();
        expect(vm.waypoints, isEmpty);
      });
    });

    group('selectWaypoint', () {
      test('sets selectedWaypoint and notifies listeners', () {
        final vm = buildViewModel();
        var notified = false;
        vm.addListener(() => notified = true);

        vm.selectWaypoint(testWaypoints[0]);

        expect(vm.selectedWaypoint, equals(testWaypoints[0]));
        expect(notified, isTrue);
      });

      test('deselects by passing null', () {
        final vm = buildViewModel();
        vm.selectWaypoint(testWaypoints[0]);

        vm.selectWaypoint(null);

        expect(vm.selectedWaypoint, isNull);
      });

      test('replacing selection with a different waypoint works', () {
        final vm = buildViewModel();
        vm.selectWaypoint(testWaypoints[0]);
        vm.selectWaypoint(testWaypoints[1]);

        expect(vm.selectedWaypoint?.id, equals(2));
      });

      test('notifies listeners on deselect', () {
        final vm = buildViewModel();
        vm.selectWaypoint(testWaypoints[0]);

        var notified = false;
        vm.addListener(() => notified = true);

        vm.selectWaypoint(null);

        expect(notified, isTrue);
      });
    });

    group('loadWaypoints', () {
      test('sets isLoading during fetch', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);

        final vm = buildViewModel();
        final loadFuture = vm.loadWaypoints();

        // isLoading should be true immediately after call
        expect(vm.isLoading, isTrue);
        await loadFuture;
        expect(vm.isLoading, isFalse);
      });

      test('populates waypoints on success', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);

        final vm = buildViewModel();
        await vm.loadWaypoints();

        // 3 real waypoints have spread coords, so they should be kept as-is
        expect(vm.waypoints.length, greaterThanOrEqualTo(3));
        expect(vm.error, isNull);
      });

      test('sets error and clears isLoading on failure', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenThrow(Exception('network error'));

        final vm = buildViewModel();
        await vm.loadWaypoints();

        expect(vm.error, contains('network error'));
        expect(vm.isLoading, isFalse);
      });

      test('clears previous error on successful retry', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenThrow(Exception('first error'));

        final vm = buildViewModel();
        await vm.loadWaypoints();
        expect(vm.error, isNotNull);

        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);
        await vm.loadWaypoints();

        expect(vm.error, isNull);
      });

      test('generates test data when repository returns empty list', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => []);

        final vm = buildViewModel();
        await vm.loadWaypoints();

        expect(vm.waypoints, isNotEmpty);
      });
    });

    group('toggleWaypointVisited', () {
      test('flips isVisited for a waypoint', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);

        final vm = buildViewModel();
        await vm.loadWaypoints();

        final wp = vm.waypoints.firstWhere((w) => w.id == 1);
        expect(wp.isVisited, isFalse);

        await vm.toggleWaypointVisited(wp);

        final updated = vm.waypoints.firstWhere((w) => w.id == 1);
        expect(updated.isVisited, isTrue);
      });

      test('keeps selectedWaypoint in sync when toggling selected POI', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);

        final vm = buildViewModel();
        await vm.loadWaypoints();

        final wp = vm.waypoints.firstWhere((w) => w.id == 1);
        vm.selectWaypoint(wp);

        await vm.toggleWaypointVisited(wp);

        expect(vm.selectedWaypoint?.isVisited, isTrue);
        expect(vm.selectedWaypoint?.id, equals(1));
      });

      test('does not change selectedWaypoint when toggling a different POI',
          () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);

        final vm = buildViewModel();
        await vm.loadWaypoints();

        final wp1 = vm.waypoints.firstWhere((w) => w.id == 1);
        final wp2 = vm.waypoints.firstWhere((w) => w.id == 2);
        vm.selectWaypoint(wp1);

        await vm.toggleWaypointVisited(wp2);

        expect(vm.selectedWaypoint?.id, equals(1));
      });

      test('notifies listeners after toggle', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);

        final vm = buildViewModel();
        await vm.loadWaypoints();

        var notified = false;
        vm.addListener(() => notified = true);

        final wp = vm.waypoints.firstWhere((w) => w.id == 1);
        await vm.toggleWaypointVisited(wp);

        expect(notified, isTrue);
      });
    });

    group('getCurrentCenter', () {
      test('returns Germany fallback when no waypoints', () {
        final vm = buildViewModel();
        final center = vm.getCurrentCenter();
        expect(center.latitude, closeTo(51.1657, 0.001));
        expect(center.longitude, closeTo(10.4515, 0.001));
      });

      test('returns average of all waypoint coords', () async {
        when(mockRepository.getWaypointsForHike(42))
            .thenAnswer((_) async => testWaypoints);

        final vm = buildViewModel();
        await vm.loadWaypoints();

        // Use only the loaded waypoints (may include generated ones)
        final coords = vm.waypoints;
        final expectedLat =
            coords.map((w) => w.latitude).reduce((a, b) => a + b) /
            coords.length;
        final expectedLng =
            coords.map((w) => w.longitude).reduce((a, b) => a + b) /
            coords.length;

        final center = vm.getCurrentCenter();
        expect(center.latitude, closeTo(expectedLat, 0.001));
        expect(center.longitude, closeTo(expectedLng, 0.001));
      });
    });
  });
}
