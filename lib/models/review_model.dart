class ReviewModel {
  final String id;
  final String customerName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  factory ReviewModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ReviewModel(
      id: id,
      customerName: map['customerName'] as String? ?? 'Customer',
      rating: (map['rating'] as num).toInt(),
      comment: map['comment'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
