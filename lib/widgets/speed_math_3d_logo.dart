import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ultra-Modern 3D Speed Math Brand Mark & Logo
/// Replaces the generic flat purple squircle with a tangible 3D mathematical speed crest
class SpeedMath3DLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final String? subtitle;

  const SpeedMath3DLogo({
    super.key,
    this.size = 38,
    this.showText = true,
    this.subtitle,
  });

  @override
  State<SpeedMath3DLogo> createState() => _SpeedMath3DLogoState();
}

class _SpeedMath3DLogoState extends State<SpeedMath3DLogo> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;

    final logoBadge = Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s * 0.3),
        // 3D Metallic & Obsidian Multi-Stop Gradient
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Premium Slate Obsidian
            Color(0xFF0F172A), // Dark Slate
          ],
        ),
        // 3D Bevel Rim & Drop Shadows
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(s * 0.3),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 3D Top-Left Specular Glass Highlight
            Positioned(
              top: -s * 0.2,
              left: -s * 0.2,
              child: Container(
                width: s * 0.8,
                height: s * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // PrepVanta Official Brand Emblem
            Image.asset(
              'assets/images/prepvanta_icon_1024.png',
              width: s,
              height: s,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CustomPaint(
                size: Size(s * 0.72, s * 0.72),
                painter: _Math3DCrestPainter(),
              ),
            ),

            // Shimmer Reflection Sweep
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment(
                      -2.0 + (_shimmerController.value * 4.0),
                      0.0,
                    ),
                    widthFactor: 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    if (!widget.showText) return logoBadge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoBadge,
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFE0E7FF),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'PrepVanta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 9, color: AppTheme.gold),
                      SizedBox(width: 2),
                      Text(
                        'PREP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 1),
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Custom Vector Painter for a 3D Golden Mathematical Sigma-Delta Prism
/// Completely replaces the 2D flat yellow bolt with dimensional geometry
class _Math3DCrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Center offset
    canvas.translate(w * 0.05, h * 0.02);

    // 1. 3D Isometric Delta / Prism Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final Path sigmaPath = Path()
      // Top bar of Sigma
      ..moveTo(w * 0.72, h * 0.18)
      ..lineTo(w * 0.22, h * 0.18)
      // Diagonal to center vertex
      ..lineTo(w * 0.48, h * 0.48)
      // Diagonal to bottom
      ..lineTo(w * 0.22, h * 0.78)
      // Bottom bar
      ..lineTo(w * 0.72, h * 0.78)
      // Bottom thickness
      ..lineTo(w * 0.72, h * 0.65)
      ..lineTo(w * 0.38, h * 0.65)
      // Return to center
      ..lineTo(w * 0.58, h * 0.48)
      // Return to top
      ..lineTo(w * 0.38, h * 0.31)
      ..lineTo(w * 0.72, h * 0.31)
      ..close();

    // Draw shadow slightly offset
    canvas.save();
    canvas.translate(1.5, 2.0);
    canvas.drawPath(sigmaPath, shadowPaint);
    canvas.restore();

    // 2. 3D Metallic Golden Gradient for the Sigma Symbol
    final sigmaShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFEF08A), // Light bright gold
        Color(0xFFF59E0B), // Vibrant Amber gold
        Color(0xFFB45309), // Deep rich bronze
      ],
      stops: [0.0, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final sigmaPaint = Paint()
      ..shader = sigmaShader
      ..style = PaintingStyle.fill;

    canvas.drawPath(sigmaPath, sigmaPaint);

    // 3. 3D Bevel Ridge Highlight (Top edge of Sigma)
    final ridgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Path ridgePath = Path()
      ..moveTo(w * 0.72, h * 0.18)
      ..lineTo(w * 0.22, h * 0.18)
      ..lineTo(w * 0.48, h * 0.48);

    canvas.drawPath(ridgePath, ridgePaint);

    // 4. Dynamic Speed Impulse Vector: Radiant Cyan Diamond
    final impulsePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF67E8F9), // Electric cyan
          Color(0xFF06B6D4), // Deep cyan
        ],
      ).createShader(Rect.fromLTWH(w * 0.55, h * 0.38, w * 0.3, h * 0.3));

    final impulsePath = Path()
      ..moveTo(w * 0.72, h * 0.48) // right tip
      ..lineTo(w * 0.62, h * 0.40) // top
      ..lineTo(w * 0.54, h * 0.48) // left
      ..lineTo(w * 0.62, h * 0.56) // bottom
      ..close();

    canvas.drawPath(impulsePath, impulsePaint);

    // Cyan core glow dot
    final coreGlow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.62, h * 0.48), 1.8, coreGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
