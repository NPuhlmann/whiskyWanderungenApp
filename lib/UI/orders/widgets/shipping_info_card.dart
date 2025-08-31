import 'package:flutter/material.dart';
import '../../../domain/models/enhanced_order.dart' as enhanced;
import '../../../domain/models/basic_order.dart' as basic;

/// Widget for displaying shipping information for orders
class ShippingInfoCard extends StatelessWidget {
  final dynamic order; // Can be either EnhancedOrder or BasicOrder

  const ShippingInfoCard({
    super.key,
    required this.order,
  });

  /// Factory constructor for enhanced orders
  factory ShippingInfoCard.enhanced({required enhanced.EnhancedOrder order}) {
    return ShippingInfoCard(order: order);
  }

  /// Factory constructor for basic orders
  factory ShippingInfoCard.basic({required basic.BasicOrder order}) {
    return ShippingInfoCard(order: order);
  }

  @override
  Widget build(BuildContext context) {
    if (order is enhanced.EnhancedOrder) {
      return _buildEnhancedShippingInfo(context, order as enhanced.EnhancedOrder);
    } else if (order is basic.BasicOrder) {
      return _buildBasicShippingInfo(context, order as basic.BasicOrder);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildEnhancedShippingInfo(BuildContext context, enhanced.EnhancedOrder order) {
    if (order.deliveryType == enhanced.DeliveryType.pickup) {
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
                  Icons.local_shipping,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Versandinformationen',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildShippingDetails(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicShippingInfo(BuildContext context, basic.BasicOrder order) {
    if (order.deliveryType == basic.DeliveryType.shipping) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Versandinformationen',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBasicShippingDetails(context, order),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildShippingDetails(BuildContext context, enhanced.EnhancedOrder order) {
    return Column(
      children: [
        // Shipping service
        if (order.shippingService != null) ...[
          _buildInfoRow(
            context,
            'Versanddienstleister',
            order.shippingService!,
          ),
          const SizedBox(height: 8),
        ],

        // Shipping cost
        _buildInfoRow(
          context,
          'Versandkosten',
          '€${order.shippingCost.toStringAsFixed(2)}',
        ),
        const SizedBox(height: 8),

        // Estimated delivery
        if (order.estimatedDelivery != null) ...[
          _buildInfoRow(
            context,
            'Geschätzte Lieferung',
            _formatDate(order.estimatedDelivery!),
          ),
          const SizedBox(height: 8),
        ],

        // Actual delivery
        if (order.actualDelivery != null) ...[
          _buildInfoRow(
            context,
            'Tatsächliche Lieferung',
            _formatDate(order.actualDelivery!),
          ),
          const SizedBox(height: 8),
        ],

        // Shipping details (simplified for now)
        _buildInfoRow(
          context,
          'Versandart',
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

  Widget _buildBasicShippingDetails(BuildContext context, basic.BasicOrder order) {
    return Column(
      children: [
        // Shipping cost (fixed for basic orders)
        _buildInfoRow(
          context,
          'Versandkosten',
          '€5.00',
        ),
        const SizedBox(height: 8),

        // Estimated delivery
        if (order.estimatedDelivery != null) ...[
          _buildInfoRow(
            context,
            'Geschätzte Lieferung',
            _formatDate(order.estimatedDelivery!),
          ),
          const SizedBox(height: 8),
        ],

        // Standard shipping info
        _buildInfoRow(
          context,
          'Versandart',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
