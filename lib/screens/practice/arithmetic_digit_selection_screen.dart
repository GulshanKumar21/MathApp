import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import '../practice/practice_quiz_screen.dart';
import '../auth/auth_screen.dart';

class ArithmeticDigitSelectionScreen extends StatefulWidget {
  final TopicType type;

  const ArithmeticDigitSelectionScreen({
    super.key,
    required this.type,
  });

  @override
  State<ArithmeticDigitSelectionScreen> createState() => _ArithmeticDigitSelectionScreenState();
}

class _ArithmeticDigitSelectionScreenState extends State<ArithmeticDigitSelectionScreen> {
  int _questionCount = 10;
  QuizTimerDifficulty _timerDifficulty = QuizTimerDifficulty.medium;
  int? _selectedMaxLimit; // null = Standard (All), 20, 50, 100, or custom integer

  String get _operationTitle {
    switch (widget.type) {
      case TopicType.addition:
        return 'Speed Addition';
      case TopicType.subtraction:
        return 'Speed Subtraction';
      case TopicType.hardMultiplier:
      case TopicType.tables:
        return 'Speed Multiplication';
      case TopicType.division:
        return 'Rapid Division';
      default:
        return 'Calculation Drills';
    }
  }

  String get _operationSymbol {
    switch (widget.type) {
      case TopicType.addition:
        return '+';
      case TopicType.subtraction:
        return '−';
      case TopicType.hardMultiplier:
      case TopicType.tables:
        return '×';
      case TopicType.division:
        return '÷';
      default:
        return '⚡';
    }
  }

  Color get _themeColor {
    switch (widget.type) {
      case TopicType.addition:
        return const Color(0xFF10B981); // Emerald Green
      case TopicType.subtraction:
        return const Color(0xFFF97316); // Vibrant Orange
      case TopicType.hardMultiplier:
      case TopicType.tables:
        return const Color(0xFFEC4899); // Neon Pink/Rose
      case TopicType.division:
        return const Color(0xFF14B8A6); // Cyan Teal
      default:
        return AppTheme.accent;
    }
  }

  IconData get _operationIcon {
    switch (widget.type) {
      case TopicType.addition:
        return Icons.add_rounded;
      case TopicType.subtraction:
        return Icons.remove_rounded;
      case TopicType.hardMultiplier:
      case TopicType.tables:
        return Icons.close_rounded;
      case TopicType.division:
        return Icons.safety_divider_rounded;
      default:
        return Icons.calculate_rounded;
    }
  }

  String _getExample(int digits) {
    if (_selectedMaxLimit != null) {
      final lim = _selectedMaxLimit!;
      switch (widget.type) {
        case TopicType.addition:
          final a1 = min(lim, max(2, (lim * 0.7).round()));
          final b1 = min(lim, max(2, (lim * 0.4).round()));
          final a2 = min(lim, max(2, (lim * 0.9).round()));
          final b2 = min(lim, max(2, (lim * 0.5).round()));
          return '$a1 + $b1 = ${a1 + b1}   •   $a2 + $b2 = ${a2 + b2}  (All ≤ $lim)';
        case TopicType.subtraction:
          final a1 = lim;
          final b1 = max(1, (lim * 0.4).round());
          final a2 = max(2, (lim * 0.85).round());
          final b2 = max(1, (lim * 0.35).round());
          return '$a1 − $b1 = ${a1 - b1}   •   $a2 − $b2 = ${a2 - b2}  (All ≤ $lim)';
        case TopicType.hardMultiplier:
        case TopicType.tables:
          final a1 = min(lim, 12);
          final b1 = min(lim, 8);
          final a2 = lim;
          final b2 = min(lim, 9);
          return '$a1 × $b1 = ${a1 * b1}   •   $a2 × $b2 = ${a2 * b2}  (All ≤ $lim)';
        case TopicType.division:
          final d1 = min(max(2, lim ~/ 3), 6);
          final q1 = min(max(2, lim ~/ d1), 8);
          final div1 = d1 * q1;
          return '$div1 ÷ $d1 = $q1  (All ≤ $lim)';
        default:
          return 'Numbers strictly capped at ≤ $lim';
      }
    }

    switch (widget.type) {
      case TopicType.addition:
        if (digits == 1) return '7 + 8 = 15   •   9 + 6 = 15';
        if (digits == 2) return '47 + 68 = 115   •   84 + 39 = 123';
        if (digits == 3) return '348 + 592 = 940   •   627 + 285 = 912';
        return '2458 + 3791 = 6249   •   5824 + 1967 = 7791';
      case TopicType.subtraction:
        if (digits == 1) return '14 − 8 = 6   •   9 − 4 = 5';
        if (digits == 2) return '83 − 29 = 54   •   91 − 47 = 44';
        if (digits == 3) return '724 − 389 = 335   •   812 − 467 = 345';
        return '8105 − 4639 = 3466   •   7420 − 2895 = 4525';
      case TopicType.hardMultiplier:
      case TopicType.tables:
        if (digits == 1) return '7 × 8 = 56   •   9 × 6 = 54';
        if (digits == 2) return '24 × 16 = 384   •   35 × 12 = 420';
        if (digits == 3) return '125 × 14 = 1750   •   240 × 15 = 3600';
        return '1250 × 8 = 10000   •   2400 × 6 = 14400';
      case TopicType.division:
        if (digits == 1) return '56 ÷ 7 = 8   •   36 ÷ 4 = 9';
        if (digits == 2) return '96 ÷ 4 = 24   •   84 ÷ 6 = 14';
        if (digits == 3) return '864 ÷ 6 = 144   •   756 ÷ 4 = 189';
        return '4560 ÷ 8 = 570   •   7320 ÷ 6 = 1220';
      default:
        return '12 × 12 = 144';
    }
  }

