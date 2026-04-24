import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/data/providers/order_management_provider.dart';

class OrderFilterWidget extends StatelessWidget {
  const OrderFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderManagementProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status Filter
            _buildStatusFilter(context, provider),
            const SizedBox(height: 16),

            // Date Range Filter
            _buildDateRangeFilter(context, provider),
            const SizedBox(height: 16),

            // Amount Range Filter
            _buildAmountRangeFilter(context, provider),
            const SizedBox(height: 16),

            // Search Filter
            _buildSearchFilter(context, provider),
            const SizedBox(height: 16),

            // Filter Actions
            _buildFilterActions(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildStatusFilter(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: provider.currentFilter == 'all'
              ? null
              : provider.currentFilter,
          decoration: const InputDecoration(
            hintText: 'Alle Status',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Alle Status'),
            ),
            ...provider.getValidOrderStatuses().map(
              (status) => DropdownMenuItem<String>(
                value: status,
                child: Text(_getStatusDisplayName(status)),
              ),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              provider.applyStatusFilter('all');
            } else {
              provider.applyStatusFilter(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Zeitraum', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDateRange(context, provider),
                icon: const Icon(Icons.date_range),
                label: Text(
                  provider.startDate != null && provider.endDate != null
                      ? '${_formatDate(provider.startDate!)} - ${_formatDate(provider.endDate!)}'
                      : 'Datum wählen',
                ),
              ),
            ),
            if (provider.startDate != null || provider.endDate != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => provider.clearDateFilter(),
                icon: const Icon(Icons.clear),
                tooltip: 'Datumsfilter löschen',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAmountRangeFilter(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Betrag', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Min €',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  provider.setMinAmount(amount);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Max €',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  provider.setMaxAmount(amount);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchFilter(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suche', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Order ID, User ID...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => provider.searchOrders(value),
        ),
      ],
    );
  }

  Widget _buildFilterActions(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    final hasActiveFilters =
        provider.currentFilter != 'all' ||
        provider.startDate != null ||
        provider.endDate != null ||
        provider.minAmount != null ||
        provider.maxAmount != null ||
        provider.searchQuery.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: hasActiveFilters ? () => provider.clearFilters() : null,
            child: const Text('Filter zurücksetzen'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => provider.applyFilters(),
            child: const Text('Anwenden'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(
    BuildContext context,
    OrderManagementProvider provider,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
    );

    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
