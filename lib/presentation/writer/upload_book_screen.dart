import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/api_service.dart';

class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({super.key});

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedGenre = 'Fantasy';
  String _selectedFormat = 'Novel';
  String _selectedStatus = 'Ongoing';
  bool _isMature = false;
  bool _isLoading = false;

  final List<String> _genres = [
    'Fantasy', 'Sci-Fi', 'Romance', 'Thriller',
    'Horror', 'Comedy', 'Drama', 'Action', 'Mystery',
  ];

  final List<String> _formats = [
    'Novel', 'Manga', 'Comic', 'Webtoon', 'Audio Story',
  ];

  final List<String> _statuses = ['Ongoing', 'Completed', 'Hiatus'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _uploadBook({bool isDraft = false}) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a title',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a description',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.createBook(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        genre: _selectedGenre,
        type: _selectedFormat,
        status: _selectedStatus,
        isMature: _isMature,
        tags: _tagsController.text.isNotEmpty
            ? _tagsController.text
            : null,
      );

      if (response.statusCode == 201 && mounted) {
        final bookId = response.data['data']['book']['id'];

        if (!isDraft) {
          await ApiService.updateBook(
            bookId: bookId,
            isPublished: true,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDraft
                  ? 'Book saved as draft!'
                  : 'Book published successfully!',
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
              'Failed to upload book. Please try again.',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoverUpload(),
                    const SizedBox(height: 24),
                    _buildInputField(
                      controller: _titleController,
                      label: 'Book Title',
                      hint: 'Enter your book title',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Write a compelling description...',
                      maxLines: 6,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Genre'),
                    const SizedBox(height: 10),
                    _buildChips(
                      _genres,
                      _selectedGenre,
                          (v) => setState(() => _selectedGenre = v),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Format'),
                    const SizedBox(height: 10),
                    _buildChips(
                      _formats,
                      _selectedFormat,
                          (v) => setState(() => _selectedFormat = v),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Status'),
                    const SizedBox(height: 10),
                    _buildChips(
                      _statuses,
                      _selectedStatus,
                          (v) => setState(() => _selectedStatus = v),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _tagsController,
                      label: 'Tags (Optional)',
                      hint: 'e.g. magic, war, romance',
                      icon: Icons.tag_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      title: 'Mature Content',
                      subtitle: 'Enable for 18+ content',
                      value: _isMature,
                      onChanged: (v) => setState(() => _isMature = v),
                    ),
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
            'Upload New Book',
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

  Widget _buildCoverUpload() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1610),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFC8823A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Color(0xFFC8823A),
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload Book Cover',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFFC4A882),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG or PNG · Recommended 400×600px',
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.sourceSans3(
        fontSize: 13,
        color: const Color(0xFF8A6A4A),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildChips(
      List<String> items,
      String selected,
      Function(String) onSelect,
      ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selected;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFC8823A)
                  : const Color(0xFF1E1610),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC8823A)
                    : const Color(0xFF2E2018),
                width: 0.5,
              ),
            ),
            child: Text(
              item,
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF1C1510)
                    : const Color(0xFF8A6A4A),
                fontWeight: isSelected
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
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
        _buildLabel(label),
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

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
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
            maxLines: maxLines,
            style: GoogleFonts.lora(
              fontSize: 14,
              color: const Color(0xFFF0D9B5),
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: const Color(0xFF3D2E1E),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: const Color(0xFFC4A882),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    color: const Color(0xFF5A4535),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFC8823A),
            activeTrackColor: const Color(0xFFC8823A).withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF5A4535),
            inactiveTrackColor: const Color(0xFF3D2E1E),
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
              onTap: _isLoading ? null : () => _uploadBook(isDraft: true),
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
                    'Save as Draft',
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
              onTap: _isLoading ? null : () => _uploadBook(isDraft: false),
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
                    'Publish Book',
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
