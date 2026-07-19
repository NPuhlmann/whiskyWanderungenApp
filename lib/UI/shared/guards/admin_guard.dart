import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/user_repository.dart';

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

  Object? _error;

  Future<void> _check() async {
    try {
      await _runCheck();
    } catch (e) {
      // Without this, a throwing check leaves _isAdmin null forever and the
      // UI renders a spinner that never resolves.
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _runCheck() async {
    final userRepository = context.read<UserRepository>();
    _isLoggedIn = userRepository.isUserLoggedIn();
    if (!_isLoggedIn) {
      if (!mounted) return;
      setState(() => _isAdmin = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return;
    }
    final isAdmin = await userRepository.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() => _isAdmin = isAdmin);
    if (!isAdmin) {
      // No redirect here: '/' points back at an admin route, so navigating
      // away just bounced straight back in and span forever.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Du musst Admin sein um dich hier anmelden zu können',
            ),
          ),
        );
      });
    }
  }

  Future<void> _signOut() async {
    await context.read<UserRepository>().signUserOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Admin-Check fehlgeschlagen: $_error')),
      );
    }
    if (_isAdmin == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isAdmin == false) {
      // Logged out: the redirect to /login is already scheduled.
      if (!_isLoggedIn) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      // Logged in but not an admin. The snackbar disappears, so leave a way
      // back on screen.
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Du musst Admin sein um dich hier anmelden zu können'),
              const SizedBox(height: 16),
              FilledButton(onPressed: _signOut, child: const Text('Abmelden')),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}

/// Admin-Guard für GoRouter-Redirects.
class AdminRouteGuard {
  /// Prüft, ob der Benutzer Zugriff auf die Route hat (eingeloggt + Admin).
  Future<bool> canAccess(BuildContext context, GoRouterState state) async {
    final repo = Provider.of<UserRepository>(context, listen: false);
    if (!repo.isUserLoggedIn()) return false;
    return await repo.isCurrentUserAdmin();
  }

  /// Redirect-Funktion für GoRouter. Wird async aufgerufen, damit der
  /// Rollen-Check gegen Supabase laufen kann.
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final repo = Provider.of<UserRepository>(context, listen: false);

    if (!repo.isUserLoggedIn()) {
      return '/login';
    }
    final isAdmin = await repo.isCurrentUserAdmin();
    if (!isAdmin) {
      return '/';
    }
    return null;
  }
}
