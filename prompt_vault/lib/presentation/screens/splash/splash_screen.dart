import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Particle animation
  late AnimationController _particleController;
  // Logo assembly animation
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  // Text animation
  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  // Progress animation
  late AnimationController _progressController;

  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _generateParticles();

    // Particle controller — continuous
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _logoRotation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Progress
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppConfig.splashDurationMs - 500),
    );

    _runAnimationSequence();
  }

  void _generateParticles() {
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 3 + 1,
        speed: _rng.nextDouble() * 0.3 + 0.1,
        opacity: _rng.nextDouble() * 0.6 + 0.2,
        color: i % 3 == 0
            ? AppColors.primary
            : i % 3 == 1
                ? AppColors.accent
                : AppColors.secondary,
        phase: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  Future<void> _runAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    _progressController.forward();
    await Future.delayed(
        Duration(milliseconds: AppConfig.splashDurationMs - 300));
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Animated background orbs
          _buildBackgroundOrbs(),
          // Particle field
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              painter:
                  _ParticlePainter(_particles, _particleController.value),
              child: const SizedBox.expand(),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, child) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value,
                        child: child,
                      ),
                    ),
                  ),
                  child: _buildLogo(),
                ),
                const SizedBox(height: 24),
                // App name + tagline
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, child) => FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppConfig.appName,
                        style: AppTextStyles.displayLarge.copyWith(
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ).createShader(
                                const Rect.fromLTWH(0, 0, 200, 60)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Koleksi Prompt Engineering Pribadi',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Progress indicator
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, child) => FadeTransition(
                    opacity: _textOpacity,
                    child: child,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (_, __) => Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary),
                              minHeight: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Memuat vault...',
                            style: AppTextStyles.captionText,
                          ),
                        ],
                      ),
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

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text('⚡', style: TextStyle(fontSize: 48)),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = (p.y + progress * p.speed) % 1.0;
      final dx = p.x + math.sin(progress * math.pi * 2 + p.phase) * 0.03;
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * (1 - dy * 0.5))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
