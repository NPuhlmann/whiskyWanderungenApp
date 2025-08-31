import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/database/backend_api.dart';
import '../../domain/models/basic_order.dart';
import '../../config/routing/routes.dart';

/// Page displaying user's order history
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<BasicOrder> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final backendApi = context.read<BackendApiService>();
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('Benutzer nicht angemeldet');
      }
      
      final userId = currentUser.id;
      
      final orders = await backendApi.fetchUserOrders(userId);
      
      setState(() {
        _orders = orders;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Bestellhistorie: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Bestellungen'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrderHistory,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrderHistory,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Keine Bestellungen gefunden',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Ihre Bestellungen werden hier angezeigt, sobald Sie eine Wanderung gekauft haben.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(BasicOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToOrderTracking(order.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              
              const SizedBox(height: 8),

              // Order details
              Row(
                children: [
                  const Icon(Icons.hiking, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Wanderung #${order.hikeId}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Delivery info
              Row(
                children: [
                  Icon(
                    order.deliveryType == DeliveryType.shipping 
                      ? Icons.local_shipping
                      : Icons.store,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.deliveryType == DeliveryType.shipping 
                      ? 'Versand'
                      : 'Abholung',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(order.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              // Tracking info for shipped orders
              if (order.status == OrderStatus.shipped && order.trackingNumber != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sendungsnummer: ${order.trackingNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Add action buttons at the bottom
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToOrderTracking(order.id),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Details anzeigen'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToOrderTracking(int orderId) {
    context.go('${Routes.orderTracking}/$orderId');
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha:0.2);
        textColor = Colors.orange.shade700;
        text = 'Ausstehend';
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.withValues(alpha:0.2);
        textColor = Colors.blue.shade700;
        text = 'Bestätigt';
        break;
      case OrderStatus.processing:
        backgroundColor = Colors.purple.withValues(alpha:0.2);
        textColor = Colors.purple.shade700;
        text = 'Verarbeitung';
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.teal.withValues(alpha:0.2);
        textColor = Colors.teal.shade700;
        text = 'Versandt';
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.withValues(alpha:0.2);
        textColor = Colors.green.shade700;
        text = 'Zugestellt';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red.withValues(alpha:0.2);
        textColor = Colors.red.shade700;
        text = 'Storniert';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}