import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'widgets/commission_statistics_widget.dart';
import 'widgets/commission_filter_widget.dart';
import 'widgets/commission_list_widget.dart';
import 'widgets/commission_export_widget.dart';

/// Admin-Seite für die Verwaltung von Provisionen
class CommissionManagementPage extends StatefulWidget {
  const CommissionManagementPage({super.key});

  @override
  State<CommissionManagementPage> createState() => _CommissionManagementPageState();
}

class _CommissionManagementPageState extends State<CommissionManagementPage> {
  final String _companyId = 'current-company'; // TODO: Get from auth/context

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final provider = context.read<CommissionProvider>();
    provider.loadCommissionsForCompany(_companyId);
    provider.loadStatistics(_companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Provisionen verwalten'),
        ],
      ),
      actions: [
        Consumer<CommissionProvider>(
          builder: (context, provider, child) {
            return IconButton(
              onPressed: provider.isLoading ? null : _refreshData,
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
        ),
        const SizedBox(width: 8),
        CommissionExportWidget(companyId: _companyId),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        const CommissionStatisticsWidget(),
        const SizedBox(height: 8),
        const CommissionFilterWidget(),
        const SizedBox(height: 8),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListHeader(context),
                const Expanded(child: CommissionListWidget()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CommissionStatisticsWidget(),
          const SizedBox(height: 16),
          const CommissionFilterWidget(),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListHeader(context),
                  const Expanded(child: CommissionListWidget()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CommissionStatisticsWidget(),
          const SizedBox(height: 24),
          const CommissionFilterWidget(),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListHeader(context),
                  const Expanded(child: CommissionListWidget()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Consumer<CommissionProvider>(
      builder: (context, provider, child) {
        final totalCount = provider.commissions.length;
        final filteredCount = provider.filteredCommissions.length;
        final hasFilters = provider.currentFilter != 'all' ||
                           provider.searchTerm.isNotEmpty ||
                           provider.startDate != null ||
                           provider.endDate != null;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.list_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Provisionen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasFilters ? '$filteredCount von $totalCount' : '$totalCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (provider.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        );
      },
    );
  }

  void _refreshData() {
    final provider = context.read<CommissionProvider>();
    provider.loadCommissionsForCompany(_companyId);
    provider.loadStatistics(_companyId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daten werden aktualisiert...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}