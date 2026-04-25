import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('ProfileRepository Tests', () {
    late MockBackendApiService mockBackendApiService;
    late MockLocalCacheService mockLocalCacheService;
    late ProfileRepository profileRepository;

    setUp(() {
      mockBackendApiService = MockBackendApiService();
      mockLocalCacheService = MockLocalCacheService();
      profileRepository = ProfileRepository(
        mockBackendApiService,
        mockLocalCacheService,
      );

      // Setup default mock behaviors
      when(
        mockLocalCacheService.getCachedProfileImagePath(any),
      ).thenAnswer((_) async => null);
      when(
        mockLocalCacheService.getCachedProfileData(any),
      ).thenAnswer((_) async => null);
      when(
        mockLocalCacheService.cacheProfileData(any, any),
      ).thenAnswer((_) async {});
      when(
        mockLocalCacheService.cacheProfileImage(any, any, any),
      ).thenAnswer((_) async => null);
    });

    group('getUserProfileById', () {
      const testUserId = 'user123';

      test('should return cached profile when cache hit', () async {
        // Arrange
        final cachedProfile = Profile(
          id: testUserId,
          firstName: 'Cached',
          lastName: 'User',
          email: 'cached@example.com',
        );

        when(
          mockLocalCacheService.getCachedProfileData(testUserId),
        ).thenAnswer((_) async => cachedProfile);

        // Act
        final result = await profileRepository.getUserProfileById(testUserId);

        // Assert
        expect(result, equals(cachedProfile));
        expect(result.firstName, 'Cached');
        expect(result.lastName, 'User');
        expect(result.email, 'cached@example.com');

        // Should not call backend API on cache hit
        verifyNever(mockBackendApiService.getUserProfileById(testUserId));
        verify(
          mockLocalCacheService.getCachedProfileData(testUserId),
        ).called(1);
      });

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

        when(
          mockLocalCacheService.getCachedProfileData(testUserId),
        ).thenAnswer((_) async => null); // Force cache miss to trigger API call
        when(
          mockBackendApiService.getUserProfileById(testUserId),
        ).thenAnswer((_) async => expectedProfile);
        when(
          mockLocalCacheService.cacheProfileData(expectedProfile, testUserId),
        ).thenAnswer((_) async => {});

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

      test(
        'should return profile with default values when profile is empty',
        () async {
          // Arrange
          final emptyProfile = Profile(id: testUserId);

          when(
            mockLocalCacheService.getCachedProfileData(testUserId),
          ).thenAnswer(
            (_) async => null,
          ); // Force cache miss to trigger API call
          when(
            mockBackendApiService.getUserProfileById(testUserId),
          ).thenAnswer((_) async => emptyProfile);
          when(
            mockLocalCacheService.cacheProfileData(emptyProfile, testUserId),
          ).thenAnswer((_) async => {});

          // Act
          final result = await profileRepository.getUserProfileById(testUserId);

          // Assert
          expect(result.id, testUserId);
          expect(result.firstName, '');
          expect(result.lastName, '');
          expect(result.email, '');
          expect(result.dateOfBirth, null);
          expect(result.imageUrl, '');

          verify(
            mockBackendApiService.getUserProfileById(testUserId),
          ).called(1);
        },
      );

      test('should throw exception when backend service fails', () async {
        // Arrange
        when(
          mockLocalCacheService.getCachedProfileData(testUserId),
        ).thenAnswer((_) async => null); // Force cache miss to trigger API call
        when(
          mockBackendApiService.getUserProfileById(testUserId),
        ).thenThrow(Exception('User not found'));

        // Act & Assert
        expect(
          () async => await profileRepository.getUserProfileById(testUserId),
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

        when(
          mockLocalCacheService.getCachedProfileData(userId1),
        ).thenAnswer((_) async => null); // Force cache miss to trigger API call
        when(
          mockLocalCacheService.getCachedProfileData(userId2),
        ).thenAnswer((_) async => null); // Force cache miss to trigger API call
        when(
          mockBackendApiService.getUserProfileById(userId1),
        ).thenAnswer((_) async => profile1);
        when(
          mockBackendApiService.getUserProfileById(userId2),
        ).thenAnswer((_) async => profile2);
        when(
          mockLocalCacheService.cacheProfileData(profile1, userId1),
        ).thenAnswer((_) async => {});
        when(
          mockLocalCacheService.cacheProfileData(profile2, userId2),
        ).thenAnswer((_) async => {});

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

        when(
          mockLocalCacheService.getCachedProfileData(emptyUserId),
        ).thenAnswer((_) async => null); // Force cache miss to trigger API call
        when(
          mockBackendApiService.getUserProfileById(emptyUserId),
        ).thenAnswer((_) async => emptyProfile);
        when(
          mockLocalCacheService.cacheProfileData(emptyProfile, emptyUserId),
        ).thenAnswer((_) async => {});

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

        when(
          mockLocalCacheService.getCachedProfileData(specialUserId),
        ).thenAnswer((_) async => null); // Force cache miss to trigger API call
        when(
          mockBackendApiService.getUserProfileById(specialUserId),
        ).thenAnswer((_) async => profile);
        when(
          mockLocalCacheService.cacheProfileData(profile, specialUserId),
        ).thenAnswer((_) async => {});

        // Act
        final result = await profileRepository.getUserProfileById(
          specialUserId,
        );

        // Assert
        expect(result.id, specialUserId);
        expect(result.firstName, 'José');
        expect(result.lastName, 'Müller-Özkaya');
        verify(
          mockBackendApiService.getUserProfileById(specialUserId),
        ).called(1);
      });

      test('should use expired cache as fallback when backend fails', () async {
        // Arrange
        final expiredProfile = Profile(
          id: testUserId,
          firstName: 'Expired',
          lastName: 'Cache',
          email: 'expired@example.com',
        );

        // Setup cache to return different values for sequential calls
        var callCount = 0;
        when(mockLocalCacheService.getCachedProfileData(testUserId)).thenAnswer(
          (_) async {
            callCount++;
            if (callCount == 1) {
              return null; // First call returns null (cache miss)
            }
            return expiredProfile; // Second call returns expired profile
          },
        );
        when(
          mockBackendApiService.getUserProfileById(testUserId),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await profileRepository.getUserProfileById(testUserId);

        // Assert - should return expired profile as fallback
        expect(result.id, expiredProfile.id);
        expect(result.firstName, expiredProfile.firstName);
        expect(result.lastName, expiredProfile.lastName);
        expect(result.firstName, 'Expired');
        expect(result.lastName, 'Cache');

        verify(mockBackendApiService.getUserProfileById(testUserId)).called(1);
        verify(
          mockLocalCacheService.getCachedProfileData(testUserId),
        ).called(2); // Called twice for fallback
      });

      test(
        'should throw exception when backend fails and no cache available',
        () async {
          // Arrange
          // Setup cache to always return null (no fallback available)
          when(
            mockLocalCacheService.getCachedProfileData(testUserId),
          ).thenAnswer((_) async => null);
          when(
            mockBackendApiService.getUserProfileById(testUserId),
          ).thenThrow(Exception('Network error'));

          // Act & Assert - should throw since no fallback cache is available
          expect(
            () => profileRepository.getUserProfileById(testUserId),
            throwsA(isA<Exception>()),
          );

          verify(
            mockBackendApiService.getUserProfileById(testUserId),
          ).called(1);
          verify(
            mockLocalCacheService.getCachedProfileData(testUserId),
          ).called(2); // Called twice for fallback
        },
      );
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

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await profileRepository.updateUserProfile(profile);

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'Test');

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenThrow(Exception('Update failed'));

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

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenAnswer((_) async => {});

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

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenAnswer((_) async => {});

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

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenAnswer((_) async => {});

        // Act & Assert
        await profileRepository.updateUserProfile(profile);

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should cache updated profile after successful update', () async {
        // Arrange
        final profile = Profile(
          id: 'user123',
          firstName: 'Updated',
          lastName: 'User',
          email: 'updated@example.com',
        );

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenAnswer((_) async => {});
        when(
          mockLocalCacheService.cacheProfileData(profile, profile.id),
        ).thenAnswer((_) async => {});

        // Act
        await profileRepository.updateUserProfile(profile);

        // Assert
        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
        verify(
          mockLocalCacheService.cacheProfileData(profile, profile.id),
        ).called(1);
      });

      test('should not cache profile if backend update fails', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'Test');

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => profileRepository.updateUserProfile(profile),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
        verifyNever(mockLocalCacheService.cacheProfileData(any, any));
      });
    });

    group('uploadProfileImage', () {
      const testUserId = 'user123';
      const testFileExt = 'jpg';

      test('should upload image and return URL successfully', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const expectedUrl = 'https://example.com/uploaded-image.jpg';

        when(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => expectedUrl);
        when(
          mockLocalCacheService.cacheProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => expectedUrl);

        // Act
        final result = await profileRepository.uploadProfileImage(
          testUserId,
          imageBytes,
          testFileExt,
        );

        // Assert
        expect(result, expectedUrl);
        verify(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).called(1);
      });

      test('should throw exception when upload fails', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).thenThrow(Exception('Upload failed'));

        // Act & Assert
        expect(
          () => profileRepository.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
          throwsA(isA<Exception>()),
        );

        verify(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).called(1);
      });

      test('should handle different file extensions', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const extensions = ['jpg', 'png', 'webp', 'jpeg'];

        for (final ext in extensions) {
          final expectedUrl = 'https://example.com/image.$ext';
          when(
            mockBackendApiService.uploadProfileImage(
              testUserId,
              imageBytes,
              ext,
            ),
          ).thenAnswer((_) async => expectedUrl);
          when(
            mockLocalCacheService.cacheProfileImage(
              testUserId,
              imageBytes,
              ext,
            ),
          ).thenAnswer((_) async => expectedUrl);
        }

        // Act & Assert
        for (final ext in extensions) {
          final result = await profileRepository.uploadProfileImage(
            testUserId,
            imageBytes,
            ext,
          );
          expect(result, 'https://example.com/image.$ext');
          verify(
            mockBackendApiService.uploadProfileImage(
              testUserId,
              imageBytes,
              ext,
            ),
          ).called(1);
        }
      });

      test('should handle large image bytes', () async {
        // Arrange
        final largeImageBytes = Uint8List.fromList(
          List.generate(1000000, (index) => index % 256),
        );
        const expectedUrl = 'https://example.com/large-image.jpg';

        when(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            largeImageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => expectedUrl);
        when(
          mockLocalCacheService.cacheProfileImage(
            testUserId,
            largeImageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => expectedUrl);

        // Act
        final result = await profileRepository.uploadProfileImage(
          testUserId,
          largeImageBytes,
          testFileExt,
        );

        // Assert
        expect(result, expectedUrl);
        verify(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            largeImageBytes,
            testFileExt,
          ),
        ).called(1);
      });

      test('should handle empty image bytes', () async {
        // Arrange
        final emptyImageBytes = Uint8List.fromList([]);

        when(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            emptyImageBytes,
            testFileExt,
          ),
        ).thenThrow(Exception('Empty file not allowed'));

        // Act & Assert
        expect(
          () => profileRepository.uploadProfileImage(
            testUserId,
            emptyImageBytes,
            testFileExt,
          ),
          throwsA(isA<Exception>()),
        );

        verify(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            emptyImageBytes,
            testFileExt,
          ),
        ).called(1);
      });

      test('should cache image locally after successful upload', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const expectedUrl = 'https://example.com/uploaded-image.jpg';

        when(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => expectedUrl);
        when(
          mockLocalCacheService.cacheProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => '/local/cache/path');

        // Act
        final result = await profileRepository.uploadProfileImage(
          testUserId,
          imageBytes,
          testFileExt,
        );

        // Assert
        expect(result, expectedUrl);
        verify(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).called(1);
        verify(
          mockLocalCacheService.cacheProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).called(1);
      });

      test('should not cache image if upload fails', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).thenThrow(Exception('Upload failed'));

        // Act & Assert
        expect(
          () => profileRepository.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
          throwsA(isA<Exception>()),
        );

        verify(
          mockBackendApiService.uploadProfileImage(
            testUserId,
            imageBytes,
            testFileExt,
          ),
        ).called(1);
        verifyNever(mockLocalCacheService.cacheProfileImage(any, any, any));
      });
    });

    group('getProfileImageUrl', () {
      const testUserId = 'user123';

      test('should return image URL when it exists', () async {
        // Arrange
        const expectedUrl = 'https://example.com/profile-image.jpg';

        when(
          mockBackendApiService.getProfileImageUrl(testUserId),
        ).thenAnswer((_) async => expectedUrl);
        when(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).thenAnswer((_) async => null);

        // Act
        final result = await profileRepository.getProfileImageUrl(testUserId);

        // Assert
        expect(result, expectedUrl);
        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });

      test('should return null when no image exists', () async {
        // Arrange
        when(
          mockBackendApiService.getProfileImageUrl(testUserId),
        ).thenAnswer((_) async => null);
        when(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).thenAnswer((_) async => null);

        // Act
        final result = await profileRepository.getProfileImageUrl(testUserId);

        // Assert
        expect(result, null);
        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        when(
          mockBackendApiService.getProfileImageUrl(testUserId),
        ).thenThrow(Exception('Service unavailable'));
        when(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => profileRepository.getProfileImageUrl(testUserId),
          throwsA(isA<Exception>()),
        );

        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
        verify(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).called(1);
      });

      test('should handle different user IDs', () async {
        // Arrange
        const userId1 = 'user1';
        const userId2 = 'user2';
        const userId3 = 'user3';

        const url1 = 'https://example.com/user1.jpg';
        const url2 = 'https://example.com/user2.png';

        when(
          mockBackendApiService.getProfileImageUrl(userId1),
        ).thenAnswer((_) async => url1);
        when(
          mockLocalCacheService.getCachedProfileImagePath(userId1),
        ).thenAnswer((_) async => null);
        when(
          mockBackendApiService.getProfileImageUrl(userId2),
        ).thenAnswer((_) async => url2);
        when(
          mockLocalCacheService.getCachedProfileImagePath(userId2),
        ).thenAnswer((_) async => null);
        when(
          mockBackendApiService.getProfileImageUrl(userId3),
        ).thenAnswer((_) async => null);
        when(
          mockLocalCacheService.getCachedProfileImagePath(userId3),
        ).thenAnswer((_) async => null);

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

        when(
          mockBackendApiService.getProfileImageUrl(emptyUserId),
        ).thenAnswer((_) async => null);
        when(
          mockLocalCacheService.getCachedProfileImagePath(emptyUserId),
        ).thenAnswer((_) async => null);

        // Act
        final result = await profileRepository.getProfileImageUrl(emptyUserId);

        // Assert
        expect(result, null);
        verify(mockBackendApiService.getProfileImageUrl(emptyUserId)).called(1);
      });

      test(
        'should return cached image path with file:// prefix when cache hit',
        () async {
          // Arrange
          const cachedImagePath = '/path/to/cached/image.jpg';
          const expectedFileUrl = 'file://$cachedImagePath';

          when(
            mockLocalCacheService.getCachedProfileImagePath(testUserId),
          ).thenAnswer((_) async => cachedImagePath);

          // Act
          final result = await profileRepository.getProfileImageUrl(testUserId);

          // Assert
          expect(result, expectedFileUrl);
          verify(
            mockLocalCacheService.getCachedProfileImagePath(testUserId),
          ).called(1);
          // Should not call backend API on cache hit
          verifyNever(mockBackendApiService.getProfileImageUrl(testUserId));
        },
      );

      test(
        'should return backend URL and attempt caching when cache miss',
        () async {
          // Arrange
          const backendUrl = 'https://example.com/profile.jpg';

          when(
            mockLocalCacheService.getCachedProfileImagePath(testUserId),
          ).thenAnswer((_) async => null); // Cache miss
          when(
            mockBackendApiService.getProfileImageUrl(testUserId),
          ).thenAnswer((_) async => backendUrl);

          // Act
          final result = await profileRepository.getProfileImageUrl(testUserId);

          // Assert
          expect(result, backendUrl);
          verify(
            mockLocalCacheService.getCachedProfileImagePath(testUserId),
          ).called(1);
          verify(
            mockBackendApiService.getProfileImageUrl(testUserId),
          ).called(1);
        },
      );

      test('should return null when no backend image and cache miss', () async {
        // Arrange
        when(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).thenAnswer((_) async => null); // Cache miss
        when(
          mockBackendApiService.getProfileImageUrl(testUserId),
        ).thenAnswer((_) async => null); // No backend image

        // Act
        final result = await profileRepository.getProfileImageUrl(testUserId);

        // Assert
        expect(result, null);
        verify(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).called(1);
        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });

      test('should handle backend errors gracefully and return null', () async {
        // Arrange
        when(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).thenAnswer((_) async => null); // Cache miss
        when(
          mockBackendApiService.getProfileImageUrl(testUserId),
        ).thenThrow(Exception('Service unavailable'));

        // Act
        final result = await profileRepository.getProfileImageUrl(testUserId);

        // Assert
        expect(result, null);
        verify(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).called(1);
        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
      });
    });

    group('Error Handling', () {
      test(
        'should propagate specific exceptions from backend service',
        () async {
          // Arrange
          const testUserId = 'user123';
          when(
            mockBackendApiService.getUserProfileById(testUserId),
          ).thenThrow(Exception('Database connection timeout'));
          when(
            mockLocalCacheService.getCachedProfileData(testUserId),
          ).thenAnswer((_) async => null);

          // Act & Assert
          expect(
            () => profileRepository.getUserProfileById(testUserId),
            throwsA(
              predicate(
                (e) => e.toString().contains('Database connection timeout'),
              ),
            ),
          );

          verify(
            mockBackendApiService.getUserProfileById(testUserId),
          ).called(1);
          verify(
            mockLocalCacheService.getCachedProfileData(testUserId),
          ).called(1);
        },
      );

      test('should handle network timeouts', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'Test');

        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () => profileRepository.updateUserProfile(profile),
          throwsA(predicate((e) => e.toString().contains('Network timeout'))),
        );

        verify(mockBackendApiService.updateUserProfile(profile)).called(1);
      });

      test('should handle authentication errors', () async {
        // Arrange
        const testUserId = 'user123';

        when(
          mockBackendApiService.getProfileImageUrl(testUserId),
        ).thenThrow(Exception('Unauthorized access'));
        when(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => profileRepository.getProfileImageUrl(testUserId),
          throwsA(
            predicate((e) => e.toString().contains('Unauthorized access')),
          ),
        );

        verify(mockBackendApiService.getProfileImageUrl(testUserId)).called(1);
        verify(
          mockLocalCacheService.getCachedProfileImagePath(testUserId),
        ).called(1);
      });
    });

    group('Concurrent Operations', () {
      test('should handle multiple concurrent profile fetches', () async {
        // Arrange
        const userIds = ['user1', 'user2', 'user3', 'user4', 'user5'];
        final profiles = userIds
            .map((id) => Profile(id: id, firstName: 'User $id'))
            .toList();

        for (int i = 0; i < userIds.length; i++) {
          when(
            mockLocalCacheService.getCachedProfileData(userIds[i]),
          ).thenAnswer(
            (_) async => null,
          ); // Force cache miss to trigger API call
          when(
            mockBackendApiService.getUserProfileById(userIds[i]),
          ).thenAnswer((_) async => profiles[i]);
          when(
            mockLocalCacheService.cacheProfileData(profiles[i], userIds[i]),
          ).thenAnswer((_) async => {});
        }

        // Act
        final futures = userIds.map(
          (id) => profileRepository.getUserProfileById(id),
        );
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, 5);
        for (int i = 0; i < results.length; i++) {
          expect(results[i].id, userIds[i]);
          expect(results[i].firstName, 'User ${userIds[i]}');
          verify(
            mockBackendApiService.getUserProfileById(userIds[i]),
          ).called(1);
        }
      });

      test('should handle mixed concurrent operations', () async {
        // Arrange
        const userId = 'user123';
        final profile = Profile(id: userId, firstName: 'Test');
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        const imageUrl = 'https://example.com/image.jpg';

        when(
          mockLocalCacheService.getCachedProfileData(userId),
        ).thenAnswer((_) async => null); // Force cache miss to trigger API call
        when(
          mockBackendApiService.getUserProfileById(userId),
        ).thenAnswer((_) async => profile);
        when(
          mockLocalCacheService.cacheProfileData(profile, userId),
        ).thenAnswer((_) async => {});
        when(
          mockBackendApiService.updateUserProfile(profile),
        ).thenAnswer((_) async => {});
        when(
          mockBackendApiService.uploadProfileImage(userId, imageBytes, 'jpg'),
        ).thenAnswer((_) async => imageUrl);
        when(
          mockLocalCacheService.cacheProfileImage(userId, imageBytes, 'jpg'),
        ).thenAnswer((_) async => '');
        when(
          mockBackendApiService.getProfileImageUrl(userId),
        ).thenAnswer((_) async => imageUrl);

        // Act
        final futures = [
          profileRepository.getUserProfileById(userId),
          profileRepository.updateUserProfile(profile).then((_) => profile),
          profileRepository
              .uploadProfileImage(userId, imageBytes, 'jpg')
              .then((_) => profile),
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
        verify(
          mockBackendApiService.uploadProfileImage(userId, imageBytes, 'jpg'),
        ).called(1);
        verify(mockBackendApiService.getProfileImageUrl(userId)).called(1);
      });
    });

    group('Cache Management', () {
      test('clearUserCache should delegate to cache service', () async {
        // Arrange
        const userId = 'user123';
        when(
          mockLocalCacheService.clearUserCache(userId),
        ).thenAnswer((_) async => {});

        // Act
        await profileRepository.clearUserCache(userId);

        // Assert
        verify(mockLocalCacheService.clearUserCache(userId)).called(1);
      });

      test('clearAllCache should delegate to cache service', () async {
        // Arrange
        when(mockLocalCacheService.clearAllCache()).thenAnswer((_) async => {});

        // Act
        await profileRepository.clearAllCache();

        // Assert
        verify(mockLocalCacheService.clearAllCache()).called(1);
      });

      test('getCacheStats should return cache statistics', () async {
        // Arrange
        final expectedStats = {
          'totalFiles': 5,
          'totalSizeMB': 12.5,
          'profileDataCacheCount': 3,
          'profileImageCacheCount': 2,
        };
        when(
          mockLocalCacheService.getCacheStats(),
        ).thenAnswer((_) async => expectedStats);

        // Act
        final stats = await profileRepository.getCacheStats();

        // Assert
        expect(stats, equals(expectedStats));
        expect(stats['totalFiles'], 5);
        expect(stats['totalSizeMB'], 12.5);
        expect(stats['profileDataCacheCount'], 3);
        expect(stats['profileImageCacheCount'], 2);
        verify(mockLocalCacheService.getCacheStats()).called(1);
      });

      test('hasNetworkConnection should delegate to cache service', () async {
        // Arrange
        when(
          mockLocalCacheService.hasNetworkConnection(),
        ).thenAnswer((_) async => true);

        // Act
        final hasConnection = await profileRepository.hasNetworkConnection();

        // Assert
        expect(hasConnection, true);
        verify(mockLocalCacheService.hasNetworkConnection()).called(1);
      });

      test('hasNetworkConnection should handle no connection', () async {
        // Arrange
        when(
          mockLocalCacheService.hasNetworkConnection(),
        ).thenAnswer((_) async => false);

        // Act
        final hasConnection = await profileRepository.hasNetworkConnection();

        // Assert
        expect(hasConnection, false);
        verify(mockLocalCacheService.hasNetworkConnection()).called(1);
      });
    });

    group('Cache Integration Scenarios', () {
      test('should use cache-first strategy for profile data', () async {
        // Arrange
        const userId = 'cache_test';
        final cachedProfile = Profile(
          id: userId,
          firstName: 'Cached',
          lastName: 'Data',
        );
        final backendProfile = Profile(
          id: userId,
          firstName: 'Backend',
          lastName: 'Data',
        );

        // Create a sequence of responses: first null, then cached profile
        var callCount = 0;
        when(mockLocalCacheService.getCachedProfileData(userId)).thenAnswer((
          _,
        ) async {
          callCount++;
          if (callCount == 1) return null;
          return cachedProfile;
        });
        when(
          mockBackendApiService.getUserProfileById(userId),
        ).thenAnswer((_) async => backendProfile);
        when(
          mockLocalCacheService.cacheProfileData(backendProfile, userId),
        ).thenAnswer((_) async => {});

        // Act - First call should hit backend
        final result1 = await profileRepository.getUserProfileById(userId);
        expect(result1.firstName, 'Backend'); // From backend

        // Act - Second call should hit cache
        final result2 = await profileRepository.getUserProfileById(userId);
        expect(result2.firstName, 'Cached'); // From cache

        // Assert
        verify(
          mockBackendApiService.getUserProfileById(userId),
        ).called(1); // Only once
        verify(
          mockLocalCacheService.getCachedProfileData(userId),
        ).called(2); // Twice
        verify(
          mockLocalCacheService.cacheProfileData(backendProfile, userId),
        ).called(1);
      });

      test('should use cache-first strategy for profile images', () async {
        // Arrange
        const userId = 'image_cache_test';
        const cachedImagePath = '/cached/image.jpg';
        const backendImageUrl = 'https://backend.com/image.jpg';

        // Create a sequence of responses: first null, then cached path
        var imageCallCount = 0;
        when(
          mockLocalCacheService.getCachedProfileImagePath(userId),
        ).thenAnswer((_) async {
          imageCallCount++;
          if (imageCallCount == 1) return null;
          return cachedImagePath;
        });
        when(
          mockBackendApiService.getProfileImageUrl(userId),
        ).thenAnswer((_) async => backendImageUrl);

        // Act - First call should hit backend
        final result1 = await profileRepository.getProfileImageUrl(userId);
        expect(result1, backendImageUrl); // From backend

        // Act - Second call should hit cache
        final result2 = await profileRepository.getProfileImageUrl(userId);
        expect(
          result2,
          'file://$cachedImagePath',
        ); // From cache with file:// prefix

        // Assert
        verify(
          mockBackendApiService.getProfileImageUrl(userId),
        ).called(1); // Only once
        verify(
          mockLocalCacheService.getCachedProfileImagePath(userId),
        ).called(2); // Twice
      });

      test('should handle cache service errors gracefully', () async {
        // Arrange
        const userId = 'error_test';
        final profile = Profile(id: userId, firstName: 'Test');

        when(
          mockLocalCacheService.getCachedProfileData(userId),
        ).thenThrow(Exception('Cache service error'));
        when(
          mockBackendApiService.getUserProfileById(userId),
        ).thenAnswer((_) async => profile);
        when(
          mockLocalCacheService.cacheProfileData(profile, userId),
        ).thenAnswer((_) async => {});

        // Act & Assert - should still work despite cache error
        final result = await profileRepository.getUserProfileById(userId);
        expect(result, equals(profile));

        // Backend should be called since cache failed
        verify(mockBackendApiService.getUserProfileById(userId)).called(1);
      });

      test(
        'should handle partial cache failures in image operations',
        () async {
          // Arrange
          const userId = 'partial_failure_test';
          final imageBytes = Uint8List.fromList([1, 2, 3]);
          const uploadedUrl = 'https://uploaded.com/image.jpg';

          when(
            mockBackendApiService.uploadProfileImage(userId, imageBytes, 'jpg'),
          ).thenAnswer((_) async => uploadedUrl);
          when(
            mockLocalCacheService.cacheProfileImage(userId, imageBytes, 'jpg'),
          ).thenThrow(Exception('Local cache full'));

          // Act - should still return uploaded URL even if local cache fails
          final result = await profileRepository.uploadProfileImage(
            userId,
            imageBytes,
            'jpg',
          );

          // Assert
          expect(result, uploadedUrl);
          verify(
            mockBackendApiService.uploadProfileImage(userId, imageBytes, 'jpg'),
          ).called(1);
          verify(
            mockLocalCacheService.cacheProfileImage(userId, imageBytes, 'jpg'),
          ).called(1);
        },
      );
    });
  });
}
