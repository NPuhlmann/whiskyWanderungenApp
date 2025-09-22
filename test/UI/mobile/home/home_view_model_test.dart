import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/home/home_view_model.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

import '../../test_helpers.dart';

class MockHikeRepository extends Mock implements HikeRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('HomePageViewModel Tests', () {
    late HomePageViewModel homeViewModel;
    late MockHikeRepository mockHikeRepository;
    late MockProfileRepository mockProfileRepository;
    late MockUserRepository mockUserRepository;
    late List<Hike> testHikes;
    late Profile testProfile;

    setUp(() {
      mockHikeRepository = MockHikeRepository();
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
        userId: 'user123',
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
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async => testHikes);

        // Act
        await homeViewModel.loadHikes();

        // Assert
        expect(homeViewModel.hikes, equals(testHikes));
        expect(homeViewModel.isLoading, false);
        verify(mockHikeRepository.getAllHikes()).called(1);
      });

      test('should handle loading state correctly', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return testHikes;
        });

        // Act
        final loadingFuture = homeViewModel.loadHikes();
        
        // Assert loading state
        expect(homeViewModel.isLoading, true);
        
        await loadingFuture;
        expect(homeViewModel.isLoading, false);
      });

      test('should handle hike loading error gracefully', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenThrow(Exception('Network error'));

        // Act
        await homeViewModel.loadHikes();

        // Assert
        expect(homeViewModel.hikes, isEmpty);
        expect(homeViewModel.isLoading, false);
        verify(mockHikeRepository.getAllHikes()).called(1);
      });
    });

    group('Get User First Name Tests', () {
      test('should get user first name successfully', () async {
        // Arrange
        when(mockUserRepository.getCurrentUserId()).thenReturn('user123');
        when(mockProfileRepository.getUserProfileById('user123')).thenAnswer((_) async => testProfile);

        // Act
        await homeViewModel.getUserFirstName();

        // Assert
        expect(homeViewModel.firstName, equals('John'));
        verify(mockUserRepository.getCurrentUserId()).called(1);
        verify(mockProfileRepository.getUserProfileById('user123')).called(1);
      });

      test('should handle null user ID', () async {
        // Arrange
        when(mockUserRepository.getCurrentUserId()).thenReturn(null);

        // Act
        await homeViewModel.getUserFirstName();

        // Assert
        expect(homeViewModel.firstName, isEmpty);
        verify(mockUserRepository.getCurrentUserId()).called(1);
        verifyNever(mockProfileRepository.getUserProfileById(any));
      });

      test('should handle profile loading error', () async {
        // Arrange
        when(mockUserRepository.getCurrentUserId()).thenReturn('user123');
        when(mockProfileRepository.getUserProfileById('user123')).thenThrow(Exception('Profile not found'));

        // Act
        await homeViewModel.getUserFirstName();

        // Assert
        expect(homeViewModel.firstName, isEmpty);
      });
    });

    group('Favorites Functionality Tests', () {
      test('should toggle show favorites correctly', () {
        // Initial state
        expect(homeViewModel.showFavorites, false);

        // Toggle to true
        homeViewModel.toggleShowFavorites();
        expect(homeViewModel.showFavorites, true);

        // Toggle back to false
        homeViewModel.toggleShowFavorites();
        expect(homeViewModel.showFavorites, false);
      });

      test('should return only favorite hikes when showFavorites is true', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async => testHikes);
        await homeViewModel.loadHikes();

        // Act
        homeViewModel.toggleShowFavorites();

        // Assert
        final favoriteHikes = homeViewModel.hikes;
        expect(favoriteHikes.length, 1);
        expect(favoriteHikes.first.isFavorite, true);
        expect(favoriteHikes.first.name, 'Hike 2');
      });

      test('should return all hikes when showFavorites is false', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async => testHikes);
        await homeViewModel.loadHikes();

        // Act - showFavorites is false by default
        
        // Assert
        expect(homeViewModel.hikes, equals(testHikes));
        expect(homeViewModel.hikes.length, 3);
      });
    });

    group('Toggle Favorite Tests', () {
      test('should toggle hike favorite status', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async => testHikes);
        when(mockHikeRepository.toggleHikeFavorite(any)).thenAnswer((_) async {});
        await homeViewModel.loadHikes();

        final hikeToToggle = testHikes[0]; // Not favorite initially

        // Act
        await homeViewModel.toggleFavorite(hikeToToggle);

        // Assert
        verify(mockHikeRepository.toggleHikeFavorite(hikeToToggle)).called(1);
      });

      test('should handle toggle favorite error gracefully', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async => testHikes);
        when(mockHikeRepository.toggleHikeFavorite(any)).thenThrow(Exception('Database error'));
        await homeViewModel.loadHikes();

        final hikeToToggle = testHikes[0];

        // Act & Assert - should not throw
        await homeViewModel.toggleFavorite(hikeToToggle);
        verify(mockHikeRepository.toggleHikeFavorite(hikeToToggle)).called(1);
      });
    });

    group('Notification Tests', () {
      test('should notify listeners during loadHikes', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async => testHikes);
        bool wasNotified = false;
        homeViewModel.addListener(() => wasNotified = true);

        // Act
        await homeViewModel.loadHikes();

        // Assert
        expect(wasNotified, true);
      });

      test('should notify listeners when toggling favorites', () {
        // Arrange
        bool wasNotified = false;
        homeViewModel.addListener(() => wasNotified = true);

        // Act
        homeViewModel.toggleShowFavorites();

        // Assert
        expect(wasNotified, true);
      });
    });

    group('Edge Cases Tests', () {
      test('should handle empty hikes list', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async => []);

        // Act
        await homeViewModel.loadHikes();

        // Assert
        expect(homeViewModel.hikes, isEmpty);
        expect(homeViewModel.isLoading, false);
      });

      test('should handle null profile first name', () async {
        // Arrange
        final profileWithoutName = testProfile.copyWith(firstName: '');
        when(mockUserRepository.getCurrentUserId()).thenReturn('user123');
        when(mockProfileRepository.getUserProfileById('user123')).thenAnswer((_) async => profileWithoutName);

        // Act
        await homeViewModel.getUserFirstName();

        // Assert
        expect(homeViewModel.firstName, isEmpty);
      });

      test('should handle concurrent operations', () async {
        // Arrange
        when(mockHikeRepository.getAllHikes()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return testHikes;
        });
        when(mockUserRepository.getCurrentUserId()).thenReturn('user123');
        when(mockProfileRepository.getUserProfileById('user123')).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 30));
          return testProfile;
        });

        // Act - call both methods concurrently
        await Future.wait([
          homeViewModel.loadHikes(),
          homeViewModel.getUserFirstName(),
        ]);

        // Assert
        expect(homeViewModel.hikes, equals(testHikes));
        expect(homeViewModel.firstName, equals('John'));
      });
    });
  });
}