import 'package:flutter/foundation.dart';
import '../models/source_model.dart';
import 'base_source.dart';
import 'mangadex_source.dart';
import 'novel_source.dart';

class SourceManager extends ChangeNotifier {
  static final SourceManager _instance = SourceManager._internal();
  factory SourceManager() => _instance;
  SourceManager._internal();

  final Map<String, BaseSource> _sources = {
    'mangadex': MangaDexSource(),
    'novels': NovelSource(),
  };

  final Set<String> _installedSourceIds = {'mangadex', 'novels'};

  List<SourceModel> get allSources => [
    SourceModel(
      id: 'mangadex',
      name: 'MangaDex',
      description: 'Massive database of fan-translated manga, manhwa, and manhua.',
      iconEmoji: '🦊',
      language: 'English',
      isInstalled: _installedSourceIds.contains('mangadex'),
      isOfficial: false,
      contentTypes: ['Manga', 'Manhwa', 'Manhua'],
    ),
    SourceModel(
      id: 'novels',
      name: 'FreeWebNovel',
      description: 'Massive library of light novels and web novels.',
      iconEmoji: '📖',
      language: 'English',
      isInstalled: _installedSourceIds.contains('novels'),
      isOfficial: false,
      contentTypes: ['Novel', 'Light Novel'],
    ),
  ];

  List<SourceModel> get installedSources =>
      allSources.where((s) => s.isInstalled).toList();

  bool isInstalled(String sourceId) =>
      _installedSourceIds.contains(sourceId);

  void installSource(String sourceId) {
    _installedSourceIds.add(sourceId);
    notifyListeners();
  }

  void uninstallSource(String sourceId) {
    _installedSourceIds.remove(sourceId);
    notifyListeners();
  }

  BaseSource? getSource(String sourceId) => _sources[sourceId];

  Future<List<SourceBook>> getPopularFromSource(
      String sourceId, {
        int page = 1,
      }) async {
    final source = _sources[sourceId];
    if (source == null) return [];
    try {
      final results = await source.getPopular(page: page);
      debugPrint('SourceManager: Fetched ${results.length} popular books from $sourceId');
      return results;
    } catch (e) {
      debugPrint('SourceManager: Error fetching popular from $sourceId: $e');
      return [];
    }
  }

  Future<List<SourceBook>> getAggregatedPopular({int page = 1}) async {
    final results = <SourceBook>[];
    final futures = _installedSourceIds.map((id) => getPopularFromSource(id, page: page));
    final lists = await Future.wait(futures);
    
    for (var list in lists) {
      results.addAll(list);
    }
    
    results.shuffle(); 
    return results;
  }

  Future<List<SourceBook>> getAggregatedLatest({int page = 1}) async {
    final results = <SourceBook>[];
    final futures = _installedSourceIds.map((id) async {
      final source = _sources[id];
      if (source != null) {
        try {
          final list = await source.getLatest(page: page);
          debugPrint('SourceManager: Fetched ${list.length} latest books from $id');
          return list;
        } catch (e) {
          debugPrint('SourceManager: Error fetching latest from $id: $e');
        }
      }
      return <SourceBook>[];
    });
    
    final lists = await Future.wait(futures);
    for (var list in lists) {
      results.addAll(list);
    }
    
    return results;
  }

  Future<List<SourceBook>> searchAllSources(String query) async {
    final results = <SourceBook>[];
    final futures = _installedSourceIds.map((id) async {
      final source = _sources[id];
      if (source != null) {
        try {
          final list = await source.search(query);
          debugPrint('SourceManager: Found ${list.length} results in $id for "$query"');
          return list;
        } catch (e) {
          debugPrint('SourceManager: Error searching in $id: $e');
        }
      }
      return <SourceBook>[];
    });
    
    final lists = await Future.wait(futures);
    for (var list in lists) {
      results.addAll(list);
    }
    return results;
  }

  Future<List<SourceChapter>> getChapters(
      String sourceId,
      String bookId,
      ) async {
    final source = _sources[sourceId];
    if (source == null) return [];
    try {
      return await source.getChapters(bookId);
    } catch (e) {
      debugPrint('SourceManager: Error fetching chapters from $sourceId: $e');
      return [];
    }
  }

  Future<List<String>> getPages(String sourceId, String chapterId) async {
    final source = _sources[sourceId];
    if (source == null) return [];
    try {
      return await source.getPages(chapterId);
    } catch (e) {
      debugPrint('SourceManager: Error fetching content from $sourceId: $e');
      return [];
    }
  }
}
