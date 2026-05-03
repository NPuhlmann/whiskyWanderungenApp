import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/UI/mobile/poi_details/poi_details_view_model.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

void main() {
  late Waypoint waypoint;

  setUp(() {
    waypoint = const Waypoint(
      id: 1,
      hikeId: 10,
      name: 'Glenfarclas 105',
      description: 'Speyside • 12 Jahre',
      latitude: 57.4,
      longitude: -3.2,
      orderIndex: 0,
      images: [],
    );
  });

  test('initial state: isAddedToOrder is false', () {
    final vm = PoiDetailsViewModel(waypoint: waypoint);
    expect(vm.isAddedToOrder, isFalse);
  });

  test('addToOrder sets isAddedToOrder to true and notifies', () {
    final vm = PoiDetailsViewModel(waypoint: waypoint);
    var notified = false;
    vm.addListener(() => notified = true);

    vm.addToOrder();

    expect(vm.isAddedToOrder, isTrue);
    expect(notified, isTrue);
  });

  test('addToOrder is idempotent — calling twice does not double-notify', () {
    final vm = PoiDetailsViewModel(waypoint: waypoint);
    var notifyCount = 0;
    vm.addListener(() => notifyCount++);

    vm.addToOrder();
    vm.addToOrder();

    expect(notifyCount, 1);
    expect(vm.isAddedToOrder, isTrue);
  });

  test('waypoint is exposed unchanged', () {
    final vm = PoiDetailsViewModel(waypoint: waypoint);
    expect(vm.waypoint, same(waypoint));
    expect(vm.waypoint.name, 'Glenfarclas 105');
  });
}
