import 'base_source.dart';
import '../models/source_model.dart';

class GlobalComixSource implements BaseSource {
  @override
  String get id => 'globalcomix';

  @override
  String get name => 'GlobalComix';

  @override
  String get iconEmoji => '🌐';

  @override
  String get language => 'English';

  @override
  bool get isOfficial => true;

  @override
  List<String> get contentTypes => ['Comic', 'Manga', 'Graphic Novel'];

  // Mock data representing what would typically come from an Indie platform feed
  final List<Map<String, dynamic>> _mockComics = [
    {
      'id': 'gc_beyond_the_clouds',
      'title': 'Beyond the Clouds',
      'author': 'Nicki',
      'genre': 'Sci-Fi',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/3/36/Pepper%26Carrot_tp_episode_01_page_06.jpg',
      'description': 'A lone traveler searches for the fabled lost city above the atmosphere.',
    },
    {
      'id': 'gc_under_the_city',
      'title': 'Under the City',
      'author': 'Trey A.',
      'genre': 'Thriller',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/f/ff/Pepper%26Carrot_tp_episode_01_page_05.jpg',
      'description': 'Detectives find a sprawling subterranean world beneath New York.',
    },
    {
      'id': 'gc_magic_academy',
      'title': 'Magic Academy',
      'author': 'Sarah L.',
      'genre': 'Fantasy',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/2/23/Pepper%26Carrot_tp_episode_01_page_04.jpg',
      'description': 'Students learn the arcane arts while hiding from the Inquisition.',
    },
    {
      'id': 'gc_neon_nights',
      'title': 'Neon Nights',
      'author': 'K.R. Studio',
      'genre': 'Cyberpunk',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/c/c5/Pepper%26Carrot_tp_episode_01_page_03.jpg',
      'description': 'A hacker races against a megacorporation to save her brother.',
    },
    {
      'id': 'gc_sword_of_light',
      'title': 'Sword of Light',
      'author': 'James F.',
      'genre': 'Action',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Pepper%26Carrot_tp_episode_01_page_02.jpg',
      'description': 'A young prince must reclaim his kingdom from the forces of darkness.',
    },
  ];

  @override
  Future<List<SourceBook>> getPopular({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockComics.map((c) => SourceBook(
      id: c['id'] as String,
      title: c['title'] as String,
      coverUrl: c['cover'] as String,
      description: c['description'] as String,
      author: c['author'] as String,
      genre: c['genre'] as String,
      status: 'Ongoing',
      sourceId: id,
      type: 'Comic',
    )).toList();
  }

  @override
  Future<List<SourceBook>> getLatest({int page = 1}) async {
    return getPopular(page: page);
  }

  @override
  Future<List<SourceBook>> search(String query, {int page = 1}) async {
    final results = _mockComics.where((c) =>
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
      type: 'Comic',
    )).toList();
  }

  @override
  Future<List<SourceChapter>> getChapters(String bookId) async {
    // For indie platforms without open page APIs, we provide external links
    return List.generate(10, (i) => SourceChapter(
      id: '${bookId}_ch${10 - i}',
      title: 'Chapter ${10 - i}',
      chapterNumber: '${10 - i}',
      publishedAt: DateTime.now()
          .subtract(Duration(days: i * 7))
          .toIso8601String(),
      sourceId: id,
      externalUrl: 'https://globalcomix.com/', // Mock URL for WebView reading
    ));
  }

  @override
  Future<List<String>> getPages(String chapterId) async {
    // If we have an external URL, the UI should launch the WebView instead of calling getPages
    // Returning empty indicates this is a Discovery-based source.
    return [];
  }
}
