import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Interactive Animated Triangle Visualizer
/// Demonstrates the Pythagorean theorem and right-angled triangles
/// with step-by-step real-time stroke drawing, interactive side morphing,
/// and geometric area proof (a² + b² = c²).
class InteractiveTriangleVisualizer extends StatefulWidget {
  final List<int> initialTriple;
  final bool showSelector;
  final Color themeColor;

  const InteractiveTriangleVisualizer({
    super.key,
    this.initialTriple = const [3, 4, 5],
    this.showSelector = true,
    this.themeColor = const Color(0xFF8B5CF6),
  });

  @override
  State<InteractiveTriangleVisualizer> createState() => _InteractiveTriangleVisualizerState();
}

class _InteractiveTriangleVisualizerState extends State<InteractiveTriangleVisualizer>
    with SingleTickerProviderStateMixin {
  late List<int> _currentTriple;
  int _multiplier = 1;
  bool _showAreaProof = false;

  late AnimationController _animController;
  late Animation<double> _drawAnimation;

  static const List<List<int>> standardTriples = [
    [3, 4, 5],
    [5, 12, 13],
    [8, 15, 17],
    [7, 24, 25],
    [9, 40, 41],
    [11, 60, 61],
    [12, 35, 37],
    [13, 84, 85],
    [16, 63, 65],
    [20, 21, 29],
    [28, 45, 53],
    [20, 99, 101],
  ];

  @override
  void initState() {
    super.initState();
    _currentTriple = List<int>.from(widget.initialTriple);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _drawAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant InteractiveTriangleVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTriple != widget.initialTriple) {
      setState(() {
        _currentTriple = List<int>.from(widget.initialTriple);
        _multiplier = 1;
      });
      _replayAnimation();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _replayAnimation() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
    _animController.reset();
    _animController.forward();
  }

  void _selectTriple(List<int> triple) {
    setState(() {
      _currentTriple = List<int>.from(triple);
      _multiplier = 1;
    });
    _replayAnimation();
  }

  void _setMultiplier(int k) {
    setState(() {
      _multiplier = k;
    });
    _replayAnimation();
  }

  int get a => _currentTriple[0] * _multiplier;
  int get b => _currentTriple[1] * _multiplier;
  int get c => _currentTriple[2] * _multiplier;

  @override
  Widget build(BuildContext context) {
    final aVal = a;
    final bVal = b;
    final cVal = c;

    final double area = 0.5 * aVal * bVal;
    final int perimeter = aVal + bVal + cVal;
    final double angleDeg = (math.atan2(aVal, bVal) * 180 / math.pi);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark blueprint slate
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.themeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Control Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.change_history_rounded, color: widget.themeColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interactive Triangle Concept',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Tap below to live draw & switch dimensions',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Redraw Action Button
                InkWell(
                  onTap: _replayAnimation,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: widget.themeColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.brush_rounded, size: 14, color: widget.themeColor),
                        const SizedBox(width: 5),
                        Text(
                          'Draw Again',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Main Animated Canvas Area
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Blueprint grid background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TriangleGridPainter(),
                    ),
                  ),

                  // Animated Triangle Vector Drawing
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _drawAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _AnimatedTrianglePainter(
                            progress: _drawAnimation.value,
                            a: aVal,
                            b: bVal,
                            c: cVal,
                            showAreaProof: _showAreaProof,
                            themeColor: widget.themeColor,
                          ),
                        );
                      },
                    ),
                  ),

                  // Live Drawing Status Tag
                  Positioned(
                    top: 10,
                    left: 12,
                    child: AnimatedBuilder(
                      animation: _drawAnimation,
                      builder: (context, child) {
                        final p = _drawAnimation.value;
                        String stepText = 'Base b = $bVal';
                        if (p > 0.35 && p <= 0.70) {
                          stepText = 'Height a = $aVal';
                        } else if (p > 0.70 && p < 1.0) {
                          stepText = 'Hypotenuse c = $cVal';
                        } else if (p == 1.0) {
                          stepText = 'Right Angle (90°) Verified ✓';
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p == 1.0 ? Colors.greenAccent : Colors.amberAccent,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                stepText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Toggle Area Proof button
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showAreaProof = !_showAreaProof;
                        });
                        _replayAnimation();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _showAreaProof
                              ? AppTheme.accent.withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _showAreaProof ? AppTheme.accent : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showAreaProof ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              size: 13,
                              color: _showAreaProof ? AppTheme.accent : Colors.white60,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Area Proof (a² + b² = c²)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _showAreaProof ? AppTheme.accent : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mathematical Breakdown Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Formula equation
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                          children: [
                            TextSpan(
                              text: '$aVal² + $bVal² = ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${aVal * aVal} + ${bVal * bVal} = ${cVal * cVal}',
                              style: TextStyle(
                                color: widget.themeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' = $cVal²',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PROVEN ✓',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📐 θ ≈ ${angleDeg.toStringAsFixed(1)}°',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Text(
                        'Area: ${area.toStringAsFixed(1)} sq units',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      Text(
                        'Perimeter: $perimeter',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Interactive Triple Selection Pills
          if (widget.showSelector) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SELECT A TRIPLET TO DRAW:',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: Colors.white54,
                    ),
                  ),
                  // Multiplier pills
                  Row(
                    children: [1, 2, 3].map((k) {
                      final isSelected = _multiplier == k;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: InkWell(
                          onTap: () => _setMultiplier(k),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? widget.themeColor : Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$k×',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                scrollDirection: Axis.horizontal,
                itemCount: standardTriples.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final t = standardTriples[index];
                  final isSelected = _currentTriple[0] == t[0] &&
                      _currentTriple[1] == t[1] &&
                      _currentTriple[2] == t[2];
                  return InkWell(
                    onTap: () => _selectTriple(t),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.themeColor.withValues(alpha: 0.3)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? widget.themeColor : Colors.white12,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        '(${t[0]}, ${t[1]}, ${t[2]})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _TriangleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedTrianglePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final int a; // perpendicular (height)
  final int b; // base
  final int c; // hypotenuse
  final bool showAreaProof;
  final Color themeColor;

  _AnimatedTrianglePainter({
    required this.progress,
    required this.a,
    required this.b,
    required this.c,
    required this.showAreaProof,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Determine normalized triangle proportions within canvas bounds
    final double maxW = w * 0.65;
    final double maxH = h * 0.65;

    // Aspect ratio between height (a) and base (b)
    final double aspect = a / b;
    double drawB = maxW;
    double drawA = drawB * aspect;

    if (drawA > maxH) {
      drawA = maxH;
      drawB = drawA / aspect;
    }

    // Anchor points:
    // Right angle vertex O at bottom-left
    final originX = (w - drawB) * 0.35 + 20;
    final originY = h * 0.82;

    final pO = Offset(originX, originY); // Right angle vertex
    final pB = Offset(originX + drawB, originY); // Base end
    final pA = Offset(originX, originY - drawA); // Perpendicular top

    // Step 1: Draw Base (progress 0.0 to 0.35)
    final double pBase = (progress / 0.35).clamp(0.0, 1.0);
    if (pBase > 0) {
      final currentBaseEnd = Offset.lerp(pO, pB, pBase)!;
      final basePaint = Paint()
        ..color = const Color(0xFF38BDF8) // Sky Blue
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(pO, currentBaseEnd, basePaint);

      if (pBase > 0.5) {
        _drawLabel(
          canvas,
          'b = $b',
          Offset((pO.dx + currentBaseEnd.dx) / 2, pO.dy + 12),
          const Color(0xFF38BDF8),
        );
      }
    }

    // Step 2: Draw Height (progress 0.35 to 0.70)
    final double pHeight = ((progress - 0.35) / 0.35).clamp(0.0, 1.0);
    if (pHeight > 0) {
      final currentHeightEnd = Offset.lerp(pO, pA, pHeight)!;
      final heightPaint = Paint()
        ..color = const Color(0xFFF43F5E) // Rose Red
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(pO, currentHeightEnd, heightPaint);

      if (pHeight > 0.5) {
        _drawLabel(
          canvas,
          'a = $a',
          Offset(pO.dx - 22, (pO.dy + currentHeightEnd.dy) / 2),
          const Color(0xFFF43F5E),
        );
      }
    }

    // Step 3: Draw Hypotenuse (progress 0.70 to 0.92)
    final double pHypo = ((progress - 0.70) / 0.22).clamp(0.0, 1.0);
    if (pHypo > 0) {
      final currentHypoEnd = Offset.lerp(pA, pB, pHypo)!;
      final hypoPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFF43F5E),
            themeColor,
            const Color(0xFF38BDF8),
          ],
        ).createShader(Rect.fromPoints(pA, pB))
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(pA, currentHypoEnd, hypoPaint);

      // Glowing pencil laser dot at current drawing tip
      if (pHypo < 1.0) {
        final glowPaint = Paint()
          ..color = Colors.amberAccent
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(currentHypoEnd, 6, glowPaint);
        canvas.drawCircle(currentHypoEnd, 3, Paint()..color = Colors.white);
      }

      if (pHypo > 0.5) {
        final midHypo = Offset((pA.dx + pB.dx) / 2 + 14, (pA.dy + pB.dy) / 2 - 12);
        _drawLabel(canvas, 'c = $c', midHypo, Colors.amberAccent, bold: true);
      }
    }

    // Step 4: Full Triangle Fill & Right-Angle Mark (progress 0.92 to 1.0)
    final double pFinal = ((progress - 0.92) / 0.08).clamp(0.0, 1.0);
    if (pFinal > 0) {
      // Shaded triangle interior
      final fillPath = Path()
        ..moveTo(pO.dx, pO.dy)
        ..lineTo(pB.dx, pB.dy)
        ..lineTo(pA.dx, pA.dy)
        ..close();

      final fillPaint = Paint()
        ..color = themeColor.withValues(alpha: 0.12 * pFinal)
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // Right-angle square marker (90 deg)
      const double sq = 12.0;
      final anglePath = Path()
        ..moveTo(pO.dx, pO.dy - sq)
        ..lineTo(pO.dx + sq, pO.dy - sq)
        ..lineTo(pO.dx + sq, pO.dy);

      final anglePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * pFinal)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      canvas.drawPath(anglePath, anglePaint);

      // Vertex dots
      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(pO, 3.5, dotPaint);
      canvas.drawCircle(pA, 3.5, dotPaint);
      canvas.drawCircle(pB, 3.5, dotPaint);
    }

    // Optional Area Squares (a² and b² boxes visual proof)
    if (showAreaProof && progress > 0.9) {
      final double boxAlpha = ((progress - 0.9) / 0.1).clamp(0.0, 1.0) * 0.18;

      // a² box (drawn to the left of side a)
      final boxA = Rect.fromLTWH(pA.dx - drawA * 0.45, pA.dy, drawA * 0.45, drawA);
      canvas.drawRect(
        boxA,
        Paint()
          ..color = const Color(0xFFF43F5E).withValues(alpha: boxAlpha)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        boxA,
        Paint()
          ..color = const Color(0xFFF43F5E).withValues(alpha: 0.5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
      _drawLabel(canvas, 'a² = ${a * a}', boxA.center, const Color(0xFFF43F5E), fontSize: 9);

      // b² box (drawn below side b)
      final boxB = Rect.fromLTWH(pO.dx, pO.dy, drawB, drawB * 0.35);
      canvas.drawRect(
        boxB,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: boxAlpha)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        boxB,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
      _drawLabel(canvas, 'b² = ${b * b}', boxB.center, const Color(0xFF38BDF8), fontSize: 9);
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    bool bold = false,
    double fontSize = 11,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _AnimatedTrianglePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.a != a ||
        oldDelegate.b != b ||
        oldDelegate.c != c ||
        oldDelegate.showAreaProof != showAreaProof;
  }
}
