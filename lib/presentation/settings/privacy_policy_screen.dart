import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/app_settings_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsProvider();
    final theme = settings.currentTheme;

    return Scaffold(
      backgroundColor: settings.bgColor,
      appBar: AppBar(
        backgroundColor: settings.bgColor,
        elevation: 0,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.playfairDisplay(
            color: theme['text'],
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme['textMuted']),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your privacy matters to us.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: settings.currentAccentColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(theme, 'Data Collection', 'LitNOVA is a client for MangaDex. We do not store your personal reading habits on our servers. Your bookmarks and history are stored locally on your device using Hive.'),
            const SizedBox(height: 16),
            _buildSection(theme, 'External Sources', 'When you read content from sources like MangaDex, you are subject to their respective privacy policies. LitNOVA does not control how these third-party services handle data.'),
            const SizedBox(height: 16),
            _buildSection(theme, 'Cookies', 'LitNOVA does not use cookies for tracking. We only use local storage to save your application preferences and theme settings.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(Map<String, Color> theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme['text'],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.sourceSans3(
            fontSize: 14,
            height: 1.6,
            color: theme['textSecondary'],
          ),
        ),
      ],
    );
  }
}
