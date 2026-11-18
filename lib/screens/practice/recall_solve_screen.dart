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
  final String? correctAnswer;

  const RecallSolveScreen({
    super.key,
    required this.formula,
    this.mistake,
    this.correctAnswer,
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
  String? _explanation;

  bool _checkIsAnswerCorrect(String typed, String correct) {
    if (typed.toLowerCase().trim() == correct.toLowerCase().trim()) return true;
    final tNum = num.tryParse(typed.replaceAll(',', '').replaceAll(' ', '').trim());
    final cNum = num.tryParse(correct.replaceAll(',', '').replaceAll(' ', '').trim());
    if (tNum != null && cNum != null) {
      return (tNum - cNum).abs() < 0.001;
    }
    return false;
  }

  String _generateMathExplanation(String formula, String answer) {
    try {
      final clean = formula.replaceAll(' = ?', '').replaceAll('=?', '').replaceAll('?', '').trim();
      final multMatch = RegExp(r'(\d+)\s*[×\*xX]\s*(\d+)').firstMatch(clean);
      if (multMatch != null) {
        final a = int.parse(multMatch.group(1)!);
        final b = int.parse(multMatch.group(2)!);
        if (a > 10 && a < 100) {
          final tens = (a ~/ 10) * 10;
          final units = a % 10;
          return '$a × $b = ($tens × $b) + ($units × $b)\n= ${tens * b} + ${units * b} = $answer';
        } else if (b > 10 && b < 100) {
          final tens = (b ~/ 10) * 10;
          final units = b % 10;
          return '$a × $b = ($a × $tens) + ($a × $units)\n= ${a * tens} + ${a * units} = $answer';
        }
        return '$a × $b = $answer';
      }
      final addMatch = RegExp(r'(\d+)\s*\+\s*(\d+)').firstMatch(clean);
      if (addMatch != null) {
        final a = int.parse(addMatch.group(1)!);
        final b = int.parse(addMatch.group(2)!);
        if (a > 10 && b > 10) {
          final tensA = (a ~/ 10) * 10;
          final unitsA = a % 10;
          final tensB = (b ~/ 10) * 10;
          final unitsB = b % 10;
          return '$a + $b = ($tensA + $tensB) + ($unitsA + $unitsB)\n= ${tensA + tensB} + ${unitsA + unitsB} = $answer';
        }
        return '$a + $b = $answer';
      }
      final sqMatch = RegExp(r'(\d+)\s*[²\^2]').firstMatch(clean);
      if (sqMatch != null) {
        final a = int.parse(sqMatch.group(1)!);
        return '$a² = $a × $a = $answer';
      }
      final cubeMatch = RegExp(r'(\d+)\s*[³\^3]').firstMatch(clean);
      if (cubeMatch != null) {
        final a = int.parse(cubeMatch.group(1)!);
        return '$a³ = $a × $a × $a = $answer';
      }
    } catch (_) {}
    return 'Calculation: $formula = $answer';
  }

  late AnimationController _popController;
  late Animation<double> _popAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _detectIsEnglish(String text, MistakeModel? mistake) {
    if (mistake != null) {
      if (mistake.topicId.toLowerCase().startsWith('english')) return true;
      if (num.tryParse(mistake.correctAnswer.trim()) != null) return false;
      final tid = mistake.topicId.toLowerCase();
      if (tid.contains('crossroad') ||
          tid.contains('table') ||
          tid.contains('multi') ||
          tid.contains('square') ||
          tid.contains('cube') ||
          tid.contains('math') ||
          tid.contains('calc') ||
          tid.contains('drill') ||
          tid.contains('numpad') ||
          tid.contains('fraction')) {
        return false;
      }
    }
    final raw = text.trim();
    if (raw.isEmpty) return false;
    final lower = raw.toLowerCase();
    if (lower.contains('pairs of') || lower.contains('table of') || lower.contains('factors of')) {
      return false;
    }
    if (lower.contains('synonym') ||
        lower.contains('antonym') ||
        lower.contains('spelling') ||
        lower.contains('idiom') ||
        lower.contains('one word') ||
        lower.contains('grammar') ||
        lower.contains('meaning') ||
        lower.contains('vocab')) {
      return true;
    }
    // Check if prompt has English words and no arithmetic operators / math terms
    final withoutOf = raw.replaceAll(RegExp(r'\s+of\s+', caseSensitive: false), ' ');
    final hasWords = RegExp(r'[a-zA-Z]{3,}').hasMatch(withoutOf);
    final hasMathSymbols = RegExp(r'[×\*÷/\+²³√∛]').hasMatch(raw);
    final hasMathEquals = RegExp(r'^\s*\d+').hasMatch(raw);
    final hasDigits = RegExp(r'\d').hasMatch(raw);
    return hasWords && (!hasMathSymbols && !hasMathEquals && !hasDigits);
  }

  String _normAlphanumeric(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  @override
  void initState() {
    super.initState();
    _isEnglishQuestion = _detectIsEnglish(widget.formula, widget.mistake);
    if (_isEnglishQuestion) {
      _cleanFormula = widget.formula
          .replaceAll(' = ?', '')
          .replaceAll('=?', '')
          .replaceAll('=', '')
          .trim();
    } else {
      final cleaned = NotificationService().cleanPrompt(widget.formula);
      if (cleaned.isNotEmpty) {
        _cleanFormula = cleaned;
      } else {
        final raw = widget.formula.replaceAll(' = ?', '').replaceAll('=?', '').trim();
        _cleanFormula = raw.isNotEmpty ? raw : (widget.mistake?.topicId.toUpperCase() ?? 'Math Recall');
      }
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
    final String rawNorm = _normAlphanumeric(widget.formula);
    final String cleanNorm = _normAlphanumeric(_cleanFormula);

    // 0. Check if this question matches an English mistake / English MCQ bank
    EnglishMistake? matchedEng;
    for (final em in state.englishMistakes) {
      final qNorm = _normAlphanumeric(em.questionText);
      if (qNorm == rawNorm ||
          qNorm == cleanNorm ||
          (rawNorm.isNotEmpty && (qNorm.contains(rawNorm) || rawNorm.contains(qNorm)))) {
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
      final qNorm = _normAlphanumeric(eq.questionText);
      if (qNorm == rawNorm ||
          qNorm == cleanNorm ||
          (rawNorm.isNotEmpty && (qNorm.contains(rawNorm) || rawNorm.contains(qNorm)))) {
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
          (m) => NotificationService().cleanPrompt(m.prompt) == _cleanFormula ||
              _normAlphanumeric(m.prompt) == rawNorm,
        );
      } catch (_) {
        matched = null;
      }
    }

    // If English is detected, guarantee real vocabulary word choices and never fallback to math numbers
    if (_isEnglishQuestion ||
        (matched != null && matched.topicId.toLowerCase().startsWith('english')) ||
        _detectIsEnglish(_cleanFormula, matched)) {
      _isEnglishQuestion = true;
      if (matched != null && matched.prompt.trim().isNotEmpty) {
        _cleanFormula = matched.prompt.replaceAll(' = ?', '').replaceAll('=?', '').trim();
      }
      final ans = matched?.correctAnswer.trim() ?? '';
      _correctAnswer = (ans.isNotEmpty && num.tryParse(ans) == null) ? ans : 'Careful';
      final Set<String> wordOpts = {_correctAnswer};
      if (matched != null &&
          matched.userAnswer.trim().isNotEmpty &&
          num.tryParse(matched.userAnswer.trim()) == null &&
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

    if (widget.correctAnswer != null && widget.correctAnswer!.trim().isNotEmpty) {
      _correctAnswer = widget.correctAnswer!.trim();
    } else if (matched != null &&
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

    final bool isRight = _checkIsAnswerCorrect(trimmed, _correctAnswer);

    setState(() {
      _selectedOption = trimmed;
      _isSubmitted = true;
      _isCorrect = isRight;
      if (!isRight && !_isEnglishQuestion) {
        _explanation = _generateMathExplanation(_cleanFormula, _correctAnswer);
      } else {
        _explanation = null;
      }
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
        _feedbackMessage = _isEnglishQuestion
            ? '🎉 Correct! "$trimmed" is the right answer!\nMastered & closing...'
            : '🎉 Correct! You solved $_cleanFormula = $trimmed!\nSpaced revision progress saved.';
      });

      // Clear from mistakes list and cancel reminder notification
      await state.checkAndResolveIfMistake(prompt: _cleanFormula, answer: trimmed);
      if (_matchedEnglishId != null) {
        await state.removeEnglishMistake(_matchedEnglishId!);
      }

      // Auto exit back after 1200ms with smooth transition
      Future.delayed(const Duration(milliseconds: 1200), () {
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

      // Record wrong attempt, update notification, and keep in spaced revision loop
      await state.recordWrongRecallAttempt(
        prompt: _cleanFormula,
        wrongAnswer: trimmed,
        correctAnswer: _correctAnswer,
        topicId: widget.mistake?.topicId ?? (_isEnglishQuestion ? 'English: Verbal' : 'recall'),
      );
      setState(() {
        _feedbackMessage = _isEnglishQuestion
            ? '❌ Incorrect ($trimmed)! Think carefully and try again.'
            : '❌ Incorrect ($trimmed)! Correct answer is: $_correctAnswer';
      });
    }
  }

  void _resetForRetry() {
    setState(() {
      _isSubmitted = false;
      _isCorrect = false;
      _selectedOption = null;
      _feedbackMessage = null;
      _explanation = null;
      _inputCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spaced Revision Recall'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 20,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.alarm_on_rounded, color: AppTheme.warning, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '8-Stage Spaced Revision Active',
                          style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Prompt Card (DOES NOT reveal the answer!)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
                      Text(
                        _isEnglishQuestion ? 'VOCABULARY & ENGLISH RECALL' : 'TYPE YOUR ANSWER',
                        style: const TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        (_isEnglishQuestion || _cleanFormula.endsWith('?')) ? _cleanFormula : '$_cleanFormula = ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _cleanFormula.length > 22 ? 22 : (isTablet ? 40 : 34),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isEnglishQuestion
                            ? 'Select or type the correct answer to master this word'
                            : 'No multiple choice — write the answer to solidify retention',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _isCorrect ? AppTheme.accent : AppTheme.error, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _feedbackMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _isCorrect ? AppTheme.accent : AppTheme.error,
                            height: 1.4,
                          ),
                        ),
                        if (_explanation != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.gold, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _explanation!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // MATH REVISION MODE: Type answer directly (Section 3 of PDF Specification)
                if (!_isEnglishQuestion) ...[
                  if (!_isSubmitted || _isCorrect) ...[
                    // Input TextField
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your answer',
                          hintStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          suffixIcon: _inputCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                                  onPressed: () {
                                    setState(() => _inputCtrl.clear());
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (val) => _submitAnswer(val),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.black,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _inputCtrl.text.trim().isNotEmpty ? () => _submitAnswer(_inputCtrl.text) : null,
                        child: const Text(
                          'Submit Answer',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Try Again Button if incorrect
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text(
                          'Try Again',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _resetForRetry,
                      ),
                    ),
                  ],
                ] else ...[
                  // ENGLISH MODE: Multiple Choice Options
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 2 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isTablet ? 2.6 : 2.2,
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

                      Widget optionWidget = AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
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
                            Flexible(
                              child: Text(
                                opt,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: opt.length > 10 ? 16 : 20, fontWeight: FontWeight.w800, color: textColor),
                              ),
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
