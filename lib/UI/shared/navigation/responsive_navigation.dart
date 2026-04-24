import 'package:flutter/material.dart';
import '../responsive_layout.dart';

/// Responsive Navigation für verschiedene Bildschirmgrößen
class ResponsiveNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ResponsiveNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileNavigation(),
      desktop: _buildDesktopNavigation(),
    );
  }

  /// Mobile Navigation (Bottom Navigation Bar)
  Widget _buildMobileNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Wanderrouten'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Bestellungen',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  /// Desktop Navigation (Left Sidebar)
  Widget _buildDesktopNavigation() {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: Column(
        children: [
          // Logo/Branding
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.hiking, size: 32, color: Colors.amber[800]),
                const SizedBox(width: 12),
                const Text(
                  'Whisky Hikes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(),

          // Admin Navigation
          _buildAdminNavigationSection(),

          const Divider(),

          // User Navigation
          _buildUserNavigationSection(),
        ],
      ),
    );
  }

  /// Admin Navigation Section
  Widget _buildAdminNavigationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'ADMIN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        _buildNavigationItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          route: '/admin/dashboard',
          isSelected: currentIndex == 0,
        ),
        _buildNavigationItem(
          icon: Icons.map,
          label: 'Wanderrouten',
          route: '/admin/routes',
          isSelected: currentIndex == 1,
        ),
        _buildNavigationItem(
          icon: Icons.shopping_cart,
          label: 'Bestellungen',
          route: '/admin/orders',
          isSelected: currentIndex == 2,
        ),
        _buildNavigationItem(
          icon: Icons.local_bar,
          label: 'Whisky-Katalog',
          route: '/admin/whisky',
          isSelected: currentIndex == 3,
        ),
        _buildNavigationItem(
          icon: Icons.analytics,
          label: 'Analytics',
          route: '/admin/analytics',
          isSelected: currentIndex == 4,
        ),
        _buildNavigationItem(
          icon: Icons.people,
          label: 'Team',
          route: '/admin/team',
          isSelected: currentIndex == 5,
        ),
        _buildNavigationItem(
          icon: Icons.account_balance_wallet,
          label: 'Finanzen',
          route: '/admin/finances',
          isSelected: currentIndex == 6,
        ),
        _buildNavigationItem(
          icon: Icons.settings,
          label: 'Einstellungen',
          route: '/admin/settings',
          isSelected: currentIndex == 7,
        ),
      ],
    );
  }

  /// User Navigation Section
  Widget _buildUserNavigationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'BENUTZER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        _buildNavigationItem(
          icon: Icons.home,
          label: 'Home',
          route: '/',
          isSelected: currentIndex == 8,
        ),
        _buildNavigationItem(
          icon: Icons.person,
          label: 'Profil',
          route: '/profile',
          isSelected: currentIndex == 9,
        ),
        _buildNavigationItem(
          icon: Icons.history,
          label: 'Bestellverlauf',
          route: '/order-history',
          isSelected: currentIndex == 10,
        ),
      ],
    );
  }

  /// Einzelnes Navigation Item
  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.amber[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.amber[800] : Colors.grey[600],
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.amber[900] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          // Hier würde die Navigation erfolgen
          // Für jetzt nur ein print
          debugPrint('Navigate to: $route');
        },
      ),
    );
  }
}
