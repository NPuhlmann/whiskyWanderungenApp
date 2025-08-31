import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/enhanced_order.dart' as enhanced;
import '../../domain/models/basic_order.dart' as basic;
import '../../domain/models/delivery_address.dart';
import 'order_tracking_view_model.dart';
import 'widgets/order_status_timeline.dart';
import 'widgets/shipping_info_card.dart';
import 'widgets/tracking_info_card.dart';

/// Page for tracking order status and delivery progress
class OrderTrackingPage extends StatelessWidget {
  final int orderId;
  final bool useEnhancedOrder;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    this.useEnhancedOrder = true, // Default to enhanced order for better features
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderTrackingViewModel(
        orderId: orderId,
        useEnhancedOrder: useEnhancedOrder,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bestellverfolgung'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Consumer<OrderTrackingViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fehler beim Laden der Bestellung',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.retry,
                      child: const Text('Wiederholen'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.order == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bestellung nicht gefunden',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Die angeforderte Bestellung konnte nicht gefunden werden.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return _buildOrderTrackingContent(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildOrderTrackingContent(
    BuildContext context,
    OrderTrackingViewModel viewModel,
  ) {
    if (useEnhancedOrder && viewModel.enhancedOrder != null) {
      return _buildEnhancedOrderContent(context, viewModel.enhancedOrder!);
    } else if (viewModel.order != null) {
      return _buildBasicOrderContent(context, viewModel.order!);
    } else {
      return const Center(
        child: Text('Unexpected state: No order data available'),
      );
    }
  }

  Widget _buildEnhancedOrderContent(
    BuildContext context,
    enhanced.EnhancedOrder order,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(context, order),
          const SizedBox(height: 24),

          // Order Status Timeline
          OrderStatusTimeline.enhanced(order: order),
          const SizedBox(height: 24),

          // Delivery Information
          if (order.requiresDeliveryAddress) ...[
            _buildDeliveryInfoCard(context, order),
            const SizedBox(height: 24),
          ],

          // Shipping Information (if applicable)
          if (order.deliveryType != enhanced.DeliveryType.pickup) ...[
            ShippingInfoCard.enhanced(order: order),
            const SizedBox(height: 24),
          ],

          // Tracking Information (if available)
          if (order.canBeTracked) ...[
            TrackingInfoCard.enhanced(order: order),
            const SizedBox(height: 24),
          ],

          // Order Details
          _buildOrderDetailsCard(context, order),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, order),
        ],
      ),
    );
  }

  Widget _buildBasicOrderContent(
    BuildContext context,
    basic.BasicOrder order,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildBasicOrderHeader(context, order),
          const SizedBox(height: 24),

          // Order Status Timeline
          OrderStatusTimeline.basic(order: order),
          const SizedBox(height: 24),

          // Delivery Information
          if (order.requiresDeliveryAddress) ...[
            _buildBasicDeliveryInfoCard(context, order),
            const SizedBox(height: 24),
          ],

          // Shipping Information (if applicable)
          if (order.deliveryType == basic.DeliveryType.shipping) ...[
            ShippingInfoCard.basic(order: order),
            const SizedBox(height: 24),
          ],

          // Tracking Information (if available)
          if (order.trackingNumber?.isNotEmpty == true &&
              [basic.OrderStatus.shipped, basic.OrderStatus.delivered].contains(order.status)) ...[
            TrackingInfoCard.basic(order: order),
            const SizedBox(height: 24),
          ],

          // Order Details
          _buildBasicOrderDetailsCard(context, order),
          const SizedBox(height: 24),

          // Action Buttons
          _buildBasicActionButtons(context, order),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, enhanced.EnhancedOrder order) {
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
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.formattedOrderNumber,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order.statusDisplayText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getStatusColor(context, order.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    'Bestelldatum',
                    _formatDate(order.createdAt),
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    'Gesamtbetrag',
                    '€${order.totalAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicOrderHeader(BuildContext context, basic.BasicOrder order) {
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
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.formattedOrderNumber,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getBasicStatusText(order.status),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getBasicStatusColor(context, order.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    'Bestelldatum',
                    _formatDate(order.createdAt),
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    'Gesamtbetrag',
                    '€${order.totalAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard(BuildContext context, enhanced.EnhancedOrder order) {
    if (order.deliveryAddress == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lieferadresse',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatEnhancedAddress(order.deliveryAddress!),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDeliveryInfoCard(BuildContext context, basic.BasicOrder order) {
    if (order.deliveryAddress == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lieferadresse',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatBasicAddress(order.deliveryAddress!),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(BuildContext context, enhanced.EnhancedOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bestelldetails',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Versandart',
              order.deliveryTypeDisplayText,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Basispreis',
              '€${order.baseAmount.toStringAsFixed(2)}',
            ),
            if (order.shippingCost > 0) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Versandkosten',
                '€${order.shippingCost.toStringAsFixed(2)}',
              ),
            ],
            if (order.estimatedDelivery != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Geschätzte Lieferung',
                _formatDate(order.estimatedDelivery!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicOrderDetailsCard(BuildContext context, basic.BasicOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bestelldetails',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Versandart',
              order.deliveryType == basic.DeliveryType.pickup
                  ? 'Vor Ort abholen'
                  : 'Versand',
            ),
            if (order.estimatedDelivery != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Geschätzte Lieferung',
                _formatDate(order.estimatedDelivery!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, enhanced.EnhancedOrder order) {
    return Row(
      children: [
        if (order.canBeCancelled) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelOrderDialog(context, order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              child: const Text('Bestellung stornieren'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () => _contactSupport(context),
            child: const Text('Support kontaktieren'),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicActionButtons(BuildContext context, basic.BasicOrder order) {
    return Row(
      children: [
        if (order.canBeCancelled) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelOrderDialog(context, order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              child: const Text('Bestellung stornieren'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () => _contactSupport(context),
            child: const Text('Support kontaktieren'),
          ),
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

  Color _getStatusColor(BuildContext context, enhanced.EnhancedOrderStatus status) {
    switch (status) {
      case enhanced.EnhancedOrderStatus.pending:
      case enhanced.EnhancedOrderStatus.paymentPending:
        return Theme.of(context).colorScheme.tertiary;
      case enhanced.EnhancedOrderStatus.confirmed:
      case enhanced.EnhancedOrderStatus.processing:
        return Theme.of(context).colorScheme.primary;
      case enhanced.EnhancedOrderStatus.shipped:
      case enhanced.EnhancedOrderStatus.outForDelivery:
        return Theme.of(context).colorScheme.secondary;
      case enhanced.EnhancedOrderStatus.delivered:
        return Colors.green;
      case enhanced.EnhancedOrderStatus.cancelled:
      case enhanced.EnhancedOrderStatus.failed:
        return Theme.of(context).colorScheme.error;
      case enhanced.EnhancedOrderStatus.refunded:
        return Colors.orange;
    }
  }

  Color _getBasicStatusColor(BuildContext context, basic.OrderStatus status) {
    switch (status) {
      case basic.OrderStatus.pending:
        return Theme.of(context).colorScheme.tertiary;
      case basic.OrderStatus.confirmed:
      case basic.OrderStatus.processing:
        return Theme.of(context).colorScheme.primary;
      case basic.OrderStatus.shipped:
        return Theme.of(context).colorScheme.secondary;
      case basic.OrderStatus.delivered:
        return Colors.green;
      case basic.OrderStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getBasicStatusText(basic.OrderStatus status) {
    switch (status) {
      case basic.OrderStatus.pending:
        return 'Ausstehend';
      case basic.OrderStatus.confirmed:
        return 'Bestätigt';
      case basic.OrderStatus.processing:
        return 'In Bearbeitung';
      case basic.OrderStatus.shipped:
        return 'Versendet';
      case basic.OrderStatus.delivered:
        return 'Zugestellt';
      case basic.OrderStatus.cancelled:
        return 'Storniert';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatBasicAddress(Map<String, dynamic> address) {
    final street = address['street'] ?? '';
    final houseNumber = address['house_number'] ?? '';
    final postalCode = address['postal_code'] ?? '';
    final city = address['city'] ?? '';
    
    return '$street $houseNumber\n$postalCode $city';
  }

  String _formatEnhancedAddress(DeliveryAddress address) {
    // TODO: Implement proper address formatting when DeliveryAddress model is available
    return 'Adresse verfügbar';
  }

  void _showCancelOrderDialog(BuildContext context, dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bestellung stornieren'),
        content: const Text('Möchtest du diese Bestellung wirklich stornieren?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelOrder(context, order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context, dynamic order) {
    // TODO: Implement order cancellation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stornierung der Bestellung wurde angefordert'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    // TODO: Implement contact support logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kontaktiere Support...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
