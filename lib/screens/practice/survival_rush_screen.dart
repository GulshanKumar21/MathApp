import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import '../auth/auth_screen.dart';

class SurvivalRushScreen extends StatefulWidget {
  const SurvivalRushScreen({super.key});

  @override
  State<SurvivalRushScreen> createState() => _SurvivalRushScreenState();
}

class _SurvivalRushScreenState extends State<SurvivalRushScreen> with SingleTickerProviderStateMixin {
  static const int _totalQuestions = 15;
  static const double timePerQuestion = 5.0; // ⚡ 5.0 seconds per question

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _isGameOver = false;

  Timer? _countdownTimer;
  double _secondsLeft = timePerQuestion;

  String? _selectedOption;
  bool _isAnswerSubmitted = false;
  final List<MistakeModel> _sessionMistakes = [];

  @override
  void initState() {
    super.initState();
    _startNewBlitzRound();

    // 🔒 Guest Trial Check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppStateProvider>();
      if (state.isGuestLimitReached) {
        _countdownTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthScreen(
              initialIsLogin: false,
              isMandatory: true,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startNewBlitzRound() {
    _countdownTimer?.cancel();
    _questions = DynamicQuestionEngine.generateSpeedBlitzTricksSet(count: _totalQuestions);
    _currentIndex = 0;
    _score = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _isGameOver = false;
    _selectedOption = null;
    _isAnswerSubmitted = false;
    _sessionMistakes.clear();

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _countdownTimer?.cancel();
    _secondsLeft = timePerQuestion;
    _selectedOption = null;
    _isAnswerSubmitted = false;

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0.05) {
        setState(() {
          _secondsLeft -= 0.05;
        });
      } else {
        _secondsLeft = 0.0;
        _onTimeUp();
      }
    });
  }

