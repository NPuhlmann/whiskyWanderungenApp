import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/data/providers/order_management_provider.dart';
import 'order_status_chip.dart';

class OrderDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsDialog({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 600,
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContent(context),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bestellung #${widget.order['id']}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Erstellt am ${_formatDate(widget.order['created_at'])}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          OrderStatusChip(status: widget.order['status'] ?? 'pending'),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Schließen',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildOrderInfo(context),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildCustomerInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildOrderItems(context),
          const SizedBox(height: 24),
          _buildPaymentInfo(context),
          if (widget.order['notes'] != null) ...[
            const SizedBox(height: 24),
            _buildNotesSection(context),
          ],
          const SizedBox(height: 24),
          _buildStatusHistory(context),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bestellinformationen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Bestellnummer', '#${widget.order['id']}'),
            _buildInfoRow('Hike ID', '${widget.order['hike_id'] ?? 'N/A'}'),
            _buildInfoRow(
              'Gesamtbetrag',
              context.read<OrderManagementProvider>().formatOrderAmount(widget.order),
            ),
            _buildInfoRow('Erstellt am', _formatDate(widget.order['created_at'])),
            if (widget.order['updated_at'] != null)
              _buildInfoRow('Aktualisiert am', _formatDate(widget.order['updated_at'])),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kundeninformationen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', '${widget.order['user_id'] ?? 'Unknown'}'),
            if (widget.order['customer_email'] != null)
              _buildInfoRow('E-Mail', '${widget.order['customer_email']}'),
            if (widget.order['customer_name'] != null)
              _buildInfoRow('Name', '${widget.order['customer_name']}'),
            if (widget.order['shipping_address'] != null)
              _buildInfoRow('Lieferadresse', '${widget.order['shipping_address']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    final items = widget.order['items'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bestellpositionen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Text('Keine Bestellpositionen verfügbar')
            else
              ...items.map((item) => _buildOrderItem(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item['name'] ?? 'Unbekanntes Produkt',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              'Menge: ${item['quantity'] ?? 1}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '€${(item['price'] ?? 0.0).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zahlungsinformationen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Zahlungsmethode',
              '${widget.order['payment_method'] ?? 'Nicht angegeben'}',
            ),
            _buildInfoRow(
              'Zahlungsstatus',
              '${widget.order['payment_status'] ?? 'Unbekannt'}',
            ),
            if (widget.order['payment_id'] != null)
              _buildInfoRow('Payment ID', '${widget.order['payment_id']}'),
            if (widget.order['payment_date'] != null)
              _buildInfoRow('Bezahlt am', _formatDate(widget.order['payment_date'])),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notizen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.order['notes']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistory(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Status-Verlauf',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              _buildStatusHistoryList(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistoryList(BuildContext context) {
    final statusHistory = widget.order['status_history'] as List<dynamic>? ?? [];

    if (statusHistory.isEmpty) {
      return const Text('Kein Status-Verlauf verfügbar');
    }

    return Column(
      children: statusHistory.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              OrderStatusChip(status: entry['status'] ?? 'unknown'),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDate(entry['changed_at']),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (entry['changed_by'] != null)
                Text(
                  'von ${entry['changed_by']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
          const SizedBox(width: 12),
          Consumer<OrderManagementProvider>(
            builder: (context, provider, child) {
              if (!provider.canModifyOrder(widget.order)) {
                return const SizedBox.shrink();
              }

              return ElevatedButton(
                onPressed: () => _showStatusUpdateDialog(context, provider),
                child: const Text('Status ändern'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, OrderManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = widget.order['status'] ?? 'pending';
        return AlertDialog(
          title: Text('Status ändern - Bestellung #${widget.order['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Aktueller Status: ${widget.order['status']}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Neuer Status',
                  border: OutlineInputBorder(),
                ),
                items: provider.getValidOrderStatuses()
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              OrderStatusChip(status: status),
                              const SizedBox(width: 8),
                              Text(status),
                            ],
                          ),
                        ))
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
                Navigator.of(context).pop(); // Close details dialog too
                await provider.updateOrderStatus(widget.order['id'], selectedStatus);
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unbekannt';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Ungültiges Datum';
    }
  }
}