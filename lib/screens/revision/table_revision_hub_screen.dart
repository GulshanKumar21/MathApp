import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import '../practice/arithmetic_digit_selection_screen.dart';
import '../practice/practice_quiz_screen.dart';
import '../auth/auth_screen.dart';
import '../../services/voice_reciter_helper.dart';
import '../../widgets/voice_studio_modal.dart';

class TableRevisionHubScreen extends StatefulWidget {
  final int initialTable;
  final bool isEmbedded;

  const TableRevisionHubScreen({
    super.key,
    this.initialTable = 2,
    this.isEmbedded = false,
  });

  @override
  State<TableRevisionHubScreen> createState() => _TableRevisionHubScreenState();
}

class _TableRevisionHubScreenState extends State<TableRevisionHubScreen> {
  late int _selectedTable;
  String _selectedRangeCategory = '1-10'; // 'all', '1-10', '11-20', '21-30', '31-40', '41-50', 'starred'
  int _multipliersCount = 12; // 10, 12 (standard), or 20
  bool _hideAnswers = false;
  bool _is3DFlashcardMode = false;
  final Set<int> _revealedIndices = {};

  // Audio / TTS Recital State
  final FlutterTts _flutterTts = FlutterTts();
  bool _isReciting = false;
  bool _isRecitalPaused = false;
  bool _isWaitingForQuizAnswer = false;
  int _currentlySpeakingMultiplier = -1;
  Timer? _recitalTimer;

  // 🎯 Level-Wise Table Practice State: 'current' (default: Table of _selectedTable), 'mix', 'range_1_10', 'range_11_20', 'range_21_50'
  String _drillLevel = 'current';
  QuizTimerDifficulty _drillTimerDifficulty = QuizTimerDifficulty.medium; // easy, medium, hard
  int _drillQuestionCount = 10; // 10, 20, 30
  Set<int> _mixSelectedTables = {}; // User-selected multi-table mixture (dynamic, no hardcoded defaults)

  @override
  void initState() {
    super.initState();
    _selectedTable = widget.initialTable;
    _updateRangeCategoryForTable(_selectedTable);
    _initTts();
    _loadSavedMixTables();
  }

