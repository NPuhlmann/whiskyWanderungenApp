import 'package:flutter/material.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;
  final bool isClickable;
  final VoidCallback? onTap;

  const OrderStatusChip({
    super.key,
    required this.status,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusInfo.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusInfo.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusInfo.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: statusInfo.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: statusInfo.textColor,
            ),
          ],
        ],
      ),
    );

    if (isClickable && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: chip,
      );
    }

    return chip;
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusInfo(
          displayName: 'Ausstehend',
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          dotColor: Colors.orange.shade600,
          textColor: Colors.orange.shade800,
        );

      case 'confirmed':
        return _StatusInfo(
          displayName: 'Bestätigt',
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          dotColor: Colors.blue.shade600,
          textColor: Colors.blue.shade800,
        );

      case 'processing':
        return _StatusInfo(
          displayName: 'In Bearbeitung',
          backgroundColor: Colors.indigo.shade50,
          borderColor: Colors.indigo.shade200,
          dotColor: Colors.indigo.shade600,
          textColor: Colors.indigo.shade800,
        );

      case 'shipped':
        return _StatusInfo(
          displayName: 'Versandt',
          backgroundColor: Colors.purple.shade50,
          borderColor: Colors.purple.shade200,
          dotColor: Colors.purple.shade600,
          textColor: Colors.purple.shade800,
        );

      case 'delivered':
        return _StatusInfo(
          displayName: 'Zugestellt',
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          dotColor: Colors.green.shade600,
          textColor: Colors.green.shade800,
        );

      case 'cancelled':
        return _StatusInfo(
          displayName: 'Storniert',
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          dotColor: Colors.red.shade600,
          textColor: Colors.red.shade800,
        );

      case 'refunded':
        return _StatusInfo(
          displayName: 'Erstattet',
          backgroundColor: Colors.grey.shade50,
          borderColor: Colors.grey.shade300,
          dotColor: Colors.grey.shade600,
          textColor: Colors.grey.shade800,
        );

      default:
        return _StatusInfo(
          displayName: status,
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          dotColor: Colors.grey.shade500,
          textColor: Colors.grey.shade700,
        );
    }
  }
}

class _StatusInfo {
  final String displayName;
  final Color backgroundColor;
  final Color borderColor;
  final Color dotColor;
  final Color textColor;

  _StatusInfo({
    required this.displayName,
    required this.backgroundColor,
    required this.borderColor,
    required this.dotColor,
    required this.textColor,
  });
}

class OrderStatusChipGroup extends StatelessWidget {
  final List<String> statuses;
  final String? selectedStatus;
  final Function(String)? onStatusSelected;

  const OrderStatusChipGroup({
    super.key,
    required this.statuses,
    this.selectedStatus,
    this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = status == selectedStatus;

        return GestureDetector(
          onTap: () => onStatusSelected?.call(status),
          child: Container(
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : null,
            child: OrderStatusChip(
              status: status,
              isClickable: onStatusSelected != null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
