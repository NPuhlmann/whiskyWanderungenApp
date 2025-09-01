import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../UI/shared/responsive_layout.dart';
import '../../../../UI/shared/guards/admin_guard.dart';
import '../../../../UI/shared/components/breadcrumbs.dart';
import '../../../../data/providers/admin_provider.dart';
import '../admin_router.dart';

/// Admin-Dashboard für die Web-App
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Lade Dashboard-Daten beim Start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  /// Mobile Layout
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: _buildDashboardContent(),
      bottomNavigationBar: _buildMobileNavigation(),
    );
  }

  /// Desktop Layout
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildDesktopSidebar(),
          Expanded(
            child: _buildDashboardContent(),
          ),
        ],
      ),
    );
  }

  /// Desktop Sidebar
  Widget _buildDesktopSidebar() {
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Navigation
          Expanded(
            child: _buildSidebarNavigation(),
          ),
        ],
      ),
    );
  }

  /// Sidebar Navigation
  Widget _buildSidebarNavigation() {
    final navigationItems = [
      {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/admin/dashboard'},
      {'icon': Icons.map, 'label': 'Wanderrouten', 'route': '/admin/routes'},
      {'icon': Icons.shopping_cart, 'label': 'Bestellungen', 'route': '/admin/orders'},
      {'icon': Icons.local_bar, 'label': 'Whisky-Katalog', 'route': '/admin/whisky'},
      {'icon': Icons.analytics, 'label': 'Analytics', 'route': '/admin/analytics'},
      {'icon': Icons.people, 'label': 'Team', 'route': '/admin/team'},
      {'icon': Icons.account_balance_wallet, 'label': 'Finanzen', 'route': '/admin/finances'},
      {'icon': Icons.settings, 'label': 'Einstellungen', 'route': '/admin/settings'},
    ];

    return ListView.builder(
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        final isSelected = _selectedIndex == index;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: isSelected ? Colors.amber[800] : Colors.grey[600],
            ),
            title: Text(
              item['label'] as String,
              style: TextStyle(
                color: isSelected ? Colors.amber[900] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              // Navigation zur entsprechenden Route
              AdminRouter.navigateTo(context, item['route'] as String);
            },
          ),
        );
      },
    );
  }

  /// Mobile Navigation
  Widget _buildMobileNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Routen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Bestellungen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  /// Dashboard Content
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildDashboardHeader(),
          
          const SizedBox(height: 24),
          
          // KPI Cards
          _buildKPICards(),
          
          const SizedBox(height: 24),
          
          // Charts
          _buildCharts(),
          
          const SizedBox(height: 24),
          
          // Recent Orders
          _buildRecentOrders(),
        ],
      ),
    );
  }

  /// Dashboard Header
  Widget _buildDashboardHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumbs
        const AdminBreadcrumbs(currentSection: 'Dashboard'),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Willkommen zurück!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hier ist eine Übersicht Ihrer Whisky Hikes Aktivitäten',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
                    Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Dashboard aktualisieren
                context.read<AdminProvider>().loadDashboardData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Aktualisieren'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Neue Route erstellen
                AdminRouter.navigateTo(context, AdminRouter.routesRoute);
              },
              icon: const Icon(Icons.add),
              label: const Text('Neue Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
          ],
        ),
      ],
    );
  }

  /// KPI Cards
  Widget _buildKPICards() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingKPIs) {
          return const Center(child: CircularProgressIndicator());
        }

        final kpis = adminProvider.dashboardKPIs;
        
        return GridView.count(
          crossAxisCount: ResponsiveLayoutUtils.isMobile(context) ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: ResponsiveLayoutUtils.isMobile(context) ? 1.5 : 1.8,
          children: [
            _buildKPICard(
              title: 'Verkaufte Routen',
              value: '${kpis['monthlyRoutes'] ?? 0}',
              subtitle: 'Dieser Monat',
              icon: Icons.map,
              color: Colors.blue,
            ),
            _buildKPICard(
              title: 'Umsatz',
              value: '€${(kpis['monthlyRevenue'] ?? 0.0).toStringAsFixed(0)}',
              subtitle: 'Dieser Monat',
              icon: Icons.euro,
              color: Colors.green,
            ),
            _buildKPICard(
              title: 'Aktive Bestellungen',
              value: '${kpis['activeOrders'] ?? 0}',
              subtitle: 'In Bearbeitung',
              icon: Icons.shopping_cart,
              color: Colors.orange,
            ),
            _buildKPICard(
              title: 'Kundenbewertung',
              value: '${(kpis['averageRating'] ?? 0.0).toStringAsFixed(1)}',
              subtitle: 'Durchschnitt',
              icon: Icons.star,
              color: Colors.amber,
            ),
          ],
        );
      },
    );
  }

  /// Einzelne KPI Card
  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Charts
  Widget _buildCharts() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSalesChart(),
        ),
        const SizedBox(width: 16),
        if (!ResponsiveLayoutUtils.isMobile(context))
          Expanded(
            child: _buildTopRoutesChart(),
          ),
      ],
    );
  }

  /// Sales Chart
  Widget _buildSalesChart() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingTrend) {
          return const Center(child: CircularProgressIndicator());
        }

        final trend = adminProvider.revenueTrend;
        final spots = trend.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value['revenue'] as double);
        }).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Umsatz-Entwicklung (30 Tage)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: trend.isEmpty 
                  ? const Center(child: Text('Keine Daten verfügbar'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.amber[800],
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.amber[800]!.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Top Routes Chart
  Widget _buildTopRoutesChart() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingRoutes) {
          return const Center(child: CircularProgressIndicator());
        }

        final routes = adminProvider.topRoutes;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beliebteste Routen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: routes.isEmpty 
                  ? const Center(child: Text('Keine Daten verfügbar'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: routes.isNotEmpty 
                          ? routes.map((r) => r['sales'] as int).reduce((a, b) => a > b ? a : b).toDouble() + 2
                          : 20,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: routes.asMap().entries.map((entry) {
                          final route = entry.value;
                          final colors = [Colors.amber[800], Colors.blue[400], Colors.green[400], Colors.orange[400], Colors.purple[400]];
                          return BarChartGroupData(
                            x: entry.key, 
                            barRods: [BarChartRodData(
                              toY: (route['sales'] as int).toDouble(), 
                              color: colors[entry.key % colors.length]
                            )]
                          );
                        }).toList(),
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Recent Orders
  Widget _buildRecentOrders() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingOrders) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = adminProvider.recentOrders;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aktuelle Bestellungen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      print('View all orders');
                    },
                    child: const Text('Alle anzeigen'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Keine Bestellungen verfügbar'),
                  ),
                )
              else
                ...orders.map((order) => _buildOrderItem(
                  orderNumber: order['orderNumber'] ?? 'N/A',
                  customerName: order['customerName'] ?? 'N/A',
                  routeName: order['routeName'] ?? 'N/A',
                  amount: '€${(order['amount'] ?? 0.0).toStringAsFixed(2)}',
                  status: _getStatusDisplayName(order['status'] ?? ''),
                  statusColor: _getStatusColor(order['status'] ?? ''),
                  onTap: () => _showOrderDetails(order),
                )),
            ],
          ),
        );
      },
    );
  }

  /// Einzelne Bestellung
  Widget _buildOrderItem({
    required String orderNumber,
    required String customerName,
    required String routeName,
    required String amount,
    required String status,
    required Color statusColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                orderNumber,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(customerName),
            ),
            Expanded(
              flex: 4,
              child: Text(routeName),
            ),
            Expanded(
              flex: 2,
              child: Text(
                amount,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hilfsmethoden für Status-Anzeige
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Ausstehend';
      case 'confirmed':
        return 'Bestätigt';
      case 'processing':
        return 'In Bearbeitung';
      case 'shipped':
        return 'Versandt';
      case 'delivered':
        return 'Geliefert';
      case 'cancelled':
        return 'Storniert';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.amber;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Zeigt Bestelldetails an
  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bestellung ${order['orderNumber']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kunde: ${order['customerName']}'),
            Text('Route: ${order['routeName']}'),
            Text('Betrag: €${(order['amount'] ?? 0.0).toStringAsFixed(2)}'),
            Text('Status: ${_getStatusDisplayName(order['status'] ?? '')}'),
            Text('Datum: ${order['createdAt'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}
