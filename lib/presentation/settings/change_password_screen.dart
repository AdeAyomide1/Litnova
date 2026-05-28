import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/app_settings_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
          'Change Password',
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
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Current Password',
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              theme: theme,
              accent: settings.currentAccentColor,
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              theme: theme,
              accent: settings.currentAccentColor,
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              theme: theme,
              accent: settings.currentAccentColor,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Password change logic coming soon!'),
                    backgroundColor: settings.currentAccentColor,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: settings.currentAccentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Update Password',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required Map<String, Color> theme,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            color: theme['textSecondary'],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme['surface'],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme['border'] ?? Colors.transparent, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: TextStyle(color: theme['text']),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: theme['textMuted'],
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
