// models/book.dart
import 'review.dart'; // 리뷰 모델 import

class Book {
  final int id;
  final String title;
  final String author;
  final String genre;
  final String year;
  final String overview;
  final String coverUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final String description;
  final List<Review> reviews; // ★ 추가

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.year,
    required this.overview,
    required this.coverUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.description,
    required this.reviews, // ★ 추가
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? '제목 없음',
      author: json['author'] ?? '저자 미상',
      genre: json['genre'] ?? '',
      year: json['year'] ?? '',
      overview: json['overview'] ?? '',
      coverUrl: (json['coverUrl'] == null || json['coverUrl'] == '')
          ? 'assets/images/default.png'
          : json['coverUrl'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(), // ★ 추가
    );
  }
}
