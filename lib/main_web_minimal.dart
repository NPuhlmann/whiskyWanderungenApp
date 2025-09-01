import 'package:flutter/material.dart';
import 'UI/shared/responsive_layout.dart';

/// Minimale Web-Version der App ohne problematische Dependencies
void main() {
  runApp(const WhiskyHikesWebAppMinimal());
}

class WhiskyHikesWebAppMinimal extends StatelessWidget {
  const WhiskyHikesWebAppMinimal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whisky Hikes - Web Admin (Minimal)',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const WebHomePageMinimal(),
    );
  }
}

/// Minimale Web-Startseite
class WebHomePageMinimal extends StatelessWidget {
  const WebHomePageMinimal({super.key});

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
            SizedBox(height: 16),
            Text('Phase 1: Admin-Dashboard implementiert'),
            Text('✅ KPI-Cards mit echten Daten'),
            Text('✅ Charts für Umsatz-Entwicklung'),
            Text('✅ Bestellungen-Tabelle'),
            Text('✅ Admin-Routing-System'),
            Text('✅ Breadcrumbs & Navigation'),
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
                      ListTile(
                        leading: const Icon(Icons.local_bar),
                        title: const Text('Whisky-Katalog'),
                        onTap: () {
                          print('Navigate to Whisky');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.analytics),
                        title: const Text('Analytics'),
                        onTap: () {
                          print('Navigate to Analytics');
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
                    'Phase 1: Admin-Features implementiert:',
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
                  SizedBox(height: 16),
                  Text('✅ AdminService für echte Daten'),
                  Text('✅ AdminProvider für State Management'),
                  Text('✅ KPI-Cards mit echten Daten'),
                  Text('✅ Charts für Umsatz-Entwicklung'),
                  Text('✅ Bestellungen-Tabelle mit echten Daten'),
                  Text('✅ Admin-Routing-System'),
                  Text('✅ Breadcrumbs & Navigation'),
                  Text('✅ Loading-States & Error-Handling'),
                  SizedBox(height: 32),
                  Text(
                    'Nächste Schritte:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('🚧 Phase 2: Wanderrouten-Verwaltung'),
                  Text('🚧 Phase 3: Bestellverwaltung'),
                  Text('🚧 Phase 4: Whisky-Katalog & Provision'),
                  Text('🚧 Phase 5: Analytics & Team-Management'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
