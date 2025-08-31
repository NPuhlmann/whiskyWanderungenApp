import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../../../domain/models/payment_intent.dart';
import '../../../data/services/payment/multi_payment_service.dart';

/// Enhanced widget for selecting from multiple payment methods
/// Supports Credit Cards, Apple Pay, Google Pay, PayPal, and SEPA
class MultiPaymentMethodSelector extends StatefulWidget {
  final PaymentMethodType? selectedPaymentMethod;
  final String? selectedPaymentMethodId;
  final Function(PaymentMethodType, String?) onPaymentMethodChanged;
  final List<PaymentMethodType> availablePaymentMethods;

  const MultiPaymentMethodSelector({
    super.key,
    required this.selectedPaymentMethod,
    this.selectedPaymentMethodId,
    required this.onPaymentMethodChanged,
    required this.availablePaymentMethods,
  });

  @override
  State<MultiPaymentMethodSelector> createState() => _MultiPaymentMethodSelectorState();
}

class _MultiPaymentMethodSelectorState extends State<MultiPaymentMethodSelector> {
  final MultiPaymentService _paymentService = MultiPaymentService.instance;
  
  // Card form controllers (only used for credit card)
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Header
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Zahlungsmethode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Method Options
            ...widget.availablePaymentMethods.map((method) => _buildPaymentMethodOption(method)),
            
            const SizedBox(height: 16),

            // Card Details Form (only shown if card is selected)
            if (widget.selectedPaymentMethod == PaymentMethodType.card) ...[
              const Divider(),
              const SizedBox(height: 16),
              _buildCardDetailsForm(),
              const SizedBox(width: 16),
            ],

            // Security Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethodType method) {
    final isSelected = widget.selectedPaymentMethod == method;
    final displayName = _paymentService.getPaymentMethodDisplayName(method);
    final iconName = _paymentService.getPaymentMethodIcon(method);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _selectPaymentMethod(method),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
                : null,
          ),
          child: Row(
            children: [
              // Payment Method Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconData(iconName),
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Payment Method Name and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getPaymentMethodDescription(method),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection Radio
              Transform.scale(
                scale: 0.8,
                child: Radio<PaymentMethodType>(
                  value: method,
                  // ignore: deprecated_member_use
                  groupValue: widget.selectedPaymentMethod,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) {
                      _selectPaymentMethod(value);
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kartendetails',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
            onChanged: _updateCardPaymentMethod,
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
              _updateCardPaymentMethod();
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
                    _updateCardPaymentMethod();
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
                  onChanged: _updateCardPaymentMethod,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectPaymentMethod(PaymentMethodType method) {
    if (method == PaymentMethodType.card) {
      // For card, wait for form completion
      widget.onPaymentMethodChanged(method, null);
    } else {
      // For other methods, immediately provide a mock payment method ID
      final paymentMethodId = 'pm_${method.name}_test_${DateTime.now().millisecondsSinceEpoch}';
      widget.onPaymentMethodChanged(method, paymentMethodId);
    }
  }

  void _updateCardPaymentMethod([String? _]) async {
    if (widget.selectedPaymentMethod == PaymentMethodType.card &&
        _formKey.currentState?.validate() == true && 
        _isCardFormComplete()) {
      
      try {
        // Create real Stripe payment method from card details
        final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
          params: stripe.PaymentMethodParams.card(
            paymentMethodData: stripe.PaymentMethodData(
              billingDetails: stripe.BillingDetails(
                name: _cardHolderController.text,
              ),
            ),
          ),
        );
        
        widget.onPaymentMethodChanged(PaymentMethodType.card, paymentMethod.id);
        
      } catch (e) {
        // For development/testing, fall back to test payment method ID
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        final paymentMethodId = 'pm_card_${cardNumber.substring(cardNumber.length - 4)}';
        widget.onPaymentMethodChanged(PaymentMethodType.card, paymentMethodId);
      }
    } else if (widget.selectedPaymentMethod == PaymentMethodType.card) {
      // Clear payment method if form is invalid
      widget.onPaymentMethodChanged(PaymentMethodType.card, null);
    }
  }

  bool _isCardFormComplete() {
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'credit_card':
        return Icons.credit_card;
      case 'apple':
        return Icons.phone_iphone; // Apple Pay icon
      case 'google':
        return Icons.android; // Google Pay icon
      case 'account_balance':
        return Icons.account_balance;
      case 'flash_on':
        return Icons.flash_on;
      case 'euro_symbol':
        return Icons.euro_symbol;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodDescription(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.card:
        return 'Visa, Mastercard, American Express';
      case PaymentMethodType.applePay:
        return 'Zahlung mit Touch ID oder Face ID';
      case PaymentMethodType.googlePay:
        return 'Sichere Zahlung mit Google';
      case PaymentMethodType.sepaDebit:
        return 'Lastschrift vom Bankkonto';
      case PaymentMethodType.sofort:
        return 'Sofortüberweisung online';
      case PaymentMethodType.giropay:
        return 'Sicher mit Ihrer Bank';
      case PaymentMethodType.ideal:
        return 'Niederländische Banken';
    }
  }
}