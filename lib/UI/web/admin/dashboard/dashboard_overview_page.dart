import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/data/providers/dashboard_provider.dart';
import 'package:whisky_hikes/UI/web/admin/dashboard/widgets/kpi_card.dart';
import 'package:whisky_hikes/UI/web/admin/dashboard/widgets/recent_orders_widget.dart';
import 'package:whisky_hikes/UI/web/admin/dashboard/widgets/popular_routes_widget.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';

class DashboardOverviewPage extends StatefulWidget {
  @override
  _DashboardOverviewPageState createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().refreshData();
            },
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!, provider);
          }

          return ResponsiveLayout(
            mobile: _buildMobileLayout(provider),
            desktop: _buildDesktopLayout(provider),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading dashboard data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, DashboardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.refreshData(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DashboardProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueSection(provider),
          SizedBox(height: 24),
          _buildOrderSection(provider),
          SizedBox(height: 24),
          _buildRouteSalesSection(provider),
          SizedBox(height: 24),
          _buildCustomerRatingSection(provider),
          SizedBox(height: 24),
          _buildRecentOrdersSection(provider),
          SizedBox(height: 24),
          _buildPopularRoutesSection(provider),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(DashboardProvider provider) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.5,
        children: [
          _buildRevenueSection(provider),
          _buildOrderSection(provider),
          _buildRouteSalesSection(provider),
          _buildCustomerRatingSection(provider),
          _buildRecentOrdersSection(provider),
          _buildPopularRoutesSection(provider),
        ],
      ),
    );
  }

  Widget _buildRevenueSection(DashboardProvider provider) {
    if (!provider.hasRevenueData) {
      return _buildEmptySection('Revenue Overview', 'No revenue data available');
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Today',
                      value: provider.formattedDailyRevenue,
                      growthPercentage: provider.dailyGrowthPercentage,
                      icon: Icons.today,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'This Week',
                      value: provider.formattedWeeklyRevenue,
                      growthPercentage: provider.weeklyGrowthPercentage,
                      icon: Icons.date_range,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'This Month',
                      value: provider.formattedMonthlyRevenue,
                      growthPercentage: 0.0, // No comparison for monthly
                      icon: Icons.calendar_month,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection(DashboardProvider provider) {
    if (!provider.hasOrderData) {
      return _buildEmptySection('Order Management', 'No order data available');
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Total Active',
                      value: provider.totalActiveOrders.toString(),
                      icon: Icons.shopping_cart,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'Pending',
                      value: provider.pendingOrders.toString(),
                      icon: Icons.hourglass_empty,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'Processing',
                      value: provider.processingOrders.toString(),
                      icon: Icons.settings,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'Shipped',
                      value: provider.shippedOrders.toString(),
                      icon: Icons.local_shipping,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSalesSection(DashboardProvider provider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Sales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Today',
                      value: provider.soldRoutesToday.toString(),
                      icon: Icons.today,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'This Week',
                      value: provider.soldRoutesThisWeek.toString(),
                      icon: Icons.date_range,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: KpiCard(
                      title: 'This Month',
                      value: provider.soldRoutesThisMonth.toString(),
                      icon: Icons.calendar_month,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRatingSection(DashboardProvider provider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.formattedRating,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < provider.ratingStars ? Icons.star : Icons.star_border,
                        color: Colors.amber[700],
                        size: 20,
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Average Rating',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersSection(DashboardProvider provider) {
    if (!provider.hasRecentOrders) {
      return _buildEmptySection('Recent Orders', 'No recent orders');
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: RecentOrdersWidget(orders: provider.recentOrders),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularRoutesSection(DashboardProvider provider) {
    if (!provider.hasPopularRoutes) {
      return _buildEmptySection('Popular Routes', 'No popular routes data');
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular Routes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: PopularRoutesWidget(routes: provider.popularRoutes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String title, String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}