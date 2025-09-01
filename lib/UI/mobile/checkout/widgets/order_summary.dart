import 'package:flutter/material.dart';
import '../../../domain/models/basic_order.dart';

/// Widget that displays order details and pricing breakdown
class OrderSummary extends StatelessWidget {
  final BasicOrder order;

  const OrderSummary({
    super.key,
    required this.order,
  });

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

            // Order Number
            _buildInfoRow(
              'Bestellnummer:',
              order.formattedOrderNumber,
              theme,
            ),
            const SizedBox(height: 8),

            // Delivery Type
            _buildInfoRow(
              'Lieferart:',
              order.deliveryType == DeliveryType.shipping 
                  ? 'Versand' 
                  : 'Abholung',
              theme,
            ),
            const SizedBox(height: 16),

            const Divider(),
            const SizedBox(height: 16),

            // Pricing Breakdown
            _buildPriceRow(
              'Grundpreis:',
              order.basePrice,
              theme,
              isSubtotal: true,
            ),
            
            if (order.deliveryCost > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Versandkosten:',
                order.deliveryCost,
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
              order.totalAmount,
              theme,
              isTotal: true,
            ),

            const SizedBox(height: 16),

            // Delivery Info
            if (order.deliveryType == DeliveryType.shipping)
              _buildDeliveryInfo(theme)
            else
              _buildPickupInfo(theme),
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