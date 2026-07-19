import 'package:flutter/material.dart';
import '../../../../domain/models/basic_order.dart';
import '../../../../domain/models/hike.dart';

/// Shipping cost per delivery type, in euros.
const _deliveryCosts = {
  DeliveryType.pickup: 0.0,
  DeliveryType.standardShipping: 5.0,
  DeliveryType.expressShipping: 10.0,
};

/// Widget that displays order details and pricing breakdown
class OrderSummary extends StatelessWidget {
  final Hike hike;
  final DeliveryType deliveryType;

  const OrderSummary({
    super.key,
    required this.hike,
    required this.deliveryType,
  });

  double get _deliveryCost => _deliveryCosts[deliveryType] ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Bestellübersicht',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Hike
            _buildInfoRow('Wanderung:', hike.name, theme),
            const SizedBox(height: 8),

            // Delivery Type
            _buildInfoRow(
              'Lieferart:',
              deliveryType == DeliveryType.pickup ? 'Abholung' : 'Versand',
              theme,
            ),
            const SizedBox(height: 16),

            const Divider(),
            const SizedBox(height: 16),

            // Pricing Breakdown
            _buildPriceRow('Grundpreis:', hike.price, theme, isSubtotal: true),

            if (_deliveryCost > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Versandkosten:',
                _deliveryCost,
                theme,
                isSubtotal: true,
              ),
            ],

            const SizedBox(height: 8),
            const Divider(thickness: 2),
            const SizedBox(height: 8),

            // Total
            _buildPriceRow(
              'Gesamt:',
              hike.price + _deliveryCost,
              theme,
              isTotal: true,
            ),

            const SizedBox(height: 16),

            // Delivery Info
            if (deliveryType == DeliveryType.pickup)
              _buildPickupInfo(theme)
            else
              _buildDeliveryInfo(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isSubtotal = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            '${amount.toStringAsFixed(2)} €',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : null,
              color: isTotal ? theme.colorScheme.primary : null,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Versand innerhalb von 3-5 Werktagen',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bereit zur Abholung nach Zahlungsbestätigung',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
