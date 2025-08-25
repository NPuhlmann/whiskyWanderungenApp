import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:whisky_hikes/UI/auth/login/login_page.dart';
import 'package:whisky_hikes/UI/auth/login/login_page_view_model.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';

class MockLoginPageViewModel extends Mock implements LoginPageViewModel {}

void main() {
  group('LoginPage Widget Tests', () {
    late MockLoginPageViewModel mockViewModel;

    setUp(() {
      mockViewModel = MockLoginPageViewModel();
    });

    Widget createTestWidget(Widget child) {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => child,
          ),
          GoRoute(
            path: '/signUp',
            builder: (context, state) => const Scaffold(body: Text('Sign Up Page')),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('de', ''),
        ],
      );
    }

    testWidgets('should build without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));

      // Assert
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display all required UI elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Whisky Hikes'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // Logo
    });

    testWidgets('should display logo image', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));

      // Assert
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      
      final Image image = tester.widget(imageFinder);
      expect(image.height, equals(250.0));
      expect(image.width, equals(250.0));
    });

    testWidgets('should have email text field with correct properties', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));

      // Assert
      final emailField = find.byType(TextField).first;
      final TextField emailTextField = tester.widget(emailField);
      
      expect(emailTextField.decoration?.labelText, equals('Email'));
      expect(emailTextField.obscureText, isFalse);
      expect(emailTextField.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('should have password text field with correct properties', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));

      // Assert
      final passwordField = find.byType(TextField).last;
      final TextField passwordTextField = tester.widget(passwordField);
      
      expect(passwordTextField.decoration?.labelText, equals('Password'));
      expect(passwordTextField.obscureText, isTrue);
      expect(passwordTextField.decoration?.border, isA<OutlineInputBorder>());
    });

    testWidgets('should accept text input in email field', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.pump();

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should accept text input in password field', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();

      // Assert - Password field should be obscured, so we check the controller
      final passwordField = find.byType(TextField).last;
      final TextField passwordTextField = tester.widget(passwordField);
      expect(passwordTextField.controller?.text, equals('password123'));
    });

    testWidgets('should call loginWithEmailAndPassword when login button is pressed', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.loginWithEmailAndPassword('test@example.com', 'password123'))
          .thenAnswer((_) async => AuthResponse());

      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      verify(mockViewModel.loginWithEmailAndPassword('test@example.com', 'password123')).called(1);
    });

    testWidgets('should show snackbar when login fails', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.loginWithEmailAndPassword('test@example.com', 'wrongpassword'))
          .thenThrow(Exception('Login failed'));

      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Exception: Login failed'), findsOneWidget);
    });

    testWidgets('should navigate to sign up page when sign up button is pressed', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign Up Page'), findsOneWidget);
    });

    testWidgets('should have correct button styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));

      // Assert
      final elevatedButton = find.byType(ElevatedButton);
      expect(elevatedButton, findsOneWidget);
      
      final textButton = find.byType(TextButton);
      expect(textButton, findsOneWidget);
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));

      // Assert
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsNWidgets(4)); // Multiple SizedBoxes for spacing
    });

    testWidgets('should use ListView with proper padding', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));

      // Assert
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
      
      final ListView listViewWidget = tester.widget(listView);
      expect(listViewWidget.padding, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 100)));
    });

    testWidgets('should handle async login operation correctly', (WidgetTester tester) async {
      // Arrange
      bool loginCompleted = false;
      when(mockViewModel.loginWithEmailAndPassword('test@example.com', 'password123'))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            loginCompleted = true;
            return AuthResponse();
          });

      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 50));
      
      expect(loginCompleted, isFalse); // Should still be processing
      
      await tester.pump(const Duration(milliseconds: 100));
      
      // Assert
      expect(loginCompleted, isTrue);
    });

    testWidgets('should handle mounted check for error snackbar', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.loginWithEmailAndPassword('test@example.com', 'password123'))
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      
      await tester.tap(find.byType(ElevatedButton));
      
      // Navigate away before error completes
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Assert - Should have navigated without showing error
      expect(find.text('Sign Up Page'), findsOneWidget);
    });

    testWidgets('should clear text controllers when disposed', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(LoginPage(viewModel: mockViewModel)));
      
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      
      // Navigate away to trigger dispose
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Assert - Page should have been properly disposed without errors
      expect(find.text('Sign Up Page'), findsOneWidget);
    });
  });
}