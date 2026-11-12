import 'package:flutter/material.dart';

/// Custom Crossroads "108" 4-way Factor Intersection Emblem
class Crossroads108Logo extends StatelessWidget {
  final double size;

  const Crossroads108Logo({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final bool compact = size <= 54;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CrossroadsPainter(),
          ),
          // Top arm label
          Positioned(
            top: 0,
            child: _armTag(compact ? '12×9' : '12×9', compact),
          ),
          // Bottom arm label
          Positioned(
            bottom: 0,
            child: _armTag(compact ? '18×6' : '18×6', compact),
          ),
          // Left arm label
          Positioned(
            left: 0,
            child: _armTag(compact ? '27×4' : '27×4', compact),
          ),
          // Right arm label
          Positioned(
            right: 0,
            child: _armTag(compact ? '36×3' : '36×3', compact),
          ),
          // Center "108" badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size * 0.12,
              vertical: size * 0.04,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(size * 0.18),
              border: Border.all(
                color: const Color(0xFFF59E0B),
                width: compact ? 1.3 : 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              '108',
              style: TextStyle(
                color: const Color(0xFFFDE68A),
                fontSize: compact ? 9.5 : 13,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _armTag(String label, bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 2.5 : 4, vertical: 0.5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF06B6D4).withValues(alpha: 0.55),
          width: 0.7,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF67E8F9),
          fontSize: compact ? 5.6 : 7.5,
          fontWeight: FontWeight.w800,
          height: 1.05,
        ),
      ),
    );
  }
}

class _CrossroadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.7)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(center.dx, 4), Offset(center.dx, size.height - 4), paint);
    canvas.drawLine(Offset(4, center.dy), Offset(size.width - 4, center.dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
