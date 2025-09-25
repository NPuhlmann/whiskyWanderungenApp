import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/data/providers/whisky_management_provider.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

/// Overview widget showing key statistics for the whisky catalog
class WhiskyCatalogOverview extends StatelessWidget {
  const WhiskyCatalogOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WhiskyManagementProvider>(
      builder: (context, provider, child) {
        return ResponsiveLayout(
          mobile: _buildMobileLayout(context, provider),
          tablet: _buildTabletLayout(context, provider),
          desktop: _buildDesktopLayout(context, provider),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, WhiskyManagementProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.catalogOverview,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.error != null)
              _buildErrorWidget(context, provider.error!)
            else
              _buildStatsGrid(context, provider, crossAxisCount: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WhiskyManagementProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.catalogOverview,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.error != null)
              _buildErrorWidget(context, provider.error!)
            else
              _buildStatsGrid(context, provider, crossAxisCount: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WhiskyManagementProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.catalogOverview,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => provider.refreshData(),
                  tooltip: AppLocalizations.of(context)!.refresh,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.error != null)
              _buildErrorWidget(context, provider.error!)
            else
              _buildStatsGrid(context, provider, crossAxisCount: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WhiskyManagementProvider provider, {required int crossAxisCount}) {
    final statistics = provider.statistics;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildStatCard(
          context,
          title: AppLocalizations.of(context)!.totalSets,
          value: statistics?['totalSets']?.toString() ?? provider.tastingSets.length.toString(),
          icon: Icons.local_bar,
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          title: AppLocalizations.of(context)!.availableSets,
          value: statistics?['availableSets']?.toString() ??
                 provider.tastingSets.where((set) => set.isCurrentlyAvailable).length.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          title: AppLocalizations.of(context)!.totalSamples,
          value: statistics?['totalSamples']?.toString() ??
                 provider.tastingSets.fold(0, (int sum, set) => sum + set.sampleCount).toString(),
          icon: Icons.inventory,
          color: Colors.orange,
        ),
        if (crossAxisCount >= 3) ...[
          _buildStatCard(
            context,
            title: AppLocalizations.of(context)!.avgSamplesPerSet,
            value: statistics?['averageSamplesPerSet']?.toStringAsFixed(1) ?? '0.0',
            icon: Icons.analytics,
            color: Colors.purple,
          ),
          _buildStatCard(
            context,
            title: AppLocalizations.of(context)!.regions,
            value: provider.availableRegions.length.toString(),
            icon: Icons.map,
            color: Colors.teal,
          ),
          _buildStatCard(
            context,
            title: AppLocalizations.of(context)!.distilleries,
            value: provider.availableDistilleries.length.toString(),
            icon: Icons.business,
            color: Colors.indigo,
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[700],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.red[700],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<WhiskyManagementProvider>().refreshData();
              },
              tooltip: AppLocalizations.of(context)!.retry,
            ),
          ],
        ),
      ),
    );
  }
}