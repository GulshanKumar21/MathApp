import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../models/english_models.dart';
import '../../data/english_content_bank.dart';
import '../../services/vocab_dictionary_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../services/notification_service.dart';
import '../auth/auth_screen.dart';

class RecallSolveScreen extends StatefulWidget {
  final String formula;
  final MistakeModel? mistake;

  const RecallSolveScreen({
    super.key,
    required this.formula,
    this.mistake,
  });

  @override
  State<RecallSolveScreen> createState() => _RecallSolveScreenState();
}

class _RecallSolveScreenState extends State<RecallSolveScreen> with TickerProviderStateMixin {
  late String _cleanFormula;
  late String _correctAnswer;
  late List<String> _options;
  bool _isEnglishQuestion = false;
  String? _matchedEnglishId;
  final TextEditingController _inputCtrl = TextEditingController();

  String? _selectedOption;
  bool _isSubmitted = false;
  bool _isCorrect = false;
  String? _feedbackMessage;

  late AnimationController _popController;
  late Animation<double> _popAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    final isLegacyEnglish = widget.mistake?.topicId.toLowerCase().startsWith('english') == true;
    final cleaned = NotificationService().cleanPrompt(widget.formula);
    if (isLegacyEnglish) {
      _isEnglishQuestion = true;
      _cleanFormula = widget.formula.replaceAll(' = ?', '').trim();
    } else if (cleaned.isNotEmpty) {
      _cleanFormula = cleaned;
    } else {
      final raw = widget.formula.replaceAll(' = ?', '').replaceAll('=?', '').trim();
      _cleanFormula = raw.isNotEmpty ? raw : (widget.mistake?.topicId.toUpperCase() ?? 'Math Recall');
    }
    _deriveAnswerAndOptions();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.10).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.10, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 50),
    ]).animate(_popController);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -12.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: -12.0, end: 12.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 12.0, end: -6.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: -6.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _popController.dispose();
    _shakeController.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  void _deriveAnswerAndOptions() {
    final state = context.read<AppStateProvider>();
    final String rawNorm = widget.formula.replaceAll(' = ?', '').replaceAll(':', '').trim().toLowerCase();

    // 0. Check if this question matches an English mistake / English MCQ bank
    EnglishMistake? matchedEng;
    for (final em in state.englishMistakes) {
      final qNorm = em.questionText.replaceAll(':', '').trim().toLowerCase();
      if (qNorm == rawNorm || em.questionText.trim() == widget.formula.trim()) {
        matchedEng = em;
        break;
      }
    }
    if (matchedEng != null && matchedEng.options.length >= 2) {
      _isEnglishQuestion = true;
      _matchedEnglishId = matchedEng.id;
      _cleanFormula = matchedEng.questionText.trim();
      final idx = matchedEng.correctIndex.clamp(0, matchedEng.options.length - 1);
      _correctAnswer = matchedEng.options[idx].trim();
      _options = List<String>.from(matchedEng.options)..shuffle();
      return;
    }

    // Search built-in English banks in case EnglishMistake was already removed or opened from legacy cache
    final allEnglishQs = <EnglishExerciseQuestion>[
      ...EnglishContentBank.topics.expand((t) => t.exercises),
      ...EnglishContentBank.allOneWordSubstitution,
      ...EnglishContentBank.allSpellingQuestions,
      ...EnglishContentBank.allIdiomQuestions,
      ...EnglishContentBank.allGrammarQuestions,
      ...VocabDictionaryService().getQuestionsForTopic('all'),
    ];
    for (final eq in allEnglishQs) {
      final qNorm = eq.questionText.replaceAll(':', '').trim().toLowerCase();
      if (qNorm == rawNorm || eq.questionText.trim() == widget.formula.trim()) {
        _isEnglishQuestion = true;
        _cleanFormula = eq.questionText.trim();
        final idx = eq.correctIndex.clamp(0, eq.options.length - 1);
        _correctAnswer = eq.options[idx].trim();
        _options = List<String>.from(eq.options)..shuffle();
        return;
      }
    }

    // 1. Try to find from passed mistake or AppStateProvider mistakes
    MistakeModel? matched = widget.mistake;
    if (matched == null) {
      try {
        matched = state.mistakes.firstWhere(
          (m) => NotificationService().cleanPrompt(m.prompt) == _cleanFormula,
        );
      } catch (_) {
        matched = null;
      }
    }

    if (matched != null && matched.topicId.toLowerCase().startsWith('english')) {
      _isEnglishQuestion = true;
      _cleanFormula = matched.prompt.replaceAll(' = ?', '').trim();
      final ans = matched.correctAnswer.trim();
      _correctAnswer = ans.isNotEmpty ? ans : 'None';
      final Set<String> wordOpts = {_correctAnswer};
      if (matched.userAnswer.trim().isNotEmpty &&
          matched.userAnswer.trim().toLowerCase() != _correctAnswer.toLowerCase()) {
        wordOpts.add(matched.userAnswer.trim());
      }
      final fallbackWords = EnglishContentBank.topics.map((t) => t.word).toList()..shuffle();
      for (final w in fallbackWords) {
        if (wordOpts.length >= 4) break;
        if (w.toLowerCase() != _correctAnswer.toLowerCase()) wordOpts.add(w);
      }
      _options = wordOpts.take(4).toList()..shuffle();
      return;
    }

    if (matched != null &&
        matched.correctAnswer.trim().isNotEmpty &&
        (num.tryParse(matched.correctAnswer.trim()) != null ||
            matched.correctAnswer.trim().endsWith('%')) &&
        !matched.correctAnswer.contains(RegExp(r'[×\*xX\+\^²³]'))) {
      _correctAnswer = matched.correctAnswer.trim();
    } else if (matched != null &&
        matched.correctAnswer.trim().isNotEmpty &&
        _computeFallbackAnswer(_cleanFormula) == '0') {
      _correctAnswer = matched.correctAnswer.trim();
    } else {
      // Compute dynamically from clean formula
      _correctAnswer = _computeFallbackAnswer(_cleanFormula);
    }

    // 2. Generate 4 randomized options (without revealing the answer)
    _options = _generateOptions(_correctAnswer, _cleanFormula);
  }

  String _computeFallbackAnswer(String formula) {
    if (formula.trim().isEmpty) return '0';

    final directInt = int.tryParse(formula.trim());
    if (directInt != null) return '$directInt';

    try {
      String clean = NotificationService().cleanPrompt(formula);

      // Squares (e.g. 17²)
      final sqMatch = RegExp(r'(\d+)\s*(?:²|\^2)').firstMatch(clean);
      if (sqMatch != null) {
        int n = int.parse(sqMatch.group(1)!);
        return '${n * n}';
      }

      // Cubes (e.g. 8³)
      final cbMatch = RegExp(r'(\d+)\s*(?:³|\^3)').firstMatch(clean);
      if (cbMatch != null) {
        int n = int.parse(cbMatch.group(1)!);
        return '${n * n * n}';
      }

      // Multiplication
      final multMatch = RegExp(r'(\d+)\s*[×\*xX\u00D7\u2715\u2716]\s*(\d+)').firstMatch(clean);
      if (multMatch != null) {
        int a = int.parse(multMatch.group(1)!);
        int b = int.parse(multMatch.group(2)!);
        return '${a * b}';
      }

      // Addition
      final addMatch = RegExp(r'(\d+)\s*\+\s*(\d+)').firstMatch(clean);
      if (addMatch != null) {
        int a = int.parse(addMatch.group(1)!);
        int b = int.parse(addMatch.group(2)!);
        return '${a + b}';
      }

      // Subtraction
      final subMatch = RegExp(r'(\d+)\s*[\-−\u2212]\s*(\d+)').firstMatch(clean);
      if (subMatch != null) {
        int a = int.parse(subMatch.group(1)!);
        int b = int.parse(subMatch.group(2)!);
        return '${a - b}';
      }

      // Division
      final divMatch = RegExp(r'(\d+)\s*[÷/\u00F7]\s*(\d+)').firstMatch(clean);
      if (divMatch != null) {
        int a = int.parse(divMatch.group(1)!);
        int b = int.parse(divMatch.group(2)!);
        if (b != 0) {
          if (a < b) {
            final pct = (a / b * 100);
            return pct == pct.roundToDouble()
                ? '${pct.toInt()}%'
                : '${pct.toStringAsFixed(2)}%';
          }
          return '${a ~/ b}';
        }
      }
    } catch (_) {}

    return '0';
  }

  List<String> _generateOptions(String correct, String formula) {
    String cleanCorrect = correct.trim();
    int? correctNum = int.tryParse(cleanCorrect);

    if (correctNum == null || cleanCorrect.contains(RegExp(r'[×\*xX\+\-−÷/\^²³]'))) {
      cleanCorrect = _computeFallbackAnswer(formula.isNotEmpty ? formula : cleanCorrect);
      correctNum = int.tryParse(cleanCorrect);
    }

    Set<String> opts = {cleanCorrect};

    if (correctNum != null) {
      if (correctNum == 0) {
        opts.addAll(['1', '2', '3']);
      } else if (correctNum.abs() < 10) {
        // Single-digit answer (< 10): Provide realistic nearby numbers (e.g. 4 -> 5, 8, 1, 3)
        final pool = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5]..shuffle();
        for (int d in pool) {
          if (opts.length >= 4) break;
          int cand = correctNum + d;
          if (cand >= 0 && cand != correctNum) {
            opts.add('$cand');
          }
        }
        int step = 1;
        while (opts.length < 4) {
          if (correctNum + step >= 0) opts.add('${correctNum + step}');
          if (opts.length < 4 && correctNum - step >= 0) opts.add('${correctNum - step}');
          step++;
        }
      } else {
        final int unit = (correctNum % 10).abs();
        final pool = [10, -10, 20, -20, 30, -30, 40, -40, 50, -50]..shuffle();

        for (int d in pool) {
          if (opts.length >= 4) break;
          int cand = correctNum + d;
          if (cand > 0 && cand != correctNum && (cand % 10 == unit)) {
            opts.add('$cand');
          }
        }

        int step = 1;
        while (opts.length < 4) {
          int plus = correctNum + (10 * step);
          if (plus > 0 && plus % 10 == unit) opts.add('$plus');
          if (opts.length < 4) {
            int minus = correctNum - (10 * step);
            if (minus > 0 && minus % 10 == unit) opts.add('$minus');
          }
          step++;
        }
      }
    } else if (cleanCorrect.endsWith('%')) {
      final cleanVal = cleanCorrect.replaceAll('%', '').trim();
      final double? pct = double.tryParse(cleanVal);
      if (pct != null) {
        opts.add('${(pct + 2.38).toStringAsFixed(2)}%');
        opts.add('${(pct - 1.78).abs().toStringAsFixed(2)}%');
        opts.add('${(pct + 5.0).toStringAsFixed(2)}%');
      }
    } else {
      int fallbackVal = int.tryParse(cleanCorrect) ?? 48;
      opts.add('${fallbackVal + 10}');
      opts.add('${fallbackVal - 10 > 0 ? fallbackVal - 10 : fallbackVal + 20}');
      opts.add('${fallbackVal + 30}');
    }

    final list = opts.take(4).toList()..shuffle();
    return list;
  }

  Future<void> _submitAnswer(String answer) async {
    if (_isSubmitted && _isCorrect) return;

    final trimmed = answer.trim();
    if (trimmed.isEmpty) return;

    final bool isRight = trimmed.toLowerCase() == _correctAnswer.toLowerCase();

    setState(() {
      _selectedOption = trimmed;
      _isSubmitted = true;
      _isCorrect = isRight;
    });

    final state = context.read<AppStateProvider>();
    if (!state.isLoggedIn) {
      state.recordGuestQuestionAnswered();
      if (state.isGuestLimitReached) {
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

    if (isRight) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
      _popController.forward(from: 0.0);

      setState(() {
        _feedbackMessage = '🎉 Correct! You solved $_cleanFormula = $trimmed!\nReminder alert cancelled & closing...';
      });

      // Clear from mistakes list and cancel 1-hour periodic notification
      await state.checkAndResolveIfMistake(prompt: _cleanFormula, answer: trimmed);
      if (_matchedEnglishId != null) {
        await state.removeEnglishMistake(_matchedEnglishId!);
      }

      // Auto exit back after 750ms with smooth transition
      Future.delayed(const Duration(milliseconds: 750), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } else {
      try {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 120), () => HapticFeedback.heavyImpact());
      } catch (_) {}
      _shakeController.forward(from: 0.0);

      // Record wrong attempt, update notification, and schedule 1-hour recall notification
      await state.recordWrongRecallAttempt(
        prompt: _cleanFormula,
        wrongAnswer: trimmed,
        correctAnswer: _correctAnswer,
        topicId: widget.mistake?.topicId ?? 'recall',
      );
      setState(() {
        _feedbackMessage = '❌ Incorrect ($trimmed)! Think carefully and try again.\n(1-Hour Recall notification queued)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recall Check'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alarm_on_rounded, color: AppTheme.warning, size: 16),
                  SizedBox(width: 6),
                  Text(
                    '1-Hour Recurring Reminder Active',
                    style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Prompt Card (DOES NOT show the answer!)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'WHAT IS THE RESULT?',
                    style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (_isEnglishQuestion || _cleanFormula.endsWith('?')) ? _cleanFormula : '$_cleanFormula = ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _cleanFormula.length > 22 ? 22 : 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Solve correctly to clear this calculation from alerts',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Feedback Banner if attempted
            if (_feedbackMessage != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isCorrect ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _isCorrect ? AppTheme.accent : AppTheme.error),
                ),
                child: Text(
                  _feedbackMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _isCorrect ? AppTheme.accent : AppTheme.error,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4 Multiple-Choice Options
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Your Answer:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: _options.length,
              itemBuilder: (context, idx) {
                final opt = _options[idx];
                final isChosen = _selectedOption == opt;

                Color cardColor = AppTheme.surface;
                Color borderColor = AppTheme.surfaceLight;
                Color textColor = Colors.white;

                if (isChosen) {
                  if (_isSubmitted) {
                    if (_isCorrect) {
                      cardColor = const Color(0xFF10B981).withValues(alpha: 0.25);
                      borderColor = const Color(0xFF10B981);
                      textColor = const Color(0xFF10B981);
                    } else {
                      cardColor = AppTheme.error.withValues(alpha: 0.25);
                      borderColor = AppTheme.error;
                      textColor = AppTheme.error;
                    }
                  } else {
                    borderColor = AppTheme.primaryLight;
                  }
                }

                Widget optionWidget = Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: isChosen ? 2.2 : 1),
                    boxShadow: (isChosen && _isSubmitted)
                        ? [
                            BoxShadow(
                              color: _isCorrect
                                  ? const Color(0xFF10B981).withValues(alpha: 0.55)
                                  : AppTheme.error.withValues(alpha: 0.45),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isChosen && _isSubmitted) ...[
                        Icon(
                          _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: _isCorrect ? const Color(0xFF10B981) : AppTheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        opt,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor),
                      ),
                    ],
                  ),
                );

                if (isChosen && _isSubmitted) {
                  if (_isCorrect) {
                    optionWidget = ScaleTransition(
                      scale: _popAnimation,
                      child: optionWidget,
                    );
                  } else {
                    optionWidget = AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      ),
                      child: optionWidget,
                    );
                  }
                }

                return GestureDetector(
                  onTap: () {
                    _inputCtrl.text = opt;
                    _submitAnswer(opt);
                  },
                  child: optionWidget,
                );
              },
            ),
            const SizedBox(height: 24),

            // Or Direct Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Or type your answer directly:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter answer...',
                            filled: true,
                            fillColor: AppTheme.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (val) => _submitAnswer(val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                        onPressed: () => _submitAnswer(_inputCtrl.text),
                        child: const Text('Verify'),
                      ),
                    ],
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
