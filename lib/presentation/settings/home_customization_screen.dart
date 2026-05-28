import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_settings_provider.dart';

class HomeCustomizationScreen extends StatefulWidget {
  const HomeCustomizationScreen({super.key});

  @override
  State<HomeCustomizationScreen> createState() =>
      _HomeCustomizationScreenState();
}

class _HomeCustomizationScreenState extends State<HomeCustomizationScreen> {
  final AppSettingsProvider _settings = AppSettingsProvider();

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
                    _buildSectionTitle('Layout Style'),
                    const SizedBox(height: 12),
                    _buildLayoutSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Visible Sections'),
                    const SizedBox(height: 12),
                    _buildSectionToggles(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Preview'),
                    const SizedBox(height: 12),
                    _buildPreview(),
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
                context.go('/settings');
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
            'Home Customization',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFF0D9B5),
      ),
    );
  }

  Widget _buildLayoutSelector() {
    final layouts = [
      {
        'id': 'list',
        'label': 'List',
        'icon': Icons.view_list_rounded,
        'desc': 'Books displayed in a scrollable list',
      },
      {
        'id': 'grid',
        'label': 'Grid',
        'icon': Icons.grid_view_rounded,
        'desc': 'Books displayed in a 2-column grid',
      },
      {
        'id': 'card',
        'label': 'Cards',
        'icon': Icons.view_carousel_rounded,
        'desc': 'Books displayed as large cards',
      },
    ];

    return Row(
      children: layouts.map((layout) {
        final isSelected = _settings.homeLayout == layout['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _settings.homeLayout = layout['id'] as String;
            }),
            child: Container(
              margin: EdgeInsets.only(
                right: layout['id'] != 'card' ? 10 : 0,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? _settings.currentAccentColor.withValues(alpha: 0.15)
                    : const Color(0xFF1E1610),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? _settings.currentAccentColor
                      : const Color(0xFF2E2018),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    layout['icon'] as IconData,
                    color: isSelected
                        ? _settings.currentAccentColor
                        : const Color(0xFF5A4535),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    layout['label'] as String,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: isSelected
                          ? _settings.currentAccentColor
                          : const Color(0xFF8A6A4A),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionToggles() {
    final sections = [
      {
        'title': 'Continue Reading',
        'subtitle': 'Show books you\'re currently reading',
        'icon': Icons.auto_stories_rounded,
        'value': _settings.showContinueReading,
        'onChanged': (bool v) =>
            setState(() => _settings.showContinueReading = v),
      },
      {
        'title': 'Trending Now',
        'subtitle': 'Show trending books this week',
        'icon': Icons.trending_up_rounded,
        'value': _settings.showTrending,
        'onChanged': (bool v) =>
            setState(() => _settings.showTrending = v),
      },
      {
        'title': 'Featured Books',
        'subtitle': 'Show editorially featured books',
        'icon': Icons.star_rounded,
        'value': _settings.showFeatured,
        'onChanged': (bool v) =>
            setState(() => _settings.showFeatured = v),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
      ),
      child: Column(
        children: sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          final isLast = index == sections.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _settings.currentAccentColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        section['icon'] as IconData,
                        color: _settings.currentAccentColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section['title'] as String,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 14,
                              color: const Color(0xFFC4A882),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            section['subtitle'] as String,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 11,
                              color: const Color(0xFF5A4535),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: section['value'] as bool,
                      onChanged: section['onChanged'] as ValueChanged<bool>,
                      activeThumbColor: _settings.currentAccentColor,
                      activeTrackColor:
                      _settings.currentAccentColor.withValues(alpha: 0.3),
                      inactiveThumbColor: const Color(0xFF5A4535),
                      inactiveTrackColor: const Color(0xFF3D2E1E),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.only(left: 64),
                  color: const Color(0xFF2E2018),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1610),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _settings.currentAccentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  color: _settings.currentAccentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_settings.homeLayout == 'list')
            _buildListPreview()
          else if (_settings.homeLayout == 'grid')
            _buildGridPreview()
          else
            _buildCardPreview(),
        ],
      ),
    );
  }

  Widget _buildListPreview() {
    return Column(
      children: List.generate(3, (i) {
        final titles = [
          'The Ember Throne',
          'Void Samurai',
          'Stars of Orion',
        ];
        final genres = ['Fantasy', 'Action', 'Sci-Fi'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF241A11),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF3D2E1E), width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _settings.currentAccentColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[i],
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      color: const Color(0xFFF0D9B5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    genres[i],
                    style: GoogleFonts.sourceSans3(
                      fontSize: 9,
                      color: const Color(0xFF5A4535),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGridPreview() {
    final titles = [
      'Ember Throne',
      'Void Samurai',
      'Stars of Orion',
      'Shadow Meridian',
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.65,
      children: List.generate(4, (i) {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _settings.currentAccentColor.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titles[i],
              style: GoogleFonts.sourceSans3(
                fontSize: 8,
                color: const Color(0xFFF0D9B5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCardPreview() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final titles = [
            'The Ember Throne',
            'Void Samurai',
            'Stars of Orion',
          ];
          return Container(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _settings.currentAccentColor.withValues(alpha: 0.2),
              border: Border.all(
                color: _settings.currentAccentColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  titles[i],
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 11,
                    color: const Color(0xFFF0D9B5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
