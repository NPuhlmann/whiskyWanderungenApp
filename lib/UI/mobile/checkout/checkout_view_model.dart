import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as dev;

import '../../../data/repositories/purchase_intake_repository.dart';
import '../../../domain/models/basic_order.dart';
import '../../../domain/models/hike.dart';
import '../../../domain/models/payment_intent.dart';
import '../../../config/routing/routes.dart';

/// ViewModel for managing checkout state and payment processing
class CheckoutViewModel extends ChangeNotifier {
  final PurchaseIntakeRepository _purchaseIntakeRepository;
  final Hike _hike;

  CheckoutViewModel({
    required PurchaseIntakeRepository purchaseIntakeRepository,
    required Hike hike,
  }) : _purchaseIntakeRepository = purchaseIntakeRepository,
       _hike = hike;

  // State properties
  bool _isLoading = false;
  bool _isInitializing = false;
  String? _errorMessage;
  PaymentMethodType? _selectedPaymentMethod;
  String? _selectedPaymentMethodId;
  List<PaymentMethodType> _availablePaymentMethods = [];
  Map<String, dynamic>? _deliveryAddress;
  // ponytail: no delivery-type picker in this slice — the tasting set always
  // ships. Add a selector when pickup becomes a real option.
  final DeliveryType _deliveryType = DeliveryType.standardShipping;
  bool _paymentSuccess = false;
  int? _completedOrderId;
  String? _completedOrderNumber;

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  PaymentMethodType? get selectedPaymentMethod => _selectedPaymentMethod;
  String? get selectedPaymentMethodId => _selectedPaymentMethodId;
  List<PaymentMethodType> get availablePaymentMethods =>
      _availablePaymentMethods;
  Map<String, dynamic>? get deliveryAddress => _deliveryAddress;
  bool get paymentSuccess => _paymentSuccess;
  int? get completedOrderId => _completedOrderId;
  String? get completedOrderNumber => _completedOrderNumber;
  Hike get hike => _hike;
  DeliveryType get deliveryType => _deliveryType;

  bool get requiresDeliveryAddress => _deliveryType != DeliveryType.pickup;

  /// Fields the Edge Function needs before it will create an order.
  static const _requiredAddressFields = [
    'firstName',
    'lastName',
    'street',
    'city',
    'postalCode',
    'country',
  ];

  /// Check if payment can be processed
  bool get canProcessPayment {
    if (_isLoading || _isInitializing) return false;
    if (_selectedPaymentMethod == null) return false;

    // For card payments, payment method ID is required
    if (_selectedPaymentMethod == PaymentMethodType.card &&
        (_selectedPaymentMethodId == null ||
            _selectedPaymentMethodId!.isEmpty)) {
      return false;
    }

    if (requiresDeliveryAddress) {
      if (_deliveryAddress == null) return false;
      for (final field in _requiredAddressFields) {
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
      _availablePaymentMethods = await _purchaseIntakeRepository
          .getAvailablePaymentMethods();
      dev.log(
        '✅ Payment methods initialized: '
        '${_availablePaymentMethods.map((m) => m.name).join(', ')}',
      );
    } catch (e) {
      dev.log('❌ Failed to initialize payment methods: $e');
      _setError('Fehler beim Laden der Zahlungsmethoden');
    } finally {
      _setInitializing(false);
    }
  }

  /// Set selected payment method
  void setPaymentMethod(
    PaymentMethodType paymentMethod,
    String? paymentMethodId,
  ) {
    _selectedPaymentMethod = paymentMethod;
    _selectedPaymentMethodId = paymentMethodId;
    dev.log(
      '💳 Payment method selected: ${paymentMethod.name} (ID: $paymentMethodId)',
    );
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

  /// Take the purchase from "Pay" to a paid order.
  Future<void> processPayment() async {
    if (!canProcessPayment) {
      _setError('Bitte füllen Sie alle erforderlichen Felder aus');
      return;
    }

    _setLoading(true);
    clearError();

    try {
      dev.log('🔄 Processing purchase for hike ${_hike.id}...');

      final result = await _purchaseIntakeRepository.intakePurchase(
        hike: _hike,
        deliveryType: _deliveryType,
        deliveryAddress: requiresDeliveryAddress ? _deliveryAddress : null,
        paymentMethod: _selectedPaymentMethod!,
        paymentMethodId: _selectedPaymentMethodId,
        metadata: {
          'source': 'mobile_checkout',
          'delivery_type': _deliveryType.name,
          'payment_method_type': _selectedPaymentMethod!.name,
        },
      );

      if (result.isSuccess) {
        _paymentSuccess = true;
        _completedOrderId = result.orderId;
        _completedOrderNumber = result.orderNumber;
        dev.log('✅ Purchase successful: order ${result.orderNumber}');
      } else {
        _setError(result.message ?? 'Zahlung fehlgeschlagen');
        dev.log('❌ Purchase failed: ${result.reason}');
      }
    } catch (e) {
      _setError(
        'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.',
      );
      dev.log('❌ Payment processing error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Validate delivery address
  String? validateAddressField(String field, String value) {
    if (value.isEmpty) {
      switch (field) {
        case 'firstName':
          return 'Vorname ist erforderlich';
        case 'lastName':
          return 'Nachname ist erforderlich';
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
      case 'firstName':
      case 'lastName':
        if (value.length < 2) {
          return 'Mindestens 2 Zeichen haben';
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
      dev.log(
        '⚠️ Cannot navigate to order tracking: payment not successful or order ID missing',
      );
    }
  }

  /// Navigate to payment success page
  void navigateToPaymentSuccess(BuildContext context) {
    if (_paymentSuccess) {
      dev.log('📍 Navigating to payment success page');
      context.go(
        '${Routes.paymentSuccess}?orderNumber=${_completedOrderNumber ?? ''}',
      );
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
    _completedOrderNumber = null;
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
