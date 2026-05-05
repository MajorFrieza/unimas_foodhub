class OrderItemSnapshot {
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItemSnapshot({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemSnapshot.fromMap(String itemId, Map<dynamic, dynamic> map) {
    return OrderItemSnapshot(
      itemId: itemId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String sellerId;
  final String stallName;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String pickupCode;
  final List<OrderItemSnapshot> items;
  final String? note;
  final int? rating;
  final String? comment;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.sellerId,
    required this.stallName,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.pickupCode,
    required this.items,
    this.note,
    this.rating,
    this.comment,
  });

  factory OrderModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final itemsMap = map['items'] as Map<dynamic, dynamic>? ?? {};
    final items = itemsMap.entries.map((entry) {
      return OrderItemSnapshot.fromMap(
          entry.key.toString(), entry.value as Map<dynamic, dynamic>);
    }).toList();

    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      stallName: map['stallName'] ?? '',
      status: map['status'] ?? 'pending',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      pickupCode: map['pickupCode'] ?? '',
      items: items,
      note: map['note'],
      rating: map['rating'] != null ? (map['rating'] as num).toInt() : null,
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    final itemsMap = <String, dynamic>{};
    for (final item in items) {
      itemsMap[item.itemId] = item.toMap();
    }

    return {
      'customerId': customerId,
      'customerName': customerName,
      'sellerId': sellerId,
      'stallName': stallName,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'pickupCode': pickupCode,
      'items': itemsMap,
      'note': note,
      if (rating != null) 'rating': rating,
      if (comment != null) 'comment': comment,
    };
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      sellerId: sellerId,
      stallName: stallName,
      status: status ?? this.status,
      totalAmount: totalAmount,
      createdAt: createdAt,
      pickupCode: pickupCode,
      items: items,
      note: note,
      rating: rating,
      comment: comment,
    );
  }
}
