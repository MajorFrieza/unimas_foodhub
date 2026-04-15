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
    required this.createdAt,
  });

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
      createdAt: createdAt,
    );
  }
}
