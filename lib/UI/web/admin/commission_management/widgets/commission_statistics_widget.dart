import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';

/// Widget für die Anzeige von Provisions-Statistiken
class CommissionStatisticsWidget extends StatelessWidget {
  const CommissionStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommissionProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 16),
                _buildContent(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CommissionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Provisions-Statistiken',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          onPressed: provider.isLoading
              ? null
              : () => provider.loadStatistics(
                  'current-company',
                ), // TODO: Get actual company ID
          icon: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          tooltip: 'Statistiken aktualisieren',
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, CommissionProvider provider) {
    if (provider.isLoading && provider.statistics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Fehler beim Laden',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              provider.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileGrid(context, provider),
      tablet: _buildTabletGrid(context, provider),
      desktop: _buildDesktopGrid(context, provider),
    );
  }

  Widget _buildMobileGrid(BuildContext context, CommissionProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: _buildKpiCards(context, provider),
    );
  }

  Widget _buildTabletGrid(BuildContext context, CommissionProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: _buildKpiCards(context, provider),
    );
  }

  Widget _buildDesktopGrid(BuildContext context, CommissionProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 6,
      childAspectRatio: 1.1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: _buildKpiCards(context, provider),
    );
  }

  List<Widget> _buildKpiCards(
    BuildContext context,
    CommissionProvider provider,
  ) {
    final statistics = provider.statistics;

    return [
      _buildKpiCard(
        context,
        'Gesamt Provisionen',
        _formatNumber(statistics['totalCommissions'] ?? 0),
        Icons.receipt_long,
        Colors.blue,
      ),
      _buildKpiCard(
        context,
        'Ausstehende Provisionen',
        _formatNumber(statistics['pendingCommissions'] ?? 0),
        Icons.pending,
        Colors.orange,
      ),
      _buildKpiCard(
        context,
        'Bezahlte Provisionen',
        _formatNumber(statistics['paidCommissions'] ?? 0),
        Icons.check_circle,
        Colors.green,
      ),
      _buildKpiCard(
        context,
        'Gesamt Betrag',
        _formatCurrency(statistics['totalAmount'] ?? 0.0),
        Icons.euro,
        Colors.indigo,
      ),
      _buildKpiCard(
        context,
        'Ausstehender Betrag',
        _formatCurrency(statistics['pendingAmount'] ?? 0.0),
        Icons.euro,
        Colors.orange,
      ),
      _buildKpiCard(
        context,
        'Durchschnitt',
        _formatCurrency(statistics['averageCommission'] ?? 0.0),
        Icons.analytics,
        Colors.purple,
      ),
    ];
  }

  Widget _buildKpiCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';

    final number = value is int ? value : (value as double).toInt();
    final formatter = NumberFormat('#,##0', 'de_DE');
    return formatter.format(number);
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '€0,00';

    final amount = value is double ? value : (value as int).toDouble();
    final formatter = NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
