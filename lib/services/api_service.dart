import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/review.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080'; // 실제 서버 주소로 변경

  Future<List<Book>> getBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/books'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Book.fromJson(e)).toList();
    } else {
      throw Exception('책 목록을 불러오지 못했습니다');
    }
  }

  Future<Book> getBookDetail(int bookId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/books/$bookId'));
    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('책 상세 정보를 불러오지 못했습니다');
    }
  }

  Future<List<Review>> getBookReviews(int bookId, {int page = 1}) async {
    final response = await http.get(Uri.parse('$baseUrl/api/books/$bookId/reviews?page=$page'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('리뷰를 불러오지 못했습니다');
    }
  }
}
