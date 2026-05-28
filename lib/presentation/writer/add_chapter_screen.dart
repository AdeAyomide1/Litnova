import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/api_service.dart';

class AddChapterScreen extends StatefulWidget {
  const AddChapterScreen({super.key});

  @override
  State<AddChapterScreen> createState() => _AddChapterScreenState();
}

class _AddChapterScreenState extends State<AddChapterScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'Text';
  bool _isLoading = false;
  bool _isScheduled = false;
  String? _selectedBookId;
  List<Map<String, dynamic>> _myBooks = [];
  bool _loadingBooks = true;

  final List<String> _types = ['Text', 'Images', 'Audio'];

  @override
  void initState() {
    super.initState();
    _loadMyBooks();
  }

  Future<void> _loadMyBooks() async {
    try {
      final response = await ApiService.getMyBooks();
      if (response.statusCode == 200 && mounted) {
        final books = response.data['data']['books'] as List;
        setState(() {
          _myBooks = books.map((b) => {
            'id': b['id'],
            'title': b['title'],
          }).toList();
          if (_myBooks.isNotEmpty) {
            _selectedBookId = _myBooks[0]['id'];
          }
          _loadingBooks = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingBooks = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publishChapter({bool isDraft = false}) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a chapter title',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    if (_selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a book first',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.createChapter(
        bookId: _selectedBookId!,
        title: _titleController.text.trim(),
        content: _contentController.text.isNotEmpty
            ? _contentController.text.trim()
            : null,
        type: _selectedType,
      );

      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDraft
                  ? 'Chapter saved as draft!'
                  : 'Chapter published successfully!',
              style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
            ),
            backgroundColor: const Color(0xFF1E1610),
          ),
        );
        context.go('/writer/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to publish chapter. Please try again.',
              style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
            ),
            backgroundColor: const Color(0xFF1E1610),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTypeSelector(),
            Expanded(
              child: _loadingBooks
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC8823A),
                  strokeWidth: 2,
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_myBooks.isNotEmpty) ...[
                      _buildBookSelector(),
                      const SizedBox(height: 16),
                    ],
                    if (_myBooks.isEmpty) ...[
                      _buildNoBooksWarning(context),
                      const SizedBox(height: 16),
                    ],
                    _buildInputField(
                      controller: _titleController,
                      label: 'Chapter Title',
                      hint: 'e.g. Chapter 1 — The Beginning',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildContentSection(),
                    const SizedBox(height: 16),
                    _buildScheduleToggle(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
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
                context.go('/writer/dashboard');
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
          const SizedBox(width: 16),
          Text(
            'Add New Chapter',
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

  Widget _buildBookSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Book',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: const Color(0xFF8A6A4A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1610),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBookId,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1610),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF5A4535),
              ),
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: const Color(0xFFF0D9B5),
              ),
              items: _myBooks.map((book) {
                return DropdownMenuItem<String>(
                  value: book['id'] as String,
                  child: Text(book['title'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedBookId = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoBooksWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE05555).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE05555).withValues(alpha: 0.3), width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE05555),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You need to create a book first before adding chapters.',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFFE05555),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/writer/upload'),
            child: Text(
              'Create',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFFC8823A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: _types.map((type) {
          final isSelected = type == _selectedType;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                margin: EdgeInsets.only(
                  right: type != _types.last ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFC8823A)
                      : const Color(0xFF1E1610),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFC8823A)
                        : const Color(0xFF2E2018),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: isSelected
                          ? const Color(0xFF1C1510)
                          : const Color(0xFF8A6A4A),
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentSection() {
    if (_selectedType == 'Text') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapter Content',
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              color: const Color(0xFF8A6A4A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1610),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2E2018), width: 0.5,
              ),
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 16,
              style: GoogleFonts.lora(
                fontSize: 15,
                color: const Color(0xFFF0D9B5),
                height: 1.8,
              ),
              decoration: InputDecoration(
                hintText: 'Start writing your chapter here...',
                hintStyle: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: const Color(0xFF3D2E1E),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_contentController.text.split(' ').where((w) => w.isNotEmpty).length} words',
              style: GoogleFonts.sourceSans3(
                fontSize: 11,
                color: const Color(0xFF3D2E1E),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1610),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedType == 'Images'
                  ? Icons.add_photo_alternate_rounded
                  : Icons.audio_file_rounded,
              color: const Color(0xFFC8823A),
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              _selectedType == 'Images'
                  ? 'Upload comic/manga pages'
                  : 'Upload audio file',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFFC4A882),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedType == 'Images'
                  ? 'JPG or PNG · Upload in order'
                  : 'MP3 or AAC · Max 200MB',
              style: GoogleFonts.sourceSans3(
                fontSize: 11,
                color: const Color(0xFF5A4535),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleToggle() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Release',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 13,
                        color: const Color(0xFFC4A882),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set a future date for this chapter to go live',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: const Color(0xFF5A4535),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isScheduled,
                onChanged: (v) => setState(() => _isScheduled = v),
                activeThumbColor: const Color(0xFFC8823A),
                activeTrackColor: const Color(0xFFC8823A).withValues(alpha: 0.3),
                inactiveThumbColor: const Color(0xFF5A4535),
                inactiveTrackColor: const Color(0xFF3D2E1E),
              ),
            ],
          ),
          if (_isScheduled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF241A11),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF3D2E1E), width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFFC8823A),
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Select release date & time',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: const Color(0xFF8A6A4A),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF5A4535),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: const Color(0xFF8A6A4A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1610),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2E2018), width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              color: const Color(0xFFF0D9B5),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFF3D2E1E),
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF5A4535), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14,
              ),
            ),
          ),
        ),
      ],
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
              onTap: _isLoading ? null : () => _publishChapter(isDraft: true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1610),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E2018), width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Save Draft',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A6A4A),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _isLoading ? null : () => _publishChapter(isDraft: false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8823A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF1C1510),
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Publish Chapter',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1510),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
