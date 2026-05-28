import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the terms and conditions',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passwords do not match',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password must be at least 6 characters',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await AuthService.register(
        _nameController.text.trim(),
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );
      if (user != null && mounted) {
        context.go('/home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registration failed. Please try again.',
                style: GoogleFonts.sourceSans3(
                  color: const Color(0xFFF0D9B5),
                ),
              ),
              backgroundColor: const Color(0xFF1E1610),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String message = 'Registration failed. Please try again.';
        if (e.toString().contains('Email already in use')) {
          message = 'Email already in use. Please login instead.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.sourceSans3(
                color: const Color(0xFFF0D9B5),
              ),
            ),
            backgroundColor: const Color(0xFF1E1610),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTopBar(context),
              const SizedBox(height: 32),
              _buildWelcomeText(),
              const SizedBox(height: 32),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              const SizedBox(height: 20),
              _buildTermsCheckbox(),
              const SizedBox(height: 32),
              _buildSignupButton(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildGoogleButton(),
              const SizedBox(height: 16),
              _buildLoginLink(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/login'),
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
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Lit',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF0D9B5),
                ),
              ),
              TextSpan(
                text: 'NOVA',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC8823A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create account',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF0D9B5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start your reading journey today',
          style: GoogleFonts.lora(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF7A6045),
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
    bool obscure = false,
    bool? showObscure,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sourceSans3(
            fontSize: 13,
            color: const Color(0xFF8A6A4A),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1610),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2E2018), width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              color: const Color(0xFFF0D9B5),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: const Color(0xFF3D2E1E),
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF5A4535),
                size: 18,
              ),
              suffixIcon: onToggleObscure != null
                  ? GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  showObscure == true
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF5A4535),
                  size: 18,
                ),
              )
                  : null,
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

  Widget _buildNameField() {
    return _buildInputField(
      controller: _nameController,
      label: 'Full Name',
      hint: 'Your name',
      icon: Icons.person_outline_rounded,
    );
  }

  Widget _buildEmailField() {
    return _buildInputField(
      controller: _emailController,
      label: 'Email',
      hint: 'your@email.com',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return _buildInputField(
      controller: _passwordController,
      label: 'Password',
      hint: '••••••••',
      icon: Icons.lock_outlined,
      obscure: _obscurePassword,
      showObscure: _obscurePassword,
      onToggleObscure: () =>
          setState(() => _obscurePassword = !_obscurePassword),
    );
  }

  Widget _buildConfirmPasswordField() {
    return _buildInputField(
      controller: _confirmPasswordController,
      label: 'Confirm Password',
      hint: '••••••••',
      icon: Icons.lock_outlined,
      obscure: _obscureConfirm,
      showObscure: _obscureConfirm,
      onToggleObscure: () =>
          setState(() => _obscureConfirm = !_obscureConfirm),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreeToTerms
                  ? const Color(0xFFC8823A)
                  : const Color(0xFF1E1610),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _agreeToTerms
                    ? const Color(0xFFC8823A)
                    : const Color(0xFF3D2E1E),
                width: 0.5,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(
              Icons.check_rounded,
              color: Color(0xFF1C1510),
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
                      color: const Color(0xFF5A4535),
                    ),
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: const Color(0xFFC8823A),
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: const Color(0xFF5A4535),
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: const Color(0xFFC8823A),
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

  Widget _buildSignupButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _signup,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFC8823A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Color(0xFF1C1510),
              strokeWidth: 2,
            ),
          )
              : Text(
            'Create Account',
            style: GoogleFonts.sourceSans3(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1510),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 0.5, color: const Color(0xFF2E2018)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: GoogleFonts.sourceSans3(
              fontSize: 12,
              color: const Color(0xFF5A4535),
            ),
          ),
        ),
        Expanded(
          child: Container(height: 0.5, color: const Color(0xFF2E2018)),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1610),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2E2018), width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF241A11),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC8823A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: const Color(0xFFC4A882),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
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
    );
  }
}
