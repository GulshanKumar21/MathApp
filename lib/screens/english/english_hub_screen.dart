import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/english_models.dart';
import '../../data/english_content_bank.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/swiggy_flipkart_section_bar.dart';
import '../../services/english_tts_service.dart';
import 'english_quiz_screen.dart';
import 'english_topic_detail_screen.dart';

class EnglishHubScreen extends StatefulWidget {
  const EnglishHubScreen({super.key});

  @override
  State<EnglishHubScreen> createState() => _EnglishHubScreenState();
}

class _EnglishHubScreenState extends State<EnglishHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Vocab Category Filter
  String _vocabSubCategory = 'all'; // 'all', 'ows', 'spelling', 'synonyms', 'antonyms'

  // Grammar Category Filter
  String _grammarSubCategory = 'all'; // 'all', 'errors', 'improvement'

  // Peeked solutions/rules set
  final Set<String> _revealedRules = {};

  // Interactive in-card question answers: questionId -> selectedOptionIndex
  final Map<String, int> _userCardSelections = {};

  // Preposition browse filter
  int _prepositionSetIndex = 0; // 0 = Set 1 (Q151-200), 1 = Set 2 (Q201-250), 2 = All 100
  bool _prepositionShowRulesDirectly = true;

  // Idioms Category Filter
  String _selectedIdiomTheme = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      bottomNavigationBar: _buildEnglishFooter(state),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Swiggy/Flipkart 3-Department Navigation Bar
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SwiggyFlipkartSectionBar(),
            ),

            // 2. Streamlined Verbal Header with Micro Performance Stats
            _buildStatsHeader(state),
            const SizedBox(height: 6),

            // 3. Tab Views (Gets 100% of Screen Space!)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVocabVaultTab(state),
                  _buildGrammarRulesTab(state),
                  _buildFixedPrepositionsTab(state),
                  _buildIdiomsLexiconTab(),
                  _buildMistakeNotebookTab(state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // MODERN FLOATING FOOTER (BOTTOM NAVIGATION BAR)
  // =========================================================================
  Widget _buildEnglishFooter(AppStateProvider state) {
    final int activeIndex = _tabController.index;
    final int mistakeCount = state.englishMistakes.length;

    final items = [
      {'title': 'Vocab', 'icon': Icons.auto_stories_rounded, 'color': const Color(0xFF38BDF8)},
      {'title': 'Grammar', 'icon': Icons.gavel_rounded, 'color': const Color(0xFF818CF8)},
      {'title': 'Prepositions', 'icon': Icons.rule_folder_rounded, 'color': const Color(0xFFFBBF24)},
      {'title': 'Idioms', 'icon': Icons.lightbulb_rounded, 'color': Colors.orangeAccent},
      {'title': 'Notebook', 'icon': Icons.bookmark_added_rounded, 'color': const Color(0xFFEF4444)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final int idx = entry.key;
            final item = entry.value;
            final bool isSelected = activeIndex == idx;
            final Color color = item['color'] as Color;
            final IconData icon = item['icon'] as IconData;
            final String title = item['title'] as String;

            return InkWell(
              onTap: () {
                try {
                  HapticFeedback.selectionClick();
                } catch (_) {}
                _tabController.animateTo(idx);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.16) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          icon,
                          color: isSelected ? color : Colors.white54,
                          size: 20,
                        ),
                        if (idx == 4 && mistakeCount > 0)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: Container(
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
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // =========================================================================
  // STREAMLINED VERBAL HEADER WITH LIVE MICRO-METRICS
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
                  'SSC CGL • CHSL • Banking (350+ MCQs)',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Micro Performance Badges
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
  // TAB 1: VOCAB MASTER (ALL TOPICS, OWS, SPELLING, SYNONYMS, ANTONYMS)
  // =========================================================================
  Widget _buildVocabVaultTab(AppStateProvider state) {
    final allTopics = EnglishContentBank.topics;
    final owsList = EnglishContentBank.allOneWordSubstitution;
    final spellingList = EnglishContentBank.allSpellingQuestions;

    // Collect all standalone synonym and antonym questions across topics
    final allExercises = allTopics.expand((t) => t.exercises).toList();
    final synList = allExercises.where((q) => q.questionText.toUpperCase().contains('SYNONYM')).toList();
    final antList = allExercises.where((q) => q.questionText.toUpperCase().contains('ANTONYM')).toList();

    return Column(
      children: [
        // Vocab Subcategory Filter Pills
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _filterChip('all', '📖 18 Word Vaults (${allTopics.length})', _vocabSubCategory == 'all', (val) => setState(() => _vocabSubCategory = 'all')),
              _filterChip('ows', '💡 One Word Substitution (${owsList.length})', _vocabSubCategory == 'ows', (val) => setState(() => _vocabSubCategory = 'ows')),
              _filterChip('spelling', '✏️ Spelling Test (${spellingList.length})', _vocabSubCategory == 'spelling', (val) => setState(() => _vocabSubCategory = 'spelling')),
              _filterChip('synonyms', '🎯 Synonyms Drill (${synList.length})', _vocabSubCategory == 'synonyms', (val) => setState(() => _vocabSubCategory = 'synonyms')),
              _filterChip('antonyms', '⚖️ Antonyms Drill (${antList.length})', _vocabSubCategory == 'antonyms', (val) => setState(() => _vocabSubCategory = 'antonyms')),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Subcategory View Switcher
        Expanded(
          child: Builder(builder: (context) {
            if (_vocabSubCategory == 'ows') {
              return _buildExerciseList(
                state: state,
                title: 'One Word Substitution (OWS)',
                subtitle: '35 High-Yield SSC Exam Questions (Personalities, Phobias, Government & Science)',
                color: const Color(0xFF10B981),
                icon: Icons.lightbulb_rounded,
                questions: owsList,
              );
            } else if (_vocabSubCategory == 'spelling') {
              return _buildExerciseList(
                state: state,
                title: 'Spelling Correction & Misspelt Words',
                subtitle: '20 Most Confusing Words from SSC CGL & CHSL (Accommodation, Privilege, Occurrence, Millennium)',
                color: const Color(0xFFF59E0B),
                icon: Icons.spellcheck_rounded,
                questions: spellingList,
              );
            } else if (_vocabSubCategory == 'synonyms') {
              return _buildExerciseList(
                state: state,
                title: 'High-Frequency Synonyms Arena',
                subtitle: 'Exam-tested synonym questions from top SSC & Banking papers',
                color: const Color(0xFF06B6D4),
                icon: Icons.check_circle_rounded,
                questions: synList,
              );
            } else if (_vocabSubCategory == 'antonyms') {
              return _buildExerciseList(
                state: state,
                title: 'High-Frequency Antonyms Arena',
                subtitle: 'Exam-tested antonym questions from top SSC & Banking papers',
                color: const Color(0xFFF43F5E),
                icon: Icons.swap_horiz_rounded,
                questions: antList,
              );
            }

            // Default 'all': 18 Word Vault Units
            final filteredTopics = _searchQuery.isEmpty
                ? allTopics
                : allTopics.where((t) {
                    final query = _searchQuery.toLowerCase();
                    return t.word.toLowerCase().contains(query) ||
                        t.partOfSpeech.toLowerCase().contains(query) ||
                        t.rootWord.toLowerCase().contains(query) ||
                        t.synonyms.any((s) => s.toLowerCase().contains(query)) ||
                        t.antonyms.any((a) => a.toLowerCase().contains(query));
                  }).toList();

            return Column(
              children: [
                // Search & Flashcard Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search word, root, synonym, or antonym...',
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
                        onPressed: () => _openFlashcardModal(allTopics),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceElevated,
                          foregroundColor: AppTheme.gold,
                          side: const BorderSide(color: AppTheme.gold, width: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.flip_to_back_rounded, size: 15),
                        label: const Text('Cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredTopics.isEmpty
                      ? Center(
                          child: Text(
                            'No vocabulary found for "$_searchQuery"',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: filteredTopics.length,
                          itemBuilder: (ctx, idx) {
                            final topic = filteredTopics[idx];
                            final isBookmarked = state.isEnglishWordBookmarked(topic.word);
                            return _buildTopicCard(topic, isBookmarked, state);
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 2: GRAMMAR & RULES (SPOTTING ERRORS, SENTENCE IMPROVEMENT, VOICE, NARRATION)
  // =========================================================================
  Widget _buildGrammarRulesTab(AppStateProvider state) {
    final errorsList = EnglishContentBank.allSpottingErrors;
    final improvementList = EnglishContentBank.allSentenceImprovement;
    final allGrammar = EnglishContentBank.allGrammarQuestions;

    List<EnglishExerciseQuestion> activeQuestions = allGrammar;
    if (_grammarSubCategory == 'errors') {
      activeQuestions = errorsList;
    } else if (_grammarSubCategory == 'improvement') {
      activeQuestions = improvementList;
    }

    return Column(
      children: [
        // Grammar Subcategory Pills
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              _filterChip('all', '⚖️ All Grammar (${allGrammar.length})', _grammarSubCategory == 'all', (val) => setState(() => _grammarSubCategory = 'all')),
              _filterChip('errors', '🔍 Spotting Errors (${errorsList.length})', _grammarSubCategory == 'errors', (val) => setState(() => _grammarSubCategory = 'errors')),
              _filterChip('improvement', '🛠️ Sentence Improvement & Voice (${improvementList.length})', _grammarSubCategory == 'improvement', (val) => setState(() => _grammarSubCategory = 'improvement')),
            ],
          ),
        ),
        const SizedBox(height: 6),

        Expanded(
          child: _buildExerciseList(
            state: state,
            title: 'SSC Grammar & Error Spotting Arena',
            subtitle: 'Subject-Verb Agreement, Conditionals, Prepositions, Voice & Narration with Complete Rules',
            color: const Color(0xFF6366F1),
            icon: Icons.gavel_rounded,
            questions: activeQuestions,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseList({
    required AppStateProvider state,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required List<EnglishExerciseQuestion> questions,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      physics: const BouncingScrollPhysics(),
      children: [
        // Hero Launch Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13192B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Colors.white60)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 16),
                  label: Text('START TIMED EXAM DRILL (${questions.length} MCQs)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EnglishQuizScreen(
                          title: title,
                          subtitle: '${questions.length} Exam-grade MCQs',
                          questions: questions,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // List of Interactive Individual Question Cards
        ...questions.asMap().entries.map((entry) {
          final idx = entry.key;
          final q = entry.value;
          return _buildInteractiveQuestionCard(
            idx: idx,
            q: q,
            color: color,
            state: state,
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  // =========================================================================
  // HIGH-END INTERACTIVE QUESTION CARD (INSTANT SELECTION & MISTAKE LOGGING)
  // =========================================================================
  Widget _buildInteractiveQuestionCard({
    required int idx,
    required EnglishExerciseQuestion q,
    required Color color,
    required AppStateProvider state,
  }) {
    final int? selectedOpt = _userCardSelections[q.id];
    final bool hasAnswered = selectedOpt != null;
    final bool isRevealed = _revealedRules.contains(q.id) || hasAnswered;
    final bool isUserCorrect = hasAnswered && selectedOpt == q.correctIndex;

    final optionLabels = ['A', 'B', 'C', 'D'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAnswered
              ? (isUserCorrect ? const Color(0xFF10B981).withValues(alpha: 0.6) : const Color(0xFFEF4444).withValues(alpha: 0.6))
              : AppTheme.surfaceLight,
          width: hasAnswered ? 1.5 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Badge, TTS Speaker, Peek toggle, Reset
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${idx + 1} • ${q.type.toUpperCase()}',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const Spacer(),
              // Audio pronunciation button
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white60, size: 18),
                tooltip: 'Pronounce Question',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  EnglishTtsService().speakWord(q.questionText);
                },
              ),
              const SizedBox(width: 10),
              // Peek / Hide solution toggle
              InkWell(
                onTap: () {
                  setState(() {
                    if (_revealedRules.contains(q.id)) {
                      _revealedRules.remove(q.id);
                    } else {
                      _revealedRules.add(q.id);
                    }
                  });
                },
                child: Text(
                  isRevealed ? 'Hide Solution' : 'Peek Solution →',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isRevealed ? Colors.white54 : color,
                  ),
                ),
              ),
              if (hasAnswered) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _userCardSelections.remove(q.id);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay_rounded, size: 12, color: Colors.white70),
                        SizedBox(width: 3),
                        Text('Retry', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Question Prompt
          Text(
            q.questionText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // 4 Interactive Option Tiles
          ...q.options.asMap().entries.map((optEntry) {
            final optIdx = optEntry.key;
            final optText = optEntry.value;
            final label = optIdx < optionLabels.length ? optionLabels[optIdx] : '${optIdx + 1}';

            return _buildInCardOptionTile(
              label: label,
              text: optText,
              optIdx: optIdx,
              correctIndex: q.correctIndex,
              userSelectedIndex: selectedOpt,
              isRevealed: isRevealed,
              onTap: () {
                final bool isCorrect = optIdx == q.correctIndex;
                setState(() {
                  _userCardSelections[q.id] = optIdx;
                });
                if (isCorrect) {
                  HapticFeedback.lightImpact();
                  state.recordEnglishAnswer(
                    isCorrect: true,
                    questionId: q.id,
                    questionText: q.questionText,
                    options: q.options,
                    correctIndex: q.correctIndex,
                    selectedIndex: optIdx,
                    explanation: q.explanation,
                  );
                } else {
                  HapticFeedback.heavyImpact();
                  state.recordEnglishAnswer(
                    isCorrect: false,
                    questionId: q.id,
                    questionText: q.questionText,
                    options: q.options,
                    correctIndex: q.correctIndex,
                    selectedIndex: optIdx,
                    explanation: q.explanation,
                  );
                }
              },
            );
          }),

          // Solution & Grammar Rule Box (Auto-appears on select or peek)
          if (isRevealed && q.explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, size: 14, color: AppTheme.gold),
                      const SizedBox(width: 6),
                      Text(
                        hasAnswered
                            ? (isUserCorrect ? '✓ Correct! Exam Rule & Etymology:' : '✗ Incorrect! Exam Rule & Solution:')
                            : 'Exam Rule & Etymology:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: hasAnswered
                              ? (isUserCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              : AppTheme.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.explanation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // REUSABLE IN-CARD OPTION TILE WITH SATISFYING SELECTION ANIMATION
  // =========================================================================
  Widget _buildInCardOptionTile({
    required String label,
    required String text,
    required int optIdx,
    required int correctIndex,
    required int? userSelectedIndex,
    required bool isRevealed,
    required VoidCallback onTap,
  }) {
    final bool hasAnswered = userSelectedIndex != null;
    final bool isUserChoice = userSelectedIndex == optIdx;
    final bool isCorrect = optIdx == correctIndex;

    Color borderColor = Colors.white12;
    Color bgColor = const Color(0xFF0F172A);
    Color textColor = Colors.white70;
    Color badgeBg = const Color(0xFF1E293B);
    Color badgeText = Colors.white60;
    Widget? statusIcon;

    if (hasAnswered) {
      if (isCorrect) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.16);
        textColor = const Color(0xFF34D399);
        badgeBg = const Color(0xFF10B981);
        badgeText = Colors.white;
        statusIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16);
      } else if (isUserChoice) {
        borderColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.16);
        textColor = const Color(0xFFF87171);
        badgeBg = const Color(0xFFEF4444);
        badgeText = Colors.white;
        statusIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 16);
      } else {
        textColor = Colors.white38;
        badgeText = Colors.white24;
      }
    } else if (isRevealed) {
      if (isCorrect) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.16);
        textColor = const Color(0xFF34D399);
        badgeBg = const Color(0xFF10B981);
        badgeText = Colors.white;
        statusIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: (hasAnswered && (isCorrect || isUserChoice)) ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: badgeText,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: (hasAnswered && isCorrect) ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (statusIcon != null) statusIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // MODERNIZED WORD VAULT TOPIC CARD
  // =========================================================================
  Widget _buildTopicCard(EnglishWordTopic topic, bool isBookmarked, AppStateProvider state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EnglishTopicDetailScreen(topic: topic)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${topic.id} • ${topic.partOfSpeech.toUpperCase()}',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.volume_up_rounded, color: AppTheme.cyan, size: 20),
                      tooltip: 'Pronounce',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        EnglishTtsService().speakWord(topic.word);
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? AppTheme.gold : Colors.white38,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        state.toggleEnglishBookmark(topic.word);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Main Headword
                Row(
                  children: [
                    Text(
                      topic.word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (topic.rootWord.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${topic.rootWord})',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Meaning Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    topic.displayTitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                ),
                const SizedBox(height: 10),

                // Synonyms & Antonyms Preview Chips
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          '✓ Syn: ${topic.synonyms.take(2).join(", ")}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          '✗ Ant: ${topic.antonyms.take(2).join(", ")}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 1-Tap Launch Quiz Drill Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 16),
                    label: Text(
                      'Practice ${topic.exercises.length} MCQs →',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnglishQuizScreen(
                            title: '${topic.word} Drill',
                            subtitle: '${topic.exercises.length} Exam-grade MCQs',
                            questions: topic.exercises,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // INTERACTIVE FIXED PREPOSITION CARD
  // =========================================================================
  Widget _buildPrepositionCard(FixedPrepositionQuestion q, AppStateProvider state) {
    final qId = 'prep_${q.number}';
    final int? selectedOpt = _userCardSelections[qId];
    final bool hasAnswered = selectedOpt != null;
    final bool isUserCorrect = hasAnswered && selectedOpt == q.correctIndex;
    final bool isRevealed = _revealedRules.contains(qId) || hasAnswered;

    final optionLabels = ['A', 'B', 'C', 'D'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAnswered
              ? (isUserCorrect ? const Color(0xFF10B981).withValues(alpha: 0.6) : const Color(0xFFEF4444).withValues(alpha: 0.6))
              : AppTheme.surfaceLight,
          width: hasAnswered ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${q.number} • PREPOSITION',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              // Audio speaker
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white60, size: 18),
                tooltip: 'Pronounce Sentence',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  EnglishTtsService().speakWord(q.sentence);
                },
              ),
              const SizedBox(width: 10),
              // Peek rule
              InkWell(
                onTap: () {
                  setState(() {
                    if (_revealedRules.contains(qId)) {
                      _revealedRules.remove(qId);
                    } else {
                      _revealedRules.add(qId);
                    }
                  });
                },
                child: Text(
                  isRevealed ? 'Hide Rule' : 'Peek Rule →',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isRevealed ? Colors.white54 : const Color(0xFFF59E0B),
                  ),
                ),
              ),
              if (hasAnswered) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _userCardSelections.remove(qId);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay_rounded, size: 12, color: Colors.white70),
                        SizedBox(width: 3),
                        Text('Retry', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Sentence with Blank
          Text(
            q.sentence,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Interactive 4 Options
          ...q.options.asMap().entries.map((e) {
            final optIdx = e.key;
            final optText = e.value;
            final label = optIdx < optionLabels.length ? optionLabels[optIdx] : '${optIdx + 1}';

            return _buildInCardOptionTile(
              label: label,
              text: optText,
              optIdx: optIdx,
              correctIndex: q.correctIndex,
              userSelectedIndex: selectedOpt,
              isRevealed: isRevealed,
              onTap: () {
                final bool isCorrect = optIdx == q.correctIndex;
                setState(() {
                  _userCardSelections[qId] = optIdx;
                });
                if (isCorrect) {
                  HapticFeedback.lightImpact();
                  state.recordEnglishAnswer(
                    isCorrect: true,
                    questionId: qId,
                    questionText: q.sentence,
                    options: q.options,
                    correctIndex: q.correctIndex,
                    selectedIndex: optIdx,
                    explanation: q.rule,
                  );
                } else {
                  HapticFeedback.heavyImpact();
                  state.recordEnglishAnswer(
                    isCorrect: false,
                    questionId: qId,
                    questionText: q.sentence,
                    options: q.options,
                    correctIndex: q.correctIndex,
                    selectedIndex: optIdx,
                    explanation: q.rule,
                  );
                }
              },
            );
          }),

          // Preposition Rule Card
          if (isRevealed && q.rule.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rule_rounded, size: 16, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasAnswered
                              ? (isUserCorrect ? '✓ Correct! Preposition Rule:' : '✗ Incorrect! Fixed Preposition Rule:')
                              : 'Fixed Preposition Rule:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: hasAnswered
                                ? (isUserCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                : const Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          q.rule,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _filterChip(String id, String label, bool isSelected, Function(bool) onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSecondary,
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        selectedColor: AppTheme.primaryLight,
        backgroundColor: AppTheme.surface,
        showCheckmark: false,
        side: BorderSide(color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight),
        onSelected: onSelected,
      ),
    );
  }

  Widget _buildFixedPrepositionsTab(AppStateProvider state) {
    final allList = EnglishContentBank.fixedPrepositions;
    List<FixedPrepositionQuestion> displayedList;
    if (_prepositionSetIndex == 0) {
      displayedList = allList.take(50).toList();
    } else if (_prepositionSetIndex == 1) {
      displayedList = allList.skip(50).take(50).toList();
    } else {
      displayedList = allList;
    }

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPrepositionSetChip(0, 'Set 1 (Q1-50)'),
                const SizedBox(width: 8),
                _buildPrepositionSetChip(1, 'Set 2 (Q51-100)'),
                const SizedBox(width: 8),
                _buildPrepositionSetChip(2, 'All 100 Prepositions'),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: displayedList.length,
            itemBuilder: (context, index) {
              return _buildPrepositionCard(displayedList[index], state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrepositionSetChip(int index, String label) {
    final isSelected = _prepositionSetIndex == index;
    return InkWell(
      onTap: () => setState(() => _prepositionSetIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B).withValues(alpha: 0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : AppTheme.surfaceLight,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFF59E0B) : AppTheme.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 4: THEMATIC IDIOMS (LEXICON & EXAM DRILLS)
  // =========================================================================
  Widget _buildIdiomsLexiconTab() {
    final allGroups = EnglishContentBank.thematicIdioms;
    final themes = ['All', ...allGroups.map((g) => g.theme)];
    final idiomQuestions = EnglishContentBank.allIdiomQuestions;

    final filteredGroups = _selectedIdiomTheme == 'All'
        ? allGroups
        : allGroups.where((g) => g.theme == _selectedIdiomTheme).toList();

    return Column(
      children: [
        // Top Hero Launch Banner for Idiom Exam Drills
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF13192B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Colors.orangeAccent, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Idioms Exam Arena', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                      Text('30 Real SSC MCQs + 40 Thematic Grouped Idioms', style: TextStyle(fontSize: 10.5, color: Colors.white60)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 15),
                  label: const Text('Quiz Drill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EnglishQuizScreen(
                          title: 'Idioms & Phrases Exam Drill',
                          subtitle: '20 High-Yield SSC Questions',
                          questions: idiomQuestions,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Category Filter Chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: themes.length,
            itemBuilder: (ctx, idx) {
              final theme = themes[idx];
              final isSelected = _selectedIdiomTheme == theme;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(theme),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selectedColor: AppTheme.primaryLight,
                  backgroundColor: AppTheme.surface,
                  side: BorderSide(color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight),
                  onSelected: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedIdiomTheme = theme);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Thematic Idioms List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: filteredGroups.length,
            itemBuilder: (ctx, gIdx) {
              final group = filteredGroups[gIdx];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceLight, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology_rounded, color: AppTheme.gold, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            group.theme.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${group.idioms.length} IDIOMS',
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: group.idioms.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => EnglishTtsService().speakWord(item.idiom),
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.volume_up_rounded, size: 16, color: AppTheme.cyan),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.idiom,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.meaning,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11.5,
                                          height: 1.3,
                                        ),
                                      ),
                                      if (item.example.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'e.g. ${item.example}',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 10.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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

  // =========================================================================
  // TAB 5: MISTAKE NOTEBOOK (RETEST FAILED QUESTIONS)
  // =========================================================================
  Widget _buildMistakeNotebookTab(AppStateProvider state) {
    final mistakes = state.englishMistakes;

    if (mistakes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 48),
              SizedBox(height: 12),
              Text(
                'Zero Mistakes Logged!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Every missed question during verbal practice drills automatically enters this notebook for smart revision.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mistakes.length} VERBAL QUESTIONS NEED REVISION',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.replay_rounded, size: 14),
                label: const Text('Retest All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final retestQuestions = mistakes.map((m) {
                    return EnglishExerciseQuestion(
                      id: m.id,
                      questionText: m.questionText,
                      options: m.options,
                      correctIndex: m.correctIndex,
                      explanation: m.explanation,
                    );
                  }).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnglishQuizScreen(
                        title: 'Mistakes Retest Drill',
                        subtitle: '${retestQuestions.length} Questions from Notebook',
                        questions: retestQuestions,
                        isMistakeRetest: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: mistakes.length,
            itemBuilder: (ctx, idx) {
              final m = mistakes[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.questionText,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Correct Answer: ${m.options.isNotEmpty && m.correctIndex < m.options.length ? m.options[m.correctIndex] : ""}',
                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    if (m.explanation.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          m.explanation,
                          style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                        ),
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

  // Flashcard Modal
  void _openFlashcardModal(List<EnglishWordTopic> topics) {
    if (topics.isEmpty) return;
    int currentIndex = 0;
    bool isFlipped = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dCtx, setDlgState) {
            final topic = topics[currentIndex];
            return AlertDialog(
              backgroundColor: const Color(0xFF13192B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card ${currentIndex + 1} of ${topics.length}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white54),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => setDlgState(() => isFlipped = !isFlipped),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFlipped
                              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                              : [const Color(0xFF1E1B4B), const Color(0xFF312E81)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: isFlipped ? _buildCardBack(topic) : _buildCardFront(topic),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                        onPressed: currentIndex > 0
                            ? () => setDlgState(() {
                                  currentIndex--;
                                  isFlipped = false;
                                })
                            : null,
                        child: const Text('Previous', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryLight),
                        onPressed: currentIndex < topics.length - 1
                            ? () => setDlgState(() {
                                  currentIndex++;
                                  isFlipped = false;
                                })
                            : null,
                        child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 11)),
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

  Widget _buildCardFront(EnglishWordTopic topic) {
    return Column(
      children: [
        Text(
          topic.word,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          topic.partOfSpeech.toUpperCase(),
          style: const TextStyle(color: AppTheme.primaryLight, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        if (topic.rootWord.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Root: ${topic.rootWord}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.gold, fontSize: 11),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Tap to flip & see Synonyms / Antonyms',
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildCardBack(EnglishWordTopic topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SYNONYMS:', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
        Text(topic.synonyms.take(6).join(', '), style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 10),
        const Text('ANTONYMS:', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
        Text(topic.antonyms.take(6).join(', '), style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
