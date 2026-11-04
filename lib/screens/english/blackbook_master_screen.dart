import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/english_models.dart';
import '../../data/english_content_bank.dart';
import '../../providers/app_state_provider.dart';
import '../../services/english_tts_service.dart';

class BlackbookMasterScreen extends StatefulWidget {
  final int initialTabIndex;
  const BlackbookMasterScreen({super.key, this.initialTabIndex = 0});

  @override
  State<BlackbookMasterScreen> createState() => _BlackbookMasterScreenState();
}

class _BlackbookMasterScreenState extends State<BlackbookMasterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortByFrequency = true; // true = #R high to low, false = alphabetical
  bool _hideMeaningsForTest = false; // Self-test recall mode

  // Set of revealed item IDs when in self-test recall mode
  final Set<String> _revealedItems = {};

  // Quiz state
  final Map<String, int> _userQuizAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 6),
    );
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

  void _speak(String text) {
    EnglishTtsService().speakWord(text);
  }

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
            _buildTabSelector(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOwsTab(),
                  _buildIdiomsTab(),
                  _buildSynAntTab(),
                  _buildHomonymsTab(),
                  _buildSpellingsTab(),
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
  // 1. TOP APP BAR WITH BLACKBOOK 2026 BADGE
  // =========================================================================
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Blackbook 2026',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'PRO',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Nikhil Gupta • SSC CGL, CHSL, CPO, CDS, Bank',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Recall Mode Toggle
          IconButton(
            tooltip: _hideMeaningsForTest ? 'Exit Recall Mode' : 'Enter Recall Mode (Hide Meanings)',
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
                      ? '🧠 Recall Mode ON: Tap cards to reveal Hindi & explanations!'
                      : '📖 Study Mode ON: All meanings visible.'),
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
  // 2. SEARCH BAR & FREQUENCY TOGGLE
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
                  hintText: 'Search English words, Hindi or meaning...',
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
          // Sort by Frequency / A-Z button
          InkWell(
            onTap: () {
              setState(() => _sortByFrequency = !_sortByFrequency);
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _sortByFrequency ? const Color(0xFFF59E0B).withValues(alpha: 0.15) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _sortByFrequency ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _sortByFrequency ? Icons.trending_up_rounded : Icons.sort_by_alpha_rounded,
                    size: 16,
                    color: _sortByFrequency ? const Color(0xFFF59E0B) : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortByFrequency ? '#R Rank' : 'A-Z',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _sortByFrequency ? const Color(0xFFF59E0B) : Colors.white70,
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
  // 3. TAB SELECTOR PILLS
  // =========================================================================
  Widget _buildTabSelector() {
    final tabs = [
      {'title': 'Top OWS', 'icon': Icons.lightbulb_rounded, 'color': const Color(0xFF10B981)},
      {'title': 'Idioms', 'icon': Icons.palette_rounded, 'color': const Color(0xFFF59E0B)},
      {'title': 'Syn & Ant', 'icon': Icons.compare_arrows_rounded, 'color': const Color(0xFF06B6D4)},
      {'title': 'Homonyms', 'icon': Icons.splitscreen_rounded, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Spellings', 'icon': Icons.spellcheck_rounded, 'color': const Color(0xFFEC4899)},
      {'title': 'Root Words', 'icon': Icons.account_tree_rounded, 'color': const Color(0xFF14B8A6)},
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

  // =========================================================================
  // TAB 1: ONE WORD SUBSTITUTION (OWS)
  // =========================================================================
  Widget _buildOwsTab() {
    var items = List<BlackbookOwsItem>.from(EnglishContentBank.blackbookOws);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.word.toLowerCase().contains(_searchQuery) ||
            item.phrase.toLowerCase().contains(_searchQuery) ||
            item.hindiMeaning.toLowerCase().contains(_searchQuery) ||
            item.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Sort
    if (_sortByFrequency) {
      items.sort((a, b) => b.repetitionCount.compareTo(a.repetitionCount));
    } else {
      items.sort((a, b) => a.word.compareTo(b.word));
    }

    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final keyId = 'ows_${item.id}';
        final isRevealed = !_hideMeaningsForTest || _revealedItems.contains(keyId);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
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
                  // Top Row: Frequency Badge & Tags
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
                          '#R: ${item.repetitionCount}x in SSC',
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
                            '* Spelling Trap',
                            style: TextStyle(color: Color(0xFFF472B6), fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      if (item.isSynAnt) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            '~ Syn/Ant',
                            style: TextStyle(color: Color(0xFF22D3EE), fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Pronunciation button
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

                  // Definition / Phrase
                  Text(
                    item.phrase,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Word and Hindi Meaning
                  if (isRevealed) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          item.word,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
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
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 2: IDIOMS & PHRASES
  // =========================================================================
  Widget _buildIdiomsTab() {
    var items = List<BlackbookIdiomItem>.from(EnglishContentBank.blackbookIdioms);

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.idiom.toLowerCase().contains(_searchQuery) ||
            item.englishMeaning.toLowerCase().contains(_searchQuery) ||
            item.hindiMeaning.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (_sortByFrequency) {
      items.sort((a, b) => b.repetitionCount.compareTo(a.repetitionCount));
    } else {
      items.sort((a, b) => a.idiom.compareTo(b.idiom));
    }

    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final keyId = 'idiom_${item.id}';
        final isRevealed = !_hideMeaningsForTest || _revealedItems.contains(keyId);

        return Container(
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
                    // Hindi Meaning
                    Text(
                      item.hindiMeaning,
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // English Meaning
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
        );
      },
    );
  }

  // =========================================================================
  // TAB 3: DUAL SYNONYMS & ANTONYMS MATRIX
  // =========================================================================
  Widget _buildSynAntTab() {
    var items = List<BlackbookSynAntItem>.from(EnglishContentBank.blackbookSynAnt);

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.word.toLowerCase().contains(_searchQuery) ||
            item.hindiMeaning.toLowerCase().contains(_searchQuery) ||
            item.synonyms.any((s) => s.toLowerCase().contains(_searchQuery)) ||
            item.antonyms.any((a) => a.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    if (_sortByFrequency) {
      items.sort((a, b) => b.repetitionCount.compareTo(a.repetitionCount));
    } else {
      items.sort((a, b) => a.word.compareTo(b.word));
    }

    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
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
              // Header
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
                  Text(
                    item.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('(${item.partOfSpeech})', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 19),
                    onPressed: () => _speak(item.word),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Hindi Meaning
              Text(
                item.hindiMeaning,
                style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              // Dual Synonyms / Antonyms Section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // Synonyms Row
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
                            children: item.synonyms.map((s) => Text(
                              s,
                              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w500),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 14),
                    // Antonyms Row
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
                            children: item.antonyms.map((a) => Text(
                              a,
                              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontWeight: FontWeight.w500),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 4: CONFUSING HOMONYMS & PAIRS
  // =========================================================================
  Widget _buildHomonymsTab() {
    var items = List<BlackbookHomonymPair>.from(EnglishContentBank.blackbookHomonyms);

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.word1.toLowerCase().contains(_searchQuery) ||
            item.word2.toLowerCase().contains(_searchQuery) ||
            item.hindi1.toLowerCase().contains(_searchQuery) ||
            item.hindi2.toLowerCase().contains(_searchQuery) ||
            item.meaning1.toLowerCase().contains(_searchQuery) ||
            item.meaning2.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
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
              // Comparison Header
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
                  Text(
                    '${item.word1}  vs  ${item.word2}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Side 1
              _buildHomonymSubCard(
                word: item.word1,
                pos: item.pos1,
                meaning: item.meaning1,
                hindi: item.hindi1,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 8),

              // Side 2
              _buildHomonymSubCard(
                word: item.word2,
                pos: item.pos2,
                meaning: item.meaning2,
                hindi: item.hindi2,
                color: const Color(0xFFF43F5E),
              ),

              // Optional Side 3
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
                    const SizedBox(width: 6),
                    Text('($pos)', style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                    const Spacer(),
                    Text(hindi, style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(meaning, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 5: SPELLING TRAPS
  // =========================================================================
  Widget _buildSpellingsTab() {
    var items = List<BlackbookSpellingItem>.from(EnglishContentBank.blackbookSpellings);

    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.correctWord.toLowerCase().contains(_searchQuery) ||
            item.hindiMeaning.toLowerCase().contains(_searchQuery) ||
            item.wrongOptions.any((w) => w.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    if (_sortByFrequency) {
      items.sort((a, b) => b.repetitionCount.compareTo(a.repetitionCount));
    } else {
      items.sort((a, b) => a.correctWord.compareTo(b.correctWord));
    }

    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
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
                      '#R: ${item.repetitionCount}x in SSC',
                      style: const TextStyle(color: Color(0xFFF472B6), fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const Spacer(),
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

              // Correct Spelling Row
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    item.correctWord,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
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

              const SizedBox(height: 8),

              // Common Traps Row
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
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 6: ROOT WORDS & ETYMOLOGY
  // =========================================================================
  Widget _buildRootWordsTab() {
    var items = List<BlackbookRootWordItem>.from(EnglishContentBank.blackbookRoots);

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

    if (items.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

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
              // Root Header
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
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '= ${item.meaning}',
                          style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Origin: ${item.origin}',
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Derivative Words
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
                                Text(
                                  word,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  hindi,
                                  style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
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
  // TAB 7: LIVE SSC EXAM PRACTICE QUIZ
  // =========================================================================
  Widget _buildQuizTab(AppStateProvider state) {
    final questions = EnglishContentBank.blackbookPractice;

    if (questions.isEmpty) return _buildEmptyState();

    final int totalCount = questions.length;
    final int answeredCount = _userQuizAnswers.length;
    int correctCount = 0;
    _userQuizAnswers.forEach((qId, selIdx) {
      final q = questions.firstWhere((item) => item.id == qId);
      if (q.correctIndex == selIdx) correctCount++;
    });

    return Column(
      children: [
        // Score Header
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
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
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
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
                    // Question Number and Type Badge
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
                            userSelection == q.correctIndex
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: userSelection == q.correctIndex
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Question Text
                    Text(
                      q.questionText,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
                    ),
                    const SizedBox(height: 12),

                    // Options
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

                                  // Record to AppStateProvider for Mistake Notebook
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
                                  String.fromCharCode(65 + optIdx) + '.',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
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

                    // Explanation (if answered)
                    if (isAnswered) ...[
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

  // =========================================================================
  // EMPTY STATE HELPER
  // =========================================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty ? 'No matches found for "$_searchQuery"' : 'No vocabulary items available',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
