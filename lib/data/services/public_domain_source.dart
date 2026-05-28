import 'base_source.dart';
import '../models/source_model.dart';

class PublicDomainSource implements BaseSource {
  @override
  String get id => 'public_domain';

  @override
  String get name => 'Public Domain Comics';

  @override
  String get iconEmoji => '🏛️';

  @override
  String get language => 'English';

  @override
  bool get isOfficial => true; // They are 100% legal to read and redistribute

  @override
  List<String> get contentTypes => ['Classic Comic', 'Golden Age'];

  // A mock version representing Golden Age comics that are now Public Domain
  final List<Map<String, dynamic>> _ccComics = [
    {
      'id': 'pd_action_comics_1',
      'title': 'Action Comics (1938)',
      'author': 'Jerry Siegel, Joe Shuster',
      'genre': 'Superhero',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/6/62/Pepper%26Carrot_tp_episode_01_page_01.jpg',
      'description': 'The debut of Superman (Note: Character may be trademarked, but specific early issues have complex copyright statuses).',
    },
    {
      'id': 'pd_captain_marvel',
      'title': 'Whiz Comics (Captain Marvel)',
      'author': 'Fawcett Publications',
      'genre': 'Superhero',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Pepper%26Carrot_tp_episode_01_page_02.jpg',
      'description': 'Early public domain issues of the original Captain Marvel (Shazam).',
    },
    {
      'id': 'pd_black_terror',
      'title': 'The Black Terror',
      'author': 'Nedor Comics',
      'genre': 'Action',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/c/c5/Pepper%26Carrot_tp_episode_01_page_03.jpg',
      'description': 'The nemesis of crime, a pharmacist who gained superpowers.',
    },
  ];

  @override
  Future<List<SourceBook>> getPopular({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _ccComics.map((c) => SourceBook(
      id: c['id'] as String,
      title: c['title'] as String,
      coverUrl: c['cover'] as String,
      description: c['description'] as String,
      author: c['author'] as String,
      genre: c['genre'] as String,
      status: 'Completed',
      sourceId: id,
      type: 'Classic Comic',
    )).toList();
  }

  @override
  Future<List<SourceBook>> getLatest({int page = 1}) async {
    return getPopular(page: page);
  }

  @override
  Future<List<SourceBook>> search(String query, {int page = 1}) async {
    final results = _ccComics.where((c) =>
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
      status: 'Completed',
      sourceId: id,
      type: 'Classic Comic',
    )).toList();
  }

  @override
  Future<List<SourceChapter>> getChapters(String bookId) async {
    // Public domain comics are often single issues
    return [
      SourceChapter(
        id: '${bookId}_issue1',
        title: 'Issue #1',
        chapterNumber: '1',
        publishedAt: '1940-01-01T00:00:00Z',
        sourceId: id,
      )
    ];
  }

  @override
  Future<List<String>> getPages(String chapterId) async {
    // Return CC-BY Pepper&Carrot pages as a real example
    return [
      'https://upload.wikimedia.org/wikipedia/commons/6/62/Pepper%26Carrot_tp_episode_01_page_01.jpg',
      'https://upload.wikimedia.org/wikipedia/commons/4/4c/Pepper%26Carrot_tp_episode_01_page_02.jpg',
      'https://upload.wikimedia.org/wikipedia/commons/c/c5/Pepper%26Carrot_tp_episode_01_page_03.jpg',
      'https://upload.wikimedia.org/wikipedia/commons/2/23/Pepper%26Carrot_tp_episode_01_page_04.jpg',
      'https://upload.wikimedia.org/wikipedia/commons/f/ff/Pepper%26Carrot_tp_episode_01_page_05.jpg',
      'https://upload.wikimedia.org/wikipedia/commons/3/36/Pepper%26Carrot_tp_episode_01_page_06.jpg',
    ];
  }
}
