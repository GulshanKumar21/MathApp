import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/english_models.dart';
import '../../providers/app_state_provider.dart';
import '../../services/english_tts_service.dart';

class EnglishQuizScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<EnglishExerciseQuestion> questions;
  final bool isPreposition;
  final bool isMistakeRetest;

  const EnglishQuizScreen({
    super.key,
    required this.title,
    this.subtitle = 'Interactive Verbal Mastery Drill',
    required this.questions,
    this.isPreposition = false,
    this.isMistakeRetest = false,
  });

  @override
  State<EnglishQuizScreen> createState() => _EnglishQuizScreenState();
}

class _EnglishQuizScreenState extends State<EnglishQuizScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _streak = 0;
  int _bestStreak = 0;

  // Speed timer mode
  bool _speedMode = false;
  int _secondsLeft = 15;
  Timer? _countdownTimer;

  // Total session timer
  late DateTime _sessionStart;
  int _totalElapsedSeconds = 0;

  bool _isQuizCompleted = false;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    if (_speedMode) {
      _startQuestionTimer();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    EnglishTtsService().stop();
    super.dispose();
  }

  void _startQuestionTimer() {
    _countdownTimer?.cancel();
    _secondsLeft = 15;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_answered) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        // Time ran out -> auto submit wrong attempt
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    if (_answered || _isQuizCompleted) return;
    _selectOption(-1); // -1 represents timeout / missed
  }

  void _selectOption(int index) {
    if (_answered || _isQuizCompleted) return;
    _countdownTimer?.cancel();

    final currentQ = widget.questions[_currentIndex];
    final bool isCorrect = index == currentQ.correctIndex;

    setState(() {
      _answered = true;
      _selectedIndex = index;
      if (isCorrect) {
        _correctCount++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        HapticFeedback.lightImpact();
      } else {
        _wrongCount++;
        _streak = 0;
        HapticFeedback.heavyImpact();
      }
    });

    // Save result and update English mistake notebook
    context.read<AppStateProvider>().recordEnglishAnswer(
      isCorrect: isCorrect,
      questionId: currentQ.id,
      questionText: currentQ.questionText,
      options: currentQ.options,
      correctIndex: currentQ.correctIndex,
      selectedIndex: index >= 0 ? index : 0,
      explanation: currentQ.explanation,
    );
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
      if (_speedMode) {
        _startQuestionTimer();
      }
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _countdownTimer?.cancel();
    final elapsed = DateTime.now().difference(_sessionStart).inSeconds;
    setState(() {
      _totalElapsedSeconds = elapsed;
      _isQuizCompleted = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _correctCount = 0;
      _wrongCount = 0;
      _streak = 0;
      _isQuizCompleted = false;
      _sessionStart = DateTime.now();
    });
    if (_speedMode) {
      _startQuestionTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: AppTheme.bgDark,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_rounded, color: AppTheme.textMuted, size: 64),
              const SizedBox(height: 16),
              const Text(
                'No questions found in this set.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back to English Hub'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isQuizCompleted) {
      return _buildScorecard();
    }

    final currentQ = widget.questions[_currentIndex];
    final double progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => _confirmExit(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Q ${_currentIndex + 1} of ${widget.questions.length} • ${widget.subtitle}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // Speed mode toggle
          IconButton(
            tooltip: _speedMode ? 'Speed Timer: ON (15s)' : 'Speed Timer: OFF (Relaxed)',
            icon: Icon(
              _speedMode ? Icons.timer_rounded : Icons.timer_off_rounded,
              color: _speedMode ? AppTheme.gold : AppTheme.textMuted,
            ),
            onPressed: () {
              setState(() {
                _speedMode = !_speedMode;
                if (_speedMode && !_answered) {
                  _startQuestionTimer();
                } else {
                  _countdownTimer?.cancel();
                }
              });
            },
          ),
          if (_streak >= 2)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$_streak STREAK',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Bar
            ClipRRect(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppTheme.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
              ),
            ),

            // Speed Countdown indicator if enabled
            if (_speedMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: _secondsLeft <= 5 ? AppTheme.error.withValues(alpha: 0.15) : AppTheme.surface,
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm_rounded,
                      size: 16,
                      color: _secondsLeft <= 5 ? AppTheme.error : AppTheme.gold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time remaining: ${_secondsLeft}s',
                      style: TextStyle(
                        color: _secondsLeft <= 5 ? AppTheme.error : AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _secondsLeft / 15,
                          minHeight: 6,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _secondsLeft <= 5 ? AppTheme.error : AppTheme.gold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Question Scroll Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Type Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(currentQ.type).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getBadgeColor(currentQ.type).withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            currentQ.type.toUpperCase(),
                            style: TextStyle(
                              color: _getBadgeColor(currentQ.type),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Audio pronunciation speaker
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryLight, size: 22),
                          tooltip: 'Pronounce Question',
                          onPressed: () {
                            EnglishTtsService().speakWord(currentQ.questionText);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Question Prompt Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.surfaceLight, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        currentQ.questionText,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4 Options (A, B, C, D)
                    ...List.generate(currentQ.options.length, (optIdx) {
                      final optionText = currentQ.options[optIdx];
                      return _buildOptionTile(optIdx, optionText, currentQ);
                    }),

                    // Detailed Explanation Box (shown after answer)
                    if (_answered) ...[
                      const SizedBox(height: 18),
                      _buildExplanationCard(currentQ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Navigation Next / Continue Bar
            if (_answered)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(top: BorderSide(color: AppTheme.surfaceLight, width: 1)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex < widget.questions.length - 1 ? 'NEXT QUESTION' : 'VIEW SCORECARD',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int optIdx, String text, EnglishExerciseQuestion question) {
    final bool isSelected = _selectedIndex == optIdx;
    final bool isCorrectAnswer = optIdx == question.correctIndex;

    Color borderColor = AppTheme.surfaceLight;
    Color bgColor = AppTheme.surface;
    Color textColor = AppTheme.textPrimary;
    Widget? trailingIcon;

    if (_answered) {
      if (isCorrectAnswer) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.16);
        textColor = const Color(0xFF34D399);
        trailingIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22);
      } else if (isSelected) {
        borderColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.16);
        textColor = const Color(0xFFF87171);
        trailingIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 22);
      } else {
        textColor = AppTheme.textMuted;
      }
    }

    final optionLabels = ['A', 'B', 'C', 'D'];
    final label = optIdx < optionLabels.length ? optionLabels[optIdx] : '${optIdx + 1}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _answered ? null : () => _selectOption(optIdx),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: isSelected || (_answered && isCorrectAnswer) ? 2 : 1.2),
            ),
            child: Row(
              children: [
                // Option Letter Badge
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _answered && isCorrectAnswer
                        ? const Color(0xFF10B981)
                        : (_answered && isSelected
                            ? const Color(0xFFEF4444)
                            : AppTheme.surfaceElevated),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: (_answered && (isCorrectAnswer || isSelected)) ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Option Text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: isSelected || (_answered && isCorrectAnswer) ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                ?trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(EnglishExerciseQuestion question) {
    final bool isCorrect = _selectedIndex == question.correctIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct! Outstanding!' : 'Grammar & Concept Rule:',
                style: TextStyle(
                  color: isCorrect ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation.isNotEmpty
                ? question.explanation
                : 'Correct answer is: ${question.options[question.correctIndex]}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecard() {
    final total = widget.questions.length;
    final accuracy = total > 0 ? (_correctCount / total * 100).round() : 0;
    final isMastery = accuracy >= 80;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Trophy / Medal Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMastery
                        ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                        : [const Color(0xFF4338CA), const Color(0xFF3730A3)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isMastery ? const Color(0xFFF59E0B) : const Color(0xFF4338CA)).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  isMastery ? Icons.emoji_events_rounded : Icons.verified_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                isMastery ? 'Mastery Achieved!' : 'Drill Completed!',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // 3-Metric Cards
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.surfaceLight, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCol('Accuracy', '$accuracy%', const Color(0xFF10B981)),
                    Container(height: 36, width: 1, color: AppTheme.surfaceLight),
                    _buildMetricCol('Correct', '$_correctCount / $total', const Color(0xFF38BDF8)),
                    Container(height: 36, width: 1, color: AppTheme.surfaceLight),
                    _buildMetricCol('Streak', '$_bestStreak 🔥', const Color(0xFFF59E0B)),
                    Container(height: 36, width: 1, color: AppTheme.surfaceLight),
                    _buildMetricCol('Time', '${_totalElapsedSeconds}s', const Color(0xFFA855F7)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_wrongCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$_wrongCount mistake(s) automatically saved to your English Mistake Notebook for spaced recall.',
                          style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _restartQuiz,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.surfaceLight, width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('RETAKE DRILL', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getBadgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'synonym':
        return const Color(0xFF38BDF8); // Cyan
      case 'antonym':
        return const Color(0xFFA78BFA); // Violet
      case 'preposition':
        return const Color(0xFF10B981); // Emerald
      case 'mistake':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF94A3B8);
    }
  }

  void _confirmExit() {
    if (_answered && _currentIndex == widget.questions.length - 1) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Quit this drill?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Your progress in this drill session will be lost. Any answered questions have already been recorded.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('QUIT DRILL'),
          ),
        ],
      ),
    );
  }
}
