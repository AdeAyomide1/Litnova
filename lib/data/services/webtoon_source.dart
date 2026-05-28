import 'base_source.dart';
import '../models/source_model.dart';

class WebtoonSource implements BaseSource {
  @override
  String get id => 'webtoon';

  @override
  String get name => 'WEBTOON';

  @override
  String get iconEmoji => '📱';

  @override
  String get language => 'English';

  @override
  bool get isOfficial => true;

  @override
  List<String> get contentTypes => ['Webtoon'];

  final List<Map<String, dynamic>> _webtoons = [
    {
      'id': 'wt_lore_olympus',
      'title': 'Lore Olympus',
      'author': 'Rachel Smythe',
      'genre': 'Romance',
      'cover': 'https://picsum.photos/seed/loreolympus/400/600',
      'description': 'The story of how Hades and Persephone came to be together, set in a modern day mythological world.',
      'chapters': 270,
    },
    {
      'id': 'wt_unordinary',
      'title': 'unOrdinary',
      'author': 'uru-chan',
      'genre': 'Action',
      'cover': 'https://picsum.photos/seed/unordinary/400/600',
      'description': 'In a world where everyone has superpowers, a boy without powers must navigate a brutal social hierarchy.',
      'chapters': 320,
    },
    {
      'id': 'wt_tower_of_god',
      'title': 'Tower of God',
      'author': 'SIU',
      'genre': 'Fantasy',
      'cover': 'https://picsum.photos/seed/towerofgod/400/600',
      'description': 'A boy enters a mysterious tower to find his only friend who entered it before him.',
      'chapters': 600,
    },
    {
      'id': 'wt_true_beauty',
      'title': 'True Beauty',
      'author': 'Yaongyi',
      'genre': 'Romance',
      'cover': 'https://picsum.photos/seed/truebeauty/400/600',
      'description': 'A girl who is insecure about her appearance discovers the power of makeup.',
      'chapters': 214,
    },
    {
      'id': 'wt_god_of_highschool',
      'title': 'The God of High School',
      'author': 'Yongje Park',
      'genre': 'Action',
      'cover': 'https://picsum.photos/seed/goh/400/600',
      'description': 'A high school martial arts tournament where the winner gets any wish granted.',
      'chapters': 570,
    },
    {
      'id': 'wt_sweet_home',
      'title': 'Sweet Home',
      'author': 'Kim Carnby',
      'genre': 'Horror',
      'cover': 'https://picsum.photos/seed/sweethome/400/600',
      'description': 'Humans begin transforming into monsters based on their deepest desires.',
      'chapters': 140,
    },
    {
      'id': 'wt_noblesse',
      'title': 'Noblesse',
      'author': 'Son Jeho',
      'genre': 'Action',
      'cover': 'https://picsum.photos/seed/noblesse/400/600',
      'description': 'A powerful noble vampire awakens after 820 years and enrolls in a high school.',
      'chapters': 544,
    },
    {
      'id': 'wt_I_love_yoo',
      'title': 'I Love Yoo',
      'author': 'Quimchee',
      'genre': 'Romance',
      'cover': 'https://picsum.photos/seed/iloveyoo/400/600',
      'description': 'A girl who has given up on love and friendship gets entangled with two brothers.',
      'chapters': 285,
    },
    {
      'id': 'wt_purple_hyacinth',
      'title': 'Purple Hyacinth',
      'author': 'Ephemerys',
      'genre': 'Thriller',
      'cover': 'https://picsum.photos/seed/purplehyacinth/400/600',
      'description': 'A woman with the ability to detect lies teams up with an assassin to uncover a conspiracy.',
      'chapters': 190,
    },
    {
      'id': 'wt_let_dai',
      'title': 'Let Dai',
      'author': 'Won Soo-Yeon',
      'genre': 'Drama',
      'cover': 'https://picsum.photos/seed/letdai/400/600',
      'description': 'A dark romance set in a dystopian future city.',
      'chapters': 155,
    },
  ];

  @override
  Future<List<SourceBook>> getPopular({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _webtoons.map((w) => SourceBook(
      id: w['id'] as String,
      title: w['title'] as String,
      coverUrl: w['cover'] as String,
      description: w['description'] as String,
      author: w['author'] as String,
      genre: w['genre'] as String,
      status: 'Ongoing',
      sourceId: id,
      type: 'Webtoon',
    )).toList();
  }

  @override
  Future<List<SourceBook>> getLatest({int page = 1}) async {
    return getPopular(page: page);
  }

  @override
  Future<List<SourceBook>> search(String query, {int page = 1}) async {
    final results = _webtoons.where((w) =>
    (w['title'] as String).toLowerCase().contains(query.toLowerCase()) ||
        (w['author'] as String).toLowerCase().contains(query.toLowerCase())
    ).toList();

    return results.map((w) => SourceBook(
      id: w['id'] as String,
      title: w['title'] as String,
      coverUrl: w['cover'] as String,
      description: w['description'] as String,
      author: w['author'] as String,
      genre: w['genre'] as String,
      status: 'Ongoing',
      sourceId: id,
      type: 'Webtoon',
    )).toList();
  }

  @override
  Future<List<SourceChapter>> getChapters(String bookId) async {
    final webtoon = _webtoons.firstWhere(
          (w) => w['id'] == bookId,
      orElse: () => {'chapters': 10},
    );
    final chapterCount = webtoon['chapters'] as int? ?? 10;
    final displayCount = chapterCount > 50 ? 50 : chapterCount;

    return List.generate(displayCount, (i) => SourceChapter(
      id: '${bookId}_ep${i + 1}',
      title: 'Episode ${i + 1}',
      chapterNumber: '${i + 1}',
      publishedAt: DateTime.now()
          .subtract(Duration(days: (displayCount - i) * 7))
          .toIso8601String(),
      sourceId: id,
      externalUrl: 'https://www.webtoons.com/en/', // Link to the official site
    ));
  }

  @override
  Future<List<String>> getPages(String chapterId) async {
    // Returning an empty array signals to the Reader that this is a Discovery (Webview) only chapter
    return [];
  }
}
