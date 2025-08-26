import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

import '../../data/repositories/payment_repository.dart';
import '../../domain/models/basic_order.dart';
import '../../domain/models/basic_payment_result.dart';

/// ViewModel for managing checkout state and payment processing
class CheckoutViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;
  final BasicOrder _order;

  CheckoutViewModel({
    required PaymentRepository paymentRepository,
    required BasicOrder order,
  })  : _paymentRepository = paymentRepository,
        _order = order;

  // State properties
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedPaymentMethod;
  Map<String, dynamic>? _deliveryAddress;
  bool _paymentSuccess = false;
  int? _completedOrderId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  Map<String, dynamic>? get deliveryAddress => _deliveryAddress;
  bool get paymentSuccess => _paymentSuccess;
  int? get completedOrderId => _completedOrderId;
  BasicOrder get order => _order;

  /// Check if payment can be processed
  bool get canProcessPayment {
    if (_isLoading) return false;
    if (_selectedPaymentMethod == null || _selectedPaymentMethod!.isEmpty) return false;
    
    // For shipping orders, delivery address is required
    if (_order.deliveryType == DeliveryType.shipping) {
      if (_deliveryAddress == null) return false;
      
      // Check required address fields
      final requiredFields = ['street', 'city', 'postalCode', 'country'];
      for (final field in requiredFields) {
        if (_deliveryAddress![field] == null || 
            _deliveryAddress![field].toString().isEmpty) {
          return false;
        }
      }
    }
    
    return true;
  }

  /// Set selected payment method
  void setPaymentMethod(String paymentMethodId) {
    _selectedPaymentMethod = paymentMethodId;
    dev.log('💳 Payment method selected: $paymentMethodId');
    notifyListeners();
  }

  /// Set delivery address (for shipping orders)
  void setDeliveryAddress(Map<String, dynamic> address) {
    _deliveryAddress = address;
    dev.log('📍 Delivery address updated: ${address['city']}');
    notifyListeners();
  }

  /// Update specific address field
  void updateAddressField(String field, String value) {
    _deliveryAddress ??= {};
    _deliveryAddress![field] = value;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    dev.log('🧹 Error message cleared');
    notifyListeners();
  }

  /// Process payment
  Future<void> processPayment() async {
    if (!canProcessPayment) {
      _setError('Bitte füllen Sie alle erforderlichen Felder aus');
      return;
    }

    _setLoading(true);
    clearError();

    try {
      dev.log('🔄 Processing payment for order ${_order.orderNumber}...');

      // Update order with delivery address if shipping
      BasicOrder orderToProcess = _order;
      if (_order.deliveryType == DeliveryType.shipping && _deliveryAddress != null) {
        orderToProcess = _order.copyWith(deliveryAddress: _deliveryAddress);
      }

      // Process payment through repository
      final paymentResult = await _paymentRepository.processPayment(
        order: orderToProcess,
        paymentMethodId: _selectedPaymentMethod!,
        metadata: {
          'source': 'mobile_checkout',
          'delivery_type': _order.deliveryType.name,
          'order_number': _order.orderNumber,
        },
      );

      // Handle payment result
      if (paymentResult.isSuccess) {
        _paymentSuccess = true;
        _completedOrderId = _order.id;
        dev.log('✅ Payment successful for order ${_order.orderNumber}');
      } else if (paymentResult.requiresUserAction) {
        _setError('Zusätzliche Authentifizierung erforderlich. Bitte versuchen Sie es erneut.');
        dev.log('🔐 Payment requires additional authentication');
      } else if (paymentResult.wasCancelled) {
        _setError('Zahlung wurde abgebrochen');
        dev.log('❌ Payment was cancelled');
      } else {
        // Use friendly error message from payment result
        final friendlyError = paymentResult.friendlyErrorMessage;
        _setError(friendlyError);
        dev.log('❌ Payment failed: ${paymentResult.errorMessage}');
      }

    } catch (e) {
      _setError('Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.');
      dev.log('❌ Payment processing error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Validate delivery address
  String? validateAddressField(String field, String value) {
    if (value.isEmpty) {
      switch (field) {
        case 'street':
          return 'Straße ist erforderlich';
        case 'city':
          return 'Stadt ist erforderlich';
        case 'postalCode':
          return 'Postleitzahl ist erforderlich';
        case 'country':
          return 'Land ist erforderlich';
        default:
          return 'Dieses Feld ist erforderlich';
      }
    }

    // Specific validation
    switch (field) {
      case 'postalCode':
        // German postal code validation (5 digits)
        if (!RegExp(r'^\d{5}$').hasMatch(value)) {
          return 'Postleitzahl muss 5 Ziffern haben';
        }
        break;
      case 'street':
        if (value.length < 3) {
          return 'Straße muss mindestens 3 Zeichen haben';
        }
        break;
      case 'city':
        if (value.length < 2) {
          return 'Stadt muss mindestens 2 Zeichen haben';
        }
        break;
    }

    return null; // Valid
  }

  /// Reset checkout state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _selectedPaymentMethod = null;
    _deliveryAddress = null;
    _paymentSuccess = false;
    _completedOrderId = null;
    dev.log('🔄 Checkout state reset');
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    dev.log('🗑️ CheckoutViewModel disposed');
    super.dispose();
  }
}