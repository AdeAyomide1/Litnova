import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _published = [
    {
      'title': 'The Ember Throne',
      'genre': 'Fantasy',
      'type': 'Novel',
      'chapters': 14,
      'reads': '18.2K',
      'rating': 4.8,
      'color1': const Color(0xFF2C0A0A),
      'color2': const Color(0xFF7A1A1A),
    },
    {
      'title': 'Void Samurai',
      'genre': 'Action',
      'type': 'Manga',
      'chapters': 38,
      'reads': '5.1K',
      'rating': 4.6,
      'color1': const Color(0xFF0A1A2C),
      'color2': const Color(0xFF1A3A6A),
    },
  ];

  final List<Map<String, dynamic>> _drafts = [
    {
      'title': 'Shadow Meridian',
      'genre': 'Thriller',
      'type': 'Novel',
      'chapters': 3,
      'reads': '0',
      'rating': 0.0,
      'color1': const Color(0xFF1A0A2C),
      'color2': const Color(0xFF3A1A6A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBooksList(_published, isPublished: true),
                  _buildBooksList(_drafts, isPublished: false),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/writer/upload'),
        backgroundColor: const Color(0xFFC8823A),
        child: const Icon(Icons.add_rounded, color: Color(0xFF1C1510)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1610),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFA08060), size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Manage Books',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF0D9B5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFFC8823A),
      indicatorWeight: 2,
      labelColor: const Color(0xFFC8823A),
      unselectedLabelColor: const Color(0xFF5A4535),
      labelStyle: GoogleFonts.sourceSans3(fontSize: 13, fontWeight: FontWeight.w500),
      unselectedLabelStyle: GoogleFonts.sourceSans3(fontSize: 13),
      dividerColor: const Color(0xFF2E2018),
      tabs: [
        Tab(text: 'Published (${_published.length})'),
        Tab(text: 'Drafts (${_drafts.length})'),
      ],
    );
  }

  Widget _buildBooksList(List<Map<String, dynamic>> books, {required bool isPublished}) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, color: Color(0xFF3D2E1E), size: 64),
            const SizedBox(height: 16),
            Text(
              isPublished ? 'No published books yet' : 'No drafts',
              style: GoogleFonts.playfairDisplay(fontSize: 16, color: const Color(0xFF5A4535)),
            ),
            const SizedBox(height: 8),
            Text(
              isPublished ? 'Upload your first book!' : 'Start writing a new book',
              style: GoogleFonts.sourceSans3(fontSize: 13, color: const Color(0xFF3D2E1E)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(context, book, isPublished: isPublished);
      },
    );
  }

  Widget _buildBookCard(
      BuildContext context,
      Map<String, dynamic> book, {
        required bool isPublished,
      }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [book['color1'] as Color, book['color2'] as Color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.book_rounded, color: Color(0xFFF0D9B5), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'] as String,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF0D9B5),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${book['type']} · ${book['genre']} · ${book['chapters']} chapters',
                      style: GoogleFonts.sourceSans3(fontSize: 11, color: const Color(0xFF5A4535)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: Color(0xFF5A4535), size: 12),
                        const SizedBox(width: 4),
                        Text('${book['reads']} reads',
                            style: GoogleFonts.sourceSans3(fontSize: 11, color: const Color(0xFF5A4535))),
                        if (isPublished) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.star_rounded, color: Color(0xFFC8823A), size: 12),
                          const SizedBox(width: 4),
                          Text('${book['rating']}',
                              style: GoogleFonts.sourceSans3(fontSize: 11, color: const Color(0xFFC8823A))),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 0.5, color: Color(0xFF2E2018)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionBtn(
                icon: Icons.add_rounded,
                label: 'Add Chapter',
                onTap: () => context.go('/writer/chapter/add'),
              ),
              const SizedBox(width: 8),
              _buildActionBtn(
                icon: Icons.edit_rounded,
                label: 'Edit',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _buildActionBtn(
                icon: isPublished
                    ? Icons.unpublished_rounded
                    : Icons.publish_rounded,
                label: isPublished ? 'Unpublish' : 'Publish',
                onTap: () => _showConfirmDialog(
                  context,
                  isPublished ? 'Unpublish Book?' : 'Publish Book?',
                  isPublished
                      ? 'This book will no longer be visible to readers.'
                      : 'This book will be visible to all readers.',
                ),
              ),
              const SizedBox(width: 8),
              _buildActionBtn(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                onTap: () => _showConfirmDialog(
                  context,
                  'Delete Book?',
                  'This action cannot be undone. All chapters will be deleted.',
                  isDestructive: true,
                ),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFF6A1A1A).withValues(alpha: 0.3)
                : const Color(0xFF241A11),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFF6A1A1A)
                  : const Color(0xFF3D2E1E),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? const Color(0xFFE05555)
                    : const Color(0xFF8A6A4A),
                size: 16,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.sourceSans3(
                  fontSize: 9,
                  color: isDestructive
                      ? const Color(0xFFE05555)
                      : const Color(0xFF5A4535),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(
      BuildContext context,
      String title,
      String message, {
        bool isDestructive = false,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1610),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E2018), width: 0.5),
        ),
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            color: const Color(0xFFF0D9B5),
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.sourceSans3(fontSize: 13, color: const Color(0xFF8A6A4A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.sourceSans3(color: const Color(0xFF5A4535))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isDestructive ? 'Delete' : 'Confirm',
              style: GoogleFonts.sourceSans3(
                color: isDestructive
                    ? const Color(0xFFE05555)
                    : const Color(0xFFC8823A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
