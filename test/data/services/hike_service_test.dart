import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/database/hike_service.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('HikeService', () {
    late HikeService hikeService;

    setUp(() {
      hikeService = HikeService(client: _MockSupabaseClient());
    });

    group('deleteHike', () {
      test('should exist as a method', () {
        expect(() => hikeService.deleteHike, returnsNormally);
      });

      test('should throw ArgumentError for hike id 0', () async {
        expect(
          () async => await hikeService.deleteHike(0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for negative hike id', () async {
        expect(
          () async => await hikeService.deleteHike(-1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for very negative hike id', () async {
        expect(
          () async => await hikeService.deleteHike(-999),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
