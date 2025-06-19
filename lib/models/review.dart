class Review {
  final int id;
  final String content;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      content: json['content'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
