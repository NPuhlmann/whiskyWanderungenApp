import 'package:flutter/material.dart';
import '../../../../domain/models/enhanced_order.dart';
import '../../../../domain/models/basic_order.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';

/// Widget for displaying order status progression in a timeline format
class OrderStatusTimeline extends StatelessWidget {
  final dynamic order; // Can be either EnhancedOrder or BasicOrder

  const OrderStatusTimeline({
    super.key,
    required this.order,
  });

  /// Factory constructor for enhanced orders
  factory OrderStatusTimeline.enhanced({required EnhancedOrder order}) {
    return OrderStatusTimeline(order: order);
  }

  /// Factory constructor for basic orders
  factory OrderStatusTimeline.basic({required BasicOrder order}) {
    return OrderStatusTimeline(order: order);
  }

  @override
  Widget build(BuildContext context) {
    if (order is EnhancedOrder) {
      return _buildEnhancedTimeline(context, order as EnhancedOrder);
    } else if (order is BasicOrder) {
      return _buildBasicTimeline(context, order as BasicOrder);
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.unknownOrderType),
        ),
      );
    }
  }

  Widget _buildEnhancedTimeline(BuildContext context, EnhancedOrder order) {
    final statusHistory = order.statusHistory;
    final currentStatus = order.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bestellstatus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimelineSteps(context, _getEnhancedStatusSteps(currentStatus), statusHistory ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicTimeline(BuildContext context, BasicOrder order) {
    final currentStatus = order.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bestellstatus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimelineSteps(context, _getBasicStatusSteps(currentStatus), []),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSteps(
    BuildContext context,
    List<TimelineStep> steps,
    List<OrderStatusChange> statusHistory,
  ) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = step.isCompleted;
        final isCurrent = step.isCurrent;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStepColor(context, step, isCompleted, isCurrent),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : isCurrent
                          ? Icon(
                              Icons.schedule,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : isCurrent
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (step.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(step.timestamp!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getStepColor(
    BuildContext context,
    TimelineStep step,
    bool isCompleted,
    bool isCurrent,
  ) {
    if (isCompleted) {
      return Theme.of(context).colorScheme.primary;
    } else if (isCurrent) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  List<TimelineStep> _getEnhancedStatusSteps(EnhancedOrderStatus currentStatus) {
    final steps = <TimelineStep>[];
    final allStatuses = EnhancedOrderStatus.values;

    for (final status in allStatuses) {
      final isCompleted = _isStatusCompleted(status, currentStatus);
      final isCurrent = status == currentStatus;

      steps.add(TimelineStep(
        status: status,
        title: _getEnhancedStatusTitle(status),
        description: _getEnhancedStatusDescription(status),
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        timestamp: _getStatusTimestamp(status),
      ));
    }

    return steps;
  }

  List<TimelineStep> _getBasicStatusSteps(OrderStatus currentStatus) {
    final steps = <TimelineStep>[];
    final allStatuses = OrderStatus.values;

    for (final status in allStatuses) {
      final isCompleted = _isBasicStatusCompleted(status, currentStatus);
      final isCurrent = status == currentStatus;

      steps.add(TimelineStep(
        status: status,
        title: _getBasicStatusTitle(status),
        description: _getBasicStatusDescription(status),
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        timestamp: _getBasicStatusTimestamp(status),
      ));
    }

    return steps;
  }

  bool _isStatusCompleted(EnhancedOrderStatus status, EnhancedOrderStatus currentStatus) {
    final statusOrder = [
      EnhancedOrderStatus.pending,
      EnhancedOrderStatus.paymentPending,
      EnhancedOrderStatus.confirmed,
      EnhancedOrderStatus.processing,
      EnhancedOrderStatus.shipped,
      EnhancedOrderStatus.outForDelivery,
      EnhancedOrderStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final statusIndex = statusOrder.indexOf(status);

    if (currentIndex == -1 || statusIndex == -1) return false;
    return statusIndex <= currentIndex;
  }

  bool _isBasicStatusCompleted(OrderStatus status, OrderStatus currentStatus) {
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final statusIndex = statusOrder.indexOf(status);

    if (currentIndex == -1 || statusIndex == -1) return false;
    return statusIndex <= currentIndex;
  }

  String _getEnhancedStatusTitle(EnhancedOrderStatus status) {
    switch (status) {
      case EnhancedOrderStatus.pending:
        return 'Bestellung eingegangen';
      case EnhancedOrderStatus.paymentPending:
        return 'Zahlung ausstehend';
      case EnhancedOrderStatus.confirmed:
        return 'Bestellung bestätigt';
      case EnhancedOrderStatus.processing:
        return 'In Bearbeitung';
      case EnhancedOrderStatus.shipped:
        return 'Versendet';
      case EnhancedOrderStatus.outForDelivery:
        return 'Zustellung unterwegs';
      case EnhancedOrderStatus.delivered:
        return 'Zugestellt';
      case EnhancedOrderStatus.cancelled:
        return 'Storniert';
      case EnhancedOrderStatus.refunded:
        return 'Erstattet';
      case EnhancedOrderStatus.failed:
        return 'Fehlgeschlagen';
    }
  }

  String _getBasicStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Bestellung eingegangen';
      case OrderStatus.confirmed:
        return 'Bestellung bestätigt';
      case OrderStatus.processing:
        return 'In Bearbeitung';
      case OrderStatus.shipped:
        return 'Versendet';
      case OrderStatus.delivered:
        return 'Zugestellt';
      case OrderStatus.cancelled:
        return 'Storniert';
      case OrderStatus.failed:
        return 'Fehlgeschlagen';
    }
  }

  String? _getEnhancedStatusDescription(EnhancedOrderStatus status) {
    switch (status) {
      case EnhancedOrderStatus.pending:
        return 'Deine Bestellung wurde erfolgreich aufgegeben';
      case EnhancedOrderStatus.paymentPending:
        return 'Warte auf Zahlungsbestätigung';
      case EnhancedOrderStatus.confirmed:
        return 'Zahlung bestätigt, Bestellung wird vorbereitet';
      case EnhancedOrderStatus.processing:
        return 'Dein Tasting-Set wird zusammengestellt';
      case EnhancedOrderStatus.shipped:
        return 'Dein Paket ist auf dem Weg';
      case EnhancedOrderStatus.outForDelivery:
        return 'Zustellung erfolgt heute';
      case EnhancedOrderStatus.delivered:
        return 'Dein Paket wurde erfolgreich zugestellt';
      case EnhancedOrderStatus.cancelled:
        return 'Bestellung wurde storniert';
      case EnhancedOrderStatus.refunded:
        return 'Betrag wurde erstattet';
      case EnhancedOrderStatus.failed:
        return 'Bestellung konnte nicht verarbeitet werden';
    }
  }

  String? _getBasicStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Deine Bestellung wurde erfolgreich aufgegeben';
      case OrderStatus.confirmed:
        return 'Zahlung bestätigt, Bestellung wird vorbereitet';
      case OrderStatus.processing:
        return 'Dein Tasting-Set wird zusammengestellt';
      case OrderStatus.shipped:
        return 'Dein Paket ist auf dem Weg';
      case OrderStatus.delivered:
        return 'Dein Paket wurde erfolgreich zugestellt';
      case OrderStatus.cancelled:
        return 'Bestellung wurde storniert';
      case OrderStatus.failed:
        return 'Bestellung konnte nicht verarbeitet werden';
    }
  }

  DateTime? _getStatusTimestamp(EnhancedOrderStatus status) {
    // TODO: Implement when status history is available
    return null;
  }

  DateTime? _getBasicStatusTimestamp(OrderStatus status) {
    // TODO: Implement when status history is available
    return null;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'vor ${difference.inDays} Tag${difference.inDays == 1 ? '' : 'en'}';
    } else if (difference.inHours > 0) {
      return 'vor ${difference.inHours} Stunde${difference.inHours == 1 ? '' : 'n'}';
    } else if (difference.inMinutes > 0) {
      return 'vor ${difference.inMinutes} Minute${difference.inMinutes == 1 ? '' : 'n'}';
    } else {
      return 'gerade eben';
    }
  }
}

/// Represents a single step in the timeline
class TimelineStep {
  final dynamic status; // Can be EnhancedOrderStatus or OrderStatus
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isCurrent;
  final DateTime? timestamp;

  const TimelineStep({
    required this.status,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.isCurrent,
    this.timestamp,
  });
}
