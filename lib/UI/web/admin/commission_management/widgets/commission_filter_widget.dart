import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'dart:async';

/// Widget für das Filtern von Provisionen
class CommissionFilterWidget extends StatefulWidget {
  const CommissionFilterWidget({super.key});

  @override
  State<CommissionFilterWidget> createState() => _CommissionFilterWidgetState();
}

class _CommissionFilterWidgetState extends State<CommissionFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _showCustomDatePickers = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CommissionProvider>();
    _searchController.text = provider.searchTerm;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommissionProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ResponsiveLayout(
              mobile: _buildMobileLayout(context, provider),
              tablet: _buildTabletLayout(context, provider),
              desktop: _buildDesktopLayout(context, provider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, CommissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusFilter(provider),
        const SizedBox(height: 12),
        _buildSearchField(provider),
        const SizedBox(height: 12),
        _buildPeriodFilter(provider),
        if (_showCustomDatePickers) ...[
          const SizedBox(height: 12),
          _buildCustomDatePickers(provider),
        ],
        if (_hasActiveFilters(provider)) ...[
          const SizedBox(height: 12),
          _buildClearFiltersButton(provider),
        ],
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, CommissionProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatusFilter(provider)),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _buildSearchField(provider)),
            const SizedBox(width: 12),
            Expanded(child: _buildPeriodFilter(provider)),
          ],
        ),
        if (_showCustomDatePickers) ...[
          const SizedBox(height: 12),
          _buildCustomDatePickers(provider),
        ],
        if (_hasActiveFilters(provider)) ...[
          const SizedBox(height: 12),
          _buildClearFiltersButton(provider),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    CommissionProvider provider,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatusFilter(provider),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildSearchField(provider)),
            const SizedBox(width: 16),
            _buildPeriodFilter(provider),
            if (_hasActiveFilters(provider)) ...[
              const SizedBox(width: 16),
              _buildClearFiltersButton(provider),
            ],
          ],
        ),
        if (_showCustomDatePickers) ...[
          const SizedBox(height: 12),
          _buildCustomDatePickers(provider),
        ],
      ],
    );
  }

  Widget _buildStatusFilter(CommissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        DropdownButton<String>(
          key: const Key('status_filter_dropdown'),
          value: provider.currentFilter,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Alle')),
            DropdownMenuItem(value: 'pending', child: Text('Ausstehend')),
            DropdownMenuItem(value: 'calculated', child: Text('Berechnet')),
            DropdownMenuItem(value: 'paid', child: Text('Bezahlt')),
            DropdownMenuItem(value: 'cancelled', child: Text('Storniert')),
          ],
          onChanged: (value) {
            if (value != null) {
              provider.setFilter(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchField(CommissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suchbegriff', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        TextField(
          key: const Key('search_text_field'),
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nach Unternehmen oder Bestellung suchen...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 500), () {
              provider.setSearchTerm(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPeriodFilter(CommissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Zeitraum', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        DropdownButton<String>(
          key: const Key('period_filter_dropdown'),
          value: provider.selectedPeriod,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'week', child: Text('Diese Woche')),
            DropdownMenuItem(value: 'month', child: Text('Dieser Monat')),
            DropdownMenuItem(value: 'lastMonth', child: Text('Letzter Monat')),
            DropdownMenuItem(value: 'year', child: Text('Dieses Jahr')),
            DropdownMenuItem(value: 'custom', child: Text('Benutzerdefiniert')),
          ],
          onChanged: (value) {
            if (value != null) {
              _handlePeriodChange(value, provider);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCustomDatePickers(CommissionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Von', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Startdatum wählen',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onTap: () => _selectStartDate(context, provider),
                controller: TextEditingController(
                  text: provider.startDate?.toString().split(' ')[0] ?? '',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bis', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Enddatum wählen',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onTap: () => _selectEndDate(context, provider),
                controller: TextEditingController(
                  text: provider.endDate?.toString().split(' ')[0] ?? '',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton(CommissionProvider provider) {
    return ElevatedButton.icon(
      onPressed: () => _clearAllFilters(provider),
      icon: const Icon(Icons.clear_all),
      label: const Text('Filter zurücksetzen'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  void _handlePeriodChange(String period, CommissionProvider provider) {
    setState(() {
      _showCustomDatePickers = period == 'custom';
    });

    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (period) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(now.year, now.month, 0);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
        break;
      case 'custom':
        // Don't set dates automatically for custom
        return;
    }

    provider.setDateRange(startDate, endDate);
  }

  Future<void> _selectStartDate(
    BuildContext context,
    CommissionProvider provider,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      provider.setDateRange(date, provider.endDate);
    }
  }

  Future<void> _selectEndDate(
    BuildContext context,
    CommissionProvider provider,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: provider.endDate ?? DateTime.now(),
      firstDate: provider.startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      provider.setDateRange(provider.startDate, date);
    }
  }

  void _clearAllFilters(CommissionProvider provider) {
    _searchController.clear();
    provider.setFilter('all');
    provider.setSearchTerm('');
    provider.setDateRange(null, null);
    setState(() {
      _showCustomDatePickers = false;
    });
  }

  bool _hasActiveFilters(CommissionProvider provider) {
    return provider.currentFilter != 'all' ||
        provider.searchTerm.isNotEmpty ||
        provider.startDate != null ||
        provider.endDate != null;
  }
}
