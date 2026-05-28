import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your email and password',
            style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
          ),
          backgroundColor: const Color(0xFF1E1610),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (user != null && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed. Check your email and password.',
              style: GoogleFonts.sourceSans3(color: const Color(0xFFF0D9B5)),
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
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 48),
              _buildWelcomeText(),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 12),
              _buildForgotPassword(),
              const SizedBox(height: 32),
              _buildLoginButton(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildGoogleButton(),
              const SizedBox(height: 16),
              _buildSignupLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Lit',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF0D9B5),
            ),
          ),
          TextSpan(
            text: 'NOVA',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFC8823A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF0D9B5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your reading journey',
          style: GoogleFonts.lora(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF7A6045),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
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
            border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              color: const Color(0xFFF0D9B5),
            ),
            decoration: InputDecoration(
              hintText: 'your@email.com',
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: const Color(0xFF3D2E1E),
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF5A4535),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
            border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              color: const Color(0xFFF0D9B5),
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: const Color(0xFF3D2E1E),
              ),
              prefixIcon: const Icon(
                Icons.lock_outlined,
                color: Color(0xFF5A4535),
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                ),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF5A4535),
                  size: 18,
                ),
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Forgot password?',
        style: GoogleFonts.sourceSans3(
          fontSize: 13,
          color: const Color(0xFFC8823A),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _login,
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
            'Sign In',
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
          border: Border.all(color: const Color(0xFF2E2018), width: 0.5),
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

  Widget _buildSignupLink() {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/signup'),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account? ",
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: const Color(0xFF5A4535),
                ),
              ),
              TextSpan(
                text: 'Sign up',
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
