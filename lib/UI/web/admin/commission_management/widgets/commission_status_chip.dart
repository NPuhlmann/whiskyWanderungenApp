import 'package:flutter/material.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

/// Widget zur Anzeige des Commission-Status als farbiges Chip
class CommissionStatusChip extends StatelessWidget {
  final CommissionStatus status;
  final bool showAction;
  final VoidCallback? onStatusChange;

  const CommissionStatusChip({
    super.key,
    required this.status,
    this.showAction = false,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = _getColorScheme(status);
    final statusText = _getStatusText(status);
    final statusIcon = _getStatusIcon(status);

    return Tooltip(
      message: 'Status: $statusText',
      child: Chip(
        avatar: Icon(statusIcon, size: 16, color: colorScheme['textColor']),
        label: Text(
          statusText,
          style: TextStyle(
            color: colorScheme['textColor'],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        backgroundColor: colorScheme['backgroundColor'],
        side: BorderSide(color: colorScheme['borderColor']!, width: 1),
        deleteIcon: showAction && onStatusChange != null
            ? Icon(Icons.edit, size: 16, color: colorScheme['textColor'])
            : null,
        onDeleted: showAction && onStatusChange != null ? onStatusChange : null,
      ),
    );
  }

  /// Get color scheme based on commission status
  Map<String, Color> _getColorScheme(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.pending:
        return {
          'backgroundColor': Colors.orange.shade100,
          'textColor': Colors.orange.shade800,
          'borderColor': Colors.orange.shade300,
        };
      case CommissionStatus.calculated:
        return {
          'backgroundColor': Colors.blue.shade100,
          'textColor': Colors.blue.shade800,
          'borderColor': Colors.blue.shade300,
        };
      case CommissionStatus.paid:
        return {
          'backgroundColor': Colors.green.shade100,
          'textColor': Colors.green.shade800,
          'borderColor': Colors.green.shade300,
        };
      case CommissionStatus.cancelled:
        return {
          'backgroundColor': Colors.red.shade100,
          'textColor': Colors.red.shade800,
          'borderColor': Colors.red.shade300,
        };
    }
  }

  /// Get display text for commission status
  String _getStatusText(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.pending:
        return 'Ausstehend';
      case CommissionStatus.calculated:
        return 'Berechnet';
      case CommissionStatus.paid:
        return 'Bezahlt';
      case CommissionStatus.cancelled:
        return 'Storniert';
    }
  }

  /// Get icon for commission status
  IconData _getStatusIcon(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.pending:
        return Icons.pending;
      case CommissionStatus.calculated:
        return Icons.calculate;
      case CommissionStatus.paid:
        return Icons.check_circle;
      case CommissionStatus.cancelled:
        return Icons.cancel;
    }
  }
}
