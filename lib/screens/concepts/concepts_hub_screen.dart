import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/concept_formula_model.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/concept_formula_repository.dart';
import '../practice/practice_quiz_screen.dart';
import '../../widgets/concept_geometry_painter.dart';
import '../../widgets/math_formula_view.dart';
import 'concept_detail_screen.dart';

class ConceptsHubScreen extends StatefulWidget {
  const ConceptsHubScreen({super.key});

  @override
  State<ConceptsHubScreen> createState() => _ConceptsHubScreenState();
}

class _ConceptsHubScreenState extends State<ConceptsHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  ConceptPillar? _selectedPillar;
  bool _onlyShowStarred = false;
  int _viewMode = 0; // 0 = Detailed Explorer Cards, 1 = Quick Formula Cheat Sheet
  bool _showFlashcard = false;
  int _flashcardIndex = 0;
  bool _flashcardRevealed = false;
  String? _copiedFormulaId;
  final Set<String> _expandedShortcuts = {};

  final List<String> _quickFilterKeywords = [
    'Intercept',
    'Tangent',
    'Apollonius',
    'Trapezium',
    'Frustum',
    'Centroid',
    'Incenter',
    'Cyclic',
    'Chord',
  ];

  @override
  void initState() {
    super.initState();
    // Pick a random initial flashcard
    if (ConceptFormulaRepository.formulas.isNotEmpty) {
      _flashcardIndex = math.Random().nextInt(ConceptFormulaRepository.formulas.length);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getPillarColor(ConceptPillar pillar) {
    switch (pillar) {
      case ConceptPillar.linesAndAngle:
        return const Color(0xFF06B6D4); // Vibrant Cyan
      case ConceptPillar.quadrilaterals:
        return const Color(0xFFF59E0B); // Amber Yellow
      case ConceptPillar.circle:
        return const Color(0xFF10B981); // Emerald Green
      case ConceptPillar.mensuration:
        return const Color(0xFF8B5CF6); // Purple / Violet
      case ConceptPillar.triangles:
        return const Color(0xFFF43F5E); // Rose Coral
    }
  }

  IconData _getPillarIcon(ConceptPillar pillar) {
    switch (pillar) {
      case ConceptPillar.linesAndAngle:
        return Icons.straighten_rounded;
      case ConceptPillar.quadrilaterals:
        return Icons.crop_square_rounded;
      case ConceptPillar.circle:
        return Icons.radio_button_unchecked_rounded;
      case ConceptPillar.mensuration:
        return Icons.view_in_ar_rounded;
      case ConceptPillar.triangles:
        return Icons.change_history_rounded;
    }
  }

  void _copyFormulaText(String id, String formula) {
    Clipboard.setData(ClipboardData(text: formula));
    setState(() => _copiedFormulaId = id);
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            SizedBox(width: 8),
            Text('Formula copied to clipboard! Ready to paste.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && _copiedFormulaId == id) {
        setState(() => _copiedFormulaId = null);
      }
    });
  }

  void _cycleNextFlashcard() {
    final list = ConceptFormulaRepository.formulas;
    if (list.isEmpty) return;
    setState(() {
      _flashcardIndex = (_flashcardIndex + 1) % list.length;
      _flashcardRevealed = false;
    });
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  void _launchPracticeQuiz(ConceptFormulaModel formula) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13192B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.speed_rounded, color: AppTheme.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Speed Drill Mode',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        'Choose timer pacing for exam reflex training',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1525),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(_getPillarIcon(formula.pillar), size: 16, color: _getPillarColor(formula.pillar)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${formula.pillar.ordinalLabel}: ${formula.title} • ${formula.practiceQuestions.length} Questions',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildModalSpeedOption(
                ctx,
                formula,
                title: 'Easy Mode (Untimed)',
                subtitle: 'No Timer • Relaxed concept absorption & review',
                color: const Color(0xFF10B981),
                icon: Icons.spa_rounded,
                perQuestionSeconds: null,
                isTimed: false,
              ),
              const SizedBox(height: 10),
              _buildModalSpeedOption(
                ctx,
                formula,
                title: 'Medium Pace (SSC CGL Standard)',
                subtitle: '10s / Question • Recommended for exam simulation',
                color: const Color(0xFFF59E0B),
                icon: Icons.timer_outlined,
                perQuestionSeconds: 10.0,
                isTimed: true,
              ),
              const SizedBox(height: 10),
              _buildModalSpeedOption(
                ctx,
                formula,
                title: 'Hard Speed (Reflex Blitz)',
                subtitle: '5s / Question • High-pressure mental calculation',
                color: const Color(0xFFEF4444),
                icon: Icons.bolt_rounded,
                perQuestionSeconds: 5.0,
                isTimed: true,
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalSpeedOption(
    BuildContext ctx,
    ConceptFormulaModel formula, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required double? perQuestionSeconds,
    required bool isTimed,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PracticeQuizScreen(
              topic: TopicModel(
                id: formula.id,
                title: formula.title,
                subtitle: '${formula.pillar.ordinalLabel} Drill',
                type: TopicType.addition,
                iconName: formula.pillar.iconName,
              ),
              customQuestions: formula.practiceQuestions,
              isTimed: isTimed,
              perQuestionSeconds: perQuestionSeconds,
              questionCount: formula.practiceQuestions.length,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final query = _searchController.text.trim();

    List<ConceptFormulaModel> items = ConceptFormulaRepository.search(query);

    if (_selectedPillar != null) {
      items = items.where((f) => f.pillar == _selectedPillar).toList();
    }

    if (_onlyShowStarred) {
      items = items.where((f) => state.isFormulaStarred(f.id)).toList();
    }

    final allFormulas = ConceptFormulaRepository.formulas;
    final totalQuestions = allFormulas.fold(0, (sum, f) => sum + f.practiceQuestions.length);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Floating & Snapping App Bar: Slides away when reading, snaps back when scrolling up!
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: const Color(0xFF090D16),
              elevation: 0,
              leading: Navigator.canPop(context)
                  ? IconButton(
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
                    )
                  : null,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.auto_stories_rounded, color: AppTheme.accent, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Concept Hub',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '5 Pillars • 30 Theorems & Exam Formulas',
                    style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              actions: [
                // Flashcard toggle
                IconButton(
                  tooltip: _showFlashcard ? 'Hide Daily Flashcard' : 'Show Daily Flashcard',
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _showFlashcard ? AppTheme.accent.withValues(alpha: 0.2) : Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _showFlashcard ? AppTheme.accent.withValues(alpha: 0.4) : Colors.transparent),
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: _showFlashcard ? AppTheme.accent : Colors.white60,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _showFlashcard = !_showFlashcard);
                  },
                ),
                // Starred concepts filter
                IconButton(
                  tooltip: 'Starred Formulas',
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _onlyShowStarred ? Colors.amber.withValues(alpha: 0.25) : Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _onlyShowStarred ? Colors.amber : Colors.transparent),
                    ),
                    child: Icon(
                      _onlyShowStarred ? Icons.star_rounded : Icons.star_border_rounded,
                      color: _onlyShowStarred ? Colors.amber : Colors.white70,
                      size: 19,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _onlyShowStarred = !_onlyShowStarred);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Top Header Box (Hero, Flashcard, Search, Keywords, Pillar Chips, Results Counter)
            // ALL PART OF THE SCROLL VIEW - Glide smoothly away on swipe!
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Overview Card with Live Stats
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _buildHeroCard(allFormulas.length, totalQuestions, state.starredFormulas.length),
                  ),

                  // 2. Interactive Flashcard (Active Recall Widget)
                  if (_showFlashcard && allFormulas.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _buildFlashcardWidget(allFormulas[_flashcardIndex % allFormulas.length], state),
                    ),

                  // 3. Dual View Mode Selector & Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF13192B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search (e.g. Intercept, Apollonius, Tangent)...',
                                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 18),
                                suffixIcon: query.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 16),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // View Mode Switcher
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13192B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _viewModeButton(
                                icon: Icons.dashboard_rounded,
                                tooltip: 'Explorer Cards',
                                isSelected: _viewMode == 0,
                                onTap: () => setState(() => _viewMode = 0),
                              ),
                              _viewModeButton(
                                icon: Icons.bolt_rounded,
                                tooltip: 'Speed Revision Sheet',
                                isSelected: _viewMode == 1,
                                onTap: () => setState(() => _viewMode = 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Quick Tag Suggestions (when search query is empty)
                  if (query.isEmpty) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        children: _quickFilterKeywords.map((kw) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () {
                                _searchController.text = kw;
                                setState(() {});
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  '#$kw',
                                  style: const TextStyle(fontSize: 10.5, color: Colors.white60, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // 5. Pillars Category Chips (5 Pillars + Saved Filter)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildCategoryChip(
                          label: 'All Topics (${allFormulas.length})',
                          icon: Icons.all_inclusive_rounded,
                          isSelected: _selectedPillar == null && !_onlyShowStarred,
                          onTap: () => setState(() {
                            _selectedPillar = null;
                            _onlyShowStarred = false;
                          }),
                          color: AppTheme.accent,
                        ),
                        ...ConceptPillar.values.map((pillar) {
                          final pillarCount = ConceptFormulaRepository.getByPillar(pillar).length;
                          return _buildCategoryChip(
                            label: '${pillar.ordinalLabel.split(" ")[0]} ${pillar.shortName} ($pillarCount)',
                            icon: _getPillarIcon(pillar),
                            isSelected: _selectedPillar == pillar,
                            onTap: () => setState(() {
                              _selectedPillar = _selectedPillar == pillar ? null : pillar;
                              _onlyShowStarred = false;
                            }),
                            color: _getPillarColor(pillar),
                          );
                        }),
                        _buildCategoryChip(
                          label: '★ Saved (${state.starredFormulas.length})',
                          icon: Icons.bookmark_rounded,
                          isSelected: _onlyShowStarred,
                          onTap: () => setState(() {
                            _onlyShowStarred = !_onlyShowStarred;
                            if (_onlyShowStarred) _selectedPillar = null;
                          }),
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 6. Active results counter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SHOWING ${items.length} ${items.length == 1 ? "CONCEPT" : "CONCEPTS"}${_selectedPillar != null ? " • ${_selectedPillar!.displayName.toUpperCase()}" : ""}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 0.6),
                        ),
                        if (query.isNotEmpty || _selectedPillar != null || _onlyShowStarred)
                          InkWell(
                            onTap: () => setState(() {
                              _searchController.clear();
                              _selectedPillar = null;
                              _onlyShowStarred = false;
                            }),
                            child: const Text(
                              'Clear Filters',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.accent),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),

            // 7. Formula / Concept Cards List (All in the same unified scroll!)
            if (items.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(query),
              )
            else if (_viewMode == 0)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) => _buildDetailedFormulaCard(items[idx], state),
                    childCount: items.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) => _buildCheatSheetFormulaCard(items[idx], state),
                    childCount: items.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(int totalConcepts, int totalQuestions, int savedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
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
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
                ),
                child: const Text(
                  '🏆 SSC CGL · CHSL · RAILWAY · CDS',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: 0.5),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 14, color: AppTheme.gold),
                  SizedBox(width: 4),
                  Text('Speed Formula Engine', style: TextStyle(fontSize: 10, color: AppTheme.gold, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Geometry & Mensuration Mastery Hub',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 3),
          const Text(
            'All theorems, high-res vector figures, shortcuts & speed drills in one place.',
            style: TextStyle(fontSize: 11, color: Colors.white60),
          ),
          const SizedBox(height: 10),
          // 4 Metric Pills
          Row(
            children: [
              _heroStatPill(Icons.account_balance_rounded, '5 Pillars', const Color(0xFF06B6D4)),
              const SizedBox(width: 6),
              _heroStatPill(Icons.functions_rounded, '$totalConcepts Concepts', const Color(0xFFF43F5E)),
              const SizedBox(width: 6),
              _heroStatPill(Icons.bolt_rounded, '$totalQuestions+ MCQs', const Color(0xFF10B981)),
              const SizedBox(width: 6),
              _heroStatPill(Icons.bookmark_rounded, '$savedCount Saved', Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatPill(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardWidget(ConceptFormulaModel formula, AppStateProvider state) {
    final color = _getPillarColor(formula.pillar);
    final isStarred = state.isFormulaStarred(formula.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.psychology_rounded, size: 14, color: color),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'QUICK RECALL FLASHCARD',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 0.8),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: _cycleNextFlashcard,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.casino_rounded, size: 12, color: Colors.white70),
                          SizedBox(width: 4),
                          Text('Next', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => setState(() => _showFlashcard = false),
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${formula.pillar.ordinalLabel} • ${formula.pillar.shortName}',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => state.toggleStarFormula(formula.id),
                child: Icon(
                  isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                  color: isStarred ? Colors.amber : Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formula.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            formula.subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.white60),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          if (!_flashcardRevealed) ...[
            InkWell(
              onTap: () {
                setState(() => _flashcardRevealed = true);
                try {
                  HapticFeedback.lightImpact();
                } catch (_) {}
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_rounded, size: 15, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to Reveal Formula & Pro Shortcut',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Revealed Formula
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0B101D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      formula.formula,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
                    ),
                  ),
                  InkWell(
                    onTap: () => _copyFormulaText(formula.id, formula.formula),
                    child: Icon(
                      _copiedFormulaId == formula.id ? Icons.check_circle_rounded : Icons.copy_rounded,
                      size: 15,
                      color: _copiedFormulaId == formula.id ? const Color(0xFF10B981) : color,
                    ),
                  ),
                ],
              ),
            ),
            if (formula.solvedExamples.isNotEmpty && formula.solvedExamples.first.shortcutTip.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, size: 12, color: Colors.amber),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        formula.solvedExamples.first.shortcutTip,
                        style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 14),
                    label: const Text('Practice Drill', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    onPressed: () => _launchPracticeQuiz(formula),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.menu_book_rounded, size: 13),
                  label: const Text('Read', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ConceptDetailScreen(formula: formula)),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _viewModeButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 17,
            color: isSelected ? AppTheme.accent : Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.22) : const Color(0xFF13192B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: isSelected ? color : Colors.white60),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedFormulaCard(ConceptFormulaModel item, AppStateProvider state) {
    final color = _getPillarColor(item.pillar);
    final isStarred = state.isFormulaStarred(item.id);
    final isCopied = _copiedFormulaId == item.id;
    final isShortcutExpanded = _expandedShortcuts.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ConceptDetailScreen(formula: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Topic Ordinal Badge, Exam tier, and Bookmark Star
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getPillarIcon(item.pillar), size: 12, color: color),
                              const SizedBox(width: 5),
                              Text(
                                '${item.pillar.ordinalLabel.toUpperCase()} • ${item.pillar.shortName.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SSC & CDS',
                            style: TextStyle(fontSize: 9.5, color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isStarred ? Colors.amber : Colors.white38,
                        size: 22,
                      ),
                      onPressed: () {
                        state.toggleStarFormula(item.id);
                        try {
                          HapticFeedback.lightImpact();
                        } catch (_) {}
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 2),

                // Subtitle
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
                ),
                const SizedBox(height: 8),

                // Meta Info Tags (Questions count, Solved walkthroughs count)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _cardMetaTag(Icons.quiz_rounded, '${item.practiceQuestions.length} Drills', AppTheme.accent),
                    _cardMetaTag(Icons.lightbulb_outline_rounded, '${item.solvedExamples.length} Examples', AppTheme.gold),
                    if (item.diagramType != null && item.diagramType != 'none')
                      _cardMetaTag(Icons.polyline_rounded, 'Vector Figure', color),
                  ],
                ),

                // Vector diagram preview (if applicable)
                if (item.diagramType != null && item.diagramType != 'none') ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConceptGeometryVisualizer(
                      diagramType: item.diagramType,
                      themeColor: color,
                      height: 115,
                      showControls: false,
                      margin: EdgeInsets.zero,
                    ),
                  ),
                ],
                const SizedBox(height: 10),

                // Formula Banner Pill with Fractions and Copy Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A),
                        color.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: MathFormulaView(
                            formula: item.formula,
                            formulaId: item.id,
                            fontSize: 12.5,
                            color: Colors.white,
                            accentColor: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _copyFormulaText(item.id, item.formula),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCopied ? const Color(0xFF10B981).withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                                size: 13,
                                color: isCopied ? const Color(0xFF10B981) : color,
                              ),
                              if (isCopied) ...[
                                const SizedBox(width: 4),
                                const Text('Copied', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Inline Shortcut Tip Expansion Dropdown (Clean, No Duplicate Icons)
                if (item.solvedExamples.isNotEmpty && item.solvedExamples.first.shortcutTip.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (_expandedShortcuts.contains(item.id)) {
                          _expandedShortcuts.remove(item.id);
                        } else {
                          _expandedShortcuts.add(item.id);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 15, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isShortcutExpanded ? "Hide Topper's Exam Shortcut" : "Peek Topper's Exam Shortcut",
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                          Icon(
                            isShortcutExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isShortcutExpanded) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1333),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.45)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        item.solvedExamples.first.shortcutTip,
                        style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 12),

                // Action Buttons: Read Concept & Practice Drill
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.menu_book_rounded, size: 14),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Read Concept', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ConceptDetailScreen(formula: item)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 15),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Practice (${item.practiceQuestions.length} Qs)',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                        onPressed: () => _launchPracticeQuiz(item),
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

  Widget _buildCheatSheetFormulaCard(ConceptFormulaModel item, AppStateProvider state) {
    final color = _getPillarColor(item.pillar);
    final isStarred = state.isFormulaStarred(item.id);
    final isCopied = _copiedFormulaId == item.id;
    final shortcut = item.solvedExamples.isNotEmpty ? item.solvedExamples.first.shortcutTip : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ConceptDetailScreen(formula: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.pillar.shortName.toUpperCase(),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => state.toggleStarFormula(item.id),
                          child: Icon(
                            isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 18,
                            color: isStarred ? Colors.amber : Colors.white38,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _copyFormulaText(item.id, item.formula),
                          child: Icon(
                            isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                            size: 16,
                            color: isCopied ? const Color(0xFF10B981) : Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _launchPracticeQuiz(item),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.bolt_rounded, size: 14, color: color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B101D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: MathFormulaView(
                      formula: item.formula,
                      formulaId: item.id,
                      fontSize: 11.5,
                      color: Colors.white,
                      accentColor: color,
                    ),
                  ),
                ),
                if (shortcut.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, size: 11, color: Colors.amber),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shortcut,
                          style: const TextStyle(fontSize: 10.5, color: Colors.white60),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardMetaTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              _onlyShowStarred ? 'No saved formulas yet' : 'No matching concepts found',
              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _onlyShowStarred
                  ? 'Tap the ⭐ icon on any concept card to save it for quick formula revision.'
                  : 'Try searching for Lines, Quads, Circle, Mensuration, Tangent or Triangles.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedPillar = null;
                  _onlyShowStarred = false;
                });
              },
              child: const Text('Reset All Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
