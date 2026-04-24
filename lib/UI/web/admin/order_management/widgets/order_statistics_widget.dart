import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/data/providers/order_management_provider.dart';

class OrderStatisticsWidget extends StatelessWidget {
  const OrderStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.statistics.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.statistics.isEmpty) {
          return const Center(child: Text('Keine Statistiken verfügbar'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiken',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Summary Cards
            _buildSummaryCards(context, provider),
            const SizedBox(height: 16),

            // Status Distribution
            _buildStatusDistribution(context, provider),
            const SizedBox(height: 16),

            // Time Period Selector
            _buildTimePeriodSelector(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    final stats = provider.statistics;

    return Column(
      children: [
        _buildStatCard(
          context,
          'Gesamtumsatz',
          _formatCurrency(stats['total_revenue']?.toDouble() ?? 0.0),
          Icons.euro,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          context,
          'Bestellungen',
          '${stats['total_orders'] ?? 0}',
          Icons.shopping_cart,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          context,
          'Ø Bestellwert',
          _formatCurrency(stats['average_order_value']?.toDouble() ?? 0.0),
          Icons.trending_up,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          context,
          'Heute',
          '${stats['orders_today'] ?? 0}',
          Icons.today,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

  Widget _buildStatusDistribution(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    final statusCounts =
        provider.statistics['status_distribution'] as Map<String, dynamic>? ??
        {};

    if (statusCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Verteilung',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...statusCounts.entries.map((entry) {
          final status = entry.key;
          final count = entry.value as int;
          final totalOrders = provider.statistics['total_orders'] as int? ?? 1;
          final percentage = (count / totalOrders * 100).round();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusDisplayName(status),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  '$count ($percentage%)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimePeriodSelector(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zeitraum',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'today', label: Text('Heute')),
            ButtonSegment(value: 'week', label: Text('Woche')),
            ButtonSegment(value: 'month', label: Text('Monat')),
          ],
          selected: {provider.selectedPeriod},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              provider.setStatisticsPeriod(selection.first);
            }
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => provider.loadOrderStatistics(),
          icon: provider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: const Text('Aktualisieren'),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.indigo;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

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
        return 'Zugestellt';
      case 'cancelled':
        return 'Storniert';
      case 'refunded':
        return 'Erstattet';
      default:
        return status;
    }
  }

  String _formatCurrency(double amount) {
    return '€${amount.toStringAsFixed(2)}';
  }
}
