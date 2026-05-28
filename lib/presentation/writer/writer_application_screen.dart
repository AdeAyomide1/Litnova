import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_settings_provider.dart';

class WriterApplicationScreen extends StatefulWidget {
  const WriterApplicationScreen({super.key});

  @override
  State<WriterApplicationScreen> createState() =>
      _WriterApplicationScreenState();
}

class _WriterApplicationScreenState extends State<WriterApplicationScreen> {
  final AppSettingsProvider _s = AppSettingsProvider();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _sampleController = TextEditingController();
  final _socialController = TextEditingController();
  final _reasonController = TextEditingController();

  String _selectedGenre = 'Fantasy';
  String _selectedFormat = 'Novel';
  bool _hasPublishedBefore = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _isSubmitted = false;
  int _currentStep = 0;

  final List<String> _genres = [
    'Fantasy',
    'Sci-Fi',
    'Romance',
    'Thriller',
    'Horror',
    'Comedy',
    'Drama',
    'Action',
    'Mystery',
    'Historical',
  ];

  final List<String> _formats = [
    'Novel',
    'Manga',
    'Comic',
    'Webtoon',
    'Audio Story',
    'Multiple Formats',
  ];

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Personal Info', 'icon': Icons.person_outline_rounded},
    {'title': 'Writing Style', 'icon': Icons.edit_outlined},
    {'title': 'Sample Work', 'icon': Icons.article_outlined},
    {'title': 'Review', 'icon': Icons.check_circle_outline_rounded},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _sampleController.dispose();
    _socialController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (context, _) {
        if (_isSubmitted) return _buildSuccessScreen(context);

        return Scaffold(
          backgroundColor: _s.bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildStepIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepContent(),
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
                border: Border.all(
                  color: _s.borderColor, width: 0.5,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: _s.textMutedColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Become a Writer',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: _s.textColor,
                ),
              ),
              Text(
                'Step ${_currentStep + 1} of ${_steps.length}',
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  color: _s.textFaintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: _steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          final isLast = index == _steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (index < _currentStep) {
                        setState(() => _currentStep = index);
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? _s.currentAccentColor
                                : isActive
                                ? _s.currentAccentColor.withOpacity(0.15)
                                : _s.surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive || isCompleted
                                  ? _s.currentAccentColor
                                  : _s.borderColor,
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_rounded
                                : step['icon'] as IconData,
                            color: isCompleted
                                ? Colors.black87
                                : isActive
                                ? _s.currentAccentColor
                                : _s.textGhostColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['title'] as String,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 9,
                            color: isActive || isCompleted
                                ? _s.currentAccentColor
                                : _s.textGhostColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: index < _currentStep
                          ? _s.currentAccentColor
                          : _s.borderColor,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildWritingStyleStep();
      case 2:
        return _buildSampleWorkStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Tell us about yourself',
          'Share your identity as a writer so readers can connect with you.',
        ),
        const SizedBox(height: 24),
        _buildInputField(
          controller: _nameController,
          label: 'Pen Name / Author Name',
          hint: 'What should readers call you?',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildTextAreaField(
          controller: _bioController,
          label: 'Author Bio',
          hint:
          'Tell readers about yourself, your writing journey and what inspires you...',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _socialController,
          label: 'Social Media / Website (Optional)',
          hint: 'Twitter, Instagram, or personal website',
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'I have published work before',
          subtitle: 'On other platforms like Wattpad, Webtoon, etc.',
          value: _hasPublishedBefore,
          onChanged: (v) => setState(() => _hasPublishedBefore = v),
        ),
      ],
    );
  }

