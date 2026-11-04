import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import 'practice_quiz_screen.dart';
import '../auth/auth_screen.dart';

class ExamMockHubScreen extends StatefulWidget {
  const ExamMockHubScreen({super.key});

  @override
  State<ExamMockHubScreen> createState() => _ExamMockHubScreenState();
}

class _ExamMockHubScreenState extends State<ExamMockHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMaterialCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Exam Mock Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Official Level Questions & High-Yield Notes', style: TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          labelColor: AppTheme.gold,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.flash_on_rounded, size: 20), text: 'Exam Mocks'),
            Tab(icon: Icon(Icons.menu_book_rounded, size: 20), text: 'Reading Material'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExamMocksTab(context),
          _buildReadingMaterialTab(context),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: EXAM SPEED MOCKS
  // ==========================================
  Widget _buildExamMocksTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Motivational Exam Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.military_tech_rounded, color: AppTheme.gold, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real All-India Exam Difficulty',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Dynamic question generator calibrated to exact TCS / IBPS / RRB patterns with official marking schemes.',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _examCard(
          context,
          examTitle: 'SSC CGL & CHSL Speed Booster',
          pattern: 'Reciprocal Algebra Shortcuts • Pythagorean Triples • Unit Digit Cyclicity • Fractional % • Squares',
          markingScheme: '+2.0 marks / -0.50 negative',
          icon: Icons.flash_on_rounded,
          badge: 'SSC CGL / CHSL / CPO',
          badgeColor: Colors.blueAccent,
          questionsCount: 25,
          examKey: 'ssc',
          recommendedTimerSec: 2.5,
        ),
        const SizedBox(height: 16),

        _examCard(
          context,
          examTitle: 'Bank PO & Clerk Simplification Drill',
          pattern: 'BODMAS Multi-step Simplification • 4-Digit Square Roots • 5-Digit Cube Roots • Mixed % Splits',
          markingScheme: '+1.0 mark / -0.25 negative',
          icon: Icons.account_balance_rounded,
          badge: 'SBI PO / IBPS PO / Clerk',
          badgeColor: Colors.purpleAccent,
          questionsCount: 35,
          examKey: 'banking',
          recommendedTimerSec: 2.5,
        ),
        const SizedBox(height: 16),

        _examCard(
          context,
          examTitle: 'Railway NTPC & Group D Reflex Sprint',
          pattern: 'Speed km/h ↔ m/s Conversions • Rapid Mental LCM/HCF • Divisibility Tests • a² - b² Identity',
          markingScheme: '+1.0 mark / -0.33 negative',
          icon: Icons.train_rounded,
          badge: 'RRB NTPC / Group D / ALP',
          badgeColor: Colors.amberAccent,
          questionsCount: 30,
          examKey: 'railway',
          recommendedTimerSec: 2.5,
        ),
        const SizedBox(height: 16),

        _examCard(
          context,
          examTitle: 'CAT Quant Speed & Recall Drill',
          pattern: 'Vedic Base-100/50 Multiplication • Successive % Formulas • Remainder Theorems • Exponent Powers',
          markingScheme: '+3.0 marks / -1.00 negative',
          icon: Icons.psychology_rounded,
          badge: 'CAT / XAT / IPMAT',
          badgeColor: Colors.tealAccent,
          questionsCount: 20,
          examKey: 'cat',
          recommendedTimerSec: 2.5,
        ),
        const SizedBox(height: 16),

        _examCard(
          context,
          examTitle: 'Hard-On Pro Multiplier Sprint',
          pattern: '2-Digit × 2-Digit Extreme Calculation (17×45 to 48×87) with step-by-step Vedic breakdown',
          markingScheme: '+2.0 marks / strict timing',
          icon: Icons.electric_bolt_rounded,
          badge: 'PRO VIP DRILL',
          badgeColor: Colors.deepOrangeAccent,
          questionsCount: 20,
          examKey: 'multiplier',
          recommendedTimerSec: 2.5,
        ),
      ],
    );
  }

  Widget _examCard(
    BuildContext context, {
    required String examTitle,
    required String pattern,
    required String markingScheme,
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required int questionsCount,
    required String examKey,
    required double recommendedTimerSec,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(icon, color: badgeColor, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            examTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(pattern, style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rule_rounded, color: AppTheme.gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  markingScheme,
                  style: const TextStyle(fontSize: 11, color: AppTheme.gold, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                Text(
                  '• $questionsCount Questions',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 2.5s Rapid Reflex Sprint Button
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _launchMockQuiz(
                    context,
                    examKey: examKey,
                    examTitle: examTitle,
                    badge: badge,
                    count: questionsCount,
                    perQuestionSec: recommendedTimerSec,
                  ),
                  label: const Text('2.5s Reflex Sprint', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              // Standard Exam Timer Button
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: AppTheme.surfaceLight.withValues(alpha: 0.9)),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _launchMockQuiz(
                    context,
                    examKey: examKey,
                    examTitle: examTitle,
                    badge: badge,
                    count: questionsCount,
                    perQuestionSec: 12.0, // standard 12s per question simulator
                  ),
                  label: const Text('12s Simulator', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchMockQuiz(
    BuildContext context, {
    required String examKey,
    required String examTitle,
    required String badge,
    required int count,
    required double perQuestionSec,
  }) {
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

    final generatedQuestions = DynamicQuestionEngine.generateExamSpecificMockSet(
      examType: examKey,
      count: count,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'exam_mock_$examKey',
            title: examTitle,
            subtitle: '$badge • ${perQuestionSec}s Mode',
            type: TopicType.custom,
            iconName: 'timer',
          ),
          customQuestions: generatedQuestions,
          onRegenerateQuestions: () => DynamicQuestionEngine.generateExamSpecificMockSet(
            examType: examKey,
            count: count,
          ),
          isTimed: true,
          perQuestionSeconds: perQuestionSec,
          questionCount: generatedQuestions.length,
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: HIGH-YIELD READING MATERIAL & FORMULA SHEETS
  // ==========================================
  Widget _buildReadingMaterialTab(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final pdfs = state.adminPdfMaterials;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All'),
              _filterChip('SSC CGL/CHSL'),
              _filterChip('Banking PO'),
              _filterChip('Railways NTPC'),
              _filterChip('CAT / MBA'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 1. SSC Reciprocal Algebra Shortcuts
        if (_shouldShowCategory('SSC CGL/CHSL'))
          _buildFormulaCard(
            context,
            examTag: 'SSC CGL / CHSL',
            tagColor: Colors.blueAccent,
            title: '⚡ Reciprocal Algebra Speed Shortcuts',
            content: [
              '• If x + 1/x = k  ➔  x² + 1/x² = k² - 2',
              '  e.g., If x + 1/x = 4  ➔  x² + 1/x² = 4² - 2 = 14',
              '• If x - 1/x = k  ➔  x² + 1/x² = k² + 2',
              '  e.g., If x - 1/x = 4  ➔  x² + 1/x² = 4² + 2 = 18',
              '• If x + 1/x = k  ➔  x³ + 1/x³ = k³ - 3k',
              '  e.g., If x + 1/x = 3  ➔  x³ + 1/x³ = 27 - 9 = 18',
              '• If x - 1/x = k  ➔  x³ - 1/x³ = k³ + 3k',
            ],
            testTopicKey: 'ssc',
            drillName: 'Practice Algebra Drill',
          ),

        // 2. Pythagorean Triples Speed Handbook
        if (_shouldShowCategory('SSC CGL/CHSL') || _shouldShowCategory('Railways NTPC'))
          _buildFormulaCard(
            context,
            examTag: 'SSC & RAILWAYS',
            tagColor: Colors.amberAccent,
            title: '📐 High-Frequency Pythagorean Triples',
            content: [
              '• Core Primitive Triples:',
              '  (3, 4, 5)     | (5, 12, 13)   | (7, 24, 25)',
              '  (8, 15, 17)   | (9, 40, 41)   | (11, 60, 61)',
              '  (12, 35, 37)  | (13, 84, 85)  | (16, 63, 65)',
              '  (20, 21, 29)  | (28, 45, 53)  | (33, 56, 65)',
              '  (36, 77, 85)  | (39, 80, 89)  | (48, 55, 73)',
              '  (65, 72, 97)  | (20, 99, 101)',
              '• Generation Rule for Odd a:',
              '  b = (a² - 1) / 2  and  c = (a² + 1) / 2',
              '  e.g., a = 7 ➔ b = (49-1)/2 = 24, c = 25',
            ],
            testTopicKey: 'ssc',
            drillName: 'Practice Triples Drill',
          ),

        // 3. Fractional Percentages Master Table
        if (_shouldShowCategory('Banking PO') || _shouldShowCategory('SSC CGL/CHSL'))
          _buildFormulaCard(
            context,
            examTag: 'BANK PO & SSC',
            tagColor: Colors.purpleAccent,
            title: '📊 Fractional Percentage Equivalence Table',
            content: [
              '• 1/2 = 50%       | 1/3 = 33.33%   | 1/4 = 25%',
              '• 1/5 = 20%       | 1/6 = 16.67%   | 1/7 = 14.28%',
              '• 1/8 = 12.5%     | 1/9 = 11.11%   | 1/11 = 9.09%',
              '• 1/12 = 8.33%    | 1/16 = 6.25%',
              '• Crucial Bank Multiples:',
              '  3/8 = 37.5%     | 5/8 = 62.5%    | 7/8 = 87.5%',
              '  5/6 = 83.33%    | 2/3 = 66.67%   | 4/7 = 57.14%',
            ],
            testTopicKey: 'banking',
            drillName: 'Practice Fractions Drill',
          ),

        // 4. Railway Speed Conversion Ladder
        if (_shouldShowCategory('Railways NTPC'))
          _buildFormulaCard(
            context,
            examTag: 'RAILWAYS NTPC',
            tagColor: Colors.amberAccent,
            title: '🚂 Speed Conversion Multiplier 18 Ladder',
            content: [
              '• km/h to m/s ➔ Multiply by (5/18)',
              '• m/s to km/h ➔ Multiply by (18/5)',
              '• Instant Reflex Table (Multiples of 18 km/h):',
              '  18 km/h = 5 m/s    |  36 km/h = 10 m/s',
              '  54 km/h = 15 m/s   |  72 km/h = 20 m/s',
              '  90 km/h = 25 m/s   | 108 km/h = 30 m/s',
              '  126 km/h = 35 m/s  | 144 km/h = 40 m/s',
            ],
            testTopicKey: 'railway',
            drillName: 'Practice Speed Drill',
          ),

        // 5. Vedic Base-100 & Base-50 Multiplication
        if (_shouldShowCategory('CAT / MBA') || _shouldShowCategory('Banking PO'))
          _buildFormulaCard(
            context,
            examTag: 'CAT & BANKING',
            tagColor: Colors.tealAccent,
            title: '⚡ Vedic Base-100 & Base-50 Shortcuts',
            content: [
              '• Base-100 Near Numbers (e.g., 96 × 97):',
              '  Deficiencies: (100 - 4) and (100 - 3)',
              '  Part 1: 100 - (4 + 3) = 93',
              '  Part 2: 4 × 3 = 12 ➔ Result: 9,312',
              '• Base-50 Symmetrical Numbers (e.g., 48 × 52):',
              '  (50 - 2) × (50 + 2) = 50² - 2² = 2500 - 4 = 2,496',
              '• Successive Percentage Change Formula:',
              '  Net % = a + b + (ab / 100)',
              '  e.g., +20% and +30% ➔ 20 + 30 + 6 = +56%',
            ],
            testTopicKey: 'cat',
            drillName: 'Practice Vedic Drill',
          ),

        // 6. Unit Digit Cyclicity Rules
        if (_shouldShowCategory('SSC CGL/CHSL') || _shouldShowCategory('Railways NTPC'))
          _buildFormulaCard(
            context,
            examTag: 'NUMBER SYSTEM',
            tagColor: Colors.cyanAccent,
            title: '🔢 Unit Digit Cyclicity Master Sheet',
            content: [
              '• Periodicity 4 (Cycle of 4): 2, 3, 7, 8',
              '  Divide power by 4. If rem=1 ➔ b¹, rem=2 ➔ b², rem=3 ➔ b³, rem=0 ➔ b⁴',
              '  e.g., 7³⁵ ➔ 35 ÷ 4 leaves rem 3 ➔ 7³ = 343 ➔ Unit digit = 3',
              '• Periodicity 2 (Cycle of 2): 4 and 9',
              '  4^odd = 4,  4^even = 6',
              '  9^odd = 9,  9^even = 1',
              '• Periodicity 1 (Never change): 0, 1, 5, 6',
            ],
            testTopicKey: 'ssc',
            drillName: 'Practice Unit Digit Drill',
          ),

        // 7. Cloud PDF Study Notes from Admin
        if (pdfs.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            '📥 Downloadable PDF Notes & Handouts',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          ...pdfs.map((doc) => _buildPdfDocCard(context, doc)),
        ],
      ],
    );
  }

  bool _shouldShowCategory(String cat) {
    if (_selectedMaterialCategory == 'All') return true;
    return _selectedMaterialCategory == cat;
  }

  Widget _filterChip(String category) {
    final isSelected = _selectedMaterialCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(category),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: AppTheme.surface,
        selectedColor: AppTheme.gold,
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppTheme.gold : AppTheme.surfaceLight),
        ),
        onSelected: (val) {
          setState(() {
            _selectedMaterialCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildFormulaCard(
    BuildContext context, {
    required String examTag,
    required Color tagColor,
    required String title,
    required List<String> content,
    required String testTopicKey,
    required String drillName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tagColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  examTag,
                  style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.bookmark_added_rounded, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content.map((line) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontFamily: line.contains('|') || line.contains('=') ? 'monospace' : null,
                      fontSize: 12.5,
                      color: line.startsWith('•') ? AppTheme.gold : Colors.white70,
                      fontWeight: line.startsWith('•') ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, color: AppTheme.gold, size: 20),
              label: Text(
                drillName,
                style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: () => _launchMockQuiz(
                context,
                examKey: testTopicKey,
                examTitle: title,
                badge: examTag,
                count: 10,
                perQuestionSec: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfDocCard(BuildContext context, Map<String, dynamic> doc) {
    String title = doc['title'] ?? 'Study Notes';
    String examCategory = doc['category'] ?? 'General';
    String fileUrl = doc['url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Tag: $examCategory', style: const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: AppTheme.gold, size: 20),
            tooltip: 'Open PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening PDF: $title ($fileUrl)'),
                  backgroundColor: AppTheme.surfaceLight,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
