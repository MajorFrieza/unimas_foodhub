class SellerModel {
  final String uid;
  final String stallName;
  final String ownerName;
  final String email;
  final String phone;
  final String description;
  final bool isOpen;
  final String? imageUrl;
  final String? location;
  final String cuisineType;
  final double rating;
  final String openFrom;
  final String openUntil;
  final DateTime createdAt;

  SellerModel({
    required this.uid,
    required this.stallName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.description,
    required this.isOpen,
    this.imageUrl,
    this.location,
    this.cuisineType = 'Others',
    this.rating = 0.0,
    this.openFrom = '08:00',
    this.openUntil = '17:00',
    required this.createdAt,
  });

  /// True if the stall is manually open AND current time is within operating hours.
  bool get isEffectivelyOpen {
    if (!isOpen) return false;
    try {
      final now = DateTime.now();
      final current = now.hour * 60 + now.minute;
      final fromParts = openFrom.split(':');
      final untilParts = openUntil.split(':');
      final from = int.parse(fromParts[0]) * 60 + int.parse(fromParts[1]);
      final until = int.parse(untilParts[0]) * 60 + int.parse(untilParts[1]);
      return current >= from && current < until;
    } catch (_) {
      return isOpen;
    }
  }

  factory SellerModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return SellerModel(
      uid: uid,
      stallName: map['stallName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      description: map['description'] ?? '',
      isOpen: map['isOpen'] ?? false,
      imageUrl: map['imageUrl'],
      location: map['location'],
      cuisineType: map['cuisineType'] ?? 'Others',
      rating: (map['rating'] ?? 0.0).toDouble(),
      openFrom: map['openFrom'] ?? '08:00',
      openUntil: map['openUntil'] ?? '17:00',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stallName': stallName,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'description': description,
      'isOpen': isOpen,
      'imageUrl': imageUrl,
      'location': location,
      'cuisineType': cuisineType,
      'rating': rating,
      'openFrom': openFrom,
      'openUntil': openUntil,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'role': 'seller',
    };
  }

  SellerModel copyWith({
    String? stallName,
    String? ownerName,
    String? phone,
    String? description,
    bool? isOpen,
    String? imageUrl,
    String? location,
    String? cuisineType,
    double? rating,
    String? openFrom,
    String? openUntil,
  }) {
    return SellerModel(
      uid: uid,
      stallName: stallName ?? this.stallName,
      ownerName: ownerName ?? this.ownerName,
      email: email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      isOpen: isOpen ?? this.isOpen,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      cuisineType: cuisineType ?? this.cuisineType,
      rating: rating ?? this.rating,
      openFrom: openFrom ?? this.openFrom,
      openUntil: openUntil ?? this.openUntil,
      createdAt: createdAt,
    );
  }
}
