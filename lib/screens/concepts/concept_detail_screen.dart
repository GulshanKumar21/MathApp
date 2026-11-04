import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/concept_formula_model.dart';
import '../../models/math_models.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/concept_geometry_painter.dart';
import '../../widgets/math_formula_view.dart';
import '../practice/practice_quiz_screen.dart';

class ConceptDetailScreen extends StatefulWidget {
  final ConceptFormulaModel formula;

  const ConceptDetailScreen({
    super.key,
    required this.formula,
  });

  @override
  State<ConceptDetailScreen> createState() => _ConceptDetailScreenState();
}

class _ConceptDetailScreenState extends State<ConceptDetailScreen> {
  QuizTimerDifficulty _timerDifficulty = QuizTimerDifficulty.medium;
  final Set<String> _revealedSolutions = {};
  final Set<String> _revealedFigures = {};
  int _viewMode = 0; // 0 = ⚡ Speed Revision (Shortcuts), 1 = 📖 In-Depth Theory (Full)

  Color get _pillarColor {
    switch (widget.formula.pillar) {
      case ConceptPillar.linesAndAngle:
        return const Color(0xFF06B6D4); // Vibrant Cyan
      case ConceptPillar.quadrilaterals:
        return const Color(0xFFF59E0B); // Amber Yellow
      case ConceptPillar.circle:
        return const Color(0xFF10B981); // Emerald Green
      case ConceptPillar.mensuration:
        return const Color(0xFF8B5CF6); // Purple
      case ConceptPillar.triangles:
        return const Color(0xFFF43F5E); // Rose Coral
    }
  }

