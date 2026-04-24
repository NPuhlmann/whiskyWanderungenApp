import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/data/providers/whisky_management_provider.dart';

/// Widget for filtering and searching tasting sets
class WhiskyCatalogFilters extends StatefulWidget {
  final VoidCallback? onFiltersChanged;

  const WhiskyCatalogFilters({super.key, this.onFiltersChanged});

  @override
  State<WhiskyCatalogFilters> createState() => _WhiskyCatalogFiltersState();
}

class _WhiskyCatalogFiltersState extends State<WhiskyCatalogFilters> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Initialize with current search query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WhiskyManagementProvider>();
      _searchController.text = provider.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WhiskyManagementProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.filters,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_hasActiveFilters(provider))
                    TextButton(
                      onPressed: () => _clearAllFilters(provider),
                      child: Text(AppLocalizations.of(context)!.clearAll),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Search field
              _buildSearchField(provider),
              const SizedBox(height: 16),

              // Region filter
              _buildRegionFilter(provider),
              const SizedBox(height: 16),

              // Distillery filter
              _buildDistilleryFilter(provider),
              const SizedBox(height: 16),

              // Quick filters
              _buildQuickFilters(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(WhiskyManagementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.search,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchTastingSets,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      provider.updateSearchQuery('');
                      widget.onFiltersChanged?.call();
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          onChanged: (value) {
            provider.updateSearchQuery(value);
            widget.onFiltersChanged?.call();
          },
        ),
      ],
    );
  }

  Widget _buildRegionFilter(WhiskyManagementProvider provider) {
    final regions = provider.availableRegions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.region,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          value: provider.selectedRegion,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          hint: Text(AppLocalizations.of(context)!.allRegions),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(AppLocalizations.of(context)!.allRegions),
            ),
            ...regions.map(
              (region) =>
                  DropdownMenuItem<String?>(value: region, child: Text(region)),
            ),
          ],
          onChanged: (value) {
            provider.updateRegionFilter(value);
            widget.onFiltersChanged?.call();
          },
        ),
      ],
    );
  }

  Widget _buildDistilleryFilter(WhiskyManagementProvider provider) {
    final distilleries = provider.availableDistilleries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.distillery,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          value: provider.selectedDistillery,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          hint: Text(AppLocalizations.of(context)!.allDistilleries),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(AppLocalizations.of(context)!.allDistilleries),
            ),
            ...distilleries.map(
              (distillery) => DropdownMenuItem<String?>(
                value: distillery,
                child: Text(distillery),
              ),
            ),
          ],
          onChanged: (value) {
            provider.updateDistilleryFilter(value);
            widget.onFiltersChanged?.call();
          },
        ),
      ],
    );
  }

  Widget _buildQuickFilters(WhiskyManagementProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quickFilters,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(AppLocalizations.of(context)!.availableOnly),
              selected: false, // TODO: Implement availability filter
              onSelected: (selected) {
                // TODO: Implement availability filter logic
                widget.onFiltersChanged?.call();
              },
            ),
            FilterChip(
              label: Text(AppLocalizations.of(context)!.hasImages),
              selected: false, // TODO: Implement image filter
              onSelected: (selected) {
                // TODO: Implement image filter logic
                widget.onFiltersChanged?.call();
              },
            ),
            FilterChip(
              label: Text(AppLocalizations.of(context)!.newThisMonth),
              selected: false, // TODO: Implement date filter
              onSelected: (selected) {
                // TODO: Implement date filter logic
                widget.onFiltersChanged?.call();
              },
            ),
          ],
        ),
      ],
    );
  }

  bool _hasActiveFilters(WhiskyManagementProvider provider) {
    return provider.searchQuery.isNotEmpty ||
        provider.selectedRegion != null ||
        provider.selectedDistillery != null;
  }

  void _clearAllFilters(WhiskyManagementProvider provider) {
    _searchController.clear();
    provider.clearFilters();
    widget.onFiltersChanged?.call();
  }
}
