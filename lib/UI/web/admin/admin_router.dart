import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dashboard/admin_dashboard.dart';
import '../../shared/guards/admin_guard.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'order_management/order_management_page.dart';
import 'whisky_catalog/whisky_catalog_page.dart';
import 'commission_management/commission_management_page.dart';

/// Admin-Router für die Navigation zwischen Admin-Seiten
class AdminRouter {
  static const String dashboardRoute = '/admin/dashboard';
  static const String routesRoute = '/admin/routes';
  static const String ordersRoute = '/admin/orders';
  static const String whiskyRoute = '/admin/whisky';
  static const String analyticsRoute = '/admin/analytics';
  static const String teamRoute = '/admin/team';
  static const String financesRoute = '/admin/finances';
  static const String settingsRoute = '/admin/settings';

  /// Erstellt die Admin-Routes für GoRouter
  static List<RouteBase> getAdminRoutes() {
    return [
      GoRoute(
        path: dashboardRoute,
        name: 'AdminDashboard',
        builder: (context, state) => const AdminGuard(
          child: AdminDashboard(),
        ),
      ),
      GoRoute(
        path: routesRoute,
        name: 'AdminRoutes',
        builder: (context, state) => const AdminGuard(
          child: _AdminRoutesPage(),
        ),
      ),
      GoRoute(
        path: ordersRoute,
        name: 'AdminOrders',
        builder: (context, state) => const AdminGuard(
          child: OrderManagementPage(),
        ),
      ),
      GoRoute(
        path: whiskyRoute,
        name: 'AdminWhisky',
        builder: (context, state) => const AdminGuard(
          child: WhiskyCatalogPage(),
        ),
      ),
      GoRoute(
        path: analyticsRoute,
        name: 'AdminAnalytics',
        builder: (context, state) => const AdminGuard(
          child: _AdminAnalyticsPage(),
        ),
      ),
      GoRoute(
        path: teamRoute,
        name: 'AdminTeam',
        builder: (context, state) => const AdminGuard(
          child: _AdminTeamPage(),
        ),
      ),
      GoRoute(
        path: financesRoute,
        name: 'AdminFinances',
        builder: (context, state) => const AdminGuard(
          child: CommissionManagementPage(),
        ),
      ),
      GoRoute(
        path: settingsRoute,
        name: 'AdminSettings',
        builder: (context, state) => const AdminGuard(
          child: _AdminSettingsPage(),
        ),
      ),
    ];
  }

  /// Navigiert zu einer Admin-Route
  static void navigateTo(BuildContext context, String route) {
    context.go(route);
  }

  /// Prüft, ob der aktuelle Pfad eine Admin-Route ist
  static bool isAdminRoute(String path) {
    return path.startsWith('/admin');
  }

  /// Gibt den aktuellen Admin-Bereich zurück
  static String getCurrentAdminSection(String path) {
    if (path == dashboardRoute) return 'Dashboard';
    if (path == routesRoute) return 'Wanderrouten';
    if (path == ordersRoute) return 'Bestellungen';
    if (path == whiskyRoute) return 'Whisky-Katalog';
    if (path == analyticsRoute) return 'Analytics';
    if (path == teamRoute) return 'Team';
    if (path == financesRoute) return 'Provisionen';
    if (path == settingsRoute) return 'Einstellungen';
    return 'Dashboard';
  }
}

// Platzhalter-Seiten für die verschiedenen Admin-Bereiche
class _AdminRoutesPage extends StatelessWidget {
  const _AdminRoutesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageHikingRoutes),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Wanderrouten-Verwaltung',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.manageHikingRoutesDescription),
            SizedBox(height: 32),
            Text('🚧 In Entwicklung 🚧'),
          ],
        ),
      ),
    );
  }
}



class _AdminAnalyticsPage extends StatelessWidget {
  const _AdminAnalyticsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Berichte'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Analytics & Berichte',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Hier finden Sie detaillierte Analysen und Berichte'),
            SizedBox(height: 32),
            Text('🚧 In Entwicklung 🚧'),
          ],
        ),
      ),
    );
  }
}

class _AdminTeamPage extends StatelessWidget {
  const _AdminTeamPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team verwalten'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Team-Verwaltung',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Hier können Sie Ihr Team und Berechtigungen verwalten'),
            SizedBox(height: 32),
            Text('🚧 In Entwicklung 🚧'),
          ],
        ),
      ),
    );
  }
}


class _AdminSettingsPage extends StatelessWidget {
  const _AdminSettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Einstellungen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Hier können Sie die App-Einstellungen anpassen'),
            SizedBox(height: 32),
            Text('🚧 In Entwicklung 🚧'),
          ],
        ),
      ),
    );
  }
}
