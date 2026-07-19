import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_page.dart';

void main() {
  group('nextImageIndex', () {
    test('advances within bounds', () {
      expect(nextImageIndex(0, 5), 1);
      expect(nextImageIndex(3, 5), 4);
    });

    test('wraps from last to first', () {
      expect(nextImageIndex(4, 5), 0);
    });

    test('stays put when there is nothing to wrap to', () {
      expect(nextImageIndex(0, 1), 0);
      expect(nextImageIndex(0, 0), 0);
    });
  });

  group('prevImageIndex', () {
    test('goes back within bounds', () {
      expect(prevImageIndex(4, 5), 3);
      expect(prevImageIndex(1, 5), 0);
    });

    test('wraps from first to last', () {
      expect(prevImageIndex(0, 5), 4);
    });

    test('stays put when there is nothing to wrap to', () {
      expect(prevImageIndex(0, 1), 0);
      expect(prevImageIndex(0, 0), 0);
    });
  });
}
