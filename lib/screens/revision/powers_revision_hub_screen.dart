import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import '../practice/practice_quiz_screen.dart';
import '../auth/auth_screen.dart';
import '../../services/voice_reciter_helper.dart';
import '../../widgets/voice_studio_modal.dart';

class PowersRevisionHubScreen extends StatefulWidget {
  final bool isCubes; // false = Squares (1-50), true = Cubes (1-30)
  final int? initialNumber;

  const PowersRevisionHubScreen({
    super.key,
    this.isCubes = false,
    this.initialNumber,
  });

  @override
  State<PowersRevisionHubScreen> createState() => _PowersRevisionHubScreenState();
}

class _PowersRevisionHubScreenState extends State<PowersRevisionHubScreen> {
  late int _selectedRangeIndex; // 0 to 4 (5 parts)
  bool _hideAnswers = false;
  bool _is3DFlashcardMode = false;
  final Set<int> _revealedNumbers = {};

  // Audio / TTS Recital
  final FlutterTts _flutterTts = FlutterTts();
  bool _isReciting = false;
  int _currentlySpeakingNumber = -1;

  // Squares 5 Parts: 1-10, 11-20, 21-30, 31-40, 41-50
  static final List<Map<String, dynamic>> _squaresParts = [
    {
      'label': '1 – 10',
      'title': 'Foundation Basics',
      'start': 1,
      'end': 10,
      'color': AppTheme.cyan,
      'icon': Icons.school_rounded,
      'tag': 'WARMUP',
    },
    {
      'label': '11 – 20',
      'title': 'Exam Core (SSC / Bank)',
      'start': 11,
      'end': 20,
      'color': AppTheme.gold,
      'icon': Icons.local_fire_department_rounded,
      'tag': 'HOT CORE',
    },
    {
      'label': '21 – 30',
      'title': 'Speed Standard',
      'start': 21,
      'end': 30,
      'color': AppTheme.accent,
      'icon': Icons.bolt_rounded,
      'tag': 'PRO DRILL',
    },
    {
      'label': '31 – 40',
      'title': 'High Yield Drill',
      'start': 31,
      'end': 40,
      'color': const Color(0xFFEC4899),
      'icon': Icons.trending_up_rounded,
      'tag': 'ADVANCED',
    },
    {
      'label': '41 – 50',
      'title': 'Master 50 Challenge',
      'start': 41,
      'end': 50,
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.workspace_premium_rounded,
      'tag': 'ELITE 50',
    },
  ];

  // Cubes 5 Parts: 1-6, 7-12, 13-18, 19-24, 25-30
  static final List<Map<String, dynamic>> _cubesParts = [
    {
      'label': '1 – 6',
      'title': 'Foundation Cubes',
      'start': 1,
      'end': 6,
      'color': AppTheme.cyan,
      'icon': Icons.school_rounded,
      'tag': 'WARMUP',
    },
    {
      'label': '7 – 12',
      'title': 'Exam High Yield',
      'start': 7,
      'end': 12,
      'color': AppTheme.gold,
      'icon': Icons.local_fire_department_rounded,
      'tag': 'HIGH YIELD',
    },
    {
      'label': '13 – 18',
      'title': 'PO & CGL Core',
      'start': 13,
      'end': 18,
      'color': AppTheme.accent,
      'icon': Icons.bolt_rounded,
      'tag': 'PRO SPEED',
    },
    {
      'label': '19 – 24',
      'title': 'Speed Expansion',
      'start': 19,
      'end': 24,
      'color': const Color(0xFFEC4899),
      'icon': Icons.trending_up_rounded,
      'tag': 'ADVANCED',
    },
    {
      'label': '25 – 30',
      'title': 'Master 30 Cubes',
      'start': 25,
      'end': 30,
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.workspace_premium_rounded,
      'tag': 'ELITE 30',
    },
  ];

  List<Map<String, dynamic>> get _currentParts => widget.isCubes ? _cubesParts : _squaresParts;

