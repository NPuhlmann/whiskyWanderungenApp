import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/hike_map/hike_map_view_model.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

import '../../../mocks/mock_repositories.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HikeMapViewModel waypoint selection', () {
    late MockOfflineFirstWaypointRepository mockRepository;

    const waypointA = Waypoint(
      id: 1,
      hikeId: 42,
      name: 'Glen Ord Station',
      description: 'A peaty highland dram awaits.',
      latitude: 51.16,
      longitude: 10.44,
      orderIndex: 0,
    );
    const waypointB = Waypoint(
      id: 2,
      hikeId: 42,
      name: 'Glenmorangie Outlook',
      description: 'Floral and fruity views.',
      latitude: 51.17,
      longitude: 10.46,
      orderIndex: 1,
    );

    setUp(() {
      mockRepository = MockOfflineFirstWaypointRepository();
      when(
        mockRepository.getWaypointsForHike(any),
      ).thenAnswer((_) async => [waypointA, waypointB]);
    });

    HikeMapViewModel buildViewModel() =>
        HikeMapViewModel(hikeId: 42, waypointRepository: mockRepository);

    test('starts with no selection', () {
      expect(buildViewModel().selectedWaypoint, isNull);
    });

    test('selectWaypoint sets the selection and notifies', () {
      final vm = buildViewModel();
      var notified = 0;
      vm.addListener(() => notified++);

      vm.selectWaypoint(waypointA);

      expect(vm.selectedWaypoint, waypointA);
      expect(notified, 1);
    });

    test('selecting a different waypoint replaces the selection', () {
      final vm = buildViewModel()..selectWaypoint(waypointA);

      vm.selectWaypoint(waypointB);

      expect(vm.selectedWaypoint, waypointB);
    });

    test('clearSelection removes the selection', () {
      final vm = buildViewModel()..selectWaypoint(waypointA);

      vm.clearSelection();

      expect(vm.selectedWaypoint, isNull);
    });

    test(
      'toggling visited keeps the selection in sync with the list',
      () async {
        final vm = buildViewModel();
        await vm.loadWaypoints();
        vm.selectWaypoint(vm.waypoints.first);

        await vm.toggleWaypointVisited(vm.waypoints.first);

        expect(vm.selectedWaypoint?.isVisited, isTrue);
        expect(vm.waypoints.first.isVisited, isTrue);
      },
    );
  });
}
