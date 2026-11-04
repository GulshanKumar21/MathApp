import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/practice/speed_test_30s_screen.dart';
import 'bouncing_card.dart';

/// Compact & Clear 30-Second Speed Test Card
/// Simple English language, clear speed metric, and directly launches the 30-second live test!
class MentalSpeedometerCard extends StatelessWidget {
  final double avgSpeedSeconds; // e.g. 2.4s
  final int totalQuestionsSolved;
  final String? targetExam;

  const MentalSpeedometerCard({
    super.key,
    required this.avgSpeedSeconds,
    required this.totalQuestionsSolved,
    this.targetExam,
  });

  @override
  Widget build(BuildContext context) {
    final double displaySpeed = avgSpeedSeconds > 0 ? avgSpeedSeconds : 3.0;

    String speedLabel;
    String speedEmoji;
    Color speedColor;

    if (displaySpeed <= 2.2) {
      speedLabel = 'Superfast Pace';
      speedEmoji = '⚡';
      speedColor = const Color(0xFF10B981); // Emerald
    } else if (displaySpeed <= 3.8) {
      speedLabel = 'Fast Pace';
      speedEmoji = '🚀';
      speedColor = const Color(0xFF06B6D4); // Cyan
    } else if (displaySpeed <= 5.5) {
      speedLabel = 'Good Pace';
      speedEmoji = '🏃';
      speedColor = const Color(0xFFF59E0B); // Amber
    } else {
      speedLabel = 'Practice Needed';
      speedEmoji = '🐢';
      speedColor = const Color(0xFFEF4444); // Red
    }

    return BouncingCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SpeedTest30sScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF131D31),
              Color(0xFF0D1424),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF24324D),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Speed Icon Badge
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: speedColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: speedColor.withValues(alpha: 0.35), width: 1.1),
              ),
              child: Icon(Icons.speed_rounded, color: speedColor, size: 26),
            ),
            const SizedBox(width: 14),

            // Middle: Title & Speed Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Text(
                          '30s Speed Test',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: speedColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$speedEmoji $speedLabel',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: speedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          displaySpeed.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'sec/answer',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.white30, fontSize: 12)),
                        const SizedBox(width: 8),
                        const Text(
                          'Live Speed Drill ⏱️',
                          style: TextStyle(fontSize: 11, color: Color(0xFFFDE047), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right: Play / Start Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
