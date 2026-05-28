import 'base_source.dart';
import '../models/source_model.dart';
import 'api_service.dart';

class LitNovaSource implements BaseSource {
  @override
  String get id => 'litnova';

  @override
  String get name => 'LitNOVA Originals';

  @override
  String get iconEmoji => '📖';

  @override
  String get language => 'English';

  @override
  bool get isOfficial => true;

  @override
  List<String> get contentTypes => [
    'Novel', 'Manga', 'Comic', 'Webtoon', 'Audio Story'
  ];

  @override
  Future<List<SourceBook>> getPopular({int page = 1}) async {
    try {
      final response = await ApiService.getTrendingBooks();
      if (response.statusCode == 200) {
        final books = response.data['data']['books'] as List;
        return books.map((b) => SourceBook(
          id: b['id'],
          title: b['title'],
          coverUrl: b['cover_url'],
          description: b['description'],
          author: b['author_name'],
          genre: b['genre'],
          status: b['status'],
          sourceId: id,
          type: b['type'],
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SourceBook>> getLatest({int page = 1}) async {
    try {
      final response = await ApiService.getAllBooks(page: page);
      if (response.statusCode == 200) {
        final books = response.data['data']['books'] as List;
        return books.map((b) => SourceBook(
          id: b['id'],
          title: b['title'],
          coverUrl: b['cover_url'],
          description: b['description'],
          author: b['author_name'],
          genre: b['genre'],
          status: b['status'],
          sourceId: id,
          type: b['type'],
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SourceBook>> search(String query, {int page = 1}) async {
    try {
      final response = await ApiService.searchBooks(query);
      if (response.statusCode == 200) {
        final books = response.data['data']['books'] as List;
        return books.map((b) => SourceBook(
          id: b['id'],
          title: b['title'],
          coverUrl: b['cover_url'],
          description: b['description'],
          author: b['author_name'],
          genre: b['genre'],
          status: b['status'],
          sourceId: id,
          type: b['type'],
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SourceChapter>> getChapters(String bookId) async {
    try {
      final response = await ApiService.getChapters(bookId);
      if (response.statusCode == 200) {
        final chapters = response.data['data']['chapters'] as List;
        return chapters.map((c) => SourceChapter(
          id: c['id'],
          title: c['title'],
          chapterNumber: c['chapter_number']?.toString(),
          publishedAt: c['created_at'],
          sourceId: id,
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getPages(String chapterId) async {
    return [];
  }
}
