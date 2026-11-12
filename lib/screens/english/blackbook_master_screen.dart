import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/english_models.dart';
import '../../services/vocab_dictionary_service.dart';
import '../../providers/app_state_provider.dart';
import '../../services/english_tts_service.dart';
import 'english_quiz_screen.dart';

typedef BlackbookMasterScreen = VocabDictionaryScreen;

class VocabDictionaryScreen extends StatefulWidget {
  final int initialTabIndex;
  const VocabDictionaryScreen({super.key, this.initialTabIndex = 0});

  @override
  State<VocabDictionaryScreen> createState() => _VocabDictionaryScreenState();
}

class _VocabDictionaryScreenState extends State<VocabDictionaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final VocabDictionaryService _dict = VocabDictionaryService();

  String _searchQuery = '';
  String _selectedLetter = 'ALL';
  String _boosterFilter = 'ALL';
  String _quizTopicFilter = 'ssc_ows';
  bool _sortByFrequency = false; // Default: true Dictionary Order (A -> AA -> AB -> ... -> Z)
  bool _hideMeaningsForTest = false;
  bool _bookmarkedOnly = false;
  bool _isLoadingData = false;

  final Set<String> _revealedItems = {};
  final Map<String, int> _userQuizAnswers = {};

  static const List<String> _alphabet = [
    'ALL', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 8,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 7),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _initDictionaryData();
  }

  Future<void> _initDictionaryData() async {
    if (!_dict.isLoaded) {
      setState(() => _isLoadingData = true);
      await _dict.ensureLoaded();
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _speak(String text) {
    EnglishTtsService().speakWord(text);
  }

  int get _totalDictionaryEntries =>
      _dict.ows.length +
      _dict.idioms.length +
      _dict.synAnt.length +
      _dict.homonyms.length +
      _dict.spellings.length +
      _dict.boosters.length +
      _dict.roots.length;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            _buildSearchBarAndControls(),
            if (_tabController.index < 6) _buildAlphabetIndexStrip(),
            _buildTabSelector(),
            Expanded(
              child: _isLoadingData
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF10B981)),
                          SizedBox(height: 14),
                          Text(
                            'Loading A–Z Vocabulary Dictionary...',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOwsTab(state),
                        _buildIdiomsTab(state),
                        _buildSynAntTab(state),
                        _buildHomonymsTab(state),
                        _buildSpellingsTab(state),
                        _buildBoostersTab(state),
                        _buildRootWordsTab(),
                        _buildQuizTab(state),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 1. TOP APP BAR (100% PREPVANTA BRANDING, ZERO BOOK NAME)
  // =========================================================================
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          const SizedBox(width: 2),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Vocab Dictionary',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '$_totalDictionaryEntries+ A–Z',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'PrepVanta Lexicon • SSC, Banking, Railway & Defence',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Bookmarks filter toggle
          IconButton(
            tooltip: _bookmarkedOnly ? 'Show All Words' : 'Show Bookmarked Only',
            icon: Icon(
              _bookmarkedOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _bookmarkedOnly ? const Color(0xFFFBBF24) : Colors.white60,
              size: 21,
            ),
            onPressed: () {
              setState(() => _bookmarkedOnly = !_bookmarkedOnly);
              HapticFeedback.selectionClick();
            },
          ),
          // Recall Mode Toggle
          IconButton(
            tooltip: _hideMeaningsForTest ? 'Exit Recall Mode' : 'Recall Mode (Hide Meanings)',
            icon: Icon(
              _hideMeaningsForTest ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: _hideMeaningsForTest ? const Color(0xFFEF4444) : Colors.white60,
              size: 21,
            ),
            onPressed: () {
              setState(() {
                _hideMeaningsForTest = !_hideMeaningsForTest;
                _revealedItems.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_hideMeaningsForTest
                      ? '🧠 Recall Mode ON: Tap cards to reveal word & Hindi!'
                      : '📖 Dictionary Mode ON: All meanings visible.'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF1E293B),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. SEARCH BAR & DICTIONARY A-Z / #R SORT TOGGLE
  // =========================================================================
  Widget _buildSearchBarAndControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      color: const Color(0xFF0F172A),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search prefix (a, aa, ab...) or Hindi meaning...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() => _sortByFrequency = !_sortByFrequency);
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: !_sortByFrequency
                    ? const Color(0xFF10B981).withValues(alpha: 0.16)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: !_sortByFrequency
                      ? const Color(0xFF10B981).withValues(alpha: 0.55)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _sortByFrequency ? Icons.trending_up_rounded : Icons.sort_by_alpha_rounded,
                    size: 16,
                    color: !_sortByFrequency ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortByFrequency ? '#R Rank' : 'A–Z Dict',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: !_sortByFrequency ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
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

  // =========================================================================
  // 2b. DICTIONARY A-Z QUICK JUMP STRIP
  // =========================================================================
  Widget _buildAlphabetIndexStrip() {
    return Container(
      height: 36,
      color: const Color(0xFF0F172A),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        itemCount: _alphabet.length,
        itemBuilder: (context, index) {
          final letter = _alphabet[index];
          final bool isSelected = _selectedLetter == letter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: InkWell(
              onTap: () {
                setState(() => _selectedLetter = letter);
                HapticFeedback.selectionClick();
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(horizontal: letter == 'ALL' ? 10 : 8, vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF34D399) : Colors.white12,
                  ),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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

  // =========================================================================
  // 3. TAB SELECTOR PILLS (ALL 8 SECTIONS)
  // =========================================================================
  Widget _buildTabSelector() {
    final tabs = [
      {'title': 'OWS (${_dict.ows.length})', 'icon': Icons.lightbulb_rounded, 'color': const Color(0xFF10B981)},
      {'title': 'Idioms (${_dict.idioms.length})', 'icon': Icons.palette_rounded, 'color': const Color(0xFFF59E0B)},
      {'title': 'Syn & Ant (${_dict.synAnt.length})', 'icon': Icons.compare_arrows_rounded, 'color': const Color(0xFF06B6D4)},
      {'title': 'Homonyms (${_dict.homonyms.length})', 'icon': Icons.splitscreen_rounded, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Spellings (${_dict.spellings.length})', 'icon': Icons.spellcheck_rounded, 'color': const Color(0xFFEC4899)},
      {'title': 'Boosters (${_dict.boosters.length})', 'icon': Icons.auto_awesome_rounded, 'color': const Color(0xFF38BDF8)},
      {'title': 'Roots & Lists', 'icon': Icons.account_tree_rounded, 'color': const Color(0xFF14B8A6)},
      {'title': 'Exam Quiz', 'icon': Icons.quiz_rounded, 'color': const Color(0xFF6366F1)},
    ];

    return Container(
      height: 44,
      color: const Color(0xFF0F172A),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final bool isSelected = _tabController.index == index;
          final Color color = tab['color'] as Color;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                _tabController.animateTo(index);
                HapticFeedback.selectionClick();
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.white12,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(tab['icon'] as IconData, size: 14, color: isSelected ? color : Colors.white54),
                    const SizedBox(width: 5),
                    Text(
                      tab['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLetterDivider(String letter, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: Text(
              letter,
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: accent.withValues(alpha: 0.22), thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _bookmarkButton(AppStateProvider state, String word) {
    final isSaved = state.isEnglishWordBookmarked(word);
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
        color: isSaved ? const Color(0xFFFBBF24) : Colors.white38,
        size: 19,
      ),
      onPressed: () {
        state.toggleEnglishBookmark(word);
        HapticFeedback.selectionClick();
      },
      tooltip: isSaved ? 'Remove Bookmark' : 'Bookmark Word',
    );
  }

  // =========================================================================
  // TAB 1: ONE WORD SUBSTITUTION (A -> AA -> AB -> Z DICTIONARY)
  // =========================================================================
  Widget _buildOwsTab(AppStateProvider state) {
    var source = _dict.ows;
    if (_bookmarkedOnly) {
      source = source.where((item) => state.isEnglishWordBookmarked(item.word)).toList();
    }

    final items = VocabDictionaryService.filterAndRankDictionary<BlackbookOwsItem>(
      items: source,
      query: _searchQuery,
      letterFilter: _selectedLetter,
      sortByFrequency: _sortByFrequency,
      getHeadword: (item) => item.word,
      getRepetition: (item) => item.repetitionCount,
      matchesSecondary: (item, q) =>
          item.phrase.toLowerCase().contains(q) ||
          item.hindiMeaning.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q),
    );

    if (items.isEmpty) return _buildEmptyState();

    final bool showHeaders = !_sortByFrequency && _searchQuery.isEmpty;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final letter = VocabDictionaryService.startingLetter(item.word);
        final prevLetter = index > 0 ? VocabDictionaryService.startingLetter(items[index - 1].word) : '';
        final bool needHeader = showHeaders && (index == 0 || letter != prevLetter);

        final keyId = 'ows_${item.id}';
        final isRevealed = !_hideMeaningsForTest || _revealedItems.contains(keyId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needHeader) _buildLetterDivider(letter, const Color(0xFF10B981)),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: InkWell(
                onTap: () {
                  if (_hideMeaningsForTest) {
                    setState(() {
                      if (_revealedItems.contains(keyId)) {
                        _revealedItems.remove(keyId);
                      } else {
                        _revealedItems.add(keyId);
                      }
                    });
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#R: ${item.repetitionCount}x',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.partOfSpeech,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (item.isSpellingTrap) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                '* Spelling',
                                style: TextStyle(color: Color(0xFFF472B6), fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          const Spacer(),
                          _bookmarkButton(state, item.word),
                          const SizedBox(width: 10),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 19),
                            onPressed: () => _speak(item.word),
                            tooltip: 'Pronounce',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isRevealed) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                item.word,
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (item.hindiMeaning.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.hindiMeaning,
                                  style: const TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_rounded, size: 15, color: Colors.white54),
                              SizedBox(width: 6),
                              Text(
                                'Tap to Reveal Word & Hindi',
                                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        item.phrase,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // TAB 2: IDIOMS, PHRASES & PROVERBS (A -> Z DICTIONARY)
  // =========================================================================
  Widget _buildIdiomsTab(AppStateProvider state) {
    var source = _dict.idioms;
    if (_bookmarkedOnly) {
      source = source.where((item) => state.isEnglishWordBookmarked(item.idiom)).toList();
    }

    final items = VocabDictionaryService.filterAndRankDictionary<BlackbookIdiomItem>(
      items: source,
      query: _searchQuery,
      letterFilter: _selectedLetter,
      sortByFrequency: _sortByFrequency,
      getHeadword: (item) => item.idiom,
      getRepetition: (item) => item.repetitionCount,
      matchesSecondary: (item, q) =>
          item.englishMeaning.toLowerCase().contains(q) ||
          item.hindiMeaning.toLowerCase().contains(q),
    );

    if (items.isEmpty) return _buildEmptyState();

    final bool showHeaders = !_sortByFrequency && _searchQuery.isEmpty;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final letter = VocabDictionaryService.startingLetter(item.idiom);
        final prevLetter = index > 0 ? VocabDictionaryService.startingLetter(items[index - 1].idiom) : '';
        final bool needHeader = showHeaders && (index == 0 || letter != prevLetter);

        final keyId = 'idiom_${item.id}';
        final isRevealed = !_hideMeaningsForTest || _revealedItems.contains(keyId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needHeader) _buildLetterDivider(letter, const Color(0xFFF59E0B)),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: InkWell(
                onTap: () {
                  if (_hideMeaningsForTest) {
                    setState(() {
                      if (_revealedItems.contains(keyId)) {
                        _revealedItems.remove(keyId);
                      } else {
                        _revealedItems.add(keyId);
                      }
                    });
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '#R: ${item.repetitionCount}x',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.idiom,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _bookmarkButton(state, item.idiom),
                          const SizedBox(width: 10),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 19),
                            onPressed: () => _speak(item.idiom),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isRevealed) ...[
                        if (item.hindiMeaning.isNotEmpty) ...[
                          Text(
                            item.hindiMeaning,
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          item.englishMeaning,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                        if (item.example.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Eg: ', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    item.example,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Tap to Reveal Meaning & Hindi', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // TAB 3: DUAL SYNONYMS & ANTONYMS MATRIX (A -> Z DICTIONARY)
  // =========================================================================
  Widget _buildSynAntTab(AppStateProvider state) {
    var source = _dict.synAnt;
    if (_bookmarkedOnly) {
      source = source.where((item) => state.isEnglishWordBookmarked(item.word)).toList();
    }

    final items = VocabDictionaryService.filterAndRankDictionary<BlackbookSynAntItem>(
      items: source,
      query: _searchQuery,
      letterFilter: _selectedLetter,
      sortByFrequency: _sortByFrequency,
      getHeadword: (item) => item.word,
      getRepetition: (item) => item.repetitionCount,
      matchesSecondary: (item, q) =>
          item.hindiMeaning.toLowerCase().contains(q) ||
          item.definition.toLowerCase().contains(q) ||
          item.synonyms.any((s) => s.toLowerCase().contains(q)) ||
          item.antonyms.any((a) => a.toLowerCase().contains(q)),
    );

    if (items.isEmpty) return _buildEmptyState();

    final bool showHeaders = !_sortByFrequency && _searchQuery.isEmpty;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final letter = VocabDictionaryService.startingLetter(item.word);
        final prevLetter = index > 0 ? VocabDictionaryService.startingLetter(items[index - 1].word) : '';
        final bool needHeader = showHeaders && (index == 0 || letter != prevLetter);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needHeader) _buildLetterDivider(letter, const Color(0xFF06B6D4)),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#R: ${item.repetitionCount}x',
                          style: const TextStyle(
                            color: Color(0xFF22D3EE),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item.word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('(${item.partOfSpeech})', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      const Spacer(),
                      _bookmarkButton(state, item.word),
                      const SizedBox(width: 10),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 19),
                        onPressed: () => _speak(item.word),
                      ),
                    ],
                  ),
                  if (item.definition.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.definition, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                  if (item.hindiMeaning.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.hindiMeaning,
                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (item.synonyms.isNotEmpty || item.antonyms.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          if (item.synonyms.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text('SYN', style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.w900)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: item.synonyms
                                        .map((s) => Text(s, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w500)))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          if (item.synonyms.isNotEmpty && item.antonyms.isNotEmpty)
                            const Divider(color: Colors.white12, height: 14),
                          if (item.antonyms.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text('ANT', style: TextStyle(color: Color(0xFFF87171), fontSize: 9.5, fontWeight: FontWeight.w900)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: item.antonyms
                                        .map((a) => Text(a, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w500)))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // TAB 4: CONFUSING HOMONYMS & PAIRS (A -> Z DICTIONARY)
  // =========================================================================
  Widget _buildHomonymsTab(AppStateProvider state) {
    var source = _dict.homonyms;
    if (_bookmarkedOnly) {
      source = source.where((item) => state.isEnglishWordBookmarked(item.word1)).toList();
    }

    final items = VocabDictionaryService.filterAndRankDictionary<BlackbookHomonymPair>(
      items: source,
      query: _searchQuery,
      letterFilter: _selectedLetter,
      sortByFrequency: _sortByFrequency,
      getHeadword: (item) => item.word1,
      getRepetition: (item) => item.repetitionCount,
      matchesSecondary: (item, q) =>
          item.word2.toLowerCase().contains(q) ||
          item.hindi1.toLowerCase().contains(q) ||
          item.hindi2.toLowerCase().contains(q) ||
          item.meaning1.toLowerCase().contains(q) ||
          item.meaning2.toLowerCase().contains(q),
    );

    if (items.isEmpty) return _buildEmptyState();

    final bool showHeaders = !_sortByFrequency && _searchQuery.isEmpty;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final letter = VocabDictionaryService.startingLetter(item.word1);
        final prevLetter = index > 0 ? VocabDictionaryService.startingLetter(items[index - 1].word1) : '';
        final bool needHeader = showHeaders && (index == 0 || letter != prevLetter);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needHeader) _buildLetterDivider(letter, const Color(0xFF8B5CF6)),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#R: ${item.repetitionCount}x',
                          style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.word1}  vs  ${item.word2}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _bookmarkButton(state, item.word1),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildHomonymSubCard(
                    word: item.word1,
                    pos: item.pos1,
                    meaning: item.meaning1,
                    hindi: item.hindi1,
                    color: const Color(0xFF38BDF8),
                  ),
                  const SizedBox(height: 8),
                  _buildHomonymSubCard(
                    word: item.word2,
                    pos: item.pos2,
                    meaning: item.meaning2,
                    hindi: item.hindi2,
                    color: const Color(0xFFF43F5E),
                  ),
                  if (item.word3 != null && item.word3!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildHomonymSubCard(
                      word: item.word3!,
                      pos: item.pos3 ?? '',
                      meaning: item.meaning3 ?? '',
                      hindi: item.hindi3 ?? '',
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomonymSubCard({
    required String word,
    required String pos,
    required String meaning,
    required String hindi,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.volume_up_rounded, color: color, size: 18),
            onPressed: () => _speak(word),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(word, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
                    if (pos.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('($pos)', style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                    ],
                    const Spacer(),
                    if (hindi.isNotEmpty)
                      Flexible(
                        child: Text(
                          hindi,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                if (meaning.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(meaning, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 5: SPELLINGS DICTIONARY (A -> Z)
  // =========================================================================
  Widget _buildSpellingsTab(AppStateProvider state) {
    var source = _dict.spellings;
    if (_bookmarkedOnly) {
      source = source.where((item) => state.isEnglishWordBookmarked(item.correctWord)).toList();
    }

    final items = VocabDictionaryService.filterAndRankDictionary<BlackbookSpellingItem>(
      items: source,
      query: _searchQuery,
      letterFilter: _selectedLetter,
      sortByFrequency: _sortByFrequency,
      getHeadword: (item) => item.correctWord,
      getRepetition: (item) => item.repetitionCount,
      matchesSecondary: (item, q) =>
          item.hindiMeaning.toLowerCase().contains(q) ||
          item.wrongOptions.any((w) => w.toLowerCase().contains(q)),
    );

    if (items.isEmpty) return _buildEmptyState();

    final bool showHeaders = !_sortByFrequency && _searchQuery.isEmpty;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final letter = VocabDictionaryService.startingLetter(item.correctWord);
        final prevLetter = index > 0 ? VocabDictionaryService.startingLetter(items[index - 1].correctWord) : '';
        final bool needHeader = showHeaders && (index == 0 || letter != prevLetter);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needHeader) _buildLetterDivider(letter, const Color(0xFFEC4899)),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#R: ${item.repetitionCount}x',
                          style: const TextStyle(color: Color(0xFFF472B6), fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Spacer(),
                      _bookmarkButton(state, item.correctWord),
                      const SizedBox(width: 10),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 19),
                        onPressed: () => _speak(item.correctWord),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.correctWord,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      if (item.hindiMeaning.isNotEmpty)
                        Flexible(
                          child: Text(
                            item.hindiMeaning,
                            style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12.5, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                  if (item.trickyPart.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 13),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Tricky Part: ${item.trickyPart}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.wrongOptions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.wrongOptions.map((wrong) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '✗ $wrong',
                            style: const TextStyle(
                              color: Color(0xFFF87171),
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // TAB 6: VOCAB BOOSTERS (PHRASAL VERBS, PREPOSITIONS, EDITORIAL, FOREIGN)
  // =========================================================================
  Widget _buildBoostersTab(AppStateProvider state) {
    final sections = [
      'ALL',
      'Phrasal Verbs',
      'Fixed Prepositions',
      'Editorial Vocab',
      'Foreign Words',
    ];

    var source = _dict.boosters;
    if (_boosterFilter != 'ALL') {
      source = source.where((b) => b.section == _boosterFilter).toList();
    }
    if (_bookmarkedOnly) {
      source = source.where((b) => state.isEnglishWordBookmarked(b.word)).toList();
    }

    final items = VocabDictionaryService.filterAndRankDictionary<VocabBoosterWordItem>(
      items: source,
      query: _searchQuery,
      letterFilter: _selectedLetter,
      sortByFrequency: _sortByFrequency,
      getHeadword: (item) => item.word,
      getRepetition: (item) => item.repetitionCount,
      matchesSecondary: (item, q) =>
          item.englishMeaning.toLowerCase().contains(q) ||
          item.hindiMeaning.toLowerCase().contains(q) ||
          item.synonyms.any((s) => s.toLowerCase().contains(q)),
    );

    final bool showHeaders = !_sortByFrequency && _searchQuery.isEmpty;

    return Column(
      children: [
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            itemCount: sections.length,
            itemBuilder: (context, idx) {
              final sec = sections[idx];
              final sel = _boosterFilter == sec;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(sec, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.black : Colors.white70)),
                  selected: sel,
                  selectedColor: const Color(0xFF38BDF8),
                  backgroundColor: const Color(0xFF1E293B),
                  onSelected: (_) => setState(() => _boosterFilter = sec),
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final letter = VocabDictionaryService.startingLetter(item.word);
                    final prevLetter = index > 0 ? VocabDictionaryService.startingLetter(items[index - 1].word) : '';
                    final bool needHeader = showHeaders && (index == 0 || letter != prevLetter);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (needHeader) _buildLetterDivider(letter, const Color(0xFF38BDF8)),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.section,
                                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  if (item.origin.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Text(item.origin, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                                  ],
                                  const Spacer(),
                                  _bookmarkButton(state, item.word),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 19),
                                    onPressed: () => _speak(item.word),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.partOfSpeech.isNotEmpty ? '${item.word} (${item.partOfSpeech})' : item.word,
                                      style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.hindiMeaning.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(item.hindiMeaning, style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12.5, fontWeight: FontWeight.w600)),
                              ],
                              if (item.englishMeaning.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(item.englishMeaning, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                              ],
                              if (item.synonyms.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Syn: ${item.synonyms.join(', ')}',
                                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 11.5, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 7: ROOT WORDS, ETYMOLOGY & SPECIAL WORD FAMILIES
  // =========================================================================
  Widget _buildRootWordsTab() {
    var items = List<BlackbookRootWordItem>.from(_dict.roots);

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.root.toLowerCase().contains(_searchQuery) ||
            item.meaning.toLowerCase().contains(_searchQuery) ||
            item.derivatives.any((d) =>
                (d['word'] ?? '').toLowerCase().contains(_searchQuery) ||
                (d['meaning'] ?? '').toLowerCase().contains(_searchQuery) ||
                (d['hindi'] ?? '').toLowerCase().contains(_searchQuery));
      }).toList();
    }

    // Build dynamic Special Word Families from full OWS dataset (Phobia, Mania, Cide, Logy, Cracy, Graphy, Phile)
    final familyPatterns = <Map<String, String>>[
      {'suffix': 'phobia', 'title': 'Phobia (Extreme Fears)', 'meaning': 'Fear / Irrational Aversion'},
      {'suffix': 'mania', 'title': 'Mania (Obsessions)', 'meaning': 'Obsession / Madness'},
      {'suffix': 'cide', 'title': 'Cide (Killings / Killers)', 'meaning': 'Killing / Murder'},
      {'suffix': 'logy', 'title': 'Logy (Branches of Study)', 'meaning': 'Study / Science of'},
      {'suffix': 'cracy', 'title': 'Cracy / Archy (Governments)', 'meaning': 'Rule / Governance'},
      {'suffix': 'graphy', 'title': 'Graphy (Writing & Art)', 'meaning': 'Writing / Recording / Art'},
      {'suffix': 'phile', 'title': 'Phile (Lovers / Admirers)', 'meaning': 'Fondness / Lover of'},
    ];

    final specialGroups = <BlackbookRootWordItem>[];
    for (final fp in familyPatterns) {
      final suf = fp['suffix']!;
      final matches = _dict.ows
          .where((o) => o.word.toLowerCase().contains(suf))
          .take(25)
          .map((o) => {'word': o.word, 'meaning': o.phrase, 'hindi': o.hindiMeaning})
          .toList();
      if (matches.isNotEmpty) {
        final q = _searchQuery;
        if (q.isEmpty ||
            fp['title']!.toLowerCase().contains(q) ||
            matches.any((m) => (m['word'] ?? '').toLowerCase().contains(q) || (m['meaning'] ?? '').toLowerCase().contains(q))) {
          specialGroups.add(BlackbookRootWordItem(
            root: fp['title']!,
            meaning: fp['meaning']!,
            origin: 'Special Word Family (${matches.length} A–Z words)',
            derivatives: matches,
          ));
        }
      }
    }

    final combined = [...items, ...specialGroups];
    if (combined.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.root.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '= ${item.meaning}',
                          style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 13.5, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          item.origin,
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...item.derivatives.map((d) {
                final word = d['word'] ?? '';
                final meaning = d['meaning'] ?? '';
                final hindi = d['hindi'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 16),
                        onPressed: () => _speak(word),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    word,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (hindi.isNotEmpty)
                                  Flexible(
                                    child: Text(
                                      hindi,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                            if (meaning.isNotEmpty)
                              Text(
                                meaning,
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 8: EXAM PRACTICE QUIZ ARENA
  // =========================================================================
  Widget _buildQuizTab(AppStateProvider state) {
    const topicChips = [
      {'id': 'ssc_ows', 'label': 'SSC OWS'},
      {'id': 'other_ows', 'label': 'Other OWS'},
      {'id': 'ssc_idioms', 'label': 'SSC Idioms'},
      {'id': 'proverbs_idioms', 'label': 'Proverbs'},
      {'id': 'synonyms', 'label': 'Synonyms'},
      {'id': 'antonyms', 'label': 'Antonyms'},
      {'id': 'spelling', 'label': 'Spelling'},
      {'id': 'phrasal_preps', 'label': 'Phrasal Verbs'},
      {'id': 'homonyms', 'label': 'Homonyms'},
      {'id': 'all', 'label': 'All Topics'},
    ];
    final questions = _dict.getQuestionsForTopic(_quizTopicFilter);
    if (questions.isEmpty) return _buildEmptyState();

    final int totalCount = questions.length;
    final int answeredCount = _userQuizAnswers.length;
    int correctCount = 0;
    _userQuizAnswers.forEach((qId, selIdx) {
      final q = questions.firstWhere((item) => item.id == qId, orElse: () => questions.first);
      if (q.id == qId && q.correctIndex == selIdx) correctCount++;
    });

    return Column(
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            itemCount: topicChips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (ctx, i) {
              final chip = topicChips[i];
              final sel = _quizTopicFilter == chip['id'];
              return ChoiceChip(
                label: Text(chip['label']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.black : Colors.white70)),
                selected: sel,
                selectedColor: const Color(0xFF10B981),
                backgroundColor: const Color(0xFF1E293B),
                onSelected: (_) => setState(() => _quizTopicFilter = chip['id']!),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF818CF8), size: 18),
              const SizedBox(width: 8),
              Text(
                'Attempted: $answeredCount/$totalCount',
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Score: $correctCount / $answeredCount',
                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 11.5, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final sample = List<EnglishExerciseQuestion>.from(questions)..shuffle();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnglishQuizScreen(
                        title: 'Topic Vocab Drill',
                        subtitle: '${sample.take(25).length} Randomized MCQs',
                        questions: sample.take(25).toList(),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('25-Q Test', style: TextStyle(color: Colors.black, fontSize: 10.5, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              final userSelection = _userQuizAnswers[q.id];
              final bool isAnswered = userSelection != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isAnswered
                        ? (userSelection == q.correctIndex
                            ? const Color(0xFF10B981).withValues(alpha: 0.5)
                            : const Color(0xFFEF4444).withValues(alpha: 0.5))
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Q${index + 1} • ${q.type.toUpperCase()}',
                            style: const TextStyle(color: Color(0xFFA5B4FC), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        if (isAnswered)
                          Icon(
                            userSelection == q.correctIndex ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: userSelection == q.correctIndex ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.questionText,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    ...q.options.asMap().entries.map((entry) {
                      final optIdx = entry.key;
                      final optText = entry.value;

                      Color optBg = Colors.white.withValues(alpha: 0.04);
                      Color optBorder = Colors.white12;
                      Color textColor = Colors.white70;

                      if (isAnswered) {
                        if (optIdx == q.correctIndex) {
                          optBg = const Color(0xFF10B981).withValues(alpha: 0.2);
                          optBorder = const Color(0xFF10B981);
                          textColor = const Color(0xFF34D399);
                        } else if (optIdx == userSelection) {
                          optBg = const Color(0xFFEF4444).withValues(alpha: 0.2);
                          optBorder = const Color(0xFFEF4444);
                          textColor = const Color(0xFFF87171);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: isAnswered
                              ? null
                              : () {
                                  setState(() {
                                    _userQuizAnswers[q.id] = optIdx;
                                  });
                                  HapticFeedback.selectionClick();

                                  final isCorrect = optIdx == q.correctIndex;
                                  state.recordEnglishAnswer(
                                    isCorrect: isCorrect,
                                    questionId: q.id,
                                    questionText: q.questionText,
                                    options: q.options,
                                    correctIndex: q.correctIndex,
                                    selectedIndex: optIdx,
                                    explanation: q.explanation,
                                  );
                                },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: optBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: optBorder),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${String.fromCharCode(65 + optIdx)}.',
                                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    optText,
                                    style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (isAnswered && q.explanation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                q.explanation,
                                style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'No matches found for "$_searchQuery"'
                : (_selectedLetter != 'ALL'
                    ? 'No words starting with "$_selectedLetter" in this tab'
                    : 'No vocabulary items available'),
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
