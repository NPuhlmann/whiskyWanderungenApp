import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'package:whisky_hikes/data/providers/order_management_provider.dart';
import 'widgets/order_list_widget.dart';
import 'widgets/order_filter_widget.dart';
import 'widgets/order_statistics_widget.dart';

/// Hauptseite für Order Management im Admin-Bereich
class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  @override
  void initState() {
    super.initState();
    // Daten beim ersten Laden laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<OrderManagementProvider>();
    await Future.wait([
      provider.loadOrders(),
      provider.loadOrderStatistics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          _buildRefreshButton(),
        ],
      ),
      body: Consumer<OrderManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Statistiken
              Container(
                padding: const EdgeInsets.all(16),
                child: OrderStatisticsWidget(),
              ),
              // Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OrderFilterWidget(),
              ),
              const Divider(),
              // Order Liste
              Expanded(
                child: OrderListWidget(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          _buildRefreshButton(),
        ],
      ),
      body: Consumer<OrderManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Row(
            children: [
              // Sidebar mit Filtern und Statistiken
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Statistiken
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: OrderStatisticsWidget(),
                    ),
                    const Divider(),
                    // Filter
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: OrderFilterWidget(),
                    ),
                  ],
                ),
              ),
              // Order Liste
              Expanded(
                child: OrderListWidget(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Consumer<OrderManagementProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Order Management',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildRefreshButton(),
                  ],
                ),
              ),

              if (provider.isLoading && provider.orders.isEmpty)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar mit Filtern und Statistiken
                      Container(
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Statistiken
                              OrderStatisticsWidget(),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              // Filter
                              OrderFilterWidget(),
                            ],
                          ),
                        ),
                      ),
                      // Hauptinhalt mit Order Liste
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: OrderListWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Consumer<OrderManagementProvider>(
      builder: (context, provider, child) {
        return IconButton(
          onPressed: provider.isLoading ? null : _loadInitialData,
          icon: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          tooltip: 'Daten aktualisieren',
        );
      },
    );
  }
}