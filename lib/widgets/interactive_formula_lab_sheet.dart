import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/concept_formula_model.dart';
import '../theme/app_theme.dart';

/// 🧪 Interactive Live Formula Lab Modal
/// Allows students to drag sliders, see dynamic geometric shapes reshape in real-time,
/// observe mathematical formulas compute live, and discover exam-vital Pythagorean Triplets!
class InteractiveFormulaLabSheet extends StatefulWidget {
  final ConceptFormulaModel formula;

  const InteractiveFormulaLabSheet({
    super.key,
    required this.formula,
  });

  static void show(BuildContext context, ConceptFormulaModel formula) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InteractiveFormulaLabSheet(formula: formula),
    );
  }

  @override
  State<InteractiveFormulaLabSheet> createState() => _InteractiveFormulaLabSheetState();
}

class _InteractiveFormulaLabSheetState extends State<InteractiveFormulaLabSheet> {
  late double _val1; // e.g. Length or Radius or Base
  late double _val2; // e.g. Breadth or Height or Perpendicular
  late double _val3; // e.g. Path width or Slant height

  @override
  void initState() {
    super.initState();
    final id = widget.formula.id.toLowerCase();
    if (id.contains('rect') || id.contains('tri') || id.contains('pythag')) {
      _val1 = 12.0;
      _val2 = 5.0;
      _val3 = 2.0;
    } else if (id.contains('circle')) {
      _val1 = 7.0;
      _val2 = 14.0;
      _val3 = 1.0;
    } else if (id.contains('cone') || id.contains('cylinder')) {
      _val1 = 7.0;
      _val2 = 24.0;
      _val3 = 25.0;
    } else {
      _val1 = 10.0;
      _val2 = 6.0;
      _val3 = 2.0;
    }
  }

