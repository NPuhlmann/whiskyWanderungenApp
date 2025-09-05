import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'checkout_view_model.dart';
import 'widgets/order_summary.dart';
import 'widgets/multi_payment_method_selector.dart';
import 'widgets/delivery_address_form.dart';
import 'widgets/checkout_button.dart';
import '../../domain/models/basic_order.dart';
import '../../data/repositories/payment_repository.dart';

/// Main checkout page for processing hike purchases
class CheckoutPage extends StatefulWidget {
  final BasicOrder order;

  const CheckoutPage({
    super.key,
    required this.order,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _hasShownSuccessDialog = false;
  
  void _showPaymentSuccessDialog(CheckoutViewModel viewModel) {
    if (_hasShownSuccessDialog) return;
    _hasShownSuccessDialog = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Zahlung erfolgreich!'),
        content: Text(
          'Ihre Bestellung ${viewModel.order.formattedOrderNumber} wurde erfolgreich verarbeitet.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.navigateToOrderHistory(context);
            },
            child: const Text('Alle Bestellungen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.navigateToOrderTracking(context);
            },
            child: const Text('Bestellung verfolgen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = CheckoutViewModel(
          paymentRepository: context.read<PaymentRepository>(),
          order: widget.order,
        );
        // Initialize payment methods
        viewModel.initialize();
        return viewModel;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.checkout),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Consumer<CheckoutViewModel>(
          builder: (context, viewModel, child) {
            // Show success dialog when payment is successful
            if (viewModel.paymentSuccess && !_hasShownSuccessDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showPaymentSuccessDialog(viewModel);
              });
            }
            
            return Stack(
              children: [
                // Main content
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Order Summary
                      Semantics(
                        label: 'Bestellübersicht',
                        child: OrderSummary(order: widget.order),
                      ),
                      
                      const SizedBox(height: 24),

                      // Delivery Address Form (only for shipping orders)
                      if (widget.order.deliveryType == DeliveryType.shipping) ...[
                        const Text(
                          'Lieferadresse',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DeliveryAddressForm(
                          onAddressChanged: viewModel.setDeliveryAddress,
                          validator: viewModel.validateAddressField,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Multi Payment Method Selector
                      if (viewModel.isInitializing)
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Zahlungsmethoden werden geladen...'),
                            ],
                          ),
                        )
                      else
                        Semantics(
                          label: 'Zahlungsmethode auswählen',
                          child: MultiPaymentMethodSelector(
                            selectedPaymentMethod: viewModel.selectedPaymentMethod,
                            selectedPaymentMethodId: viewModel.selectedPaymentMethodId,
                            availablePaymentMethods: viewModel.availablePaymentMethods,
                            onPaymentMethodChanged: viewModel.setPaymentMethod,
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Error Message
                      if (viewModel.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: viewModel.clearError,
                                child: Text(
                                  'Erneut versuchen',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Checkout Button
                      Semantics(
                        label: 'Zahlung abschließen',
                        child: CheckoutButton(
                          enabled: viewModel.canProcessPayment,
                          onPressed: viewModel.processPayment,
                        ),
                      ),

                      // Bottom spacing for safe area
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Loading overlay
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Zahlung wird verarbeitet...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}