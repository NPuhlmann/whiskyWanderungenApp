import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/shared/guards/admin_guard.dart';
import 'package:whisky_hikes/data/services/auth/auth_service.dart';

// Mock AuthService für Tests
class MockAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated = false;

  @override
  bool isUserLoggedIn() => _isAuthenticated;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  // Implementiere andere Methoden als leere Stubs
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AdminGuard Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('AdminGuard zeigt Kind-Widget bei authentifiziertem Benutzer', (
      WidgetTester tester,
    ) async {
      mockAuthService.setAuthenticated(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: MaterialApp(
            home: AdminGuard(child: const Text('Geschützter Inhalt')),
          ),
        ),
      );

      expect(find.text('Geschützter Inhalt'), findsOneWidget);
    });

    testWidgets(
      'AdminGuard zeigt Loading bei nicht authentifiziertem Benutzer',
      (WidgetTester tester) async {
        mockAuthService.setAuthenticated(false);

        await tester.pumpWidget(
          ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: MaterialApp(
              home: AdminGuard(child: const Text('Geschützter Inhalt')),
            ),
          ),
        );

        // Sollte Loading-Indikator zeigen
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Geschützter Inhalt'), findsNothing);
      },
    );

    testWidgets('AdminGuard leitet bei Authentifizierung weiter', (
      WidgetTester tester,
    ) async {
      mockAuthService.setAuthenticated(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: MaterialApp(
            home: AdminGuard(child: const Text('Geschützter Inhalt')),
          ),
        ),
      );

      // Warte auf PostFrameCallback
      await tester.pumpAndSettle();

      // Sollte Loading-Indikator zeigen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AdminRouteGuard Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    test('canAccess gibt true bei authentifiziertem Benutzer zurück', () async {
      mockAuthService.setAuthenticated(true);

      final guard = AdminRouteGuard();
      final canAccess = await guard.canAccess(
        TestWidgetsFlutterBinding.instance.rootElement!.context!,
        const GoRouterState(),
      );

      expect(canAccess, isTrue);
    });

    test(
      'canAccess gibt false bei nicht authentifiziertem Benutzer zurück',
      () async {
        mockAuthService.setAuthenticated(false);

        final guard = AdminRouteGuard();
        final canAccess = await guard.canAccess(
          TestWidgetsFlutterBinding.instance.rootElement!.context!,
          const GoRouterState(),
        );

        expect(canAccess, isFalse);
      },
    );

    test(
      'redirect gibt /login bei nicht authentifiziertem Benutzer zurück',
      () {
        mockAuthService.setAuthenticated(false);

        final guard = AdminRouteGuard();
        final redirect = guard.redirect(
          TestWidgetsFlutterBinding.instance.rootElement!.context!,
          const GoRouterState(),
        );

        expect(redirect, equals('/login'));
      },
    );

    test('redirect gibt null bei authentifiziertem Benutzer zurück', () {
      mockAuthService.setAuthenticated(true);

      final guard = AdminRouteGuard();
      final redirect = guard.redirect(
        TestWidgetsFlutterBinding.instance.rootElement!.context!,
        const GoRouterState(),
      );

      expect(redirect, isNull);
    });
  });

  group('AdminGuard Integration Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('AdminGuard reagiert auf Authentifizierungsänderungen', (
      WidgetTester tester,
    ) async {
      mockAuthService.setAuthenticated(false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: MaterialApp(
            home: AdminGuard(child: const Text('Geschützter Inhalt')),
          ),
        ),
      );

      // Nicht authentifiziert - sollte Loading zeigen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Geschützter Inhalt'), findsNothing);

      // Authentifizierung aktivieren
      mockAuthService.setAuthenticated(true);
      await tester.pumpAndSettle();

      // Jetzt sollte der Inhalt sichtbar sein
      expect(find.text('Geschützter Inhalt'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('AdminGuard funktioniert mit verschiedenen Kind-Widgets', (
      WidgetTester tester,
    ) async {
      mockAuthService.setAuthenticated(true);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: MaterialApp(
            home: AdminGuard(
              child: Column(
                children: [
                  const Text('Titel'),
                  const Text('Beschreibung'),
                  ElevatedButton(onPressed: () {}, child: const Text('Aktion')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Titel'), findsOneWidget);
      expect(find.text('Beschreibung'), findsOneWidget);
      expect(find.text('Aktion'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}

// Hilfsklasse für GoRouterState
class GoRouterState {
  const GoRouterState();
}
