import 'package:flutter/material.dart';
import '../../../domain/models/enhanced_order.dart' as enhanced;
import '../../../domain/models/basic_order.dart' as basic;

/// Widget for displaying tracking information for shipped orders
class TrackingInfoCard extends StatelessWidget {
  final dynamic order; // Can be either EnhancedOrder or BasicOrder

  const TrackingInfoCard({
    super.key,
    required this.order,
  });

  /// Factory constructor for enhanced orders
  factory TrackingInfoCard.enhanced({required enhanced.EnhancedOrder order}) {
    return TrackingInfoCard(order: order);
  }

  /// Factory constructor for basic orders
  factory TrackingInfoCard.basic({required basic.BasicOrder order}) {
    return TrackingInfoCard(order: order);
  }

  @override
  Widget build(BuildContext context) {
    if (order is enhanced.EnhancedOrder) {
      return _buildEnhancedTrackingInfo(context, order as enhanced.EnhancedOrder);
    } else if (order is basic.BasicOrder) {
      return _buildBasicTrackingInfo(context, order as basic.BasicOrder);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildEnhancedTrackingInfo(BuildContext context, enhanced.EnhancedOrder order) {
    if (!order.canBeTracked) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sendungsverfolgung',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTrackingDetails(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicTrackingInfo(BuildContext context, basic.BasicOrder order) {
    if (order.trackingNumber?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sendungsverfolgung',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBasicTrackingDetails(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingDetails(BuildContext context, enhanced.EnhancedOrder order) {
    return Column(
      children: [
        // Tracking number
        if (order.trackingNumber?.isNotEmpty == true) ...[
          _buildInfoRow(
            context,
            'Tracking-Nummer',
            order.trackingNumber!,
          ),
          const SizedBox(height: 8),
        ],

        // Tracking URL
        if (order.trackingUrl?.isNotEmpty == true) ...[
          _buildInfoRow(
            context,
            'Tracking-Link',
            order.trackingUrl!,
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openTrackingUrl(order.trackingUrl!),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Tracking öffnen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],

        // Current status
        _buildInfoRow(
          context,
          'Aktueller Status',
          _getTrackingStatusText(order.status),
        ),
        const SizedBox(height: 8),

        // Last update
        if (order.updatedAt != null) ...[
          _buildInfoRow(
            context,
            'Letzte Aktualisierung',
            _formatDate(order.updatedAt!),
          ),
          const SizedBox(height: 8),
        ],

        // Estimated delivery
        if (order.estimatedDelivery != null) ...[
          _buildInfoRow(
            context,
            'Geschätzte Zustellung',
            _formatDate(order.estimatedDelivery!),
          ),
        ],
      ],
    );
  }

  Widget _buildBasicTrackingDetails(BuildContext context, basic.BasicOrder order) {
    return Column(
      children: [
        // Tracking number
        _buildInfoRow(
          context,
          'Tracking-Nummer',
          order.trackingNumber!,
        ),
        const SizedBox(height: 8),

        // Current status
        _buildInfoRow(
          context,
          'Aktueller Status',
          _getBasicTrackingStatusText(order.status),
        ),
        const SizedBox(height: 8),

        // Estimated delivery
        if (order.estimatedDelivery != null) ...[
          _buildInfoRow(
            context,
            'Geschätzte Zustellung',
            _formatDate(order.estimatedDelivery!),
          ),
          const SizedBox(height: 8),
        ],

        // Standard tracking info
        _buildInfoRow(
          context,
          'Versanddienstleister',
          'Standardversand',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          'Versandzeit',
          '3-5 Werktage',
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getTrackingStatusText(enhanced.EnhancedOrderStatus status) {
    switch (status) {
      case enhanced.EnhancedOrderStatus.shipped:
        return 'Versendet';
      case enhanced.EnhancedOrderStatus.outForDelivery:
        return 'Zustellung unterwegs';
      case enhanced.EnhancedOrderStatus.delivered:
        return 'Zugestellt';
      default:
        return 'Unbekannt';
    }
  }

  String _getBasicTrackingStatusText(basic.OrderStatus status) {
    switch (status) {
      case basic.OrderStatus.shipped:
        return 'Versendet';
      case basic.OrderStatus.delivered:
        return 'Zugestellt';
      default:
        return 'Unbekannt';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _openTrackingUrl(String url) {
    // TODO: Implement URL opening logic
    // This would typically use url_launcher package
    print('Opening tracking URL: $url');
  }
}
