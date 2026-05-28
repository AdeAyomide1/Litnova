import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _taglineFade;
  late Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (mounted) {
        final isLoggedIn = await AuthService.isLoggedIn();
        if (mounted) {
          if (isLoggedIn) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D08),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ParticlePainter(),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC8823A).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4A2C0A),
                              Color(0xFF8B4513),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: const Color(0xFFC8823A).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC8823A).withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFFF0D9B5),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Lit',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF0D9B5),
                                letterSpacing: 2,
                              ),
                            ),
                            TextSpan(
                              text: 'NOVA',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFC8823A),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _taglineFade,
                      child: child,
                    );
                  },
                  child: Text(
                    'Your world of stories',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF7A6045),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _progressFade,
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: const LinearProgressIndicator(
                              backgroundColor: Color(0xFF1E1610),
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFFC8823A),
                              ),
                              minHeight: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading your library...',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 12,
                            color: const Color(0xFF3D2E1E),
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
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8823A).withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.15),
      Offset(size.width * 0.05, size.height * 0.6),
      Offset(size.width * 0.95, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.9),
      Offset(size.width * 0.8, size.height * 0.85),
      Offset(size.width * 0.5, size.height * 0.05),
    ];

    final radii = [60.0, 80.0, 50.0, 70.0, 90.0, 55.0, 65.0];

    for (int i = 0; i < positions.length; i++) {
      canvas.drawCircle(positions[i], radii[i], paint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFC8823A).withValues(alpha: 0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.1),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.9),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
