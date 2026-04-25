import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/cart_provider.dart';
import '../../../domain/models/basic_order.dart';
import '../../../domain/models/cart_item.dart';
import '../../../config/routing/routes.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warenkorb'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Dein Warenkorb ist leer',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(
                      item: item,
                      onIncrement: () =>
                          cart.updateQuantity(item.hike.id, item.quantity + 1),
                      onDecrement: () =>
                          cart.updateQuantity(item.hike.id, item.quantity - 1),
                      onRemove: () => cart.removeHike(item.hike.id),
                    );
                  },
                ),
              ),
              _CartSummary(cart: cart),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.hike.thumbnailImageUrl != null
              ? Image.network(
                  item.hike.thumbnailImageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(width: 12),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.hike.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.hike.price.toStringAsFixed(2)} €',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Quantity controls
        Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onDecrement,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onIncrement,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Entfernen',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
    width: 64,
    height: 64,
    color: Colors.grey[200],
    child: const Icon(Icons.landscape, color: Colors.grey),
  );
}

class _CartSummary extends StatefulWidget {
  final CartProvider cart;

  const _CartSummary({required this.cart});

  @override
  State<_CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends State<_CartSummary> {
  DeliveryType _deliveryType = DeliveryType.standardShipping;

  double get _shippingCost {
    switch (_deliveryType) {
      case DeliveryType.expressShipping:
        return 10.0;
      case DeliveryType.standardShipping:
        return 5.0;
      case DeliveryType.pickup:
        return 0.0;
    }
  }

  double get _total => widget.cart.totalAmount + _shippingCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delivery type selector
            const Text(
              'Lieferart',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<DeliveryType>(
              segments: const [
                ButtonSegment(
                  value: DeliveryType.pickup,
                  label: Text('Abholung'),
                  icon: Icon(Icons.store),
                ),
                ButtonSegment(
                  value: DeliveryType.standardShipping,
                  label: Text('Standard'),
                  icon: Icon(Icons.local_shipping),
                ),
                ButtonSegment(
                  value: DeliveryType.expressShipping,
                  label: Text('Express'),
                  icon: Icon(Icons.flash_on),
                ),
              ],
              selected: {_deliveryType},
              onSelectionChanged: (selection) =>
                  setState(() => _deliveryType = selection.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 12),
            // Price breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Zwischensumme'),
                Text('${widget.cart.totalAmount.toStringAsFixed(2)} €'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Versand'),
                Text(
                  _shippingCost == 0
                      ? 'Kostenlos'
                      : '${_shippingCost.toStringAsFixed(2)} €',
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gesamt',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${_total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push(
                Routes.stubCheckout,
                extra: {
                  'deliveryType': _deliveryType,
                  'totalAmount': _total,
                },
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Zur Kasse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
