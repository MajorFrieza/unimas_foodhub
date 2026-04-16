class MenuItemModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final bool isPopular;
  final String? imageUrl;
  final int prepTime;
  final int calories;
  final DateTime createdAt;

  MenuItemModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.isPopular = false,
    this.imageUrl,
    this.prepTime = 15,
    this.calories = 0,
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
      isPopular: map['isPopular'] ?? false,
      imageUrl: map['imageUrl'],
      prepTime: (map['prepTime'] ?? 15) as int,
      calories: (map['calories'] ?? 0) as int,
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
      'isPopular': isPopular,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'calories': calories,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  MenuItemModel copyWith({
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isAvailable,
    bool? isPopular,
    String? imageUrl,
    int? prepTime,
    int? calories,
  }) {
    return MenuItemModel(
      id: id,
      sellerId: sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTime: prepTime ?? this.prepTime,
      calories: calories ?? this.calories,
      createdAt: createdAt,
    );
  }
}
