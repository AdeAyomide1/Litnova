import '../models/source_model.dart';

abstract class BaseSource {
  String get id;
  String get name;
  String get iconEmoji;
  String get language;
  bool get isOfficial;
  List<String> get contentTypes;

  Future<List<SourceBook>> getPopular({int page = 1});
  Future<List<SourceBook>> getLatest({int page = 1});
  Future<List<SourceBook>> search(String query, {int page = 1});
  Future<List<SourceChapter>> getChapters(String bookId);
  Future<List<String>> getPages(String chapterId);
}
