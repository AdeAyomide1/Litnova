import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/api_service.dart';

class ComicReaderScreen extends StatefulWidget {
  final String bookId;
  const ComicReaderScreen({super.key, required this.bookId});

  @override
  State<ComicReaderScreen> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  final PageController _pageController = PageController();
  CameraController? _cameraController;

  int _currentPage = 0;
  bool _showControls = true;
  bool _isCameraOn = false;
  bool _isVerticalScroll = false;
  bool _isLoading = true;
  bool _isLoadingPages = false;

  List<String> _pages = [];
  List<Map<String, dynamic>> _chapters = [];
  int _currentChapterIndex = 0;
  String _bookTitle = 'Loading...';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() => _isLoading = true);
    try {
      // Load book details
      final bookResponse = await ApiService.getBook(widget.bookId);
      if (bookResponse.statusCode == 200) {
        final book = bookResponse.data['data']['book'];
        _bookTitle = book['title'] ?? 'Unknown';
        // Load chapters from our database
        await _loadLocalChapters();
      }
    } catch (e) {
      debugPrint('Load book error: $e');
      _loadFallbackPages();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalChapters() async {
    try {
      final response = await ApiService.getChapters(widget.bookId);
      if (response.statusCode == 200) {
        final chapters = response.data['data']['chapters'] as List;
        setState(() {
          _chapters = chapters
              .map((c) => {
            'id': c['id'],
            'title': c['title'],
          })
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Local chapters error: $e');
    }
    _loadFallbackPages();
  }

  void _loadFallbackPages() {
    setState(() {
      _pages = [
        'https://upload.wikimedia.org/wikipedia/commons/6/62/Pepper%26Carrot_tp_episode_01_page_01.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/4/4c/Pepper%26Carrot_tp_episode_01_page_02.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/c/c5/Pepper%26Carrot_tp_episode_01_page_03.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/2/23/Pepper%26Carrot_tp_episode_01_page_04.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/f/ff/Pepper%26Carrot_tp_episode_01_page_05.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/3/36/Pepper%26Carrot_tp_episode_01_page_06.jpg',
      ];
      _isLoadingPages = false;
    });
  }

  Future<void> _switchChapter(int index) async {
    if (index < 0 || index >= _chapters.length) return;
    setState(() => _currentChapterIndex = index);

    _loadFallbackPages();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _toggleCamera() async {
    if (_isCameraOn) {
      await _cameraController?.dispose();
      setState(() {
        _cameraController = null;
        _isCameraOn = false;
      });
    } else {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras.first,
            ResolutionPreset.medium,
          );
          await _cameraController!.initialize();
          setState(() => _isCameraOn = true);
        }
      } catch (e) {
        debugPrint('Camera error: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                'Loading manga...',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraOn &&
              _cameraController != null &&
              _cameraController!.value.isInitialized)
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: CameraPreview(_cameraController!),
              ),
            ),
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
                : _isVerticalScroll
                ? _buildVerticalReader()
                : _buildHorizontalReader(),
          ),
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          if (_showControls && _pages.isNotEmpty)
            Positioned(
              top: 100,
              right: 16,
              child: _buildPageIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_rounded,
            color: Colors.white24,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No pages available',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              color: Colors.white38,
            ),
          ),
        ],
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
          imageProvider: NetworkImage(_pages[index]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          heroAttributes: PhotoViewHeroAttributes(tag: 'page_$index'),
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.white24,
                size: 48,
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
              ? 0
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
        return Image.network(
          _pages[index],
          fit: BoxFit.fitWidth,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 400,
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.white24,
                size: 48,
              ),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: 400,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                      : null,
                  color: const Color(0xFFC8823A),
                  strokeWidth: 2,
                ),
              ),
            );
          },
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
            Colors.black.withValues(alpha: 0.8),
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
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
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
                      _bookTitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _chapters.isNotEmpty
                          ? _chapters[_currentChapterIndex]['title']
                      as String
                          : 'Loading...',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTopIconBtn(
                _isVerticalScroll
                    ? Icons.swap_horiz_rounded
                    : Icons.swap_vert_rounded,
                onTap: () =>
                    setState(() => _isVerticalScroll = !_isVerticalScroll),
              ),
              const SizedBox(width: 8),
              _buildTopIconBtn(
                _isCameraOn
                    ? Icons.camera_alt_rounded
                    : Icons.camera_alt_outlined,
                isActive: _isCameraOn,
                onTap: _toggleCamera,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconBtn(
      IconData icon, {
        bool isActive = false,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFC8823A).withValues(alpha: 0.8)
              : Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1), width: 0.5,
        ),
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
            Colors.black.withValues(alpha: 0.9),
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
              if (_pages.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      '1',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentPage.toDouble(),
                        min: 0,
                        max: (_pages.length - 1).toDouble(),
                        divisions: _pages.length > 1 ? _pages.length - 1 : 1,
                        activeColor: const Color(0xFFC8823A),
                        inactiveColor: Colors.white.withValues(alpha: 0.2),
                        onChanged: (value) {
                          setState(() => _currentPage = value.toInt());
                          _pageController.jumpToPage(value.toInt());
                        },
                      ),
                    ),
                    Text(
                      '${_pages.length}',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomBtn(
                    Icons.skip_previous_rounded,
                    'Prev Chapter',
                    onTap: () => _switchChapter(_currentChapterIndex - 1),
                  ),
                  _buildBottomBtn(
                    Icons.arrow_back_ios_rounded,
                    'Previous',
                    onTap: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  _buildBottomBtn(
                    Icons.bookmark_border_rounded,
                    'Bookmark',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Page ${_currentPage + 1} bookmarked!',
                            style: GoogleFonts.sourceSans3(
                              color: const Color(0xFFF0D9B5),
                            ),
                          ),
                          backgroundColor: const Color(0xFF1E1610),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _buildBottomBtn(
                    Icons.arrow_forward_ios_rounded,
                    'Next',
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  _buildBottomBtn(
                    Icons.skip_next_rounded,
                    'Next Chapter',
                    onTap: () => _switchChapter(_currentChapterIndex + 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBtn(
      IconData icon,
      String label, {
        VoidCallback? onTap,
      }) {
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
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
