import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/app_settings_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About LitNOVA',
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
          children: [
            const Center(
              child: Text(
                '🦊',
                style: TextStyle(fontSize: 80),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'LitNOVA',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: settings.currentAccentColor,
              ),
            ),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.sourceSans3(
                color: theme['textMuted'],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'LitNOVA is an open-source, unrestricted reading application inspired by Tachiyomi. It provides a unified interface to browse and read manga from various sources like MangaDex without any restrictions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 16,
                height: 1.6,
                color: theme['textSecondary'],
              ),
            ),
            const SizedBox(height: 48),
            _buildInfoCard(theme, 'Open Source', 'Built with love by the community.'),
            const SizedBox(height: 16),
            _buildInfoCard(theme, 'Unrestricted', 'Full access to MangaDex library.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, Color> theme, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme['surface'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme['border'] ?? Colors.transparent, width: 0.5),
      ),
      child: Column(
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.sourceSans3(
              color: theme['textMuted'],
            ),
          ),
        ],
      ),
    );
  }
}
