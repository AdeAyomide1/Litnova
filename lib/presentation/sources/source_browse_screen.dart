import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/source_model.dart';
import '../../data/services/source_manager.dart';

class SourceBrowseScreen extends StatefulWidget {
  final String sourceId;
  const SourceBrowseScreen({super.key, required this.sourceId});

  @override
  State<SourceBrowseScreen> createState() => _SourceBrowseScreenState();
}

class _SourceBrowseScreenState extends State<SourceBrowseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SourceManager _sourceManager = SourceManager();
  final TextEditingController _searchController = TextEditingController();

  List<SourceBook> _popular = [];
  List<SourceBook> _latest = [];
  List<SourceBook> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final popular = await _sourceManager.getPopularFromSource(
        widget.sourceId,
      );
      final source = _sourceManager.getSource(widget.sourceId);
      final latest = await source?.getLatest() ?? [];
      if (mounted) {
        setState(() {
          _popular = popular;
          _latest = latest;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final source = _sourceManager.getSource(widget.sourceId);
      final results = await source?.search(query) ?? [];
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  String _getSourceName() {
    final source = _sourceManager.allSources.firstWhere(
          (s) => s.id == widget.sourceId,
      orElse: () => SourceModel(
        id: widget.sourceId,
        name: widget.sourceId,
        description: '',
        iconEmoji: '📚',
        language: 'English',
        isInstalled: true,
        isOfficial: false,
        contentTypes: [],
      ),
    );
    return '${source.iconEmoji} ${source.name}';
  }

  void _openBook(SourceBook book) {
    context.go(
      '/sources/reader/${book.sourceId}/${book.id}',
      extra: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_showSearch) _buildSearchBar(),
            if (!_showSearch) _buildTabBar(),
            Expanded(
              child: _showSearch
                  ? _buildSearchResults()
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildBookGrid(_popular),
                  _buildBookGrid(_latest),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/sources');
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1610),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E2018), width: 0.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFA08060),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getSourceName(),
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF0D9B5),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                _searchResults = [];
              }
            }),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _showSearch
                    ? const Color(0xFFC8823A).withValues(alpha: 0.2)
                    : const Color(0xFF1E1610),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _showSearch
                      ? const Color(0xFFC8823A)
                      : const Color(0xFF2E2018),
                  width: 0.5,
                ),
              ),
              child: Icon(
                _showSearch ? Icons.close_rounded : Icons.search_rounded,
                color: _showSearch
                    ? const Color(0xFFC8823A)
                    : const Color(0xFFA08060),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1610),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.sourceSans3(
            fontSize: 14,
            color: const Color(0xFFF0D9B5),
          ),
          onSubmitted: _search,
          onChanged: (v) {
            if (v.isEmpty) {
              setState(() {
                _searchResults = [];
                _isSearching = false;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Search in this source...',
            hintStyle: GoogleFonts.sourceSans3(
              fontSize: 13,
              color: const Color(0xFF3D2E1E),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF5A4535),
              size: 18,
            ),
            suffixIcon: GestureDetector(
              onTap: () => _search(_searchController.text),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFC8823A),
                size: 18,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFFC8823A),
      indicatorWeight: 2,
      labelColor: const Color(0xFFC8823A),
      unselectedLabelColor: const Color(0xFF5A4535),
      labelStyle: GoogleFonts.sourceSans3(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.sourceSans3(fontSize: 13),
      dividerColor: const Color(0xFF2E2018),
      tabs: const [
        Tab(text: 'Popular'),
        Tab(text: 'Latest'),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC8823A),
          strokeWidth: 2,
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF3D2E1E),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: const Color(0xFF5A4535),
              ),
            ),
          ],
        ),
      );
    }

    return _buildBookGrid(_searchResults);
  }

  Widget _buildBookGrid(List<SourceBook> books) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC8823A),
          strokeWidth: 2,
        ),
      );
    }

    if (books.isEmpty) {
      return Center(
        child: Text(
          'No books available',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            color: const Color(0xFF5A4535),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return GestureDetector(
          onTap: () => _openBook(book),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF1E1610),
                    image: book.coverUrl != null
                        ? DecorationImage(
                      image: NetworkImage(book.coverUrl!),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                        : null,
                  ),
                  child: book.coverUrl == null
                      ? Center(
                    child: Text(
                      book.title[0],
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        color: const Color(0xFFC8823A),
                      ),
                    ),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.title,
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  color: const Color(0xFFF0D9B5),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (book.author != null) ...[
                const SizedBox(height: 2),
                Text(
                  book.author!,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 10,
                    color: const Color(0xFF5A4535),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
