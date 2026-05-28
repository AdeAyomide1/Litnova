import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.133.172.146:5000/api';
  // Use 10.0.2.2 for Android emulator
  // Use your PC's IP address for real device e.g. http://192.168.1.100:5000/api

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Dio get _dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));

    return dio;
  }

  // Auth
  static Future<Response> register(String name, String email, String password) async {
    return await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  static Future<Response> login(String email, String password) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  static Future<Response> getMe() async {
    return await _dio.get('/auth/me');
  }
  static Future<Response> getChapter(String id) async {
    return await _dio.get('/chapters/$id');
  }
  // Books
  static Future<Response> getAllBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String? type,
  }) async {
    return await _dio.get('/books', queryParameters: {
      'page': page,
      'limit': limit,
      if (genre != null) 'genre': genre,
      if (type != null) 'type': type,
    });
  }

  static Future<Response> getBook(String id) async {
    return await _dio.get('/books/$id');
  }

  static Future<Response> getTrendingBooks() async {
    return await _dio.get('/books/trending');
  }

  static Future<Response> getFeaturedBooks() async {
    return await _dio.get('/books/featured');
  }

  static Future<Response> searchBooks(String query) async {
    return await _dio.get('/books/search', queryParameters: {'q': query});
  }

  static Future<Response> rateBook(String id, int rating, String comment) async {
    return await _dio.post('/books/$id/rate', data: {
      'rating': rating,
      'comment': comment,
    });
  }

  // Chapters
  static Future<Response> getChapters(String bookId) async {
    return await _dio.get('/chapters/book/$bookId');
  }

  static Future<Response> saveProgress(
      String chapterId,
      int page,
      double percentage,
      ) async {
    return await _dio.post('/chapters/$chapterId/progress', data: {
      'page': page,
      'percentage': percentage,
    });
  }

  static Future<Response> getProgress(String chapterId) async {
    return await _dio.get('/chapters/$chapterId/progress');
  }

  // Writers
  static Future<Response> applyAsWriter({
    required String penName,
    required String bio,
    required String genre,
    required String format,
    required String sampleWork,
    String? socialLinks,
    bool hasPublishedBefore = false,
    String? reason,
  }) async {
    return await _dio.post('/writers/apply', data: {
      'pen_name': penName,
      'bio': bio,
      'genre': genre,
      'format': format,
      'sample_work': sampleWork,
      if (socialLinks != null) 'social_links': socialLinks,
      'has_published_before': hasPublishedBefore,
      if (reason != null) 'reason': reason,
    });
  }

  static Future<Response> getApplicationStatus() async {
    return await _dio.get('/writers/application/status');
  }

  static Future<Response> getWriterProfile(String id) async {
    return await _dio.get('/writers/$id');
  }

  static Future<Response> followWriter(String id) async {
    return await _dio.post('/writers/$id/follow');
  }

  static Future<Response> unfollowWriter(String id) async {
    return await _dio.delete('/writers/$id/follow');
  }
  // Writer - Create Book
  static Future<Response> createBook({
    required String title,
    required String description,
    required String genre,
    required String type,
    required String status,
    bool isMature = false,
    String? tags,
  }) async {
    return await _dio.post('/books', data: {
      'title': title,
      'description': description,
      'genre': genre,
      'type': type,
      'status': status,
      'is_mature': isMature,
      if (tags != null) 'tags': tags.split(',').map((t) => t.trim()).toList(),
    });
  }

  // Writer - Create Chapter
  static Future<Response> createChapter({
    required String bookId,
    required String title,
    String? content,
    String type = 'Text',
    String? scheduledAt,
  }) async {
    return await _dio.post('/chapters/book/$bookId', data: {
      'title': title,
      if (content != null) 'content': content,
      'type': type,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
    });
  }

  // Writer - Get my books
  static Future<Response> getMyBooks() async {
    final userId = await AuthService.getUserId();
    return await _dio.get('/writers/$userId/books');
  }

  // Writer - Get my stats
  static Future<Response> getMyStats() async {
    final userId = await AuthService.getUserId();
    return await _dio.get('/writers/$userId/stats');
  }

  // Writer - Update book
  static Future<Response> updateBook({
    required String bookId,
    String? title,
    String? description,
    bool? isPublished,
  }) async {
    return await _dio.put('/books/$bookId', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isPublished != null) 'is_published': isPublished,
    });
  }

  // Writer - Delete book
  static Future<Response> deleteBook(String bookId) async {
    return await _dio.delete('/books/$bookId');
  }

  // Writer - Delete chapter
  static Future<Response> deleteChapter(String chapterId) async {
    return await _dio.delete('/chapters/$chapterId');
  }
  static Future<Response> updateProfile({
    String? name,
    String? username,
    String? bio,
  }) async {
    return await _dio.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (username != null) 'username': username,
      if (bio != null) 'bio': bio,
    });
  }
}
