import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class CartProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final Uuid _uuid = const Uuid();

  final List<CartItemModel> _items = [];
  String? _currentSellerId;
  String? _currentStallName;
  bool _isPlacingOrder = false;
  String? _errorMessage;

  List<CartItemModel> get items => List.unmodifiable(_items);
  String? get currentSellerId => _currentSellerId;
  String? get currentStallName => _currentStallName;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // ─── Add to Cart ──────────────────────────────────────────────────────────

  /// Returns false if the item is from a different stall (cart conflict).
  bool addItem(MenuItemModel menuItem, String sellerId, String stallName) {
    // Different stall — cannot mix orders
    if (_currentSellerId != null && _currentSellerId != sellerId) {
      return false;
    }

    _currentSellerId = sellerId;
    _currentStallName = stallName;

    final existingIndex =
        _items.indexWhere((c) => c.menuItem.id == menuItem.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItemModel(menuItem: menuItem));
    }

    notifyListeners();
    return true;
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((c) => c.menuItem.id == menuItemId);
    if (_items.isEmpty) _clearStall();
    notifyListeners();
  }

  void decrementItem(String menuItemId) {
    final index = _items.indexWhere((c) => c.menuItem.id == menuItemId);
    if (index < 0) return;
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
      if (_items.isEmpty) _clearStall();
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _clearStall();
    notifyListeners();
  }

  void _clearStall() {
    _currentSellerId = null;
    _currentStallName = null;
  }

  // ─── Place Order ──────────────────────────────────────────────────────────

  Future<OrderModel?> placeOrder({
    required String customerId,
    required String customerName,
    String? note,
  }) async {
    if (_items.isEmpty || _currentSellerId == null) return null;

    _isPlacingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = OrderModel(
        id: '',
        customerId: customerId,
        customerName: customerName,
        sellerId: _currentSellerId!,
        stallName: _currentStallName ?? '',
        status: AppConstants.statusPending,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        pickupCode:
            '${AppConstants.pickupPrefix}${_uuid.v4().substring(0, 4).toUpperCase()}',
        items: _items
            .map((item) => OrderItemSnapshot(
                  itemId: item.menuItem.id,
                  name: item.menuItem.name,
                  price: item.menuItem.price,
                  quantity: item.quantity,
                  subtotal: item.subtotal,
                ))
            .toList(),
        note: note,
      );
      final placedOrder = await _dbService.placeOrder(
        order,
      );
      clearCart();
      return OrderModel.fromMap(placedOrder, order.toMap());
    } catch (e, stackTrace) {
      debugPrint('Order placement failed: $e\n$stackTrace');
      _errorMessage = 'Unable to place your order. Please try again.';
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
