import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/source_model.dart';
import '../../data/services/source_manager.dart';
import '../../data/services/auth_service.dart';
import '../../shared/providers/app_settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();
  final SourceManager _sourceManager = SourceManager();
  
  List<SourceBook> _trendingBooks = [];
  List<SourceBook> _allBooks = [];
  bool _isLoading = true;
  String _userName = 'Reader';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Novels', 'Manga', 'Manhwa', 'Manhua'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final name = await AuthService.getUserName();
      
      final trending = await _sourceManager.getAggregatedPopular();
      final latest = await _sourceManager.getAggregatedLatest();
      
      if (mounted) {
        setState(() {
          _userName = name ?? 'Reader';
          _trendingBooks = trending;
          _allBooks = latest;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onBookTap(SourceBook book) {
    context.push(
      '/sources/reader/${book.sourceId}/${book.id}',
      extra: book,
    );
  }

  Future<void> _filterByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    
    try {
      await _loadData(); 
      
      if (category != 'All') {
        setState(() {
          _allBooks = _allBooks.where((b) {
            if (category == 'Novels') return b.type == 'Novel';
            return b.type.toLowerCase().contains(category.toLowerCase());
          }).toList();
        });
      }
    } finally {
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
                    _buildHeader(context),
                    _buildGreeting(),
                    _buildSearchBar(context),
                    _buildCategories(),
                    if (_s.showTrending && _trendingBooks.isNotEmpty) ...[
                      _buildSectionTitle(
                        'Trending Now', showSeeAll: true,
                      ),
                      _buildTrendingBooks(context),
                    ],
                    _buildSectionTitle(
                      _selectedCategory == 'All'
                          ? 'Latest Updates'
                          : 'Recent $_selectedCategory',
                      showSeeAll: false,
                    ),
                    _buildAllBooks(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Lit',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _s.textColor,
                  ),
                ),
                TextSpan(
                  text: 'NOVA',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _s.currentAccentColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/settings'),
                child: _buildIconButton(Icons.settings_outlined),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: _buildIconButton(Icons.notifications_outlined),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: _buildAvatar(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _s.surfaceColor,
        shape: BoxShape.circle,
        border: Border.all(color: _s.borderColor, width: 0.5),
      ),
      child: Icon(icon, color: _s.textMutedColor, size: 18),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            _s.currentAccentColor.withOpacity(0.6),
            _s.currentAccentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
          style: GoogleFonts.sourceSans3(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
    if (hour >= 17) greeting = 'Good evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $_userName',
            style: GoogleFonts.lora(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: _s.textFaintColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'What shall we read today?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10,
        ),
        decoration: BoxDecoration(
          color: _s.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _s.borderColor, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: _s.currentAccentColor.withOpacity(0.5),
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Search novels & manga...',
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: _s.textFaintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = _categories[index] == _selectedCategory;
          return GestureDetector(
            onTap: () => _filterByCategory(_categories[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? _s.currentAccentColor
                    : _s.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? _s.currentAccentColor
                      : _s.borderColor,
                  width: 0.5,
                ),
              ),
              child: Text(
                _categories[index],
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  fontWeight: isActive
                      ? FontWeight.w500
                      : FontWeight.w400,
                  color: isActive
                      ? Colors.black87
                      : _s.textMutedColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
          if (showSeeAll)
            Text(
              'See all',
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                color: _s.currentAccentColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingBooks(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _trendingBooks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildBookCard(context, _trendingBooks[index]);
        },
      ),
    );
  }

  Widget _buildAllBooks(BuildContext context) {
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

    if (_allBooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.book_outlined,
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
            ],
          ),
        ),
      );
    }

    // Grid layout
    if (_s.homeLayout == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemCount: _allBooks.length,
        itemBuilder: (context, index) {
          final book = _allBooks[index];
          return GestureDetector(
            onTap: () => _onBookTap(book),
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
                        size: 36,
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 12,
                    color: _s.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  book.author ?? '',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 10,
                    color: _s.textFaintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      );
    }

    // Default list layout
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _allBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildBookListCard(context, _allBooks[index]);
      },
    );
  }

  Widget _buildBookCard(BuildContext context, SourceBook book) {
    return GestureDetector(
      onTap: () => _onBookTap(book),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 195,
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
                  ? Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    book.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _s.textColor,
                    ),
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              book.author ?? 'Unknown Author',
              style: GoogleFonts.sourceSans3(
                fontSize: 11,
                color: _s.textMutedColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _s.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _s.borderColor, width: 0.5,
                    ),
                  ),
                  child: Text(
                    book.type,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 10,
                      color: _s.textFaintColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  book.sourceId.toUpperCase(),
                  style: GoogleFonts.sourceSans3(
                    fontSize: 10,
                    color: _s.textGhostColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookListCard(BuildContext context, SourceBook book) {
    return GestureDetector(
      onTap: () => _onBookTap(book),
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
                size: 24,
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
                      color: _s.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author ?? 'Unknown Author',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      color: _s.textMutedColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTag(book.type),
                      const SizedBox(width: 8),
                      Text(
                        book.sourceId.toUpperCase(),
                        style: GoogleFonts.sourceSans3(
                          fontSize: 10,
                          color: _s.textFaintColor,
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
