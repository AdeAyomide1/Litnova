import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_service.dart';
import '../../shared/providers/app_settings_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _imageFile;
  bool _isLoading = false;
  bool _isSaving = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getMe();
      if (response.statusCode == 200 && mounted) {
        final user = response.data['data']['user'];
        setState(() {
          _user = user;
          _nameController.text = user['name'] ?? '';
          _usernameController.text = user['username'] ?? '';
          _bioController.text = user['bio'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Name cannot be empty',
            style: GoogleFonts.sourceSans3(color: _s.textColor),
          ),
          backgroundColor: _s.surfaceColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // In a real app, you would upload _imageFile here if it's not null
      final response = await ApiService.updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.sourceSans3(color: _s.textColor),
            ),
            backgroundColor: _s.surfaceColor,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile',
              style: GoogleFonts.sourceSans3(color: _s.textColor),
            ),
            backgroundColor: _s.surfaceColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _s.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: _s.currentAccentColor,
                      strokeWidth: 2,
                    ),
                  )
                      : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarSection(),
                        const SizedBox(height: 24),
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Your full name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: '@username',
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildTextArea(
                          controller: _bioController,
                          label: 'Bio',
                          hint: 'Tell readers about yourself...',
                        ),
                        const SizedBox(height: 16),
                        _buildEmailDisplay(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        );
      },
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
                context.go('/profile');
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _s.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: _s.borderColor, width: 0.5),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: _s.textMutedColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Edit Profile',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: _s.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final name = _user?['name'] ?? 'Reader';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: _imageFile != null 
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null,
                    gradient: _imageFile == null ? LinearGradient(
                      colors: [
                        _s.currentAccentColor.withOpacity(0.6),
                        _s.currentAccentColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null,
                  ),
                  child: _imageFile == null ? Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _s.currentAccentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: _s.bgColor, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.black87,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to change photo',
            style: GoogleFonts.sourceSans3(
              fontSize: 12,
              color: _s.currentAccentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: _s.textMutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _s.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _s.borderColor, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.sourceSans3(
              fontSize: 14, color: _s.textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 13, color: _s.textGhostColor,
              ),
              prefixIcon: Icon(
                icon, color: _s.textFaintColor, size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: _s.textMutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _s.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _s.borderColor, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: GoogleFonts.lora(
              fontSize: 14, color: _s.textColor, height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 13, color: _s.textGhostColor,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: _s.textMutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14,
          ),
          decoration: BoxDecoration(
            color: _s.surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _s.borderColor, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: _s.textGhostColor,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _user?['email'] ?? '',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14, color: _s.textFaintColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _s.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cannot change',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 10, color: _s.textGhostColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: _s.bgColor,
        border: Border(
          top: BorderSide(color: _s.borderColor, width: 0.5),
        ),
      ),
      child: GestureDetector(
        onTap: _isSaving ? null : _saveProfile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _s.currentAccentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.black87,
                strokeWidth: 2,
              ),
            )
                : Text(
              'Save Changes',
              style: GoogleFonts.sourceSans3(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
