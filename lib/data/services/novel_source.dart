import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'base_source.dart';
import '../models/source_model.dart';
import 'package:flutter/foundation.dart';

class NovelSource implements BaseSource {
  static const String baseUrl = 'https://freewebnovel.com';

  @override
  String get id => 'novels';

  @override
  String get name => 'FreeWebNovel';

  @override
  String get iconEmoji => '📖';

  @override
  String get language => 'English';

  @override
  bool get isOfficial => false;

  @override
  List<String> get contentTypes => ['Novel', 'Light Novel'];

  Map<String, String> get _headers => {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Referer': '$baseUrl/',
  };

  @override
  Future<List<SourceBook>> getPopular({int page = 1}) async {
    try {
      final url = page == 1 
          ? '$baseUrl/most-popular-novels.html' 
          : '$baseUrl/most-popular-novels/$page.html';
          
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var items = document.querySelectorAll('.ul-list1 .li-row');
        
        final List<SourceBook> books = [];
        for (var item in items) {
          var titleElement = item.querySelector('.tit a');
          if (titleElement == null) continue;
          
          var title = titleElement.text.trim();
          var path = titleElement.attributes['href'] ?? '';
          if (path.isEmpty) continue;
          
          // ID should be the filename without .html, e.g. /the-novel-name.html -> the-novel-name
          var bookId = path.split('/').last.replaceAll('.html', '');

          var img = item.querySelector('.pic img');
          var cover = img?.attributes['src'] ?? '';
          if (cover.isNotEmpty && !cover.startsWith('http')) {
            cover = '$baseUrl$cover';
          }
          
          books.add(SourceBook(
            id: bookId,
            title: title,
            coverUrl: cover,
            sourceId: id,
            type: 'Novel',
          ));
        }
        debugPrint('NovelSource: Found ${books.length} popular novels');
        return books;
      }
    } catch (e) {
      debugPrint('NovelSource getPopular error: $e');
    }
    return [];
  }

  @override
  Future<List<SourceBook>> getLatest({int page = 1}) async {
    try {
      final url = page == 1 
          ? '$baseUrl/latest-release-novels/' 
          : '$baseUrl/latest-release-novels/$page/';
          
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var items = document.querySelectorAll('.ul-list1 .li-row');
        
        final List<SourceBook> books = [];
        for (var item in items) {
          var titleElement = item.querySelector('.tit a');
          if (titleElement == null) continue;
          
          var title = titleElement.text.trim();
          var path = titleElement.attributes['href'] ?? '';
          var bookId = path.split('/').last.replaceAll('.html', '');

          var img = item.querySelector('.pic img');
          var cover = img?.attributes['src'] ?? '';
          if (cover.isNotEmpty && !cover.startsWith('http')) {
            cover = '$baseUrl$cover';
          }
          
          books.add(SourceBook(
            id: bookId,
            title: title,
            coverUrl: cover,
            sourceId: id,
            type: 'Novel',
          ));
        }
        return books;
      }
    } catch (e) {
      debugPrint('NovelSource getLatest error: $e');
    }
    return [];
  }

  @override
  Future<List<SourceBook>> search(String query, {int page = 1}) async {
    try {
      // FreeWebNovel search is a POST request
      final response = await http.post(
        Uri.parse('$baseUrl/search/'),
        headers: _headers,
        body: {'searchkey': query},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var items = document.querySelectorAll('.ul-list1 .li-row');
        
        final List<SourceBook> books = [];
        for (var item in items) {
          var titleElement = item.querySelector('.tit a');
          if (titleElement == null) continue;
          
          var title = titleElement.text.trim();
          var path = titleElement.attributes['href'] ?? '';
          var bookId = path.split('/').last.replaceAll('.html', '');

          var img = item.querySelector('.pic img');
          var cover = img?.attributes['src'] ?? '';
          if (cover.isNotEmpty && !cover.startsWith('http')) {
            cover = '$baseUrl$cover';
          }
          
          books.add(SourceBook(
            id: bookId,
            title: title,
            coverUrl: cover,
            sourceId: id,
            type: 'Novel',
          ));
        }
        return books;
      }
    } catch (e) {
      debugPrint('NovelSource search error: $e');
    }
    return [];
  }

  @override
  Future<List<SourceChapter>> getChapters(String bookId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$bookId.html'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var document = parse(response.body);
        
        // Chapters are often in a list with class .m-newest2 or similar
        var items = document.querySelectorAll('.m-newest2 ul li a');
        if (items.isEmpty) {
          items = document.querySelectorAll('ul.chapter-list li a');
        }
        
        return items.map((item) {
          var title = item.attributes['title'] ?? item.text.trim();
          var path = item.attributes['href'] ?? '';
          // chapterId should be book-name/chapter-name
          var chapterId = path.replaceAll('.html', '');
          if (chapterId.startsWith('/')) {
            chapterId = chapterId.substring(1);
          }
          
          return SourceChapter(
            id: chapterId,
            title: title,
            sourceId: id,
          );
        }).where((c) => c.id.isNotEmpty).toList();
      }
    } catch (e) {
      debugPrint('NovelSource getChapters error: $e');
    }
    return [];
  }

  @override
  Future<List<String>> getPages(String chapterId) async {
    try {
      // chapterId is already the path like book-name/chapter-1
      final response = await http.get(
        Uri.parse('$baseUrl/$chapterId.html'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var content = document.querySelector('.txtwrap') ?? 
                      document.querySelector('#content') ??
                      document.querySelector('.chapter-content');

        if (content != null) {
          // Remove unwanted elements
          content.querySelectorAll('script, .ads, .ads-container, .hidden, style, .bottom-link').forEach((e) => e.remove());
          return [content.innerHtml];
        }
      }
    } catch (e) {
      debugPrint('NovelSource getPages error: $e');
    }
    return [];
  }
}
