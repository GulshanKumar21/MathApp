import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import '../auth/auth_screen.dart';
import '../../services/notification_service.dart';

/// 30-Second Speed Challenge
/// Tests real mental speed: count down exactly 30 seconds, calculate answers per second
class SpeedTest30sScreen extends StatefulWidget {
  const SpeedTest30sScreen({super.key});

  @override
  State<SpeedTest30sScreen> createState() => _SpeedTest30sScreenState();
}

class _SpeedTest30sScreenState extends State<SpeedTest30sScreen> {
  static const int _totalTimeSeconds = 30;
  int _secondsRemaining = _totalTimeSeconds;
  Timer? _timer;

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  final List<MistakeModel> _sessionMistakes = [];

  String? _selectedOption;
  bool? _isCurrentCorrect;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  void _loadQuestions() {
    // Generate pool of fast arithmetic & multiplication questions
    final qPool = <QuestionModel>[];
    qPool.addAll(DynamicQuestionEngine.generateUniqueQuestions(type: TopicType.tables, count: 18));
    qPool.addAll(DynamicQuestionEngine.generateUniqueQuestions(type: TopicType.addition, count: 18));
    qPool.addAll(DynamicQuestionEngine.generateUniqueQuestions(type: TopicType.subtraction, count: 15));
    qPool.addAll(DynamicQuestionEngine.generateUniqueQuestions(type: TopicType.squares, count: 10));
    qPool.shuffle();
    _questions = qPool;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          _finishTest();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_sessionMistakes.isNotEmpty) {
      NotificationService().enqueueSessionMistakesAndTrigger(_sessionMistakes);
    }
    super.dispose();
  }

  void _handleOptionTap(String option) {
    if (_isFinished || _selectedOption != null) return;

    final currentQ = _questions[_currentIndex];
    final bool isRight = option.trim() == currentQ.correctAnswer.trim();

    setState(() {
      _selectedOption = option;
      _isCurrentCorrect = isRight;

      if (isRight) {
        _correctCount++;
      } else {
        _wrongCount++;
        _sessionMistakes.add(
          MistakeModel(
            id: 'speed_${DateTime.now().millisecondsSinceEpoch}_$_currentIndex',
            prompt: currentQ.prompt,
            userAnswer: option,
            correctAnswer: currentQ.correctAnswer,
            topicId: 'speed_test',
            timestamp: DateTime.now(),
          ),
        );
      }
    });

    // Check guest question limit
    final appState = context.read<AppStateProvider>();
    if (!appState.isLoggedIn) {
      appState.recordGuestQuestionAnswered();
      if (appState.isGuestLimitReached) {
        _timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthScreen(initialIsLogin: false, isMandatory: true),
          ),
        );
        return;
      }
    }

    // Rapid transition to next question in 280ms
    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted || _isFinished) return;

      if (_currentIndex < _questions.length - 1 && _secondsRemaining > 0) {
        setState(() {
          _currentIndex++;
          _selectedOption = null;
          _isCurrentCorrect = null;
        });
      } else {
        _finishTest();
      }
    });
  }

  void _finishTest() {
    if (_isFinished) return;
    _timer?.cancel();
    setState(() {
      _isFinished = true;
    });

    final int totalAnswered = _correctCount + _wrongCount;
    final int timeElapsed = _totalTimeSeconds - _secondsRemaining;
    final int effectiveTime = timeElapsed > 0 ? timeElapsed : 1;
    final double avgSecondsPerQ = totalAnswered > 0
        ? (effectiveTime / totalAnswered)
        : 3.5;
    final double accuracy = totalAnswered > 0
        ? (_correctCount / totalAnswered) * 100
        : 0.0;
    final int score = (_correctCount * 10) - (_wrongCount * 2);

    final result = PracticeResult(
      totalQuestions: totalAnswered,
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      accuracy: accuracy,
      avgTimeSeconds: avgSecondsPerQ,
      score: score > 0 ? score : 0,
      topicId: 'speed_test',
      date: DateTime.now(),
    );

    context.read<AppStateProvider>().recordPracticeResult(result, _sessionMistakes);
    _showSpeedResultModal(result, avgSecondsPerQ, effectiveTime);
  }

  void _showSpeedResultModal(PracticeResult result, double avgSec, int timeElapsed) {
    String speedTitle;
    String speedEmoji;
    Color speedColor;
    String speedComment;

    if (avgSec <= 2.0 && result.accuracy >= 75) {
      speedTitle = 'Rocket Speed';
      speedEmoji = '🚀';
      speedColor = const Color(0xFF10B981);
      speedComment = 'Outstanding! Top 1% in speed calculation!';
    } else if (avgSec <= 3.2) {
      speedTitle = 'Superfast Pace';
      speedEmoji = '⚡';
      speedColor = const Color(0xFF06B6D4);
      speedComment = 'Great speed! Exam benchmark achieved!';
    } else if (avgSec <= 4.8) {
      speedTitle = 'Good Speed';
      speedEmoji = '🏃';
      speedColor = const Color(0xFFF59E0B);
      speedComment = 'Decent pace! Daily 30s practice will make you faster.';
    } else {
      speedTitle = 'Practice Needed';
      speedEmoji = '🐢';
      speedColor = const Color(0xFFEF4444);
      speedComment = 'Keep practicing daily to build muscle memory.';
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: speedColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: speedColor.withValues(alpha: 0.5), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(speedEmoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 12),
              Text(
                speedTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: speedColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                speedComment,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 18),

              // Metric Highlights Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statColumn('Speed', '${avgSec.toStringAsFixed(1)}s', 'sec/ans', speedColor),
                    Container(width: 1, height: 28, color: Colors.white12),
                    _statColumn('Solved', '${result.correctCount}', 'in ${timeElapsed}s', Colors.white),
                    Container(width: 1, height: 28, color: Colors.white12),
                    _statColumn('Accuracy', '${result.accuracy.toStringAsFixed(0)}%', 'correct', const Color(0xFF10B981)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SpeedTest30sScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Test Again', style: TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statColumn(String label, String value, String unit, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: valColor)),
        Text(unit, style: const TextStyle(fontSize: 9.5, color: Colors.white38)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQ = _questions[_currentIndex];
    final double timeProgress = _secondsRemaining / _totalTimeSeconds;
    final Color timerColor = _secondsRemaining <= 5
        ? const Color(0xFFEF4444)
        : (_secondsRemaining <= 10 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: const Text('⚡ 30-Second Speed Test', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _finishTest,
            child: const Text('Finish', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Ticking Countdown Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF0F172A),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_rounded, color: timerColor, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '$_secondsRemaining s Left',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: timerColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '🔥 $_correctCount Solved',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFA5B4FC),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: timeProgress,
                      minHeight: 7,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 2. Question Prompt Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'QUESTION #${_currentIndex + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white54,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currentQ.prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 3. Four Big Rapid-Tap Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentQ.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, idx) {
                  final opt = currentQ.options[idx];
                  final isSelected = _selectedOption == opt;

                  Color btnColor = const Color(0xFF1E293B);
                  Color borderColor = Colors.white12;
                  Color textColor = Colors.white;

                  if (isSelected && _isCurrentCorrect != null) {
                    if (_isCurrentCorrect!) {
                      btnColor = const Color(0xFF10B981);
                      borderColor = const Color(0xFF059669);
                    } else {
                      btnColor = const Color(0xFFEF4444);
                      borderColor = const Color(0xFFDC2626);
                    }
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _handleOptionTap(opt),
                    child: Container(
                      decoration: BoxDecoration(
                        color: btnColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