  @override
  void initState() {
    super.initState();
    _initSelection();
    _initTts();
  }

  void _initSelection() {
    int target = widget.initialNumber ?? 1;
    final parts = _currentParts;
    int foundPart = 0;
    for (int i = 0; i < parts.length; i++) {
      if (target >= (parts[i]['start'] as int) && target <= (parts[i]['end'] as int)) {
        foundPart = i;
        break;
      }
    }
    _selectedRangeIndex = foundPart;
  }

  Future<void> _initTts() async {
    try {
      final state = context.read<AppStateProvider>();
      await VoiceReciterHelper.applyTtsSettings(
        tts: _flutterTts,
        rate: state.ttsSpeechRate,
        pitch: state.ttsPitch,
        language: state.ttsLanguage,
      );
      _flutterTts.setCompletionHandler(() {
        if (_isReciting && mounted) {
          _speakNextNumber();
        }
      });
    } catch (e) {
      debugPrint('TTS setup: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _stopRecital() {
    _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isReciting = false;
        _currentlySpeakingNumber = -1;
      });
    }
  }

  void _speakNumber(int n) {
    _flutterTts.stop();
    setState(() {
      _currentlySpeakingNumber = n;
      _isReciting = true;
    });
    _speakCurrentNumber();
  }

  void _startRecital() {
    final part = _currentParts[_selectedRangeIndex];
    int start = part['start'] as int;
    setState(() {
      _isReciting = true;
      _currentlySpeakingNumber = start;
    });
    _speakCurrentNumber();
  }

  Future<void> _speakCurrentNumber() async {
    if (!_isReciting || !mounted) return;
    final state = context.read<AppStateProvider>();
    int n = _currentlySpeakingNumber;
    await VoiceReciterHelper.applyTtsSettings(
      tts: _flutterTts,
      rate: state.ttsSpeechRate,
      pitch: state.ttsPitch,
      language: state.ttsLanguage,
    );
    String text = widget.isCubes
        ? VoiceReciterHelper.getCubeSpeechText(number: n, style: state.ttsRecitalStyle)
        : VoiceReciterHelper.getSquareSpeechText(number: n, style: state.ttsRecitalStyle);
    await _flutterTts.speak(text);
  }

  void _speakNextNumber() {
    if (!_isReciting || !mounted) return;
    final part = _currentParts[_selectedRangeIndex];
    int end = part['end'] as int;
    if (_currentlySpeakingNumber < end) {
      setState(() {
        _currentlySpeakingNumber++;
      });
      _speakCurrentNumber();
    } else {
      _stopRecital();
    }
  }

  int _calculateAnswer(int n) {
    return widget.isCubes ? (n * n * n) : (n * n);
  }

  String _formatTrick(int n) {
    if (!widget.isCubes) {
      // Square tricks
      if (n % 10 == 5) {
        int tens = n ~/ 10;
        return 'End with 5: $tens × ${tens + 1} = ${tens * (tens + 1)}, attach 25 -> ${n * n}';
      } else if (n > 25 && n < 50) {
        int diff = 50 - n;
        return 'Base 50: (25 - $diff = ${25 - diff}), attach ${diff * diff < 10 ? '0' : ''}${diff * diff} -> ${n * n}';
      } else if (n > 10 && n <= 25) {
        int diff = n - 10;
        return 'Vedic: ($n + $diff) × 10 + $diff² = ${(n + diff) * 10} + ${diff * diff} = ${n * n}';
      }
      return '$n × $n = ${n * n}';
    } else {
      // Cube tricks
      return '$n × $n × $n = ${n * n * n}';
    }
  }

  void _startPartSpeedQuiz() {
    _stopRecital();
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

    final part = _currentParts[_selectedRangeIndex];
    int start = part['start'] as int;
    int end = part['end'] as int;
    final questions = widget.isCubes
        ? DynamicQuestionEngine.generateCubesRangeQuestions(start: start, end: end, count: 10)
        : DynamicQuestionEngine.generateSquaresRangeQuestions(start: start, end: end, count: 10);

    final title = widget.isCubes
        ? 'Cubes ($start to $end) Speed Drill'
        : 'Squares ($start to $end) Speed Drill';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: widget.isCubes ? 'cubes_${start}_$end' : 'squares_${start}_$end',
            title: title,
            subtitle: '10 Rapid Benchmark Questions',
            type: widget.isCubes ? TopicType.cubes : TopicType.squares,
            iconName: widget.isCubes ? 'view_in_ar_rounded' : 'crop_square_rounded',
          ),
          customQuestions: questions,
          isTimed: true,
          questionCount: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = _currentParts;
    final currentPart = parts[_selectedRangeIndex];
    final Color themeColor = currentPart['color'] as Color;
    final int start = currentPart['start'] as int;
    final int end = currentPart['end'] as int;
    final List<int> numbersInRange = List.generate(end - start + 1, (i) => start + i);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(widget.isCubes ? 'Cubes (1–30) 5-Part Hub' : 'Squares (1–50) 5-Part Hub'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isReciting ? Icons.stop_circle_rounded : Icons.record_voice_over_rounded,
              color: _isReciting ? AppTheme.error : AppTheme.gold,
            ),
            tooltip: _isReciting ? 'Stop Recital' : 'TTS Audio Recital',
            onPressed: () {
              if (_isReciting) {
                _stopRecital();
              } else {
                _startRecital();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Five Parts Tab Bar
          _buildPartsTabBar(parts),

          // 2. Part Summary Banner
          _buildPartHeaderCard(currentPart, themeColor),

          // 3. Interactive Toolbar (List vs 3D Cards, Hide Answers)
          _buildInteractiveToolbar(themeColor),

          // 4. Content (List or 3D Cards)
          Expanded(
            child: _is3DFlashcardMode
                ? _build3DFlipGrid(numbersInRange, themeColor)
                : _buildNumbersList(numbersInRange, themeColor),
          ),

          // 5. Sticky Bottom Action Bar
          _buildBottomActionBar(currentPart, themeColor),
        ],
      ),
    );
  }

  Widget _buildPartsTabBar(List<Map<String, dynamic>> parts) {
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(0, 6, 0, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: parts.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final p = parts[idx];
          final bool isSelected = _selectedRangeIndex == idx;
          final Color col = p['color'] as Color;

          return GestureDetector(
            onTap: () {
              _stopRecital();
              setState(() {
                _selectedRangeIndex = idx;
                _revealedNumbers.clear();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? col.withValues(alpha: 0.18) : AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? col : AppTheme.surfaceLight,
                  width: isSelected ? 1.6 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: col.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(p['icon'] as IconData, size: 16, color: isSelected ? col : Colors.white60),
                  const SizedBox(width: 6),
                  Text(
                    'Part ${idx + 1} (${p['label']})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartHeaderCard(Map<String, dynamic> part, Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.18),
            const Color(0xFF131B2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(part['icon'] as IconData, color: themeColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Part ${_selectedRangeIndex + 1}: ${part['label']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        part['tag'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  part['title'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveToolbar(Color themeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          // View Mode Switcher
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              _stopRecital();
              setState(() => _is3DFlashcardMode = !_is3DFlashcardMode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _is3DFlashcardMode ? themeColor.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _is3DFlashcardMode ? themeColor : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _is3DFlashcardMode ? Icons.style_rounded : Icons.view_agenda_rounded,
                    size: 15,
                    color: _is3DFlashcardMode ? themeColor : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _is3DFlashcardMode ? '🎴 3D Flip Mode' : '📋 List View',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _is3DFlashcardMode ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // Voice Studio Button
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => VoiceStudioModal.show(context, onSettingsChanged: _initTts),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 14, color: AppTheme.accent),
                  SizedBox(width: 4),
                  Text(
                    'Voice',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Hide / Show Answers (Self Test)
          if (!_is3DFlashcardMode)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _hideAnswers = !_hideAnswers;
                  _revealedNumbers.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _hideAnswers ? AppTheme.warning.withValues(alpha: 0.18) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _hideAnswers ? AppTheme.warning : AppTheme.surfaceLight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hideAnswers ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 14,
                      color: _hideAnswers ? AppTheme.warning : Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _hideAnswers ? 'Self-Test (Hidden)' : 'Hide Answers',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _hideAnswers ? AppTheme.warning : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumbersList(List<int> numbers, Color themeColor) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      itemCount: numbers.length,
      itemBuilder: (context, idx) {
        int n = numbers[idx];
        int ans = _calculateAnswer(n);
        bool isSpoken = _isReciting && _currentlySpeakingNumber == n;
        bool isRevealed = !_hideAnswers || _revealedNumbers.contains(n);
        String trick = _formatTrick(n);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSpoken ? themeColor.withValues(alpha: 0.18) : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSpoken ? themeColor : AppTheme.surfaceLight.withValues(alpha: 0.6),
              width: isSpoken ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _speakNumber(n),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.isCubes ? '$n³' : '$n²',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isCubes ? '($n × $n × $n)' : '($n × $n)',
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                        if (isSpoken) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('RECITE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    if (isRevealed) ...[
                      const SizedBox(height: 3),
                      Text(
                        trick,
                        style: const TextStyle(fontSize: 11, color: Colors.white60, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),

              // Answer or Tap to Reveal
              if (isRevealed)
                Text(
                  '=  $ans',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                    letterSpacing: -0.5,
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    setState(() => _revealedNumbers.add(n));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warning.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, color: AppTheme.warning, size: 14),
                        SizedBox(width: 4),
                        Text('Reveal', style: TextStyle(fontSize: 12, color: AppTheme.warning, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
},
    );
  }

  Widget _build3DFlipGrid(List<int> numbers, Color themeColor) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: numbers.length,
      itemBuilder: (context, idx) {
        int n = numbers[idx];
        int ans = _calculateAnswer(n);
        String trick = _formatTrick(n);

        return _Power3DFlipCard(
          number: n,
          isCubes: widget.isCubes,
          answer: ans,
          trick: trick,
          themeColor: themeColor,
        );
      },
    );
  }

  Widget _buildBottomActionBar(Map<String, dynamic> part, Color themeColor) {
    final start = part['start'] as int;
    final end = part['end'] as int;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.surfaceLight.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.bolt_rounded, color: Colors.white),
              label: Text(
                'Speed Quiz: Part ${_selectedRangeIndex + 1} ($start to $end)',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              onPressed: _startPartSpeedQuiz,
            ),
          ),
        ],
      ),
    );
  }
}

class _Power3DFlipCard extends StatefulWidget {
  final int number;
  final bool isCubes;
  final int answer;
  final String trick;
  final Color themeColor;

  const _Power3DFlipCard({
    required this.number,
    required this.isCubes,
    required this.answer,
    required this.trick,
    required this.themeColor,
  });

  @override
  State<_Power3DFlipCard> createState() => _Power3DFlipCardState();
}

class _Power3DFlipCardState extends State<_Power3DFlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double angle = _animation.value * pi;
        final bool isUnder = _animation.value > 0.5;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: _flip,
            child: isUnder
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  )
                : _buildFront(),
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isCubes ? '${widget.number}³' : '${widget.number}²',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isCubes ? 'What is ${widget.number}³?' : 'What is ${widget.number}²?',
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_rounded, size: 12, color: widget.themeColor),
              const SizedBox(width: 4),
              const Text('Tap to Flip', style: TextStyle(fontSize: 9.5, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0F172A), widget.themeColor.withValues(alpha: 0.3)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeColor,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '= ${widget.answer}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: widget.themeColor),
          ),
          const SizedBox(height: 6),
          Text(
            widget.trick,
            style: const TextStyle(fontSize: 9.5, color: Colors.white70, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Text('Tap to flip back', style: TextStyle(fontSize: 9.5, color: Colors.white38)),
        ],
      ),
    );
  }
}
