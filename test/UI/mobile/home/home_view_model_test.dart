import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisky_hikes/UI/mobile/home/home_view_model.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

import '../../../mocks/mock_repositories.dart';
import '../../../test_helpers.dart';

void main() {
  group('HomePageViewModel Tests', () {
    late HomePageViewModel homeViewModel;
    late MockOfflineFirstHikeRepository mockHikeRepository;
    late MockProfileRepository mockProfileRepository;
    late MockUserRepository mockUserRepository;
    late List<Hike> testHikes;
    late Profile testProfile;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockHikeRepository = MockOfflineFirstHikeRepository();
      mockProfileRepository = MockProfileRepository();
      mockUserRepository = MockUserRepository();

      homeViewModel = HomePageViewModel(
        hikeRepository: mockHikeRepository,
        profileRepository: mockProfileRepository,
        userRepository: mockUserRepository,
      );

      testHikes = [
        TestHelpers.createTestHike(id: 1, name: 'Hike 1', isFavorite: false),
        TestHelpers.createTestHike(id: 2, name: 'Hike 2', isFavorite: true),
        TestHelpers.createTestHike(id: 3, name: 'Hike 3', isFavorite: false),
      ];

      testProfile = TestHelpers.createTestProfile(
        id: 'user123',
        firstName: 'John',
      );
    });

    group('Initial State Tests', () {
      test('should have correct initial values', () {
        expect(homeViewModel.hikes, isEmpty);
        expect(homeViewModel.firstName, isEmpty);
        expect(homeViewModel.showFavorites, false);
        expect(homeViewModel.isLoading, false);
      });
    });

    group('Load Hikes Tests', () {
      test('should load hikes successfully', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async => testHikes);

        await homeViewModel.loadHikes();

        expect(homeViewModel.hikes, equals(testHikes));
        expect(homeViewModel.isLoading, false);
        verify(
          mockHikeRepository.getAllAvailableHikes(forceRefresh: false),
        ).called(1);
      });

      test('should handle loading state correctly', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return testHikes;
        });

        final loadingFuture = homeViewModel.loadHikes();

        expect(homeViewModel.isLoading, true);

        await loadingFuture;
        expect(homeViewModel.isLoading, false);
      });

      test('should handle hike loading error gracefully', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenThrow(Exception('Network error'));

        await homeViewModel.loadHikes();

        expect(homeViewModel.hikes, isEmpty);
        expect(homeViewModel.isLoading, false);
      });

      test('refresh() forces a fresh network fetch', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async => testHikes);

        await homeViewModel.refresh();

        verify(
          mockHikeRepository.getAllAvailableHikes(forceRefresh: true),
        ).called(1);
      });
    });

    group('Get User First Name Tests', () {
      test('should get user first name successfully', () async {
        when(mockUserRepository.getUserId()).thenReturn('user123');
        when(
          mockProfileRepository.getUserProfileById('user123'),
        ).thenAnswer((_) async => testProfile);

        await homeViewModel.getUserFirstName();

        expect(homeViewModel.firstName, equals('John'));
        verify(mockUserRepository.getUserId()).called(1);
        verify(mockProfileRepository.getUserProfileById('user123')).called(1);
      });

      test('should handle null user ID', () async {
        when(mockUserRepository.getUserId()).thenReturn(null);

        await homeViewModel.getUserFirstName();

        expect(homeViewModel.firstName, isEmpty);
        verify(mockUserRepository.getUserId()).called(1);
        verifyNever(mockProfileRepository.getUserProfileById(any));
      });

      test('should handle profile loading error', () async {
        when(mockUserRepository.getUserId()).thenReturn('user123');
        when(
          mockProfileRepository.getUserProfileById('user123'),
        ).thenThrow(Exception('Profile not found'));

        await homeViewModel.getUserFirstName();

        expect(homeViewModel.firstName, isEmpty);
      });
    });

    group('Favorites Functionality Tests', () {
      test('should toggle show favorites correctly', () {
        expect(homeViewModel.showFavorites, false);

        homeViewModel.toggleShowFavorites();
        expect(homeViewModel.showFavorites, true);

        homeViewModel.toggleShowFavorites();
        expect(homeViewModel.showFavorites, false);
      });

      test(
        'should return only favorite hikes when showFavorites is true',
        () async {
          when(
            mockHikeRepository.getAllAvailableHikes(
              forceRefresh: anyNamed('forceRefresh'),
            ),
          ).thenAnswer((_) async => testHikes);
          await homeViewModel.loadHikes();

          homeViewModel.toggleShowFavorites();

          final favoriteHikes = homeViewModel.hikes;
          expect(favoriteHikes.length, 1);
          expect(favoriteHikes.first.isFavorite, true);
          expect(favoriteHikes.first.name, 'Hike 2');
        },
      );

      test('should return all hikes when showFavorites is false', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async => testHikes);
        await homeViewModel.loadHikes();

        expect(homeViewModel.hikes, equals(testHikes));
        expect(homeViewModel.hikes.length, 3);
      });
    });

    group('Toggle Favorite Tests', () {
      test('should toggle hike favorite status locally', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async => testHikes);
        await homeViewModel.loadHikes();

        final hikeToToggle = testHikes[0]; // Not favorite initially

        homeViewModel.toggleFavorite(hikeToToggle);

        expect(
          homeViewModel.hikes
              .firstWhere((h) => h.id == hikeToToggle.id)
              .isFavorite,
          true,
        );
      });
    });

    group('Notification Tests', () {
      test('should notify listeners during loadHikes', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async => testHikes);
        bool wasNotified = false;
        homeViewModel.addListener(() => wasNotified = true);

        await homeViewModel.loadHikes();

        expect(wasNotified, true);
      });

      test('should notify listeners when toggling favorites', () {
        bool wasNotified = false;
        homeViewModel.addListener(() => wasNotified = true);

        homeViewModel.toggleShowFavorites();

        expect(wasNotified, true);
      });
    });

    group('Edge Cases Tests', () {
      test('should handle empty hikes list', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async => []);

        await homeViewModel.loadHikes();

        expect(homeViewModel.hikes, isEmpty);
        expect(homeViewModel.isLoading, false);
      });

      test('should handle empty profile first name', () async {
        final profileWithoutName = testProfile.copyWith(firstName: '');
        when(mockUserRepository.getUserId()).thenReturn('user123');
        when(
          mockProfileRepository.getUserProfileById('user123'),
        ).thenAnswer((_) async => profileWithoutName);

        await homeViewModel.getUserFirstName();

        expect(homeViewModel.firstName, isEmpty);
      });

      test('should handle concurrent operations', () async {
        when(
          mockHikeRepository.getAllAvailableHikes(
            forceRefresh: anyNamed('forceRefresh'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return testHikes;
        });
        when(mockUserRepository.getUserId()).thenReturn('user123');
        when(mockProfileRepository.getUserProfileById('user123')).thenAnswer((
          _,
        ) async {
          await Future.delayed(const Duration(milliseconds: 30));
          return testProfile;
        });

        await Future.wait([
          homeViewModel.loadHikes(),
          homeViewModel.getUserFirstName(),
        ]);

        expect(homeViewModel.hikes, equals(testHikes));
        expect(homeViewModel.firstName, equals('John'));
      });
    });
  });
}