  bool _isPythagoreanTriplet(int a, int b, int c) {
    final sides = [a, b, c]..sort();
    return (sides[0] * sides[0] + sides[1] * sides[1]) == (sides[2] * sides[2]);
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.formula.id.toLowerCase();
    final bool isRectangle = id.contains('rect');
    final bool isCircle = id.contains('circle');
    final bool isTriangle = id.contains('tri') || id.contains('pythag');
    final bool isConeOrCylinder = id.contains('cone') || id.contains('cylinder') || id.contains('solids');

    final int a = _val1.round();
    final int b = _val2.round();
    final double diagRaw = math.sqrt(a * a + b * b);
    final bool isIntDiag = (diagRaw - diagRaw.round()).abs() < 0.001;
    final int diagInt = diagRaw.round();
    final bool hasTriplet = isIntDiag && _isPythagoreanTriplet(a, b, diagInt);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.science_rounded, color: Color(0xFF38BDF8), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interactive Live Formula Lab',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text(
                          'Drag sliders to compute & discover in real-time',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // 1. Golden Triplet Discovery Alert (Appears dynamically!)
                if (hasTriplet)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF78350F), Color(0xFF451A03)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFBBF24), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOLDEN TRIPLET FOUND: ($a, $b, $diagInt)!',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFFFDE68A)),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Direct Exam Hack: In SSC CGL, you never square these! Directly write the diagonal as $diagInt cm.',
                                style: TextStyle(fontSize: 11, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. Interactive Geometry Visual Box
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(200, 110),
                      painter: _LabShapePainter(
                        isRectangle: isRectangle,
                        isCircle: isCircle,
                        isTriangle: isTriangle,
                        isConeOrCylinder: isConeOrCylinder,
                        val1: _val1,
                        val2: _val2,
                        hasTriplet: hasTriplet,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Live Values & Real-Time Calculation Cards
                const Text(
                  '⚡ REAL-TIME COMPUTED FORMULAS:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1),
                ),
                const SizedBox(height: 8),

                if (isRectangle) ...[
                  _buildResultPill('Area (क्षेत्रफल = l × b)', '$a × $b = ${a * b} cm²', const Color(0xFF10B981)),
                  _buildResultPill('Perimeter (परिमाप = 2(l + b))', '2($a + $b) = ${2 * (a + b)} cm', const Color(0xFF38BDF8)),
                  _buildResultPill(
                    'Diagonal (विकर्ण = √(l² + b²))',
                    '√($a² + $b²) = √${a * a + b * b} ≈ ${diagRaw.toStringAsFixed(2)} cm' + (hasTriplet ? ' (Exact $diagInt cm ⭐)' : ''),
                    const Color(0xFFF59E0B),
                  ),
                  _buildResultPill(
                    'Outer Path (w = ${_val3.round()} cm)',
                    '2w(l + b + 2w) = ${2 * _val3.round() * (a + b + 2 * _val3.round())} cm²',
                    const Color(0xFFEC4899),
                  ),
                ] else if (isCircle) ...[
                  _buildResultPill('Radius (r)', '$a cm', const Color(0xFF38BDF8)),
                  _buildResultPill('Circumference (परिधि = 2πr)', '2 × (22/7) × $a = ${(2 * 22 / 7 * a).toStringAsFixed(1)} cm', const Color(0xFF10B981)),
                  _buildResultPill('Area (क्षेत्रफल = πr²)', '(22/7) × $a² = ${(22 / 7 * a * a).toStringAsFixed(1)} cm²', const Color(0xFFF59E0B)),
                ] else if (isTriangle) ...[
                  _buildResultPill('Base (आधार)', '$a cm', const Color(0xFF38BDF8)),
                  _buildResultPill('Perpendicular (लम्ब)', '$b cm', const Color(0xFFEC4899)),
                  _buildResultPill('Area (क्षेत्रफल = ½ × b × h)', '½ × $a × $b = ${(0.5 * a * b).toStringAsFixed(1)} cm²', const Color(0xFF10B981)),
                  _buildResultPill('Hypotenuse (कर्ण = √(b² + p²))', '√($a² + $b²) ≈ ${diagRaw.toStringAsFixed(2)} cm' + (hasTriplet ? ' (Exact $diagInt cm ⭐)' : ''), const Color(0xFFF59E0B)),
                ] else ...[
                  _buildResultPill('Input Value 1', '$a units', const Color(0xFF38BDF8)),
                  _buildResultPill('Input Value 2', '$b units', const Color(0xFF10B981)),
                  _buildResultPill('Combined Interaction', '$a × $b = ${a * b} units²', const Color(0xFFF59E0B)),
                ],

                const SizedBox(height: 20),

                // 4. Interactive Variable Sliders
                const Text(
                  '🎛️ ADJUST VARIABLES:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1),
                ),
                const SizedBox(height: 10),

                // Slider 1
                _buildSliderRow(
                  label: isRectangle ? 'Length (l)' : (isCircle ? 'Radius (r)' : 'Base (b)'),
                  value: _val1,
                  min: 2,
                  max: 25,
                  color: const Color(0xFF38BDF8),
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _val1 = v);
                  },
                ),

                // Slider 2
                if (!isCircle) ...[
                  const SizedBox(height: 8),
                  _buildSliderRow(
                    label: isRectangle ? 'Breadth (b)' : 'Height / Perpendicular',
                    value: _val2,
                    min: 2,
                    max: 25,
                    color: const Color(0xFF10B981),
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _val2 = v);
                    },
                  ),
                ],

                // Slider 3 (Optional: Path width)
                if (isRectangle) ...[
                  const SizedBox(height: 8),
                  _buildSliderRow(
                    label: 'Path Width (w)',
                    value: _val3,
                    min: 1,
                    max: 8,
                    color: const Color(0xFFEC4899),
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _val3 = v);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPill(String title, String result, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
          Text(result, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${value.round()} cm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white12,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 3.5,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabShapePainter extends CustomPainter {
  final bool isRectangle;
  final bool isCircle;
  final bool isTriangle;
  final bool isConeOrCylinder;
  final double val1;
  final double val2;
  final bool hasTriplet;

  _LabShapePainter({
    required this.isRectangle,
    required this.isCircle,
    required this.isTriangle,
    required this.isConeOrCylinder,
    required this.val1,
    required this.val2,
    required this.hasTriplet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = hasTriplet
          ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
          : const Color(0xFF38BDF8).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = hasTriplet ? const Color(0xFFFBBF24) : const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    if (isCircle) {
      final r = (val1 / 25.0) * 45.0 + 15.0;
      canvas.drawCircle(Offset(cx, cy), r, paintFill);
      canvas.drawCircle(Offset(cx, cy), r, paintStroke);
      // Radius line
      final rPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 1.8;
      canvas.drawLine(Offset(cx, cy), Offset(cx + r, cy), rPaint);
    } else if (isTriangle) {
      final w = (val1 / 25.0) * 110.0 + 30.0;
      final h = (val2 / 25.0) * 80.0 + 20.0;
      final p1 = Offset(cx - w / 2, cy + h / 2);
      final p2 = Offset(cx + w / 2, cy + h / 2);
      final p3 = Offset(cx - w / 2, cy - h / 2);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      canvas.drawPath(path, paintFill);
      canvas.drawPath(path, paintStroke);

      // Hypotenuse highlight
      final hypPaint = Paint()
        ..color = hasTriplet ? const Color(0xFFFDE68A) : const Color(0xFFEC4899)
        ..strokeWidth = 2.5;
      canvas.drawLine(p3, p2, hypPaint);
    } else {
      // Rectangle
      final w = (val1 / 25.0) * 120.0 + 35.0;
      final h = (val2 / 25.0) * 70.0 + 20.0;
      final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);

      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paintFill);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paintStroke);

      // Diagonal line
      final diagPaint = Paint()
        ..color = hasTriplet ? const Color(0xFFFDE68A) : const Color(0xFFF59E0B)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(rect.topLeft, rect.bottomRight, diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LabShapePainter oldDelegate) {
    return oldDelegate.val1 != val1 || oldDelegate.val2 != val2 || oldDelegate.hasTriplet != hasTriplet;
  }
}
