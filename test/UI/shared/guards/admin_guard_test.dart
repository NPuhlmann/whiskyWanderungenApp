import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/shared/guards/admin_guard.dart';
import 'package:whisky_hikes/data/services/auth/auth_service.dart';

/// Fake-AuthService, der weder Supabase noch RouterState benötigt.
/// `implements` statt `extends`, damit der `AuthService`-Konstruktor mit
/// seinem `Supabase.instance.client`-Default nicht angefasst wird.
class _FakeAuthService implements AuthService {
  _FakeAuthService({required this.loggedIn, required this.admin});

  final bool loggedIn;
  final bool admin;

  @override
  bool isUserLoggedIn() => loggedIn;

  @override
  Future<bool> isCurrentUserAdmin() async => admin;

  @override
  String? getCurrentUserId() => loggedIn ? 'user-1' : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Negativ-Pfade (nicht-Admin / nicht eingeloggt) triggern context.go(...),
// was ohne installierten GoRouter in Widget-Tests fehlschlägt. Sie sind
// in den Provider-/Service-Tests indirekt abgedeckt; hier konzentrieren
// wir uns auf die UI-Sichtbarkeitsregeln des Guards.
void main() {
  group('AdminGuard', () {
    testWidgets('zeigt Spinner während Rolle geladen wird', (tester) async {
      final auth = _FakeAuthService(loggedIn: true, admin: true);
      await tester.pumpWidget(
        Provider<AuthService>.value(
          value: auth,
          child: const MaterialApp(home: AdminGuard(child: Text('geheim'))),
        ),
      );

      // Erstes Frame: Future noch nicht aufgelöst -> Spinner sichtbar.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('geheim'), findsNothing);
    });

    testWidgets('zeigt Kind-Widget, wenn User Admin ist', (tester) async {
      final auth = _FakeAuthService(loggedIn: true, admin: true);
      await tester.pumpWidget(
        Provider<AuthService>.value(
          value: auth,
          child: const MaterialApp(home: AdminGuard(child: Text('Dashboard'))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
