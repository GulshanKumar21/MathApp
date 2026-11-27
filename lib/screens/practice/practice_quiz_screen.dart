import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/content_repository.dart';
import '../../services/voice_reciter_helper.dart';
import 'learn_mode_screen.dart';
import '../auth/auth_screen.dart';
import '../../services/notification_service.dart';
import '../../widgets/tactile_numpad.dart';
import '../../widgets/concept_geometry_painter.dart';

class PracticeQuizScreen extends StatefulWidget {
  final TopicModel topic;
  final bool isTimed;
  final double? perQuestionSeconds; // Strict per-question timer (e.g. 2.5s for exams)
  final int questionCount;
  final List<QuestionModel>? customQuestions;
  final List<QuestionModel> Function()? onRegenerateQuestions;
  final bool initialUseNumpad;

  const PracticeQuizScreen({
    super.key,
    required this.topic,
    this.isTimed = true,
    this.perQuestionSeconds,
    this.questionCount = 15,
    this.customQuestions,
    this.onRegenerateQuestions,
    this.initialUseNumpad = false,
  });

  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen> {
  late List<QuestionModel> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;

  // 🎙️ Voice Coach / Audio Question Reader
  final FlutterTts _flutterTts = FlutterTts();
  bool _isAutoSpeakEnabled = false;
  bool _isSpeaking = false;

  // ⌨️ Numpad vs 🎯 MCQ Mode Toggle
  bool _useNumpad = false;
  String _typedAnswer = '';

  // ⚡ 50:50 Lifeline & Trick Hints for MCQ
  final Set<String> _eliminatedOptions = {};
  int _fiftyFiftyRemaining = 3;

  Timer? _timer;
  int _secondsElapsed = 0;
  final List<MistakeModel> _sessionMistakes = [];

  // ⏱️ Pause flag while reading Quick Tip
  bool _isTimerPaused = false;

  // Per-question strict timer (Easy: null, Medium: 10s, Hard: 5s, Exam: 2.5s)
  Timer? _perQuestionTimer;
  late double? _currentPerQuestionSeconds;
  double _questionSecondsLeft = 10.0;

  @override
  void initState() {
    super.initState();
    _useNumpad = widget.initialUseNumpad ||
        (widget.perQuestionSeconds != null && widget.perQuestionSeconds! <= 5.0);
    if (widget.perQuestionSeconds != null) {
      _currentPerQuestionSeconds = widget.perQuestionSeconds;
    } else if (widget.isTimed) {
      _currentPerQuestionSeconds = 10.0;
    } else {
      _currentPerQuestionSeconds = null;
    }

    if (widget.customQuestions != null && widget.customQuestions!.isNotEmpty) {
      _questions = List.from(widget.customQuestions!);
    } else {
      _questions = ContentRepository.generateQuestions(
        widget.topic.type,
        count: widget.questionCount,
      );
    }

    if (widget.isTimed) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted && !_isTimerPaused) {
          setState(() {
            _secondsElapsed++;
          });
        }
      });
    }

    if (_currentPerQuestionSeconds != null) {
      _questionSecondsLeft = _currentPerQuestionSeconds!;
      _startPerQuestionTimer();
    }

    _initTts();

    // 🔒 Guest Trial Check: If 3 or more questions already solved, redirect directly to Register
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppStateProvider>();
      if (state.isGuestLimitReached) {
        _timer?.cancel();
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

  void _initTts() {
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakCurrentQuestion() async {
    if (!mounted || _questions.isEmpty || _currentIndex >= _questions.length) return;
    try {
      final currentQ = _questions[_currentIndex];
      final state = context.read<AppStateProvider>();
      await _flutterTts.stop();
      if (!mounted) return;
      await VoiceReciterHelper.applyTtsSettings(
        tts: _flutterTts,
        rate: state.ttsSpeechRate,
        pitch: state.ttsPitch,
        language: state.ttsLanguage,
      );

      final spokenText = VoiceReciterHelper.getQuestionSpeechText(
        prompt: currentQ.prompt,
        style: state.ttsRecitalStyle,
      );
      if (mounted) {
        setState(() => _isSpeaking = true);
      }
      await _flutterTts.speak(spokenText);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _perQuestionTimer?.cancel();
    _flutterTts.stop();
    if (_sessionMistakes.isNotEmpty) {
      NotificationService().enqueueSessionMistakesAndTrigger(_sessionMistakes);
    }
    super.dispose();
  }

  void _setTimerDifficulty(double? seconds) {
    setState(() {
      _currentPerQuestionSeconds = seconds;
      _perQuestionTimer?.cancel();
      if (_currentPerQuestionSeconds != null) {
        _questionSecondsLeft = _currentPerQuestionSeconds!;
        if (!_isAnswered) {
          _startPerQuestionTimer();
        }
      }
    });
  }

  void _startPerQuestionTimer() {
    _perQuestionTimer?.cancel();
    if (_currentPerQuestionSeconds == null) return;
    _questionSecondsLeft = _currentPerQuestionSeconds!;
    // 50ms interval for ultra-smooth progress countdown
    _perQuestionTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isAnswered) {
        timer.cancel();
        return;
      }
      if (_isTimerPaused) return;
      setState(() {
        _questionSecondsLeft -= 0.05;
        if (_questionSecondsLeft <= 0.0) {
          _questionSecondsLeft = 0.0;
          timer.cancel();
          _onTimeExpired();
        }
      });
    });
  }

  void _onTimeExpired() {
    if (_isAnswered) return;
    final currentQ = _questions[_currentIndex];
    final appState = context.read<AppStateProvider>();
    appState.triggerHapticFeedback();

    final double totalSec = _currentPerQuestionSeconds ?? 10.0;
    final String limitLabel = '${totalSec.toStringAsFixed(0)}s';

    setState(() {
      _isAnswered = true;
      _wrongCount++;
      _sessionMistakes.add(MistakeModel(
        id: '${currentQ.id}_${DateTime.now().millisecondsSinceEpoch}',
        prompt: currentQ.prompt,
        userAnswer: 'Timed Out (>$limitLabel)',
        correctAnswer: currentQ.correctAnswer,
        topicId: widget.topic.id,
        timestamp: DateTime.now(),
      ));
    });

    if (!appState.isLoggedIn) {
      appState.recordGuestQuestionAnswered();
      if (appState.isGuestLimitReached) {
        _timer?.cancel();
        _perQuestionTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 650), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AuthScreen(
                initialIsLogin: false,
                isMandatory: true,
              ),
            ),
          );
        });
        return;
      }
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _isAnswered = false;
          _typedAnswer = '';
          _eliminatedOptions.clear();
        });
        _startPerQuestionTimer();
        if (_isAutoSpeakEnabled) {
          _speakCurrentQuestion();
        }
      } else {
        _finishSession();
      }
    });
  }

  void _onAnswerSelected(String option) {
    if (_isAnswered) return;
    _perQuestionTimer?.cancel();

    final currentQ = _questions[_currentIndex];
    final bool isCorrect = option == currentQ.correctAnswer;
    final appState = context.read<AppStateProvider>();

    setState(() {
      _selectedAnswer = option;
      _isAnswered = true;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
        _sessionMistakes.add(MistakeModel(
          id: '${currentQ.id}_${DateTime.now().millisecondsSinceEpoch}',
          prompt: currentQ.prompt,
          userAnswer: option,
          correctAnswer: currentQ.correctAnswer,
          topicId: widget.topic.id,
          timestamp: DateTime.now(),
        ));
      }
    });

    if (isCorrect) {
      appState.checkAndResolveIfMistake(
        prompt: currentQ.prompt,
        answer: option,
      );
    }

    // 🔒 Record question attempt for guest trial check ("3 ya 4 question banaya to direct register page")
    if (!appState.isLoggedIn) {
      appState.recordGuestQuestionAnswered();
      if (appState.isGuestLimitReached) {
        _timer?.cancel();
        _perQuestionTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 650), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AuthScreen(
                initialIsLogin: false,
                isMandatory: true,
              ),
            ),
          );
        });
        return;
      }
    }

    // Auto next after 700ms
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _isAnswered = false;
          _typedAnswer = '';
          _eliminatedOptions.clear();
        });
        _startPerQuestionTimer();
        if (_isAutoSpeakEnabled) {
          _speakCurrentQuestion();
        }
      } else {
        _finishSession();
      }
    });
  }

  void _finishSession() {
    if (!mounted) return;
    _timer?.cancel();
    _perQuestionTimer?.cancel();
    int total = _questions.length;
    double accuracy = total == 0 ? 0 : (_correctCount / total) * 100;
    double avgTime = total == 0 ? 0 : _secondsElapsed / total;
    int score = (_correctCount * 10) - (_wrongCount * 2);
    if (score < 0) score = 0;

    final result = PracticeResult(
      totalQuestions: total,
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      accuracy: accuracy,
      avgTimeSeconds: avgTime,
      score: score,
      topicId: widget.topic.id,
      date: DateTime.now(),
    );

    context.read<AppStateProvider>().recordPracticeResult(result, _sessionMistakes);
    _showSummaryDialog(result);
  }

  void _showSummaryDialog(PracticeResult result) {
    bool hasMistakes = _sessionMistakes.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 36),
              ),
              const SizedBox(height: 14),
              const Text(
                'Practice Complete!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Score: ${result.score} pts',
                style: const TextStyle(fontSize: 16, color: AppTheme.gold, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Accuracy', '${result.accuracy.toStringAsFixed(1)}%', AppTheme.accent),
                  _statItem('Correct', '${result.correctCount}', Colors.white),
                  _statItem('Wrong', '${result.wrongCount}', AppTheme.error),
                  _statItem('Avg Time', '${result.avgTimeSeconds.toStringAsFixed(1)}s', AppTheme.primaryLight),
                ],
              ),

              // Smart Mistake Notice & Direct Learn Mode CTA
              if (hasMistakes) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You made ${result.wrongCount} mistake(s). Jump to Learn Mode to review these calculations!',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LearnModeScreen(topic: widget.topic)),
                          );
                        },
                        child: const Text('Learn Now', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.surfaceLight),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _currentIndex = 0;
                          _correctCount = 0;
                          _wrongCount = 0;
                          _secondsElapsed = 0;
                          _selectedAnswer = null;
                          _isAnswered = false;
                          _typedAnswer = '';
                          _eliminatedOptions.clear();
                          _fiftyFiftyRemaining = 3;
                          _sessionMistakes.clear();
                          if (widget.onRegenerateQuestions != null) {
                            _questions = widget.onRegenerateQuestions!();
                          } else if (widget.customQuestions != null && widget.customQuestions!.isNotEmpty) {
                            final prevFirstPrompt = _questions.isNotEmpty ? _questions.first.prompt : null;
                            List<QuestionModel> reshuffled = List<QuestionModel>.from(widget.customQuestions!)..shuffle();
                            if (reshuffled.length > 1 && prevFirstPrompt != null && reshuffled[0].prompt == prevFirstPrompt) {
                              final swapIdx = 1 + Random().nextInt(reshuffled.length - 1);
                              final temp = reshuffled[0];
                              reshuffled[0] = reshuffled[swapIdx];
                              reshuffled[swapIdx] = temp;
                            }
                            _questions = reshuffled;
                          } else {
                            _questions = ContentRepository.generateQuestions(
                              widget.topic.type,
                              count: widget.questionCount,
                            );
                          }
                          _timer?.cancel();
                          _perQuestionTimer?.cancel();
                          if (widget.isTimed) {
                            _timer = Timer.periodic(const Duration(seconds: 1), (t) {
                              if (mounted) setState(() => _secondsElapsed++);
                            });
                          }
                          if (_currentPerQuestionSeconds != null) {
                            _questionSecondsLeft = _currentPerQuestionSeconds!;
                            _startPerQuestionTimer();
                          }
                        });
                      },
                      child: const Text('Try Again'),
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

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  Widget _buildPerQuestionCountdownBar() {
    final totalSec = _currentPerQuestionSeconds ?? 10.0;
    final progress = (_questionSecondsLeft / totalSec).clamp(0.0, 1.0);
    final color = progress > 0.45
        ? AppTheme.accent
        : (progress > 0.2 ? Colors.amberAccent : AppTheme.error);

    final String modeLabel = totalSec <= 5.0
        ? '⚡ Hard Speed (5s / Q • Auto-Skip)'
        : (totalSec <= 10.0
            ? '⏱️ Medium Pace (10s / Q • Auto-Skip)'
            : '⚡ Timed Mode (${totalSec.toStringAsFixed(1)}s / Q • Auto-Skip)');

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 18, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        modeLabel,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_questionSecondsLeft.toStringAsFixed(1)}s',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: color,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  void _onDigitPress(String digit) {
    if (_isAnswered) return;
    context.read<AppStateProvider>().triggerHapticFeedback();
    if (_typedAnswer.length >= 6) return;
    setState(() {
      _typedAnswer += digit;
    });

    final currentQ = _questions[_currentIndex];
    if (_typedAnswer == currentQ.correctAnswer) {
      _onAnswerSelected(_typedAnswer);
    }
  }

  void _onBackspace() {
    if (_isAnswered) return;
    context.read<AppStateProvider>().triggerHapticFeedback();
    if (_typedAnswer.isNotEmpty) {
      setState(() {
        _typedAnswer = _typedAnswer.substring(0, _typedAnswer.length - 1);
      });
    }
  }

  void _onClear() {
    if (_isAnswered) return;
    context.read<AppStateProvider>().triggerHapticFeedback();
    setState(() {
      _typedAnswer = '';
    });
  }

  void _useFiftyFifty() {
    if (_fiftyFiftyRemaining <= 0 || _isAnswered) return;
    final currentQ = _questions[_currentIndex];
    final incorrect = currentQ.options.where((o) => o != currentQ.correctAnswer).toList();
    if (incorrect.length <= 1) return;

    incorrect.shuffle();
    setState(() {
      _fiftyFiftyRemaining--;
      _eliminatedOptions.addAll(incorrect.take(2));
    });
    context.read<AppStateProvider>().triggerHapticFeedback();
  }

  Future<void> _showTrickHintSheet() async {
    final currentQ = _questions[_currentIndex];
    final tipData = _computeQuestionTip(currentQ, widget.topic.type);
    final String title = tipData['title'] ?? 'Quick Tip';
    final String trick = tipData['trick'] ?? 'Break down numbers into friendly parts.';

    if (mounted) {
      setState(() => _isTimerPaused = true);
    }

    try {
      await showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lightbulb_rounded, color: AppTheme.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      '⏸ Paused',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Problem: ${currentQ.prompt}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.cyan)),
                    const SizedBox(height: 8),
                    Text(trick, style: const TextStyle(fontSize: 13.5, color: Colors.white70, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                  child: const Text('Resume Practice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isTimerPaused = false);
      }
    }
  }

  Map<String, String> _computeQuestionTip(QuestionModel q, TopicType type) {
    final prompt = q.prompt.trim();

    // Check Subtraction: e.g. "65 − 29 = ?" or "43 - 34 = ?"
    final subMatch = RegExp(r'(\d+)\s*[-−]\s*(\d+)').firstMatch(prompt);
    if (subMatch != null) {
      final a = int.tryParse(subMatch.group(1)!) ?? 0;
      final b = int.tryParse(subMatch.group(2)!) ?? 0;
      if (a > 0 && b > 0) {
        final bLast = b % 10;
        if (bLast >= 6 && b >= 10) {
          // Complement Method (Round up & compensate)
          final roundB = ((b ~/ 10) + 1) * 10;
          final diff = roundB - b;
          return {
            'title': 'Complement Subtraction Method',
            'trick': '⚡ Round & Compensate Method:\n'
                '1. Round $b up to $roundB (add $diff).\n'
                '2. $a − $roundB = ${a - roundB}.\n'
                '3. Add back $diff: ${a - roundB} + $diff = ${a - b}!\n\n'
                '💡 Mental Shortcut: $a − $b = ($a − $roundB) + $diff = ${a - b}',
          };
        } else if (b >= 10) {
          // Left-to-right Split
          final tensB = (b ~/ 10) * 10;
          final unitsB = b % 10;
          return {
            'title': 'Left-to-Right Subtraction Rule',
            'trick': '⚡ Place-Value Subtraction:\n'
                '1. Subtract tens: $a − $tensB = ${a - tensB}.\n'
                '2. Subtract units: ${a - tensB} − $unitsB = ${a - b}!\n\n'
                '💡 Mental Shortcut: $a − $b = ($a − $tensB) − $unitsB = ${a - b}',
          };
        } else {
          return {
            'title': 'Single-Digit Subtraction Reflex',
            'trick': '⚡ Instant Recall: $a − $b = ${a - b}.\n'
                'Visualize on number line: count down $b from $a!',
          };
        }
      }
    }

    // Check Addition: e.g. "68 + 47 = ?"
    final addMatch = RegExp(r'(\d+)\s*\+\s*(\d+)').firstMatch(prompt);
    if (addMatch != null) {
      final a = int.tryParse(addMatch.group(1)!) ?? 0;
      final b = int.tryParse(addMatch.group(2)!) ?? 0;
      if (a > 0 && b > 0) {
        if (a >= 10 || b >= 10) {
          final tensA = (a ~/ 10) * 10;
          final unitsA = a % 10;
          final tensB = (b ~/ 10) * 10;
          final unitsB = b % 10;
          return {
            'title': 'Left-to-Right Addition Rule',
            'trick': '⚡ Highest Place Value First:\n'
                '1. Add tens: $tensA + $tensB = ${tensA + tensB}.\n'
                '2. Add units: $unitsA + $unitsB = ${unitsA + unitsB}.\n'
                '3. Combine: ${tensA + tensB} + ${unitsA + unitsB} = ${a + b}!\n\n'
                '💡 Zero-carry mental speed: Never add right-to-left in mind!',
          };
        } else {
          return {
            'title': 'Single-Digit Addition Reflex',
            'trick': '⚡ Instant Recall: $a + $b = ${a + b}.\n'
                'Look at friendly pairs to 10 for instant answers!',
          };
        }
      }
    }

    // Check Division: e.g. "168 ÷ 7 = ?" or "168 / 7 = ?"
    final divMatch = RegExp(r'(\d+)\s*[÷/]\s*(\d+)').firstMatch(prompt);
    if (divMatch != null) {
      final a = int.tryParse(divMatch.group(1)!) ?? 0;
      final b = int.tryParse(divMatch.group(2)!) ?? 0;
      if (a > 0 && b > 0) {
        final quotient = a ~/ b;
        return {
          'title': 'Split & Reverse Division Rule',
          'trick': '⚡ Reverse Table Reflex:\n'
              '1. Think: What × $b = $a?\n'
              '2. Since $quotient × $b = $a ➔ Ans is $quotient.\n'
              '3. Or split $a into friendly multiples of $b (e.g. ${(quotient ~/ 10) * 10 * b} + ${(quotient % 10) * b}) ÷ $b = $quotient!',
        };
      }
    }

    // Check Multiplication: e.g. "24 × 6 = ?" or "24 * 6 = ?"
    final mulMatch = RegExp(r'(\d+)\s*[×*x]\s*(\d+)').firstMatch(prompt);
    if (mulMatch != null) {
      final a = int.tryParse(mulMatch.group(1)!) ?? 0;
      final b = int.tryParse(mulMatch.group(2)!) ?? 0;
      if (a > 0 && b > 0) {
        if (a == b) {
          return {
            'title': 'Square Shortcut ($a²)',
            'trick': '⚡ Instant Square: $a × $a = ${a * a}.\n'
                'Check unit digit: ${a % 10} × ${a % 10} ends in ${(a * a) % 10}!',
          };
        } else if (b == 5 || a == 5) {
          final other = b == 5 ? a : b;
          return {
            'title': 'Multiply by 5 Rule',
            'trick': '⚡ Half & Ten Rule: $other × 5 = ($other ÷ 2) × 10 = ${a * b}.',
          };
        } else {
          final tensB = (b ~/ 10) * 10;
          final unitsB = b % 10;
          return {
            'title': 'Vedic Distribution Shortcut',
            'trick': '⚡ Distributive Rule:\n'
                '1. $a × $tensB = ${a * tensB}.\n'
                '2. $a × $unitsB = ${a * unitsB}.\n'
                '3. Combine: ${a * tensB} + ${a * unitsB} = ${a * b}!\n\n'
                '💡 Unit digit check: ${(a % 10)} × ${(b % 10)} ends in ${(a * b) % 10}!',
          };
        }
      }
    }

    // Fallbacks by TopicType
    switch (type) {
      case TopicType.squares:
        return {
          'title': 'Square Shortcut Rule',
          'trick': (q.explanation.isNotEmpty && q.explanation.contains('⚡'))
              ? q.explanation
              : 'Ending in 5: Multiply tens by (tens + 1) and append 25 (e.g. 45²: 4 × 5 = 20 | 25 → 2025).\nNear 50: (25 ± diff) | (diff²).',
        };
      case TopicType.cubes:
        return {
          'title': 'Cube Last-Digit Rule',
          'trick': (q.explanation.isNotEmpty && q.explanation.contains('⚡'))
              ? q.explanation
              : 'Remember unit mappings: 1³→1, 2³→8, 3³→7, 4³→4, 5³→5, 6³→6, 7³→3, 8³→2, 9³→9. Check unit digits to eliminate options instantly!',
        };
      case TopicType.fractions:
        return {
          'title': 'Percentage & Fraction Conversion Rule',
          'trick': (q.explanation.isNotEmpty)
              ? '⚡ Formula: ${q.explanation}\n\nKey Conversions: 1/2 = 50%, 1/3 = 33.33%, 1/4 = 25%, 1/5 = 20%, 1/6 = 16.66%, 1/7 = 14.28%, 1/8 = 12.5%.'
              : '1/2 = 50%, 1/3 = 33.33%, 1/4 = 25%, 1/5 = 20%, 1/6 = 16.66%, 1/7 = 14.28%, 1/8 = 12.5%. Convert to fractions for lightning mental math!',
        };
      case TopicType.triples:
        return {
          'title': 'Pythagorean Triplet Shortcut',
          'trick': (q.explanation.isNotEmpty)
              ? q.explanation
              : 'Standard Triplets: (3, 4, 5), (5, 12, 13), (7, 24, 25), (8, 15, 17), (9, 40, 41), (20, 21, 29). Multiplying by k gives another triplet (3k, 4k, 5k)!',
        };
      default:
        if (q.explanation.isNotEmpty) {
          return {
            'title': 'Concept Tip & Explanation',
            'trick': q.explanation,
          };
        }
        return {
          'title': 'Quick Tip',
          'trick': 'Break down complex numbers into tens and units (e.g. 24 × 6 = 20 × 6 + 4 × 6 = 120 + 24 = 144).',
        };
    }
  }

  Widget _buildQuickTipButton() {
    return InkWell(
      onTap: _showTrickHintSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cyan.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb_outline_rounded, size: 15, color: AppTheme.cyan),
            SizedBox(width: 4),
            Text(
              'Quick Tip',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic.title)),
        body: const Center(child: Text('No questions available')),
      );
    }

    final currentQ = _questions[_currentIndex];
    final state = context.watch<AppStateProvider>();
    final isCalc = state.numpadStyle == 'calculator';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        actions: [
          // Mode Switcher: MCQ vs Numpad
          GestureDetector(
            onTap: () {
              setState(() {
                _useNumpad = !_useNumpad;
                _typedAnswer = '';
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: _useNumpad
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.25)
                    : AppTheme.surfaceLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _useNumpad ? const Color(0xFF8B5CF6) : Colors.white24,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _useNumpad ? Icons.dialpad_rounded : Icons.checklist_rtl_rounded,
                    size: 14,
                    color: _useNumpad ? const Color(0xFFA78BFA) : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _useNumpad ? 'Keypad' : 'MCQ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _useNumpad ? const Color(0xFFA78BFA) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timer Mode Selector Pill
          // Timer Mode Selector Pill
          PopupMenuButton<String>(
            tooltip: 'Timer Mode',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppTheme.surfaceElevated,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _currentPerQuestionSeconds == null
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : (_currentPerQuestionSeconds == 5.0
                        ? AppTheme.error.withValues(alpha: 0.2)
                        : AppTheme.accent.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _currentPerQuestionSeconds == null
                      ? const Color(0xFF10B981).withValues(alpha: 0.6)
                      : (_currentPerQuestionSeconds == 5.0
                          ? AppTheme.error
                          : AppTheme.accent),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _currentPerQuestionSeconds == null
                        ? Icons.spa_rounded
                        : (_currentPerQuestionSeconds == 5.0
                            ? Icons.flash_on_rounded
                            : Icons.timer_outlined),
                    size: 14,
                    color: _currentPerQuestionSeconds == null
                        ? const Color(0xFF10B981)
                        : (_currentPerQuestionSeconds == 5.0
                            ? AppTheme.error
                            : AppTheme.accent),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentPerQuestionSeconds == null
                        ? 'Easy'
                        : (_currentPerQuestionSeconds == 5.0 ? 'Hard (5s)' : 'Med (10s)'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _currentPerQuestionSeconds == null
                          ? const Color(0xFF10B981)
                          : (_currentPerQuestionSeconds == 5.0
                              ? AppTheme.error
                              : AppTheme.accent),
                    ),
                  ),
                ],
              ),
            ),
            onSelected: (val) {
              try {
                HapticFeedback.selectionClick();
              } catch (_) {}
              if (val == 'easy') {
                _setTimerDifficulty(null);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.spa_rounded, color: Color(0xFF10B981), size: 18),
                        SizedBox(width: 8),
                        Text('Easy Mode: Unlimited Time (No Timer)'),
                      ],
                    ),
                    duration: const Duration(milliseconds: 1400),
                    backgroundColor: const Color(0xFF13192B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else if (val == 'hard') {
                _setTimerDifficulty(5.0);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.flash_on_rounded, color: AppTheme.error, size: 18),
                        SizedBox(width: 8),
                        Text('Hard Speed: 5s / Q Rapid Blitz!'),
                      ],
                    ),
                    duration: const Duration(milliseconds: 1400),
                    backgroundColor: const Color(0xFF13192B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else {
                _setTimerDifficulty(10.0);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.timer_outlined, color: AppTheme.accent, size: 18),
                        SizedBox(width: 8),
                        Text('Medium Pace: 10s / Q Timed Drill'),
                      ],
                    ),
                    duration: const Duration(milliseconds: 1400),
                    backgroundColor: const Color(0xFF13192B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'easy',
                child: Row(
                  children: [
                    const Icon(Icons.spa_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Easy (No Timer)',
                        style: TextStyle(
                          color: _currentPerQuestionSeconds == null ? const Color(0xFF10B981) : Colors.white,
                          fontWeight: _currentPerQuestionSeconds == null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_currentPerQuestionSeconds == null)
                      const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 16),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'medium',
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppTheme.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Medium (10s / Q)',
                        style: TextStyle(
                          color: _currentPerQuestionSeconds == 10.0 ? AppTheme.accent : Colors.white,
                          fontWeight: _currentPerQuestionSeconds == 10.0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_currentPerQuestionSeconds == 10.0)
                      const Icon(Icons.check_rounded, color: AppTheme.accent, size: 16),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'hard',
                child: Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, color: AppTheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hard (5s / Q)',
                        style: TextStyle(
                          color: _currentPerQuestionSeconds == 5.0 ? AppTheme.error : Colors.white,
                          fontWeight: _currentPerQuestionSeconds == 5.0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_currentPerQuestionSeconds == 5.0)
                      const Icon(Icons.check_rounded, color: AppTheme.error, size: 16),
                  ],
                ),
              ),
            ],
          ),
          // Voice Coach Toggle Button
          IconButton(
            icon: Icon(
              _isAutoSpeakEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _isAutoSpeakEnabled ? AppTheme.accent : Colors.white60,
              size: 20,
            ),
            tooltip: _isAutoSpeakEnabled ? 'Voice Reader: ON' : 'Voice Reader: OFF',
            onPressed: () {
              setState(() {
                _isAutoSpeakEnabled = !_isAutoSpeakEnabled;
              });
              if (_isAutoSpeakEnabled) {
                _speakCurrentQuestion();
              } else {
                _flutterTts.stop();
              }
            },
          ),
          if (widget.isTimed)
            Container(
              margin: const EdgeInsets.only(right: 12),
              alignment: Alignment.center,
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 15, color: AppTheme.warning),
                  const SizedBox(width: 4),
                  Text(
                    '${_secondsElapsed}s',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator & Question Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1}/${_questions.length}',
                    style: const TextStyle(fontSize: 13.5, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 4),
                      Text('$_correctCount', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.cancel_outlined, color: AppTheme.error, size: 16),
                      const SizedBox(width: 4),
                      Text('$_wrongCount', style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                  minHeight: 5,
                ),
              ),

              // ⚡ Strict Per-Question Countdown Bar
              if (_currentPerQuestionSeconds != null)
                _buildPerQuestionCountdownBar(),

              const Spacer(),

              // Question Flashcard Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _useNumpad
                          ? 'TYPE ANSWER DIRECTLY • SPEED DRILL'
                          : (_currentPerQuestionSeconds != null
                              ? (_currentPerQuestionSeconds! <= 5.0
                                  ? '⚡ HARD SPEED (5s / Q) • RAPID REFLEX'
                                  : '⏱️ MEDIUM PACE (10s / Q) • TIMED DRILL')
                              : 'RELAXED DRILL • UNLIMITED TIME'),
                      style: TextStyle(
                        fontSize: 11,
                        color: _useNumpad
                            ? const Color(0xFFA78BFA)
                            : (_currentPerQuestionSeconds != null
                                ? (_currentPerQuestionSeconds! <= 5.0 ? AppTheme.error : AppTheme.accent)
                                : Colors.white38),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (currentQ.examBadge != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          currentQ.examBadge!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                      ),
                    ],
                    if (currentQ.diagramType != null && currentQ.diagramType != 'none') ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ConceptGeometryVisualizer(
                          diagramType: currentQ.diagramType,
                          themeColor: const Color(0xFF06B6D4),
                          height: 140,
                          showControls: true,
                          margin: const EdgeInsets.only(bottom: 12),
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            currentQ.prompt,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: currentQ.prompt.length > 90
                                  ? 15.5
                                  : (currentQ.prompt.length > 50
                                      ? 18
                                      : (currentQ.prompt.length > 25 ? 24 : 34)),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                            color: _isSpeaking ? AppTheme.accent : Colors.white60,
                            size: 24,
                          ),
                          tooltip: 'Speak Question Aloud',
                          onPressed: _speakCurrentQuestion,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 🎯 MCQ Options vs ⌨️ Tactile Numpad
              if (!_useNumpad) ...[
                // MCQ Power-ups Toolbar (50:50 Lifeline & Trick Hint)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 50:50 Lifeline Button
                      InkWell(
                        onTap: _fiftyFiftyRemaining > 0 && !_isAnswered ? _useFiftyFifty : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _fiftyFiftyRemaining > 0
                                ? Colors.amber.withValues(alpha: 0.15)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _fiftyFiftyRemaining > 0
                                  ? Colors.amber.withValues(alpha: 0.5)
                                  : Colors.white12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 15,
                                color: _fiftyFiftyRemaining > 0 ? Colors.amber : Colors.white38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '50:50 Lifeline ($_fiftyFiftyRemaining left)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _fiftyFiftyRemaining > 0 ? Colors.amber : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Quick Tip Button (pauses timer)
                      _buildQuickTipButton(),
                    ],
                  ),
                ),

                // Options 2x2 Grid with A, B, C, D badges
                Column(
                  children: [
                    for (int i = 0; i < currentQ.options.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildOptionButton(
                                currentQ.options[i],
                                currentQ.correctAnswer,
                                ['A', 'B', 'C', 'D'][i],
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (i + 1 < currentQ.options.length)
                              Expanded(
                                child: _buildOptionButton(
                                  currentQ.options[i + 1],
                                  currentQ.correctAnswer,
                                  ['A', 'B', 'C', 'D'][i + 1],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Center(child: _buildQuickTipButton()),
                ),
                // Numpad Typed Answer Preview Box
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isAnswered
                        ? (_selectedAnswer == currentQ.correctAnswer
                            ? AppTheme.accent.withValues(alpha: 0.2)
                            : AppTheme.error.withValues(alpha: 0.2))
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isAnswered
                          ? (_selectedAnswer == currentQ.correctAnswer
                              ? AppTheme.accent
                              : AppTheme.error)
                          : const Color(0xFF8B5CF6),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _typedAnswer.isEmpty
                        ? (_isAnswered ? 'Ans: ${currentQ.correctAnswer}' : 'Type Answer...')
                        : _typedAnswer,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                      color: _isAnswered
                          ? (_selectedAnswer == currentQ.correctAnswer
                              ? AppTheme.accent
                              : AppTheme.error)
                          : (_typedAnswer.isEmpty ? Colors.white24 : Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Tactile Numpad
                TactileNumpad(
                  isCalculatorLayout: isCalc,
                  onToggleLayout: () {
                    state.updateNumpadStyle(isCalc ? 'phone' : 'calculator');
                  },
                  onDigitPress: _onDigitPress,
                  onBackspace: _onBackspace,
                  onClear: _onClear,
                  onSubmit: () => _onAnswerSelected(_typedAnswer),
                  isSubmitEnabled: _typedAnswer.isNotEmpty && !_isAnswered,
                  submitColor: const Color(0xFF8B5CF6),
                ),
              ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildOptionButton(String option, String correct, String letter) {
    final bool isEliminated = _eliminatedOptions.contains(option);
    Color btnColor = AppTheme.surface;
    Color borderColor = AppTheme.surfaceLight;
    Color textColor = Colors.white;

    if (isEliminated) {
      return Opacity(
        opacity: 0.28,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12, width: 1.5),
          ),
          child: Text(
            option,
            style: const TextStyle(
              fontSize: 20,
              decoration: TextDecoration.lineThrough,
              color: Colors.white38,
            ),
          ),
        ),
      );
    }

    if (_isAnswered) {
      if (option == correct) {
        btnColor = AppTheme.accent.withValues(alpha: 0.2);
        borderColor = AppTheme.accent;
        textColor = AppTheme.accent;
      } else if (option == _selectedAnswer) {
        btnColor = AppTheme.error.withValues(alpha: 0.2);
        borderColor = AppTheme.error;
        textColor = AppTheme.error;
      }
    }

    return GestureDetector(
      onTap: isEliminated ? null : () => _onAnswerSelected(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Text(
                letter,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
