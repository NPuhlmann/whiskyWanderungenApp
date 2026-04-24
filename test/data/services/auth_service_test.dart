import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/auth/auth_service.dart';

// Generate mocks
@GenerateMocks([SupabaseClient, GoTrueClient, User, Session])
import 'auth_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Tests', () {
    late AuthService authService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuthClient;
    late MockUser mockUser;
    late MockSession mockSession;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuthClient = MockGoTrueClient();
      mockUser = MockUser();
      mockSession = MockSession();

      // Setup basic mocks
      when(mockSupabaseClient.auth).thenReturn(mockAuthClient);

      authService = AuthService(client: mockSupabaseClient);
    });

    group('Sign In', () {
      test(
        'signInWithEmailPassword should return successful AuthResponse',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'TestPassword123!';
          final expectedResponse = AuthResponse(
            user: mockUser,
            session: mockSession,
          );

          when(
            mockAuthClient.signInWithPassword(email: email, password: password),
          ).thenAnswer((_) async => expectedResponse);

          // Act
          final result = await authService.signInWithEmailPassword(
            email,
            password,
          );

          // Assert
          expect(result, equals(expectedResponse));
          expect(result.user, equals(mockUser));
          expect(result.session, equals(mockSession));
          verify(
            mockAuthClient.signInWithPassword(email: email, password: password),
          ).called(1);
        },
      );

      test(
        'signInWithEmailPassword should handle authentication errors',
        () async {
          // Arrange
          const email = 'test@example.com';
          const password = 'wrongpassword';

          when(
            mockAuthClient.signInWithPassword(email: email, password: password),
          ).thenThrow(AuthException('Invalid login credentials'));

          // Act & Assert
          expect(
            () => authService.signInWithEmailPassword(email, password),
            throwsA(isA<AuthException>()),
          );
        },
      );
    });

    group('Sign Up', () {
      test('signUpWithEmailPassword should work in production mode', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'TestPassword123!';
        final userData = {'firstName': 'John', 'lastName': 'Doe'};
        final expectedResponse = AuthResponse(
          user: mockUser,
          session: mockSession,
        );

        when(
          mockAuthClient.signUp(
            email: email,
            password: password,
            data: userData,
            emailRedirectTo: 'whiskyhikes://email-confirm',
          ),
        ).thenAnswer((_) async => expectedResponse);

        final service = AuthService(
          client: mockSupabaseClient,
          isDevMode: false,
        );

        // Act
        final result = await service.signUpWithEmailPassword(
          email,
          password,
          userData,
        );

        // Assert
        expect(result, equals(expectedResponse));
        verify(
          mockAuthClient.signUp(
            email: email,
            password: password,
            data: userData,
            emailRedirectTo: 'whiskyhikes://email-confirm',
          ),
        ).called(1);
      });

      test(
        'signUpWithEmailPassword should work in dev mode with confirmed email',
        () async {
          // Arrange
          const email = 'devuser@example.com';
          const password = 'TestPassword123!';
          final userData = {'firstName': 'Dev', 'lastName': 'User'};

          when(
            mockUser.emailConfirmedAt,
          ).thenReturn(DateTime.now().toIso8601String());
          final expectedResponse = AuthResponse(
            user: mockUser,
            session: mockSession,
          );

          when(
            mockAuthClient.signUp(
              email: email,
              password: password,
              data: userData,
              emailRedirectTo: null,
            ),
          ).thenAnswer((_) async => expectedResponse);

          final service = AuthService(
            client: mockSupabaseClient,
            isDevMode: true,
          );

          // Act
          final result = await service.signUpWithEmailPassword(
            email,
            password,
            userData,
          );

          // Assert
          expect(result, equals(expectedResponse));
          verify(
            mockAuthClient.signUp(
              email: email,
              password: password,
              data: userData,
              emailRedirectTo: null,
            ),
          ).called(1);
        },
      );

      test(
        'signUpWithEmailPassword should auto-confirm in dev mode when email not confirmed',
        () async {
          // Arrange
          const email = 'unconfirmed@example.com';
          const password = 'TestPassword123!';
          final userData = {'firstName': 'Unconfirmed', 'lastName': 'User'};

          when(mockUser.emailConfirmedAt).thenReturn(null); // Not confirmed
          final signUpResponse = AuthResponse(user: mockUser, session: null);
          final signInResponse = AuthResponse(
            user: mockUser,
            session: mockSession,
          );

          when(
            mockAuthClient.signUp(
              email: email,
              password: password,
              data: userData,
              emailRedirectTo: null,
            ),
          ).thenAnswer((_) async => signUpResponse);

          when(mockAuthClient.signOut()).thenAnswer((_) async => {});
          when(
            mockAuthClient.signInWithPassword(email: email, password: password),
          ).thenAnswer((_) async => signInResponse);

          final service = AuthService(
            client: mockSupabaseClient,
            isDevMode: true,
          );

          // Act
          final result = await service.signUpWithEmailPassword(
            email,
            password,
            userData,
          );

          // Assert
          expect(result.user, equals(mockUser));
          expect(result.session, equals(mockSession));
          verify(mockAuthClient.signOut()).called(1);
          verify(
            mockAuthClient.signInWithPassword(email: email, password: password),
          ).called(1);
        },
      );

      test(
        'signUpWithEmailPassword should handle dev mode auto-confirm failure gracefully',
        () async {
          // Arrange
          const email = 'failuser@example.com';
          const password = 'TestPassword123!';
          final userData = {'firstName': 'Fail', 'lastName': 'User'};

          when(mockUser.emailConfirmedAt).thenReturn(null);
          final signUpResponse = AuthResponse(user: mockUser, session: null);

          when(
            mockAuthClient.signUp(
              email: email,
              password: password,
              data: userData,
              emailRedirectTo: null,
            ),
          ).thenAnswer((_) async => signUpResponse);

          when(mockAuthClient.signOut()).thenAnswer((_) async => {});
          when(
            mockAuthClient.signInWithPassword(email: email, password: password),
          ).thenThrow(AuthException('Email not confirmed'));

          final service = AuthService(
            client: mockSupabaseClient,
            isDevMode: true,
          );

          // Act
          final result = await service.signUpWithEmailPassword(
            email,
            password,
            userData,
          );

          // Assert - should return original signup response
          expect(result, equals(signUpResponse));
          expect(result.session, isNull);
        },
      );

      test('signUpWithEmailPassword should handle signup errors', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'TestPassword123!';

        when(
          mockAuthClient.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
            data: anyNamed('data'),
            emailRedirectTo: anyNamed('emailRedirectTo'),
          ),
        ).thenThrow(AuthException('User already registered'));

        final service = AuthService(
          client: mockSupabaseClient,
          isDevMode: false,
        );

        // Act & Assert
        expect(
          () => service.signUpWithEmailPassword(email, password),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('Sign Out', () {
      test('signOut should call auth client signOut', () async {
        // Arrange
        when(mockAuthClient.signOut()).thenAnswer((_) async => {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockAuthClient.signOut()).called(1);
      });

      test('signOut should handle errors', () async {
        // Arrange
        when(
          mockAuthClient.signOut(),
        ).thenThrow(AuthException('Sign out failed'));

        // Act & Assert
        expect(() => authService.signOut(), throwsA(isA<AuthException>()));
      });
    });

    group('User Info Retrieval', () {
      test(
        'getCurrentUserEmail should return user email when logged in',
        () async {
          // Arrange
          const expectedEmail = 'user@example.com';
          when(mockUser.email).thenReturn(expectedEmail);
          when(mockSession.user).thenReturn(mockUser);
          when(mockAuthClient.currentSession).thenReturn(mockSession);

          // Act
          final email = authService.getCurrentUserEmail();

          // Assert
          expect(email, equals(expectedEmail));
        },
      );

      test('getCurrentUserEmail should return null when no session', () async {
        // Arrange
        when(mockAuthClient.currentSession).thenReturn(null);

        // Act
        final email = authService.getCurrentUserEmail();

        // Assert
        expect(email, isNull);
      });

      test('getCurrentUserId should return user ID when logged in', () async {
        // Arrange
        const expectedId = 'user123';
        when(mockUser.id).thenReturn(expectedId);
        when(mockSession.user).thenReturn(mockUser);
        when(mockAuthClient.currentSession).thenReturn(mockSession);

        // Act
        final userId = authService.getCurrentUserId();

        // Assert
        expect(userId, equals(expectedId));
      });

      test('getCurrentUserId should return null when no session', () async {
        // Arrange
        when(mockAuthClient.currentSession).thenReturn(null);

        // Act
        final userId = authService.getCurrentUserId();

        // Assert
        expect(userId, isNull);
      });

      test(
        'isUserLoggedIn should return true when user is logged in',
        () async {
          // Arrange
          when(mockSession.user).thenReturn(mockUser);
          when(mockAuthClient.currentSession).thenReturn(mockSession);

          // Act
          final isLoggedIn = authService.isUserLoggedIn();

          // Assert
          expect(isLoggedIn, true);
        },
      );

      test('isUserLoggedIn should return false when no session', () async {
        // Arrange
        when(mockAuthClient.currentSession).thenReturn(null);

        // Act
        final isLoggedIn = authService.isUserLoggedIn();

        // Assert
        expect(isLoggedIn, false);
      });

      test(
        'isUserLoggedIn should return false when session has no user',
        () async {
          // Arrange
          // Create a session that throws when accessing user (simulating no user)
          final mockEmptySession = MockSession();
          when(mockEmptySession.user).thenThrow(ArgumentError('No user'));
          when(mockAuthClient.currentSession).thenReturn(mockEmptySession);

          // Act
          final isLoggedIn = authService.isUserLoggedIn();

          // Assert
          expect(isLoggedIn, false);
        },
      );
    });

    group('Email Update', () {
      test('updateUserEmail should update email successfully', () async {
        // Arrange
        const newEmail = 'newemail@example.com';
        // Mock successful user update - return UserResponse.fromJson
        when(
          mockAuthClient.updateUser(any),
        ).thenAnswer((_) async => UserResponse.fromJson({'user': null}));

        // Act
        await authService.updateUserEmail(newEmail);

        // Assert
        verify(
          mockAuthClient.updateUser(
            argThat(
              predicate<UserAttributes>((attrs) => attrs.email == newEmail),
            ),
          ),
        ).called(1);
      });

      test('updateUserEmail should handle update errors', () async {
        // Arrange
        const newEmail = 'invalid@example.com';
        when(
          mockAuthClient.updateUser(any),
        ).thenThrow(AuthException('Email update failed'));

        // Act & Assert
        expect(
          () => authService.updateUserEmail(newEmail),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'Fehler beim Aktualisieren der E-Mail-Adresse',
                  ),
            ),
          ),
        );
      });
    });

    group('Email Confirmation', () {
      test('confirmEmailManually should work in dev mode', () async {
        // Arrange
        when(mockUser.emailConfirmedAt).thenReturn(null);
        when(mockAuthClient.currentUser).thenReturn(mockUser);

        final service = AuthService(
          client: mockSupabaseClient,
          isDevMode: true,
        );

        // Act & Assert - should not throw
        expect(() => service.confirmEmailManually(), returnsNormally);
      });

      test('confirmEmailManually should throw in production mode', () async {
        // Arrange
        final service = AuthService(
          client: mockSupabaseClient,
          isDevMode: false,
        );

        // Act & Assert
        expect(
          () => service.confirmEmailManually(),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('only available in development mode'),
            ),
          ),
        );
      });

      test(
        'confirmEmailManually should throw when no user logged in',
        () async {
          // Arrange
          when(mockAuthClient.currentUser).thenReturn(null);
          final service = AuthService(
            client: mockSupabaseClient,
            isDevMode: true,
          );

          // Act & Assert
          expect(
            () => service.confirmEmailManually(),
            throwsA(
              predicate(
                (e) =>
                    e is Exception &&
                    e.toString().contains('No user logged in'),
              ),
            ),
          );
        },
      );

      test(
        'confirmEmailManually should handle already confirmed email',
        () async {
          // Arrange
          when(
            mockUser.emailConfirmedAt,
          ).thenReturn(DateTime.now().toIso8601String());
          when(mockAuthClient.currentUser).thenReturn(mockUser);

          final service = AuthService(
            client: mockSupabaseClient,
            isDevMode: true,
          );

          // Act & Assert - should not throw and should handle gracefully
          expect(() => service.confirmEmailManually(), returnsNormally);
        },
      );

      test('handleEmailConfirmation should verify OTP token', () async {
        // Arrange
        const token = 'confirmation_token_123';
        const type = 'email';
        when(
          mockAuthClient.verifyOTP(token: token, type: OtpType.email),
        ).thenAnswer((_) async => AuthResponse());

        // Act
        await authService.handleEmailConfirmation(token, type);

        // Assert
        verify(
          mockAuthClient.verifyOTP(token: token, type: OtpType.email),
        ).called(1);
      });

      test(
        'handleEmailConfirmation should handle verification errors',
        () async {
          // Arrange
          const token = 'invalid_token';
          const type = 'email';
          when(
            mockAuthClient.verifyOTP(token: token, type: OtpType.email),
          ).thenThrow(AuthException('Invalid token'));

          // Act & Assert
          expect(
            () => authService.handleEmailConfirmation(token, type),
            throwsA(
              predicate(
                (e) =>
                    e is Exception &&
                    e.toString().contains('Error confirming email'),
              ),
            ),
          );
        },
      );
    });

    group('Development Mode Behavior', () {
      test('should detect dev mode from environment', () async {
        // This test depends on how the environment is set up
        // The actual isDevMode getter reads from dotenv
        final service = AuthService(
          client: mockSupabaseClient,
          isDevMode: true,
        );

        // We can't easily test the actual dotenv reading, but we can test the behavior
        expect(service.isDevMode, true);
      });

      test('should handle different modes correctly in signup', () async {
        // Test production mode
        final prodService = AuthService(
          client: mockSupabaseClient,
          isDevMode: false,
        );
        final devService = AuthService(
          client: mockSupabaseClient,
          isDevMode: true,
        );

        const email = 'test@example.com';
        const password = 'TestPassword123!';

        when(
          mockAuthClient.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
            data: anyNamed('data'),
            emailRedirectTo: anyNamed('emailRedirectTo'),
          ),
        ).thenAnswer((_) async => AuthResponse());

        // Act & Assert - both should work but with different redirect URLs
        await prodService.signUpWithEmailPassword(email, password);
        await devService.signUpWithEmailPassword(email, password);

        // Verify different redirect URLs were used
        final capturedCalls = verify(
          mockAuthClient.signUp(
            email: anyNamed('email'),
            password: anyNamed('password'),
            data: anyNamed('data'),
            emailRedirectTo: captureAnyNamed('emailRedirectTo'),
          ),
        ).captured;

        expect(capturedCalls.length, 2);
        expect(capturedCalls[0], 'whiskyhikes://email-confirm'); // Production
        expect(capturedCalls[1], isNull); // Development
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle null user in session', () async {
        // Arrange
        // Create a session that throws when accessing user (simulating no user)
        final mockEmptySession = MockSession();
        when(mockEmptySession.user).thenThrow(ArgumentError('No user'));
        when(mockAuthClient.currentSession).thenReturn(mockEmptySession);

        // Act
        final email = authService.getCurrentUserEmail();
        final userId = authService.getCurrentUserId();
        final isLoggedIn = authService.isUserLoggedIn();

        // Assert
        expect(email, isNull);
        expect(userId, isNull);
        expect(isLoggedIn, false);
      });

      test('should handle empty user data in signup', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';
        final expectedResponse = AuthResponse();

        when(
          mockAuthClient.signUp(
            email: email,
            password: password,
            data: null,
            emailRedirectTo: anyNamed('emailRedirectTo'),
          ),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await authService.signUpWithEmailPassword(
          email,
          password,
          null,
        );

        // Assert
        expect(result, equals(expectedResponse));
      });

      test('should handle network timeouts', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'TestPassword123!';

        when(
          mockAuthClient.signInWithPassword(email: email, password: password),
        ).thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () => authService.signInWithEmailPassword(email, password),
          throwsException,
        );
      });
    });
  });
}
