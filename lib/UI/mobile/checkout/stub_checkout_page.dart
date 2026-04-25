import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/providers/cart_provider.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../domain/models/basic_order.dart';
import '../../../config/routing/routes.dart';
import 'stub_checkout_view_model.dart';

class StubCheckoutPage extends StatelessWidget {
  final DeliveryType deliveryType;
  final double totalAmount;

  const StubCheckoutPage({
    super.key,
    required this.deliveryType,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StubCheckoutViewModel(
        paymentRepository: context.read<PaymentRepository>(),
        cartProvider: context.read<CartProvider>(),
        deliveryType: deliveryType,
        totalAmount: totalAmount,
      ),
      child: const _StubCheckoutView(),
    );
  }
}

class _StubCheckoutView extends StatefulWidget {
  const _StubCheckoutView();

  @override
  State<_StubCheckoutView> createState() => _StubCheckoutViewState();
}

class _StubCheckoutViewState extends State<_StubCheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Deutschland');

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _onAddressChanged(StubCheckoutViewModel vm) {
    vm.setDeliveryAddress({
      'street': _streetController.text,
      'city': _cityController.text,
      'postalCode': _postalCodeController.text,
      'country': _countryController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestellung abschließen'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer<StubCheckoutViewModel>(
        builder: (context, vm, _) {
          // Navigate to success page once order is placed
          if (vm.orderPlaced) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(
                '${Routes.paymentSuccess}?orderNumber=${vm.completedOrderNumber}',
              );
            });
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Order summary
                      _OrderSummaryCard(
                        deliveryType: vm.deliveryType,
                        totalAmount: vm.totalAmount,
                      ),

                      const SizedBox(height: 24),

                      // Address form (only for shipping)
                      if (vm.deliveryType != DeliveryType.pickup) ...[
                        const Text(
                          'Lieferadresse',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _streetController,
                          decoration: const InputDecoration(
                            labelText: 'Straße und Hausnummer',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _onAddressChanged(vm),
                          validator: (v) => vm.validateField('street', v ?? ''),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                controller: _postalCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'PLZ',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _onAddressChanged(vm),
                                validator: (v) =>
                                    vm.validateField('postalCode', v ?? ''),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: const InputDecoration(
                                  labelText: 'Stadt',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => _onAddressChanged(vm),
                                validator: (v) =>
                                    vm.validateField('city', v ?? ''),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Land',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _onAddressChanged(vm),
                          validator: (v) =>
                              vm.validateField('country', v ?? ''),
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (vm.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vm.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      ElevatedButton(
                        onPressed: vm.canPlaceOrder
                            ? () {
                                if (vm.deliveryType != DeliveryType.pickup &&
                                    !(_formKey.currentState?.validate() ??
                                        false)) {
                                  return;
                                }
                                final userId = Supabase
                                    .instance.client.auth.currentUser?.id ?? '';
                                vm.placeOrder(userId);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Jetzt bestellen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Deine Bestellung wird zur manuellen Bearbeitung weitergeleitet.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              if (vm.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final DeliveryType deliveryType;
  final double totalAmount;

  const _OrderSummaryCard({
    required this.deliveryType,
    required this.totalAmount,
  });

  String _deliveryLabel(DeliveryType type) {
    switch (type) {
      case DeliveryType.pickup:
        return 'Abholung (kostenlos)';
      case DeliveryType.standardShipping:
        return 'Standardversand';
      case DeliveryType.expressShipping:
        return 'Expressversand';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bestellübersicht',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lieferart'),
                Text(_deliveryLabel(deliveryType)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gesamtbetrag',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
