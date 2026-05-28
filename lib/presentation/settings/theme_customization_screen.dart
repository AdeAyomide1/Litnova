import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_settings_provider.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  State<ThemeCustomizationScreen> createState() =>
      _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState
    extends State<ThemeCustomizationScreen> {
  final AppSettingsProvider _settings = AppSettingsProvider();

  final List<Map<String, dynamic>> _accentColors = [
    {'id': 'amber', 'name': 'Amber', 'color': const Color(0xFFC8823A)},
    {'id': 'blue', 'name': 'Blue', 'color': const Color(0xFF5B9BD5)},
    {'id': 'green', 'name': 'Green', 'color': const Color(0xFF3AAA6A)},
    {'id': 'purple', 'name': 'Purple', 'color': const Color(0xFF8B5CF6)},
    {'id': 'red', 'name': 'Red', 'color': const Color(0xFFE05555)},
    {'id': 'pink', 'name': 'Pink', 'color': const Color(0xFFE85D8A)},
    {'id': 'teal', 'name': 'Teal', 'color': const Color(0xFF2DD4BF)},
    {'id': 'orange', 'name': 'Orange', 'color': const Color(0xFFF97316)},
  ];

  final List<Map<String, dynamic>> _appThemes = [
    {
      'id': 'dark',
      'name': 'Dark Ember',
      'desc': 'Warm dark theme with earthy tones',
      'bg': const Color(0xFF120D08),
      'accent': const Color(0xFFC8823A),
    },
    {
      'id': 'midnight',
      'name': 'Midnight',
      'desc': 'Deep blue-black theme',
      'bg': const Color(0xFF0A0A0F),
      'accent': const Color(0xFF5B9BD5),
    },
    {
      'id': 'forest',
      'name': 'Forest',
      'desc': 'Dark green nature theme',
      'bg': const Color(0xFF0A120A),
      'accent': const Color(0xFF3AAA6A),
    },
    {
      'id': 'ocean',
      'name': 'Ocean',
      'desc': 'Deep ocean blue theme',
      'bg': const Color(0xFF080E14),
      'accent': const Color(0xFF2DD4BF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) {
        final theme = _settings.currentTheme;
        final accent = _settings.currentAccentColor;

        return Scaffold(
          backgroundColor: _settings.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, theme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('App Theme', theme),
                        const SizedBox(height: 12),
                        _buildThemeSelector(theme, accent),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Accent Color', theme),
                        const SizedBox(height: 4),
                        Text(
                          'Changes buttons, highlights and active elements',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 12,
                            color: theme['textMuted'],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAccentColorSelector(theme),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Preview', theme),
                        const SizedBox(height: 12),
                        _buildThemePreview(theme, accent),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildHeader(BuildContext context, Map<String, Color> theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/settings');
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme['surface'],
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme['border'] ?? Colors.transparent,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: theme['textMuted'],
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Theme & Colors',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: theme['text'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Map<String, Color> theme) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: theme['text'],
      ),
    );
  }

  Widget _buildThemeSelector(Map<String, Color> theme, Color currentAccent) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: _appThemes.map((t) {
        final isSelected = _settings.appTheme == t['id'];
        return GestureDetector(
          onTap: () => _settings.appTheme = t['id'] as String,
          child: Container(
            decoration: BoxDecoration(
              color: t['bg'] as Color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? currentAccent
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 0.5,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: t['accent'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: currentAccent,
                        size: 18,
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['name'] as String,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      t['desc'] as String,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 9,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccentColorSelector(Map<String, Color> theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _accentColors.map((colorData) {
        final isSelected = _settings.accentColor == colorData['id'];
        final color = colorData['color'] as Color;
        return GestureDetector(
          onTap: () => _settings.accentColor = colorData['id'] as String,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                colorData['name'] as String,
                style: GoogleFonts.sourceSans3(
                  fontSize: 10,
                  color: isSelected
                      ? color
                      : theme['textMuted'],
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThemePreview(Map<String, Color> theme, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme['bg'],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme['border'] ?? const Color(0xFF2E2018),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LitNOVA Preview',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  color: theme['text'],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Button',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme['surface'],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme['border'] ?? const Color(0xFF2E2018),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: accent.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manga Title',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 12,
                        color: theme['text'],
                      ),
                    ),
                    Text(
                      'Action · MangaDex',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 10,
                        color: theme['textMuted'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '★ 4.8',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 10,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Start Reading',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme['surface'],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme['border'] ?? const Color(0xFF2E2018),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.bookmark_border_rounded,
                  color: theme['textMuted'],
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
