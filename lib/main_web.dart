import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'UI/shared/responsive_layout.dart';
import 'UI/web/admin/dashboard/admin_dashboard.dart';
import 'UI/web/admin/admin_router.dart';
import 'data/providers/admin_provider.dart';
import 'data/services/auth/auth_service.dart';
import 'config/l10n/app_localizations.dart';

/// Einfache Web-Version der App für Tests
void main() {
  runApp(const WhiskyHikesWebApp());
}

class WhiskyHikesWebApp extends StatelessWidget {
  const WhiskyHikesWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp.router(
        title: 'Whisky Hikes - Web Admin',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          useMaterial3: true,
        ),
        routerConfig: GoRouter(
          initialLocation: AdminRouter.dashboardRoute,
          routes: [
            GoRoute(
              path: '/',
              redirect: (context, state) => AdminRouter.dashboardRoute,
            ),
            ...AdminRouter.getAdminRoutes(),
          ],
        ),
      ),
    );
  }
}

/// Einfache Web-Startseite
class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisky Hikes Web'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hiking, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Whisky Hikes Web-App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Mobile Layout'),
            SizedBox(height: 32),
            Text('Web-App läuft erfolgreich! 🎉'),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[100],
            child: Column(
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.hiking, size: 32, color: Colors.amber[800]),
                      const SizedBox(width: 12),
                      const Text(
                        'Whisky Hikes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dashboard),
                        title: const Text('Dashboard'),
                        onTap: () {
                          print('Navigate to Dashboard');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.map),
                        title: const Text('Wanderrouten'),
                        onTap: () {
                          print('Navigate to Routes');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: const Text('Bestellungen'),
                        onTap: () {
                          print('Navigate to Orders');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Willkommen bei Whisky Hikes',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Desktop Layout - Web-App läuft erfolgreich! 🎉',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Features:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('✅ Flutter Web aktiviert'),
                  Text('✅ Responsive Layout implementiert'),
                  Text('✅ Admin-Dashboard erstellt'),
                  Text('✅ Navigation implementiert'),
                  Text('✅ Web-spezifische Dependencies hinzugefügt'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
