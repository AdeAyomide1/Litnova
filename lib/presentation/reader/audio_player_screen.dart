import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_settings_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String bookId;
  const AudioPlayerScreen({super.key, required this.bookId});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final AppSettingsProvider _settings = AppSettingsProvider();

  bool _isPlaying = false;
  bool _isSleepTimerOn = false;
  late double _playbackSpeed;
  Duration _position = Duration.zero;
  final Duration _duration = const Duration(minutes: 45, seconds: 32);
  int _currentChapter = 1;

  final List<Map<String, dynamic>> _chapters = [
    {
      'number': 1,
      'title': 'The Ash Falls',
      'duration': '45:32',
    },
    {
      'number': 2,
      'title': 'The Last Gate',
      'duration': '38:14',
    },
    {
      'number': 3,
      'title': 'Into the Forest',
      'duration': '42:07',
    },
    {
      'number': 4,
      'title': 'Dawn of Reckoning',
      'duration': '51:23',
    },
    {
      'number': 5,
      'title': 'The Ember Returns',
      'duration': '39:58',
    },
  ];

  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    // Use speed from settings
    _playbackSpeed = _settings.ttsSpeed;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _simulatePlayback();
  }

  void _simulatePlayback() {
    Future.doWhile(() async {
      await Future.delayed(
        Duration(milliseconds: (1000 / _playbackSpeed).round()),
      );
      if (!mounted) return false;
      if (_isPlaying) {
        setState(() {
          _position += const Duration(seconds: 1);
          if (_position >= _duration) {
            _position = Duration.zero;
            _isPlaying = false;
            _animationController.stop();
          }
        });
      }
      return mounted;
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  void _changeSpeed() {
    final currentIndex = _speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % _speeds.length;
    setState(() {
      _playbackSpeed = _speeds[nextIndex];
      _settings.ttsSpeed = _playbackSpeed;
    });
  }

  void _skipForward() {
    setState(() {
      _position += const Duration(seconds: 30);
      if (_position > _duration) _position = _duration;
    });
  }

  void _skipBackward() {
    setState(() {
      _position -= const Duration(seconds: 15);
      if (_position < Duration.zero) _position = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    final minutes =
    d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
    d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAlbumArt(),
                    _buildBookInfo(),
                    _buildProgressBar(),
                    _buildControls(),
                    _buildSpeedAndSleep(),
                    const SizedBox(height: 24),
                    _buildChapterList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFA08060),
                size: 22,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Now Playing',
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  color: const Color(0xFF5A4535),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Audio Story',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD4B896),
                ),
              ),
            ],
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
              Icons.more_vert_rounded,
              color: Color(0xFFA08060),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _isPlaying
                ? _animationController.value * 2 * 3.14159
                : 0,
            child: child,
          );
        },
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _settings.currentAccentColor.withValues(alpha: 0.5),
                _settings.currentAccentColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _settings.currentAccentColor.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _settings.currentAccentColor.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.3), width: 1,
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.3), width: 1,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF120D08),
                ),
                child: Center(
                  child: Text(
                    'LN',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 12,
                      color: _settings.currentAccentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Ember Throne',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFF0D9B5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chapter $_currentChapter · ${_chapters[_currentChapter - 1]['title']}',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: const Color(0xFF8A6A4A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'R. Blackwood · Fantasy',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    color: const Color(0xFF5A4535),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
              Icons.favorite_border_rounded,
              color: Color(0xFF5A4535),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _duration.inSeconds > 0
        ? _position.inSeconds / _duration.inSeconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape:
              const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              activeColor: _settings.currentAccentColor,
              inactiveColor: const Color(0xFF3D2E1E),
              onChanged: (value) {
                setState(() {
                  _position = Duration(
                    seconds:
                    (value * _duration.inSeconds).toInt(),
                  );
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    color: const Color(0xFF5A4535),
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    color: const Color(0xFF5A4535),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: _skipBackward,
            child: Column(
              children: [
                const Icon(
                  Icons.replay_outlined,
                  color: Color(0xFF8A6A4A),
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  '15s',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 10,
                    color: const Color(0xFF5A4535),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_currentChapter > 1) {
                setState(() {
                  _currentChapter--;
                  _position = Duration.zero;
                });
              }
            },
            child: const Icon(
              Icons.skip_previous_rounded,
              color: Color(0xFFA08060),
              size: 36,
            ),
          ),
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _settings.currentAccentColor,
                boxShadow: [
                  BoxShadow(
                    color:
                    _settings.currentAccentColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: const Color(0xFF1C1510),
                size: 36,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_currentChapter < _chapters.length) {
                setState(() {
                  _currentChapter++;
                  _position = Duration.zero;
                });
              }
            },
            child: const Icon(
              Icons.skip_next_rounded,
              color: Color(0xFFA08060),
              size: 36,
            ),
          ),
          GestureDetector(
            onTap: _skipForward,
            child: Column(
              children: [
                const Icon(
                  Icons.forward_outlined,
                  color: Color(0xFF8A6A4A),
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  '30s',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 10,
                    color: const Color(0xFF5A4535),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedAndSleep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _changeSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1610),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2E2018), width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.speed_rounded,
                    color: _settings.currentAccentColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_playbackSpeed× Speed',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      color: _settings.currentAccentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _showSleepTimerSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _isSleepTimerOn
                    ? _settings.currentAccentColor.withValues(alpha: 0.15)
                    : const Color(0xFF1E1610),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isSleepTimerOn
                      ? _settings.currentAccentColor
                      : const Color(0xFF2E2018),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bedtime_rounded,
                    color: _isSleepTimerOn
                        ? _settings.currentAccentColor
                        : const Color(0xFF8A6A4A),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isSleepTimerOn ? 'Timer On' : 'Sleep Timer',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      color: _isSleepTimerOn
                          ? _settings.currentAccentColor
                          : const Color(0xFF8A6A4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Chapters',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF0D9B5),
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _chapters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final chapter = _chapters[index];
            final isCurrent = index + 1 == _currentChapter;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentChapter = index + 1;
                  _position = Duration.zero;
                  _isPlaying = true;
                  _animationController.repeat();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? _settings.currentAccentColor.withValues(alpha: 0.1)
                      : const Color(0xFF1E1610),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? _settings.currentAccentColor.withValues(alpha: 0.3)
                        : const Color(0xFF2E2018),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? _settings.currentAccentColor
                            : const Color(0xFF241A11),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCurrent && _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isCurrent
                            ? const Color(0xFF1C1510)
                            : const Color(0xFF5A4535),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapter ${chapter['number']}',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 11,
                              color: isCurrent
                                  ? _settings.currentAccentColor
                                  : const Color(0xFF5A4535),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            chapter['title'] as String,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isCurrent
                                  ? const Color(0xFFF0D9B5)
                                  : const Color(0xFFC4A882),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      chapter['duration'] as String,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 12,
                        color: const Color(0xFF5A4535),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showSleepTimerSheet() {
    final timers = [
      '15 min',
      '30 min',
      '45 min',
      '1 hour',
      'End of chapter',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1610),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Timer',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: const Color(0xFFF0D9B5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...timers.map(
                  (timer) => GestureDetector(
                onTap: () {
                  setState(() => _isSleepTimerOn = true);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF2E2018), width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bedtime_outlined,
                        color: _settings.currentAccentColor,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timer,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 14,
                          color: const Color(0xFFC4A882),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isSleepTimerOn) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() => _isSleepTimerOn = false);
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(
                    'Cancel Timer',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: const Color(0xFFE05555),
                      fontWeight: FontWeight.w500,
                    ),
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
