import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as dev;

import '../../../data/repositories/payment_repository.dart';
import '../../../domain/models/basic_order.dart';
import '../../../domain/models/basic_payment_result.dart';
import '../../../domain/models/payment_intent.dart';
import '../../../config/routing/routes.dart';

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
  bool _isInitializing = false;
  String? _errorMessage;
  PaymentMethodType? _selectedPaymentMethod;
  String? _selectedPaymentMethodId;
  List<PaymentMethodType> _availablePaymentMethods = [];
  Map<String, dynamic>? _deliveryAddress;
  bool _paymentSuccess = false;
  int? _completedOrderId;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  PaymentMethodType? get selectedPaymentMethod => _selectedPaymentMethod;
  String? get selectedPaymentMethodId => _selectedPaymentMethodId;
  List<PaymentMethodType> get availablePaymentMethods => _availablePaymentMethods;
  Map<String, dynamic>? get deliveryAddress => _deliveryAddress;
  bool get paymentSuccess => _paymentSuccess;
  int? get completedOrderId => _completedOrderId;
  BasicOrder get order => _order;

  /// Check if payment can be processed
  bool get canProcessPayment {
    if (_isLoading || _isInitializing) return false;
    if (_selectedPaymentMethod == null) return false;
    
    // For card payments, payment method ID is required
    if (_selectedPaymentMethod == PaymentMethodType.card && 
        (_selectedPaymentMethodId == null || _selectedPaymentMethodId!.isEmpty)) {
      return false;
    }
    
    // For shipping orders, delivery address is required
    if (_order.deliveryType == DeliveryType.standardShipping || _order.deliveryType == DeliveryType.expressShipping) {
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

  /// Initialize payment methods when ViewModel is created
  Future<void> initialize() async {
    _setInitializing(true);
    try {
      dev.log('🔄 Initializing payment methods...');
      _availablePaymentMethods = await _paymentRepository.getAvailablePaymentMethods();
      dev.log('✅ Payment methods initialized: ${_availablePaymentMethods.map((m) => m.name).join(', ')}');
    } catch (e) {
      dev.log('❌ Failed to initialize payment methods: $e');
      _setError('Fehler beim Laden der Zahlungsmethoden');
    } finally {
      _setInitializing(false);
    }
  }

  /// Set selected payment method
  void setPaymentMethod(PaymentMethodType paymentMethod, String? paymentMethodId) {
    _selectedPaymentMethod = paymentMethod;
    _selectedPaymentMethodId = paymentMethodId;
    dev.log('💳 Payment method selected: ${paymentMethod.name} (ID: $paymentMethodId)');
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
      if ((_order.deliveryType == DeliveryType.standardShipping || _order.deliveryType == DeliveryType.expressShipping) && _deliveryAddress != null) {
        orderToProcess = _order.copyWith(deliveryAddress: _deliveryAddress);
      }

      // Process payment through repository with new multi-payment API
      final paymentResult = await _paymentRepository.processPayment(
        order: orderToProcess,
        paymentMethod: _selectedPaymentMethod!,
        paymentMethodId: _selectedPaymentMethodId,
        metadata: {
          'source': 'mobile_checkout',
          'delivery_type': _order.deliveryType.name,
          'order_number': _order.orderNumber,
          'payment_method_type': _selectedPaymentMethod!.name,
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

  /// Navigate to order tracking page after successful payment
  void navigateToOrderTracking(BuildContext context) {
    if (_paymentSuccess && _completedOrderId != null) {
      dev.log('📍 Navigating to order tracking for order $_completedOrderId');
      context.go('${Routes.orderTracking}/$_completedOrderId');
    } else {
      dev.log('⚠️ Cannot navigate to order tracking: payment not successful or order ID missing');
    }
  }

  /// Navigate to payment success page (alternative)
  void navigateToPaymentSuccess(BuildContext context) {
    if (_paymentSuccess) {
      dev.log('📍 Navigating to payment success page');
      context.go('${Routes.paymentSuccess}?orderNumber=${_order.orderNumber}');
    } else {
      dev.log('⚠️ Cannot navigate to payment success: payment not successful');
    }
  }

  /// Navigate to order history page
  void navigateToOrderHistory(BuildContext context) {
    dev.log('📍 Navigating to order history');
    context.go(Routes.orderHistory);
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

  void _setInitializing(bool initializing) {
    _isInitializing = initializing;
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