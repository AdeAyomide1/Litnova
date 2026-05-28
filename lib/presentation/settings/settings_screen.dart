import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';
import '../../shared/providers/app_settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettingsProvider _settings = AppSettingsProvider();

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

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
                _buildHeader(theme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Personalization', theme, [
                          _buildActionTile(
                            icon: Icons.home_rounded,
                            title: 'Home Screen Layout',
                            subtitle: 'Customize what you see on home',
                            onTap: () => context.push('/settings/home'),
                            theme: theme,
                          ),
                          _buildActionTile(
                            icon: Icons.palette_rounded,
                            title: 'Theme & Colors',
                            subtitle: 'Change app theme and accent color',
                            onTap: () => context.push('/settings/theme'),
                            theme: theme,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSection('Reading Experience', theme, [
                          _buildSliderTile(
                            icon: Icons.text_fields_rounded,
                            title: 'Font Size',
                            value: _settings.fontSize,
                            min: 12,
                            max: 24,
                            divisions: 6,
                            displayValue: '${_settings.fontSize.toInt()}px',
                            onChanged: (v) =>
                                setState(() => _settings.fontSize = v),
                            theme: theme,
                            accent: accent,
                          ),
                          _buildDropdownTile(
                            icon: Icons.font_download_rounded,
                            title: 'Font Family',
                            value: _settings.readerFont,
                            items: [
                              'Lora',
                              'Playfair',
                              'Georgia',
                              'Palatino',
                              'Times New Roman',
                            ],
                            onChanged: (v) =>
                                setState(() => _settings.readerFont = v!),
                            theme: theme,
                            accent: accent,
                          ),
                          _buildDropdownTile(
                            icon: Icons.wb_sunny_rounded,
                            title: 'Reader Theme',
                            value: _settings.readerTheme,
                            items: ['Dark', 'Light', 'Sepia', 'Midnight'],
                            onChanged: (v) =>
                                setState(() => _settings.readerTheme = v!),
                            theme: theme,
                            accent: accent,
                          ),
                          _buildSliderTile(
                            icon: Icons.format_line_spacing_rounded,
                            title: 'Line Spacing',
                            value: _settings.lineSpacing,
                            min: 1.0,
                            max: 2.5,
                            divisions: 6,
                            displayValue:
                            _settings.lineSpacing.toStringAsFixed(1),
                            onChanged: (v) =>
                                setState(() => _settings.lineSpacing = v),
                            theme: theme,
                            accent: accent,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSection('Notifications', theme, [
                          _buildSwitchTile(
                            icon: Icons.notifications_rounded,
                            title: 'Push Notifications',
                            subtitle: 'Receive app notifications',
                            value: _settings.pushNotifications,
                            onChanged: (v) =>
                                setState(() => _settings.pushNotifications = v),
                            theme: theme,
                            accent: accent,
                          ),
                          _buildSwitchTile(
                            icon: Icons.new_releases_rounded,
                            title: 'New Chapter Alerts',
                            subtitle: 'Get notified when new chapters drop',
                            value: _settings.newChapterAlerts,
                            onChanged: (v) =>
                                setState(() => _settings.newChapterAlerts = v),
                            theme: theme,
                            accent: accent,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSection('Downloads', theme, [
                          _buildSwitchTile(
                            icon: Icons.wifi_rounded,
                            title: 'Download on Wi-Fi Only',
                            subtitle: 'Save mobile data when downloading',
                            value: _settings.downloadOnWifi,
                            onChanged: (v) =>
                                setState(() => _settings.downloadOnWifi = v),
                            theme: theme,
                            accent: accent,
                          ),
                          _buildActionTile(
                            icon: Icons.delete_outline_rounded,
                            title: 'Clear Downloaded Books',
                            subtitle: 'Free up storage space',
                            onTap: _showClearDownloadsDialog,
                            theme: theme,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSection('Account', theme, [
                          _buildActionTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            onTap: () => context.push('/profile/edit'),
                            theme: theme,
                          ),
                          _buildActionTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Change Password',
                            onTap: () => context.push('/settings/password'),
                            theme: theme,
                          ),
                          _buildActionTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () => context.push('/settings/privacy'),
                            theme: theme,
                          ),
                          _buildActionTile(
                            icon: Icons.info_outline_rounded,
                            title: 'About LitNOVA',
                            subtitle: 'Version 1.0.0',
                            onTap: () => context.push('/settings/about'),
                            theme: theme,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildLogoutButton(theme),
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

  Widget _buildHeader(Map<String, Color> theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme['surface'],
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme['border'] ?? Colors.transparent, width: 0.5,
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
            'Settings',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: theme['text'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Map<String, Color> theme, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme['text'],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme['surface'],
            borderRadius: BorderRadius.circular(14),
            border:
            Border.all(color: theme['border'] ?? Colors.transparent, width: 0.5),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              final isLast = index == children.length - 1;
              return Column(
                children: [
                  child,
                  if (!isLast)
                    Divider(
                      height: 0.5,
                      color: theme['border'],
                      indent: 52,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
    required Map<String, Color> theme,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme['textMuted'], size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    color: theme['textSecondary'],
                  ),
                ),
              ),
              Text(
                displayValue,
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape:
              const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: accent,
              inactiveColor: theme['textGhost'],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Map<String, Color> theme,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: theme['textMuted'], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: theme['textSecondary'],
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: theme['surface'],
            underline: const SizedBox(),
            icon: Icon(
              Icons.chevron_right_rounded,
              color: theme['textFaint'],
              size: 18,
            ),
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              color: accent,
            ),
            items: items
                .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Map<String, Color> theme,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme['textMuted'], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    color: theme['textSecondary'],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 11,
                      color: theme['textFaint'],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: accent,
            activeTrackColor:
            accent.withOpacity(0.3),
            inactiveThumbColor: theme['textFaint'],
            inactiveTrackColor: theme['textGhost'],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Map<String, Color> theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme['textMuted'], size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: theme['textSecondary'],
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        color: theme['textFaint'],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme['textFaint'],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(Map<String, Color> theme) {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme['surface'],
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: const Color(0xFF6A1A1A), width: 0.5),
        ),
        child: Center(
          child: Text(
            'Log Out',
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE05555),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearDownloadsDialog() {
    final theme = _settings.currentTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme['surface'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme['border'] ?? Colors.transparent, width: 0.5),
        ),
        title: Text(
          'Clear Downloads?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            color: theme['text'],
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          'This will delete all downloaded books from your device.',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: theme['textMuted'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.sourceSans3(
                color: theme['textFaint'],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Downloads cleared!',
                    style: GoogleFonts.sourceSans3(
                      color: theme['text'],
                    ),
                  ),
                  backgroundColor: theme['surface'],
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFFE05555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final theme = _settings.currentTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme['surface'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme['border'] ?? Colors.transparent, width: 0.5),
        ),
        title: Text(
          'Log Out?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            color: theme['text'],
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of LitNOVA?',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: theme['textMuted'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.sourceSans3(
                color: theme['textFaint'],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) context.go('/login');
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFE05555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
