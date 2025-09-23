import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/data/providers/whisky_management_provider.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'tasting_set_card.dart';
import 'tasting_set_details_dialog.dart';

/// Widget that displays a list of tasting sets with CRUD functionality
class TastingSetList extends StatelessWidget {
  const TastingSetList({super.key});

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
    return Scaffold(
      body: _buildListContent(context, provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTastingSetDialog(context),
        backgroundColor: Colors.amber[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WhiskyManagementProvider provider) {
    return Column(
      children: [
        _buildToolbar(context, provider),
        Expanded(
          child: _buildListContent(context, provider),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WhiskyManagementProvider provider) {
    return Column(
      children: [
        _buildToolbar(context, provider),
        Expanded(
          child: _buildListContent(context, provider),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, WhiskyManagementProvider provider) {
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
          Text(
            '${AppLocalizations.of(context)!.tastingSets} (${provider.filteredTastingSets.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Sort dropdown
          PopupMenuButton<TastingSetSortBy>(
            initialValue: provider.sortBy,
            onSelected: (sortBy) => provider.updateSortBy(sortBy),
            icon: const Icon(Icons.sort),
            tooltip: AppLocalizations.of(context)!.sortBy,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TastingSetSortBy.name,
                child: Row(
                  children: [
                    const Icon(Icons.sort_by_alpha),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.name),
                    if (provider.sortBy == TastingSetSortBy.name)
                      Icon(provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TastingSetSortBy.sampleCount,
                child: Row(
                  children: [
                    const Icon(Icons.numbers),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.sampleCount),
                    if (provider.sortBy == TastingSetSortBy.sampleCount)
                      Icon(provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TastingSetSortBy.averageAge,
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.averageAge),
                    if (provider.sortBy == TastingSetSortBy.averageAge)
                      Icon(provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TastingSetSortBy.region,
                child: Row(
                  children: [
                    const Icon(Icons.map),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.region),
                    if (provider.sortBy == TastingSetSortBy.region)
                      Icon(provider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showCreateTastingSetDialog(context),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addTastingSet),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(BuildContext context, WhiskyManagementProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.errorLoadingData,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.refreshData(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    final tastingSets = provider.filteredTastingSets;

    if (tastingSets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_bar_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isNotEmpty ||
              provider.selectedRegion != null ||
              provider.selectedDistillery != null
                  ? AppLocalizations.of(context)!.noTastingSetsMatchFilter
                  : AppLocalizations.of(context)!.noTastingSetsYet,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.searchQuery.isNotEmpty ||
              provider.selectedRegion != null ||
              provider.selectedDistillery != null
                  ? AppLocalizations.of(context)!.tryAdjustingFilters
                  : AppLocalizations.of(context)!.createFirstTastingSet,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (provider.searchQuery.isNotEmpty ||
                provider.selectedRegion != null ||
                provider.selectedDistillery != null)
              ElevatedButton.icon(
                onPressed: () => provider.clearFilters(),
                icon: const Icon(Icons.clear),
                label: Text(AppLocalizations.of(context)!.clearFilters),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _showCreateTastingSetDialog(context),
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.createTastingSet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileList(context, provider, tastingSets),
      tablet: _buildTabletGrid(context, provider, tastingSets),
      desktop: _buildDesktopGrid(context, provider, tastingSets),
    );
  }

  Widget _buildMobileList(BuildContext context, WhiskyManagementProvider provider, List<TastingSet> tastingSets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tastingSets.length,
      itemBuilder: (context, index) {
        final tastingSet = tastingSets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TastingSetCard(
            tastingSet: tastingSet,
            onTap: () => _showTastingSetDetails(context, tastingSet),
            onEdit: () => _showEditTastingSetDialog(context, tastingSet),
            onDelete: () => _showDeleteConfirmation(context, tastingSet),
          ),
        );
      },
    );
  }

  Widget _buildTabletGrid(BuildContext context, WhiskyManagementProvider provider, List<TastingSet> tastingSets) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tastingSets.length,
      itemBuilder: (context, index) {
        final tastingSet = tastingSets[index];
        return TastingSetCard(
          tastingSet: tastingSet,
          onTap: () => _showTastingSetDetails(context, tastingSet),
          onEdit: () => _showEditTastingSetDialog(context, tastingSet),
          onDelete: () => _showDeleteConfirmation(context, tastingSet),
        );
      },
    );
  }

  Widget _buildDesktopGrid(BuildContext context, WhiskyManagementProvider provider, List<TastingSet> tastingSets) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.4,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: tastingSets.length,
      itemBuilder: (context, index) {
        final tastingSet = tastingSets[index];
        return TastingSetCard(
          tastingSet: tastingSet,
          onTap: () => _showTastingSetDetails(context, tastingSet),
          onEdit: () => _showEditTastingSetDialog(context, tastingSet),
          onDelete: () => _showDeleteConfirmation(context, tastingSet),
        );
      },
    );
  }

  void _showTastingSetDetails(BuildContext context, TastingSet tastingSet) {
    showDialog(
      context: context,
      builder: (context) => TastingSetDetailsDialog(tastingSet: tastingSet),
    );
  }

  void _showCreateTastingSetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createNewTastingSet),
        content: const Text('Tasting Set Creation Dialog would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement tasting set creation
            },
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }

  void _showEditTastingSetDialog(BuildContext context, TastingSet tastingSet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editTastingSet),
        content: Text('Edit Tasting Set: ${tastingSet.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement tasting set editing
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TastingSet tastingSet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTastingSet),
        content: Text(
          AppLocalizations.of(context)!.deleteTastingSetConfirmation(tastingSet.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WhiskyManagementProvider>().deleteTastingSet(tastingSet.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}