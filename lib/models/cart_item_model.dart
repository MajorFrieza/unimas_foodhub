import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel menuItem;
  int quantity;

  CartItemModel({
    required this.menuItem,
    this.quantity = 1,
  });

  double get subtotal => menuItem.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
    );
  }
}
