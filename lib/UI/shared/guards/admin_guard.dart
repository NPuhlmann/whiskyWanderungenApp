import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth/auth_service.dart';

/// Admin-Guard für geschützte Admin-Routen.
///
/// Prüft zwei Bedingungen:
///   1. User ist eingeloggt   -> sonst Redirect nach `/login`
///   2. profiles.role == 'admin' -> sonst Redirect nach `/`
class AdminGuard extends StatefulWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  bool? _isAdmin;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final authService = context.read<AuthService>();
    _isLoggedIn = authService.isUserLoggedIn();
    if (!_isLoggedIn) {
      if (!mounted) return;
      setState(() => _isAdmin = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return;
    }
    final isAdmin = await authService.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() => _isAdmin = isAdmin);
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdmin == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_isAdmin == false) {
      // Redirect wurde in _check() bereits geplant — bis er greift, Spinner.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}

/// Admin-Guard für GoRouter-Redirects.
class AdminRouteGuard {
  /// Prüft, ob der Benutzer Zugriff auf die Route hat (eingeloggt + Admin).
  Future<bool> canAccess(BuildContext context, GoRouterState state) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isUserLoggedIn()) return false;
    return await authService.isCurrentUserAdmin();
  }

  /// Redirect-Funktion für GoRouter. Wird async aufgerufen, damit der
  /// Rollen-Check gegen Supabase laufen kann.
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isUserLoggedIn()) {
      return '/login';
    }
    final isAdmin = await authService.isCurrentUserAdmin();
    if (!isAdmin) {
      return '/';
    }
    return null;
  }
}
