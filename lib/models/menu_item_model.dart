class MenuItemModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final String? imageUrl;
  final DateTime createdAt;

  MenuItemModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
    required this.createdAt,
  });

  factory MenuItemModel.fromMap(
      String id, String sellerId, Map<dynamic, dynamic> map) {
    return MenuItemModel(
      id: id,
      sellerId: sellerId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'Others',
      isAvailable: map['isAvailable'] ?? true,
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  MenuItemModel copyWith({
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return MenuItemModel(
      id: id,
      sellerId: sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
    );
  }
}
