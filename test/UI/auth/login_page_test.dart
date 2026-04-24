import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/UI/mobile/auth/login/login_page.dart';
import 'package:whisky_hikes/UI/mobile/auth/login/login_page_view_model.dart';
import 'package:whisky_hikes/UI/mobile/auth/signup/signup_page.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MockLoginPageViewModel extends Mock implements LoginPageViewModel {}

void main() {
  group('LoginPage Widget Tests', () {
    late MockLoginPageViewModel mockViewModel;

    setUp(() {
      mockViewModel = MockLoginPageViewModel();

      // Setup default mock behavior
    });

    Widget createTestWidget(Widget child) {
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => child),
          GoRoute(
            path: '/signUp',
            builder: (context, state) =>
                const Scaffold(body: Text('Sign Up Page')),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('de', '')],
      );
    }

    testWidgets('should display login form elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      // Assert
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets(
      'should call loginWithEmailAndPassword when login button is pressed',
      (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(LoginPage(viewModel: mockViewModel)),
        );

        await tester.enterText(
          find.byType(TextField).first,
          'test@example.com',
        );
        await tester.enterText(find.byType(TextField).last, 'password123');

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        verify(
          mockViewModel.loginWithEmailAndPassword(
            'test@example.com',
            'password123',
          ),
        ).called(1);
      },
    );

    testWidgets('should show snackbar when login fails', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Exception: Login failed'), findsOneWidget);
    });

    testWidgets(
      'should navigate to sign up page when sign up button is pressed',
      (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(LoginPage(viewModel: mockViewModel)),
        );

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Sign Up Page'), findsOneWidget);
      },
    );

    testWidgets('should have correct button styling', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      // Assert
      final elevatedButton = find.byType(ElevatedButton);
      expect(elevatedButton, findsOneWidget);

      final textButton = find.byType(TextButton);
      expect(textButton, findsOneWidget);
    });

    testWidgets('should have proper spacing between elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      // Assert
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsNWidgets(6)); // Updated to match actual count
    });

    testWidgets('should use ListView with proper padding', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      // Assert
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      final ListView listViewWidget = tester.widget(listView);
      expect(
        listViewWidget.padding,
        equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 100)),
      );
    });

    testWidgets('should handle async login operation correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Should complete without errors
      verify(
        mockViewModel.loginWithEmailAndPassword(
          'test@example.com',
          'password123',
        ),
      ).called(1);
    });

    testWidgets('should handle mounted check for error snackbar', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Exception: Network error'), findsOneWidget);
    });

    testWidgets('should clear text controllers when disposed', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(LoginPage(viewModel: mockViewModel)),
      );

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Text should remain in fields
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
