import '../models/book_model.dart';
import '../services/api_service.dart';

class BookRepository {
  static Future<List<BookModel>> getTrendingBooks() async {
    try {
      final response = await ApiService.getTrendingBooks();
      if (response.statusCode == 200) {
        final List books = response.data['data']['books'];
        return books.map((b) => BookModel.fromJson(b)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<BookModel>> getFeaturedBooks() async {
    try {
      final response = await ApiService.getFeaturedBooks();
      if (response.statusCode == 200) {
        final List books = response.data['data']['books'];
        return books.map((b) => BookModel.fromJson(b)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<BookModel>> getAllBooks({
    String? genre,
    String? type,
  }) async {
    try {
      final response = await ApiService.getAllBooks(
        genre: genre,
        type: type,
      );
      if (response.statusCode == 200) {
        final List books = response.data['data']['books'];
        return books.map((b) => BookModel.fromJson(b)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<BookModel>> searchBooks(String query) async {
    try {
      final response = await ApiService.searchBooks(query);
      if (response.statusCode == 200) {
        final List books = response.data['data']['books'];
        return books.map((b) => BookModel.fromJson(b)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<BookModel?> getBook(String id) async {
    try {
      final response = await ApiService.getBook(id);
      if (response.statusCode == 200) {
        return BookModel.fromJson(response.data['data']['book']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
