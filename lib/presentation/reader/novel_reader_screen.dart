import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/api_service.dart';
import '../../shared/providers/app_settings_provider.dart';

class NovelReaderScreen extends StatefulWidget {
  final String bookId;
  const NovelReaderScreen({super.key, required this.bookId});

  @override
  State<NovelReaderScreen> createState() => _NovelReaderScreenState();
}

class _NovelReaderScreenState extends State<NovelReaderScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();

  String _chapterContent = '';
  bool _isLoadingContent = true;

  String? get _chapterText => null;

  Future<void> _loadChapter() async {
    try {
      final chaptersResponse = await ApiService.getChapters(widget.bookId);
      if (chaptersResponse.statusCode == 200) {
        final chapters = chaptersResponse.data['data']['chapters'] as List;
        if (chapters.isNotEmpty) {
          final firstChapter = chapters[0];
          final chapterResponse =
          await ApiService.getChapter(firstChapter['id']);
          if (chapterResponse.statusCode == 200) {
            final content =
                chapterResponse.data['data']['chapter']['content'] ?? '';
            if (mounted) {
              setState(() {
                _chapterContent =
                content.isNotEmpty ? content : _chapterText;
                _isLoadingContent = false;
              });
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Load chapter error: $e');
    }
    if (mounted) {
      setState(() {
        _chapterContent = _chapterText!;
        _isLoadingContent = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (context, _) {
        final theme = _s.currentTheme;
        return Scaffold(
          backgroundColor: theme['bg'],
          appBar: AppBar(
            backgroundColor: theme['bg'],
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: theme['textMuted']),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Novel Reader',
              style: GoogleFonts.playfairDisplay(color: theme['text']),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📖', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 24),
                Text(
                  'Novel scraper coming soon!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: theme['textSecondary'],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'We are currently expanding our source library to include novel aggregators.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: theme['textMuted'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
