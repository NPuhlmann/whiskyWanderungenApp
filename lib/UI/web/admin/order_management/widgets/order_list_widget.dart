import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'package:whisky_hikes/data/providers/order_management_provider.dart';
import 'order_details_dialog.dart';
import 'order_status_chip.dart';

/// Widget für die Anzeige der Order-Liste
class OrderListWidget extends StatelessWidget {
  const OrderListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
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
                  'Fehler beim Laden der Bestellungen',
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
                  onPressed: () => provider.loadOrders(),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          );
        }

        final orders = provider.currentFilter == 'all'
            ? provider.orders
            : provider.filteredOrders;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Keine Bestellungen gefunden',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.currentFilter != 'all'
                      ? 'Keine Bestellungen entsprechen den aktuellen Filtern'
                      : 'Es wurden noch keine Bestellungen erstellt',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (provider.currentFilter != 'all') ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => provider.clearFilters(),
                    child: const Text('Filter zurücksetzen'),
                  ),
                ],
              ],
            ),
          );
        }

        return ResponsiveLayout(
          mobile: _buildMobileList(context, orders, provider),
          tablet: _buildTabletList(context, orders, provider),
          desktop: _buildDesktopTable(context, orders, provider),
        );
      },
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    List<Map<String, dynamic>> orders,
    OrderManagementProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showOrderDetails(context, order, provider),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Bestellung #${order['id']}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      OrderStatusChip(status: order['status'] ?? 'pending'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.formatOrderAmount(order),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'User: ${order['user_id']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(order['created_at']),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletList(
    BuildContext context,
    List<Map<String, dynamic>> orders,
    OrderManagementProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showOrderDetails(context, order, provider),
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
                          'Bestellung #${order['id']}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User: ${order['user_id']}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.formatOrderAmount(order),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order['created_at']),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order['status'] ?? 'pending'),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<Map<String, dynamic>> orders,
    OrderManagementProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header mit Sortierung
        Row(
          children: [
            Text(
              '${orders.length} Bestellungen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            _buildSortDropdown(context, provider),
          ],
        ),
        const SizedBox(height: 16),

        // Tabelle
        Expanded(
          child: Card(
            child: SingleChildScrollView(
              child: DataTable(
                headingRowHeight: 56,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
                columns: [
                  DataColumn(
                    label: Text(
                      'Bestellung',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Kunde',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Betrag',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Datum',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Aktionen',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: orders.map((order) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '#${order['id']}',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (order['hike_id'] != null)
                              Text(
                                'Hike ID: ${order['hike_id']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          order['user_id']?.toString() ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        Text(
                          provider.formatOrderAmount(order),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      DataCell(
                        OrderStatusChip(status: order['status'] ?? 'pending'),
                      ),
                      DataCell(
                        Text(
                          _formatDate(order['created_at']),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _showOrderDetails(context, order, provider),
                              icon: const Icon(Icons.visibility),
                              tooltip: 'Details anzeigen',
                            ),
                            if (provider.canModifyOrder(order))
                              IconButton(
                                onPressed: () => _showStatusUpdateDialog(
                                  context,
                                  order,
                                  provider,
                                ),
                                icon: const Icon(Icons.edit),
                                tooltip: 'Status ändern',
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortDropdown(
    BuildContext context,
    OrderManagementProvider provider,
  ) {
    return DropdownButton<String>(
      value: 'created_at',
      items: [
        DropdownMenuItem(
          value: 'created_at',
          child: Text('Nach Datum sortieren'),
        ),
        DropdownMenuItem(
          value: 'total_amount',
          child: Text('Nach Betrag sortieren'),
        ),
        DropdownMenuItem(value: 'status', child: Text('Nach Status sortieren')),
        DropdownMenuItem(value: 'id', child: Text('Nach ID sortieren')),
      ],
      onChanged: (value) {
        if (value != null) {
          // TODO: Implement sorting
        }
      },
    );
  }

  void _showOrderDetails(
    BuildContext context,
    Map<String, dynamic> order,
    OrderManagementProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  void _showStatusUpdateDialog(
    BuildContext context,
    Map<String, dynamic> order,
    OrderManagementProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = order['status'] ?? 'pending';
        return AlertDialog(
          title: Text('Status ändern - Bestellung #${order['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Aktueller Status: ${order['status']}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Neuer Status',
                  border: OutlineInputBorder(),
                ),
                items: provider
                    .getValidOrderStatuses()
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.updateOrderStatus(order['id'], selectedStatus);
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