  void _copyFormula() {
    Clipboard.setData(ClipboardData(text: widget.formula.formula));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Formula copied to clipboard!'),
          ],
        ),
        backgroundColor: _pillarColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _launchPracticeQuiz() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final double? perQuestionSeconds = switch (_timerDifficulty) {
      QuizTimerDifficulty.easy => null,
      QuizTimerDifficulty.medium => 10.0,
      QuizTimerDifficulty.hard => 5.0,
    };
    final bool isTimed = _timerDifficulty != QuizTimerDifficulty.easy;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: widget.formula.id,
            title: widget.formula.title,
            subtitle: '${widget.formula.pillar.displayName} Concept Mastery',
            type: TopicType.addition,
            iconName: widget.formula.pillar.iconName,
          ),
          customQuestions: widget.formula.practiceQuestions,
          isTimed: isTimed,
          perQuestionSeconds: perQuestionSeconds,
          questionCount: widget.formula.practiceQuestions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isStarred = state.isFormulaStarred(widget.formula.id);
    final color = _pillarColor;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.formula.pillar.ordinalLabel}: ${widget.formula.pillar.displayName}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: isStarred ? 'Remove from Saved' : 'Save to Quick Sheet',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isStarred ? Colors.amber.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isStarred ? Colors.amber : Colors.white12),
              ),
              child: Icon(
                isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                color: isStarred ? Colors.amber : Colors.white70,
                size: 20,
              ),
            ),
            onPressed: () {
              state.toggleStarFormula(widget.formula.id);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF13192B),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speed Mode selection row (Responsive & non-overlapping)
              Row(
                children: [
                  const Icon(Icons.speed_rounded, color: Colors.white70, size: 15),
                  const SizedBox(width: 6),
                  const Text(
                    'Speed:',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildSpeedChip(QuizTimerDifficulty.easy, 'Easy', 'No Timer', const Color(0xFF10B981), Icons.spa_rounded)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildSpeedChip(QuizTimerDifficulty.medium, 'Medium', '10s/Q', const Color(0xFFF59E0B), Icons.timer_outlined)),
                        const SizedBox(width: 6),
                        Expanded(child: _buildSpeedChip(QuizTimerDifficulty.hard, 'Hard', '5s/Q', const Color(0xFFEF4444), Icons.bolt_rounded)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Start Drill Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    shadowColor: color.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Start Drill (${widget.formula.practiceQuestions.length} Questions)',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                    ),
                  ),
                  onPressed: _launchPracticeQuiz,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${widget.formula.pillar.ordinalLabel.toUpperCase()} • ${widget.formula.pillar.displayName.toUpperCase()}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.formula.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              widget.formula.subtitle,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 14),

            // Dual-Mode Selector: ⚡ Speed Revision vs 📖 In-Depth Theory
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF13192B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(
                      icon: Icons.bolt_rounded,
                      title: 'Speed Revision',
                      badge: '⚡ SHORTCUTS',
                      isSelected: _viewMode == 0,
                      activeColor: const Color(0xFF10B981),
                      onTap: () {
                        setState(() => _viewMode = 0);
                        try {
                          HapticFeedback.selectionClick();
                        } catch (_) {}
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildModeTab(
                      icon: Icons.menu_book_rounded,
                      title: 'In-Depth Theory',
                      badge: '📖 FULL PROOF',
                      isSelected: _viewMode == 1,
                      activeColor: color,
                      onTap: () {
                        setState(() => _viewMode = 1);
                        try {
                          HapticFeedback.selectionClick();
                        } catch (_) {}
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Render Active Mode
            if (_viewMode == 0)
              _buildSpeedRevisionView(color)
            else
              _buildInDepthTheoryView(color),            const SizedBox(height: 24),

            // Practice Questions Section (8 MCQs from PDF with Shortcuts & PYQs)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EXAM MCQs & SHORTCUTS (${widget.formula.practiceQuestions.length}):',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.2),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  onPressed: () {
                    setState(() {
                      if (_revealedSolutions.length == widget.formula.practiceQuestions.length) {
                        _revealedSolutions.clear();
                      } else {
                        _revealedSolutions.addAll(widget.formula.practiceQuestions.map((q) => q.id));
                      }
                    });
                  },
                  icon: Icon(
                    _revealedSolutions.length == widget.formula.practiceQuestions.length
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 15,
                    color: color,
                  ),
                  label: Text(
                    _revealedSolutions.length == widget.formula.practiceQuestions.length
                        ? 'Hide All'
                        : 'Reveal All',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...widget.formula.practiceQuestions.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              final isRevealed = _revealedSolutions.contains(q.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF13192B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: q.difficulty == 3
                        ? Colors.amber.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Q${idx + 1}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (q.examBadge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: q.difficulty == 3
                                      ? Colors.amber.withValues(alpha: 0.2)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: q.difficulty == 3 ? Colors.amber.withValues(alpha: 0.5) : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  q.examBadge!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: q.difficulty == 3 ? Colors.amber : Colors.white70,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      q.prompt,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white, height: 1.35),
                    ),
                    if (_revealedFigures.contains(q.id) && q.diagramType != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ConceptGeometryVisualizer(
                          diagramType: q.diagramType,
                          themeColor: color,
                          height: 135,
                          showControls: true,
                          margin: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Options grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: q.options.map((opt) {
                        final isCorrect = isRevealed && opt == q.correctAnswer;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : const Color(0xFF0C111F),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCorrect
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCorrect ? FontWeight.w900 : FontWeight.w600,
                              color: isCorrect ? const Color(0xFF10B981) : Colors.white70,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Actions: Show Figure & Toggle Shortcut Solution
                    Row(
                      children: [
                        if (q.diagramType != null) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_revealedFigures.contains(q.id)) {
                                  _revealedFigures.remove(q.id);
                                } else {
                                  _revealedFigures.add(q.id);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _revealedFigures.contains(q.id)
                                    ? color.withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _revealedFigures.contains(q.id)
                                      ? color.withValues(alpha: 0.4)
                                      : Colors.white12,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.polyline_rounded, size: 14, color: color),
                                  const SizedBox(width: 5),
                                  Text(
                                    _revealedFigures.contains(q.id) ? 'Hide Figure' : 'Show Figure',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isRevealed) {
                                _revealedSolutions.remove(q.id);
                              } else {
                                _revealedSolutions.add(q.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isRevealed
                                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isRevealed
                                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                    : Colors.white12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isRevealed ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                                  size: 14,
                                  color: isRevealed ? const Color(0xFF10B981) : Colors.amber,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isRevealed ? 'Hide Shortcut Solution' : 'View Shortcut Solution',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isRevealed ? const Color(0xFF10B981) : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isRevealed && q.explanation.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Answer: ',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                                ),
                                Text(
                                  q.correctAnswer,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              q.explanation,
                              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedChip(
    QuizTimerDifficulty difficulty,
    String label,
    String subtitle,
    Color activeColor,
    IconData icon,
  ) {
    final bool isSelected = _timerDifficulty == difficulty;
    return InkWell(
      onTap: () {
        try {
          HapticFeedback.selectionClick();
        } catch (_) {}
        setState(() => _timerDifficulty = difficulty);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.22) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 1.3 : 1.0,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? activeColor : Colors.white54,
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? activeColor : Colors.white70,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor.withValues(alpha: 0.85) : Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required IconData icon,
    required String title,
    required String badge,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor.withValues(alpha: 0.6) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: isSelected ? activeColor : Colors.white60),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              badge,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isSelected ? activeColor : Colors.white30,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaHeroCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.25),
            const Color(0xFF151D33),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
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
                  Icon(Icons.functions_rounded, color: color, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'EXAM FORMULA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.2),
                  ),
                ],
              ),
              InkWell(
                onTap: _copyFormula,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 13, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('Copy', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: MathFormulaView(
                formula: widget.formula.formula,
                formulaId: widget.formula.id,
                fontSize: 16.0,
                color: Colors.white,
                accentColor: color,
                isHero: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRevisionView(Color color) {
    final firstExample = widget.formula.solvedExamples.isNotEmpty ? widget.formula.solvedExamples.first : null;
    final String shortcutTip = (firstExample != null && firstExample.shortcutTip.isNotEmpty)
        ? firstExample.shortcutTip
        : 'Direct Exam Trick: Apply ${widget.formula.formula} directly without constructing full auxiliary steps!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fast-track Quick Recap Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
          ),
          child: Row(
            children: const [
              Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚡ Fast-Track Revision Mode • Understand Key Shortcuts in 30 Seconds',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 1. Master Formula Hero Card
        _buildFormulaHeroCard(color),
        const SizedBox(height: 16),

        // 2. Direct Exam Shortcut Trick (Topper's 5-Second Solver)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withValues(alpha: 0.18),
                const Color(0xFF13192B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.45), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'DIRECT EXAM SHORTCUT TRICK',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF34D399),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '5-SEC SOLVER',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                shortcutTip,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Quick Memory Anchors (Top 3 Conditions)
        const Text(
          '📌 3-POINT MEMORY ANCHORS (WHEN TO USE):',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13192B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: widget.formula.keyConditions.take(3).map((cond) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded, size: 12, color: color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cond,
                        style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // 4. Rapid Exam Demo (1 Problem, Shortcut Applied)
        if (firstExample != null) ...[
          const Text(
            '⏱️ RAPID EXAM DEMO (SHORTCUT APPLIED):',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF13192B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstExample.problem,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Direct Answer: ${firstExample.answer}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF34D399),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 5. Switch to Full Theory Callout
        InkWell(
          onTap: () {
            setState(() => _viewMode = 1);
            try {
              HapticFeedback.lightImpact();
            } catch (_) {}
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Want full step-by-step vector diagram & derivations?',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      Text(
                        'Tap here to view In-Depth Theory mode',
                        style: TextStyle(fontSize: 10.5, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: color),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInDepthTheoryView(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vector Diagram Visualizer (if applicable)
        if (widget.formula.diagramType != null && widget.formula.diagramType != 'none')
          ConceptGeometryVisualizer(
            diagramType: widget.formula.diagramType,
            themeColor: color,
            showStepByStep: true,
          ),

        // Highlight Formula Hero Card
        _buildFormulaHeroCard(color),
        const SizedBox(height: 20),

        // Concept Explanation & Overview
        const Text(
          'CONCEPT BREAKDOWN:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13192B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            widget.formula.explanation,
            style: const TextStyle(fontSize: 13.5, color: Colors.white70, height: 1.45),
          ),
        ),
        const SizedBox(height: 20),

        // Key Conditions / When to Apply
        const Text(
          'WHEN TO APPLY & KEY RULES:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13192B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: widget.formula.keyConditions.map((cond) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cond,
                        style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Solved Exam-Level Examples
        const Text(
          'EXAM SOLVED WALKTHROUGH:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        ...widget.formula.solvedExamples.map((ex) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: const Text(
                        'EXAM PROBLEM',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  ex.problem,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Step-by-step Solution:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54),
                ),
                const SizedBox(height: 6),
                ...ex.steps.map((st) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(st, style: const TextStyle(fontSize: 12.5, color: Colors.white70)),
                    )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Final Answer: ${ex.answer}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (ex.shortcutTip.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pro Tip: ${ex.shortcutTip}',
                            style: const TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

}
