import 'package:hive_flutter/hive_flutter.dart';
import '../models/source_model.dart';

class BookmarkService {
  static const String _bookmarkBoxName = 'bookmarks';
  static const String _historyBoxName = 'history';
  static const String _downloadBoxName = 'downloads';

  static Future<void> init() async {
    await Hive.openBox(_bookmarkBoxName);
    await Hive.openBox(_historyBoxName);
    await Hive.openBox(_downloadBoxName);
  }

  static Future<void> addBookmark(SourceBook book) async {
    final box = Hive.box(_bookmarkBoxName);
    await box.put(book.id, {
      'id': book.id,
      'title': book.title,
      'coverUrl': book.coverUrl,
      'author': book.author,
      'sourceId': book.sourceId,
      'type': book.type,
      'genre': book.genre,
    });
  }

  static Future<void> removeBookmark(String bookId) async {
    final box = Hive.box(_bookmarkBoxName);
    await box.delete(bookId);
  }

  static bool isBookmarked(String bookId) {
    final box = Hive.box(_bookmarkBoxName);
    return box.containsKey(bookId);
  }

  static List<SourceBook> getBookmarks() {
    final box = Hive.box(_bookmarkBoxName);
    return box.values.map((item) {
      final map = Map<String, dynamic>.from(item);
      return SourceBook(
        id: map['id'],
        title: map['title'],
        coverUrl: map['coverUrl'],
        author: map['author'],
        sourceId: map['sourceId'],
        type: map['type'],
        genre: map['genre'],
      );
    }).toList();
  }

  static Future<void> addToHistory(SourceBook book) async {
    final box = Hive.box(_historyBoxName);
    await box.put(book.id, {
      'id': book.id,
      'title': book.title,
      'coverUrl': book.coverUrl,
      'author': book.author,
      'sourceId': book.sourceId,
      'type': book.type,
      'genre': book.genre,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static List<SourceBook> getHistory() {
    final box = Hive.box(_historyBoxName);
    final items = box.values.toList();
    items.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    return items.map((item) {
      final map = Map<String, dynamic>.from(item);
      return SourceBook(
        id: map['id'],
        title: map['title'],
        coverUrl: map['coverUrl'],
        author: map['author'],
        sourceId: map['sourceId'],
        type: map['type'],
        genre: map['genre'],
      );
    }).toList();
  }

  static Future<void> addDownload(SourceBook book) async {
    final box = Hive.box(_downloadBoxName);
    await box.put(book.id, {
      'id': book.id,
      'title': book.title,
      'coverUrl': book.coverUrl,
      'author': book.author,
      'sourceId': book.sourceId,
      'type': book.type,
      'genre': book.genre,
      'downloadedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static List<SourceBook> getDownloads() {
    final box = Hive.box(_downloadBoxName);
    return box.values.map((item) {
      final map = Map<String, dynamic>.from(item);
      return SourceBook(
        id: map['id'],
        title: map['title'],
        coverUrl: map['coverUrl'],
        author: map['author'],
        sourceId: map['sourceId'],
        type: map['type'],
        genre: map['genre'],
      );
    }).toList();
  }
}
