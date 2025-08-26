import 'package:flutter/material.dart';

/// Widget for selecting and configuring payment methods (credit card)
class PaymentMethodSelector extends StatefulWidget {
  final String? selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
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
              // Payment Method Header
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kreditkarte',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card Holder Name
              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Karteninhaber',
                  hintText: 'Max Mustermann',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Karteninhaber ist erforderlich';
                  }
                  if (value.length < 2) {
                    return 'Name muss mindestens 2 Zeichen haben';
                  }
                  return null;
                },
                onChanged: _updatePaymentMethod,
              ),
              const SizedBox(height: 16),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Kartennummer',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kartennummer ist erforderlich';
                  }
                  // Remove spaces for validation
                  final cleanValue = value.replaceAll(' ', '');
                  if (cleanValue.length < 13 || cleanValue.length > 19) {
                    return 'Ungültige Kartennummer';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
                    return 'Kartennummer darf nur Ziffern enthalten';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Format card number with spaces
                  final formatted = _formatCardNumber(value);
                  if (formatted != value) {
                    _cardNumberController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                  _updatePaymentMethod();
                },
              ),
              const SizedBox(height: 16),

              // Expiry and CVV Row
              Row(
                children: [
                  // Expiry Date
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Gültig bis',
                        hintText: 'MM/JJ',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gültigkeitsdatum erforderlich';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'Format: MM/JJ';
                        }
                        
                        // Check if date is in the future
                        final parts = value.split('/');
                        final month = int.tryParse(parts[0]);
                        final year = int.tryParse('20${parts[1]}');
                        
                        if (month == null || year == null || 
                            month < 1 || month > 12) {
                          return 'Ungültiges Datum';
                        }
                        
                        final now = DateTime.now();
                        final expiryDate = DateTime(year, month + 1, 0);
                        
                        if (expiryDate.isBefore(now)) {
                          return 'Karte ist abgelaufen';
                        }
                        
                        return null;
                      },
                      onChanged: (value) {
                        // Format expiry date
                        final formatted = _formatExpiryDate(value);
                        if (formatted != value) {
                          _expiryController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                        _updatePaymentMethod();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // CVV
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CVV erforderlich';
                        }
                        if (value.length < 3 || value.length > 4) {
                          return '3-4 Ziffern';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Nur Ziffern';
                        }
                        return null;
                      },
                      onChanged: _updatePaymentMethod,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ihre Zahlungsdaten werden sicher verschlüsselt übertragen',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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

  void _updatePaymentMethod([String? _]) {
    if (_formKey.currentState?.validate() == true && _isFormComplete()) {
      // Generate a test payment method ID based on card number
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final paymentMethodId = 'pm_test_${cardNumber.substring(cardNumber.length - 4)}';
      widget.onPaymentMethodChanged(paymentMethodId);
    } else {
      // Clear payment method if form is invalid
      if (widget.selectedPaymentMethod != null) {
        widget.onPaymentMethodChanged('');
      }
    }
  }

  bool _isFormComplete() {
    return _cardHolderController.text.isNotEmpty &&
           _cardNumberController.text.isNotEmpty &&
           _expiryController.text.isNotEmpty &&
           _cvvController.text.isNotEmpty;
  }

  String _formatCardNumber(String value) {
    // Remove all non-digit characters
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    
    // Add spaces every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanValue[i]);
    }
    
    return buffer.toString();
  }

  String _formatExpiryDate(String value) {
    // Remove all non-digit characters
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    
    if (cleanValue.length <= 2) {
      return cleanValue;
    } else {
      return '${cleanValue.substring(0, 2)}/${cleanValue.substring(2, cleanValue.length > 4 ? 4 : cleanValue.length)}';
    }
  }
}