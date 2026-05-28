import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../data/models/source_model.dart';
import '../../data/services/source_manager.dart';
import '../../data/services/bookmark_service.dart';
import '../../shared/providers/app_settings_provider.dart';

class SourceReaderScreen extends StatefulWidget {
  final String sourceId;
  final String bookId;
  final SourceBook? book;

  const SourceReaderScreen({
    super.key,
    required this.sourceId,
    required this.bookId,
    this.book,
  });

  @override
  State<SourceReaderScreen> createState() => _SourceReaderScreenState();
}

class _SourceReaderScreenState extends State<SourceReaderScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();
  final SourceManager _sourceManager = SourceManager();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  List<SourceChapter> _chapters = [];
  List<String> _pages = [];
  SourceChapter? _currentChapter;
  bool _isLoadingChapters = true;
  bool _isLoadingPages = false;
  bool _showControls = true;
  int _currentPage = 0;
  bool _isVertical = false;
  bool _isBookmarked = false;

  final Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
  };

  @override
  void initState() {
    super.initState();
    _checkBookmark();
    _loadChapters();
    if (widget.book != null) {
      BookmarkService.addToHistory(widget.book!);
    }
  }

  void _checkBookmark() {
    setState(() {
      _isBookmarked = BookmarkService.isBookmarked(widget.bookId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChapters() async {
    setState(() => _isLoadingChapters = true);
    try {
      final chapters = await _sourceManager.getChapters(
        widget.sourceId,
        widget.bookId,
      );
      if (mounted) {
        setState(() {
          _chapters = chapters;
          _isLoadingChapters = false;
        });
        if (chapters.isNotEmpty) {
          await _loadPages(chapters.first);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingChapters = false);
    }
  }

  Future<void> _loadPages(SourceChapter chapter) async {
    setState(() {
      _isLoadingPages = true;
      _currentChapter = chapter;
      _currentPage = 0;
    });
    try {
      if (chapter.externalUrl != null && chapter.externalUrl!.isNotEmpty) {
        final url = Uri.parse(chapter.externalUrl!);
        try {
          await launchUrl(url, mode: LaunchMode.inAppBrowserView);
        } catch (e) {
          debugPrint('Could not launch $url');
        }
        if (mounted) {
          setState(() {
            _isLoadingPages = false;
          });
        }
        return;
      }

      final pages = await _sourceManager.getPages(
        widget.sourceId,
        chapter.id,
      );
      if (mounted) {
        setState(() {
          _pages = pages;
          _isLoadingPages = false;
        });
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPages = false);
    }
  }

  bool get _isNovel => widget.book?.type == 'Novel' || widget.sourceId == 'lightnovelworld';

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _toggleBookmark() async {
    if (widget.book == null) return;
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.bookId);
    } else {
      await BookmarkService.addBookmark(widget.book!);
    }
    _checkBookmark();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingChapters) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFC8823A),
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Fetching chapters...',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _isNovel ? _s.bgColor : Colors.black,
      body: Stack(
        children: [
          _isLoadingPages
              ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFC8823A),
              strokeWidth: 2,
            ),
          )
              : GestureDetector(
            onTap: () =>
                setState(() => _showControls = !_showControls),
            child: _pages.isEmpty
                ? _buildEmptyState()
                : _isNovel
                ? _buildNovelReader()
                : _isVertical
                ? _buildVerticalReader()
                : _buildHorizontalReader(),
          ),
          if (_showControls) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
            if (_pages.isNotEmpty && !_isNovel)
              Positioned(
                top: 100,
                right: 16,
                child: _buildPageIndicator(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNovelReader() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
      child: SelectionArea(
        child: HtmlWidget(
          _pages.first,
          textStyle: GoogleFonts.lora(
            fontSize: _s.fontSize,
            color: _s.textColor,
            height: _s.lineSpacing,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasExternalUrl = _currentChapter?.externalUrl != null && _currentChapter!.externalUrl!.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(hasExternalUrl ? '🌐' : '📵', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              hasExternalUrl ? 'Available Externally' : 'No Content Found',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                color: const Color(0xFFF0D9B5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasExternalUrl
                  ? 'This chapter is hosted on an external platform. Tap below to bypass restrictions.'
                  : 'We couldn\'t fetch the content for this chapter.',
              style: GoogleFonts.lora(
                fontSize: 14,
                color: const Color(0xFF8A6A4A),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: hasExternalUrl
                  ? () async {
                      final url = Uri.parse(_currentChapter!.externalUrl!);
                      try {
                        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                      } catch (e) {
                        debugPrint('Could not launch $url');
                      }
                    }
                  : _goBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8823A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasExternalUrl ? 'Launch Webview' : 'Try another source',
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

  Widget _buildHorizontalReader() {
    return PhotoViewGallery.builder(
      pageController: _pageController,
      itemCount: _pages.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: CachedNetworkImageProvider(
            _pages[index],
            headers: _headers,
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white24,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text('Page Not Available', style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
          ),
        );
      },
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => Center(
        child: CircularProgressIndicator(
          value: event == null
              ? null
              : event.cumulativeBytesLoaded /
              (event.expectedTotalBytes ?? 1),
          color: const Color(0xFFC8823A),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildVerticalReader() {
    return ListView.builder(
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: _pages[index],
          httpHeaders: _headers,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          placeholder: (context, url) => Container(
            height: 400,
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC8823A),
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 200,
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.white24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Row(
            children: [
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book?.title ?? 'Reading',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentChapter?.title ?? 'Loading...',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggleBookmark,
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isBookmarked ? const Color(0xFFC8823A) : Colors.white,
                    size: 18,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _startDownload,
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.download_for_offline_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              if (!_isNovel)
                GestureDetector(
                  onTap: () =>
                      setState(() => _isVertical = !_isVertical),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isVertical
                          ? Icons.swap_horiz_rounded
                          : Icons.swap_vert_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startDownload() async {
    if (_pages.isEmpty || widget.book == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading: ${widget.book!.title} - ${_currentChapter?.title}'),
        backgroundColor: const Color(0xFFC8823A),
        duration: const Duration(seconds: 2),
      ),
    );
    
    await BookmarkService.addDownload(widget.book!);
    
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chapter saved for offline reading!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${_currentPage + 1} / ${_pages.length}',
        style: GoogleFonts.sourceSans3(fontSize: 12, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_pages.isNotEmpty && !_isNovel) ...[
                Row(
                  children: [
                    Text(
                      '1',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentPage.toDouble(),
                        min: 0,
                        max: (_pages.length - 1).toDouble(),
                        divisions:
                        _pages.length > 1 ? _pages.length - 1 : 1,
                        activeColor: const Color(0xFFC8823A),
                        inactiveColor: Colors.white24,
                        onChanged: (value) {
                          setState(
                                () => _currentPage = value.toInt(),
                          );
                          _pageController.jumpToPage(value.toInt());
                        },
                      ),
                    ),
                    Text(
                      '${_pages.length}',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBtn(Icons.skip_previous_rounded, 'Prev Ch',
                      onTap: () {
                        final index = _chapters.indexOf(_currentChapter!);
                        if (index > 0) _loadPages(_chapters[index - 1]);
                      }),
                  if (!_isNovel)
                    _buildBtn(Icons.arrow_back_ios_rounded, 'Previous',
                        onTap: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }),
                  _buildBtn(
                    Icons.format_list_bulleted_rounded,
                    'Chapters',
                    onTap: _showChaptersSheet,
                  ),
                  if (!_isNovel)
                    _buildBtn(Icons.arrow_forward_ios_rounded, 'Next',
                        onTap: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }),
                  _buildBtn(Icons.skip_next_rounded, 'Next Ch',
                      onTap: () {
                        final index = _chapters.indexOf(_currentChapter!);
                        if (index < _chapters.length - 1) {
                          _loadPages(_chapters[index + 1]);
                        }
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.sourceSans3(
              fontSize: 9,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  void _showChaptersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1610),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chapters',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: const Color(0xFFF0D9B5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                final isCurrent = chapter.id == _currentChapter?.id;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _loadPages(chapter);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFC8823A).withOpacity(0.1)
                          : Colors.transparent,
                      border: const Border(
                        bottom: BorderSide(
                          color: Color(0xFF2E2018), width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 14,
                              color: isCurrent
                                  ? const Color(0xFFC8823A)
                                  : const Color(0xFFC4A882),
                              fontWeight: isCurrent
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFFC8823A),
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
