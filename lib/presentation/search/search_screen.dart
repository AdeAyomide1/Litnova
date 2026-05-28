import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/source_model.dart';
import '../../data/services/source_manager.dart';
import '../../shared/providers/app_settings_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();
  final SourceManager _sourceManager = SourceManager();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<SourceBook> _results = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _query = '';

  final List<String> _trendingTags = [
    'Fantasy', 'Romance', 'Thriller', 'Manga',
    'Ongoing', 'Completed', 'Action', 'Sci-Fi',
  ];

  final List<Map<String, dynamic>> _formats = [
    {'name': 'Manga', 'icon': Icons.auto_stories_rounded, 'type': 'Manga'},
    {'name': 'Manhwa', 'icon': Icons.view_day_rounded, 'type': 'Manhwa'},
    {'name': 'Manhua', 'icon': Icons.image_rounded, 'type': 'Manhua'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _query = '';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _query = query;
    });
    try {
      final results = await _sourceManager.searchAllSources(query.trim());
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
        if (!_recentSearches.contains(query.trim())) {
          setState(() {
            _recentSearches.insert(0, query.trim());
            if (_recentSearches.length > 5) {
              _recentSearches = _recentSearches.take(5).toList();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
      _query = '';
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (context, _) {
        final theme = _s.currentTheme;
        final accent = _s.currentAccentColor;

        return Scaffold(
          backgroundColor: _s.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(context, theme, accent),
                Expanded(
                  child: _hasSearched
                      ? _buildSearchResults(theme, accent)
                      : _buildDiscovery(theme, accent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, Map<String, Color> theme, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme['surface'],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme['border'] ?? Colors.transparent, width: 0.5),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: GoogleFonts.sourceSans3(
                  fontSize: 14, color: theme['text'],
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      _results = [];
                      _hasSearched = false;
                      _query = '';
                    });
                  }
                },
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'Search MangaDex titles...',
                  hintStyle: GoogleFonts.sourceSans3(
                    fontSize: 14, color: theme['textGhost'],
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme['textFaint'],
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                    onTap: _clearSearch,
                    child: Icon(
                      Icons.close_rounded,
                      color: theme['textFaint'],
                      size: 18,
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.sourceSans3(
                fontSize: 14, color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscovery(Map<String, Color> theme, Color accent) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            _buildSectionTitle('Recent Searches', theme),
            ..._recentSearches.map((search) => GestureDetector(
              onTap: () {
                _searchController.text = search;
                _search(search);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: theme['textFaint'],
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        search,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          color: theme['textSecondary'],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(
                            () => _recentSearches.remove(search),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: theme['textGhost'],
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
          _buildSectionTitle('Trending', theme),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingTags.map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  _search(tag);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme['card'],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme['border'] ?? Colors.transparent, width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: accent,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tag,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 12, color: theme['textMuted'],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Quick Genres', theme),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: _formats.map((format) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = format['name'] as String;
                  _search(format['name'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme['surface'],
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: theme['border'] ?? Colors.transparent, width: 0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        format['icon'] as IconData,
                        color: accent,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        format['name'] as String,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 12, color: theme['textMuted'],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSearchResults(Map<String, Color> theme, Color accent) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: accent, strokeWidth: 2,
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: theme['textGhost'],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$_query"',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16, color: theme['textFaint'],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: GoogleFonts.sourceSans3(
                fontSize: 13, color: theme['textGhost'],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _clearSearch,
              child: Text(
                'Clear search',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13, color: accent,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            '${_results.length} result${_results.length == 1 ? '' : 's'} for "$_query"',
            style: GoogleFonts.sourceSans3(
              fontSize: 13, color: theme['textFaint'],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final book = _results[index];
              return GestureDetector(
                onTap: () => context.push(
                  '/sources/reader/${book.sourceId}/${book.id}',
                  extra: book,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme['surface'],
                    borderRadius: BorderRadius.circular(14),
                    border:
                    Border.all(color: theme['border'] ?? Colors.transparent, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: theme['card'],
                          image: book.coverUrl != null
                              ? DecorationImage(
                            image: NetworkImage(book.coverUrl!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: book.coverUrl == null
                            ? Icon(
                          Icons.book_rounded,
                          color: theme['text'],
                          size: 22,
                        )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme['text'],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              book.author ?? 'Unknown Author',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 12,
                                color: theme['textMuted'],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (book.genre != null) ...[
                                  _buildTag(book.genre!, theme),
                                  const SizedBox(width: 6),
                                ],
                                _buildTag(book.type, theme),
                                const SizedBox(width: 6),
                                Text(
                                  book.sourceId.toUpperCase(),
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 10,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme['textGhost'],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Map<String, Color> theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme['text'],
        ),
      ),
    );
  }

  Widget _buildTag(String tag, Map<String, Color> theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: theme['card'],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme['border'] ?? Colors.transparent, width: 0.5),
      ),
      child: Text(
        tag,
        style: GoogleFonts.sourceSans3(
          fontSize: 10, color: theme['textFaint'],
        ),
      ),
    );
  }
}
