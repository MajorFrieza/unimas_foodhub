import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
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
        ..sort((a, b) {
          int priority(OrderModel order) {
            if (order.status == AppConstants.statusPending) return 0;
            if (order.status == AppConstants.statusCompleted ||
                order.status == AppConstants.statusCancelled) {
              return 2;
            }
            return 1;
          }

          final statusOrder = priority(a).compareTo(priority(b));
          if (statusOrder != 0) return statusOrder;
          final dateOrder = b.createdAt.compareTo(a.createdAt);
          return dateOrder != 0 ? dateOrder : b.id.compareTo(a.id);
        });
      if (FirebaseAuth.instance.currentUser?.uid == sellerId) {
        unawaited(_syncSellerRating(sellerId, orders));
        unawaited(_syncSellerReviews(sellerId, orders));
      }
      return orders;
    });
  }

  Future<void> _syncSellerReviews(
      String sellerId, List<OrderModel> orders) async {
    final ratedOrders = orders.where((order) => order.rating != null);
    if (ratedOrders.isEmpty) return;

    try {
      final reviewsRef =
          _db.ref('${AppConstants.sellersPath}/$sellerId/reviews');
      final snapshot = await reviewsRef.get();
      final existing = snapshot.value as Map<dynamic, dynamic>? ?? {};
      final missing = <String, dynamic>{};
      for (final order in ratedOrders) {
        if (existing.containsKey(order.id)) continue;
        missing[order.id] = _reviewFromOrder(order).toMap();
      }
      if (missing.isNotEmpty) {
        await reviewsRef.update(missing);
      }
    } catch (error, stackTrace) {
      debugPrint('Could not sync seller reviews: $error\n$stackTrace');
    }
  }

  ReviewModel _reviewFromOrder(
    OrderModel order, {
    int? rating,
    String? comment,
  }) {
    final nameParts = order.customerName.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.firstWhere((name) => name.isNotEmpty,
        orElse: () => 'Customer');
    final orderRating = rating ?? order.rating;
    if (orderRating == null) {
      throw StateError('Cannot publish a review without a rating');
    }
    final reviewComment = (comment ?? order.comment)?.trim();
    return ReviewModel(
      id: order.id,
      customerName: firstName,
      rating: orderRating,
      comment:
          reviewComment == null || reviewComment.isEmpty ? null : reviewComment,
      createdAt: order.createdAt,
    );
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

  /// Returns public reviews for a seller, including ratings without comments.
  Stream<List<ReviewModel>> sellerReviewsStream(String sellerId) {
    return _db
        .ref('${AppConstants.sellersPath}/$sellerId/reviews')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final map = event.snapshot.value as Map<dynamic, dynamic>;
      final reviews = map.entries
          .map((entry) => ReviewModel.fromMap(
              entry.key.toString(), entry.value as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.ref('${AppConstants.ordersPath}/$orderId/status').set(status);
  }

  /// Saves an order rating, then publishes it to the seller's public reviews.
  ///
  /// Returns false when the order rating is saved but the public review write
  /// is denied by rules that have not yet been updated.
  Future<bool> rateOrder(String orderId, int rating, {String? comment}) async {
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

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw StateError('You must be signed in to submit a rating');
    }

    final orderRef = _db.ref('${AppConstants.ordersPath}/$orderId');
    final orderSnapshot = await orderRef.get();
    if (!orderSnapshot.exists) {
      throw StateError('This order could not be found');
    }
    final order = OrderModel.fromMap(
      orderId,
      orderSnapshot.value as Map<dynamic, dynamic>,
    );
    if (order.customerId != userId ||
        order.status != AppConstants.statusCompleted ||
        order.rating != null) {
      throw StateError('This order is not eligible for a new rating');
    }

    final savedComment = trimmedComment?.isNotEmpty == true
        ? trimmedComment
        : order.comment?.trim();
    final review = _reviewFromOrder(
      order,
      rating: rating,
      comment: savedComment,
    );
    final orderUpdates = <String, dynamic>{'rating': rating};
    if (order.comment == null && trimmedComment?.isNotEmpty == true) {
      orderUpdates['comment'] = trimmedComment;
    }
    await orderRef.update(orderUpdates);

    try {
      await _db
          .ref('${AppConstants.sellersPath}/${order.sellerId}/reviews/$orderId')
          .set(review.toMap());
      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'Rating saved for order $orderId, but its public stall review could '
        'not be published: $error\n$stackTrace',
      );
      return false;
    }
  }
}
