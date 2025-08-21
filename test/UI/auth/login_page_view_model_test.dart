import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/UI/auth/login/login_page_view_model.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('LoginPageViewModel Tests', () {
    late MockUserRepository mockUserRepository;
    late LoginPageViewModel loginViewModel;

    setUp(() {
      mockUserRepository = MockUserRepository();
      loginViewModel = LoginPageViewModel(userRepository: mockUserRepository);
    });

    group('loginWithEmailAndPassword', () {
      test('should call userRepository loginWithEmailAndPassword', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.loginWithEmailAndPassword(email, password))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await loginViewModel.loginWithEmailAndPassword(email, password);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUserRepository.loginWithEmailAndPassword(email, password)).called(1);
      });

      test('should propagate exceptions from userRepository', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final exception = Exception('Login failed');
        
        when(mockUserRepository.loginWithEmailAndPassword(email, password))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await loginViewModel.loginWithEmailAndPassword(email, password),
          throwsA(equals(exception)),
        );
        verify(mockUserRepository.loginWithEmailAndPassword(email, password)).called(1);
      });

      test('should handle empty email and password', () async {
        // Arrange
        const email = '';
        const password = '';
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.loginWithEmailAndPassword(email, password))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await loginViewModel.loginWithEmailAndPassword(email, password);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUserRepository.loginWithEmailAndPassword(email, password)).called(1);
      });

      test('should handle null values in AuthResponse', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.loginWithEmailAndPassword(email, password))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await loginViewModel.loginWithEmailAndPassword(email, password);

        // Assert
        expect(result.user, isNull);
        expect(result.session, isNull);
        verify(mockUserRepository.loginWithEmailAndPassword(email, password)).called(1);
      });
    });
  });
}