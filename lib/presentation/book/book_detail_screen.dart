import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/book_repository.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BookModel? _book;
  final List<dynamic> _chapters = [];
  final List<dynamic> _reviews = [];
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBook();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    setState(() => _isLoading = true);
    try {
      final book = await BookRepository.getBook(widget.bookId);
      if (mounted) {
        setState(() {
          _book = book;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  String _getReaderRoute() {
    if (_book == null) return '/read/novel/${widget.bookId}';
    switch (_book!.type.toLowerCase()) {
      case 'manga':
      case 'comic':
      case 'webtoon':
        return '/read/comic/${widget.bookId}';
      case 'audio story':
        return '/read/audio/${widget.bookId}';
      default:
        return '/read/novel/${widget.bookId}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF120D08),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC8823A),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_book == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF120D08),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book_outlined, color: Color(0xFF3D2E1E), size: 64),
              const SizedBox(height: 16),
              Text(
                'Book not found',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  color: const Color(0xFF5A4535),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8823A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1510),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBookInfo(),
                      _buildStats(),
                      _buildTags(),
                      _buildTabBar(),
                      _buildTabContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF120D08),
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: _goBack,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _isBookmarked = !_isBookmarked),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _isBookmarked ? const Color(0xFFC8823A) : Colors.white,
              size: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _book!.coverUrl != null
                ? Image.network(
              _book!.coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C0A0A), Color(0xFF7A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            )
                : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C0A0A), Color(0xFF7A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (_book!.coverUrl == null)
              Center(
                child: Container(
                  width: 120,
                  height: 160,
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withValues(alpha: 0.3),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.book_rounded,
                        color: Color(0xFFF0D9B5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _book!.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 11,
                            color: const Color(0xFFF0D9B5),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF120D08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _book!.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF0D9B5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${_book!.authorName ?? 'Unknown Author'}',
            style: GoogleFonts.lora(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF8A6A4A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRatingStars(_book!.averageRating),
              const SizedBox(width: 8),
              Text(
                '${_book!.averageRating.toStringAsFixed(1)} rating',
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  color: const Color(0xFF5A4535),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star_rounded
              : index < rating
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          color: const Color(0xFFC8823A),
          size: 16,
        );
      }),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            'Reads',
            _book!.totalReads > 1000
                ? '${(_book!.totalReads / 1000).toStringAsFixed(1)}K'
                : _book!.totalReads.toString(),
            Icons.menu_book_rounded,
          ),
          _buildVerticalDivider(),
          _buildStat('Type', _book!.type, Icons.category_rounded),
          _buildVerticalDivider(),
          _buildStat('Status', _book!.status, Icons.fiber_manual_record_rounded),
          _buildVerticalDivider(),
          _buildStat('Genre', _book!.genre, Icons.local_offer_rounded),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFC8823A), size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF0D9B5),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 10,
            color: const Color(0xFF5A4535),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 0.5, height: 40, color: const Color(0xFF2E2018));
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildTag(_book!.genre),
          _buildTag(_book!.type),
          _buildTag(_book!.status),
          if (_book!.isFeatured) _buildTag('Featured ⭐'),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
      ),
      child: Text(
        tag,
        style: GoogleFonts.sourceSans3(
          fontSize: 11,
          color: const Color(0xFF8A6A4A),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TabBar(
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
          Tab(text: 'About'),
          Tab(text: 'Chapters'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 500,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutTab(),
          _buildChaptersTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    final description = _book!.description ?? 'No description available.';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this book',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF0D9B5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _showFullDescription
                ? description
                : description.length > 200
                ? '${description.substring(0, 200)}...'
                : description,
            style: GoogleFonts.lora(
              fontSize: 14,
              color: const Color(0xFFC4A882),
              height: 1.8,
            ),
          ),
          if (description.length > 200) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  setState(() => _showFullDescription = !_showFullDescription),
              child: Text(
                _showFullDescription ? 'Show less' : 'Read more',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: const Color(0xFFC8823A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Details',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF0D9B5),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Genre', _book!.genre),
          _buildDetailRow('Format', _book!.type),
          _buildDetailRow('Status', _book!.status),
          _buildDetailRow('Total Reads', _book!.totalReads.toString()),
          _buildDetailRow(
            'Rating',
            '${_book!.averageRating.toStringAsFixed(1)} / 5.0',
          ),
          _buildDetailRow(
            'Author',
            _book!.authorName ?? 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFF5A4535),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFFC4A882),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersTab() {
    if (_chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              color: Color(0xFF3D2E1E),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No chapters yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: const Color(0xFF5A4535),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back soon!',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFF3D2E1E),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.go(_getReaderRoute()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8823A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Start Reading',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1510),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _chapters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        return GestureDetector(
          onTap: () => context.go(_getReaderRoute()),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1610),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2E2018), width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF241A11),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${chapter['chapter_number'] ?? index + 1}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5A4535),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chapter['title'] ?? 'Chapter ${index + 1}',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF0D9B5),
                    ),
                  ),
                ),
                const Icon(
                  Icons.play_circle_outline_rounded,
                  color: Color(0xFF3D2E1E),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.star_outline_rounded,
            color: Color(0xFF3D2E1E),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              color: const Color(0xFF5A4535),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Be the first to review this book!',
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              color: const Color(0xFF3D2E1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF120D08),
        border: Border(
          top: BorderSide(color: Color(0xFF1E1610), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.go(_getReaderRoute()),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8823A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Start Reading',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1510),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1610),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2E2018), width: 0.5,
              ),
            ),
            child: const Icon(
              Icons.download_rounded,
              color: Color(0xFF8A6A4A),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
