import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Your World of Stories',
      'subtitle':
      'Dive into thousands of novels, manga, comics, webtoons and audio stories — all in one place, completely free.',
      'icon': Icons.auto_stories_rounded,
      'color1': const Color(0xFF2C0A0A),
      'color2': const Color(0xFF7A1A1A),
      'accent': const Color(0xFFC8823A),
      'items': [
        {'icon': Icons.book_rounded, 'label': 'Novels'},
        {'icon': Icons.auto_stories_rounded, 'label': 'Manga'},
        {'icon': Icons.widgets_rounded, 'label': 'Comics'},
        {'icon': Icons.view_day_rounded, 'label': 'Webtoons'},
        {'icon': Icons.headphones_rounded, 'label': 'Audio'},
      ],
    },
    {
      'title': 'Listen While You Read',
      'subtitle':
      'Turn any novel into an audio story with our on-device text-to-speech. No internet needed — listen anywhere, anytime.',
      'icon': Icons.headphones_rounded,
      'color1': const Color(0xFF0A1A2C),
      'color2': const Color(0xFF1A3A6A),
      'accent': const Color(0xFF5B9BD5),
      'items': [
        {'icon': Icons.offline_bolt_rounded, 'label': 'Works Offline'},
        {'icon': Icons.speed_rounded, 'label': 'Adjustable Speed'},
        {'icon': Icons.record_voice_over_rounded, 'label': 'Multiple Voices'},
        {'icon': Icons.bedtime_rounded, 'label': 'Sleep Timer'},
      ],
    },
    {
      'title': 'Read Through Your World',
      'subtitle':
      'Enable camera background mode to read with your real environment as the backdrop. A reading experience like no other.',
      'icon': Icons.camera_alt_rounded,
      'color1': const Color(0xFF1A2C0A),
      'color2': const Color(0xFF2A5A1A),
      'accent': const Color(0xFF7AB648),
      'items': [
        {'icon': Icons.camera_rounded, 'label': 'Live Camera'},
        {'icon': Icons.opacity_rounded, 'label': 'Adjustable Blur'},
        {'icon': Icons.wb_sunny_rounded, 'label': 'Any Lighting'},
        {'icon': Icons.phone_android_rounded, 'label': 'Any Device'},
      ],
    },
    {
      'title': 'Track Your Journey',
      'subtitle':
      'Keep track of your reading progress, earn achievements, build streaks and discover new stories tailored just for you.',
      'icon': Icons.emoji_events_rounded,
      'color1': const Color(0xFF2C1A0A),
      'color2': const Color(0xFF6A3A1A),
      'accent': const Color(0xFFC8823A),
      'items': [
        {'icon': Icons.trending_up_rounded, 'label': 'Progress Tracking'},
        {'icon': Icons.local_fire_department_rounded, 'label': 'Daily Streaks'},
        {'icon': Icons.military_tech_rounded, 'label': 'Achievements'},
        {'icon': Icons.recommend_rounded, 'label': 'Recommendations'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _animationController.reset();
                _animationController.forward();
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),
            _buildTopBar(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (page['color1'] as Color).withValues(alpha: 0.8),
                const Color(0xFF120D08),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.6],
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Icon circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (page['accent'] as Color).withValues(alpha: 0.1),
                  border: Border.all(
                    color: (page['accent'] as Color).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (page['accent'] as Color).withValues(alpha: 0.15),
                      border: Border.all(
                        color: (page['accent'] as Color).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      page['icon'] as IconData,
                      color: page['accent'] as Color,
                      size: 48,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  page['title'] as String,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF0D9B5),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  page['subtitle'] as String,
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    color: const Color(0xFF8A6A4A),
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Feature items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: (page['items'] as List<Map<String, dynamic>>)
                      .map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: (page['accent'] as Color).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (page['accent'] as Color).withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: page['accent'] as Color,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['label'] as String,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 13,
                              color: const Color(0xFFC4A882),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
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
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF0D9B5),
                    ),
                  ),
                  TextSpan(
                    text: 'NOVA',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC8823A),
                    ),
                  ),
                ],
              ),
            ),
            if (_currentPage < _pages.length - 1)
              GestureDetector(
                onTap: _skip,
                child: Text(
                  'Skip',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    color: const Color(0xFF5A4535),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastPage = _currentPage == _pages.length - 1;
    final accent = _pages[_currentPage]['accent'] as Color;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF120D08),
              const Color(0xFF120D08).withValues(alpha: 0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? accent
                        : const Color(0xFF3D2E1E),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Next / Get Started button
            GestureDetector(
              onTap: _nextPage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1510),
                    ),
                  ),
                ),
              ),
            ),

            if (isLastPage) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 13,
                          color: const Color(0xFF5A4535),
                        ),
                      ),
                      TextSpan(
                        text: 'Sign in',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 13,
                          color: const Color(0xFFC8823A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
