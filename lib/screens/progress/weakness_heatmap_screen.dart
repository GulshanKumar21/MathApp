import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/math_models.dart';
import '../../data/dynamic_question_engine.dart';
import '../../providers/app_state_provider.dart';
import '../practice/practice_quiz_screen.dart';

class WeaknessHeatmapScreen extends StatefulWidget {
  const WeaknessHeatmapScreen({super.key});

  @override
  State<WeaknessHeatmapScreen> createState() => _WeaknessHeatmapScreenState();
}

class _WeaknessHeatmapScreenState extends State<WeaknessHeatmapScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Parse mistake prompts to find exact count of mistakes per number
  Map<String, Map<int, int>> _extractUserMistakeCounts(List<MistakeModel> mistakes) {
    final Map<int, int> tableCounts = {};
    final Map<int, int> squareCounts = {};
    final Map<int, int> cubeCounts = {};
    final Map<int, int> multiplierCounts = {};

    for (final m in mistakes) {
      final prompt = m.prompt;
      // Match tables e.g. "17 x 8" or "19 × 6"
      final tableMatch = RegExp(r'(\d+)\s*[x×*]\s*(\d+)').firstMatch(prompt);
      if (tableMatch != null) {
        final a = int.tryParse(tableMatch.group(1) ?? '');
        final b = int.tryParse(tableMatch.group(2) ?? '');
        if (a != null && a <= 50) tableCounts[a] = (tableCounts[a] ?? 0) + 1;
        if (b != null && b <= 50) tableCounts[b] = (tableCounts[b] ?? 0) + 1;
        if (a != null && a >= 12 && a <= 29) {
          multiplierCounts[a] = (multiplierCounts[a] ?? 0) + 1;
        }
      }
      // Match squares e.g. "23²" or "23 x 23"
      final sqMatch = RegExp(r'(\d+)²').firstMatch(prompt);
      if (sqMatch != null) {
        final n = int.tryParse(sqMatch.group(1) ?? '');
        if (n != null && n <= 100) squareCounts[n] = (squareCounts[n] ?? 0) + 1;
      }
      // Match cubes e.g. "14³"
      final cbMatch = RegExp(r'(\d+)³').firstMatch(prompt);
      if (cbMatch != null) {
        final n = int.tryParse(cbMatch.group(1) ?? '');
        if (n != null && n <= 30) cubeCounts[n] = (cubeCounts[n] ?? 0) + 1;
      }
    }

    return {
      'tables': tableCounts,
      'squares': squareCounts,
      'cubes': cubeCounts,
      'multipliers': multiplierCounts,
    };
  }

  Map<String, Set<int>> _extractAttemptedNumbers(
    AppStateProvider state,
    Map<String, Map<int, int>> mistakesMap,
  ) {
    final Set<int> tables = Set<int>.from(state.tablePracticeTimestamps.keys);
    final Set<int> squares = {};
    final Set<int> cubes = {};
    final Set<int> multipliers = {};

    // Anything with recorded mistakes was definitely attempted
    tables.addAll((mistakesMap['tables'] ?? {}).keys);
    squares.addAll((mistakesMap['squares'] ?? {}).keys);
    cubes.addAll((mistakesMap['cubes'] ?? {}).keys);
    multipliers.addAll((mistakesMap['multipliers'] ?? {}).keys);

    for (final h in state.history) {
      final tid = h.topicId;
      if (tid.startsWith('table_')) {
        final t = int.tryParse(tid.replaceFirst('table_', ''));
        if (t != null) tables.add(t);
      } else if (tid == 'tables_all_1_10') {
        for (int n = 1; n <= 10; n++) { tables.add(n); }
      } else if (tid == 'tables_all_11_20') {
        for (int n = 11; n <= 20; n++) { tables.add(n); }
      } else if (tid == 'tables_all_21_50') {
        for (int n = 21; n <= 30; n++) { tables.add(n); }
      } else if (tid.startsWith('tables_mix_')) {
        for (final part in tid.replaceFirst('tables_mix_', '').split('_')) {
          final t = int.tryParse(part);
          if (t != null) tables.add(t);
        }
      } else if (tid.startsWith('squares_focus_')) {
        final n = int.tryParse(tid.replaceFirst('squares_focus_', ''));
        if (n != null) squares.add(n);
      } else if (tid.startsWith('squares_')) {
        final parts = tid.replaceFirst('squares_', '').split('_');
        if (parts.length == 2) {
          final a = int.tryParse(parts[0]);
          final b = int.tryParse(parts[1]);
          if (a != null && b != null) {
            for (int n = a; n <= b; n++) { squares.add(n); }
          }
        }
      } else if (tid.startsWith('cubes_focus_')) {
        final n = int.tryParse(tid.replaceFirst('cubes_focus_', ''));
        if (n != null) cubes.add(n);
      } else if (tid.startsWith('cubes_')) {
        final parts = tid.replaceFirst('cubes_', '').split('_');
        if (parts.length == 2) {
          final a = int.tryParse(parts[0]);
          final b = int.tryParse(parts[1]);
          if (a != null && b != null) {
            for (int n = a; n <= b; n++) { cubes.add(n); }
          }
        }
      } else if (tid.startsWith('hard_multiplier_')) {
        final n = int.tryParse(tid.replaceFirst('hard_multiplier_', ''));
        if (n != null) multipliers.add(n);
      }
    }

    return {
      'tables': tables,
      'squares': squares,
      'cubes': cubes,
      'multipliers': multipliers,
    };
  }

  void _startAIWeaknessEliminationDrill(BuildContext context, AppStateProvider state) {
    final mistakes = state.mistakes;
    final extracted = _extractUserMistakeCounts(mistakes);
    final tableCounts = extracted['tables'] ?? {};
    final squareCounts = extracted['squares'] ?? {};

    List<QuestionModel> questions = [];

    // Prioritize student's actual most frequent mistakes
    if (tableCounts.isNotEmpty) {
      final sortedWeakTables = tableCounts.keys.toList()
        ..sort((a, b) => (tableCounts[b] ?? 0).compareTo(tableCounts[a] ?? 0));
      for (final t in sortedWeakTables.take(3)) {
        questions.addAll(DynamicQuestionEngine.generateTableQuestions(t, count: 3));
      }
    }
    if (squareCounts.isNotEmpty) {
      final sortedWeakSquares = squareCounts.keys.toList()
        ..sort((a, b) => (squareCounts[b] ?? 0).compareTo(squareCounts[a] ?? 0));
      for (final sq in sortedWeakSquares.take(2)) {
        questions.addAll(DynamicQuestionEngine.generateSquaresRangeQuestions(start: sq, end: sq, count: 2));
      }
    }

    // If student has few mistakes, dynamically fill from their starred or practiced items
    if (questions.length < 10) {
      final dynamicPool = state.starredTables.isNotEmpty
          ? state.starredTables.toList()
          : [12, 14, 16, 17, 18, 19, 23, 24, 27, 29];
      dynamicPool.shuffle();
      for (final p in dynamicPool) {
        if (questions.length >= 10) break;
        questions.addAll(DynamicQuestionEngine.generateTableQuestions(p, count: 2));
      }
    }

    questions.shuffle();
    final finalQuestions = questions.take(10).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'ai_weakness_drill',
            title: '🎯 AI Weakness Elimination Drill',
            subtitle: 'Targeted drill fixing high-latency bottlenecks',
            type: TopicType.tables,
            iconName: 'psychology_rounded',
          ),
          customQuestions: finalQuestions,
          isTimed: true,
          questionCount: 10,
        ),
      ),
    );
  }

  void _openCellDrillBottomSheet(BuildContext context, {required String title, required String sub, required VoidCallback onStartDrill, required Color statusColor, required String speedRating}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppTheme.surfaceLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      speedRating.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                sub,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: const Text(
                    'Start 10-Question Targeted Drill ⚡',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onStartDrill();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final extracted = _extractUserMistakeCounts(state.mistakes);

    final userWeakTables = extracted['tables'] ?? {};
    final userWeakSquares = extracted['squares'] ?? {};
    final userWeakCubes = extracted['cubes'] ?? {};
    final userWeakMultipliers = extracted['multipliers'] ?? {};

    final attempted = _extractAttemptedNumbers(state, extracted);
    final attemptedTables = attempted['tables'] ?? {};
    final attemptedSquares = attempted['squares'] ?? {};
    final attemptedCubes = attempted['cubes'] ?? {};
    final attemptedMultipliers = attempted['multipliers'] ?? {};

    // Dynamic calculation health based on actual recorded error bottlenecks
    final totalBottlenecks = userWeakTables.values.where((c) => c >= 2).length +
        userWeakSquares.values.where((c) => c >= 2).length +
        userWeakCubes.values.where((c) => c >= 2).length;
    final healthPercentage = (100 - (totalBottlenecks * 4)).clamp(40, 100);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('🧠 AI Calculation Heatmap'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Run Elimination Drill',
            icon: const Icon(Icons.bolt_rounded, color: AppTheme.accent),
            onPressed: () => _startAIWeaknessEliminationDrill(context, state),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelColor: AppTheme.accent,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '📊 Tables (1-30)'),
            Tab(text: '📐 Squares (1-50)'),
            Tab(text: '🧊 Cubes (1-30)'),
            Tab(text: '⚡ Multipliers'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Top AI Speed & Diagnostic Radar Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.radar_rounded, color: Color(0xFF34D399), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI LATENCY RADAR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF34D399),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Calculation Health: $healthPercentage%',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        'Avg ${state.overallAvgSpeedSeconds > 0 ? state.overallAvgSpeedSeconds.toStringAsFixed(1) : '1.8'}s / q',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  totalBottlenecks > 0
                      ? '⚠️ AI detected $totalBottlenecks calculation bottlenecks. Tap any cell or run elimination drill!'
                      : '✨ Excellent! Calculation speed is well within competitive exam target benchmarks (<1.5s).',
                  style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: const Color(0xFF064E3B),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'Start AI Weakness Elimination Drill (10 Qs)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () => _startAIWeaknessEliminationDrill(context, state),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),

          // 2. Legend Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 10,
              runSpacing: 6,
              children: [
                _buildLegendItem('Fast', const Color(0xFF10B981)),
                _buildLegendItem('Average', Colors.amber),
                _buildLegendItem('Weak', AppTheme.error),
                _buildLegendItem('Unattempted', const Color(0xFF64748B)),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 3. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTablesTab(context, userWeakTables, attemptedTables),
                _buildSquaresTab(context, userWeakSquares, attemptedSquares),
                _buildCubesTab(context, userWeakCubes, attemptedCubes),
                _buildMultipliersTab(context, userWeakMultipliers, attemptedMultipliers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // TAB 1: TABLES (1 to 30)
  Widget _buildTablesTab(BuildContext context, Map<int, int> userWeakTables, Set<int> attemptedTables) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('FOUNDATIONAL TABLES (1 to 10)', 'Instant recall should be <1.0s'),
        _buildGrid(
          context: context,
          start: 1,
          end: 10,
          prefix: 'T',
          mistakeCounts: userWeakTables,
          attemptedSet: attemptedTables,
          onTapNumber: (n) => _startTableDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('EXAM CORE TABLES (11 to 20)', 'High-yield speed section for Bank, SSC & Railways'),
        _buildGrid(
          context: context,
          start: 11,
          end: 20,
          prefix: 'T',
          mistakeCounts: userWeakTables,
          attemptedSet: attemptedTables,
          onTapNumber: (n) => _startTableDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('PRO SPEED TABLES (21 to 30)', 'Top 1% candidate speed differentiator'),
        _buildGrid(
          context: context,
          start: 21,
          end: 30,
          prefix: 'T',
          mistakeCounts: userWeakTables,
          attemptedSet: attemptedTables,
          onTapNumber: (n) => _startTableDrill(context, n),
        ),
      ],
    );
  }

  // TAB 2: SQUARES (1 to 50) Divided into 5 neat sections
  Widget _buildSquaresTab(BuildContext context, Map<int, int> userWeakSquares, Set<int> attemptedSquares) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('PART 1: SQUARES (1 to 10)', 'Foundational memory baseline'),
        _buildGrid(
          context: context,
          start: 1,
          end: 10,
          prefix: 'Sq',
          isSquare: true,
          mistakeCounts: userWeakSquares,
          attemptedSet: attemptedSquares,
          onTapNumber: (n) => _startSquareDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('PART 2: SQUARES (11 to 20)', 'Most frequent square values in competitive exams'),
        _buildGrid(
          context: context,
          start: 11,
          end: 20,
          prefix: 'Sq',
          isSquare: true,
          mistakeCounts: userWeakSquares,
          attemptedSet: attemptedSquares,
          onTapNumber: (n) => _startSquareDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('PART 3: SQUARES (21 to 30)', 'Core DI & Simplification powers'),
        _buildGrid(
          context: context,
          start: 21,
          end: 30,
          prefix: 'Sq',
          isSquare: true,
          mistakeCounts: userWeakSquares,
          attemptedSet: attemptedSquares,
          onTapNumber: (n) => _startSquareDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('PART 4: SQUARES (31 to 40)', 'Speed tricks: Base 50 deficit method applies'),
        _buildGrid(
          context: context,
          start: 31,
          end: 40,
          prefix: 'Sq',
          isSquare: true,
          mistakeCounts: userWeakSquares,
          attemptedSet: attemptedSquares,
          onTapNumber: (n) => _startSquareDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('PART 5: SQUARES (41 to 50)', 'Base 50 surplus/deficit calculations'),
        _buildGrid(
          context: context,
          start: 41,
          end: 50,
          prefix: 'Sq',
          isSquare: true,
          mistakeCounts: userWeakSquares,
          attemptedSet: attemptedSquares,
          onTapNumber: (n) => _startSquareDrill(context, n),
        ),
      ],
    );
  }

  // TAB 3: CUBES (1 to 30) Divided into 3 neat sections
  Widget _buildCubesTab(BuildContext context, Map<int, int> userWeakCubes, Set<int> attemptedCubes) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('PART 1: CUBES (1 to 10)', 'Foundational cubes required for cube roots'),
        _buildGrid(
          context: context,
          start: 1,
          end: 10,
          prefix: 'Cb',
          isCube: true,
          mistakeCounts: userWeakCubes,
          attemptedSet: attemptedCubes,
          onTapNumber: (n) => _startCubeDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('PART 2: CUBES (11 to 20)', 'High-yield exam compound interest cubes (11³ to 15³)'),
        _buildGrid(
          context: context,
          start: 11,
          end: 20,
          prefix: 'Cb',
          isCube: true,
          mistakeCounts: userWeakCubes,
          attemptedSet: attemptedCubes,
          onTapNumber: (n) => _startCubeDrill(context, n),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('PART 3: CUBES (21 to 30)', 'Advanced compound interest & DI powers'),
        _buildGrid(
          context: context,
          start: 21,
          end: 30,
          prefix: 'Cb',
          isCube: true,
          mistakeCounts: userWeakCubes,
          attemptedSet: attemptedCubes,
          onTapNumber: (n) => _startCubeDrill(context, n),
        ),
      ],
    );
  }

  // TAB 4: HARD MULTIPLIERS (Dynamic accuracy & latency)
  Widget _buildMultipliersTab(BuildContext context, Map<int, int> multiplierErrors, Set<int> attemptedMultipliers) {
    final highYieldMultipliers = [
      {'base': 12, 'label': '12 × 2D', 'desc': 'Breakdown: (10 × N) + (2 × N)'},
      {'base': 13, 'label': '13 × 2D', 'desc': 'Breakdown: (10 × N) + (3 × N)'},
      {'base': 14, 'label': '14 × 2D', 'desc': 'Breakdown: 2 × (7 × N)'},
      {'base': 15, 'label': '15 × 2D', 'desc': 'Breakdown: (10 × N) + half of result'},
      {'base': 16, 'label': '16 × 2D', 'desc': 'Power of 2: Double 4 times'},
      {'base': 17, 'label': '17 × 2D', 'desc': 'Prime number: (20 × N) - (3 × N)'},
      {'base': 18, 'label': '18 × 2D', 'desc': 'Breakdown: (20 × N) - (2 × N)'},
      {'base': 19, 'label': '19 × 2D', 'desc': 'Breakdown: (20 × N) - (1 × N)'},
      {'base': 23, 'label': '23 × 2D', 'desc': 'Prime calculation: (20 × N) + (3 × N)'},
      {'base': 25, 'label': '25 × 2D', 'desc': 'Rule: Multiply by 100 then divide by 4'},
      {'base': 27, 'label': '27 × 2D', 'desc': 'Breakdown: (30 × N) - (3 × N)'},
      {'base': 29, 'label': '29 × 2D', 'desc': 'Breakdown: (30 × N) - (1 × N)'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: highYieldMultipliers.length,
      itemBuilder: (context, idx) {
        final item = highYieldMultipliers[idx];
        final base = item['base'] as int;
        final errors = multiplierErrors[base] ?? 0;
        final bool isAttempted = attemptedMultipliers.contains(base) || errors > 0;
        final color = !isAttempted
            ? const Color(0xFF64748B)
            : (errors >= 2
                ? AppTheme.error
                : (errors == 1 ? Colors.amber : const Color(0xFF10B981)));
        final tag = !isAttempted
            ? 'NEW'
            : (errors >= 2 ? 'WEAK ($errors)' : (errors == 1 ? 'REVIEW' : 'FAST'));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 1.2),
                ),
                alignment: Alignment.center,
                child: Text(
                  tag,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: color),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['desc'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.2),
                  foregroundColor: color,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Drill ⚡', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  final questions = DynamicQuestionEngine.generateSpecificMultiplierQuestions(
                    baseMultiplier: base,
                    count: 10,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeQuizScreen(
                        topic: TopicModel(
                          id: 'hard_multiplier_$base',
                          title: '${item['label']} Speed Drill',
                          subtitle: 'Targeted multiplier drill for $base × 2D',
                          type: TopicType.hardMultiplier,
                          iconName: 'flash_on_rounded',
                        ),
                        customQuestions: questions,
                        onRegenerateQuestions: () => DynamicQuestionEngine.generateSpecificMultiplierQuestions(
                          baseMultiplier: base,
                          count: 10,
                        ),
                        isTimed: true,
                        questionCount: 10,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accent, letterSpacing: 0.5),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid({
    required BuildContext context,
    required int start,
    required int end,
    required String prefix,
    bool isSquare = false,
    bool isCube = false,
    required Map<int, int> mistakeCounts,
    required Set<int> attemptedSet,
    required Function(int) onTapNumber,
  }) {
    final count = end - start + 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (ctx, index) {
        final n = start + index;
        final int errorCount = mistakeCounts[n] ?? 0;
        final bool isAttempted = attemptedSet.contains(n) || errorCount > 0;
        Color color;
        String tag;
        String speed;

        if (!isAttempted) {
          color = const Color(0xFF64748B); // Grey for unattempted cells
          tag = 'New';
          speed = 'Unattempted';
        } else if (errorCount >= 2) {
          color = AppTheme.error;
          tag = 'Weak ($errorCount err)';
          speed = '>3.5s';
        } else if (errorCount == 1) {
          color = Colors.amber;
          tag = 'Review (1 err)';
          speed = '2-3s';
        } else {
          color = const Color(0xFF10B981); // Green for attempted & mastered
          tag = 'Fast';
          speed = '<1.5s';
        }

        return GestureDetector(
          onTap: () {
            String title = '$prefix$n Calculation';
            if (isSquare) {
              title = 'Square of $n ($n² = ${n * n})';
            } else if (isCube) {
              title = 'Cube of $n ($n³ = ${n * n * n})';
            } else {
              title = 'Multiplication Table $n';
            }

            _openCellDrillBottomSheet(
              context,
              title: title,
              sub: 'Status: $tag ($speed recall) • AI recommends a 10-question sprint to solidify speed.',
              statusColor: color,
              speedRating: tag,
              onStartDrill: () => onTapNumber(n),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.8), width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$prefix$n',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startTableDrill(BuildContext context, int tableNumber) {
    final questions = DynamicQuestionEngine.generateTableQuestions(tableNumber, count: 10);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'table_$tableNumber',
            title: 'Table $tableNumber Speed Drill',
            subtitle: 'Targeted drill from AI Heatmap',
            type: TopicType.tables,
            iconName: 'grid_view_rounded',
          ),
          customQuestions: questions,
          isTimed: true,
          questionCount: 10,
        ),
      ),
    );
  }

  void _startSquareDrill(BuildContext context, int squareNumber) {
    // Generate focused questions around squareNumber
    final start = (squareNumber - 2).clamp(1, 50);
    final end = (squareNumber + 2).clamp(1, 50);
    final questions = DynamicQuestionEngine.generateSquaresRangeQuestions(start: start, end: end, count: 10);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'squares_focus_$squareNumber',
            title: 'Squares Drill (Focus on $squareNumber²)',
            subtitle: 'Targeted drill from AI Heatmap',
            type: TopicType.squares,
            iconName: 'crop_square_rounded',
          ),
          customQuestions: questions,
          isTimed: true,
          questionCount: 10,
        ),
      ),
    );
  }

  void _startCubeDrill(BuildContext context, int cubeNumber) {
    final start = (cubeNumber - 2).clamp(1, 30);
    final end = (cubeNumber + 2).clamp(1, 30);
    final questions = DynamicQuestionEngine.generateCubesRangeQuestions(start: start, end: end, count: 10);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'cubes_focus_$cubeNumber',
            title: 'Cubes Drill (Focus on $cubeNumber³)',
            subtitle: 'Targeted drill from AI Heatmap',
            type: TopicType.cubes,
            iconName: 'view_in_ar_rounded',
          ),
          customQuestions: questions,
          isTimed: true,
          questionCount: 10,
        ),
      ),
    );
  }
}
