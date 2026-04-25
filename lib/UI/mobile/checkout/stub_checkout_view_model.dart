import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

import '../../../data/providers/cart_provider.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../domain/models/basic_order.dart';

class StubCheckoutViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;
  final CartProvider _cartProvider;
  final DeliveryType deliveryType;
  final double totalAmount;

  StubCheckoutViewModel({
    required PaymentRepository paymentRepository,
    required CartProvider cartProvider,
    required this.deliveryType,
    required this.totalAmount,
  }) : _paymentRepository = paymentRepository,
       _cartProvider = cartProvider;

  bool _isLoading = false;
  String? _errorMessage;
  String? _completedOrderNumber;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get completedOrderNumber => _completedOrderNumber;
  bool get orderPlaced => _completedOrderNumber != null;

  Map<String, dynamic>? _deliveryAddress;

  void setDeliveryAddress(Map<String, dynamic> address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  bool get canPlaceOrder {
    if (_isLoading) return false;
    if (deliveryType == DeliveryType.pickup) return true;

    if (_deliveryAddress == null) return false;
    final required = ['street', 'city', 'postalCode', 'country'];
    return required.every(
      (f) => (_deliveryAddress![f]?.toString().isNotEmpty ?? false),
    );
  }

  Future<void> placeOrder(String userId) async {
    if (!canPlaceOrder) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use the first hike in cart as the primary hike id
      final firstHikeId = _cartProvider.items.first.hike.id;

      final order = await _paymentRepository.createStubOrder(
        hikeId: firstHikeId,
        userId: userId,
        amount: totalAmount,
        deliveryType: deliveryType,
        deliveryAddress: _deliveryAddress,
      );

      _completedOrderNumber = order.orderNumber;
      _cartProvider.clear();
      dev.log('✅ Stub order placed: ${order.orderNumber}');
    } catch (e) {
      _errorMessage = 'Bestellung konnte nicht abgegeben werden. Bitte erneut versuchen.';
      dev.log('❌ Stub order failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? validateField(String field, String value) {
    if (value.isEmpty) return 'Pflichtfeld';
    if (field == 'postalCode' && !RegExp(r'^\d{5}$').hasMatch(value)) {
      return 'Postleitzahl muss 5 Ziffern haben';
    }
    return null;
  }
}
