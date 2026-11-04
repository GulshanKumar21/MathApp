import 'dart:math';
import 'package:flutter/material.dart';
import 'bouncing_card.dart';

/// Top-tier modern animated Hero Banner inspired by top consumer apps (Swiggy, Duolingo, CRED)
/// Features a custom animated rocket & orbital math particles, live sprint stats, and dynamic CTA
class AnimatedMathHeroBanner extends StatefulWidget {
  final int todaySolved;
  final int dailyTarget;
  final int streakDays;
  final VoidCallback onStartSprint;
  final VoidCallback? onExploreTables;

  const AnimatedMathHeroBanner({
    super.key,
    required this.todaySolved,
    required this.dailyTarget,
    required this.streakDays,
    required this.onStartSprint,
    this.onExploreTables,
  });

  @override
  State<AnimatedMathHeroBanner> createState() => _AnimatedMathHeroBannerState();
}

class _AnimatedMathHeroBannerState extends State<AnimatedMathHeroBanner> with TickerProviderStateMixin {
  late AnimationController _flightController;
  late AnimationController _particlesController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // Continuous floating bobbing motion for the speed rocket
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Continuous orbital rotation for math symbols
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // Shimmer wave for quick CTA button
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _flightController.dispose();
    _particlesController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF131D31), // Executive Midnight Slate
            Color(0xFF0E1626), // Deep Slate Navy
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF24324D),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. Background Animated Particle Canvas (Math Glyphs & Nebula Orbs)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particlesController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _MathGalaxyPainter(
                      progress: _particlesController.value,
                    ),
                  );
                },
              ),
            ),

            // 2. Foreground Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status Pill Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _flightController,
                              builder: (context, _) => Transform.scale(
                                scale: 0.85 + (_flightController.value * 0.35),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'SPEED BOOST ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.todaySolved}/${widget.dailyTarget} Today',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Middle Section: Dynamic Catchphrase & Animated Rocket Graphic
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text Info
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Master 2-Second\nSpeed Math 🚀',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Calculations without pen-paper for SSC CGL, Banking & CAT exams.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCBD5E1),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animated Rocket & Flame Canvas
                      Expanded(
                        flex: 4,
                        child: AnimatedBuilder(
                          animation: _flightController,
                          builder: (context, _) {
                            final double bobbing = sin(_flightController.value * pi) * 6.0;
                            return Transform.translate(
                              offset: Offset(0, bobbing),
                              child: SizedBox(
                                height: 95,
                                child: CustomPaint(
                                  painter: _SpeedRocketPainter(
                                    flameFlicker: _flightController.value,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Primary Rapid Speed Sprint CTA (Tables is already directly accessible on top)
                  BouncingCard(
                    onTap: widget.onStartSprint,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bolt_rounded, color: Color(0xFFFDE047), size: 19),
                          SizedBox(width: 8),
                          Text(
                            '⚡ Start Rapid Multipliers',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 0.3,
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
      ),
    );
  }
}

/// Custom painter that draws floating starry particles & soft glowing nebulas (NO text collision!)
class _MathGalaxyPainter extends CustomPainter {
  final double progress;

  _MathGalaxyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint glowPaint = Paint()..style = PaintingStyle.fill;

    // Glowing nebula circles
    glowPaint.color = const Color(0xFF818CF8).withValues(alpha: 0.09);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 55, glowPaint);

    glowPaint.color = const Color(0xFFEC4899).withValues(alpha: 0.07);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.35), 45, glowPaint);

    // Subtle twinkling starry particle dots
    final starOffsets = [
      Offset(size.width * 0.15, size.height * 0.20),
      Offset(size.width * 0.45, size.height * 0.15),
      Offset(size.width * 0.70, size.height * 0.18),
      Offset(size.width * 0.88, size.height * 0.55),
      Offset(size.width * 0.30, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.35),
    ];

    for (int i = 0; i < starOffsets.length; i++) {
      final double wave = (sin((progress * 2 * pi) + (i * 1.5)) + 1) / 2;
      final double alpha = 0.25 + (wave * 0.45);
      final double radius = 1.2 + (wave * 0.8);
      final Paint starPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(starOffsets[i], radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MathGalaxyPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Custom painter for an animated Vector Rocket with glowing engine jet & exhaust flame
class _SpeedRocketPainter extends CustomPainter {
  final double flameFlicker;

  _SpeedRocketPainter({required this.flameFlicker});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width * 0.55;
    final double cy = size.height * 0.45;

    // Glowing aura behind rocket
    final Paint auraPaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(cx, cy), 32, auraPaint);

    // Rocket Body (sleek angled rocket pointing top-right)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-pi / 4); // 45-degree angle

    // Rocket Exhaust Jet Flame (Animated with flicker)
    final double flameLen = 22.0 + (flameFlicker * 10.0);
    final Path flamePath = Path()
      ..moveTo(-7, 24)
      ..quadraticBezierTo(0, 24 + flameLen, 0, 24 + flameLen)
      ..quadraticBezierTo(0, 24 + flameLen, 7, 24)
      ..close();

    final Paint flamePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB703), Color(0xFFFB8500), Color(0xFFE63946)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-7, 24, 14, flameLen));
    canvas.drawPath(flamePath, flamePaint);

    // Inner white flame core
    final Path innerFlame = Path()
      ..moveTo(-3, 24)
      ..lineTo(0, 24 + (flameLen * 0.6))
      ..lineTo(3, 24)
      ..close();
    canvas.drawPath(innerFlame, Paint()..color = Colors.white.withValues(alpha: 0.9));

    // Rocket Wings / Fins
    final Paint finPaint = Paint()..color = const Color(0xFFEC4899);
    final Path leftFin = Path()
      ..moveTo(-12, 10)
      ..lineTo(-22, 22)
      ..lineTo(-10, 22)
      ..close();
    canvas.drawPath(leftFin, finPaint);

    final Path rightFin = Path()
      ..moveTo(12, 10)
      ..lineTo(22, 22)
      ..lineTo(10, 22)
      ..close();
    canvas.drawPath(rightFin, finPaint);

    // Rocket Fuselage (White/Silver streamlined hull)
    final Path hullPath = Path()
      ..moveTo(0, -28) // Rocket nose
      ..cubicTo(14, -14, 13, 14, 11, 24)
      ..lineTo(-11, 24)
      ..cubicTo(-13, 14, -14, -14, 0, -28)
      ..close();

    final Paint hullPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFE2E8F0), Color(0xFF94A3B8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-14, -28, 28, 52));
    canvas.drawPath(hullPath, hullPaint);

    // Rocket Cockpit Window (Cyan glowing glass circle)
    final Paint windowBorder = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(const Offset(0, -4), 7, windowBorder);
    final Paint windowGlass = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(const Offset(0, -4), 5, windowGlass);
    final Paint windowGlare = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-1.5, -5.5), 1.8, windowGlare);

    // Rocket Nose Cone Tip Accent (Indigo/Cyan tip)
    final Path tipPath = Path()
      ..moveTo(0, -28)
      ..lineTo(5, -18)
      ..lineTo(-5, -18)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = const Color(0xFF6366F1));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpeedRocketPainter oldDelegate) =>
      oldDelegate.flameFlicker != flameFlicker;
}
