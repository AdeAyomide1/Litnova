import 'base_source.dart';
import '../models/source_model.dart';

class TapasSource implements BaseSource {
  @override
  String get id => 'tapas';

  @override
  String get name => 'Tapas';

  @override
  String get iconEmoji => '🌟';

  @override
  String get language => 'English';

  @override
  bool get isOfficial => true;

  @override
  List<String> get contentTypes => ['Webcomic', 'Novel'];

  final List<Map<String, dynamic>> _mockTapas = [
    {
      'id': 'tp_beginning_after_end',
      'title': 'The Beginning After The End',
      'author': 'TurtleMe',
      'genre': 'Fantasy',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/6/62/Pepper%26Carrot_tp_episode_01_page_01.jpg',
      'description': 'King Grey has unrivaled strength, wealth, and prestige in a world governed by martial ability.',
    },
    {
      'id': 'tp_solo_leveling',
      'title': 'Solo Leveling',
      'author': 'Chugong',
      'genre': 'Action',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Pepper%26Carrot_tp_episode_01_page_02.jpg',
      'description': 'In a world where hunters must battle deadly monsters to protect humanity, Jinwoo Sung is the weakest of them all.',
    },
    {
      'id': 'tp_magical_boy',
      'title': 'Magical Boy',
      'author': 'The Kao',
      'genre': 'Comedy',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/c/c5/Pepper%26Carrot_tp_episode_01_page_03.jpg',
      'description': 'Max is just your average trans guy trying to get through high school...',
    },
    {
      'id': 'tp_villainess',
      'title': 'Villains Are Destined to Die',
      'author': 'Gwon Gyeoeul',
      'genre': 'Romance',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/2/23/Pepper%26Carrot_tp_episode_01_page_04.jpg',
      'description': 'I reincarnated into an otome game as the villainess who is destined to die!',
    },
  ];

  @override
  Future<List<SourceBook>> getPopular({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockTapas.map((c) => SourceBook(
      id: c['id'] as String,
      title: c['title'] as String,
      coverUrl: c['cover'] as String,
      description: c['description'] as String,
      author: c['author'] as String,
      genre: c['genre'] as String,
      status: 'Ongoing',
      sourceId: id,
      type: 'Webcomic',
    )).toList();
  }

  @override
  Future<List<SourceBook>> getLatest({int page = 1}) async {
    return getPopular(page: page);
  }

  @override
  Future<List<SourceBook>> search(String query, {int page = 1}) async {
    final results = _mockTapas.where((c) =>
    (c['title'] as String).toLowerCase().contains(query.toLowerCase()) ||
        (c['author'] as String).toLowerCase().contains(query.toLowerCase())
    ).toList();

    return results.map((c) => SourceBook(
      id: c['id'] as String,
      title: c['title'] as String,
      coverUrl: c['cover'] as String,
      description: c['description'] as String,
      author: c['author'] as String,
      genre: c['genre'] as String,
      status: 'Ongoing',
      sourceId: id,
      type: 'Webcomic',
    )).toList();
  }

  @override
  Future<List<SourceChapter>> getChapters(String bookId) async {
    return List.generate(20, (i) => SourceChapter(
      id: '${bookId}_ep${20 - i}',
      title: 'Episode ${20 - i}',
      chapterNumber: '${20 - i}',
      publishedAt: DateTime.now()
          .subtract(Duration(days: i * 7))
          .toIso8601String(),
      sourceId: id,
      externalUrl: 'https://tapas.io/', 
    ));
  }

  @override
  Future<List<String>> getPages(String chapterId) async {
    return [];
  }
}
