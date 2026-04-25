import 'hike.dart';

class CartItem {
  final Hike hike;
  final int quantity;

  const CartItem({required this.hike, this.quantity = 1});

  CartItem copyWith({Hike? hike, int? quantity}) => CartItem(
    hike: hike ?? this.hike,
    quantity: quantity ?? this.quantity,
  );

  double get totalPrice => hike.price * quantity;
}
