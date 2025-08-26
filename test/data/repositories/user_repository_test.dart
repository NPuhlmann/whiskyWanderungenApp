import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('UserRepository Tests', () {
    late MockAuthService mockAuthService;
    late UserRepository userRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      userRepository = UserRepository(mockAuthService);
    });

    group('Initial State', () {
      test('should initialize with correct default values', () {
        expect(userRepository.isLoggedIn, false);
      });
    });

    group('signUserOut', () {
      test('should call authService signOut and notify listeners', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async {});

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act
        await userRepository.signUserOut();

        // Assert
        verify(mockAuthService.signOut()).called(1);
        expect(listenerCalled, true);
      });

      test('should notify listeners even when signOut throws', () async {
        // Arrange
        when(mockAuthService.signOut()).thenThrow(Exception('Sign out failed'));

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act & Assert
        expect(
          () async => await userRepository.signUserOut(),
          throwsA(isA<Exception>()),
        );
        expect(listenerCalled, true);
        verify(mockAuthService.signOut()).called(1);
      });
    });

    group('signUpWithEmailPassword', () {
      test('should call authService signUpWithEmailPassword and notify listeners', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final expectedResponse = AuthResponse(user: null, session: null);

        when(mockAuthService.signUpWithEmailPassword(email, password, null))
            .thenAnswer((_) async => expectedResponse);

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act
        final result = await userRepository.signUpWithEmailPassword(email, password);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockAuthService.signUpWithEmailPassword(email, password, null)).called(1);
        expect(listenerCalled, true);
      });

      test('should call authService with user data and notify listeners', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final userData = {'firstName': 'John', 'lastName': 'Doe'};
        final expectedResponse = AuthResponse(user: null, session: null);

        when(mockAuthService.signUpWithEmailPassword(email, password, userData))
            .thenAnswer((_) async => expectedResponse);

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act
        final result = await userRepository.signUpWithEmailPassword(email, password, userData);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockAuthService.signUpWithEmailPassword(email, password, userData)).called(1);
        expect(listenerCalled, true);
      });

      test('should notify listeners even when signUp throws', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        when(mockAuthService.signUpWithEmailPassword(email, password, null))
            .thenThrow(Exception('Sign up failed'));

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act & Assert
        expect(
          () async => await userRepository.signUpWithEmailPassword(email, password),
          throwsA(isA<Exception>()),
        );
        expect(listenerCalled, true);
        verify(mockAuthService.signUpWithEmailPassword(email, password, null)).called(1);
      });
    });

    group('loginWithEmailAndPassword', () {
      test('should call authService signInWithEmailPassword and notify listeners', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final expectedResponse = AuthResponse(user: null, session: null);

        when(mockAuthService.signInWithEmailPassword(email, password))
            .thenAnswer((_) async => expectedResponse);

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act
        final result = await userRepository.loginWithEmailAndPassword(email, password);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockAuthService.signInWithEmailPassword(email, password)).called(1);
        expect(listenerCalled, true);
      });

      test('should notify listeners even when login throws', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        when(mockAuthService.signInWithEmailPassword(email, password))
            .thenThrow(Exception('Login failed'));

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act & Assert
        expect(
          () async => await userRepository.loginWithEmailAndPassword(email, password),
          throwsA(isA<Exception>()),
        );
        expect(listenerCalled, true);
        verify(mockAuthService.signInWithEmailPassword(email, password)).called(1);
      });
    });

    group('isUserLoggedIn', () {
      test('should call authService isUserLoggedIn and update isLoggedIn field', () {
        // Arrange
        when(mockAuthService.isUserLoggedIn()).thenReturn(true);

        // Act
        final result = userRepository.isUserLoggedIn();

        // Assert
        expect(result, true);
        expect(userRepository.isLoggedIn, true);
        verify(mockAuthService.isUserLoggedIn()).called(1);
      });

      test('should return false when authService returns false', () {
        // Arrange
        when(mockAuthService.isUserLoggedIn()).thenReturn(false);

        // Act
        final result = userRepository.isUserLoggedIn();

        // Assert
        expect(result, false);
        expect(userRepository.isLoggedIn, false);
        verify(mockAuthService.isUserLoggedIn()).called(1);
      });
    });

    group('getUserId', () {
      test('should call authService getCurrentUserId', () {
        // Arrange
        const expectedUserId = 'user123';
        when(mockAuthService.getCurrentUserId()).thenReturn(expectedUserId);

        // Act
        final result = userRepository.getUserId();

        // Assert
        expect(result, expectedUserId);
        verify(mockAuthService.getCurrentUserId()).called(1);
      });

      test('should return null when authService returns null', () {
        // Arrange
        when(mockAuthService.getCurrentUserId()).thenReturn(null);

        // Act
        final result = userRepository.getUserId();

        // Assert
        expect(result, isNull);
        verify(mockAuthService.getCurrentUserId()).called(1);
      });
    });

    group('getUserEmail', () {
      test('should call authService getCurrentUserEmail', () {
        // Arrange
        const expectedEmail = 'user@example.com';
        when(mockAuthService.getCurrentUserEmail()).thenReturn(expectedEmail);

        // Act
        final result = userRepository.getUserEmail();

        // Assert
        expect(result, expectedEmail);
        verify(mockAuthService.getCurrentUserEmail()).called(1);
      });

      test('should return null when authService returns null', () {
        // Arrange
        when(mockAuthService.getCurrentUserEmail()).thenReturn(null);

        // Act
        final result = userRepository.getUserEmail();

        // Assert
        expect(result, isNull);
        verify(mockAuthService.getCurrentUserEmail()).called(1);
      });
    });

    group('updateUserEmail', () {
      test('should call authService updateUserEmail and notify listeners', () async {
        // Arrange
        const newEmail = 'newemail@example.com';
        when(mockAuthService.updateUserEmail(newEmail))
            .thenAnswer((_) async {});

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act
        await userRepository.updateUserEmail(newEmail);

        // Assert
        verify(mockAuthService.updateUserEmail(newEmail)).called(1);
        expect(listenerCalled, true);
      });

      test('should notify listeners even when updateUserEmail throws', () async {
        // Arrange
        const newEmail = 'newemail@example.com';
        when(mockAuthService.updateUserEmail(newEmail))
            .thenThrow(Exception('Update failed'));

        bool listenerCalled = false;
        userRepository.addListener(() => listenerCalled = true);

        // Act & Assert
        expect(
          () async => await userRepository.updateUserEmail(newEmail),
          throwsA(isA<Exception>()),
        );
        expect(listenerCalled, true);
        verify(mockAuthService.updateUserEmail(newEmail)).called(1);
      });
    });

    group('Multiple Operations', () {
      test('should handle multiple operations correctly', () async {
        // Arrange
        when(mockAuthService.isUserLoggedIn()).thenReturn(true);
        when(mockAuthService.getCurrentUserId()).thenReturn('user123');
        when(mockAuthService.getCurrentUserEmail()).thenReturn('user@example.com');

        // Act & Assert
        expect(userRepository.isUserLoggedIn(), true);
        expect(userRepository.getUserId(), 'user123');
        expect(userRepository.getUserEmail(), 'user@example.com');

        verify(mockAuthService.isUserLoggedIn()).called(1);
        verify(mockAuthService.getCurrentUserId()).called(1);
        verify(mockAuthService.getCurrentUserEmail()).called(1);
      });
    });
  });
}