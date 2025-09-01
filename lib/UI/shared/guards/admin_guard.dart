import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth/auth_service.dart';

/// Admin-Guard für geschützte Admin-Routen
class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Prüfe, ob der Benutzer eingeloggt ist
        if (!authService.isUserLoggedIn()) {
          // Weiterleitung zur Login-Seite
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Benutzer hat Zugriff - zeige den Inhalt
        return child;
      },
    );
  }
}

/// Admin-Guard für GoRouter
class AdminRouteGuard {
  /// Prüft, ob der Benutzer Zugriff auf die Route hat
  Future<bool> canAccess(BuildContext context, GoRouterState state) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Prüfe Authentifizierung
    return authService.isUserLoggedIn();
  }

  /// Redirect-Funktion für GoRouter
  String? redirect(BuildContext context, GoRouterState state) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Prüfe Authentifizierung
    if (!authService.isUserLoggedIn()) {
      return '/login';
    }

    // Kein Redirect nötig
    return null;
  }
}
