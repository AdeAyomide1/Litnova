import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/source_model.dart';
import '../../data/services/bookmark_service.dart';
import '../../shared/providers/app_settings_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppSettingsProvider _s = AppSettingsProvider();
  List<SourceBook> _bookmarks = [];
  List<SourceBook> _history = [];
  List<SourceBook> _downloads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final bookmarks = BookmarkService.getBookmarks();
      final history = BookmarkService.getHistory();
      final downloads = BookmarkService.getDownloads();
      if (mounted) {
        setState(() {
          _bookmarks = bookmarks;
          _history = history;
          _downloads = downloads;
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
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListTab(_history, 'Nothing in progress', Icons.menu_book_outlined),
                      _buildListTab(_downloads, 'No downloads yet', Icons.download_outlined),
                      _buildListTab(_bookmarks, 'No bookmarks found', Icons.bookmark_outline_rounded),
                      _buildListTab(_history, 'No reading history', Icons.history_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Library',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _s.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: _s.borderColor, width: 0.5),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: _s.textMutedColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: _s.currentAccentColor,
      indicatorWeight: 2,
      labelColor: _s.currentAccentColor,
      unselectedLabelColor: _s.textFaintColor,
      labelStyle: GoogleFonts.sourceSans3(
        fontSize: 12, fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.sourceSans3(fontSize: 12),
      dividerColor: _s.borderColor,
      isScrollable: true,
      tabs: const [
        Tab(text: 'Reading'),
        Tab(text: 'Downloaded'),
        Tab(text: 'Bookmarked'),
        Tab(text: 'History'),
      ],
    );
  }

  Widget _buildListTab(List<SourceBook> books, String emptyMsg, IconData emptyIcon) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: _s.currentAccentColor, strokeWidth: 2,
        ),
      );
    }
    if (books.isEmpty) {
      return _buildEmptyState(
        icon: emptyIcon,
        title: emptyMsg,
        subtitle: 'Start reading to populate your library',
        actionLabel: 'Browse MangaDex',
        onAction: () => context.go('/home'),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: _s.currentAccentColor,
      backgroundColor: _s.surfaceColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildBookCard(books[index]),
      ),
    );
  }

  Widget _buildBookCard(SourceBook book) {
    return GestureDetector(
      onTap: () => context.push(
        '/sources/reader/${book.sourceId}/${book.id}',
        extra: book,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _s.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _s.borderColor, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _s.cardColor,
                image: book.coverUrl != null
                    ? DecorationImage(
                  image: NetworkImage(book.coverUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: book.coverUrl == null
                  ? Icon(Icons.book_rounded,
                  color: _s.textColor, size: 24)
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
                      color: _s.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author ?? 'Unknown Author',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11, color: _s.textMutedColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Source: ${book.sourceId.toUpperCase()}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 10,
                      color: _s.textGhostColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _s.currentAccentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _s.textGhostColor, size: 64),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18, color: _s.textFaintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.sourceSans3(
              fontSize: 13, color: _s.textGhostColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _s.currentAccentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
