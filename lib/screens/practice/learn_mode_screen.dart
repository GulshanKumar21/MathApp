import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../data/content_repository.dart';
import '../../data/dynamic_question_engine.dart';
import '../../providers/app_state_provider.dart';
import 'practice_quiz_screen.dart';
import '../revision/table_revision_hub_screen.dart';
import '../revision/powers_revision_hub_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../auth/auth_screen.dart';
import '../../widgets/interactive_triangle_visualizer.dart';
import '../../services/voice_reciter_helper.dart';
import '../../widgets/voice_studio_modal.dart';

class LearnModeScreen extends StatefulWidget {
  final TopicModel topic;

  const LearnModeScreen({super.key, required this.topic});

  @override
  State<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends State<LearnModeScreen> {
  int _selectedTable = 2; // For Tables: 1 to 50
  List<int> _selectedTriple = [3, 4, 5];
  final FlutterTts _flutterTts = FlutterTts();
  bool _isVoiceReciting = false;
  int _activeVoiceIndex = -1;
  String _activeVoiceType = ''; // 'fraction' or 'triple'

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppStateProvider>().trackTopicBrowsed(
          topicId: widget.topic.id,
          title: widget.topic.title,
          detail: 'Can you solve 10 ${widget.topic.title} questions quickly?',
        );
      }
    });
  }

  void _stopVoiceRecital() {
    _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isVoiceReciting = false;
        _activeVoiceIndex = -1;
        _activeVoiceType = '';
      });
    }
  }

  Future<void> _speakFraction(Map<String, String> item, {int? index}) async {
    _flutterTts.stop();
    setState(() {
      _activeVoiceType = 'fraction';
      _activeVoiceIndex = index ?? -1;
    });

    final state = context.read<AppStateProvider>();
    await VoiceReciterHelper.applyTtsSettings(
      tts: _flutterTts,
      rate: state.ttsSpeechRate,
      pitch: state.ttsPitch,
      language: state.ttsLanguage,
    );

    String speech = VoiceReciterHelper.getFractionSpeechText(
      fraction: item['fraction']!,
      percentage: item['percent']!,
      decimal: item['decimal']!,
      style: state.ttsRecitalStyle,
    );
    await _flutterTts.speak(speech);
  }

  Future<void> _toggleFractionContinuousRecital() async {
    if (_isVoiceReciting && _activeVoiceType == 'fraction') {
      _stopVoiceRecital();
      return;
    }
    setState(() {
      _isVoiceReciting = true;
      _activeVoiceType = 'fraction';
      _activeVoiceIndex = 0;
    });
    _playNextFractionRecital();
  }

  Future<void> _playNextFractionRecital() async {
    if (!_isVoiceReciting || !mounted || _activeVoiceType != 'fraction') return;
    if (_activeVoiceIndex >= ContentRepository.fractionData.length) {
      _stopVoiceRecital();
      return;
    }

    final item = ContentRepository.fractionData[_activeVoiceIndex];
    await _speakFraction(item, index: _activeVoiceIndex);

    _flutterTts.setCompletionHandler(() {
      if (_isVoiceReciting && mounted && _activeVoiceType == 'fraction') {
        Future.delayed(const Duration(milliseconds: 650), () {
          if (_isVoiceReciting && mounted && _activeVoiceType == 'fraction') {
            setState(() => _activeVoiceIndex++);
            _playNextFractionRecital();
          }
        });
      }
    });
  }

  Future<void> _speakTriple(List<int> t, {int? index}) async {
    _flutterTts.stop();
    setState(() {
      _activeVoiceType = 'triple';
      _activeVoiceIndex = index ?? -1;
      _selectedTriple = [t[0], t[1], t[2]];
    });

    final state = context.read<AppStateProvider>();
    await VoiceReciterHelper.applyTtsSettings(
      tts: _flutterTts,
      rate: state.ttsSpeechRate,
      pitch: state.ttsPitch,
      language: state.ttsLanguage,
    );

    String speech = VoiceReciterHelper.getTripleSpeechText(
      a: t[0],
      b: t[1],
      c: t[2],
      style: state.ttsRecitalStyle,
    );
    await _flutterTts.speak(speech);
  }

  Future<void> _toggleTripleContinuousRecital() async {
    if (_isVoiceReciting && _activeVoiceType == 'triple') {
      _stopVoiceRecital();
      return;
    }
    setState(() {
      _isVoiceReciting = true;
      _activeVoiceType = 'triple';
      _activeVoiceIndex = 0;
    });
    _playNextTripleRecital();
  }

  Future<void> _playNextTripleRecital() async {
    if (!_isVoiceReciting || !mounted || _activeVoiceType != 'triple') return;
    if (_activeVoiceIndex >= ContentRepository.pythagoreanTriples.length) {
      _stopVoiceRecital();
      return;
    }

    final t = ContentRepository.pythagoreanTriples[_activeVoiceIndex];
    await _speakTriple(t, index: _activeVoiceIndex);

    _flutterTts.setCompletionHandler(() {
      if (_isVoiceReciting && mounted && _activeVoiceType == 'triple') {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (_isVoiceReciting && mounted && _activeVoiceType == 'triple') {
            setState(() => _activeVoiceIndex++);
            _playNextTripleRecital();
          }
        });
      }
    });
  }

  Future<void> _speakTableRow(int table, int mult) async {
    _flutterTts.stop();
    setState(() {
      _activeVoiceType = 'table';
      _activeVoiceIndex = mult;
    });

    final state = context.read<AppStateProvider>();
    await VoiceReciterHelper.applyTtsSettings(
      tts: _flutterTts,
      rate: state.ttsSpeechRate,
      pitch: state.ttsPitch,
      language: state.ttsLanguage,
    );

    String speech = VoiceReciterHelper.getTableSpeechText(
      table: table,
      mult: mult,
      style: state.ttsRecitalStyle,
    );
    await _flutterTts.speak(speech);
  }

  Future<void> _toggleTableContinuousRecital() async {
    if (_isVoiceReciting && _activeVoiceType == 'table') {
      _stopVoiceRecital();
      return;
    }
    setState(() {
      _isVoiceReciting = true;
      _activeVoiceType = 'table';
      _activeVoiceIndex = 1;
    });
    _playNextTableRecital();
  }

  Future<void> _playNextTableRecital() async {
    if (!_isVoiceReciting || !mounted || _activeVoiceType != 'table') return;
    if (_activeVoiceIndex > 20) {
      _stopVoiceRecital();
      return;
    }

    final mult = _activeVoiceIndex;
    await _speakTableRow(_selectedTable, mult);

    _flutterTts.setCompletionHandler(() {
      if (_isVoiceReciting && mounted && _activeVoiceType == 'table') {
        Future.delayed(const Duration(milliseconds: 650), () {
          if (_isVoiceReciting && mounted && _activeVoiceType == 'table') {
            setState(() => _activeVoiceIndex++);
            _playNextTableRecital();
          }
        });
      }
    });
  }

  void _startTableQuiz(int tableNum) {
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

    final questions = DynamicQuestionEngine.generateTableQuestions(tableNum, count: 10);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'table_$tableNum',
            title: 'Table of $tableNum Drill',
            subtitle: 'Targeted quiz for Table $tableNum',
            type: TopicType.tables,
            iconName: 'grid_view_rounded',
          ),
          customQuestions: questions,
          isTimed: true,
          questionCount: questions.length,
        ),
      ),
    );
  }

  void _scheduleForTomorrow() {
    final state = context.read<AppStateProvider>();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);

    String topicId = widget.topic.type == TopicType.tables ? 'table_$_selectedTable' : widget.topic.id;
    String topicTitle = widget.topic.type == TopicType.tables ? 'Table of $_selectedTable' : widget.topic.title;
    String sampleQ;
    if (widget.topic.type == TopicType.tables) {
      final mult = 3 + (DateTime.now().second % 7);
      sampleQ = '$_selectedTable × $mult = ?';
    } else {
      final sampleList = ContentRepository.generateQuestions(widget.topic.type, count: 1);
      sampleQ = sampleList.isNotEmpty ? '${sampleList.first.prompt} = ?' : '⚡ Speed Target Drill';
    }

    state.setStudyPlan(
      topicId: topicId,
      topicTitle: topicTitle,
      targetTime: scheduledTime,
      sampleQuestion: sampleQ,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text('✅ $topicTitle scheduled for tomorrow at 9:00 AM! Reminders active.'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic.title} - Learn Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_add_rounded, color: AppTheme.accent),
            tooltip: 'Schedule for Tomorrow',
            onPressed: _scheduleForTomorrow,
          ),
          TextButton.icon(
            onPressed: () {
              if (widget.topic.type == TopicType.tables) {
                _startTableQuiz(_selectedTable);
              } else {
                _startGenericQuiz();
              }
            },
            icon: const Icon(Icons.bolt_rounded, color: AppTheme.gold),
            label: Text(
              widget.topic.type == TopicType.tables
                  ? 'Test Table $_selectedTable'
                  : 'Test Drill',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  void _startGenericQuiz() {
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

    final questions = ContentRepository.generateQuestions(widget.topic.type, count: 15);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: widget.topic,
          customQuestions: questions,
          isTimed: true,
          questionCount: questions.length,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (widget.topic.type) {
      case TopicType.tables:
        return _buildTablesView();
      case TopicType.addition:
        return _buildAdditionView();
      case TopicType.subtraction:
        return _buildSubtractionView();
      case TopicType.division:
        return _buildDivisionView();
      case TopicType.squares:
        return _buildSquaresView();
      case TopicType.cubes:
        return _buildCubesView();
      case TopicType.fractions:
        return _buildFractionsView();
      case TopicType.triples:
        return _buildTriplesView();
      case TopicType.hardMultiplier:
        return _buildHardMultiplierView();
      default:
        return _buildGenericTopicView(widget.topic);
    }
  }

  // --- 1. TABLES (1 to 50) ---
  Widget _buildTablesView() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TableRevisionHubScreen(initialTable: _selectedTable)),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Open 1–50 Table Revision Hub (Self-Test & Spaced Drills)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              int num = index + 1;
              bool isSelected = num == _selectedTable;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTable = num);
                  context.read<AppStateProvider>().trackTopicBrowsed(
                    topicId: 'table_$num',
                    title: 'Table of $num',
                    detail: 'Quick test: What is $num × 3?',
                  );
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight,
                    ),
                  ),
                  child: Text(
                    '$num',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: AppTheme.surfaceLight, height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 21, // 1 explanation card + 20 multiplier items
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildTableExplanationCard(_selectedTable);
              }
              int mult = index;
              int res = _selectedTable * mult;
              final bool isSpeaking = _isVoiceReciting && _activeVoiceType == 'table' && _activeVoiceIndex == mult;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _speakTableRow(_selectedTable, mult),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSpeaking
                          ? const Color(0xFF6366F1).withValues(alpha: 0.22)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSpeaking
                            ? const Color(0xFF818CF8)
                            : AppTheme.surfaceLight.withValues(alpha: 0.4),
                        width: isSpeaking ? 1.8 : 1.0,
                      ),
                      boxShadow: isSpeaking
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isSpeaking) ...[
                              const Icon(Icons.volume_up_rounded, color: Color(0xFF818CF8), size: 18),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '$_selectedTable  ×  $mult',
                              style: TextStyle(
                                fontSize: 18,
                                color: isSpeaking ? Colors.white : Colors.white70,
                                fontWeight: isSpeaking ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '=  $res',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSpeaking ? const Color(0xFF818CF8) : AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.surfaceLight.withValues(alpha: 0.5))),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.bolt_rounded, color: AppTheme.gold),
                label: Text(
                  'Test Table $_selectedTable Quiz (10 Qs)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () => _startTableQuiz(_selectedTable),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. SQUARES (1 to 50) ---
  Widget _buildSquaresView() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PowersRevisionHubScreen(isCubes: false)),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB45309), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB45309).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.crop_square_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Open 5-Part Squares Hub (1–10 to 41–50)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 51, // 1 explanation card + 50 squares
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildSquaresExplanationCard();
              }
              int n = index;
              int sq = n * n;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$n', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
                        ),
                        const SizedBox(width: 14),
                        Text('$n²', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    Text(
                      '$sq',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 3. CUBES (1 to 30) ---
  Widget _buildCubesView() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PowersRevisionHubScreen(isCubes: true)),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B21A8).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Open 5-Part Cubes Hub (1–6 to 25–30)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 31, // 1 explanation card + 30 cubes
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCubesExplanationCard();
              }
              int n = index;
              int cube = n * n * n;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$n', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryLight)),
                        ),
                        const SizedBox(width: 14),
                        Text('$n³', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    Text(
                      '$cube',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 4. FRACTIONS TO PERCENTAGES & DECIMALS ---
  Widget _buildFractionsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ContentRepository.fractionData.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFractionsExplanationCard();
        }
        var item = ContentRepository.fractionData[index - 1];
        final bool isSpeaking = _activeVoiceType == 'fraction' && _activeVoiceIndex == (index - 1);
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _speakFraction(item, index: index - 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSpeaking
                  ? const Color(0xFFEC4899).withValues(alpha: 0.18)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSpeaking
                    ? const Color(0xFFEC4899)
                    : AppTheme.surfaceLight.withValues(alpha: 0.4),
                width: isSpeaking ? 1.8 : 1.0,
              ),
              boxShadow: isSpeaking
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                      color: isSpeaking ? const Color(0xFFEC4899) : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item['fraction']!,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['percent']!,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accent),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '≈ ${item['decimal']}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 5. PYTHAGOREAN TRIPLES ---
  Widget _buildTriplesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ContentRepository.pythagoreanTriples.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return InteractiveTriangleVisualizer(
            initialTriple: _selectedTriple,
            themeColor: const Color(0xFF8B5CF6),
          );
        }
        if (index == 1) {
          return _buildTriplesExplanationCard();
        }
        var t = ContentRepository.pythagoreanTriples[index - 2];
        final bool isSelected = _selectedTriple[0] == t[0] &&
            _selectedTriple[1] == t[1] &&
            _selectedTriple[2] == t[2];
        final bool isSpeaking = _activeVoiceType == 'triple' && _activeVoiceIndex == (index - 2);

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTriple = [t[0], t[1], t[2]];
            });
            _speakTriple(t, index: index - 2);
            try {
              HapticFeedback.lightImpact();
            } catch (_) {}
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSpeaking || isSelected
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.18)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSpeaking || isSelected
                    ? const Color(0xFF8B5CF6)
                    : AppTheme.surfaceLight.withValues(alpha: 0.4),
                width: isSpeaking || isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSpeaking || isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSpeaking
                          ? Icons.volume_up_rounded
                          : (isSelected ? Icons.brush_rounded : Icons.change_history_rounded),
                      color: isSpeaking || isSelected ? const Color(0xFF8B5CF6) : AppTheme.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '(${t[0]},  ${t[1]},  ${t[2]})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${t[0]}² + ${t[1]}² = ${t[2]}²',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF8B5CF6) : Colors.white54,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_upward_rounded, color: Color(0xFF8B5CF6), size: 16),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 💡 DEEP MENTAL MATH EXPLANATION CARDS ---

  Widget _bulletExplanation(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.gold)),
          const SizedBox(height: 3),
          Text(detail, style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTableExplanationCard(int n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppTheme.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                '💡 Mental Math Secrets for Table of $n',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 🎙️ Voice Coach Hands-free Audio Recital Controls (Shifted to Learn Mode)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_isVoiceReciting && _activeVoiceType == 'table')
                  ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                  : AppTheme.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isVoiceReciting && _activeVoiceType == 'table')
                    ? const Color(0xFF6366F1)
                    : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isVoiceReciting && _activeVoiceType == 'table')
                          ? AppTheme.error
                          : const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _toggleTableContinuousRecital,
                    icon: Icon(
                      (_isVoiceReciting && _activeVoiceType == 'table')
                          ? Icons.stop_rounded
                          : Icons.record_voice_over_rounded,
                      size: 18,
                    ),
                    label: Text(
                      (_isVoiceReciting && _activeVoiceType == 'table')
                          ? 'Stop Recital (Speaking $n × $_activeVoiceIndex)'
                          : '🎙️ Listen Full Table of $n (Continuous Voice)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Voice Studio Settings (Accent, Speed, Style)',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.tune_rounded, color: AppTheme.accent, size: 20),
                  onPressed: () => VoiceStudioModal.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _bulletExplanation(
            '⚡ Split & Add (Vedic Partitioning):',
            'Break multiplier into (10 - 1) or (5 + 2) to solve instantly:\n• $n × 7 = ($n × 5) + ($n × 2) = ${n * 5} + ${n * 2} = ${n * 7}\n• $n × 9 = ($n × 10) - $n = ${n * 10} - $n = ${n * 9}',
          ),
          _bulletExplanation(
            '⚡ Doubling Rule (For ×4 & ×8):',
            'Never multiply by 4 or 8 directly. Simply double the number:\n• $n × 4: Double once = ${n * 2}, double again = ${n * 4}\n• $n × 8: Double 3 times: $n ➔ ${n * 2} ➔ ${n * 4} ➔ ${n * 8}',
          ),
          _bulletExplanation(
            '⚡ Repeating Unit-Digit Cycle:',
            'Units digit pattern: ${List.generate(10, (i) => (n * (i + 1)) % 10).join(' ➔ ')}',
          ),
        ],
      ),
    );
  }

  Widget _buildSquaresExplanationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                '💡 4 Vedic Mental Squaring Hacks (1–2s Solves)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bulletExplanation(
            '1. Numbers Ending in 5 (n5²):',
            'Formula: n × (n + 1) | 25\n• 35²: 3 × 4 = 12 ➔ 1225\n• 65²: 6 × 7 = 42 ➔ 4225\n• 85²: 8 × 9 = 72 ➔ 7225',
          ),
          _bulletExplanation(
            '2. Base 50 Trick (41² to 59²):',
            'Formula: (50 ± d)² = (25 ± d) | d²\n• 48²: d = -2 ➔ (25 - 2) | 2² = 23 | 04 ➔ 2304\n• 54²: d = +4 ➔ (25 + 4) | 4² = 29 | 16 ➔ 2916\n• 43²: d = -7 ➔ (25 - 7) | 7² = 18 | 49 ➔ 1849',
          ),
          _bulletExplanation(
            '3. Base 100 Trick (91² to 109²):',
            'Formula: (100 ± d)² = (100 ± 2d) | d²\n• 96²: d = -4 ➔ (96 - 4) | 4² = 92 | 16 ➔ 9216\n• 104²: d = +4 ➔ (104 + 4) | 4² = 108 | 16 ➔ 10816',
          ),
          _bulletExplanation(
            '4. Universal Duplex Method (ab²):',
            'Formula: a² | 2ab | b² with digit carry-overs.\n• 23²: 2² | 2(2)(3) | 3² = 4 | 12 | 9 = 529',
          ),
        ],
      ),
    );
  }

  Widget _buildCubesExplanationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text(
                '💡 Cube Laws & 3-Second Mental Cube Root Hack',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _bulletExplanation(
            '1. Invariant Unit Digits (Never Change):',
            'Numbers ending in 0, 1, 4, 5, 6, 9 keep their EXACT same unit digit when cubed!\n• 4³ = 64 (ends in 4) | 5³ = 125 (ends in 5) | 6³ = 216 (ends in 6) | 9³ = 729 (ends in 9)',
          ),
          _bulletExplanation(
            '2. Complementary Unit Pairs (Sum = 10):',
            'Only 2 swaps with 8, and 3 swaps with 7:\n• 2³ = 8 ➔ 8³ = 512 (ends in 2)\n• 3³ = 27 (ends in 7) ➔ 7³ = 343 (ends in 3)',
          ),
          _bulletExplanation(
            '3. Instant Cube Root of Any 6-Digit Number:',
            'Example: ∛175616\n• Step 1: Unit digit is 6 ➔ Cube root last digit MUST be 6.\n• Step 2: Strike off last 3 digits (616), remaining is 175.\n• Step 3: Since 5³ (125) < 175 < 6³ (216), tens digit is 5.\n➔ Result = 56! (Mentally solved in 2 seconds)',
          ),
        ],
      ),
    );
  }

  Widget _buildFractionsExplanationCard() {
    final bool isReciting = _isVoiceReciting && _activeVoiceType == 'fraction';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pie_chart_outline_rounded, color: Color(0xFFEC4899), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '💡 Exam Percentage Hacks & Cyclic Patterns',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 🎙️ Voice Coach Hands-free Audio Recital Controls
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isReciting
                  ? const Color(0xFFEC4899).withValues(alpha: 0.15)
                  : AppTheme.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isReciting
                    ? const Color(0xFFEC4899)
                    : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReciting ? AppTheme.error : const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _toggleFractionContinuousRecital,
                    icon: Icon(isReciting ? Icons.stop_rounded : Icons.record_voice_over_rounded, size: 18),
                    label: Text(
                      isReciting ? 'Stop Voice Recital' : '🎙️ Listen All (Hands-Free)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Voice Studio Settings',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.tune_rounded, color: AppTheme.accent, size: 20),
                  onPressed: () => VoiceStudioModal.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _bulletExplanation(
            '1. The Magic 142857 Cycle of 7:',
            'The sequence 1-4-2-8-5-7 rotates continuously for all sevenths:\n• 1/7 = 14.29%\n• 2/7 = 28.57%\n• 3/7 = 42.85%\n• 4/7 = 57.14%\n• 5/7 = 71.42%\n• 6/7 = 85.71%',
          ),
          _bulletExplanation(
            '2. The 9 and 11 Cross-Reciprocal Family:',
            '• Denominator 9 produces multiples of 11: 1/9 = 11.11%, 2/9 = 22.22%, 4/9 = 44.44%\n• Denominator 11 produces multiples of 9: 1/11 = 09.09%, 2/11 = 18.18%, 3/11 = 27.27%',
          ),
          _bulletExplanation(
            '3. High-Yield Eighths (8ths):',
            '• 1/8 = 12.5% | 3/8 = 37.5% | 5/8 = 62.5% | 7/8 = 87.5%',
          ),
        ],
      ),
    );
  }

  Widget _buildTriplesExplanationCard() {
    final bool isReciting = _isVoiceReciting && _activeVoiceType == 'triple';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Title Banner
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.change_history_rounded, color: Color(0xFFA78BFA), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ALWAYS REMEMBER : PYTHAGOREAN TRIPLET',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Base Families • Scaling Multipliers • Special Angles • Formulas',
                      style: TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 🎙️ Voice Coach Hands-free Audio Recital Controls
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isReciting
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                  : AppTheme.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isReciting
                    ? const Color(0xFF8B5CF6)
                    : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReciting ? AppTheme.error : const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _toggleTripleContinuousRecital,
                    icon: Icon(isReciting ? Icons.stop_rounded : Icons.record_voice_over_rounded, size: 18),
                    label: Text(
                      isReciting ? 'Stop Voice Recital' : '🎙️ Listen All Triples',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Voice Studio Settings',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.tune_rounded, color: AppTheme.accent, size: 20),
                  onPressed: () => VoiceStudioModal.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- 1. CORE FAMILIES WITH MULTIPLIER TREES ---
          _buildPosterSectionHeader('🌿 Core Families & Multipliers Tree', const Color(0xFFF43F5E)),
          const SizedBox(height: 10),

          // Family 1: (3, 4, 5)
          _buildFamilyMultiplierCard(
            familyTitle: '(3, 4, 5) Family',
            accentColor: const Color(0xFFF43F5E),
            multipliers: [
              {'mult': '× 1/2', 'res': '(1.5, 2, 2.5)', 'triple': null},
              {'mult': '× 2', 'res': '(6, 8, 10)', 'triple': [6, 8, 10]},
              {'mult': '× 3', 'res': '(9, 12, 15)', 'triple': [9, 12, 15]},
              {'mult': '× 4', 'res': '(12, 16, 20)', 'triple': [12, 16, 20]},
              {'mult': '× 5', 'res': '(15, 20, 25)', 'triple': [15, 20, 25]},
              {'mult': '× √2', 'res': '(3√2, 4√2, 5√2)', 'triple': null},
            ],
          ),
          const SizedBox(height: 10),

          // Family 2: (5, 12, 13)
          _buildFamilyMultiplierCard(
            familyTitle: '(5, 12, 13) Family',
            accentColor: const Color(0xFF6366F1),
            multipliers: [
              {'mult': '× 2', 'res': '(10, 24, 26)', 'triple': [10, 24, 26]},
              {'mult': '× 3', 'res': '(15, 36, 39)', 'triple': [15, 36, 39]},
            ],
          ),
          const SizedBox(height: 10),

          // Family 3: (7, 24, 25)
          _buildFamilyMultiplierCard(
            familyTitle: '(7, 24, 25) Family',
            accentColor: const Color(0xFF10B981),
            multipliers: [
              {'mult': '× 1/2', 'res': '(3.5, 12, 12.5)', 'triple': null},
              {'mult': '× 2', 'res': '(14, 48, 50)', 'triple': [14, 48, 50]},
              {'mult': '× 3', 'res': '(21, 72, 75)', 'triple': [21, 72, 75]},
            ],
          ),
          const SizedBox(height: 16),

          // --- 2. SPECIAL RIGHT ANGLED TRIANGLES ---
          _buildPosterSectionHeader('📐 Special Right Angle Triangles', const Color(0xFFF59E0B)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSpecialAngleCard(
                  title: '45° - 45° - 90°',
                  ratio: '1 : 1 : √2',
                  subtitle: 'Isosceles Right Δ',
                  accentColor: const Color(0xFFF59E0B),
                  description: 'Base = Perp (1)\nHypotenuse = √2',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSpecialAngleCard(
                  title: '30° - 60° - 90°',
                  ratio: '1 : √3 : 2',
                  subtitle: 'Half Equilateral Δ',
                  accentColor: const Color(0xFF38BDF8),
                  description: 'Opp 30° = 1\nOpp 60° = √3\nHypotenuse = 2',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- 3. EXAM ESSENTIAL STANDARD TRIPLETS ---
          _buildPosterSectionHeader('⚡ Right Angle Triangles Standard Triplets', const Color(0xFFA855F7)),
          const SizedBox(height: 8),
          const Text(
            'High-frequency exam primitives (tap any to inspect on visualizer):',
            style: TextStyle(fontSize: 11, color: Colors.white60),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              [9, 40, 41],
              [11, 60, 61],
              [12, 35, 37],
              [13, 84, 85],
              [16, 63, 65],
              [20, 21, 29],
              [28, 45, 53],
              [33, 56, 65],
              [36, 77, 85],
              [39, 80, 89],
              [48, 55, 73],
              [65, 72, 97],
              [20, 99, 101],
            ].map((t) {
              final bool isCurrent = _selectedTriple[0] == t[0] &&
                  _selectedTriple[1] == t[1] &&
                  _selectedTriple[2] == t[2];
              return InkWell(
                onTap: () {
                  _speakTriple(t);
                  try {
                    HapticFeedback.lightImpact();
                  } catch (_) {}
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFA78BFA)
                          : Colors.white12,
                      width: isCurrent ? 1.5 : 1.0,
                    ),
                  ),
                  child: Text(
                    '${t[0]}, ${t[1]}, ${t[2]}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? const Color(0xFFA78BFA) : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // --- 4. GENERATOR FORMULAS ---
          _buildPosterSectionHeader('⚙️ Triplet Generator Formulas', const Color(0xFF06B6D4)),
          const SizedBox(height: 10),
          _buildFormulaCard(
            title: 'Even Base Formula',
            formula: '(2n, n² - 1, n² + 1)',
            example: 'n = 4 ➔ 8, 15, 17  •  n = 6 ➔ 12, 35, 37',
            accentColor: const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 8),
          _buildFormulaCard(
            title: 'Odd Base Formula',
            formula: '(n, (n² - 1)/2, (n² + 1)/2)',
            example: 'n = 3 ➔ 3, 4, 5  •  n = 5 ➔ 5, 12, 13  •  n = 7 ➔ 7, 24, 25',
            accentColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 8),
          _buildFormulaCard(
            title: "Euclid's Universal Identity",
            formula: '(2ab, a² - b², a² + b²)',
            example: 'For any integers a > b > 0  (e.g., a=2, b=1 ➔ 4, 3, 5)',
            accentColor: const Color(0xFFEC4899),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterSectionHeader(String title, Color accent) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 14,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: accent,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyMultiplierCard({
    required String familyTitle,
    required Color accentColor,
    required List<Map<String, dynamic>> multipliers,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.28),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  familyTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Multiplier Tree',
                  style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: multipliers.map((m) {
              final String mult = m['mult'] as String;
              final String res = m['res'] as String;
              final List<int>? triple = m['triple'] as List<int>?;

              final bool isSelected = triple != null &&
                  _selectedTriple[0] == triple[0] &&
                  _selectedTriple[1] == triple[1] &&
                  _selectedTriple[2] == triple[2];

              return InkWell(
                onTap: () {
                  if (triple != null) {
                    _speakTriple(triple);
                  } else {
                    _flutterTts.speak('$familyTitle scaled by $mult gives $res');
                  }
                  try {
                    HapticFeedback.lightImpact();
                  } catch (_) {}
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.35)
                        : AppTheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : accentColor.withValues(alpha: 0.25),
                      width: isSelected ? 1.4 : 0.9,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          mult,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '➔ $res',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialAngleCard({
    required String title,
    required String ratio,
    required String subtitle,
    required Color accentColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: accentColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ratio,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Colors.white54, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard({
    required String title,
    required String formula,
    required String example,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.functions_rounded, color: accentColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white),
                    ),
                    Text(
                      formula,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: accentColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  example,
                  style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    // --- 6. ⚡ HARD-ON PRO MULTIPLIERS (Viral Maths Vedic Edition) ---
  Widget _buildHardMultiplierView() {
    // 1. Full 10 to 100 Consecutive Multiplication dataset categorized into 4 tiers
    final consecutiveTier1 = [
      {'q': '10 × 11', 'a': '110', 'trick': '10² + 10 = 100 + 10'},
      {'q': '11 × 12', 'a': '132', 'trick': '11² + 11 = 121 + 11'},
      {'q': '12 × 13', 'a': '156', 'trick': '12² + 12 = 144 + 12'},
      {'q': '13 × 14', 'a': '182', 'trick': '13² + 13 = 169 + 13'},
      {'q': '14 × 15', 'a': '210', 'trick': 'Half-Double: 7 × 30'},
      {'q': '15 × 16', 'a': '240', 'trick': 'Half-Double: 30 × 8'},
      {'q': '16 × 17', 'a': '272', 'trick': '16² + 16 = 256 + 16'},
      {'q': '17 × 18', 'a': '306', 'trick': '17² + 17 = 289 + 17'},
      {'q': '18 × 19', 'a': '342', 'trick': '18² + 18 = 324 + 18'},
      {'q': '19 × 20', 'a': '380', 'trick': '20² - 20 = 400 - 20'},
      {'q': '20 × 21', 'a': '420', 'trick': '20² + 20 = 400 + 20'},
      {'q': '21 × 22', 'a': '462', 'trick': '21² + 21 = 441 + 21'},
      {'q': '22 × 23', 'a': '506', 'trick': '22² + 22 = 484 + 22'},
      {'q': '23 × 24', 'a': '552', 'trick': '23² + 23 = 529 + 23'},
      {'q': '24 × 25', 'a': '600', 'trick': '24 × (100 ÷ 4) = 600'},
      {'q': '25 × 26', 'a': '650', 'trick': '25² + 25 = 625 + 25'},
    ];

    final consecutiveTier2 = [
      {'q': '29 × 30', 'a': '870', 'trick': '30² - 30 = 900 - 30'},
      {'q': '34 × 35', 'a': '1190', 'trick': 'Half-Double: 17 × 70'},
      {'q': '35 × 36', 'a': '1260', 'trick': '35² + 35 = 1225 + 35'},
      {'q': '39 × 40', 'a': '1560', 'trick': '40² - 40 = 1600 - 40'},
      {'q': '44 × 45', 'a': '1980', 'trick': 'Half-Double: 22 × 90'},
      {'q': '45 × 46', 'a': '2070', 'trick': 'Half-Double: 90 × 23'},
      {'q': '49 × 50', 'a': '2450', 'trick': '50² - 50 = 2500 - 50'},
      {'q': '50 × 51', 'a': '2550', 'trick': '50² + 50 = 2500 + 50'},
    ];

    final consecutiveTier3 = [
      {'q': '54 × 55', 'a': '2970', 'trick': 'Half-Double: 27 × 110'},
      {'q': '59 × 60', 'a': '3540', 'trick': '60² - 60 = 3600 - 60'},
      {'q': '64 × 65', 'a': '4160', 'trick': 'Half-Double: 32 × 130'},
      {'q': '65 × 66', 'a': '4290', 'trick': '65² + 65 = 4225 + 65'},
      {'q': '69 × 70', 'a': '4830', 'trick': '70² - 70 = 4900 - 70'},
      {'q': '74 × 75', 'a': '5550', 'trick': 'Half-Double: 37 × 150'},
    ];

    final consecutiveTier4 = [
      {'q': '79 × 80', 'a': '6320', 'trick': '80² - 80 = 6400 - 80'},
      {'q': '84 × 85', 'a': '7140', 'trick': 'Half-Double: 42 × 170'},
      {'q': '89 × 90', 'a': '8010', 'trick': '90² - 90 = 8100 - 90'},
      {'q': '94 × 95', 'a': '8930', 'trick': 'Half-Double: 47 × 190'},
      {'q': '95 × 96', 'a': '9120', 'trick': '95² + 95 = 9025 + 95'},
      {'q': '98 × 99', 'a': '9702', 'trick': 'Base 100: (-2) × (-1)'},
      {'q': '99 × 100', 'a': '9900', 'trick': '100² - 100 = 9900'},
    ];

    // 2. Worked Examples across Page 8, 9 & 10 Viral Maths Rules
    final workedExamples = [
      {
        'q': '17 × 18 = ?',
        'ans': '306',
        'trick': '⚡ Consecutive Multiplication: n × (n + 1)',
        'formula': 'n² + n (Smaller Square + Smaller Number)',
        'steps': '1. Smallest number is 17\n2. 17² = 289\n3. 289 + 17 = 306'
      },
      {
        'q': '24 × 26 = ?',
        'ans': '624',
        'trick': '⚡ Alternate Consecutive Numbers (Gap of 2)',
        'formula': '(N - 1)(N + 1) = N² - 1',
        'steps': '1. Midpoint of 24 and 26 is 25\n2. 25² - 1² = 625 - 1 = 624'
      },
      {
        'q': '65 × 75 = ?',
        'ans': '4875',
        'trick': '⚡ Diff of 10 Ending in 5 (Viral Maths Rule)',
        'formula': '(Higher Tens Digit)² - 1 | 75',
        'steps': '1. Last 2 digits are ALWAYS 75\n2. Higher tens digit is 7 ➔ 7² - 1 = 48\n3. Combine: 4875'
      },
      {
        'q': '16 × 125 = ?',
        'ans': '2000',
        'trick': '⚡ Powers of 5 Multiplier (× 125)',
        'formula': '(N ÷ 8) × 1000',
        'steps': '1. Divide 16 by 8 = 2\n2. Multiply 2 by 1000 = 2000'
      },
      {
        'q': '24 × 25 = ?',
        'ans': '600',
        'trick': '⚡ Magical 25 Multiplier (× 25)',
        'formula': '(N ÷ 4) × 100',
        'steps': '1. Divide 24 by 4 = 6\n2. Multiply 6 by 100 = 600'
      },
      {
        'q': '64 × 66 = ?',
        'ans': '4224',
        'trick': '⚡ Ekadhikena Purvena (Same tens, units sum = 10)',
        'formula': 'A(A + 1) | B × C',
        'steps': '1. Tens part: 6 × (6 + 1) = 6 × 7 = 42\n2. Units part: 4 × 6 = 24\n3. Combine: 4224'
      },
      {
        'q': '43 × 11 = ?',
        'ans': '473',
        'trick': '⚡ 11-Sandwich Rapid Ripple Add',
        'formula': 'Freeze outer digits, sum in middle: A | (A + B) | B',
        'steps': '1. Outer digits are 4 and 3\n2. Middle digit: 4 + 3 = 7\n3. Combine: 473'
      },
      {
        'q': '96 × 94 = ?',
        'ans': '9024',
        'trick': '⚡ Vedic Base 100 Deficiencies',
        'formula': '(A - d2) | (d1 × d2)',
        'steps': '1. 96 is (-4), 94 is (-6) from 100\n2. Left part: 96 - 6 = 90\n3. Right part: (-4) × (-6) = 24\n4. Combine: 9024'
      },
      {
        'q': '14 × 15 = ?',
        'ans': '210',
        'trick': '⚡ Half & Double Shortcut',
        'formula': '(Even ÷ 2) × (Unit 5 × 2)',
        'steps': '1. Half of 14 = 7\n2. Double of 15 = 30\n3. 7 × 30 = 210'
      },
    ];

    Widget buildConsecutiveCard(Map<String, String> it) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(it['q']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5)),
                Text('= ${it['a']}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accent, fontSize: 13.5)),
              ],
            ),
            const SizedBox(height: 2),
            Text(it['trick']!, style: const TextStyle(color: Colors.white54, fontSize: 10.5), overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '⚡ Speed Multipliers (Viral Maths Vedic Edition)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15.5),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Consecutive Multiplications (10×11 to 99×100), Midpoint Squaring, Unit-5 Diff 10 & Powers of 5 shortcuts without pen & paper!',
                style: TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Consecutive Multiplications (10 to 100) Section
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.format_list_numbered_rounded, color: AppTheme.accent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '🔢 Consecutive Multiplications Table (10 to 100)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('💡 3 Super-Fast Shortcuts for Consecutive Products:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gold, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('• Rule 1: n × (n + 1) = n² + n  (Chhote number ka square + wahi number)', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    Text('• Rule 2: Half & Double for Unit 5  (e.g., 14 × 15 = 7 × 30 = 210)', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    Text('• Rule 3: (n + 1)² - (n + 1) near Tens  (e.g., 49 × 50 = 2500 - 50 = 2450)', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Tier 1: 10 to 25 (Super high frequency)
              const Text('🌟 Tier 1: Foundation (10 to 25) - High Frequency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: consecutiveTier1.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) => buildConsecutiveCard(consecutiveTier1[idx]),
              ),
              const SizedBox(height: 14),

              // Tier 2: 26 to 50
              const Text('🚀 Tier 2: Moderate (26 to 50) - Base 50 & 5-Endings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: consecutiveTier2.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) => buildConsecutiveCard(consecutiveTier2[idx]),
              ),
              const SizedBox(height: 14),

              // Tier 3: 51 to 75
              const Text('⚡ Tier 3: Upper Mid (51 to 75)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: consecutiveTier3.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) => buildConsecutiveCard(consecutiveTier3[idx]),
              ),
              const SizedBox(height: 14),

              // Tier 4: 76 to 100
              const Text('👑 Tier 4: Mastery (76 to 100) - Base 100 Deficiencies', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: consecutiveTier4.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, idx) => buildConsecutiveCard(consecutiveTier4[idx]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Page 8, 9 & 10 Worked Shortcuts
        const Text(
          'Top Vedic Mental Shortcuts & Worked Drills',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...workedExamples.map((ex) => _buildMethodCard(ex)),
        const SizedBox(height: 12),

        // 4. Practice Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
          label: const Text('Practice 15 Speed Multiplier Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PracticeQuizScreen(
                  topic: widget.topic,
                  isTimed: true,
                  questionCount: 15,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- 7. ➕ SPEED ADDITION MASTERY (Viral Maths Vedic Edition) ---
  Widget _buildAdditionView() {
    final workedExamples = [
      {
        'q': '68 + 57 = ?',
        'ans': '125',
        'trick': '➕ Split & Merge (Left-to-Right Method)',
        'formula': '(Tens + Tens) + (Units + Units)',
        'steps': '''1. Add tens first: 60 + 50 = 110
2. Add units: 8 + 7 = 15
3. Combine mentally: 110 + 15 = 125'''
      },
      {
        'q': '89 + 46 = ?',
        'ans': '135',
        'trick': '➕ Friend Number Rule (शून्यकरण / Base-10 Rounding)',
        'formula': 'Round to 10/100, compensate from second term',
        'steps': '''1. Round 89 to 90 (+1)
2. Compensate from 46: 46 - 1 = 45
3. Instant solve: 90 + 45 = 135'''
      },
      {
        'q': '28 + 72 + 34 + 66 = ?',
        'ans': '200',
        'trick': '➕ Complementary 100s Pairing (जोड़ी बनाओ विधि)',
        'formula': 'Identify pairs that sum to 100',
        'steps': '''1. Pair (28 + 72) = 100
2. Pair (34 + 66) = 100
3. Total: 100 + 100 = 200 in 2 seconds!'''
      },
      {
        'q': '41 + 42 + 43 + ... + 50 = ?',
        'ans': '455',
        'trick': '➕ 10 Consecutive Numbers Sum Shortcut',
        'formula': '5th Number + append 5',
        'steps': '''1. Identify the 5th number in the sequence: 45
2. Append digit 5 at the end: 45 ➔ 455
3. Instant result: 455 without adding individually!'''
      },
      {
        'q': '4.7 + 0.38 = ?',
        'ans': '5.08',
        'trick': '➕ Decimal Equalizer Balancing',
        'formula': 'Equalize decimal digits mentally: 4.70 + 0.38',
        'steps': '''1. Balance digits: 4.70 + 0.38
2. Add whole parts: 4
3. Add decimal parts: 70 + 38 = 108 ➔ 1.08
4. Total: 4 + 1.08 = 5.08'''
      },
      {
        'q': '348 + 526 = ?',
        'ans': '874',
        'trick': '➕ 3-Digit Chunking Method',
        'formula': '(Hundreds + Hundreds) + (2-Digit Chunk)',
        'steps': '''1. Add hundreds: 300 + 500 = 800
2. Add remaining 2-digit chunks: 48 + 26 = 74
3. Combine: 800 + 74 = 874'''
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: AppTheme.gold, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '➕ Speed Addition (Viral Maths)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Master Left-to-Right Split, Friend Number (शून्यकरण) & Complementary 100-Pairing to add in seconds without pencil & paper!',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Viral Maths Addition Formulas & Step-by-Step Demos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...workedExamples.map((ex) => _buildMethodCard(ex)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.bolt_rounded, color: Colors.white),
          label: const Text('Practice 15 Speed Addition Questions', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: _startGenericQuiz,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- 8. ➖ SPEED SUBTRACTION MASTERY (Viral Maths Vedic Edition) ---
  Widget _buildSubtractionView() {
    final workedExamples = [
      {
        'q': '10000 - 3648 = ?',
        'ans': '6352',
        'trick': '➖ All From 9, Last From 10 (निखिलं नवतश्चरमं दशतः)',
        'formula': 'Subtract digits from 9, last digit from 10',
        'steps': '''1. Subtract from 9: 9 - 3 = 6
2. Subtract from 9: 9 - 6 = 3
3. Subtract from 9: 9 - 4 = 5
4. Subtract last from 10: 10 - 8 = 2
5. Instant Result: 6352 (Zero borrowing!)'''
      },
      {
        'q': '83 - 38 = ?',
        'ans': '45',
        'trick': '➖ 2-Digit Reverse Subtraction (AB - BA)',
        'formula': '(AB - BA) = 9 × (A - B)',
        'steps': '''1. Subtract digits: 8 - 3 = 5
2. Multiply by 9: 9 × 5 = 45
3. Instant mental result: 45!'''
      },
      {
        'q': '752 - 257 = ?',
        'ans': '495',
        'trick': '➖ 3-Digit Reverse Subtraction (ABC - CBA)',
        'formula': '(ABC - CBA) = 99 × (A - C)',
        'steps': '''1. Subtract outer digits: 7 - 2 = 5
2. Multiply by 99: 99 × 5 = 495
3. Instant result: 495!'''
      },
      {
        'q': '84 - 39 = ?',
        'ans': '45',
        'trick': '➖ Constant Difference Rule (समान अंतर नियम)',
        'formula': '(A + k) - (B + k) = A - B',
        'steps': '''1. Add +1 to both numbers to make 39 a clean 40
2. (84 + 1) - (39 + 1) = 85 - 40
3. 85 - 40 = 45 (1-second solve!)'''
      },
      {
        'q': '143 - 88 = ?',
        'ans': '55',
        'trick': '➖ Shopkeeper\'s Add-to-Reach Method (सीढ़ी विधि)',
        'formula': 'Step up from smaller to bigger number',
        'steps': '''1. Step up from 88 to 100: +12
2. Step up from 100 to 143: +43
3. Combine steps: 12 + 43 = 55'''
      },
      {
        'q': '642 - 275 = ?',
        'ans': '367',
        'trick': '➖ Left-to-Right Staged Subtraction',
        'formula': 'Subtract Hundreds ➔ Tens ➔ Units',
        'steps': '''1. 642 - 200 = 442
2. 442 - 70 = 372
3. 372 - 5 = 367'''
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF047857)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.remove_circle_outline_rounded, color: AppTheme.gold, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '➖ Speed Subtraction (Viral Maths)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Eliminate traditional borrowing! Use Nikhilam (All from 9, last from 10), Reverse Subtraction 9(A-B) & Constant Difference to subtract at lightning speed.',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Viral Maths Subtraction Formulas & Step-by-Step Demos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...workedExamples.map((ex) => _buildMethodCard(ex)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF059669),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.bolt_rounded, color: Colors.white),
          label: const Text('Practice 15 Speed Subtraction Questions', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: _startGenericQuiz,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- 9. ➗ SPEED DIVISION MASTERY (Viral Maths Vedic Edition) ---
  Widget _buildDivisionView() {
    final workedExamples = [
      {
        'q': '312 ÷ 5 = ?',
        'ans': '62.4',
        'trick': '➗ Magical Division by 5 (Double & Shift)',
        'formula': 'N ÷ 5 = (2N) ÷ 10',
        'steps': '''1. Double the numerator: 312 × 2 = 624
2. Shift decimal 1 place left: 624 ÷ 10 = 62.4'''
      },
      {
        'q': '450 ÷ 25 = ?',
        'ans': '18',
        'trick': '➗ Magical Division by 25 (Multiply by 4 & Shift 2)',
        'formula': 'N ÷ 25 = (4N) ÷ 100',
        'steps': '''1. Multiply numerator by 4: 450 × 4 = 1800
2. Shift decimal 2 places left: 1800 ÷ 100 = 18'''
      },
      {
        'q': '350 ÷ 125 = ?',
        'ans': '2.8',
        'trick': '➗ Magical Division by 125 (Multiply by 8 & Shift 3)',
        'formula': 'N ÷ 125 = (8N) ÷ 1000',
        'steps': '''1. Multiply numerator by 8: 350 × 8 = 2800
2. Shift decimal 3 places left: 2800 ÷ 1000 = 2.8'''
      },
      {
        'q': '123 ÷ 9 = ?',
        'ans': '13 R 6',
        'trick': '➗ Nikhilam Division by 9 (Left-to-Right Digits)',
        'formula': 'Progressive digit sums give quotient & remainder',
        'steps': '''1. First digit is 1 ➔ Quotient tens = 1
2. Add second digit: 1 + 2 = 3 ➔ Quotient units = 3 (Q = 13)
3. Add third digit: 3 + 3 = 6 ➔ Remainder = 6'''
      },
      {
        'q': '750 ÷ 50 = ?',
        'ans': '15',
        'trick': '➗ Double & Divide by 100',
        'formula': 'N ÷ 50 = (2N) ÷ 100',
        'steps': '''1. Double 750: 750 × 2 = 1500
2. Divide by 100: 1500 ÷ 100 = 15'''
      },
      {
        'q': '4850 ÷ 19.8 ≈ ?',
        'ans': '245',
        'trick': '➗ Proportional Decimal Shifting (Bank Exam DI)',
        'formula': 'Adjust denominator to round figure and shift numerator proportionally',
        'steps': '''1. Round 19.8 up to 20 (+1%)
2. Add +1% to numerator: 4850 + 48.5 ≈ 4898.5
3. Divide by 20: 4898.5 ÷ 20 ≈ 245'''
      },
    ];

    final divisibilityRules = [
      {'rule': 'Divisible by 2', 'desc': 'Last digit is even (0, 2, 4, 6, 8)'},
      {'rule': 'Divisible by 3', 'desc': 'Sum of all digits is a multiple of 3'},
      {'rule': 'Divisible by 4', 'desc': 'Last 2 digits form a number divisible by 4 (e.g. 716)'},
      {'rule': 'Divisible by 5', 'desc': 'Last digit is 0 or 5'},
      {'rule': 'Divisible by 6', 'desc': 'Divisible by BOTH 2 and 3'},
      {'rule': 'Divisible by 8', 'desc': 'Last 3 digits form a number divisible by 8 (e.g. 5128)'},
      {'rule': 'Divisible by 9', 'desc': 'Sum of all digits is a multiple of 9 (Digital Sum = 9)'},
      {'rule': 'Divisible by 11', 'desc': '|Sum(Odd places) - Sum(Even places)| is 0 or multiple of 11'},
      {'rule': 'Divisible by 72', 'desc': 'Divisible by BOTH 8 and 9 (Super common in SSC CGL!)'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.safety_divider_rounded, color: AppTheme.gold, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '➗ Speed Division (Viral Maths)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Transform long divisions into 2-second multiplications by 2, 4, or 8! Master Nikhilam 9 rule & Proportional Shifting for Bank DI.',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Viral Maths Division Formulas & Step-by-Step Demos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...workedExamples.map((ex) => _buildMethodCard(ex)),
        const SizedBox(height: 12),
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
              const Row(
                children: [
                  Icon(Icons.verified_rounded, color: AppTheme.cyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Essential Exam Divisibility Rules',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...divisibilityRules.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.bold, fontSize: 14)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
                              children: [
                                TextSpan(text: '${r['rule']!}: ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                TextSpan(text: r['desc']!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.bolt_rounded, color: Colors.white),
          label: const Text('Practice 15 Speed Division Questions', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: _startGenericQuiz,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMethodCard(Map<String, String> ex) {
    final formula = ex['formula'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ex['q']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '= ${ex['ans']}',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accent, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ex['trick']!,
            style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
          if (formula != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.35)),
              ),
              child: Text(
                'Formula: $formula',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), fontFamily: 'monospace'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ex['steps']!,
              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericTopicView(TopicModel topic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calculate_rounded, color: AppTheme.accent, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              topic.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              topic.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.bolt_rounded, color: Colors.white),
              label: const Text('Start Speed Practice Drill', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _startGenericQuiz,
            ),
          ],
        ),
      ),
    );
  }
}

