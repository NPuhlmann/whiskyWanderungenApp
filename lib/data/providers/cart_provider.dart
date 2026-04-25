import 'package:flutter/foundation.dart';

import '../../domain/models/cart_item.dart';
import '../../domain/models/hike.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  void addHike(Hike hike) {
    final index = _items.indexWhere((item) => item.hike.id == hike.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    } else {
      _items.add(CartItem(hike: hike));
    }
    notifyListeners();
  }

  void removeHike(int hikeId) {
    _items.removeWhere((item) => item.hike.id == hikeId);
    notifyListeners();
  }

  void updateQuantity(int hikeId, int quantity) {
    if (quantity <= 0) {
      removeHike(hikeId);
      return;
    }
    final index = _items.indexWhere((item) => item.hike.id == hikeId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
