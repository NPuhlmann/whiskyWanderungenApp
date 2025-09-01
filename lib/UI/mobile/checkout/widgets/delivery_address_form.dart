import 'package:flutter/material.dart';

/// Form for entering delivery address information for shipping orders
class DeliveryAddressForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddressChanged;
  final String? Function(String, String)? validator;

  const DeliveryAddressForm({
    super.key,
    required this.onAddressChanged,
    this.validator,
  });

  @override
  State<DeliveryAddressForm> createState() => _DeliveryAddressFormState();
}

class _DeliveryAddressFormState extends State<DeliveryAddressForm> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Header
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lieferadresse',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Street Address
              TextFormField(
                controller: _streetController,
                key: const Key('street_field'),
                decoration: const InputDecoration(
                  labelText: 'Straße und Hausnummer',
                  hintText: 'Musterstraße 123',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (widget.validator != null) {
                    return widget.validator!('street', value ?? '');
                  }
                  if (value == null || value.isEmpty) {
                    return 'Straße ist erforderlich';
                  }
                  if (value.length < 3) {
                    return 'Straße muss mindestens 3 Zeichen haben';
                  }
                  return null;
                },
                onChanged: _updateAddress,
              ),
              const SizedBox(height: 16),

              // City and Postal Code Row
              Row(
                children: [
                  // Postal Code
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _postalCodeController,
                      key: const Key('postal_code_field'),
                      decoration: const InputDecoration(
                        labelText: 'PLZ',
                        hintText: '12345',
                        prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (widget.validator != null) {
                          return widget.validator!('postalCode', value ?? '');
                        }
                        if (value == null || value.isEmpty) {
                          return 'PLZ erforderlich';
                        }
                        if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                          return 'PLZ muss 5 Ziffern haben';
                        }
                        return null;
                      },
                      onChanged: _updateAddress,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // City
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cityController,
                      key: const Key('city_field'),
                      decoration: const InputDecoration(
                        labelText: 'Stadt',
                        hintText: 'Musterstadt',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (widget.validator != null) {
                          return widget.validator!('city', value ?? '');
                        }
                        if (value == null || value.isEmpty) {
                          return 'Stadt erforderlich';
                        }
                        if (value.length < 2) {
                          return 'Stadt muss mindestens 2 Zeichen haben';
                        }
                        return null;
                      },
                      onChanged: _updateAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Country
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Land',
                  prefixIcon: Icon(Icons.public_outlined),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (widget.validator != null) {
                    return widget.validator!('country', value ?? '');
                  }
                  if (value == null || value.isEmpty) {
                    return 'Land ist erforderlich';
                  }
                  return null;
                },
                onChanged: _updateAddress,
              ),

              const SizedBox(height: 16),

              // Delivery Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lieferzeit: 3-5 Werktage nach Zahlungsbestätigung',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAddress([String? _]) {
    if (_formKey.currentState?.validate() == true) {
      final address = {
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
      };
      
      // Only notify if all fields are filled
      if (address.values.every((value) => value.isNotEmpty)) {
        widget.onAddressChanged(address);
      }
    }
  }
}