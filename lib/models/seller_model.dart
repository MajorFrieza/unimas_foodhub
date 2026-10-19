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
  final double? latitude;
  final double? longitude;
  final String cuisineType;
  final double rating;
  final Map<String, Map<String, dynamic>>? operatingHours;
  final String? paymentQrUrl;
  final DateTime createdAt;

  static const dayKeys = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
  ];
  static const dayLabels = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const dayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  SellerModel({
    required this.uid,
    required this.stallName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.description,
    required this.isOpen,
    this.imageUrl,
    this.paymentQrUrl,
    this.location,
    this.latitude,
    this.longitude,
    this.cuisineType = 'Others',
    this.rating = 0.0,
    this.operatingHours,
    required this.createdAt,
  });

  static String _currentDayKey() => dayKeys[DateTime.now().weekday - 1];

  static int _parseMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String formatDisplayTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$h:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time24;
    }
  }

  bool get isEffectivelyOpen {
    if (!isOpen) return false;
    if (operatingHours == null) return true;
    final day = operatingHours![_currentDayKey()];
    if (day == null || day['isOpen'] != true) return false;
    try {
      final now = DateTime.now();
      final current = now.hour * 60 + now.minute;
      final from = _parseMinutes(day['openFrom'] as String? ?? '00:00');
      final until = _parseMinutes(day['openUntil'] as String? ?? '23:59');
      return current >= from && current < until;
    } catch (_) {
      return isOpen;
    }
  }

  String get openStatusText {
    if (operatingHours == null) return isOpen ? 'Open' : 'Closed';
    final day = operatingHours![_currentDayKey()];
    if (!isOpen || day == null || day['isOpen'] != true) return 'Closed';
    final until = day['openUntil'] as String? ?? '';
    if (isEffectivelyOpen) return 'Open · Closes ${formatDisplayTime(until)}';
    final from = day['openFrom'] as String? ?? '';
    return 'Closed · Opens ${formatDisplayTime(from)}';
  }

  factory SellerModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    Map<String, Map<String, dynamic>>? hours;
    if (map['operatingHours'] != null) {
      final raw = map['operatingHours'] as Map<dynamic, dynamic>;
      hours = {};
      for (final key in raw.keys) {
        final v = raw[key] as Map<dynamic, dynamic>;
        hours[key.toString()] = {
          'isOpen': v['isOpen'] ?? false,
          'openFrom': v['openFrom'] ?? '08:00',
          'openUntil': v['openUntil'] ?? '17:00',
        };
      }
    } else if (map['openFrom'] != null || map['openUntil'] != null) {
      // Backward compat: build uniform schedule from old single time range
      final from = map['openFrom'] ?? '08:00';
      final until = map['openUntil'] ?? '17:00';
      hours = {
        for (final d in dayKeys)
          d: {'isOpen': true, 'openFrom': from, 'openUntil': until},
      };
    }
    return SellerModel(
      uid: uid,
      stallName: map['stallName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      description: map['description'] ?? '',
      isOpen: map['isOpen'] ?? false,
      imageUrl: map['imageUrl'],
      paymentQrUrl: map['paymentQrUrl'],
      location: map['location'],
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      cuisineType: map['cuisineType'] ?? 'Others',
      rating: (map['rating'] ?? 0.0).toDouble(),
      operatingHours: hours,
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
      'paymentQrUrl': paymentQrUrl,
      'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'cuisineType': cuisineType,
      'rating': rating,
      if (operatingHours != null) 'operatingHours': operatingHours,
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
    String? paymentQrUrl,
    String? location,
    double? latitude,
    double? longitude,
    String? cuisineType,
    double? rating,
    Map<String, Map<String, dynamic>>? operatingHours,
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
      paymentQrUrl: paymentQrUrl ?? this.paymentQrUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cuisineType: cuisineType ?? this.cuisineType,
      rating: rating ?? this.rating,
      operatingHours: operatingHours ?? this.operatingHours,
      createdAt: createdAt,
    );
  }
}
