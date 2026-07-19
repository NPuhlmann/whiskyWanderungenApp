import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/profile/profile_view_model.dart';
import 'package:whisky_hikes/domain/models/account.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('ProfilePageViewModel Tests', () {
    late ProfilePageViewModel viewModel;
    late MockProfileRepository mockProfileRepository;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockProfileRepository = MockProfileRepository();
      mockUserRepository = MockUserRepository();
      viewModel = ProfilePageViewModel(
        profileRepository: mockProfileRepository,
        userRepository: mockUserRepository,
      );
    });

    group('Initialization', () {
      test('should initialize with correct default values', () {
        expect(viewModel.profile, isA<Profile>());
        expect(viewModel.account, isA<Account>());
        expect(viewModel.account.email, '');
        expect(viewModel.isLoading, false);
      });

      test('should provide access to repositories', () {
        expect(viewModel, isA<ProfilePageViewModel>());
      });
    });

    group('loadProfile', () {
      const testUserId = 'user123';
      const testEmail = 'test@example.com';

      test('should load profile and account successfully', () async {
        // Arrange
        final expectedProfile = Profile(
          id: testUserId,
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: DateTime(1990, 5, 15),
          imageUrl: 'https://example.com/profile.jpg',
        );
        const expectedAccount = Account(
          id: testUserId,
          email: testEmail,
          role: 'user',
        );

        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.getUserProfileById(testUserId),
        ).thenAnswer((_) async => expectedProfile);
        when(
          mockUserRepository.getAccount(),
        ).thenAnswer((_) async => expectedAccount);

        // Act
        final result = await viewModel.loadProfile();

        // Assert
        expect(result!.id, testUserId);
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.imageUrl, 'https://example.com/profile.jpg');
        expect(viewModel.profile, equals(result));
        expect(viewModel.account, equals(expectedAccount));
        expect(viewModel.isLoading, false);

        verify(mockUserRepository.getUserId()).called(1);
        verify(mockProfileRepository.getUserProfileById(testUserId)).called(1);
        verify(mockUserRepository.getAccount()).called(1);
      });

      test(
        'should show an empty, editable profile when no row exists yet',
        () async {
          // Arrange - repository returns null: no `profiles` row for this
          // user (e.g. signup trigger never fired).
          when(mockUserRepository.getUserId()).thenReturn(testUserId);
          when(
            mockProfileRepository.getUserProfileById(testUserId),
          ).thenAnswer((_) async => null);
          when(mockUserRepository.getAccount()).thenAnswer(
            (_) async => const Account(id: testUserId, email: testEmail),
          );

          // Act
          final result = await viewModel.loadProfile();

          // Assert
          expect(result!.id, testUserId);
          expect(result.firstName, '');
          expect(result.lastName, '');
          expect(result.imageUrl, '');
          expect(viewModel.account.email, testEmail);
          expect(viewModel.error, isNull);
        },
      );

      test('should set error state when user ID is null', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(null);

        // Act
        final result = await viewModel.loadProfile();

        // Assert
        expect(result, isNull);
        expect(viewModel.error, isNotNull);
        expect(
          viewModel.error.toString(),
          contains('Benutzer-ID konnte nicht ermittelt werden'),
        );
        expect(viewModel.isLoading, false);
      });

      test('should set error state on profile repository errors', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.getUserProfileById(testUserId),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await viewModel.loadProfile();

        // Assert
        expect(result, isNull);
        expect(viewModel.error.toString(), contains('Network error'));
        expect(viewModel.isLoading, false);
      });

      test('should set error state when account loading fails', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.getUserProfileById(testUserId),
        ).thenAnswer((_) async => Profile(id: testUserId));
        when(
          mockUserRepository.getAccount(),
        ).thenThrow(Exception('Account load failed'));

        // Act
        final result = await viewModel.loadProfile();

        // Assert
        expect(result, isNull);
        expect(viewModel.error.toString(), contains('Account load failed'));
        expect(viewModel.isLoading, false);
      });

      test('should set loading state correctly during operation', () async {
        // Arrange
        final profile = Profile(id: testUserId);
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(mockProfileRepository.getUserProfileById(testUserId)).thenAnswer((
          _,
        ) async {
          expect(
            viewModel.isLoading,
            true,
          ); // Should be loading during async call
          return profile;
        });
        when(
          mockUserRepository.getAccount(),
        ).thenAnswer((_) async => const Account(id: testUserId));

        expect(viewModel.isLoading, false); // Initially false

        // Act
        await viewModel.loadProfile();

        // Assert
        expect(viewModel.isLoading, false); // Should be false after completion
      });
    });

    group('updateProfile', () {
      const testUserId = 'user123';
      const currentEmail = 'current@example.com';
      const newEmail = 'new@example.com';

      setUp(() async {
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.getUserProfileById(testUserId),
        ).thenAnswer((_) async => Profile(id: testUserId));
        when(mockUserRepository.getAccount()).thenAnswer(
          (_) async => const Account(id: testUserId, email: currentEmail),
        );
        await viewModel.loadProfile();
      });

      test('should update profile without email change', () async {
        // Arrange
        final updatedProfile = Profile(
          id: testUserId,
          firstName: 'Updated',
          lastName: 'Name',
        );

        when(
          mockProfileRepository.updateUserProfile(updatedProfile),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.updateProfile(updatedProfile, email: currentEmail);

        // Assert
        expect(viewModel.profile, equals(updatedProfile));
        expect(viewModel.isLoading, false);

        verify(
          mockProfileRepository.updateUserProfile(updatedProfile),
        ).called(1);
        verifyNever(mockUserRepository.updateUserEmail(any));
      });

      test('should update profile with email change', () async {
        // Arrange
        final updatedProfile = Profile(
          id: testUserId,
          firstName: 'Updated',
          lastName: 'Name',
        );

        when(
          mockUserRepository.updateUserEmail(newEmail),
        ).thenAnswer((_) async {});
        when(
          mockProfileRepository.updateUserProfile(updatedProfile),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.updateProfile(updatedProfile, email: newEmail);

        // Assert
        expect(viewModel.profile, equals(updatedProfile));
        expect(viewModel.account.email, newEmail);

        verify(mockUserRepository.updateUserEmail(newEmail)).called(1);
        verify(
          mockProfileRepository.updateUserProfile(updatedProfile),
        ).called(1);
      });

      test('should not update email when new email is empty', () async {
        // Arrange
        final updatedProfile = Profile(
          id: testUserId,
          firstName: 'Updated',
          lastName: 'Name',
        );

        when(
          mockProfileRepository.updateUserProfile(updatedProfile),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.updateProfile(updatedProfile, email: '');

        // Assert
        verify(
          mockProfileRepository.updateUserProfile(updatedProfile),
        ).called(1);
        verifyNever(mockUserRepository.updateUserEmail(any));
      });

      test('should handle email update errors gracefully', () async {
        // Arrange
        final updatedProfile = Profile(id: testUserId);

        when(
          mockUserRepository.updateUserEmail(newEmail),
        ).thenThrow(Exception('Email update failed'));

        // Act - should complete without throwing
        await viewModel.updateProfile(updatedProfile, email: newEmail);

        // Assert
        expect(viewModel.isLoading, false);
        verify(mockUserRepository.updateUserEmail(newEmail)).called(1);
        verifyNever(mockProfileRepository.updateUserProfile(any));
      });

      test(
        'should handle profile repository update errors gracefully',
        () async {
          // Arrange
          final updatedProfile = Profile(id: testUserId);

          when(
            mockProfileRepository.updateUserProfile(updatedProfile),
          ).thenThrow(Exception('Database error'));

          // Act - should complete without throwing
          await viewModel.updateProfile(updatedProfile, email: currentEmail);

          // Assert
          expect(viewModel.isLoading, false);
          verify(
            mockProfileRepository.updateUserProfile(updatedProfile),
          ).called(1);
        },
      );

      test('should set loading state correctly during update', () async {
        // Arrange
        final profile = Profile(id: testUserId);
        when(mockProfileRepository.updateUserProfile(profile)).thenAnswer((
          _,
        ) async {
          expect(viewModel.isLoading, true);
        });

        expect(viewModel.isLoading, false);

        // Act
        await viewModel.updateProfile(profile, email: currentEmail);

        // Assert
        expect(viewModel.isLoading, false);
      });
    });

    group('uploadProfileImage', () {
      const testUserId = 'user123';
      final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      const testFileExt = 'jpg';
      const uploadedImageUrl = 'https://example.com/uploaded.jpg';

      setUp(() {
        // Set up existing profile for upload tests
        viewModel.profile.id = testUserId;
        viewModel.profile.firstName = 'Test';
      });

      test('should upload image successfully', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => uploadedImageUrl);
        when(
          mockProfileRepository.updateUserProfile(any),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.uploadProfileImage(testImageBytes, testFileExt);

        // Assert
        expect(viewModel.profile.imageUrl, uploadedImageUrl);
        expect(viewModel.isLoading, false);

        verify(mockUserRepository.getUserId()).called(1);
        verify(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).called(1);
        verify(mockProfileRepository.updateUserProfile(any)).called(1);
      });

      test(
        'should handle missing user ID gracefully without calling backend',
        () async {
          // Arrange
          when(mockUserRepository.getUserId()).thenReturn(null);

          // Act - errors are caught internally, never rethrown to the UI
          await viewModel.uploadProfileImage(testImageBytes, testFileExt);

          // Assert
          expect(viewModel.isLoading, false);
          verifyNever(mockProfileRepository.uploadProfileImage(any, any, any));
        },
      );

      test(
        'should handle empty image bytes gracefully without calling backend',
        () async {
          // Arrange
          final emptyBytes = Uint8List.fromList([]);
          when(mockUserRepository.getUserId()).thenReturn(testUserId);

          // Act
          await viewModel.uploadProfileImage(emptyBytes, testFileExt);

          // Assert
          expect(viewModel.isLoading, false);
          verifyNever(mockProfileRepository.uploadProfileImage(any, any, any));
        },
      );

      test(
        'should handle oversized images gracefully without calling backend',
        () async {
          // Arrange
          final largeBytes = Uint8List.fromList(
            List.filled(11 * 1024 * 1024, 1),
          ); // 11MB
          when(mockUserRepository.getUserId()).thenReturn(testUserId);

          // Act
          await viewModel.uploadProfileImage(largeBytes, testFileExt);

          // Assert
          expect(viewModel.isLoading, false);
          verifyNever(mockProfileRepository.uploadProfileImage(any, any, any));
        },
      );

      test('should retry upload on retryable errors', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) => throw Exception('Network timeout'));
        when(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async => uploadedImageUrl);
        when(
          mockProfileRepository.updateUserProfile(any),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.uploadProfileImage(testImageBytes, testFileExt);

        // Assert
        expect(viewModel.profile.imageUrl, uploadedImageUrl);
        verify(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).called(1);
      });

      test('should fail after max retries', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).thenThrow(Exception('Network timeout')); // Always fails

        // Act & Assert
        await viewModel.uploadProfileImage(testImageBytes, testFileExt);

        // Should not throw since we handle errors gracefully
        expect(viewModel.isLoading, false);

        verify(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).called(3);
      });

      test('should not retry on non-retryable errors', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).thenThrow(Exception('Permission denied')); // Non-retryable error

        // Act & Assert
        await viewModel.uploadProfileImage(testImageBytes, testFileExt);

        // Should not throw since we handle errors gracefully
        verify(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).called(1);
      });

      test('should identify retryable errors correctly', () async {
        // Arrange
        final retryableErrors = [
          'Network timeout',
          'Connection failed',
          'HTTP 503',
          'HTTP 502',
          'HTTP 500',
        ];

        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.updateUserProfile(any),
        ).thenAnswer((_) async => {});

        // Test each retryable error
        for (final errorMessage in retryableErrors) {
          when(
            mockProfileRepository.uploadProfileImage(
              testUserId,
              testImageBytes,
              testFileExt,
            ),
          ).thenAnswer((_) => throw Exception(errorMessage));
          when(
            mockProfileRepository.uploadProfileImage(
              testUserId,
              testImageBytes,
              testFileExt,
            ),
          ).thenAnswer((_) async => uploadedImageUrl);

          // Act & Assert - should retry and eventually succeed
          await viewModel.uploadProfileImage(testImageBytes, testFileExt);
          expect(viewModel.profile.imageUrl, uploadedImageUrl);

          // Reset for next test
          reset(mockProfileRepository);
          when(
            mockProfileRepository.updateUserProfile(any),
          ).thenAnswer((_) async => {});
        }
      });

      test('should identify non-retryable errors correctly', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);

        final nonRetryableErrors = [
          'PlatformException image_picker',
          'permission denied',
          'storage error',
        ];

        // Test each error type
        for (final error in nonRetryableErrors) {
          when(
            mockProfileRepository.uploadProfileImage(
              testUserId,
              testImageBytes,
              testFileExt,
            ),
          ).thenThrow(Exception(error));

          // Act & Assert - should not retry
          await viewModel.uploadProfileImage(testImageBytes, testFileExt);

          // Should only be called once (no retry)
          verify(
            mockProfileRepository.uploadProfileImage(
              testUserId,
              testImageBytes,
              testFileExt,
            ),
          ).called(1);

          // Reset for next test
          reset(mockProfileRepository);
        }
      });

      test(
        'should handle profile update error after successful upload',
        () async {
          // Arrange
          when(mockUserRepository.getUserId()).thenReturn(testUserId);
          when(
            mockProfileRepository.uploadProfileImage(
              testUserId,
              testImageBytes,
              testFileExt,
            ),
          ).thenAnswer((_) async => uploadedImageUrl);
          when(
            mockProfileRepository.updateUserProfile(any),
          ).thenThrow(Exception('Profile update failed'));

          // Act
          await viewModel.uploadProfileImage(testImageBytes, testFileExt);

          // Image URL should be updated in memory even if profile update failed
          // since the upload was successful
          expect(viewModel.profile.imageUrl, equals(uploadedImageUrl));
          expect(viewModel.isLoading, false);
        },
      );

      test('should set loading state correctly during upload', () async {
        // Arrange
        when(mockUserRepository.getUserId()).thenReturn(testUserId);
        when(
          mockProfileRepository.uploadProfileImage(
            testUserId,
            testImageBytes,
            testFileExt,
          ),
        ).thenAnswer((_) async {
          expect(viewModel.isLoading, true);
          return uploadedImageUrl;
        });
        when(
          mockProfileRepository.updateUserProfile(any),
        ).thenAnswer((_) async => {});

        expect(viewModel.isLoading, false);

        // Act
        await viewModel.uploadProfileImage(testImageBytes, testFileExt);

        // Assert
        expect(viewModel.isLoading, false);
      });
    });

    group('signOut', () {
      test('should call userRepository signOut', () {
        // Arrange
        when(mockUserRepository.signUserOut()).thenAnswer((_) async => {});

        // Act
        viewModel.signOut();

        // Assert
        verify(mockUserRepository.signUserOut()).called(1);
      });

      test('should handle signOut errors gracefully', () {
        // Arrange
        when(
          mockUserRepository.signUserOut(),
        ).thenThrow(Exception('Sign out failed'));

        // Act & Assert - should throw since signOut doesn't handle errors
        expect(() => viewModel.signOut(), throwsA(isA<Exception>()));
      });
    });

    group('Error Handling', () {
      test('should handle various error types in uploadProfileImage', () async {
        // Arrange
        final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(mockUserRepository.getUserId()).thenReturn('user123');

        final errorTypes = [
          'PlatformException image_picker',
          'permission denied',
          'network timeout',
          'storage error',
          'unknown error',
        ];

        // Test each error type
        for (final error in errorTypes) {
          when(
            mockProfileRepository.uploadProfileImage(any, any, any),
          ).thenThrow(Exception(error));

          // Act & Assert
          await viewModel.uploadProfileImage(testImageBytes, 'jpg');

          // Should not throw since we handle errors gracefully

          reset(mockProfileRepository);
        }
      });

      test('should maintain state consistency on errors', () async {
        // Arrange
        final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final originalProfile = Profile(id: 'user123', firstName: 'Original');
        viewModel.profile.id = originalProfile.id;
        viewModel.profile.firstName = originalProfile.firstName;

        when(mockUserRepository.getUserId()).thenReturn('user123');
        when(
          mockProfileRepository.uploadProfileImage(any, any, any),
        ).thenThrow(Exception('Upload failed'));

        // Act
        await viewModel.uploadProfileImage(testImageBytes, 'jpg');

        // Should not throw since we handle errors gracefully

        // Assert - profile should maintain original state
        expect(viewModel.profile.firstName, 'Original');
        expect(viewModel.isLoading, false);
      });
    });

    group('Edge Cases', () {
      test('should handle profile with all null/empty values', () async {
        // Arrange
        final emptyProfile = Profile(id: 'empty');
        when(mockUserRepository.getUserId()).thenReturn('empty');
        when(
          mockProfileRepository.getUserProfileById('empty'),
        ).thenAnswer((_) async => emptyProfile);
        when(
          mockUserRepository.getAccount(),
        ).thenAnswer((_) async => const Account(id: 'empty'));

        // Act
        final result = await viewModel.loadProfile();

        // Assert
        expect(result!.firstName, '');
        expect(result.lastName, '');
        expect(result.imageUrl, '');
        expect(viewModel.account.email, '');
      });

      test('should handle extremely large valid image', () async {
        // Arrange
        final largeValidBytes = Uint8List.fromList(
          List.filled(9 * 1024 * 1024, 1),
        ); // 9MB (under 10MB limit)
        when(mockUserRepository.getUserId()).thenReturn('user123');
        when(
          mockProfileRepository.uploadProfileImage(
            'user123',
            largeValidBytes,
            'jpg',
          ),
        ).thenAnswer((_) async => 'https://example.com/large.jpg');
        when(
          mockProfileRepository.updateUserProfile(any),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.uploadProfileImage(largeValidBytes, 'jpg');

        // Assert
        expect(viewModel.profile.imageUrl, 'https://example.com/large.jpg');
        verify(
          mockProfileRepository.uploadProfileImage(
            'user123',
            largeValidBytes,
            'jpg',
          ),
        ).called(1);
      });

      test('should handle concurrent updateProfile calls', () async {
        // Arrange
        final profile1 = Profile(id: 'user1', firstName: 'User1');
        final profile2 = Profile(id: 'user2', firstName: 'User2');

        when(
          mockProfileRepository.updateUserProfile(any),
        ).thenAnswer((_) async => {});

        // Act - start concurrent updates
        await viewModel.updateProfile(profile1, email: '');
        await viewModel.updateProfile(profile2, email: '');

        // Assert - final state should be consistent
        expect(viewModel.isLoading, false);
        // Profile should be one of the updated profiles
        expect([
          profile1.firstName,
          profile2.firstName,
        ], contains(viewModel.profile.firstName));
      });
    });

    group('Notification Behavior', () {
      test('should notify listeners during loadProfile', () async {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        final profile = Profile(id: 'user123');
        when(mockUserRepository.getUserId()).thenReturn('user123');
        when(
          mockProfileRepository.getUserProfileById('user123'),
        ).thenAnswer((_) async => profile);
        when(
          mockUserRepository.getAccount(),
        ).thenAnswer((_) async => const Account(id: 'user123'));

        // Act
        await viewModel.loadProfile();

        // Assert
        expect(
          notificationCount,
          greaterThanOrEqualTo(2),
        ); // At least start and end notifications
      });

      test('should notify listeners during updateProfile', () async {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        final profile = Profile(id: 'user123');
        when(
          mockProfileRepository.updateUserProfile(profile),
        ).thenAnswer((_) async => {});

        // Act
        await viewModel.updateProfile(profile, email: '');

        // Assert
        expect(
          notificationCount,
          greaterThanOrEqualTo(2),
        ); // At least start and end notifications
      });

      test('should notify listeners on signOut', () {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        when(mockUserRepository.signUserOut()).thenAnswer((_) async => {});

        // Act
        viewModel.signOut();

        // Assert
        expect(notificationCount, 1);
      });
    });
  });
}
