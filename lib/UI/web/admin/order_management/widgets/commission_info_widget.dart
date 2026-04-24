import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

/// Widget to display commission information for an order
class CommissionInfoWidget extends StatefulWidget {
  final String orderId;
  final double? orderTotal;

  const CommissionInfoWidget({
    super.key,
    required this.orderId,
    this.orderTotal,
  });

  @override
  State<CommissionInfoWidget> createState() => _CommissionInfoWidgetState();
}

class _CommissionInfoWidgetState extends State<CommissionInfoWidget> {
  late final CommissionService _commissionService;
  Commission? _commission;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _commissionService = CommissionService(Supabase.instance.client);
    _loadCommissionData();
  }

  Future<void> _loadCommissionData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final commission = await _commissionService.getCommissionByOrderId(
        widget.orderId,
      );

      setState(() {
        _commission = commission;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Provision',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_commission != null)
                  _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_commission != null)
              _buildCommissionDetails()
            else
              _buildNoCommissionState(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final commission = _commission!;
    Color chipColor;
    String statusText;

    switch (commission.status) {
      case CommissionStatus.pending:
        chipColor = Colors.orange;
        statusText = 'Ausstehend';
        break;
      case CommissionStatus.calculated:
        chipColor = Colors.blue;
        statusText = 'Berechnet';
        break;
      case CommissionStatus.paid:
        chipColor = Colors.green;
        statusText = 'Bezahlt';
        break;
      case CommissionStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Storniert';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Provisionsdaten werden geladen...'),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Fehler beim Laden der Provisionsdaten',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadCommissionData,
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCommissionState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Keine Provision erstellt',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Für diese Bestellung wurde noch keine Provision erstellt. Provisionen werden automatisch erstellt, wenn die Bestellung als "Geliefert" markiert wird.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionDetails() {
    final commission = _commission!;

    return Column(
      children: [
        _buildDetailRow('Provision ID', '#${commission.id}'),
        _buildDetailRow('Hike ID', '#${commission.hikeId}'),
        _buildDetailRow('Unternehmen', commission.companyId),
        _buildDetailRow(
          'Grundbetrag',
          '€${commission.baseAmount.toStringAsFixed(2)}',
        ),
        _buildDetailRow(
          'Provisionssatz',
          '${(commission.commissionRate * 100).toStringAsFixed(1)}%',
        ),
        _buildDetailRow(
          'Provisionsbetrag',
          '€${commission.commissionAmount.toStringAsFixed(2)}',
          isAmount: true,
        ),
        _buildDetailRow('Erstellt am', _formatDate(commission.createdAt)),
        if (commission.paidAt != null)
          _buildDetailRow('Bezahlt am', _formatDate(commission.paidAt!)),
        if (commission.notes != null && commission.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Notizen:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(commission.notes!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isAmount ? FontWeight.bold : null,
                color: isAmount ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