  void _launchQuizForDigits(int digits, String levelName) {
    final state = context.read<AppStateProvider>();
    if (state.isGuestLimitReached) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(initialIsLogin: false, isMandatory: true),
        ),
      );
      return;
    }

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
      type: widget.type,
      digits: digits,
      count: _questionCount,
      maxNumberLimit: _selectedMaxLimit,
    );

    final double? perQuestionSeconds = switch (_timerDifficulty) {
      QuizTimerDifficulty.easy => null,
      QuizTimerDifficulty.medium => 10.0,
      QuizTimerDifficulty.hard => 5.0,
    };
    final bool isTimed = _timerDifficulty != QuizTimerDifficulty.easy;

    final String titleSuffix = _selectedMaxLimit != null ? ' • ≤ $_selectedMaxLimit' : '';
    final String subtitleSuffix = _selectedMaxLimit != null ? ' (Numbers ≤ $_selectedMaxLimit)' : '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: '${widget.type.name}_${digits}d',
            title: '$_operationTitle ($levelName$titleSuffix)',
            subtitle: '$digits-Digit Mental Math Drill$subtitleSuffix',
            type: widget.type,
            iconName: 'calculate_rounded',
          ),
          customQuestions: questions,
          onRegenerateQuestions: () => DynamicQuestionEngine.generateDigitSpecificQuestions(
            type: widget.type,
            digits: digits,
            count: _questionCount,
            maxNumberLimit: _selectedMaxLimit,
          ),
          isTimed: isTimed,
          perQuestionSeconds: perQuestionSeconds,
          questionCount: _questionCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _themeColor;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(_operationIcon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              _operationTitle,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner with Operation Symbol
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.22),
                    const Color(0xFF13192B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [color, color.withValues(alpha: 0.6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _operationSymbol,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Digit Complexity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Practice 1-Digit, 2-Digit, 3-Digit, or 4-Digit mental drills tailored to your exam speed.',
                          style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Quick Settings Bar (Questions Count & Timer Speed Mode)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF13192B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Questions Count:',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      _buildCountChip(10),
                      const SizedBox(width: 6),
                      _buildCountChip(20),
                      const SizedBox(width: 6),
                      _buildCountChip(30),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Speed Timer Pace:',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        _timerDifficulty == QuizTimerDifficulty.easy
                            ? 'No Timer'
                            : (_timerDifficulty == QuizTimerDifficulty.medium ? '10s / Q' : '5s / Q'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _timerDifficulty == QuizTimerDifficulty.easy
                              ? const Color(0xFF10B981)
                              : (_timerDifficulty == QuizTimerDifficulty.medium ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimerDifficultyChip(
                          QuizTimerDifficulty.easy,
                          'Easy',
                          'No Timer',
                          const Color(0xFF10B981),
                          Icons.spa_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTimerDifficultyChip(
                          QuizTimerDifficulty.medium,
                          'Medium',
                          '10s / Q',
                          const Color(0xFFF59E0B),
                          Icons.timer_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTimerDifficultyChip(
                          QuizTimerDifficulty.hard,
                          'Hard',
                          '5s / Q',
                          const Color(0xFFEF4444),
                          Icons.bolt_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.filter_alt_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Calculation Limit (Ceiling):',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        _selectedMaxLimit == null ? 'Standard (All)' : '≤ $_selectedMaxLimit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _selectedMaxLimit == null ? Colors.white54 : color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildLimitChip(label: 'Standard', limit: null),
                        const SizedBox(width: 6),
                        _buildLimitChip(label: '≤ 20', limit: 20),
                        const SizedBox(width: 6),
                        _buildLimitChip(label: '≤ 50', limit: 50),
                        const SizedBox(width: 6),
                        _buildLimitChip(label: '≤ 100', limit: 100),
                        const SizedBox(width: 6),
                        _buildCustomLimitChip(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'SELECT CALCULATION LEVEL:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            // 3. Four Digit Level Cards (1-Digit, 2-Digit, 3-Digit, 4-Digit)
            _buildDigitCard(
              digits: 1,
              title: 'Single Digit',
              levelBadge: 'LEVEL 1 • WARMUP',
              subtitle: 'Rapid reflex foundation drills • Perfect for instant warmup',
              badgeColor: const Color(0xFF10B981),
              targetPace: '< 1.5s / Q',
              exampleText: _getExample(1),
            ),
            const SizedBox(height: 14),

            _buildDigitCard(
              digits: 2,
              title: 'Double Digit',
              levelBadge: 'LEVEL 2 • EXAM CORE',
              subtitle: 'High-frequency exam calculations • Master split & merge Vedic tricks',
              badgeColor: const Color(0xFFF59E0B),
              targetPace: '< 2.5s / Q',
              exampleText: _getExample(2),
            ),
            const SizedBox(height: 14),

            _buildDigitCard(
              digits: 3,
              title: 'Triple Digit',
              levelBadge: 'LEVEL 3 • PRO SPEED',
              subtitle: 'Banking PO, SSC CGL & RRB standard • Left-to-right calculation',
              badgeColor: const Color(0xFF8B5CF6),
              targetPace: '< 4.0s / Q',
              exampleText: _getExample(3),
            ),
            const SizedBox(height: 14),

            _buildDigitCard(
              digits: 4,
              title: 'Four Digit',
              levelBadge: 'LEVEL 4 • MASTER CHALLENGER',
              subtitle: 'CAT, CSAT & Advanced Speed Drills • Large numbers lightning execution',
              badgeColor: const Color(0xFFEF4444),
              targetPace: '< 6.0s / Q',
              exampleText: _getExample(4),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(int count) {
    bool isSelected = _questionCount == count;
    final color = _themeColor;
    return InkWell(
      onTap: () => setState(() => _questionCount = count),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white10,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDifficultyChip(
    QuizTimerDifficulty difficulty,
    String label,
    String subtitle,
    Color activeColor,
    IconData icon,
  ) {
    final bool isSelected = _timerDifficulty == difficulty;
    return InkWell(
      onTap: () {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        setState(() => _timerDifficulty = difficulty);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.22) : const Color(0xFF0D1220),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? activeColor : Colors.white54,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? activeColor : Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor.withValues(alpha: 0.9) : Colors.white38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitChip({required String label, required int? limit}) {
    final bool isSelected = _selectedMaxLimit == limit;
    final color = _themeColor;
    return InkWell(
      onTap: () {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        setState(() => _selectedMaxLimit = limit);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : const Color(0xFF0D1220),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLimitChip() {
    final bool isCustom = _selectedMaxLimit != null &&
        _selectedMaxLimit != 20 &&
        _selectedMaxLimit != 50 &&
        _selectedMaxLimit != 100;
    final color = _themeColor;
    return InkWell(
      onTap: () {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        _showCustomLimitDialog();
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isCustom ? color.withValues(alpha: 0.25) : const Color(0xFF0D1220),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCustom ? color : Colors.white12,
            width: isCustom ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCustom ? '≤ $_selectedMaxLimit' : 'Custom...',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isCustom ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isCustom ? Icons.edit_rounded : Icons.tune_rounded,
              size: 13,
              color: isCustom ? color : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomLimitDialog() async {
    final controller = TextEditingController(
      text: (_selectedMaxLimit != null &&
              _selectedMaxLimit != 20 &&
              _selectedMaxLimit != 50 &&
              _selectedMaxLimit != 100)
          ? '$_selectedMaxLimit'
          : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13192B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _themeColor.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Icon(Icons.tune_rounded, color: _themeColor, size: 20),
            const SizedBox(width: 8),
            const Text('Set Custom Limit',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Questions will strictly stay capped so numbers never exceed this boundary (e.g. 15, 25, 40).',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter limit (e.g. 25)',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFF090D16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _themeColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _themeColor, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val >= 5) {
                Navigator.pop(ctx, val);
              }
            },
            child: const Text('Apply Limit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _selectedMaxLimit = result);
    }
  }

  Widget _buildDigitCard({
    required int digits,
    required String title,
    required String levelBadge,
    required String subtitle,
    required Color badgeColor,
    required String targetPace,
    required String exampleText,
  }) {
    return InkWell(
      onTap: () => _launchQuizForDigits(digits, title),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF13192B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    levelBadge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: badgeColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AppTheme.gold),
                    Text(
                      ' $targetPace',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${digits}D',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11.5, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: badgeColor, size: 18),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Example chip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.gold, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Examples: $exampleText',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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
