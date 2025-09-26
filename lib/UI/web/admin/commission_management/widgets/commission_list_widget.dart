import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'package:whisky_hikes/domain/models/commission.dart';
import 'commission_status_chip.dart';
import 'commission_details_dialog.dart';

/// Widget für die Anzeige der Commission-Liste
class CommissionListWidget extends StatelessWidget {
  const CommissionListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommissionProvider>(
      builder: (context, provider, child) {
        return _buildContent(context, provider);
      },
    );
  }

  Widget _buildContent(BuildContext context, CommissionProvider provider) {
    if (provider.isLoading && provider.commissions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(context, provider);
    }

    if (provider.filteredCommissions.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return ResponsiveLayout(
      mobile: _buildMobileList(context, provider),
      tablet: _buildTabletList(context, provider),
      desktop: _buildDesktopTable(context, provider),
    );
  }

  Widget _buildErrorState(BuildContext context, CommissionProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Fehler beim Laden der Provisionen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadCommissionsForCompany('current-company'), // TODO: Get actual company ID
            child: const Text('Wiederholen'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, CommissionProvider provider) {
    final hasCommissions = provider.commissions.isNotEmpty;
    final icon = hasCommissions ? Icons.filter_alt_off : Icons.receipt_long;
    final title = hasCommissions 
        ? 'Keine Provisionen entsprechen den Filterkriterien'
        : 'Keine Provisionen gefunden';
    final subtitle = hasCommissions
        ? 'Versuchen Sie, die Filter zu ändern oder zurückzusetzen'
        : 'Es wurden noch keine Provisionen erstellt';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, CommissionProvider provider) {
    return ListView.builder(
      itemCount: provider.filteredCommissions.length,
      itemBuilder: (context, index) {
        final commission = provider.filteredCommissions[index];
        return _buildMobileCard(context, commission, provider);
      },
    );
  }

  Widget _buildTabletList(BuildContext context, CommissionProvider provider) {
    return ListView.builder(
      itemCount: provider.filteredCommissions.length,
      itemBuilder: (context, index) {
        final commission = provider.filteredCommissions[index];
        return _buildTabletCard(context, commission, provider);
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, CommissionProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Provision')),
          DataColumn(label: Text('Grundbetrag')),
          DataColumn(label: Text('Rate')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Unternehmen')),
          DataColumn(label: Text('Erstellt')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: provider.filteredCommissions.map((commission) {
          return DataRow(
            cells: [
              DataCell(Text(commission.formattedCommissionAmount)),
              DataCell(Text(commission.formattedBaseAmount)),
              DataCell(Text('${commission.commissionRatePercentage.toStringAsFixed(1)}%')),
              DataCell(CommissionStatusChip(status: commission.status)),
              DataCell(Text(commission.companyId)),
              DataCell(Text(_formatDate(commission.createdAt))),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showCommissionDetails(context, commission),
                  tooltip: 'Details anzeigen',
                ),
              ),
            ],
            onSelectChanged: (_) => _showCommissionDetails(context, commission),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, Commission commission, CommissionProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showCommissionDetails(context, commission),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    commission.formattedCommissionAmount,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CommissionStatusChip(status: commission.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Grundbetrag: ${commission.formattedBaseAmount}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Rate: ${commission.commissionRatePercentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Unternehmen: ${commission.companyId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Erstellt: ${_formatDate(commission.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletCard(BuildContext context, Commission commission, CommissionProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showCommissionDetails(context, commission),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commission.formattedCommissionAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grundbetrag: ${commission.formattedBaseAmount}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate: ${commission.commissionRatePercentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unternehmen: ${commission.companyId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CommissionStatusChip(status: commission.status),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(commission.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommissionDetails(BuildContext context, Commission commission) {
    showDialog(
      context: context,
      builder: (context) => CommissionDetailsDialog(commission: commission),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy', 'de_DE').format(date);
  }
}