  Widget _buildWritingStyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Your writing style',
          'Help us understand what kind of content you create.',
        ),
        const SizedBox(height: 24),
        Text(
          'Primary Genre',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: _s.textMutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genres.map((genre) {
            final isSelected = genre == _selectedGenre;
            return GestureDetector(
              onTap: () => setState(() => _selectedGenre = genre),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _s.currentAccentColor
                      : _s.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _s.currentAccentColor
                        : _s.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  genre,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: isSelected
                        ? Colors.black87
                        : _s.textMutedColor,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Content Format',
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: _s.textMutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _formats.map((format) {
            final isSelected = format == _selectedFormat;
            return GestureDetector(
              onTap: () => setState(() => _selectedFormat = format),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _s.currentAccentColor
                      : _s.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _s.currentAccentColor
                        : _s.borderColor,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  format,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: isSelected
                        ? Colors.black87
                        : _s.textMutedColor,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildTextAreaField(
          controller: _reasonController,
          label: 'Why do you want to publish on LitNOVA?',
          hint: 'Tell us your motivation for joining our platform...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSampleWorkStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Share a sample',
          'Give us a taste of your writing. This helps our team review your application.',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _s.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _s.borderColor, width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: _s.currentAccentColor,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Write at least 300 words. This is your first impression — make it count!',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    color: _s.textMutedColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextAreaField(
          controller: _sampleController,
          label: 'Sample Writing',
          hint:
          'Paste or write a sample of your work here. This can be the opening chapter, a key scene, or any section that best represents your style...',
          maxLines: 12,
        ),
        const SizedBox(height: 16),
        // Upload option
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _s.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _s.borderColor,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upload_file_rounded,
                  color: _s.textFaintColor,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Or upload a file',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: _s.textFaintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, DOCX, or TXT — max 10MB',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    color: _s.textGhostColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          'Review your application',
          'Make sure everything looks good before submitting.',
        ),
        const SizedBox(height: 24),
        _buildReviewCard('Author Name',
            _nameController.text.isEmpty ? 'Not provided' : _nameController.text),
        _buildReviewCard('Primary Genre', _selectedGenre),
        _buildReviewCard('Content Format', _selectedFormat),
        _buildReviewCard('Previously Published',
            _hasPublishedBefore ? 'Yes' : 'No'),
        _buildReviewCard(
          'Bio',
          _bioController.text.isEmpty
              ? 'Not provided'
              : _bioController.text.length > 80
              ? '${_bioController.text.substring(0, 80)}...'
              : _bioController.text,
        ),
        _buildReviewCard(
          'Sample Work',
          _sampleController.text.isEmpty
              ? 'Not provided'
              : '${_sampleController.text.split(' ').length} words written',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _s.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _s.borderColor, width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What happens next?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _s.textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildNextStep('1', 'Our team reviews your application'),
              _buildNextStep('2', 'You\'ll be notified within 3-5 business days'),
              _buildNextStep('3', 'If approved, your writer dashboard unlocks'),
              _buildNextStep('4', 'Start uploading your first book!'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: _agreeToTerms
                      ? _s.currentAccentColor
                      : _s.surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _agreeToTerms
                        ? _s.currentAccentColor
                        : _s.textGhostColor,
                    width: 0.5,
                  ),
                ),
                child: _agreeToTerms
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.black87,
                  size: 14,
                )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to the ',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 13,
                          color: _s.textFaintColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Writer Terms of Service',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 13,
                          color: _s.currentAccentColor,
                        ),
                      ),
                      TextSpan(
                        text:
                        ' and confirm that all submitted content is my original work.',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 13,
                          color: _s.textFaintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _s.currentAccentColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: _s.currentAccentColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  color: _s.currentAccentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.sourceSans3(
              fontSize: 13,
              color: _s.textMutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _s.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _s.borderColor, width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                color: _s.textFaintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: _s.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: _s.textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.lora(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: _s.textMutedColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
            border: Border.all(
              color: _s.borderColor, width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              color: _s.textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: _s.textGhostColor,
              ),
              prefixIcon: Icon(
                icon,
                color: _s.textFaintColor,
                size: 18,
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

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
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
            border: Border.all(
              color: _s.borderColor, width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.lora(
              fontSize: 14,
              color: _s.textColor,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: _s.textGhostColor,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _s.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _s.borderColor, width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: _s.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    color: _s.textFaintColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _s.currentAccentColor,
            activeTrackColor: _s.currentAccentColor.withOpacity(0.3),
            inactiveThumbColor: _s.textFaintColor,
            inactiveTrackColor: _s.textGhostColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _steps.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: _s.bgColor,
        border: Border(
          top: BorderSide(color: _s.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            GestureDetector(
              onTap: () => setState(() => _currentStep--),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _s.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _s.borderColor, width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: _s.textMutedColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: GestureDetector(
              onTap: isLastStep
                  ? (_agreeToTerms ? _submitApplication : null)
                  : () => setState(() => _currentStep++),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isLastStep && !_agreeToTerms
                      ? _s.textGhostColor
                      : _s.currentAccentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black87,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    isLastStep ? 'Submit Application' : 'Next',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isLastStep && !_agreeToTerms
                          ? _s.textFaintColor
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: _s.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _s.currentAccentColor.withOpacity(0.1),
                  border: Border.all(
                    color: _s.currentAccentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: _s.currentAccentColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Application Submitted!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: _s.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for applying to become a LitNOVA writer. Our team will review your application and get back to you within 3-5 business days.',
                style: GoogleFonts.lora(
                  fontSize: 14,
                  color: _s.textMutedColor,
                  height: 1.7,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _s.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _s.borderColor, width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildNextStep('1', 'Application under review'),
                    _buildNextStep('2', 'Email notification sent to you'),
                    _buildNextStep('3', 'Check notifications in the app'),
                    _buildNextStep('4', 'Writer dashboard unlocks on approval'),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _s.currentAccentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/profile');
                  }
                },
                child: Text(
                  'View my profile',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    color: _s.textFaintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
