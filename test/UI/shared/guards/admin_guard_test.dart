import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/shared/guards/admin_guard.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
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

// Der "nicht eingeloggt"-Pfad triggert context.go(...), was ohne installierten
// GoRouter in Widget-Tests fehlschlägt, und ist hier ausgespart.
Widget _guard({required bool loggedIn, required bool admin, Widget? child}) =>
    ChangeNotifierProvider<UserRepository>(
      create: (_) =>
          UserRepository(_FakeAuthService(loggedIn: loggedIn, admin: admin)),
      child: MaterialApp(
        home: AdminGuard(child: child ?? const Text('Dashboard')),
      ),
    );

void main() {
  group('AdminGuard', () {
    testWidgets('zeigt Spinner während Rolle geladen wird', (tester) async {
      await tester.pumpWidget(
        _guard(loggedIn: true, admin: true, child: const Text('geheim')),
      );

      // Erstes Frame: Future noch nicht aufgelöst -> Spinner sichtbar.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('geheim'), findsNothing);
    });

    testWidgets('zeigt Kind-Widget, wenn User Admin ist', (tester) async {
      await tester.pumpWidget(_guard(loggedIn: true, admin: true));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('zeigt Hinweis statt Dashboard, wenn User kein Admin ist', (
      tester,
    ) async {
      await tester.pumpWidget(_guard(loggedIn: true, admin: false));
      await tester.pump();
      await tester.pump();

      expect(find.text('Dashboard'), findsNothing);
      expect(
        find.text('Du musst Admin sein um dich hier anmelden zu können'),
        findsWidgets,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
