import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Animated gradient mesh background — efek "nebula" yang bergerak halus
class AnimatedMeshBackground extends StatefulWidget {
  final Widget child;
  const AnimatedMeshBackground({super.key, required this.child});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(color: AppColors.bg),
        // Animated orbs
        AnimatedBuilder(
          animation: Listenable.merge([_controller1, _controller2]),
          builder: (context, _) {
            return CustomPaint(
              painter: _MeshPainter(
                progress1: _controller1.value,
                progress2: _controller2.value,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double progress1;
  final double progress2;

  _MeshPainter({required this.progress1, required this.progress2});

  @override
  void paint(Canvas canvas, Size size) {
    // Orb 1 — Purple, top-left area
    final orb1X = size.width * (0.1 + progress1 * 0.25);
    final orb1Y = size.height * (0.05 + progress2 * 0.15);
    _drawOrb(canvas, Offset(orb1X, orb1Y), size.width * 0.5,
        const Color(0xFF6C63FF), 0.10);

    // Orb 2 — Cyan, right area
    final orb2X = size.width * (0.6 + progress2 * 0.2);
    final orb2Y = size.height * (0.3 + progress1 * 0.2);
    _drawOrb(canvas, Offset(orb2X, orb2Y), size.width * 0.4,
        const Color(0xFF00D4FF), 0.07);

    // Orb 3 — Pink, bottom
    final orb3X = size.width * (0.3 + progress1 * 0.15);
    final orb3Y = size.height * (0.7 + progress2 * 0.1);
    _drawOrb(canvas, Offset(orb3X, orb3Y), size.width * 0.45,
        const Color(0xFFFF6584), 0.06);
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color,
      double opacity) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) =>
      oldDelegate.progress1 != progress1 || oldDelegate.progress2 != progress2;
}

/// 3D Parallax Tilt Card — bergerak mengikuti sentuhan
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final BorderRadius? borderRadius;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 6.0,
    this.borderRadius,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  double _rotateX = 0;
  double _rotateY = 0;
  late AnimationController _resetController;
  Animation<double>? _resetX;
  Animation<double>? _resetY;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    final localPos = details.localPosition;
    setState(() {
      _rotateY = ((localPos.dx - centerX) / centerX) * widget.maxTilt;
      _rotateX = -((localPos.dy - centerY) / centerY) * widget.maxTilt;
    });
  }

  void _onPanEnd(_) {
    _resetX = Tween<double>(begin: _rotateX, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );
    _resetY = Tween<double>(begin: _rotateY, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );
    _resetController.forward(from: 0).then((_) {
      setState(() {
        _rotateX = 0;
        _rotateY = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: AnimatedBuilder(
            animation: _resetController,
            builder: (context, child) {
              final rx = _resetController.isAnimating
                  ? (_resetX?.value ?? _rotateX)
                  : _rotateX;
              final ry = _resetController.isAnimating
                  ? (_resetY?.value ?? _rotateY)
                  : _rotateY;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(rx * math.pi / 180)
                  ..rotateY(ry * math.pi / 180),
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius:
                  widget.borderRadius ?? BorderRadius.circular(20),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Glassmorphism Card — kartu dengan efek kaca frosted
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool glowing;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.onTap,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F1F35),
              Color(0xFF14142A),
            ],
          ),
          border: Border.all(
            color: glowing
                ? AppColors.primary.withValues(alpha: 0.6)
                : (borderColor ?? AppColors.border),
            width: glowing ? 1.5 : 1.0,
          ),
          boxShadow: glowing
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glow Button — tombol dengan efek glow premium
class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLoading;
  final bool isOutlined;

  const GlowButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: widget.isOutlined
                ? null
                : LinearGradient(
                    colors: [color, color.withBlue(255)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: widget.isOutlined
                ? Border.all(color: color, width: 1.5)
                : null,
            boxShadow: _pressed || widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.isOutlined ? color : Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon,
                          size: 18,
                          color: widget.isOutlined ? color : Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: widget.isOutlined ? color : Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Shimmer Loading placeholder
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: const [
                Color(0xFF1A1A2E),
                Color(0xFF2A2A40),
                Color(0xFF1A1A2E),
              ],
            ),
          ),
        );
      },
    );
  }
}
