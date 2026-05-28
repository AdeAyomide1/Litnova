import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';

class WriterDashboardScreen extends StatefulWidget {
  const WriterDashboardScreen({super.key});

  @override
  State<WriterDashboardScreen> createState() => _WriterDashboardScreenState();
}

class _WriterDashboardScreenState extends State<WriterDashboardScreen> {
  Map<String, dynamic>? _stats;
  List<dynamic> _books = [];
  bool _isLoading = true;
  String _writerName = 'Writer';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final name = await AuthService.getUserName();
      final statsResponse = await ApiService.getMyStats();
      final booksResponse = await ApiService.getMyBooks();

      if (mounted) {
        setState(() {
          _writerName = name ?? 'Writer';
          if (statsResponse.statusCode == 200) {
            _stats = statsResponse.data['data']['stats'];
          }
          if (booksResponse.statusCode == 200) {
            _books = booksResponse.data['data']['books'] ?? [];
          }
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
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC8823A),
            strokeWidth: 2,
          ),
        )
            : RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFFC8823A),
          backgroundColor: const Color(0xFF1E1610),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildWelcomeBanner(),
                _buildStats(),
                _buildSectionTitle(
                  'My Books',
                  action: 'Manage',
                  onAction: () => context.go('/writer/books'),
                ),
                _buildMyBooks(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/writer/upload'),
        backgroundColor: const Color(0xFFC8823A),
        icon: const Icon(Icons.add_rounded, color: Color(0xFF1C1510)),
        label: Text(
          'New Book',
          style: GoogleFonts.sourceSans3(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1510),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _goBack,
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
          Text(
            'Writer Dashboard',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF0D9B5),
            ),
          ),
          Container(
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
              Icons.notifications_outlined,
              color: Color(0xFFA08060),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    final totalReads = _stats?['total_reads'] ?? 0;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2C0A), Color(0xFF8B4513)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $_writerName!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF0D9B5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalReads > 0
                      ? 'Your stories have been read $totalReads times!'
                      : 'Start writing your first story!',
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    color: const Color(0xFFF0D9B5).withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✓ Verified Writer',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      color: const Color(0xFFF0D9B5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.auto_stories_rounded,
            color: Color(0xFFF0D9B5),
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final statItems = [
      {
        'label': 'Total Reads',
        'value': _stats?['total_reads']?.toString() ?? '0',
        'icon': Icons.menu_book_rounded,
      },
      {
        'label': 'Followers',
        'value': _stats?['total_followers']?.toString() ?? '0',
        'icon': Icons.people_rounded,
      },
      {
        'label': 'Books',
        'value': _stats?['total_books']?.toString() ?? '0',
        'icon': Icons.book_rounded,
      },
      {
        'label': 'Rating',
        'value': double.tryParse(
          _stats?['average_rating']?.toString() ?? '0',
        )?.toStringAsFixed(1) ??
            '0.0',
        'icon': Icons.star_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.8,
        children: statItems.map((stat) {
          return Container(
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8823A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: const Color(0xFFC8823A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat['value'] as String,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF0D9B5),
                        ),
                      ),
                      Text(
                        stat['label'] as String,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 11,
                          color: const Color(0xFF5A4535),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, {
        String? action,
        VoidCallback? onAction,
      }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF0D9B5),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action,
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  color: const Color(0xFFC8823A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMyBooks() {
    if (_books.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.book_outlined,
                color: Color(0xFF3D2E1E),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No books yet',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  color: const Color(0xFF5A4535),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to upload your first book!',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: const Color(0xFF3D2E1E),
                ),
                textAlign: TextAlign.center,
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
      itemCount: _books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final book = _books[index];
        final isPublished = book['is_published'] == true;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1610),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF2E2018), width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C0A0A), Color(0xFF7A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: Color(0xFFF0D9B5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book['title'] ?? 'Untitled',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFF0D9B5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isPublished
                                ? const Color(0xFF2A5A1A)
                                : const Color(0xFF241A11),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isPublished ? 'Published' : 'Draft',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 10,
                              color: isPublished
                                  ? const Color(0xFF9AE06A)
                                  : const Color(0xFF5A4535),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book['type'] ?? ''} · ${book['genre'] ?? ''}',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: const Color(0xFF5A4535),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF5A4535),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book['total_reads'] ?? 0} reads',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 11,
                            color: const Color(0xFF5A4535),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFC8823A),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          double.tryParse(
                            book['average_rating']?.toString() ?? '0',
                          )?.toStringAsFixed(1) ??
                              '0.0',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 11,
                            color: const Color(0xFFC8823A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go('/writer/chapter/add'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8823A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFC8823A).withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '+ Chapter',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      color: const Color(0xFFC8823A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
