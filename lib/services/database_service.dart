import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
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
    await _db.ref('${AppConstants.menuItemsPath}/$sellerId/$itemId').remove();
  }

  Future<void> toggleMenuItemAvailability(
      String sellerId, String itemId, bool isAvailable) async {
    await _db
        .ref('${AppConstants.menuItemsPath}/$sellerId/$itemId/isAvailable')
        .set(isAvailable);
  }

  // ─── Orders ───────────────────────────────────────────────────────────────

  Future<String> placeOrder(OrderModel order) async {
    final orderRef = _db.ref(AppConstants.ordersPath).push();
    await orderRef.set(order.toMap());
    return orderRef.key!;
  }

  Stream<OrderModel?> orderStream(String orderId) {
    return _db.ref('${AppConstants.ordersPath}/$orderId').onValue.map((event) {
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
      final orders = map.entries
          .map((entry) => OrderModel.fromMap(
              entry.key.toString(), entry.value as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (FirebaseAuth.instance.currentUser?.uid == sellerId) {
        unawaited(_syncSellerRating(sellerId, orders));
      }
      return orders;
    });
  }

  Future<void> _syncSellerRating(
      String sellerId, List<OrderModel> orders) async {
    final ratings =
        orders.map((order) => order.rating).whereType<int>().toList();
    if (ratings.isEmpty) return;

    final average = double.parse(
        (ratings.reduce((a, b) => a + b) / ratings.length).toStringAsFixed(1));
    try {
      final ratingRef = _db.ref('${AppConstants.sellersPath}/$sellerId/rating');
      final currentRating = (await ratingRef.get()).value;
      if (currentRating is num && currentRating.toDouble() == average) return;
      await ratingRef.set(average);
    } catch (error, stackTrace) {
      debugPrint('Could not update seller rating: $error\n$stackTrace');
    }
  }

  /// Returns orders for a seller that have both a rating and a comment.
  Stream<List<OrderModel>> sellerReviewsStream(String sellerId) {
    return sellerOrdersStream(sellerId).map((orders) => orders
        .where((o) =>
            o.rating != null &&
            o.comment != null &&
            o.comment!.trim().isNotEmpty)
        .toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.ref('${AppConstants.ordersPath}/$orderId/status').set(status);
  }

  /// Saves a rating and optional comment on a completed order.
  Future<void> rateOrder(String orderId, int rating, {String? comment}) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'Must be between 1 and 5');
    }

    final trimmedComment = comment?.trim();
    if (trimmedComment != null && trimmedComment.length > 200) {
      throw ArgumentError.value(
        comment,
        'comment',
        'Must be 200 characters or fewer',
      );
    }

    final updates = <String, dynamic>{'rating': rating};
    if (trimmedComment != null && trimmedComment.isNotEmpty) {
      updates['comment'] = trimmedComment;
    }
    await _db.ref('${AppConstants.ordersPath}/$orderId').update(updates);
  }
}
