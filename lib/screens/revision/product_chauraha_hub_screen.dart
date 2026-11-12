import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/product_chauraha_model.dart';
import '../../data/product_chauraha_repository.dart';
import '../../theme/app_theme.dart';

/// Interactive Hub for "Important Products (Chauraha)"
/// Provides:
/// 1. 📖 Visual Crossroads Concept Mode (Learn factor pairs like 108, 144, 180, 216, Base 25)
/// 2. 🎯 Multi-Select Dual-Answer Practice Mode (4 options, exactly 2 correct, MUST select both to advance)
class ProductChaurahaHubScreen extends StatefulWidget {
  final int initialTarget;
  final bool startInDrillMode;

  const ProductChaurahaHubScreen({
    super.key,
    this.initialTarget = 108,
    this.startInDrillMode = false,
  });

  @override
  State<ProductChaurahaHubScreen> createState() => _ProductChaurahaHubScreenState();
}

class _ProductChaurahaHubScreenState extends State<ProductChaurahaHubScreen>
    with SingleTickerProviderStateMixin {
  late int _activeTabIndex; // 0 = Concept Hub, 1 = 2-Answer Drill
  late int _selectedChaurahaIndex;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  // Drill / Practice State
  List<ChaurahaQuestion> _drillQuestions = [];
  int _currentQuestionIndex = 0;
  final Set<int> _selectedIndices = {};
  int? _wrongTappedIndex;
  bool _isCurrentQuestionSolved = false;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _isQuizFinished = false;
  Timer? _autoAdvanceTimer;

  // Shake animation controller for wrong option taps
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.startInDrillMode ? 1 : 0;

    final all = ProductChaurahaRepository.getAll();
    final matchIdx = all.indexWhere((c) => c.targetNumber == widget.initialTarget);
    _selectedChaurahaIndex = matchIdx >= 0 ? matchIdx : 0;

    _initTts();
    _initDrillQuestions();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage('en-IN');
      await _flutterTts.setSpeechRate(0.50);
      await _flutterTts.setPitch(1.0);
      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _flutterTts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  void _speakText(String text) async {
    try {
      await _flutterTts.stop();
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _initDrillQuestions() {
    _drillQuestions = ProductChaurahaRepository.getAllQuestions()..shuffle();
    if (_drillQuestions.isEmpty) {
      _drillQuestions = List.generate(10, (_) => ProductChaurahaRepository.generateRandomQuestion());
    }
    _currentQuestionIndex = 0;
    _selectedIndices.clear();
    _wrongTappedIndex = null;
    _isCurrentQuestionSolved = false;
    _score = 0;
    _streak = 0;
    _isQuizFinished = false;
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _flutterTts.stop();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.alt_route_rounded, color: Color(0xFFF59E0B), size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Product Crossroads',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Multiplication Crossroads • 108, 144, 180, 216 & Base 25',
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'How Crossroads Help in Exams',
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white70, size: 21),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Dual-Mode Top Tab Switcher: Concept Hub vs 2-Answer Drill
            _buildTopTabSwitcher(),
            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: _activeTabIndex == 0
                  ? _buildConceptHubView()
                  : _buildDualAnswerDrillView(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TOP DUAL-MODE TAB SWITCHER
  // -------------------------------------------------------------
  Widget _buildTopTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              icon: Icons.menu_book_rounded,
              title: 'Concept Hub',
              subtitle: 'Visual Crossroads',
              activeColor: const Color(0xFF06B6D4),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              index: 1,
              icon: Icons.check_circle_outline_rounded,
              title: '2-Answer Drill',
              subtitle: 'Dual-Select Quiz',
              activeColor: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color activeColor,
  }) {
    final isSelected = _activeTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
          if (index == 1 && _drillQuestions.isEmpty) {
            _initDrillQuestions();
          }
        });
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor.withValues(alpha: 0.6) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? activeColor : Colors.white60),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isSelected ? activeColor : Colors.white38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: CONCEPT HUB (Visual Crossroads Diagram View)
  // -------------------------------------------------------------
  Widget _buildConceptHubView() {
    final allChaurahas = ProductChaurahaRepository.getAll();
    final chauraha = allChaurahas[_selectedChaurahaIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Selector Carousel for Chaurahas
          _buildChaurahaSelectorChips(allChaurahas),
          const SizedBox(height: 16),

          // Main Interactive Crossroads Visual Card
          _buildVisualCrossroadsCard(chauraha),
          const SizedBox(height: 16),

          // Quick Math Anchor Card (Prime Factorization & Factor Pairs)
          _buildMathAnchorCard(chauraha),
          const SizedBox(height: 16),

          // Topper's Exam Strategy / Note Card
          _buildExamStrategyCard(chauraha),
          const SizedBox(height: 20),

          // Action Button: Jump directly into 2-Answer Drill for this Chauraha
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 20, color: Colors.black),
              label: Text(
                'Practice ${chauraha.title} (2-Answer Drill)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              onPressed: () {
                setState(() {
                  _activeTabIndex = 1;
                  // Filter drill questions for this specific chauraha if available
                  if (chauraha.questions.isNotEmpty) {
                    _drillQuestions = List.from(chauraha.questions);
                    _currentQuestionIndex = 0;
                    _selectedIndices.clear();
                    _wrongTappedIndex = null;
                    _isCurrentQuestionSolved = false;
                  }
                });
                try {
                  HapticFeedback.lightImpact();
                } catch (_) {}
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildChaurahaSelectorChips(List<ProductChaurahaModel> list) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final item = list[idx];
          final isSelected = _selectedChaurahaIndex == idx;
          final String chipLabel = item.isBaseFormat ? 'Base 25' : '${item.targetNumber}';

          return InkWell(
            onTap: () {
              setState(() => _selectedChaurahaIndex = idx);
              try {
                HapticFeedback.selectionClick();
              } catch (_) {}
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF13192B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF06B6D4) : Colors.white12,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisualCrossroadsCard(ProductChaurahaModel chauraha) {
    final themeColor = chauraha.isBaseFormat ? const Color(0xFFF59E0B) : const Color(0xFF06B6D4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF13192B),
            themeColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withValues(alpha: 0.35), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row: Title + TTS Sound Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        chauraha.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          chauraha.isBaseFormat ? 'MULTIPLIER BASE' : 'CROSSROADS',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: themeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chauraha.subtitle,
                    style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.65)),
                  ),
                ],
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isSpeaking ? const Color(0xFF10B981) : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    size: 18,
                    color: _isSpeaking ? Colors.black : Colors.white70,
                  ),
                ),
                onPressed: () {
                  final textToSpeak = chauraha.isBaseFormat
                      ? 'Base 25 crossroads: 25 times 12 is 300, 25 times 24 is 600, 25 times 15 is 375, and 25 times 25 is 625.'
                      : '${chauraha.title}: 12 times 9, 18 times 6, 27 times 4, and 36 times 3 all equal ${chauraha.targetNumber}.';
                  _speakText(textToSpeak);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // THE VISUAL CROSSROADS (North, South, East, West with Center)
          _buildCrossroadsLayout(chauraha, themeColor),
          const SizedBox(height: 18),

          // Extra Branches (if any, e.g. 12×12 for 144 or 6³ for 216 or 54×2 for 108)
          if (chauraha.extraBranch1 != null || chauraha.extraBranch2 != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (chauraha.extraBranch1 != null)
                  _buildBranchPill(chauraha.extraBranch1!, themeColor, isCompact: true),
                if (chauraha.extraBranch2 != null)
                  _buildBranchPill(chauraha.extraBranch2!, themeColor, isCompact: true),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCrossroadsLayout(ProductChaurahaModel chauraha, Color themeColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // NORTH BRANCH (Top Arm)
        _buildBranchPill(chauraha.topBranch, themeColor),
        const SizedBox(height: 4),

        // Vertical Connection Road Top
        _buildVerticalRoad(themeColor),
        const SizedBox(height: 4),

        // MIDDLE ROW: West Branch ➔ Center Hexagon ➔ East Branch
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // WEST BRANCH
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildBranchPill(chauraha.leftBranch, themeColor),
              ),
            ),
            const SizedBox(width: 6),

            // Horizontal Connection Bar Left
            _buildHorizontalRoad(themeColor),
            const SizedBox(width: 6),

            // THE CENTRAL NUMBER BADGE
            _buildCenterTargetBadge(chauraha, themeColor),
            const SizedBox(width: 6),

            // Horizontal Connection Bar Right
            _buildHorizontalRoad(themeColor),
            const SizedBox(width: 6),

            // EAST BRANCH
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildBranchPill(chauraha.rightBranch, themeColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Vertical Connection Road Bottom
        _buildVerticalRoad(themeColor),
        const SizedBox(height: 4),

        // SOUTH BRANCH (Bottom Arm)
        _buildBranchPill(chauraha.bottomBranch, themeColor),
      ],
    );
  }

  Widget _buildCenterTargetBadge(ProductChaurahaModel chauraha, Color themeColor) {
    final String centerText = chauraha.isBaseFormat ? '25' : '${chauraha.targetNumber}';

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            themeColor.withValues(alpha: 0.35),
            const Color(0xFF0F172A),
          ],
          radius: 0.85,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: themeColor, width: 2.4),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.45),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              centerText,
              style: TextStyle(
                fontSize: chauraha.isBaseFormat ? 28 : 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              chauraha.isBaseFormat ? 'BASE' : 'PRODUCT',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: themeColor,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchPill(ChaurahaBranch branch, Color themeColor, {bool isCompact = false}) {
    return InkWell(
      onTap: () {
        final speakText = branch.isBaseFormat
            ? '25 ${branch.label}'
            : '${branch.label} equals ${branch.product}';
        _speakText(speakText);
        try {
          HapticFeedback.lightImpact();
        } catch (_) {}
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 12,
          vertical: isCompact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              branch.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'monospace',
                letterSpacing: 0.4,
              ),
            ),
            if (branch.badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  branch.badge!,
                  style: TextStyle(fontSize: 8.5, color: themeColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalRoad(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.5,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalRoad(Color color) {
    return Container(
      width: 14,
      height: 3.5,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMathAnchorCard(ProductChaurahaModel chauraha) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.functions_rounded, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text(
                'PRIME FACTORIZATION & ALL EQUIVALENT PAIRS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              chauraha.primeFactorization,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF38BDF8),
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chauraha.allFactorPairs.map((pair) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pair,
                  style: const TextStyle(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExamStrategyCard(ProductChaurahaModel chauraha) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFFBBF24)),
              SizedBox(width: 6),
              Text(
                'TOPPER\'S EXAM APPLICATION',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFFFBBF24), letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            chauraha.examTip,
            style: const TextStyle(fontSize: 12.5, color: Colors.white, height: 1.45, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: 2-ANSWER DRILL (4 Options, Exactly 2 Correct)
  // User MUST select BOTH correct options before advancing!
  // -------------------------------------------------------------
  Widget _buildDualAnswerDrillView() {
    if (_isQuizFinished) {
      return _buildQuizCompletionCard();
    }

    if (_drillQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = _drillQuestions[_currentQuestionIndex];
    final selectedCount = _selectedIndices.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drill Progress & Streak Header
          _buildDrillProgressHeader(),
          const SizedBox(height: 16),

          // Question Card with Prompt & Target
          _buildQuestionPromptCard(question, selectedCount),
          const SizedBox(height: 18),

          // 4 Options Cards (Multi-Select with exactly 2 correct)
          ...List.generate(question.options.length, (idx) {
            return _buildOptionCard(question, idx);
          }),
          const SizedBox(height: 16),

          // Solved Explanation Box (Expands when both correct options are chosen)
          if (_isCurrentQuestionSolved) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'CROSSROADS EXPLANATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question.explanation,
                    style: const TextStyle(fontSize: 12.5, color: Colors.white, height: 1.35, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Next Question Action Button
          // "jb tk dono option click kre to hi aage bde" -> Enabled ONLY when solved!
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCurrentQuestionSolved
                    ? const Color(0xFF10B981)
                    : Colors.white.withValues(alpha: 0.1),
                foregroundColor: _isCurrentQuestionSolved ? Colors.black : Colors.white38,
                elevation: _isCurrentQuestionSolved ? 6 : 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(
                _currentQuestionIndex == _drillQuestions.length - 1
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
                size: 20,
              ),
              label: Text(
                _isCurrentQuestionSolved
                    ? (_currentQuestionIndex == _drillQuestions.length - 1
                        ? 'Finish Drill'
                        : 'Next Question ➔')
                    : 'Select Both Correct Pairs to Advance (2 of 4)',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: _isCurrentQuestionSolved ? Colors.black : Colors.white38,
                ),
              ),
              onPressed: _isCurrentQuestionSolved ? _goToNextQuestion : null,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDrillProgressHeader() {
    final progress = (_currentQuestionIndex + 1) / _drillQuestions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_drillQuestions.length}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak Streak',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFF59E0B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPromptCard(ChaurahaQuestion question, int selectedCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF151D33),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.6)),
                ),
                child: Text(
                  'TARGET: ${question.target}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF06B6D4)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedCount == 2
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedCount == 2 ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                      size: 13,
                      color: selectedCount == 2 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedCount == 0
                          ? 'Select 2 Options'
                          : (selectedCount == 1 ? '1 Selected (1 more!)' : '2 of 2 Selected!'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: selectedCount == 2 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Prompt
          Text(
            question.prompt,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: Colors.white, height: 1.3),
          ),
          const SizedBox(height: 8),

          // Subtitle Guide
          Text(
            _isCurrentQuestionSolved
                ? '✅ Excellent! Both correct pairs selected. Advance to next question.'
                : (selectedCount == 1
                    ? '🎯 1 of 2 Selected! Now tap the 2nd correct pair.'
                    : 'Tap 2 pairs that multiply to give ${question.target}.'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _isCurrentQuestionSolved
                  ? const Color(0xFF10B981)
                  : (selectedCount == 1 ? const Color(0xFF38BDF8) : Colors.white60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(ChaurahaQuestion question, int optionIndex) {
    final optionText = question.options[optionIndex];
    final isSelected = _selectedIndices.contains(optionIndex);
    final isCorrectOption = question.correctIndices.contains(optionIndex);
    final isWrongTapped = _wrongTappedIndex == optionIndex;

    Color borderColor = Colors.white.withValues(alpha: 0.1);
    Color bgColor = const Color(0xFF13192B);
    Color textColor = Colors.white;

    if (isSelected && isCorrectOption) {
      borderColor = const Color(0xFF10B981);
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.18);
      textColor = const Color(0xFF34D399);
    } else if (isWrongTapped) {
      borderColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
      textColor = const Color(0xFFF87171);
    }

    final letters = ['A', 'B', 'C', 'D'];
    final letter = letters[optionIndex];

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final double offset = isWrongTapped ? _shakeAnimation.value : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isCurrentQuestionSolved ? null : () => _handleOptionTap(question, optionIndex),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Option Letter Badge (A, B, C, D)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Option Expression Text (e.g. 12 × 9)
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Selection State Indicator Icon
                  if (isSelected && isCorrectOption)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.black, size: 14),
                    )
                  else if (isWrongTapped)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                    )
                  else
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleOptionTap(ChaurahaQuestion question, int optionIndex) {
    if (_isCurrentQuestionSolved) return;

    final isCorrect = question.correctIndices.contains(optionIndex);

    if (isCorrect) {
      // Toggle or Add
      if (_selectedIndices.contains(optionIndex)) {
        setState(() => _selectedIndices.remove(optionIndex));
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        return;
      }

      setState(() {
        _selectedIndices.add(optionIndex);
        _wrongTappedIndex = null;
      });

      try {
        HapticFeedback.lightImpact();
      } catch (_) {}

      // Check if BOTH correct options are now selected!
      if (_selectedIndices.length == 2 &&
          _selectedIndices.contains(question.correctIndices[0]) &&
          _selectedIndices.contains(question.correctIndices[1])) {
        // SUCCESS: Both options clicked!
        setState(() {
          _isCurrentQuestionSolved = true;
          _score += 10;
          _streak += 1;
          if (_streak > _bestStreak) _bestStreak = _streak;
        });

        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}

        // Auto-advance after 1.4 seconds if user doesn't tap manually
        _autoAdvanceTimer?.cancel();
        _autoAdvanceTimer = Timer(const Duration(milliseconds: 1400), () {
          if (mounted && _isCurrentQuestionSolved) {
            _goToNextQuestion();
          }
        });
      }
    } else {
      // WRONG OPTION TAPPED!
      setState(() {
        _wrongTappedIndex = optionIndex;
        _streak = 0; // Streak reset on mistake
      });

      _shakeController.forward(from: 0.0);

      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}

      // Reset error flash after 900ms
      Timer(const Duration(milliseconds: 900), () {
        if (mounted && _wrongTappedIndex == optionIndex) {
          setState(() => _wrongTappedIndex = null);
        }
      });
    }
  }

  void _goToNextQuestion() {
    _autoAdvanceTimer?.cancel();
    if (_currentQuestionIndex < _drillQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex += 1;
        _selectedIndices.clear();
        _wrongTappedIndex = null;
        _isCurrentQuestionSolved = false;
      });
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    } else {
      setState(() => _isQuizFinished = true);
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  Widget _buildQuizCompletionCard() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF13192B), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF10B981), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Drill Complete!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'You mastered the Product Crossroads Dual-Select Challenge!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // Score & Best Streak Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatBadge('SCORE', '$_score pts', const Color(0xFF38BDF8)),
                const SizedBox(width: 14),
                _buildStatBadge('BEST STREAK', '$_bestStreak 🔥', const Color(0xFFF59E0B)),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons: Play Again or Back to Concept Hub
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _activeTabIndex = 0;
                        _initDrillQuestions();
                      });
                    },
                    child: const Text('Review Concepts', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() => _initDrillQuestions());
                    },
                    child: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF13192B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.alt_route_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('What is Crossroads?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'A "Product Crossroads" represents a high-frequency number that appears as the product of multiple factor pairs across competitive exams (SSC CGL, Banking, CDS).\n\nFor example, 108 is a 4-way intersection:\n• 12 × 9 = 108\n• 18 × 6 = 108\n• 27 × 4 = 108\n• 36 × 3 = 108\n\nInstant recognition of these factor pairs saves 20–30 seconds per question in Simplification, LCM/HCF, Time & Work, and Geometry!',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Got It', style: TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
