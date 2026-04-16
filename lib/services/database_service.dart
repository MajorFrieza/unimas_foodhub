import 'package:firebase_database/firebase_database.dart';
import '../models/seller_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // ─── Sellers ──────────────────────────────────────────────────────────────

  Stream<List<SellerModel>> sellersStream() {
    return _db.ref(AppConstants.sellersPath).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries.map((entry) {
        return SellerModel.fromMap(
            entry.key.toString(), entry.value as Map<dynamic, dynamic>);
      }).toList();
    });
  }

  Future<SellerModel?> getSeller(String uid) async {
    final snapshot = await _db.ref('${AppConstants.sellersPath}/$uid').get();
    if (!snapshot.exists) return null;
    return SellerModel.fromMap(uid, snapshot.value as Map<dynamic, dynamic>);
  }

  Future<void> updateSellerIsOpen(String uid, bool isOpen) async {
    await _db.ref('${AppConstants.sellersPath}/$uid/isOpen').set(isOpen);
  }

  Future<void> updateSellerProfile(
      String uid, Map<String, dynamic> updates) async {
    await _db.ref('${AppConstants.sellersPath}/$uid').update(updates);
  }

  Future<void> updateCustomerProfile(
      String uid, Map<String, dynamic> updates) async {
    await _db.ref('${AppConstants.usersPath}/$uid').update(updates);
  }

  Stream<List<String>> favouriteStallIdsStream(String customerId) {
    return _db
        .ref('${AppConstants.usersPath}/$customerId/favorites')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries
          .where((e) => e.value == true)
          .map((e) => e.key.toString())
          .toList();
    });
  }

  Future<bool> isFavoriteStall(String customerId, String sellerId) async {
    final snap = await _db
        .ref('${AppConstants.usersPath}/$customerId/favorites/$sellerId')
        .get();
    return snap.value == true;
  }

  Future<void> setFavoriteStall(
      String customerId, String sellerId, bool value) async {
    if (value) {
      await _db
          .ref('${AppConstants.usersPath}/$customerId/favorites/$sellerId')
          .set(true);
    } else {
      await _db
          .ref('${AppConstants.usersPath}/$customerId/favorites/$sellerId')
          .remove();
    }
  }

  // ─── Menu Items ───────────────────────────────────────────────────────────

  Stream<List<MenuItemModel>> menuItemsStream(String sellerId) {
    return _db
        .ref('${AppConstants.menuItemsPath}/$sellerId')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries.map((entry) {
        return MenuItemModel.fromMap(entry.key.toString(), sellerId,
            entry.value as Map<dynamic, dynamic>);
      }).toList();
    });
  }

  /// Returns all menu items across all sellers as a flat list.
  /// Used for the home screen "Popular Right Now" section.
  Stream<List<MenuItemModel>> allMenuItemsStream() {
    return _db.ref(AppConstants.menuItemsPath).onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final sellersMap = event.snapshot.value as Map<dynamic, dynamic>;
      final items = <MenuItemModel>[];
      for (final sellerEntry in sellersMap.entries) {
        final sellerId = sellerEntry.key.toString();
        final itemsMap = sellerEntry.value as Map<dynamic, dynamic>?;
        if (itemsMap == null) continue;
        for (final itemEntry in itemsMap.entries) {
          items.add(MenuItemModel.fromMap(itemEntry.key.toString(), sellerId,
              itemEntry.value as Map<dynamic, dynamic>));
        }
      }
      return items;
    });
  }

  Future<String> addMenuItem(String sellerId, MenuItemModel item) async {
    final ref = _db.ref('${AppConstants.menuItemsPath}/$sellerId').push();
    await ref.set(item.toMap());
    return ref.key!;
  }

  Future<void> updateMenuItem(
      String sellerId, String itemId, Map<String, dynamic> updates) async {
    await _db
        .ref('${AppConstants.menuItemsPath}/$sellerId/$itemId')
        .update(updates);
  }

  Future<void> deleteMenuItem(String sellerId, String itemId) async {
    await _db
        .ref('${AppConstants.menuItemsPath}/$sellerId/$itemId')
        .remove();
  }

  Future<void> toggleMenuItemAvailability(
      String sellerId, String itemId, bool isAvailable) async {
    await _db
        .ref('${AppConstants.menuItemsPath}/$sellerId/$itemId/isAvailable')
        .set(isAvailable);
  }

  // ─── Orders ───────────────────────────────────────────────────────────────

  Future<String> placeOrder(OrderModel order) async {
    final ref = _db.ref(AppConstants.ordersPath).push();
    await ref.set(order.toMap());
    return ref.key!;
  }

  Stream<OrderModel?> orderStream(String orderId) {
    return _db
        .ref('${AppConstants.ordersPath}/$orderId')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return null;
      return OrderModel.fromMap(
          orderId, event.snapshot.value as Map<dynamic, dynamic>);
    });
  }

  Stream<List<OrderModel>> customerOrdersStream(String customerId) {
    return _db
        .ref(AppConstants.ordersPath)
        .orderByChild('customerId')
        .equalTo(customerId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries
          .map((entry) => OrderModel.fromMap(
              entry.key.toString(), entry.value as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Stream<List<OrderModel>> sellerOrdersStream(String sellerId) {
    return _db
        .ref(AppConstants.ordersPath)
        .orderByChild('sellerId')
        .equalTo(sellerId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.entries
          .map((entry) => OrderModel.fromMap(
              entry.key.toString(), entry.value as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db
        .ref('${AppConstants.ordersPath}/$orderId/status')
        .set(status);
  }

  /// Saves a rating on the order then recalculates the seller's average.
  Future<void> rateOrder(String orderId, String sellerId, int rating) async {
    // 1. Write rating onto the order
    await _db
        .ref('${AppConstants.ordersPath}/$orderId/rating')
        .set(rating);

    // 2. Fetch all orders for this seller and compute average of rated ones
    final snap = await _db
        .ref(AppConstants.ordersPath)
        .orderByChild('sellerId')
        .equalTo(sellerId)
        .get();

    if (!snap.exists) return;
    final map = snap.value as Map<dynamic, dynamic>;
    final ratings = map.values
        .map((v) => (v as Map<dynamic, dynamic>)['rating'])
        .where((r) => r != null)
        .map((r) => (r as num).toDouble())
        .toList();

    if (ratings.isEmpty) return;
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    // 3. Update seller's rating field
    await _db
        .ref('${AppConstants.sellersPath}/$sellerId/rating')
        .set(double.parse(avg.toStringAsFixed(1)));
  }
}