  Future<void> _loadSavedMixTables() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('mix_selected_tables');
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() {
          _mixSelectedTables = saved
              .map((e) => int.tryParse(e) ?? 0)
              .where((e) => e >= 2 && e <= 50)
              .toSet();
        });
      }
    } catch (e) {
      debugPrint('Error loading saved mix tables: $e');
    }
  }

  Future<void> _saveMixTables(Set<int> tables) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('mix_selected_tables', tables.map((e) => e.toString()).toList());
    } catch (e) {
      debugPrint('Error saving mix tables: $e');
    }
  }

  void _updateRangeCategoryForTable(int t) {
    if (t <= 10) {
      _selectedRangeCategory = '1-10';
    } else if (t <= 20) {
      _selectedRangeCategory = '11-20';
    } else if (t <= 30) {
      _selectedRangeCategory = '21-30';
    } else if (t <= 40) {
      _selectedRangeCategory = '31-40';
    } else {
      _selectedRangeCategory = '41-50';
    }
  }

  Future<void> _initTts() async {
    try {
      final state = context.read<AppStateProvider>();
      try {
        await _flutterTts.awaitSpeakCompletion(true);
      } catch (_) {}
      await VoiceReciterHelper.applyTtsSettings(
        tts: _flutterTts,
        rate: state.ttsSpeechRate,
        pitch: state.ttsPitch,
        language: state.ttsLanguage,
      );
      _flutterTts.setCompletionHandler(() {
        if (_isReciting && !_isRecitalPaused && mounted) {
          final state = context.read<AppStateProvider>();
          if (state.ttsRecitalStyle != 'quiz') {
            _onLineCompleted();
          }
        }
      });
    } catch (e) {
      debugPrint('TTS setup: $e');
    }
  }

  Future<void> _syncTtsSettings() async {
    try {
      final state = context.read<AppStateProvider>();
      await VoiceReciterHelper.applyTtsSettings(
        tts: _flutterTts,
        rate: state.ttsSpeechRate,
        pitch: state.ttsPitch,
        language: state.ttsLanguage,
      );
      if (_isReciting && !_isRecitalPaused && mounted) {
        _speakCurrentMultiplier();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _recitalTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  void _stopRecital() {
    _recitalTimer?.cancel();
    _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isReciting = false;
        _isRecitalPaused = false;
        _isWaitingForQuizAnswer = false;
        _currentlySpeakingMultiplier = -1;
      });
    }
  }

  void _startRecital() {
    _recitalTimer?.cancel();
    _flutterTts.stop();
    setState(() {
      _isReciting = true;
      _isRecitalPaused = false;
      _currentlySpeakingMultiplier = 1;
    });
    _speakCurrentMultiplier();
  }

  void _togglePauseRecital() {
    if (!_isReciting) {
      _startRecital();
      return;
    }

    if (_isRecitalPaused) {
      setState(() => _isRecitalPaused = false);
      _speakCurrentMultiplier();
    } else {
      _recitalTimer?.cancel();
      _flutterTts.stop();
      setState(() => _isRecitalPaused = true);
    }
  }

  void _skipNext() {
    _recitalTimer?.cancel();
    _flutterTts.stop();
    if (_currentlySpeakingMultiplier < _multipliersCount) {
      setState(() {
        _currentlySpeakingMultiplier++;
        _isRecitalPaused = false;
        _isReciting = true;
      });
      _speakCurrentMultiplier();
    }
  }

  void _skipPrev() {
    _recitalTimer?.cancel();
    _flutterTts.stop();
    if (_currentlySpeakingMultiplier > 1) {
      setState(() {
        _currentlySpeakingMultiplier--;
        _isRecitalPaused = false;
        _isReciting = true;
      });
      _speakCurrentMultiplier();
    }
  }

  void _speakMultiplier(int mult) {
    _recitalTimer?.cancel();
    _flutterTts.stop();
    setState(() {
      _currentlySpeakingMultiplier = mult;
      _isReciting = true;
      _isRecitalPaused = false;
    });
    _speakCurrentMultiplier();
  }

  Future<void> _speakCurrentMultiplier() async {
    if (!_isReciting || _isRecitalPaused || !mounted) return;

    final state = context.read<AppStateProvider>();
    final style = state.ttsRecitalStyle;
    final int mult = _currentlySpeakingMultiplier;

    await VoiceReciterHelper.applyTtsSettings(
      tts: _flutterTts,
      rate: state.ttsSpeechRate,
      pitch: state.ttsPitch,
      language: state.ttsLanguage,
    );

    // Guard to ensure line advances exactly once per multiplier
    bool hasAdvancedThisLine = false;
    void advanceLineOnce() {
      if (!hasAdvancedThisLine && _isReciting && !_isRecitalPaused && mounted) {
        hasAdvancedThisLine = true;
        _recitalTimer?.cancel();
        _onLineCompleted();
      }
    }

    if (style == 'quiz') {
      // 1. Speak Question
      setState(() => _isWaitingForQuizAnswer = true);
      String qText = VoiceReciterHelper.getTableSpeechText(
        table: _selectedTable,
        mult: mult,
        style: style,
        isQuestionOnly: true,
      );
      try {
        await _flutterTts.speak(qText);
      } catch (_) {}

      // Pause for user thinking
      final pauseMs = (state.ttsQuizPauseSeconds * 1000).toInt().clamp(1000, 5000);
      _recitalTimer?.cancel();
      _recitalTimer = Timer(Duration(milliseconds: pauseMs), () async {
        if (!_isReciting || _isRecitalPaused || !mounted) return;
        setState(() => _isWaitingForQuizAnswer = false);

        // 2. Speak Answer
        String aText = VoiceReciterHelper.getTableSpeechText(
          table: _selectedTable,
          mult: mult,
          style: style,
          isQuestionOnly: false,
        );
        try {
          await _flutterTts.speak(aText);
        } catch (_) {}

        // Brief rhythmic delay before next line
        _recitalTimer = Timer(const Duration(milliseconds: 900), () {
          advanceLineOnce();
        });
      });
    } else {
      // Standard / School / Times / Vedic (Continuous Uninterrupted Recital)
      String textToSpeak = VoiceReciterHelper.getTableSpeechText(
        table: _selectedTable,
        mult: mult,
        style: style,
      );

      // Watchdog Timer: Ensures recital NEVER stops even if Android drops completion callback!
      final int wordCount = textToSpeak.split(' ').length;
      final int watchdogMs = ((wordCount / (state.ttsSpeechRate.clamp(0.2, 0.9) * 3.0)) * 1000).toInt().clamp(1600, 3200);

      _recitalTimer?.cancel();
      _recitalTimer = Timer(Duration(milliseconds: watchdogMs + 500), () {
        advanceLineOnce();
      });

      try {
        await _flutterTts.speak(textToSpeak);
        // With awaitSpeakCompletion(true), execution resumes right when audio completes
        if (!hasAdvancedThisLine && _isReciting && !_isRecitalPaused && mounted) {
          _recitalTimer?.cancel();
          // Natural breathing pause between table lines (550ms)
          _recitalTimer = Timer(const Duration(milliseconds: 550), () {
            advanceLineOnce();
          });
        }
      } catch (_) {
        advanceLineOnce();
      }
    }
  }

  void _onLineCompleted() {
    if (!_isReciting || _isRecitalPaused || !mounted) return;
    final state = context.read<AppStateProvider>();

    if (state.ttsRepeatMode == 'row') {
      // Repeat current row after a brief breath
      _recitalTimer = Timer(const Duration(milliseconds: 700), () {
        if (_isReciting && !_isRecitalPaused && mounted) {
          _speakCurrentMultiplier();
        }
      });
      return;
    }

    if (_currentlySpeakingMultiplier >= _multipliersCount) {
      if (state.ttsRepeatMode == 'table') {
        // Loop table from beginning
        setState(() => _currentlySpeakingMultiplier = 1);
        _speakCurrentMultiplier();
      } else {
        _stopRecital();
      }
      return;
    }

    // Advance to next multiplier
    setState(() => _currentlySpeakingMultiplier++);
    _speakCurrentMultiplier();
  }

  List<int> _getFilteredTables(Set<int> starredTables) {
    switch (_selectedRangeCategory) {
      case '1-10':
        return List.generate(10, (i) => i + 1);
      case '11-20':
        return List.generate(10, (i) => i + 11);
      case '21-30':
        return List.generate(10, (i) => i + 21);
      case '31-40':
        return List.generate(10, (i) => i + 31);
      case '41-50':
        return List.generate(10, (i) => i + 41);
      case 'starred':
        final list = starredTables.toList()..sort();
        return list;
      case 'all':
      default:
        return List.generate(50, (i) => i + 1);
    }
  }

  void _startTableDrill() {
    _stopRecital();
    final state = context.read<AppStateProvider>();
    if (state.isGuestLimitReached) {
      Navigator.push(
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

    List<QuestionModel> questions = _generateDrillQuestions();
    String topicTitle;
    String topicSubtitle;
    String topicId;

    switch (_drillLevel) {
      case 'easy':
      case 'range_1_10':
        topicTitle = 'All Tables 1–10 Range Drill';
        topicSubtitle = 'Foundation Tables 2–10 • Multipliers up to $_multipliersCount';
        topicId = 'tables_all_1_10';
        break;
      case 'medium':
      case 'range_11_20':
        topicTitle = 'All Tables 11–20 Range Drill';
        topicSubtitle = 'Competitive Exam Core • Multipliers up to $_multipliersCount';
        topicId = 'tables_all_11_20';
        break;
      case 'hard':
      case 'range_21_50':
        topicTitle = 'All Tables 21–50 Range Drill';
        topicSubtitle = 'Advanced Mastery • Multipliers up to $_multipliersCount';
        topicId = 'tables_all_21_50';
        break;
      case 'mix':
        if (_mixSelectedTables.length < 2) {
          _showMixTableSelectionModal();
          return;
        }
        final sortedTables = _mixSelectedTables.toList()..sort();
        topicTitle = 'Mix Drill: Tables ${sortedTables.join(', ')}';
        topicSubtitle = '${sortedTables.length} Mixed Tables • Random Speed Recall (Up to ×$_multipliersCount)';
        topicId = 'tables_mix_${sortedTables.join('_')}';
        break;
      case 'current':
      default:
        topicTitle = 'Table $_selectedTable Speed Drill (1 to $_multipliersCount)';
        topicSubtitle = 'Targeted Table $_selectedTable Mastery • Multipliers up to $_multipliersCount';
        topicId = 'table_$_selectedTable';
        break;
    }

    final double? perQuestionSeconds = switch (_drillTimerDifficulty) {
      QuizTimerDifficulty.easy => null,
      QuizTimerDifficulty.medium => 10.0,
      QuizTimerDifficulty.hard => 5.0,
    };
    final bool isTimed = _drillTimerDifficulty != QuizTimerDifficulty.easy;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: topicId,
            title: topicTitle,
            subtitle: topicSubtitle,
            type: TopicType.tables,
            iconName: 'grid_view_rounded',
          ),
          customQuestions: questions,
          onRegenerateQuestions: _generateDrillQuestions,
          isTimed: isTimed,
          perQuestionSeconds: perQuestionSeconds,
          questionCount: questions.length,
          initialUseNumpad: _drillTimerDifficulty == QuizTimerDifficulty.hard,
        ),
      ),
    );
  }

  List<QuestionModel> _generateDrillQuestions() {
    // Multiplier ceiling strictly respects student's selection (e.g. 10, 12, or 20)
    // independent of the number of drill questions selected (e.g. 30, 50 questions).
    final int effectiveMultipliers = _multipliersCount;

    switch (_drillLevel) {
      case 'easy':
      case 'range_1_10':
        return DynamicQuestionEngine.generateTableRangeQuestions(
          startTable: 2,
          endTable: 10,
          count: _drillQuestionCount,
          maxMultiplier: effectiveMultipliers,
        );
      case 'medium':
      case 'range_11_20':
        return DynamicQuestionEngine.generateTableRangeQuestions(
          startTable: 11,
          endTable: 20,
          count: _drillQuestionCount,
          maxMultiplier: effectiveMultipliers,
        );
      case 'hard':
      case 'range_21_50':
        return DynamicQuestionEngine.generateTableRangeQuestions(
          startTable: 21,
          endTable: 50,
          count: _drillQuestionCount,
          maxMultiplier: effectiveMultipliers,
        );
      case 'mix':
        final sortedTables = _mixSelectedTables.toList()..sort();
        return DynamicQuestionEngine.generateMultiTableQuestions(
          tables: sortedTables,
          count: _drillQuestionCount,
          maxMultiplier: effectiveMultipliers,
        );
      case 'current':
      default:
        return DynamicQuestionEngine.generateTableQuestions(
          _selectedTable,
          count: _drillQuestionCount,
          maxMultiplier: effectiveMultipliers,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isStarred = state.isTableStarred(_selectedTable);
    final filteredTables = _getFilteredTables(state.starredTables);

    Widget content = Column(
      children: [
        // 1. Range Categories Selector (Tabs)
        _buildRangeCategorySelector(state.starredTables.length),

        if (_selectedRangeCategory == 'multiply') ...[
          Expanded(child: _buildEmbeddedMultiplicationHub(state)),
        ] else ...[
        // 2. Table Pills Strip (1 to 50)
        _buildTableSelectorStrip(filteredTables, state),

        if (_selectedRangeCategory == 'starred' && state.starredTables.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_outline_rounded, size: 48, color: AppTheme.gold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Starred Tables Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select any table from 1 to 50 and tap the ⭐ Star icon to receive automatic 30-minute revision alerts!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          // 3. Active Table Hero Header & Controls Bar
          _buildActiveTableHeader(isStarred, state),

          // 4. Interactive Toolbar: Range Toggle (10 vs 20), Flashcard (Hide/Show), Recite (TTS)
          _buildInteractiveToolbar(),

          // 5. Table Rows List or 3D Flip Cards Grid
          Expanded(
            child: _is3DFlashcardMode ? _build3DFlipGrid() : _buildTableRowsList(),
          ),



          // 6. Sticky Test Myself Action Bar
          _buildBottomTestBar(),
        ],
        ],
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Tables & Multiply Hub',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: isStarred ? AppTheme.gold : Colors.white70,
            ),
            tooltip: 'Star Table',
            onPressed: () => state.toggleStarTable(_selectedTable),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildRangeCategorySelector(int starredCount) {
    final categories = [
      {'id': '1-10', 'label': '1 – 10 (Basics)', 'icon': Icons.school_rounded, 'color': AppTheme.cyan},
      {'id': '11-20', 'label': '11 – 20 (Core)', 'icon': Icons.local_fire_department_rounded, 'color': AppTheme.gold},
      {'id': '21-30', 'label': '21 – 30 (Advanced)', 'icon': Icons.bolt_rounded, 'color': AppTheme.accent},
      {'id': '31-40', 'label': '31 – 40 (Pro)', 'icon': Icons.trending_up_rounded, 'color': AppTheme.primaryLight},
      {'id': '41-50', 'label': '41 – 50 (Master)', 'icon': Icons.workspace_premium_rounded, 'color': AppTheme.purple},
      {'id': 'multiply', 'label': '✖️ Multiply (1D–4D)', 'icon': Icons.close_rounded, 'color': const Color(0xFFEF4444)},
      {'id': 'starred', 'label': '⭐ Starred ($starredCount)', 'icon': Icons.star_rounded, 'color': AppTheme.gold},
      {'id': 'all', 'label': 'All 1 – 50', 'icon': Icons.grid_view_rounded, 'color': Colors.white70},
    ];

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final isSelected = _selectedRangeCategory == cat['id'];
          final color = cat['color'] as Color;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRangeCategory = cat['id'] as String;
                _stopRecital();
                final available = _getFilteredTables(context.read<AppStateProvider>().starredTables);
                if (!available.contains(_selectedTable) && available.isNotEmpty) {
                  _selectedTable = available.first;
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLight.withValues(alpha: 0.18) : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(cat['icon'] as IconData, size: 15, color: isSelected ? AppTheme.primaryLight : color),
                  const SizedBox(width: 5),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
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

  Widget _buildTableSelectorStrip(List<int> tables, AppStateProvider state) {
    if (tables.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Text('No starred tables yet. Star any table to practice it here!',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      );
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tables.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                int t = tables[idx];
                bool isSelected = t == _selectedTable;
                bool isTableStarred = state.isTableStarred(t);

                return GestureDetector(
                  onTap: () {
                    final prevSelected = _selectedTable;
                    _stopRecital();
                    setState(() {
                      _selectedTable = t;
                      _revealedIndices.clear();
                    });
                    final randomMult = 2 + Random().nextInt(_multipliersCount > 2 ? _multipliersCount - 1 : 8);
                    context.read<AppStateProvider>().trackTopicBrowsed(
                          topicId: 'table_$t',
                          title: 'Table of $t',
                          detail: '$t × $randomMult',
                        );

                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppTheme.primaryLight, AppTheme.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryLight.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$t',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                            ),
                            Text(
                              'Table',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        if (isTableStarred)
                          const Positioned(
                            top: 3,
                            right: 3,
                            child: Icon(
                              Icons.star_rounded,
                              size: 11,
                              color: AppTheme.gold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedRangeCategory == 'starred' && tables.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Clear All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                onPressed: () {
                  state.clearAllStarredTables();
                  setState(() {
                    _selectedRangeCategory = '1-10';
                    _selectedTable = 2;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveTableHeader(bool isStarred, AppStateProvider state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  ),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.calculate_rounded, color: AppTheme.primaryLight, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Table of $_selectedTable',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        if (isStarred)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, color: AppTheme.gold, size: 11),
                                SizedBox(width: 2),
                                Text('STARRED', style: TextStyle(color: AppTheme.gold, fontSize: 8.5, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Table of $_selectedTable • Up to × $_multipliersCount',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isStarred ? AppTheme.gold : Colors.white54,
                  size: 24,
                ),
                tooltip: isStarred ? 'Starred Table' : 'Bookmark Table',
                onPressed: () => state.toggleStarTable(_selectedTable),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildEmbeddedMultiplicationHub(AppStateProvider state) {
    final digitModes = [
      {'digits': 1, 'title': '1-Digit × 1-Digit', 'sub': '7 × 8 = 56 • Reflex recall', 'color': const Color(0xFF10B981)},
      {'digits': 2, 'title': '2-Digit × 2-Digit', 'sub': '24 × 16 = 384 • Cross multiply', 'color': const Color(0xFF38BDF8)},
      {'digits': 3, 'title': '3-Digit × Multi', 'sub': '125 × 14 = 1750 • Speed chunks', 'color': const Color(0xFFF59E0B)},
      {'digits': 4, 'title': '4-Digit Master', 'sub': '1250 × 8 = 10000 • Exam pro', 'color': const Color(0xFFEF4444)},
    ];

    void launchDigits(int digits, String title) {
      if (state.isGuestLimitReached) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthScreen(initialIsLogin: false, isMandatory: true),
          ),
        );
        return;
      }
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.hardMultiplier,
        digits: digits,
        count: _drillQuestionCount,
      );
      final double? perQuestionSeconds = switch (_drillTimerDifficulty) {
        QuizTimerDifficulty.easy => null,
        QuizTimerDifficulty.medium => 10.0,
        QuizTimerDifficulty.hard => 5.0,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeQuizScreen(
            topic: TopicModel(
              id: 'multiply_${digits}d',
              title: 'Speed Multiply ($title)',
              subtitle: '$digits-Digit Multiplication Speed Drill',
              type: TopicType.hardMultiplier,
              iconName: 'flash_on_rounded',
            ),
            customQuestions: questions,
            onRegenerateQuestions: () => DynamicQuestionEngine.generateDigitSpecificQuestions(
              type: TopicType.hardMultiplier,
              digits: digits,
              count: _drillQuestionCount,
            ),
            isTimed: _drillTimerDifficulty != QuizTimerDifficulty.easy,
            perQuestionSeconds: perQuestionSeconds,
            questionCount: _drillQuestionCount,
            initialUseNumpad: _drillTimerDifficulty == QuizTimerDifficulty.hard,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flash_on_rounded, color: AppTheme.gold, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speed Multiplication (1D–4D)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Integrated inside Tables & Multiply hub • Choose digit tier or custom ceiling.',
                      style: TextStyle(color: Colors.white70, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('Pace:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(width: 6),
              _buildPaceChip(QuizTimerDifficulty.easy, 'Easy (No Timer)', const Color(0xFF10B981)),
              const SizedBox(width: 5),
              _buildPaceChip(QuizTimerDifficulty.medium, 'Med (10s)', const Color(0xFFF59E0B)),
              const SizedBox(width: 5),
              _buildPaceChip(QuizTimerDifficulty.hard, 'Hard (5s Numpad)', const Color(0xFFEF4444)),
              const SizedBox(width: 10),
              _buildCountChip(10),
              const SizedBox(width: 5),
              _buildCountChip(20),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...digitModes.map((m) {
          final color = m['color'] as Color;
          final int d = m['digits'] as int;
          final String title = m['title'] as String;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: ListTile(
              onTap: () => launchDigits(d, title),
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.18),
                child: Text('${d}D', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
              ),
              title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(m['sub'] as String, style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => launchDigits(d, title),
                child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('Custom Limit (Ceiling) & Full Options'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ArithmeticDigitSelectionScreen(type: TopicType.hardMultiplier),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInteractiveToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.8)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 🔊 Manual Read / Listen Table Button
            _toolbarChip(
              label: _isReciting ? '⏹️ Stop' : '🔊 Read Table',
              isActive: _isReciting,
              onTap: () {
                if (_isReciting) {
                  _stopRecital();
                } else {
                  _startRecital();
                }
              },
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 18, color: AppTheme.surfaceLight),
            const SizedBox(width: 8),

            // Range Switch (×10 vs ×12 vs ×20)
            _toolbarChip(
              label: '1 to 10',
              isActive: _multipliersCount == 10,
              onTap: () {
                _stopRecital();
                setState(() => _multipliersCount = 10);
              },
            ),
            const SizedBox(width: 6),
            _toolbarChip(
              label: '1 to 12 (Std)',
              isActive: _multipliersCount == 12,
              onTap: () {
                _stopRecital();
                setState(() => _multipliersCount = 12);
              },
            ),
            const SizedBox(width: 6),
            _toolbarChip(
              label: '1 to 20',
              isActive: _multipliersCount == 20,
              onTap: () {
                _stopRecital();
                setState(() => _multipliersCount = 20);
              },
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 18, color: AppTheme.surfaceLight),
            const SizedBox(width: 8),

            // View Mode Toggle (List vs 3D Cards)
            _toolbarChip(
              label: _is3DFlashcardMode ? '🎴 3D Cards' : '📋 List View',
              isActive: true,
              onTap: () {
                _stopRecital();
                setState(() => _is3DFlashcardMode = !_is3DFlashcardMode);
              },
            ),
            const SizedBox(width: 8),

            // Flashcard / Hide Answers Toggle (When in List mode)
            if (!_is3DFlashcardMode) ...[
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _hideAnswers = !_hideAnswers;
                    _revealedIndices.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _hideAnswers ? AppTheme.warning.withValues(alpha: 0.15) : AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _hideAnswers ? AppTheme.warning.withValues(alpha: 0.4) : AppTheme.surfaceLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _hideAnswers ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 14,
                        color: _hideAnswers ? AppTheme.warning : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _hideAnswers ? 'Self-Test (Hidden)' : 'Peek Mode',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _hideAnswers ? AppTheme.warning : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],


          ],
        ),
      ),
    );
  }

  Widget _toolbarChip({required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppTheme.primaryLight : AppTheme.surfaceLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRowsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _multipliersCount,
      itemBuilder: (context, index) {
        int mult = index + 1;
        int result = _selectedTable * mult;
        bool isSpoken = _isReciting && _currentlySpeakingMultiplier == mult;
        bool isRevealed = !_hideAnswers || _revealedIndices.contains(mult);

        // Mental trick breakdown hint (e.g. 17 × 8 = 10×8 + 7×8 = 80 + 56 = 136)
        String? decomposition;
        if (_selectedTable > 10) {
          int tens = (_selectedTable ~/ 10) * 10;
          int units = _selectedTable % 10;
          if (units > 0) {
            decomposition = '($tens×$mult + $units×$mult = ${tens * mult} + ${units * mult})';
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: isSpoken
                ? (_isWaitingForQuizAnswer
                    ? Colors.amber.withValues(alpha: 0.18)
                    : AppTheme.primaryLight.withValues(alpha: 0.18))
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSpoken
                  ? (_isWaitingForQuizAnswer ? Colors.amberAccent : AppTheme.primaryLight)
                  : AppTheme.surfaceLight.withValues(alpha: 0.6),
              width: isSpoken ? 1.8 : 1,
            ),
            boxShadow: isSpoken
                ? [
                    BoxShadow(
                      color: (_isWaitingForQuizAnswer ? Colors.amber : AppTheme.primaryLight)
                          .withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (_hideAnswers) {
                  setState(() {
                    if (_revealedIndices.contains(mult)) {
                      _revealedIndices.remove(mult);
                    } else {
                      _revealedIndices.add(mult);
                    }
                  });
                } else {
                  _speakMultiplier(mult);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    // Expression
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$_selectedTable',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                '  ×  ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$mult',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isSpoken)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _isWaitingForQuizAnswer
                                        ? Colors.amber.shade800
                                        : AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isWaitingForQuizAnswer
                                            ? Icons.psychology_rounded
                                            : Icons.volume_up_rounded,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        _isWaitingForQuizAnswer ? 'THINK...' : 'RECITE',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (isRevealed && decomposition != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              decomposition,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Answer or Reveal Pill
                    if (isRevealed)
                      Text(
                        (isSpoken && _isWaitingForQuizAnswer) ? '=  ? 🤔' : '=  $result',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: (isSpoken && _isWaitingForQuizAnswer)
                              ? Colors.amberAccent
                              : AppTheme.accent,
                          letterSpacing: -0.5,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _revealedIndices.add(mult);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.warning.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app_rounded, color: AppTheme.warning, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Tap to Reveal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.warning,
                                ),
                              ),
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

Widget _buildFloatingAudioPlayerDeck(AppStateProvider state) {
    if (!_isReciting) return const SizedBox.shrink();

    final currentStyleData = VoiceReciterHelper.recitalStyles.firstWhere(
      (s) => s['id'] == state.ttsRecitalStyle,
      orElse: () => VoiceReciterHelper.recitalStyles.first,
    );

    IconData repeatIcon = Icons.repeat_rounded;
    Color repeatColor = AppTheme.textMuted;
    String repeatTooltip = 'Loop: Off';
    if (state.ttsRepeatMode == 'table') {
      repeatIcon = Icons.repeat_rounded;
      repeatColor = AppTheme.accent;
      repeatTooltip = 'Loop Table (Infinite)';
    } else if (state.ttsRepeatMode == 'row') {
      repeatIcon = Icons.repeat_one_rounded;
      repeatColor = AppTheme.gold;
      repeatTooltip = 'Loop Current Row';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRecitalPaused
              ? Colors.amber.withValues(alpha: 0.6)
              : AppTheme.accent.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isRecitalPaused ? Colors.amber : AppTheme.accent)
                .withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Mini Info Row: Playing info + Style Pill + Voice Studio trigger
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecitalPaused ? Colors.amber : AppTheme.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isWaitingForQuizAnswer
                      ? '🧠 Think answer... (${state.ttsQuizPauseSeconds.toStringAsFixed(1)}s)'
                      : (_isRecitalPaused
                          ? 'Audio Paused (Row $_currentlySpeakingMultiplier/$_multipliersCount)'
                          : 'Reciting: $_selectedTable × $_currentlySpeakingMultiplier = ${_selectedTable * _currentlySpeakingMultiplier}'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _isRecitalPaused ? Colors.amber : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => VoiceStudioModal.show(context, onSettingsChanged: _syncTtsSettings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currentStyleData['title'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _stopRecital,
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.close_rounded, size: 18, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom Controls Row: Speed, Prev, Play/Pause, Next, Loop, Studio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Speed cycle pill
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final speeds = [0.35, 0.45, 0.55, 0.65];
                  int currIdx = speeds.indexOf(state.ttsSpeechRate);
                  if (currIdx == -1) currIdx = 1;
                  double nextSpeed = speeds[(currIdx + 1) % speeds.length];
                  state.updateTtsSpeechRate(nextSpeed);
                  _syncTtsSettings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bgDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.surfaceLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.speed_rounded, size: 13, color: AppTheme.cyan),
                      const SizedBox(width: 3),
                      Text(
                        '${state.ttsSpeechRate.toStringAsFixed(2)}x',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 22,
                color: _currentlySpeakingMultiplier > 1 ? Colors.white : Colors.white24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Previous Row',
                onPressed: _currentlySpeakingMultiplier > 1 ? _skipPrev : null,
              ),

              GestureDetector(
                onTap: _togglePauseRecital,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isRecitalPaused
                          ? [Colors.amber.shade600, Colors.amber.shade800]
                          : [AppTheme.accent, AppTheme.primaryLight],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecitalPaused ? Colors.amber : AppTheme.accent)
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecitalPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 22,
                color: _currentlySpeakingMultiplier < _multipliersCount ? Colors.white : Colors.white24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Next Row',
                onPressed: _currentlySpeakingMultiplier < _multipliersCount ? _skipNext : null,
              ),

              IconButton(
                icon: Icon(repeatIcon),
                iconSize: 20,
                color: repeatColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: repeatTooltip,
                onPressed: () {
                  String nextMode = 'none';
                  if (state.ttsRepeatMode == 'none') {
                    nextMode = 'table';
                  } else if (state.ttsRepeatMode == 'table') {
                    nextMode = 'row';
                  } else {
                    nextMode = 'none';
                  }
                  state.updateTtsRepeatMode(nextMode);
                },
              ),

              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => VoiceStudioModal.show(context, onSettingsChanged: _syncTtsSettings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 13, color: AppTheme.accent),
                      SizedBox(width: 3),
                      Text(
                        'Studio',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3DFlipGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _multipliersCount,
      itemBuilder: (context, index) {
        int mult = index + 1;
        String? decomposition;
        if (_selectedTable > 10) {
          int tens = (_selectedTable ~/ 10) * 10;
          int units = _selectedTable % 10;
          if (units > 0) {
            decomposition = '$tens×$mult + $units×$mult = ${tens * mult + units * mult}';
          }
        }

        return _Table3DFlipCard(
          key: ValueKey('flip_${_selectedTable}_$mult'),
          table: _selectedTable,
          multiplier: mult,
          decomposition: decomposition,
        );
      },
    );
  }

  Widget _buildBottomTestBar() {
    String levelButtonLabel;
    Color levelColor;
    switch (_drillLevel) {
      case 'easy':
      case 'range_1_10':
        levelButtonLabel = 'All Tables 1–10 (1 to $_multipliersCount)';
        levelColor = const Color(0xFF10B981);
        break;
      case 'medium':
      case 'range_11_20':
        levelButtonLabel = 'All Tables 11–20 (1 to $_multipliersCount)';
        levelColor = const Color(0xFFF59E0B);
        break;
      case 'hard':
      case 'range_21_50':
        levelButtonLabel = 'All Tables 21–50 (1 to $_multipliersCount)';
        levelColor = const Color(0xFFEF4444);
        break;
      case 'mix':
        levelButtonLabel = _mixSelectedTables.length < 2
            ? 'Pick Mix Tables'
            : 'Mix (${_mixSelectedTables.length} Tables • 1 to $_multipliersCount)';
        levelColor = const Color(0xFFA855F7);
        break;
      case 'current':
      default:
        levelButtonLabel = 'Table $_selectedTable (1 to $_multipliersCount)';
        levelColor = AppTheme.cyan;
        break;
    }

    String paceLabel = _drillTimerDifficulty == QuizTimerDifficulty.easy
        ? 'No Timer'
        : (_drillTimerDifficulty == QuizTimerDifficulty.medium ? '10s' : '5s Blitz');

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101625),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppTheme.surfaceLight.withValues(alpha: 0.8), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Target Scope Tabs (Table $_selectedTable Only first and default!)
          Row(
            children: [
              const Text(
                'Target:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLevelTab('current', '🎯 Table $_selectedTable Only', AppTheme.cyan),
                      const SizedBox(width: 6),
                      _buildLevelTab(
                        'mix',
                        _mixSelectedTables.length < 2
                            ? '🔀 Mix Tables'
                            : '🔀 Mix (${_mixSelectedTables.length} Tables)',
                        const Color(0xFFA855F7),
                      ),
                      const SizedBox(width: 6),
                      _buildLevelTab('range_1_10', '📚 All Tables (1–10)', const Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      _buildLevelTab('range_11_20', '📚 All Tables (11–20)', const Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      _buildLevelTab('range_21_50', '📚 All Tables (21–50)', const Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Mix Selected Strip (visible when Mix level is chosen)
          if (_drillLevel == 'mix') ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shuffle_rounded, size: 14, color: Color(0xFFA855F7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _mixSelectedTables.length < 2
                          ? 'Select 2 or more tables to practice together'
                          : 'Practicing Mix: Tables ${(_mixSelectedTables.toList()..sort()).join(', ')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _mixSelectedTables.length < 2 ? Colors.amberAccent : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showMixTableSelectionModal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tune_rounded, size: 13, color: Color(0xFFA855F7)),
                          const SizedBox(width: 3),
                          Text(
                            _mixSelectedTables.length < 2 ? 'Select Tables' : 'Change Tables',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA855F7),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),

          // Row 2: Multipliers (1-10, 1-12, 1-20) + Pace + Count
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Mults:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(width: 5),
                _buildMultiplierChip(10, '1–10'),
                const SizedBox(width: 4),
                _buildMultiplierChip(12, '1–12 (Std)'),
                const SizedBox(width: 4),
                _buildMultiplierChip(20, '1–20'),
                const SizedBox(width: 10),
                Container(width: 1, height: 16, color: Colors.white24),
                const SizedBox(width: 10),
                const Text(
                  'Pace:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(width: 6),
                _buildPaceChip(QuizTimerDifficulty.easy, 'Easy (No Timer)', const Color(0xFF10B981)),
                const SizedBox(width: 5),
                _buildPaceChip(QuizTimerDifficulty.medium, 'Med (10s)', const Color(0xFFF59E0B)),
                const SizedBox(width: 5),
                _buildPaceChip(QuizTimerDifficulty.hard, 'Hard (5s)', const Color(0xFFEF4444)),
                const SizedBox(width: 10),
                Container(width: 1, height: 16, color: Colors.white24),
                const SizedBox(width: 10),
                const Text(
                  'Count:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(width: 6),
                _buildCountChip(10),
                const SizedBox(width: 5),
                _buildCountChip(20),
                const SizedBox(width: 5),
                _buildCountChip(30),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Row 3: Action Button & Schedule Icon
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: levelColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.bolt_rounded, color: Colors.white),
                  label: Text(
                    'Start $levelButtonLabel • $_drillQuestionCount Qs ($paceLabel)',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: _startTableDrill,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMixTableSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        Set<int> tempSelected = _mixSelectedTables.isNotEmpty
            ? Set<int>.from(_mixSelectedTables)
            : (_selectedTable >= 2 ? {_selectedTable} : <int>{});
        return StatefulBuilder(
          builder: (context, setModalState) {
            final state = context.read<AppStateProvider>();
            final starred = state.starredTables;

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF141927),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shuffle_rounded, color: Color(0xFFA855F7), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Multi-Table Mix Practice',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Pick 2 or more tables to practice together',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Selection Helpers (No hardcoded tables)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Dynamic Chip 1: Current table shortcut
                        _mixPresetChip(
                          label: tempSelected.contains(_selectedTable)
                              ? '✓ Table $_selectedTable'
                              : '+ Table $_selectedTable',
                          onTap: () {
                            setModalState(() {
                              if (tempSelected.contains(_selectedTable)) {
                                tempSelected.remove(_selectedTable);
                              } else {
                                tempSelected.add(_selectedTable);
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        // Dynamic Chip 2: User's real starred tables
                        if (starred.length >= 2) ...[
                          _mixPresetChip(
                            label: '⭐ Starred (${starred.length})',
                            onTap: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll(starred);
                              });
                            },
                          ),
                          const SizedBox(width: 6),
                        ],
                        // Dynamic Chip 3: Random 2 Tables generated on-the-fly
                        _mixPresetChip(
                          label: '🎲 Random 2 Tables',
                          onTap: () {
                            final rng = Random();
                            final pool = List.generate(29, (i) => i + 2)..shuffle(rng);
                            setModalState(() {
                              tempSelected.clear();
                              tempSelected.addAll(pool.take(2));
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        // Dynamic Chip 4: Random 3 Tables generated on-the-fly
                        _mixPresetChip(
                          label: '🎲 Random 3 Tables',
                          onTap: () {
                            final rng = Random();
                            final pool = List.generate(29, (i) => i + 2)..shuffle(rng);
                            setModalState(() {
                              tempSelected.clear();
                              tempSelected.addAll(pool.take(3));
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        // Dynamic Chip 5: Clear Selection
                        if (tempSelected.isNotEmpty) ...[
                          _mixPresetChip(
                            label: 'Clear (${tempSelected.length})',
                            isDanger: true,
                            onTap: () {
                              setModalState(() {
                                tempSelected.clear();
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid of tables 2 to 50
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: 49,
                      itemBuilder: (context, index) {
                        int tableNum = index + 2;
                        bool isPicked = tempSelected.contains(tableNum);
                        bool isStar = starred.contains(tableNum);

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isPicked) {
                                tempSelected.remove(tableNum);
                              } else {
                                tempSelected.add(tableNum);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isPicked
                                  ? const Color(0xFFA855F7)
                                  : AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isPicked
                                    ? const Color(0xFFC084FC)
                                    : (isStar ? AppTheme.gold.withValues(alpha: 0.5) : AppTheme.surfaceLight),
                                width: isPicked ? 1.5 : 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '$tableNum',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isPicked ? FontWeight.bold : FontWeight.w600,
                                    color: isPicked ? Colors.white : Colors.white70,
                                  ),
                                ),
                                if (isStar)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 10,
                                      color: isPicked ? Colors.white : AppTheme.gold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom action row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tempSelected.length < 2
                              ? 'Select at least 2 tables (Picked: ${tempSelected.length})'
                              : 'Selected: ${(tempSelected.toList()..sort()).join(', ')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: tempSelected.length < 2 ? Colors.amberAccent : Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA855F7),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: tempSelected.length < 2
                            ? null
                            : () {
                                final newMix = Set<int>.from(tempSelected);
                                setState(() {
                                  _mixSelectedTables = newMix;
                                  _drillLevel = 'mix';
                                });
                                _saveMixTables(newMix);
                                Navigator.pop(sheetContext);
                              },
                        child: const Text(
                          'Apply Mix',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _mixPresetChip({required String label, required VoidCallback onTap, bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDanger
              ? Colors.redAccent.withValues(alpha: 0.15)
              : AppTheme.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDanger ? Colors.redAccent.withValues(alpha: 0.4) : AppTheme.surfaceLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDanger ? Colors.redAccent : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelTab(String levelKey, String label, Color color) {
    final bool isSelected = _drillLevel == levelKey;
    return InkWell(
      onTap: () {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        if (levelKey == 'mix') {
          if (_mixSelectedTables.length < 2) {
            _showMixTableSelectionModal();
          } else if (_drillLevel == 'mix') {
            _showMixTableSelectionModal();
          } else {
            setState(() => _drillLevel = 'mix');
          }
        } else {
          setState(() => _drillLevel = levelKey);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? color : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildPaceChip(QuizTimerDifficulty diff, String label, Color color) {
    final bool isSelected = _drillTimerDifficulty == diff;
    return InkWell(
      onTap: () {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        setState(() => _drillTimerDifficulty = diff);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplierChip(int count, String label) {
    final bool isSelected = _multipliersCount == count;
    return InkWell(
      onTap: () {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        _stopRecital();
        setState(() => _multipliersCount = count);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cyan.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.cyan : Colors.white12,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.cyan : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildCountChip(int count) {
    final bool isSelected = _drillQuestionCount == count;
    return InkWell(
      onTap: () {
        setState(() => _drillQuestionCount = count);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : Colors.white12,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          '$count Qs',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

class _Table3DFlipCard extends StatefulWidget {
  final int table;
  final int multiplier;
  final String? decomposition;

  const _Table3DFlipCard({
    super.key,
    required this.table,
    required this.multiplier,
    this.decomposition,
  });

  @override
  State<_Table3DFlipCard> createState() => _Table3DFlipCardState();
}

class _Table3DFlipCardState extends State<_Table3DFlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
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

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int result = widget.table * widget.multiplier;

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
            onTap: _flipCard,
            child: isUnder
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(result),
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
          color: const Color(0xFF6366F1).withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${widget.multiplier}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
                ),
              ),
              const Icon(Icons.flip_camera_android_rounded, size: 14, color: Colors.white38),
            ],
          ),
          const Spacer(),
          Text(
            '${widget.table} × ${widget.multiplier}',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, size: 11, color: AppTheme.accent),
                SizedBox(width: 4),
                Text(
                  'Tap to Flip',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(int result) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF064E3B)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'REVEALED',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                ),
              ),
              const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
            ],
          ),
          const Spacer(),
          Text(
            '= $result',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF34D399)),
          ),
          if (widget.decomposition != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.decomposition!,
              style: const TextStyle(fontSize: 9.5, color: Colors.white70, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          const Text(
            'Tap to flip back',
            style: TextStyle(fontSize: 9, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
