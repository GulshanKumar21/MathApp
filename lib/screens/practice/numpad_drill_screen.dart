import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import '../../services/voice_reciter_helper.dart';
import '../../widgets/tactile_numpad.dart';
import '../auth/auth_screen.dart';

class NumpadDrillScreen extends StatefulWidget {
  final TopicType? initialTopicType;
  final String? initialSubOption;
  final List<QuestionModel>? customQuestions;
  final String? customTitle;
  final int? initialQuestionCount; // e.g. 10, 15, 25, 50, or -1 for endless
  final bool? startInMcqMode;

  const NumpadDrillScreen({
    super.key,
    this.initialTopicType,
    this.initialSubOption,
    this.customQuestions,
    this.customTitle,
    this.initialQuestionCount,
    this.startInMcqMode,
  });

  @override
  State<NumpadDrillScreen> createState() => _NumpadDrillScreenState();
}

class _NumpadDrillScreenState extends State<NumpadDrillScreen> {
  late QuestionModel _currentQ;
  String _typedAnswer = '';
  int _score = 0;
  int _questionCount = 0;
  int _correctCount = 0;
  int _streak = 0;
  int _bestStreak = 0;
  Timer? _elapsedTimer;
  int _seconds = 0;

  // 🎙️ Voice Coach / Audio Question Reader
  final FlutterTts _flutterTts = FlutterTts();
  bool _isAutoSpeakEnabled = false;
  bool _isSpeaking = false;

  // Mode: Numpad vs MCQ
  bool _isMcqMode = false;

  // Settings
  int _targetQuestionCount = 15; // 10, 15, 25, 50, -1 (endless)
  double? _perQuestionTimerSeconds; // null for untimed, 10.0, 5.0, 3.0
  double _questionTimeRemaining = 0.0;
  Timer? _countdownTimer;

  // Selected Category & Sub-options
  int _selectedCategoryIndex = 0;
  String _selectedSubOption = 'all';
  int _selectedSingleTable = 17;
  final Set<int> _mixSelectedTables = {12, 17, 19};

  // Feedback states
  int _feedbackState = 0; // 0: idle, 1: correct, -1: wrong
  String _revealedCorrectAnswer = '';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _topics = [
    {
      'id': 'mixed',
      'label': '⚡ Mixed Speed',
      'icon': Icons.bolt_rounded,
      'color': AppTheme.cyan,
      'type': null,
    },
    {
      'id': 'tables',
      'label': '✖️ Tables (1–50)',
      'icon': Icons.grid_view_rounded,
      'color': AppTheme.gold,
      'type': TopicType.tables,
    },
    {
      'id': 'squares',
      'label': '² Squares (1–50)',
      'icon': Icons.crop_square_rounded,
      'color': AppTheme.accent,
      'type': TopicType.squares,
    },
    {
      'id': 'cubes',
      'label': '³ Cubes (1–30)',
      'icon': Icons.view_in_ar_rounded,
      'color': AppTheme.primaryLight,
      'type': TopicType.cubes,
    },
    {
      'id': 'addition',
      'label': '➕ Addition',
      'icon': Icons.add_rounded,
      'color': Color(0xFF10B981),
      'type': TopicType.addition,
    },
    {
      'id': 'subtraction',
      'label': '➖ Subtraction',
      'icon': Icons.remove_rounded,
      'color': Color(0xFFF97316),
      'type': TopicType.subtraction,
    },
    {
      'id': 'multiplication',
      'label': '✖️ Hard Multipliers',
      'icon': Icons.close_rounded,
      'color': Color(0xFFEC4899),
      'type': TopicType.hardMultiplier,
    },
    {
      'id': 'division',
      'label': '➗ Division',
      'icon': Icons.safety_divider_rounded,
      'color': Color(0xFF14B8A6),
      'type': TopicType.division,
    },
    {
      'id': 'fractions',
      'label': '½ Fractions',
      'icon': Icons.pie_chart_rounded,
      'color': Colors.purpleAccent,
      'type': TopicType.fractions,
    },
    {
      'id': 'triples',
      'label': '📐 Triples',
      'icon': Icons.change_history_rounded,
      'color': Colors.amberAccent,
      'type': TopicType.triples,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.startInMcqMode != null) {
      _isMcqMode = widget.startInMcqMode!;
    }
    if (widget.initialQuestionCount != null) {
      _targetQuestionCount = widget.initialQuestionCount!;
    }

    // Match initial topic if passed
    if (widget.initialTopicType != null) {
      final idx = _topics.indexWhere((t) => t['type'] == widget.initialTopicType);
      if (idx != -1) {
        _selectedCategoryIndex = idx;
      }
    }
    if (widget.initialSubOption != null) {
      _selectedSubOption = widget.initialSubOption!;
    } else {
      _selectedSubOption = _getDefaultSubOptionForTopic(_topics[_selectedCategoryIndex]['id'] as String);
    }

    _initTts();
    _loadQuestion();

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppStateProvider>();
      if (state.isGuestLimitReached) {
        _stopAllTimers();
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
    if (!mounted) return;
    try {
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
        prompt: _currentQ.prompt,
        style: state.ttsRecitalStyle,
      );
      if (mounted) {
        setState(() => _isSpeaking = true);
      }
      await _flutterTts.speak(spokenText);
    } catch (_) {}
  }

