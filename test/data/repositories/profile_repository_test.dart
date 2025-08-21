import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

import '../../mocks/mock_backend_api_service.dart';

void main() {
  group('ProfileRepository Tests', () {
    late MockBackendApiService mockBackendApiService;
    late ProfileRepository profileRepository;

    setUp(() {
      mockBackendApiService = MockBackendApiService();
      profileRepository = ProfileRepository(mockBackendApiService);
    });

    group('getUserProfileById', () {
      const testUserId = 'user123';

      test('should return profile when backend service succeeds', () async {
        // Arrange
        final expectedProfile = Profile(
          id: testUserId,
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          dateOfBirth: DateTime(1990, 5, 15),
          imageUrl: 'https://example.com/avatar.jpg',
        );

        when(mockBackendApiService.getUserProfileById(testUserId))
            .thenAnswer((_) async => expectedProfile);

        // Act
        final result = await profileRepository.getUserProfileById(testUserId);

        // Assert
        expect(result, equals(expectedProfile));
        expect(result.id, testUserId);
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.email, 'john.doe@example.com');
        expect(result.dateOfBirth, DateTime(1990, 5, 15));
        expect(result.imageUrl, 'https://example.com/avatar.jpg');

        verify(mockBackendApiService.getUserProfileById(testUserId)).called(1);
      });

      test('should return profile with default values when profile is empty', () async {
        // Arrange
        final emptyProfile = Profile(id: testUserId);

        when(mockBackendApiService.getUserProfileById(testUserId))
            .thenAnswer((_) async => emptyProfile);

        // Act
        final result = await profileRepository.getUserProfileById(testUserId);

        // Assert
        expect(result.id, testUserId);
        expect(result.firstName, '');
        expect(result.lastName, '');
        expect(result.email, '');
        expect(result.dateOfBirth, null);
        expect(result.imageUrl, '');

        verify(mockBackendApiService.getUserProfileById(testUserId)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        when(mockBackendApiService.getUserProfileById(testUserId))
            .thenThrow(Exception('User not found'));

        // Act & Assert
        expect(
          () => profileRepository.getUserProfileById(testUserId),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.getUserProfileById(testUserId)).called(1);
      });

      test('should handle different user IDs correctly', () async {
        // Arrange
        const userId1 = 'user1';
        const userId2 = 'user2';
        
        final profile1 = Profile(id: userId1, firstName: 'Alice');
        final profile2 = Profile(id: userId2, firstName: 'Bob');

        when(mockBackendApiService.getUserProfileById(userId1))
            .thenAnswer((_) async => profile1);
        when(mockBackendApiService.getUserProfileById(userId2))
            .thenAnswer((_) async => profile2);

        // Act
        final result1 = await profileRepository.getUserProfileById(userId1);
        final result2 = await profileRepository.getUserProfileById(userId2);

        // Assert
        expect(result1.id, userId1);
        expect(result1.firstName, 'Alice');
        expect(result2.id, userId2);
        expect(result2.firstName, 'Bob');

        verify(mockBackendApiService.getUserProfileById(userId1)).called(1);
        verify(mockBackendApiService.getUserProfileById(userId2)).called(1);
      });

      test('should handle empty user ID', () async {
        // Arrange
        const emptyUserId = '';
        final emptyProfile = Profile(id: emptyUserId);

        when(mockBackendApiService.getUserProfileById(emptyUserId))
            .thenAnswer((_) async => emptyProfile);

        // Act
        final result = await profileRepository.getUserProfileById(emptyUserId);

        // Assert
        expect(result.id, emptyUserId);
        verify(mockBackendApiService.getUserProfileById(emptyUserId)).called(1);
      });

      test('should handle special characters in user ID', () async {
        // Arrange
        const specialUserId = 'user@123-test_id';
        final profile = Profile(
          id: specialUserId,
          firstName: 'José',
          lastName: 'Müller-Özkaya',
        );

        when(mockBackendApiService.getUserProfileById(specialUserId))
            .thenAnswer((_) async => profile);

        // Act
        final result = await profileRepository.getUserProfileById(specialUserId);

        // Assert
        expect(result.id, specialUserId);
        expect(result.firstName, 'José');
        expect(result.lastName, 'Müller-Özkaya');
        verify(mockBackendApiService.getUserProfileById(specialUserId)).called(1);
      });
    });

    group('updateUserProfile', () {
      test('should update profile successfully', () async {
        // Arrange
        final profile = Profile(
          id: 'user123',
          firstName: 'Updated',
          lastName: 'User',
          email: 'updated@example.com',
        );

        when(mockBackendApiService.updateUserProfile(profile))
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await profileRepository.updateUserProfile(profile);

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'Test');

        when(mockBackendApiService.updateUserProfile(profile))
            .thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => profileRepository.updateUserProfile(profile),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should handle profile with null date of birth', () async {
        // Arrange
        final profile = Profile(
          id: 'user123',
          firstName: 'Test',
          dateOfBirth: null,
        );

        when(mockBackendApiService.updateUserProfile(profile))
            .thenAnswer((_) async => {});

        // Act & Assert
        await profileRepository.updateUserProfile(profile);

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should handle profile with date of birth', () async {
        // Arrange
        final birthDate = DateTime(1985, 8, 20);
        final profile = Profile(
          id: 'user123',
          firstName: 'Test',
          dateOfBirth: birthDate,
        );

        when(mockBackendApiService.updateUserProfile(profile))
            .thenAnswer((_) async => {});

        // Act & Assert
        await profileRepository.updateUserProfile(profile);

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should handle empty profile fields', () async {
        // Arrange
        final profile = Profile(
          id: 'user123',
          firstName: '',
          lastName: '',
          email: '',
          imageUrl: '',
        );

        when(mockBackendApiService.updateUserProfile(profile))
            .thenAnswer((_) async => {});

        // Act & Assert
        await profileRepository.updateUserProfile(profile);

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });
    });

    group('uploadProfileImage', () {
      const testUserId = 'user123';
      const testFileExt = 'jpg';

      test('should upload image and return URL successfully', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const expectedUrl = 'https://example.com/uploaded-image.jpg';

        when(mockBackendApiService.uploadProfileImage(testUserId, imageBytes, testFileExt))
            .thenAnswer((_) async => expectedUrl);

        // Act
        final result = await profileRepository.uploadProfileImage(testUserId, imageBytes, testFileExt);

        // Assert
        expect(result, expectedUrl);
        verify(mockBackendApiService.uploadProfileImage(testUserId, imageBytes, testFileExt)).called(1);
      });

      test('should throw exception when upload fails', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(mockBackendApiService.uploadProfileImage(testUserId, imageBytes, testFileExt))
            .thenThrow(Exception('Upload failed'));

        // Act & Assert
        expect(
          () => profileRepository.uploadProfileImage(testUserId, imageBytes, testFileExt),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.uploadProfileImage(testUserId, imageBytes, testFileExt)).called(1);
      });

      test('should handle different file extensions', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const extensions = ['jpg', 'png', 'webp', 'jpeg'];

        for (final ext in extensions) {
          final expectedUrl = 'https://example.com/image.$ext';
          when(mockBackendApiService.uploadProfileImage(testUserId, imageBytes, ext))
              .thenAnswer((_) async => expectedUrl);
        }

        // Act & Assert
        for (final ext in extensions) {
          final result = await profileRepository.uploadProfileImage(testUserId, imageBytes, ext);
          expect(result, 'https://example.com/image.$ext');
          verify(mockBackendApiService.uploadProfileImage(testUserId, imageBytes, ext)).called(1);
        }
      });

      test('should handle large image bytes', () async {
        // Arrange
        final largeImageBytes = Uint8List.fromList(List.generate(1000000, (index) => index % 256));
        const expectedUrl = 'https://example.com/large-image.jpg';

        when(mockBackendApiService.uploadProfileImage(testUserId, largeImageBytes, testFileExt))
            .thenAnswer((_) async => expectedUrl);

        // Act
        final result = await profileRepository.uploadProfileImage(testUserId, largeImageBytes, testFileExt);

        // Assert
        expect(result, expectedUrl);
        verify(mockBackendApiService.uploadProfileImage(testUserId, largeImageBytes, testFileExt)).called(1);
      });

      test('should handle empty image bytes', () async {
        // Arrange
        final emptyImageBytes = Uint8List.fromList([]);

        when(mockBackendApiService.uploadProfileImage(testUserId, emptyImageBytes, testFileExt))
            .thenThrow(Exception('Empty file not allowed'));

        // Act & Assert
        expect(
          () => profileRepository.uploadProfileImage(testUserId, emptyImageBytes, testFileExt),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.uploadProfileImage(testUserId, emptyImageBytes, testFileExt)).called(1);
      });
    });

    group('getProfileImageUrl', () {
      const testUserId = 'user123';

      test('should return image URL when it exists', () async {
        // Arrange
        const expectedUrl = 'https://example.com/profile-image.jpg';

        when(mockBackendApiService.getProfileImageUrl(testUserId))
            .thenAnswer((_) async => expectedUrl);

        // Act
        final result = await profileRepository.getProfileImageUrl(testUserId);

        // Assert
        expect(result, expectedUrl);
        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });

      test('should return null when no image exists', () async {
        // Arrange
        when(mockBackendApiService.getProfileImageUrl(testUserId))
            .thenAnswer((_) async => null);

        // Act
        final result = await profileRepository.getProfileImageUrl(testUserId);

        // Assert
        expect(result, null);
        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        when(mockBackendApiService.getProfileImageUrl(testUserId))
            .thenThrow(Exception('Service unavailable'));

        // Act & Assert
        expect(
          () => profileRepository.getProfileImageUrl(testUserId),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });

      test('should handle different user IDs', () async {
        // Arrange
        const userId1 = 'user1';
        const userId2 = 'user2';
        const userId3 = 'user3';
        
        const url1 = 'https://example.com/user1.jpg';
        const url2 = 'https://example.com/user2.png';

        when(mockBackendApiService.getProfileImageUrl(userId1))
            .thenAnswer((_) async => url1);
        when(mockBackendApiService.getProfileImageUrl(userId2))
            .thenAnswer((_) async => url2);
        when(mockBackendApiService.getProfileImageUrl(userId3))
            .thenAnswer((_) async => null);

        // Act
        final result1 = await profileRepository.getProfileImageUrl(userId1);
        final result2 = await profileRepository.getProfileImageUrl(userId2);
        final result3 = await profileRepository.getProfileImageUrl(userId3);

        // Assert
        expect(result1, url1);
        expect(result2, url2);
        expect(result3, null);

        verify(mockBackendApiService.getProfileImageUrl(userId1)).called(1);
        verify(mockBackendApiService.getProfileImageUrl(userId2)).called(1);
        verify(mockBackendApiService.getProfileImageUrl(userId3)).called(1);
      });

      test('should handle empty user ID', () async {
        // Arrange
        const emptyUserId = '';

        when(mockBackendApiService.getProfileImageUrl(emptyUserId))
            .thenAnswer((_) async => null);

        // Act
        final result = await profileRepository.getProfileImageUrl(emptyUserId);

        // Assert
        expect(result, null);
        verify(mockBackendApiService.getProfileImageUrl(emptyUserId)).called(1);
      });
    });

    group('Error Handling', () {
      test('should propagate specific exceptions from backend service', () async {
        // Arrange
        const testUserId = 'user123';
        const errorMessage = 'Database connection timeout';

        when(mockBackendApiService.getUserProfileById(testUserId))
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        try {
          await profileRepository.getUserProfileById(testUserId);
          fail('Expected exception was not thrown');
        } catch (e) {
          expect(e.toString(), contains(errorMessage));
        }

        verify(mockBackendApiService.getUserProfileById(testUserId)).called(1);
      });

      test('should handle network timeouts', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'Test');

        when(mockBackendApiService.updateUserProfile(profile))
            .thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () => profileRepository.updateUserProfile(profile),
          throwsA(
            predicate((e) => e.toString().contains('Network timeout')),
          ),
        );

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should handle authentication errors', () async {
        // Arrange
        const testUserId = 'user123';

        when(mockBackendApiService.getProfileImageUrl(testUserId))
            .thenThrow(Exception('Unauthorized'));

        // Act & Assert
        expect(
          () => profileRepository.getProfileImageUrl(testUserId),
          throwsA(
            predicate((e) => e.toString().contains('Unauthorized')),
          ),
        );

        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });
    });

    group('Concurrent Operations', () {
      test('should handle multiple concurrent profile fetches', () async {
        // Arrange
        const userIds = ['user1', 'user2', 'user3', 'user4', 'user5'];
        final profiles = userIds.map((id) => Profile(id: id, firstName: 'User $id')).toList();

        for (int i = 0; i < userIds.length; i++) {
          when(mockBackendApiService.getUserProfileById(userIds[i]))
              .thenAnswer((_) async => profiles[i]);
        }

        // Act
        final futures = userIds.map((id) => profileRepository.getUserProfileById(id));
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, 5);
        for (int i = 0; i < results.length; i++) {
          expect(results[i].id, userIds[i]);
          expect(results[i].firstName, 'User ${userIds[i]}');
          verify(mockBackendApiService.getUserProfileById(userIds[i])).called(1);
        }
      });

      test('should handle mixed concurrent operations', () async {
        // Arrange
        const userId = 'user123';
        final profile = Profile(id: userId, firstName: 'Test');
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        const imageUrl = 'https://example.com/image.jpg';

        when(mockBackendApiService.getUserProfileById(userId))
            .thenAnswer((_) async => profile);
        when(mockBackendApiService.updateUserProfile(profile))
            .thenAnswer((_) async => {});
        when(mockBackendApiService.uploadProfileImage(userId, imageBytes, 'jpg'))
            .thenAnswer((_) async => imageUrl);
        when(mockBackendApiService.getProfileImageUrl(userId))
            .thenAnswer((_) async => imageUrl);

        // Act
        final futures = [
          profileRepository.getUserProfileById(userId),
          profileRepository.updateUserProfile(profile).then((_) => profile),
          profileRepository.uploadProfileImage(userId, imageBytes, 'jpg').then((_) => profile),
          profileRepository.getProfileImageUrl(userId).then((_) => profile),
        ];

        final results = await Future.wait(futures);

        // Assert
        expect(results.length, 4);
        for (final result in results) {
          expect(result.id, userId);
        }

        verify(mockBackendApiService.getUserProfileById(userId)).called(1);
        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
        verify(mockBackendApiService.uploadProfileImage(userId, imageBytes, 'jpg')).called(1);
        verify(mockBackendApiService.getProfileImageUrl(userId)).called(1);
      });
    });
  });
}