import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:whisky_hikes/domain/models/commission.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'commission_status_chip.dart';

/// Dialog für die Anzeige und Bearbeitung von Provisions-Details
class CommissionDetailsDialog extends StatefulWidget {
  final Commission commission;

  const CommissionDetailsDialog({
    super.key,
    required this.commission,
  });

  @override
  State<CommissionDetailsDialog> createState() => _CommissionDetailsDialogState();
}

class _CommissionDetailsDialogState extends State<CommissionDetailsDialog> {
  late Commission _currentCommission;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentCommission = widget.commission;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: _buildContent(context),
              ),
            ),
            const Divider(height: 32),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Provisions-Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Allgemeine Informationen', [
          _buildInfoRow('Provisions-ID', '#${_currentCommission.id}'),
          _buildInfoRow('Bestellungs-ID', _currentCommission.orderId),
          _buildInfoRow('Unternehmen', _currentCommission.companyId),
          _buildInfoRow('Wanderroute', 'Hike #${_currentCommission.hikeId}'),
        ]),
        const SizedBox(height: 24),
        _buildSection('Finanzielle Details', [
          _buildInfoRow('Grundbetrag', _currentCommission.formattedBaseAmount),
          _buildInfoRow('Provisionssatz', '${_currentCommission.commissionRatePercentage.toStringAsFixed(1)}%'),
          _buildInfoRow('Provisionsbetrag', _currentCommission.formattedCommissionAmount),
        ]),
        const SizedBox(height: 24),
        _buildSection('Status & Zeitstempel', [
          _buildStatusRow('Status', _currentCommission.status),
          _buildInfoRow('Erstellt am', _formatDateTime(_currentCommission.createdAt)),
          if (_currentCommission.paidAt != null)
            _buildInfoRow('Bezahlt am', _formatDateTime(_currentCommission.paidAt!)),
          if (_currentCommission.updatedAt != null)
            _buildInfoRow('Zuletzt aktualisiert', _formatDateTime(_currentCommission.updatedAt!)),
        ]),
        if (_currentCommission.billingPeriodId != null) ...[
          const SizedBox(height: 24),
          _buildSection('Abrechnungsdetails', [
            _buildInfoRow('Abrechnungsperiode', _currentCommission.billingPeriodId!),
          ]),
        ],
        if (_currentCommission.notes != null && _currentCommission.notes!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSection('Notizen', [
            _buildNotesSection(_currentCommission.notes!),
          ]),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
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

  Widget _buildStatusRow(String label, CommissionStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                CommissionStatusChip(
                  status: status,
                  showAction: _canUpdateStatus(status),
                  onStatusChange: _canUpdateStatus(status) 
                      ? () => _showStatusUpdateDialog(context) 
                      : null,
                ),
                if (_isUpdating) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Text(
        notes,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Schließen'),
        ),
        if (_canUpdateStatus(_currentCommission.status)) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isUpdating 
                ? null 
                : () => _showStatusUpdateDialog(context),
            child: _isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Status ändern'),
          ),
        ],
      ],
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    final availableStatuses = _getAvailableStatusUpdates(_currentCommission.status);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status ändern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableStatuses.map((status) {
            return ListTile(
              leading: CommissionStatusChip(status: status),
              title: Text(_getStatusDescription(status)),
              onTap: () {
                Navigator.of(context).pop();
                _updateCommissionStatus(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCommissionStatus(CommissionStatus newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final provider = context.read<CommissionProvider>();
      await provider.updateCommissionStatus(_currentCommission.id, newStatus);
      
      setState(() {
        _currentCommission = _currentCommission.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
          paidAt: newStatus == CommissionStatus.paid ? DateTime.now() : null,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status erfolgreich aktualisiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Aktualisieren: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  bool _canUpdateStatus(CommissionStatus status) {
    return status != CommissionStatus.paid && status != CommissionStatus.cancelled;
  }

  List<CommissionStatus> _getAvailableStatusUpdates(CommissionStatus currentStatus) {
    switch (currentStatus) {
      case CommissionStatus.pending:
        return [CommissionStatus.calculated, CommissionStatus.cancelled];
      case CommissionStatus.calculated:
        return [CommissionStatus.paid, CommissionStatus.cancelled];
      case CommissionStatus.paid:
      case CommissionStatus.cancelled:
        return [];
    }
  }

  String _getStatusDescription(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.pending:
        return 'Provision ist noch ausstehend';
      case CommissionStatus.calculated:
        return 'Provision wurde berechnet';
      case CommissionStatus.paid:
        return 'Provision wurde bezahlt';
      case CommissionStatus.cancelled:
        return 'Provision wurde storniert';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm', 'de_DE').format(dateTime);
  }
}