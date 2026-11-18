import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/english_models.dart';
import '../../data/english_topics_repository.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/swiggy_flipkart_section_bar.dart';
import '../../services/english_tts_service.dart';
import 'english_quiz_screen.dart';
import 'english_learn_concept_screen.dart';
import 'blackbook_master_screen.dart';

class EnglishHubScreen extends StatefulWidget {
  const EnglishHubScreen({super.key});

  @override
  State<EnglishHubScreen> createState() => _EnglishHubScreenState();
}

class _EnglishHubScreenState extends State<EnglishHubScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Grammar',
    'Vocabulary',
    'Fixed Prepositions',
    'Idioms',
    'Word Vaults',
    'Mistakes Notebook',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final allModules = EnglishTopicsRepository.getModules();
    final filteredModules = _filterModules(allModules);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Swiggy/Flipkart 3-Department Top Bar (Math • English • Tricks)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SwiggyFlipkartSectionBar(),
            ),

            // 2. Streamlined Verbal Performance Header
            _buildStatsHeader(state),
            const SizedBox(height: 6),

            // 3. Category Filter Chips (Exact parity with Math Modules Hub)
            _buildCategoryFilterRow(state),
            const SizedBox(height: 6),

            // 4. Main Content Area
            Expanded(
              child: _selectedCategory == 'Mistakes Notebook'
                  ? _buildMistakeNotebookView(state)
                  : _buildTopicModulesList(filteredModules, state),
            ),
          ],
        ),
      ),
    );
  }

  List<EnglishTopicModule> _filterModules(List<EnglishTopicModule> modules) {
    List<EnglishTopicModule> list = modules;
    if (_selectedCategory != 'All' && _selectedCategory != 'Mistakes Notebook') {
      list = list.where((m) => m.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((m) {
        return m.title.toLowerCase().contains(q) ||
            m.subtitle.toLowerCase().contains(q) ||
            m.category.toLowerCase().contains(q) ||
            m.examTag.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  // =========================================================================
  // 1. PERFORMANCE STATS HEADER
  // =========================================================================
  Widget _buildStatsHeader(AppStateProvider state) {
    final int attempted = state.englishQuestionsAttempted;
    final int correct = state.englishQuestionsCorrect;
    final double accuracy = state.englishAccuracy;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4338CA).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'English Verbal Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Topic-Wise Concepts • Rules • MCQs',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statBadge(
                label: '${accuracy.toStringAsFixed(0)}%',
                icon: Icons.track_changes_rounded,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 6),
              _statBadge(
                label: '$correct/$attempted',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF38BDF8),
              ),
              if (state.englishMistakes.isNotEmpty) ...[
                const SizedBox(width: 6),
                _statBadge(
                  label: '${state.englishMistakes.length}',
                  icon: Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge({required String label, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. CATEGORY FILTER ROW (LIKE MATH MODULES HUB)
  // =========================================================================
  Widget _buildCategoryFilterRow(AppStateProvider state) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, idx) {
          final cat = _categories[idx];
          final isSelected = _selectedCategory == cat;
          final int mistakeCount = state.englishMistakes.length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                  if (cat == 'Mistakes Notebook' && mistakeCount > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$mistakeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF4338CA),
              backgroundColor: AppTheme.surfaceElevated,
              side: BorderSide(
                color: isSelected ? const Color(0xFF6366F1) : AppTheme.surfaceLight,
              ),
              onSelected: (val) {
                if (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = cat);
                }
              },
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 3. TOPIC MODULES LIST (MATH PARITY: LEARN BUTTON + PRACTICE QUIZ BUTTON)
  // =========================================================================
  Widget _buildTopicModulesList(List<EnglishTopicModule> modules, AppStateProvider state) {
    return Column(
      children: [
        // Search & Blackbook A-Z Dictionary Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search English topics, rules, vocabulary...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.surfaceLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlackbookMasterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceElevated,
                  foregroundColor: AppTheme.gold,
                  side: const BorderSide(color: AppTheme.gold, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 15),
                label: const Text('A–Z Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),

        // Topic Count Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Topics (${modules.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                ),
              ),
              const Text(
                'Learn Rules ➔ Practice MCQs',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
        ),

        // List of Cards
        Expanded(
          child: modules.isEmpty
              ? Center(
                  child: Text(
                    'No topics found for "$_searchQuery"',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: modules.length,
                  itemBuilder: (ctx, idx) => _buildModuleCard(modules[idx]),
                ),
        ),
      ],
    );
  }

  // =========================================================================
  // 4. UNIFIED TOPIC MODULE CARD (IDENTICAL INTUITIVE UX TO MATH MODULES)
  // =========================================================================
  Widget _buildModuleCard(EnglishTopicModule module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: module.color.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: module.color.withValues(alpha: 0.35)),
                  ),
                  child: Icon(
                    module.icon,
                    color: module.color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: module.color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              module.category.toUpperCase(),
                              style: TextStyle(
                                color: module.color,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${module.questions.length} MCQs',
                            style: TextStyle(
                              color: module.color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        module.subtitle,
                        style: const TextStyle(fontSize: 11.5, color: Colors.white60, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.surfaceLight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // 1. Learn & Rules Button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: module.color.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.menu_book_rounded, size: 16, color: module.color),
                    label: const Text(
                      'Learn & Rules',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnglishLearnConceptScreen(module: module),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Practice Quiz Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: module.color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.black),
                    label: Text(
                      module.questions.length > 25 ? 'Start Quiz (25)' : 'Start Quiz',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                    onPressed: module.questions.isEmpty
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            final sample = List<EnglishExerciseQuestion>.from(module.questions)..shuffle();
                            final qSlice = sample.take(25).toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EnglishQuizScreen(
                                  title: module.title,
                                  subtitle: '${qSlice.length} Topic Practice Questions',
                                  questions: qSlice,
                                ),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. MISTAKES NOTEBOOK VIEW (SAVED WRONG QUESTIONS & RETEST)
  // =========================================================================
  Widget _buildMistakeNotebookView(AppStateProvider state) {
    final mistakes = state.englishMistakes;

    if (mistakes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Zero Mistakes in Notebook!',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Attempt topic quizzes to automatically record incorrect questions here for spaced revision.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Retest All Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1A24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.replay_rounded, color: Color(0xFFEF4444), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${mistakes.length} Saved Mistakes',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Retest until you achieve 100% mastery',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final retestQs = mistakes.map((m) {
                    return EnglishExerciseQuestion(
                      id: m.id,
                      questionText: m.questionText,
                      options: m.options,
                      correctIndex: m.correctIndex,
                      type: 'mistake_retest',
                      explanation: m.explanation,
                    );
                  }).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnglishQuizScreen(
                        title: 'Mistake Retest Arena',
                        subtitle: '${retestQs.length} Incorrect Questions',
                        questions: retestQs,
                        isMistakeRetest: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Retest All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // List of Mistakes
        ...mistakes.map((m) {
          final String correctOptionText =
              m.options.isNotEmpty && m.correctIndex < m.options.length ? m.options[m.correctIndex] : '';
          final String userOptionText =
              m.options.isNotEmpty && m.selectedIndex < m.options.length ? m.options[m.selectedIndex] : '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 6),
                    const Text('Incorrect Attempt', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                      tooltip: 'Remove from Notebook',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        state.removeEnglishMistake(m.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  m.questionText,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Your answer: $userOptionText',
                          style: const TextStyle(color: Color(0xFFF87171), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Correct: $correctOptionText',
                          style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                if (m.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Rule: ${m.explanation}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.35),
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