  QuestionModel get _currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) {
      return QuestionModel(
        id: 'fallback',
        topicId: 'hard_multiplier',
        prompt: '12 × 13 = ?',
        correctAnswer: '156',
        options: ['146', '156', '166', '176'],
      );
    }
    return _questions[_currentIndex];
  }

  void _onAnswerTap(String selected) {
    if (_isAnswerSubmitted || _isGameOver) return;

    final appState = context.read<AppStateProvider>();
    if (!appState.isLoggedIn) {
      appState.recordGuestQuestionAnswered();
      if (appState.isGuestLimitReached) {
        _countdownTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthScreen(
              initialIsLogin: false,
              isMandatory: true,
            ),
          ),
        );
        return;
      }
    }

    _countdownTimer?.cancel();
    setState(() {
      _selectedOption = selected;
      _isAnswerSubmitted = true;
    });

    final currentQ = _currentQuestion;
    final bool isCorrect = selected == currentQ.correctAnswer;

    if (isCorrect) {
      _correctCount++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
      _score += 10 + (_currentStreak * 2); // Streak multiplier bonus

      context.read<AppStateProvider>().checkAndResolveIfMistake(
            prompt: currentQ.prompt,
            answer: selected,
          );
    } else {
      _wrongCount++;
      _currentStreak = 0;
      _sessionMistakes.add(
        MistakeModel(
          id: 'blitz_${DateTime.now().millisecondsSinceEpoch}_$_currentIndex',
          prompt: currentQ.prompt,
          userAnswer: selected,
          correctAnswer: currentQ.correctAnswer,
          topicId: currentQ.topicId,
          timestamp: DateTime.now(),
        ),
      );
    }

    // Brief 450ms feedback delay before advancing to next question
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _advanceToNextQuestion();
    });
  }

  void _onTimeUp() {
    if (_isAnswerSubmitted || _isGameOver) return;
    _countdownTimer?.cancel();

    setState(() {
      _isAnswerSubmitted = true;
      _selectedOption = ''; // None selected (Timed out)
      _wrongCount++;
      _currentStreak = 0;
    });

    final currentQ = _currentQuestion;
    _sessionMistakes.add(
      MistakeModel(
        id: 'blitz_timeout_${DateTime.now().millisecondsSinceEpoch}_$_currentIndex',
        prompt: currentQ.prompt,
        userAnswer: 'Timed Out',
        correctAnswer: currentQ.correctAnswer,
        topicId: currentQ.topicId,
        timestamp: DateTime.now(),
      ),
    );

    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      _advanceToNextQuestion();
    });
  }

  void _advanceToNextQuestion() {
    if (_currentIndex + 1 < _totalQuestions) {
      setState(() {
        _currentIndex++;
      });
      _startQuestionTimer();
    } else {
      _triggerGameOver();
    }
  }

  void _triggerGameOver() {
    _countdownTimer?.cancel();
    setState(() {
      _isGameOver = true;
    });

    // Record session in user practice history
    final result = PracticeResult(
      totalQuestions: _totalQuestions,
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      accuracy: (_correctCount / _totalQuestions) * 100,
      avgTimeSeconds: 5.0,
      score: _score,
      topicId: 'speed_blitz',
      date: DateTime.now(),
    );

    context.read<AppStateProvider>().recordPracticeResult(result, _sessionMistakes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isGameOver ? const Color(0xFF14141E) : AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('⚡ 5s Speed Blitz (15 Viral Tricks Qs)'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isGameOver ? _buildGameOverView() : _buildActiveGameView(),
        ),
      ),
    );
  }

  Widget _buildActiveGameView() {
    double progress = (_secondsLeft / timePerQuestion).clamp(0.0, 1.0);
    final q = _currentQuestion;

    return Column(
      children: [
        // Top HUD: Question Progress, Streak, Score
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('QUESTION', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold)),
                Text('${_currentIndex + 1} / $_totalQuestions', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            Column(
              children: [
                const Text('STREAK', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold)),
                Text('$_currentStreak 🔥', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('SCORE', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold)),
                Text('$_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.gold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Urgent 5-Second Timer Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              _secondsLeft <= 1.5 ? AppTheme.error : const Color(0xFF10B981),
            ),
            minHeight: 9,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_secondsLeft.toStringAsFixed(1)}s remaining',
              style: TextStyle(
                color: _secondsLeft <= 1.5 ? AppTheme.error : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            const Text(
              '5s Per Question Blitz',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),

        const Spacer(),

        // Prompt Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.surfaceLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚡ VIRAL TRICKS REFLEX',
                  style: TextStyle(letterSpacing: 1.5, fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.accent),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                q.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),

        const Spacer(),

        // 4 Options Grid (2x2)
        Column(
          children: [
            for (int i = 0; i < q.options.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(child: _rushOptionBtn(q.options[i])),
                    const SizedBox(width: 12),
                    if (i + 1 < q.options.length)
                      Expanded(child: _rushOptionBtn(q.options[i + 1])),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _rushOptionBtn(String option) {
    final currentQ = _currentQuestion;
    Color bgColor = AppTheme.surface;
    Color borderColor = AppTheme.surfaceLight;
    Color textColor = Colors.white;

    if (_isAnswerSubmitted) {
      if (option == currentQ.correctAnswer) {
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.25);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF10B981);
      } else if (option == _selectedOption) {
        bgColor = AppTheme.error.withValues(alpha: 0.25);
        borderColor = AppTheme.error;
        textColor = AppTheme.error;
      }
    }

    return GestureDetector(
      onTap: () => _onAnswerTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          option,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  Widget _buildGameOverView() {
    final accuracy = ((_correctCount / _totalQuestions) * 100).toInt();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, size: 64, color: AppTheme.gold),
          ),
          const SizedBox(height: 18),
          const Text('15Q BLITZ COMPLETE! 🎉', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            '$_correctCount out of $_totalQuestions Correct ($accuracy%)',
            style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text('Score: $_score points  •  Best Streak: $_bestStreak 🔥', style: const TextStyle(fontSize: 14.5, color: AppTheme.gold)),
          const SizedBox(height: 28),

          // Action Buttons
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            label: const Text('Play Again (15Q Blitz)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                _startNewBlitzRound();
              });
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Home', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
