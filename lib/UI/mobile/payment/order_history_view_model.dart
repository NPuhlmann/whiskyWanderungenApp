import 'package:flutter/foundation.dart';

import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/basic_order.dart';

/// ViewModel für die Bestellhistorie.
///
/// Hält Lade-, Fehler- und Listenzustand der [OrderHistoryPage]. Die
/// Nutzer-Identität kommt aus dem [UserRepository], nicht aus dem globalen
/// Supabase-Client (ADR-0004).
class OrderHistoryViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;
  final UserRepository _userRepository;

  OrderHistoryViewModel({
    required PaymentRepository paymentRepository,
    required UserRepository userRepository,
  }) : _paymentRepository = paymentRepository,
       _userRepository = userRepository;

  List<BasicOrder> _orders = const [];
  bool _isLoading = true;
  String? _errorMessage;

  List<BasicOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    _notify();

    try {
      final userId = _userRepository.getUserId();
      if (userId == null) {
        throw Exception('Benutzer nicht angemeldet');
      }
      _orders = await _paymentRepository.getUserOrders(userId);
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Bestellhistorie: $e';
      _orders = const [];
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // Der Ladevorgang kann das ViewModel überleben, wenn der Nutzer die Seite
  // während des Requests verlässt; notifyListeners auf einem disposed
  // ChangeNotifier wirft (vgl. CheckoutViewModel).
  bool _disposed = false;

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
