import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/source_model.dart';
import '../../data/services/source_manager.dart';
import '../../shared/providers/app_settings_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();
  final SourceManager _sourceManager = SourceManager();
  
  List<SourceBook> _trendingManga = [];
  List<SourceBook> _trendingNovels = [];
  List<SourceBook> _newReleases = [];
  bool _isLoading = true;
  String _selectedGenre = 'All';

  final List<Map<String, dynamic>> _genres = [
    {'name': 'Action', 'icon': '⚔️', 'color': const Color(0xFF3A0A0A)},
    {'name': 'Adventure', 'icon': '🗺️', 'color': const Color(0xFF0A2A0A)},
    {'name': 'Comedy', 'icon': '😂', 'color': const Color(0xFF4A3A0A)},
    {'name': 'Drama', 'icon': '🎭', 'color': const Color(0xFF2A1A0A)},
    {'name': 'Fantasy', 'icon': '🏰', 'color': const Color(0xFF4A1A6A)},
    {'name': 'Horror', 'icon': '👻', 'color': const Color(0xFF2A0A0A)},
    {'name': 'Romance', 'icon': '💕', 'color': const Color(0xFF6A1A3A)},
    {'name': 'Sci-Fi', 'icon': '🚀', 'color': const Color(0xFF0A2A4A)},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final manga = await _sourceManager.getPopularFromSource('mangadex');
      final novels = await _sourceManager.getPopularFromSource('novels');
      final latest = await _sourceManager.getAggregatedLatest();
      
      if (mounted) {
        setState(() {
          _trendingManga = manga;
          _trendingNovels = novels;
          _newReleases = latest;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _filterByGenre(String genre) async {
    setState(() {
      _selectedGenre = genre;
      _isLoading = true;
    });
    try {
      final query = genre == 'All' ? 'Latest' : genre;
      final books = await _sourceManager.searchAllSources(query);
      if (mounted) {
        setState(() {
          _newReleases = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _s.bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: _s.currentAccentColor,
              backgroundColor: _s.surfaceColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildGenreGrid(),
                    
                    if (_trendingNovels.isNotEmpty) ...[
                      _buildSectionTitle('Top Light Novels'),
                      _buildHorizontalList(_trendingNovels),
                    ],

                    if (_trendingManga.isNotEmpty) ...[
                      _buildSectionTitle('Trending Manga'),
                      _buildHorizontalList(_trendingManga),
                    ],

                    _buildSectionTitle(
                      _selectedCategoryTitle(),
                    ),
                    _buildBooksList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _selectedCategoryTitle() {
    if (_selectedGenre == 'All') return 'Latest Updates';
    return '$_selectedGenre Results';
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
          Text(
            'Discover the best novels and manga',
            style: GoogleFonts.lora(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: _s.textFaintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Genre',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
            children: _genres.map((genre) {
              final isSelected = _selectedGenre == genre['name'];
              return GestureDetector(
                onTap: () => _filterByGenre(genre['name'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _s.currentAccentColor.withOpacity(0.2)
                        : (genre['color'] as Color).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _s.currentAccentColor
                          : _s.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        genre['icon'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        genre['name'] as String,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 10,
                          color: isSelected
                              ? _s.currentAccentColor
                              : _s.textColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _s.textColor,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<SourceBook> books) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: books.take(10).length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => context.push(
              '/sources/reader/${book.sourceId}/${book.id}',
              extra: book,
            ),
            child: SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _s.cardColor,
                        image: book.coverUrl != null && book.coverUrl!.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(book.coverUrl!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: book.coverUrl == null || book.coverUrl!.isEmpty
                          ? Center(
                        child: Icon(
                          book.type == 'Novel' ? Icons.menu_book_rounded : Icons.book_rounded,
                          color: _s.currentAccentColor,
                          size: 32,
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 11,
                      color: _s.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksList() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: _s.currentAccentColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_newReleases.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                color: _s.textGhostColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No content found',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  color: _s.textFaintColor,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _filterByGenre('All'),
                child: Text(
                  'Clear filter',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: _s.currentAccentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _newReleases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final book = _newReleases[index];
        return GestureDetector(
          onTap: () => context.push(
            '/sources/reader/${book.sourceId}/${book.id}',
            extra: book,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _s.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _s.borderColor, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _s.cardColor,
                    image: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(book.coverUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: book.coverUrl == null || book.coverUrl!.isEmpty
                      ? Icon(
                    book.type == 'Novel' ? Icons.menu_book_rounded : Icons.book_rounded,
                    color: _s.textColor,
                    size: 20,
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _s.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author ?? 'Unknown Author',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 11,
                          color: _s.textMutedColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildTag(book.type),
                          const SizedBox(width: 6),
                          Text(
                            book.sourceId.toUpperCase(),
                            style: GoogleFonts.sourceSans3(
                              fontSize: 10,
                              color: _s.currentAccentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _s.textGhostColor,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _s.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _s.borderColor, width: 0.5),
      ),
      child: Text(
        tag,
        style: GoogleFonts.sourceSans3(
          fontSize: 10,
          color: _s.textFaintColor,
        ),
      ),
    );
  }
}