  String _getDefaultSubOptionForTopic(String topicId) {
    switch (topicId) {
      case 'tables':
        return '11-20';
      case 'squares':
      case 'cubes':
        return 'all';
      case 'addition':
      case 'subtraction':
        return '2d';
      case 'multiplication':
        return '2d1d';
      case 'division':
        return '2d1d';
      case 'fractions':
      case 'triples':
      case 'mixed':
      default:
        return 'all';
    }
  }

  @override
  void dispose() {
    _stopAllTimers();
    _flutterTts.stop();
    super.dispose();
  }

  void _stopAllTimers() {
    _elapsedTimer?.cancel();
    _countdownTimer?.cancel();
  }

  void _startQuestionCountdown() {
    _countdownTimer?.cancel();
    if (_perQuestionTimerSeconds == null) return;

    _questionTimeRemaining = _perQuestionTimerSeconds!;
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _questionTimeRemaining -= 0.1;
        if (_questionTimeRemaining <= 0) {
          timer.cancel();
          _questionTimeRemaining = 0.0;
          if (!_isProcessing) {
            _onSubmit(isTimeout: true);
          }
        }
      });
    });
  }

  List<Map<String, dynamic>> _getSubOptionsForCurrentTopic() {
    final topicId = _topics[_selectedCategoryIndex]['id'] as String;
    switch (topicId) {
      case 'tables':
        return [
          {'id': '1-10', 'label': '1–10 (Easy)', 'icon': Icons.school_rounded},
          {'id': '11-20', 'label': '11–20 (Core)', 'icon': Icons.local_fire_department_rounded},
          {'id': '21-30', 'label': '21–30 (Adv)', 'icon': Icons.bolt_rounded},
          {'id': '31-40', 'label': '31–40 (Pro)', 'icon': Icons.trending_up_rounded},
          {'id': '41-50', 'label': '41–50 (Master)', 'icon': Icons.workspace_premium_rounded},
          {'id': 'all', 'label': 'All 1–50', 'icon': Icons.all_inclusive_rounded},
          {'id': 'single', 'label': '🎯 Table $_selectedSingleTable', 'icon': Icons.filter_1_rounded},
          {'id': 'mix', 'label': '🔀 Mix (${_mixSelectedTables.length})', 'icon': Icons.shuffle_rounded},
        ];
      case 'squares':
        return [
          {'id': '1-10', 'label': '1–10 (Basics)'},
          {'id': '11-20', 'label': '11–20 (Core)'},
          {'id': '21-30', 'label': '21–30 (Adv)'},
          {'id': '31-40', 'label': '31–40 (Pro)'},
          {'id': '41-50', 'label': '41–50 (Master)'},
          {'id': 'all', 'label': 'All 1–50'},
        ];
      case 'cubes':
        return [
          {'id': '1-10', 'label': '1–10 (Basics)'},
          {'id': '11-20', 'label': '11–20 (Core)'},
          {'id': '21-30', 'label': '21–30 (Master)'},
          {'id': 'all', 'label': 'All 1–30'},
        ];
      case 'addition':
        return [
          {'id': '1d', 'label': '1-Digit (7+8)'},
          {'id': '2d', 'label': '2-Digit (47+68)'},
          {'id': '3d', 'label': '3-Digit (348+592)'},
          {'id': '4d', 'label': '4-Digit (2458+3791)'},
        ];
      case 'subtraction':
        return [
          {'id': '1d', 'label': '1-Digit (14−8)'},
          {'id': '2d', 'label': '2-Digit (83−29)'},
          {'id': '3d', 'label': '3-Digit (542−189)'},
          {'id': '4d', 'label': '4-Digit (5824−1967)'},
        ];
      case 'multiplication':
        return [
          {'id': '2d1d', 'label': '2D × 1D (17×8)'},
          {'id': '2d2d', 'label': '2D × 2D (23×45)'},
          {'id': '3d1d', 'label': '3D × 1D (125×7)'},
          {'id': 'all', 'label': 'Mixed Multipliers'},
        ];
      case 'division':
        return [
          {'id': '2d1d', 'label': '2D ÷ 1D (84÷7)'},
          {'id': '3d1d', 'label': '3D ÷ 1D (348÷6)'},
          {'id': '4d2d', 'label': '4D ÷ 2D (1248÷12)'},
        ];
      case 'fractions':
        return [
          {'id': 'all', 'label': 'All Fractions'},
          {'id': 'percent', 'label': 'Percentages (1/4 → 25%)'},
          {'id': 'decimal', 'label': 'Decimals (1/4 → 0.25)'},
        ];
      case 'triples':
        return [
          {'id': 'core', 'label': 'Core (3-4-5, 5-12-13)'},
          {'id': 'master', 'label': 'Master Triples'},
        ];
      case 'mixed':
      default:
        return [
          {'id': 'all', 'label': '⚡ Speed All-Rounder'},
        ];
    }
  }

  void _loadQuestion() {
    if (widget.customQuestions != null && widget.customQuestions!.isNotEmpty) {
      int idx = _questionCount % widget.customQuestions!.length;
      _currentQ = widget.customQuestions![idx];
    } else {
      _currentQ = _generateQuestionFromConfig();
    }

    _typedAnswer = '';
    _feedbackState = 0;
    _revealedCorrectAnswer = '';
    _isProcessing = false;
    _startQuestionCountdown();

    if (_isAutoSpeakEnabled) {
      _speakCurrentQuestion();
    }
  }

  QuestionModel _generateQuestionFromConfig() {
    final topicId = _topics[_selectedCategoryIndex]['id'] as String;

    try {
      if (topicId == 'tables') {
        switch (_selectedSubOption) {
          case '1-10':
            return DynamicQuestionEngine.generateTableRangeQuestions(startTable: 2, endTable: 10, count: 1).first;
          case '11-20':
            return DynamicQuestionEngine.generateTableRangeQuestions(startTable: 11, endTable: 20, count: 1).first;
          case '21-30':
            return DynamicQuestionEngine.generateTableRangeQuestions(startTable: 21, endTable: 30, count: 1).first;
          case '31-40':
            return DynamicQuestionEngine.generateTableRangeQuestions(startTable: 31, endTable: 40, count: 1).first;
          case '41-50':
            return DynamicQuestionEngine.generateTableRangeQuestions(startTable: 41, endTable: 50, count: 1).first;
          case 'single':
            return DynamicQuestionEngine.generateTableQuestions(_selectedSingleTable, count: 1).first;
          case 'mix':
            final tables = _mixSelectedTables.length >= 2 ? _mixSelectedTables.toList() : [12, 17, 19];
            return DynamicQuestionEngine.generateMultiTableQuestions(tables: tables, count: 1).first;
          case 'all':
          default:
            return DynamicQuestionEngine.generateTableRangeQuestions(startTable: 2, endTable: 50, count: 1).first;
        }
      }

      if (topicId == 'squares') {
        int start = 1;
        int end = 50;
        switch (_selectedSubOption) {
          case '1-10':
            start = 1; end = 10; break;
          case '11-20':
            start = 11; end = 20; break;
          case '21-30':
            start = 21; end = 30; break;
          case '31-40':
            start = 31; end = 40; break;
          case '41-50':
            start = 41; end = 50; break;
          case 'all':
          default:
            start = 1; end = 50; break;
        }
        return DynamicQuestionEngine.generateSquaresRangeQuestions(start: start, end: end, count: 1).first;
      }

      if (topicId == 'cubes') {
        int start = 1;
        int end = 30;
        switch (_selectedSubOption) {
          case '1-10':
            start = 1; end = 10; break;
          case '11-20':
            start = 11; end = 20; break;
          case '21-30':
            start = 21; end = 30; break;
          case 'all':
          default:
            start = 1; end = 30; break;
        }
        return DynamicQuestionEngine.generateCubesRangeQuestions(start: start, end: end, count: 1).first;
      }

      if (topicId == 'addition') {
        int digits = int.tryParse(_selectedSubOption.replaceAll('d', '')) ?? 2;
        return DynamicQuestionEngine.generateDigitSpecificQuestions(type: TopicType.addition, digits: digits, count: 1).first;
      }

      if (topicId == 'subtraction') {
        int digits = int.tryParse(_selectedSubOption.replaceAll('d', '')) ?? 2;
        return DynamicQuestionEngine.generateDigitSpecificQuestions(type: TopicType.subtraction, digits: digits, count: 1).first;
      }

      if (topicId == 'multiplication') {
        if (_selectedSubOption == '2d1d') {
          return DynamicQuestionEngine.generateDigitSpecificQuestions(type: TopicType.hardMultiplier, digits: 1, count: 1).first;
        } else if (_selectedSubOption == '2d2d') {
          return DynamicQuestionEngine.generateDigitSpecificQuestions(type: TopicType.hardMultiplier, digits: 2, count: 1).first;
        } else if (_selectedSubOption == '3d1d') {
          return DynamicQuestionEngine.generateDigitSpecificQuestions(type: TopicType.hardMultiplier, digits: 3, count: 1).first;
        }
        return DynamicQuestionEngine.generateHardMultiplierQuestions(count: 1).first;
      }

      if (topicId == 'division') {
        int digits = 2;
        if (_selectedSubOption == '3d1d') digits = 3;
        if (_selectedSubOption == '4d2d') digits = 4;
        return DynamicQuestionEngine.generateDigitSpecificQuestions(type: TopicType.division, digits: digits, count: 1).first;
      }

      if (topicId == 'fractions') {
        return DynamicQuestionEngine.generateUniqueQuestions(type: TopicType.fractions, count: 1).first;
      }

      if (topicId == 'triples') {
        return DynamicQuestionEngine.generateUniqueQuestions(type: TopicType.triples, count: 1).first;
      }

      // Mixed
      final randomPool = [
        TopicType.tables,
        TopicType.squares,
        TopicType.cubes,
        TopicType.addition,
        TopicType.subtraction,
        TopicType.hardMultiplier,
        TopicType.division,
      ];
      final picked = randomPool[DateTime.now().millisecond % randomPool.length];
      return DynamicQuestionEngine.generateUniqueQuestions(type: picked, count: 1).first;
    } catch (_) {
      return DynamicQuestionEngine.generateUniqueQuestions(type: TopicType.tables, count: 1).first;
    }
  }

  void _onDigitPress(String digit) {
    if (_isProcessing) return;
    context.read<AppStateProvider>().triggerHapticFeedback();
    if (_typedAnswer.length >= 6) return;
    setState(() {
      _typedAnswer += digit;
    });

    if (_typedAnswer == _currentQ.correctAnswer) {
      _onSubmit(isAuto: true);
    }
  }

  void _onBackspace() {
    if (_isProcessing) return;
    context.read<AppStateProvider>().triggerHapticFeedback();
    if (_typedAnswer.isNotEmpty) {
      setState(() {
        _typedAnswer = _typedAnswer.substring(0, _typedAnswer.length - 1);
      });
    }
  }

  void _onClear() {
    if (_isProcessing) return;
    context.read<AppStateProvider>().triggerHapticFeedback();
    setState(() {
      _typedAnswer = '';
    });
  }

  void _onSubmit({bool isAuto = false, String? mcqChoice, bool isTimeout = false}) {
    if (_isProcessing) return;
    _countdownTimer?.cancel();

    final answerToSubmit = isTimeout ? 'TIMEOUT' : (mcqChoice ?? _typedAnswer);
    if (!isTimeout && answerToSubmit.isEmpty) return;

    final appState = context.read<AppStateProvider>();
    if (!appState.isLoggedIn) {
      appState.recordGuestQuestionAnswered();
      if (appState.isGuestLimitReached) {
        _stopAllTimers();
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

    _isProcessing = true;
    final bool correct = !isTimeout && answerToSubmit.trim() == _currentQ.correctAnswer.trim();
    _questionCount++;

    if (correct) {
      _correctCount++;
      _streak++;
      if (_streak > _bestStreak) _bestStreak = _streak;
      _score += 10 + (_streak > 2 ? 5 : 0);
      _feedbackState = 1;

      appState.checkAndResolveIfMistake(
        prompt: _currentQ.prompt,
        answer: answerToSubmit,
      );

      setState(() {});

      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _proceedToNext();
      });
    } else {
      _streak = 0;
      _feedbackState = -1;
      _revealedCorrectAnswer = _currentQ.correctAnswer;

      appState.recordPracticeResult(
        PracticeResult(
          totalQuestions: 1,
          correctCount: 0,
          wrongCount: 1,
          accuracy: 0,
          avgTimeSeconds: 2,
          score: 0,
          topicId: 'numpad_drill',
          date: DateTime.now(),
        ),
        [
          MistakeModel(
            id: 'numpad_${DateTime.now().millisecondsSinceEpoch}',
            prompt: _currentQ.prompt,
            userAnswer: isTimeout ? 'Timed Out' : answerToSubmit,
            correctAnswer: _currentQ.correctAnswer,
            topicId: 'numpad',
            timestamp: DateTime.now(),
          )
        ],
      );

      setState(() {});

      Future.delayed(const Duration(milliseconds: 950), () {
        if (!mounted) return;
        _proceedToNext();
      });
    }
  }

  void _proceedToNext() {
    if (_targetQuestionCount != -1 && _questionCount >= _targetQuestionCount) {
      _stopAllTimers();
      _showFinishSheet();
    } else {
      setState(() {
        _loadQuestion();
      });
    }
  }

  void _showFinishSheet() {
    final accuracy = _questionCount > 0 ? ((_correctCount / _questionCount) * 100).toInt() : 0;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.military_tech_rounded, size: 44, color: AppTheme.accent),
            ),
            const SizedBox(height: 12),
            const Text(
              'Speed Calculation Drill Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Score: $_score pts  •  Accuracy: $accuracy%',
              style: const TextStyle(color: AppTheme.gold, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statPill('Correct', '$_correctCount/$_questionCount', AppTheme.accent),
                _statPill('Best Streak', '🔥 $_bestStreak', Colors.amber),
                _statPill('Time', '${_seconds}s', AppTheme.cyan),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Exit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _stopAllTimers();
                      setState(() {
                        _questionCount = 0;
                        _correctCount = 0;
                        _score = 0;
                        _streak = 0;
                        _seconds = 0;
                        _loadQuestion();
                        _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                          if (mounted) setState(() => _seconds++);
                        });
                      });
                    },
                    child: const Text('Play Again ⚡'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showSingleTablePicker() {
    final state = context.read<AppStateProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Select Specific Table (1–50)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Directly master any table with tactile numpad reflex',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.25,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 50,
                  itemBuilder: (_, index) {
                    int tableNum = index + 1;
                    bool isSelected = _selectedSingleTable == tableNum;
                    bool isStarred = state.starredTables.contains(tableNum);
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          _selectedSingleTable = tableNum;
                          _selectedSubOption = 'single';
                          _loadQuestion();
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accent
                              : (isStarred ? AppTheme.gold.withValues(alpha: 0.18) : AppTheme.surfaceLight),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accent
                                : (isStarred ? AppTheme.gold : Colors.white12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$tableNum',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMixTablePicker() {
    final tempSelected = Set<int>.from(_mixSelectedTables);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🔀 Mix Tables Practice',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${tempSelected.length} Selected',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select 2 or more tables to mix randomly (zero hardcoding)',
                  style: TextStyle(fontSize: 12, color: Colors.white60),
                ),
                const SizedBox(height: 12),

                // Quick presets
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: const Text('11–15 Core', style: TextStyle(fontSize: 11)),
                        onPressed: () => setModalState(() {
                          tempSelected.clear();
                          tempSelected.addAll([11, 12, 13, 14, 15]);
                        }),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('16–20 Pro', style: TextStyle(fontSize: 11)),
                        onPressed: () => setModalState(() {
                          tempSelected.clear();
                          tempSelected.addAll([16, 17, 18, 19, 20]);
                        }),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('Primes (13,17,19,23,29)', style: TextStyle(fontSize: 11)),
                        onPressed: () => setModalState(() {
                          tempSelected.clear();
                          tempSelected.addAll([13, 17, 19, 23, 29]);
                        }),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('Clear', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
                        onPressed: () => setModalState(() => tempSelected.clear()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: 49,
                    itemBuilder: (_, index) {
                      int t = index + 2; // 2 to 50
                      bool isSel = tempSelected.contains(t);
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setModalState(() {
                            if (isSel) {
                              tempSelected.remove(t);
                            } else {
                              tempSelected.add(t);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFA855F7) : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSel ? const Color(0xFFA855F7) : Colors.white12),
                          ),
                          child: Center(
                            child: Text(
                              '$t',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSel ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tempSelected.length >= 2 ? AppTheme.accent : Colors.white24,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: tempSelected.length < 2
                      ? null
                      : () {
                          setState(() {
                            _mixSelectedTables.clear();
                            _mixSelectedTables.addAll(tempSelected);
                            _selectedSubOption = 'mix';
                            _loadQuestion();
                          });
                          Navigator.pop(ctx);
                        },
                  child: Text(
                    tempSelected.length < 2 ? 'Select at least 2 tables' : 'Start Mix Drill (${tempSelected.length} Tables) ⚡',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDrillSettingsSheet() {
    final state = context.read<AppStateProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppTheme.accent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Drill Configuration & Pace',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Question Count Target
              const Text(
                'Target Questions:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [10, 15, 25, 50, -1].map((cnt) {
                  bool isSel = _targetQuestionCount == cnt;
                  String label = cnt == -1 ? '♾️ Endless' : '$cnt Qs';
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSel,
                    selectedColor: AppTheme.primaryLight,
                    backgroundColor: AppTheme.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Colors.white70,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _targetQuestionCount = cnt);
                        setModalState(() {});
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // 2. Per-Question Timer Pace
              const Text(
                'Speed Timer Mode:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  {'val': null, 'label': 'No Timer (Untimed)'},
                  {'val': 10.0, 'label': '10s Relaxed'},
                  {'val': 5.0, 'label': '5s Speed Drill'},
                  {'val': 3.0, 'label': '3s Exam Blitz'},
                ].map((item) {
                  final double? val = item['val'] as double?;
                  bool isSel = _perQuestionTimerSeconds == val;
                  return ChoiceChip(
                    label: Text(item['label'] as String),
                    selected: isSel,
                    selectedColor: AppTheme.accent,
                    backgroundColor: AppTheme.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : Colors.white70,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (sel) {
                      if (sel) {
                        setState(() {
                          _perQuestionTimerSeconds = val;
                          _startQuestionCountdown();
                        });
                        setModalState(() {});
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // 3. Numpad layout toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Numpad Layout Style:',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _styleToggleBtn('📱 Phone', state.numpadStyle != 'calculator', () {
                          state.updateNumpadStyle('phone');
                          setModalState(() {});
                        }),
                        _styleToggleBtn('🧮 Calculator', state.numpadStyle == 'calculator', () {
                          state.updateNumpadStyle('calculator');
                          setModalState(() {});
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _styleToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isCalc = state.numpadStyle == 'calculator';
    final subOptions = _getSubOptionsForCurrentTopic();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(widget.customTitle ?? '⚡ Speed Drill Arena'),
        actions: [
          // Mode Toggle (Numpad vs MCQ)
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeTab('⌨️ Keypad', !_isMcqMode, () {
                  if (_isMcqMode) setState(() => _isMcqMode = false);
                }),
                _buildModeTab('🎯 MCQ', _isMcqMode, () {
                  if (!_isMcqMode) setState(() => _isMcqMode = true);
                }),
              ],
            ),
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

          // Settings Button
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.accent, size: 20),
            tooltip: 'Drill Settings',
            onPressed: _showDrillSettingsSheet,
          ),

          // Target Counter / Finish
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _targetQuestionCount == -1
                  ? InkWell(
                      onTap: _showFinishSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accent, width: 0.8),
                        ),
                        child: Text(
                          '#$_questionCount • Stop',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.accent),
                        ),
                      ),
                    )
                  : Text(
                      '${_questionCount + 1}/$_targetQuestionCount',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Per-question Timer Progress Bar
            if (_perQuestionTimerSeconds != null)
              LinearProgressIndicator(
                value: (_questionTimeRemaining / _perQuestionTimerSeconds!).clamp(0.0, 1.0),
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _questionTimeRemaining < 1.5 ? Colors.redAccent : AppTheme.accent,
                ),
                minHeight: 3,
              ),

            // 1. Topic Categories Selector Bar (Row 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: List.generate(_topics.length, (idx) {
                  final isSel = _selectedCategoryIndex == idx;
                  final topic = _topics[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Icon(
                        topic['icon'] as IconData,
                        size: 14,
                        color: isSel ? Colors.white : (topic['color'] as Color),
                      ),
                      label: Text(topic['label'] as String),
                      selected: isSel,
                      selectedColor: topic['color'] as Color,
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        color: isSel ? Colors.black : Colors.white70,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategoryIndex = idx;
                            _selectedSubOption = _getDefaultSubOptionForTopic(topic['id'] as String);
                            _loadQuestion();
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),

            // 2. Sub-options Selector Bar (Row 2)
            if (subOptions.length > 1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  children: subOptions.map((sub) {
                    final subId = sub['id'] as String;
                    final isSel = _selectedSubOption == subId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        avatar: sub.containsKey('icon')
                            ? Icon(sub['icon'] as IconData, size: 12, color: isSel ? Colors.white : AppTheme.textMuted)
                            : null,
                        label: Text(sub['label'] as String),
                        selected: isSel,
                        selectedColor: AppTheme.primaryLight,
                        backgroundColor: AppTheme.surfaceLight.withValues(alpha: 0.5),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : Colors.white60,
                        ),
                        onSelected: (val) {
                          if (subId == 'single') {
                            _showSingleTablePicker();
                          } else if (subId == 'mix') {
                            _showMixTablePicker();
                          } else {
                            setState(() {
                              _selectedSubOption = subId;
                              _loadQuestion();
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            // 3. Stats bar: Streak, Score & Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: _streak > 0 ? Colors.amber.withValues(alpha: 0.18) : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _streak > 0 ? Colors.amber.withValues(alpha: 0.5) : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          _streak > 0 ? '🔥 $_streak Streak' : '⚡ 0 Streak',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: _streak > 0 ? Colors.amber : Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Score: $_score',
                        style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        '${_seconds}s',
                        style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 4. Question Flashcard Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.surfaceLight, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isMcqMode ? 'SELECT THE CORRECT ANSWER' : 'TYPE ANSWER DIRECTLY',
                              style: const TextStyle(
                                fontSize: 10.5,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.cyan,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _currentQ.prompt,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
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

                      const SizedBox(height: 10),

                      // 5. Answer Input (Numpad Typed Box vs MCQ 4-Option Grid)
                      if (!_isMcqMode) ...[
                        _buildAnswerDisplay(),
                      ] else ...[
                        _buildMcqOptions(),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 6. Tactile Numpad (Keypad mode only)
            if (!_isMcqMode)
              TactileNumpad(
                isCalculatorLayout: isCalc,
                onToggleLayout: () {
                  state.updateNumpadStyle(isCalc ? 'phone' : 'calculator');
                },
                onDigitPress: _onDigitPress,
                onBackspace: _onBackspace,
                onClear: _onClear,
                onSubmit: () => _onSubmit(),
                isSubmitEnabled: _typedAnswer.isNotEmpty && !_isProcessing,
                submitColor: AppTheme.accent,
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerDisplay() {
    Color borderColor = AppTheme.primaryLight.withValues(alpha: 0.7);
    Color bgColor = AppTheme.surface;
    Color textColor = AppTheme.accent;

    if (_feedbackState == 1) {
      borderColor = AppTheme.accent;
      bgColor = AppTheme.accent.withValues(alpha: 0.15);
      textColor = AppTheme.accent;
    } else if (_feedbackState == -1) {
      borderColor = AppTheme.error;
      bgColor = AppTheme.error.withValues(alpha: 0.15);
      textColor = AppTheme.error;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_feedbackState == 1)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 24),
                )
              else if (_feedbackState == -1)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.cancel_rounded, color: AppTheme.error, size: 24),
                ),
              Text(
                _typedAnswer.isEmpty
                    ? (_feedbackState == 0 ? 'Type Answer...' : '')
                    : _typedAnswer,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                  color: _typedAnswer.isEmpty ? Colors.white24 : textColor,
                ),
              ),
            ],
          ),
          if (_feedbackState == -1 && _revealedCorrectAnswer.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              'Correct: $_revealedCorrectAnswer',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.gold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMcqOptions() {
    final options = _currentQ.options;
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (int i = 0; i < options.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: _buildMcqOptionCard(options[i], ['A', 'B', 'C', 'D'][i])),
                  const SizedBox(width: 10),
                  if (i + 1 < options.length)
                    Expanded(child: _buildMcqOptionCard(options[i + 1], ['A', 'B', 'C', 'D'][i + 1])),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMcqOptionCard(String option, String letter) {
    Color cardColor = AppTheme.surface;
    Color borderColor = AppTheme.surfaceLight;
    Color textColor = Colors.white;

    if (_feedbackState != 0) {
      if (option == _currentQ.correctAnswer) {
        cardColor = AppTheme.accent.withValues(alpha: 0.2);
        borderColor = AppTheme.accent;
        textColor = AppTheme.accent;
      } else if (option == _typedAnswer && _feedbackState == -1) {
        cardColor = AppTheme.error.withValues(alpha: 0.2);
        borderColor = AppTheme.error;
        textColor = AppTheme.error;
      }
    }

    return InkWell(
      onTap: _isProcessing
          ? null
          : () {
              setState(() => _typedAnswer = option);
              _onSubmit(mcqChoice: option);
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
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
                  fontSize: 20,
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
