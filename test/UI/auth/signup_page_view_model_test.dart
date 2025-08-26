import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/UI/auth/signup/sign_up_page_view_model.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('SignUpPageViewModel Tests', () {
    late MockUserRepository mockUserRepository;
    late MockAuthService mockAuthService;
    late SignUpPageViewModel signUpViewModel;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockAuthService = MockAuthService();
      signUpViewModel = SignUpPageViewModel(
        userRepository: mockUserRepository,
        authService: mockAuthService,
      );
    });

    group('Initialization', () {
      test('should initialize with correct dependencies', () {
        expect(signUpViewModel.authService, equals(mockAuthService));
      });
    });

    group('signUpWithEmailPassword', () {
      test('should call userRepository signUpWithEmailPassword without data', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.signUpWithEmailPassword(email, password, null))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await signUpViewModel.signUpWithEmailPassword(email, password);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUserRepository.signUpWithEmailPassword(email, password, null)).called(1);
      });

      test('should call userRepository signUpWithEmailPassword with data', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final data = {'firstName': 'John', 'lastName': 'Doe'};
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.signUpWithEmailPassword(email, password, data))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await signUpViewModel.signUpWithEmailPassword(email, password, data);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUserRepository.signUpWithEmailPassword(email, password, data)).called(1);
      });

      test('should propagate exceptions from userRepository', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final exception = Exception('Sign up failed');
        
        when(mockUserRepository.signUpWithEmailPassword(email, password, null))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await signUpViewModel.signUpWithEmailPassword(email, password),
          throwsA(equals(exception)),
        );
        verify(mockUserRepository.signUpWithEmailPassword(email, password, null)).called(1);
      });

      test('should handle empty email and password', () async {
        // Arrange
        const email = '';
        const password = '';
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.signUpWithEmailPassword(email, password, null))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await signUpViewModel.signUpWithEmailPassword(email, password);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUserRepository.signUpWithEmailPassword(email, password, null)).called(1);
      });

      test('should handle complex user data', () async {
        // Arrange
        const email = 'john.doe@example.com';
        const password = 'securePassword123';
        final userData = {
          'firstName': 'John',
          'lastName': 'Doe',
          'dateOfBirth': '1990-05-15',
          'preferences': {'newsletter': true}
        };
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.signUpWithEmailPassword(email, password, userData))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await signUpViewModel.signUpWithEmailPassword(email, password, userData);

        // Assert
        expect(result, equals(expectedResponse));
        verify(mockUserRepository.signUpWithEmailPassword(email, password, userData)).called(1);
      });

      test('should handle null values in AuthResponse', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final expectedResponse = AuthResponse(user: null, session: null);
        
        when(mockUserRepository.signUpWithEmailPassword(email, password, null))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await signUpViewModel.signUpWithEmailPassword(email, password);

        // Assert
        expect(result.user, isNull);
        expect(result.session, isNull);
        verify(mockUserRepository.signUpWithEmailPassword(email, password, null)).called(1);
      });
    });
  });
}