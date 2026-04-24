import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

import '../../mocks/mock_backend_api_service.dart';

void main() {
  group('HikeRepository Tests', () {
    late MockBackendApiService mockBackendApiService;
    late HikeRepository hikeRepository;

    setUp(() {
      mockBackendApiService = MockBackendApiService();
      hikeRepository = HikeRepository(mockBackendApiService);
    });

    group('getAllAvailableHikes', () {
      test(
        'should return list of hikes when backend service succeeds',
        () async {
          // Arrange
          final expectedHikes = [
            const Hike(
              id: 1,
              name: 'Mountain Trail',
              length: 5.5,
              price: 19.99,
              difficulty: Difficulty.mid,
            ),
            const Hike(
              id: 2,
              name: 'Forest Path',
              length: 3.2,
              price: 14.99,
              difficulty: Difficulty.easy,
            ),
            const Hike(
              id: 3,
              name: 'Peak Challenge',
              length: 8.7,
              price: 29.99,
              difficulty: Difficulty.hard,
            ),
          ];

          when(
            mockBackendApiService.fetchHikes(),
          ).thenAnswer((_) async => expectedHikes);

          // Act
          final result = await hikeRepository.getAllAvailableHikes();

          // Assert
          expect(result, equals(expectedHikes));
          expect(result.length, 3);
          expect(result[0].name, 'Mountain Trail');
          expect(result[1].difficulty, Difficulty.easy);
          expect(result[2].price, 29.99);

          verify(mockBackendApiService.fetchHikes()).called(1);
        },
      );

      test('should return empty list when no hikes available', () async {
        // Arrange
        when(mockBackendApiService.fetchHikes()).thenAnswer((_) async => []);

        // Act
        final result = await hikeRepository.getAllAvailableHikes();

        // Assert
        expect(result, isEmpty);
        verify(mockBackendApiService.fetchHikes()).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        when(
          mockBackendApiService.fetchHikes(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => hikeRepository.getAllAvailableHikes(),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.fetchHikes()).called(1);
      });

      test('should handle null response gracefully', () async {
        // Arrange
        when(
          mockBackendApiService.fetchHikes(),
        ).thenAnswer((_) async => <Hike>[]);

        // Act
        final result = await hikeRepository.getAllAvailableHikes();

        // Assert
        expect(result, isNotNull);
        expect(result, isEmpty);
        verify(mockBackendApiService.fetchHikes()).called(1);
      });
    });

    group('getUserHikes', () {
      const testUserId = 'user123';

      test('should return user hikes when backend service succeeds', () async {
        // Arrange
        final expectedUserHikes = [
          const Hike(
            id: 1,
            name: 'User Hike 1',
            length: 4.0,
            price: 15.99,
            difficulty: Difficulty.mid,
          ),
          const Hike(
            id: 3,
            name: 'User Hike 2',
            length: 6.5,
            price: 25.99,
            difficulty: Difficulty.hard,
          ),
        ];

        when(
          mockBackendApiService.fetchUserHikes(testUserId),
        ).thenAnswer((_) async => expectedUserHikes);

        // Act
        final result = await hikeRepository.getUserHikes(testUserId);

        // Assert
        expect(result, equals(expectedUserHikes));
        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[1].id, 3);

        verify(mockBackendApiService.fetchUserHikes(testUserId)).called(1);
      });

      test('should return empty list when user has no hikes', () async {
        // Arrange
        when(
          mockBackendApiService.fetchUserHikes(testUserId),
        ).thenAnswer((_) async => []);

        // Act
        final result = await hikeRepository.getUserHikes(testUserId);

        // Assert
        expect(result, isEmpty);
        verify(mockBackendApiService.fetchUserHikes(testUserId)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        when(
          mockBackendApiService.fetchUserHikes(testUserId),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => hikeRepository.getUserHikes(testUserId),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.fetchUserHikes(testUserId)).called(1);
      });

      test('should handle different user IDs correctly', () async {
        // Arrange
        const userId1 = 'user1';
        const userId2 = 'user2';

        final user1Hikes = [const Hike(id: 1, name: 'Hike 1')];
        final user2Hikes = [
          const Hike(id: 2, name: 'Hike 2'),
          const Hike(id: 3, name: 'Hike 3'),
        ];

        when(
          mockBackendApiService.fetchUserHikes(userId1),
        ).thenAnswer((_) async => user1Hikes);
        when(
          mockBackendApiService.fetchUserHikes(userId2),
        ).thenAnswer((_) async => user2Hikes);

        // Act
        final result1 = await hikeRepository.getUserHikes(userId1);
        final result2 = await hikeRepository.getUserHikes(userId2);

        // Assert
        expect(result1.length, 1);
        expect(result2.length, 2);
        expect(result1[0].name, 'Hike 1');
        expect(result2[0].name, 'Hike 2');

        verify(mockBackendApiService.fetchUserHikes(userId1)).called(1);
        verify(mockBackendApiService.fetchUserHikes(userId2)).called(1);
      });

      test('should handle empty user ID', () async {
        // Arrange
        const emptyUserId = '';
        when(
          mockBackendApiService.fetchUserHikes(emptyUserId),
        ).thenAnswer((_) async => []);

        // Act
        final result = await hikeRepository.getUserHikes(emptyUserId);

        // Assert
        expect(result, isEmpty);
        verify(mockBackendApiService.fetchUserHikes(emptyUserId)).called(1);
      });

      test('should handle special characters in user ID', () async {
        // Arrange
        const specialUserId = 'user@123-test_id';
        final expectedHikes = [const Hike(id: 99, name: 'Special User Hike')];

        when(
          mockBackendApiService.fetchUserHikes(specialUserId),
        ).thenAnswer((_) async => expectedHikes);

        // Act
        final result = await hikeRepository.getUserHikes(specialUserId);

        // Assert
        expect(result, expectedHikes);
        verify(mockBackendApiService.fetchUserHikes(specialUserId)).called(1);
      });
    });

    group('Error Handling', () {
      test(
        'should propagate specific exceptions from backend service',
        () async {
          // Arrange
          const errorMessage = 'Specific database connection error';
          when(
            mockBackendApiService.fetchHikes(),
          ).thenThrow(Exception(errorMessage));

          // Act & Assert
          try {
            await hikeRepository.getAllAvailableHikes();
            fail('Expected exception was not thrown');
          } catch (e) {
            expect(e.toString(), contains(errorMessage));
          }

          verify(mockBackendApiService.fetchHikes()).called(1);
        },
      );

      test('should handle timeout exceptions', () async {
        // Arrange
        when(
          mockBackendApiService.fetchHikes(),
        ).thenThrow(Exception('Timeout'));

        // Act & Assert
        expect(
          () => hikeRepository.getAllAvailableHikes(),
          throwsA(predicate((e) => e.toString().contains('Timeout'))),
        );

        verify(mockBackendApiService.fetchHikes()).called(1);
      });
    });

    group('Multiple Calls', () {
      test('should handle multiple sequential calls correctly', () async {
        // Arrange
        final hikes1 = [const Hike(id: 1, name: 'First Call')];
        final hikes2 = [const Hike(id: 2, name: 'Second Call')];

        when(
          mockBackendApiService.fetchHikes(),
        ).thenAnswer((_) async => hikes1);

        // Act
        final result1 = await hikeRepository.getAllAvailableHikes();

        // Re-setup mock for second call
        when(
          mockBackendApiService.fetchHikes(),
        ).thenAnswer((_) async => hikes2);

        final result2 = await hikeRepository.getAllAvailableHikes();

        // Assert
        expect(result1[0].name, 'First Call');
        expect(result2[0].name, 'Second Call');
        verify(mockBackendApiService.fetchHikes()).called(2);
      });

      test('should handle concurrent calls correctly', () async {
        // Arrange
        final expectedHikes = [const Hike(id: 1, name: 'Concurrent Hike')];

        when(
          mockBackendApiService.fetchHikes(),
        ).thenAnswer((_) async => expectedHikes);

        // Act
        final futures = List.generate(
          3,
          (_) => hikeRepository.getAllAvailableHikes(),
        );
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, equals(expectedHikes));
        }
        verify(mockBackendApiService.fetchHikes()).called(3);
      });
    });
  });
}
