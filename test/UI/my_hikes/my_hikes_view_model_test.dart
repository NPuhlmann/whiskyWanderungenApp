import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/my_hikes/my_hikes_view_model.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('MyHikesViewModel Tests', () {
    late MockHikeRepository mockHikeRepository;
    late MockUserRepository mockUserRepository;
    late MyHikesViewModel myHikesViewModel;

    setUp(() {
      mockHikeRepository = MockHikeRepository();
      mockUserRepository = MockUserRepository();
      myHikesViewModel = MyHikesViewModel(
        hikeRepository: mockHikeRepository,
        userRepository: mockUserRepository,
      );
    });

    group('Initial State', () {
      test('should initialize with correct default values', () {
        expect(myHikesViewModel.userHikes, isEmpty);
        expect(myHikesViewModel.isLoading, false);
        expect(myHikesViewModel.errorMessage, isNull);
      });
    });

    group('loadUserHikes', () {
      const testUserId = 'user123';

      test(
        'should load user hikes successfully and notify listeners',
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
          ];

          when(mockUserRepository.getUserId()).thenReturn(testUserId);
          when(
            mockHikeRepository.getUserHikes(testUserId),
          ).thenAnswer((_) async => expectedHikes);

          bool listenerCalled = false;
          myHikesViewModel.addListener(() => listenerCalled = true);

          // Act
          await myHikesViewModel.loadUserHikes();

          // Assert
          expect(myHikesViewModel.userHikes, equals(expectedHikes));
          expect(myHikesViewModel.isLoading, false);
          expect(myHikesViewModel.errorMessage, isNull);
          expect(listenerCalled, true);
          verify(mockUserRepository.getUserId()).called(1);
          verify(mockHikeRepository.getUserHikes(testUserId)).called(1);
        },
      );

      test('should handle null user ID', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(null);

        bool listenerCalled = false;
        myHikesViewModel.addListener(() => listenerCalled = true);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert
        expect(myHikesViewModel.userHikes, isEmpty);
        expect(myHikesViewModel.isLoading, false);
        expect(myHikesViewModel.errorMessage, 'loginRequiredForHikes');
        expect(listenerCalled, true);
        verify(mockUserRepository.getUserId()).called(1);
        verifyNever(mockHikeRepository.getUserHikes(any));
      });

      test('should handle empty user hikes list', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenAnswer((_) async => []);

        bool listenerCalled = false;
        myHikesViewModel.addListener(() => listenerCalled = true);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert
        expect(myHikesViewModel.userHikes, isEmpty);
        expect(myHikesViewModel.isLoading, false);
        expect(myHikesViewModel.errorMessage, isNull);
        expect(listenerCalled, true);
        verify(mockHikeRepository.getUserHikes(testUserId)).called(1);
      });

      test('should handle error loading user hikes', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenThrow(Exception('Network error'));

        bool listenerCalled = false;
        myHikesViewModel.addListener(() => listenerCalled = true);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert
        expect(myHikesViewModel.userHikes, isEmpty);
        expect(myHikesViewModel.isLoading, false);
        expect(myHikesViewModel.errorMessage, 'errorLoadingHikes');
        expect(listenerCalled, true);
        verify(mockHikeRepository.getUserHikes(testUserId)).called(1);
      });

      test('should not load multiple times simultaneously', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(mockHikeRepository.getUserHikes(testUserId)).thenAnswer((_) async {
          // Simulate slow network
          await Future.delayed(const Duration(milliseconds: 100));
          return [const Hike(id: 1, name: 'Test Hike')];
        });

        // Act - Call loadUserHikes multiple times quickly
        final future1 = myHikesViewModel.loadUserHikes();
        final future2 = myHikesViewModel.loadUserHikes(); // Should return early

        await Future.wait([future1, future2]);

        // Assert - Should only call the repository once
        verify(mockHikeRepository.getUserHikes(testUserId)).called(1);
      });

      test('should set loading state correctly during load', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(mockHikeRepository.getUserHikes(testUserId)).thenAnswer((_) async {
          // Verify loading is true during async call
          expect(myHikesViewModel.isLoading, true);
          await Future.delayed(const Duration(milliseconds: 10));
          return [const Hike(id: 1, name: 'Test Hike')];
        });

        // Initially not loading
        expect(myHikesViewModel.isLoading, false);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert - Loading should be false after completion
        expect(myHikesViewModel.isLoading, false);
      });

      test('should clear error message on successful load', () async {
        // Arrange - First cause an error
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenThrow(Exception('Network error'));

        await myHikesViewModel.loadUserHikes();
        expect(myHikesViewModel.errorMessage, 'errorLoadingHikes');

        // Now return successful data
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenAnswer((_) async => [const Hike(id: 1, name: 'Test Hike')]);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert
        expect(myHikesViewModel.errorMessage, isNull);
        expect(myHikesViewModel.userHikes.length, 1);
      });
    });

    group('refresh', () {
      test('should call loadUserHikes', () async {
        // Arrange
        const testUserId = 'user123';
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenAnswer((_) async => []);

        // Act
        await myHikesViewModel.refresh();

        // Assert
        verify(mockUserRepository.getUserId()).called(1);
        verify(mockHikeRepository.getUserHikes(testUserId)).called(1);
      });

      test('should handle refresh with existing data', () async {
        // Arrange
        const testUserId = 'user123';
        final initialHikes = [const Hike(id: 1, name: 'Initial Hike')];
        final updatedHikes = [
          const Hike(id: 1, name: 'Initial Hike'),
          const Hike(id: 2, name: 'New Hike'),
        ];

        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenAnswer((_) async => initialHikes);

        await myHikesViewModel.loadUserHikes();
        expect(myHikesViewModel.userHikes.length, 1);

        // Update mock to return new data
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenAnswer((_) async => updatedHikes);

        // Act
        await myHikesViewModel.refresh();

        // Assert
        expect(myHikesViewModel.userHikes.length, 2);
        expect(myHikesViewModel.userHikes, equals(updatedHikes));
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners on successful load', () async {
        // Arrange
        const testUserId = 'user123';
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenAnswer((_) async => []);

        int notificationCount = 0;
        myHikesViewModel.addListener(() => notificationCount++);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert - Should be notified at least once
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on error', () async {
        // Arrange
        const testUserId = 'user123';
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockHikeRepository.getUserHikes(testUserId),
        ).thenThrow(Exception('Error'));

        int notificationCount = 0;
        myHikesViewModel.addListener(() => notificationCount++);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on null user ID', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(null);

        int notificationCount = 0;
        myHikesViewModel.addListener(() => notificationCount++);

        // Act
        await myHikesViewModel.loadUserHikes();

        // Assert
        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
