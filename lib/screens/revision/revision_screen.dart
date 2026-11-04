import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/content_repository.dart';
import '../../data/concept_formula_repository.dart';
import '../practice/practice_quiz_screen.dart';
import '../practice/recall_solve_screen.dart';

class RevisionScreen extends StatefulWidget {
  final int initialTabIndex;

  const RevisionScreen({super.key, this.initialTabIndex = 0});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMistakeFilter = 'all';

  // Custom Revision Deck Filter & State
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final Set<String> _revealedCardIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int initialIdx = widget.initialTabIndex;
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    if (initialIdx == 0 && provider.revisionItems.isEmpty && provider.allMistakes.isNotEmpty) {
      initialIdx = 1;
    }
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIdx,
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final mistakes = state.allMistakes;
    final revisionItems = state.revisionItems;
    final pendingMistakesCount = mistakes.where((m) => !m.isResolved).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded, color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Revision & Memorization',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Active Recall & Lifetime Mistakes',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 0) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accent),
              tooltip: 'Add From App Content',
              onPressed: () => _showAddFromAppContentSheet(context, state),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
              color: AppTheme.surface,
              onSelected: (value) {
                if (value == 'clear_deck') {
                  state.clearAllRevisionDeck();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Revision deck cleared.')),
                  );
                } else if (value == 'drill_all') {
                  if (revisionItems.isNotEmpty) {
                    _startFlashcardDrill(context, state, revisionItems);
                  }
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'drill_all',
                  child: Row(
                    children: [
                      Icon(Icons.style_rounded, size: 18, color: AppTheme.primaryLight),
                      SizedBox(width: 10),
                      Text('Start Flashcard Drill'),
                    ],
                  ),
                ),
                if (revisionItems.isNotEmpty)
                  const PopupMenuItem(
                    value: 'clear_deck',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.redAccent),
                        SizedBox(width: 10),
                        Text('Clear Revision Deck', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (_tabController.index == 1 && mistakes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
              tooltip: 'Clear All Mistakes',
              onPressed: () => _confirmClearMistakes(context, state),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.7)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.style_rounded, size: 16),
                      const SizedBox(width: 7),
                      const Text('Flashcards'),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _tabController.index == 0
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${revisionItems.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _tabController.index == 0 ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_edu_rounded, size: 16),
                      const SizedBox(width: 7),
                      const Text('Mistakes'),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? (pendingMistakesCount > 0
                                  ? AppTheme.error.withValues(alpha: 0.35)
                                  : Colors.white.withValues(alpha: 0.25))
                              : (pendingMistakesCount > 0
                                  ? AppTheme.error.withValues(alpha: 0.25)
                                  : AppTheme.surfaceLight),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${mistakes.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _tabController.index == 1 ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (_tabController.index == 0 && revisionItems.isNotEmpty)
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Revision Card', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () => _showAddFromAppContentSheet(context, state),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Custom Revision Deck (Revise anything: formulas, percentages, triplets, notes)
          _buildCustomRevisionDeckTab(context, state, revisionItems),

          // TAB 2: Mistake Notebook
          _buildMistakeNotebookTab(context, state, mistakes),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: CUSTOM REVISION DECK ("Revise Anything")
  // ==========================================
  Widget _buildCustomRevisionDeckTab(
    BuildContext context,
    AppStateProvider state,
    List<RevisionItemModel> items,
  ) {
    if (items.isEmpty) {
      return _buildCustomDeckEmptyState(context, state, true);
    }

    final masteredCount = items.where((e) => e.isMastered).length;
    final toReviewCount = items.length - masteredCount;
    final double masteryRatio = items.isEmpty ? 0.0 : (masteredCount / items.length);

    // Filter items by category & search query
    List<RevisionItemModel> filtered = items.where((item) {
      // Category filter
      if (_selectedCategory == 'mastered' && !item.isMastered) return false;
      if (_selectedCategory == 'to_review' && item.isMastered) return false;
      if (_selectedCategory != 'all' &&
          _selectedCategory != 'mastered' &&
          _selectedCategory != 'to_review' &&
          item.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      // Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesQuestion = item.question.toLowerCase().contains(q);
        final matchesAnswer = item.answer.toLowerCase().contains(q);
        final matchesNotes = item.notes.toLowerCase().contains(q);
        final matchesCategory = item.category.toLowerCase().contains(q);
        if (!matchesTitle && !matchesQuestion && !matchesAnswer && !matchesNotes && !matchesCategory) {
          return false;
        }
      }
      return true;
    }).toList();

    // Extract dynamic unique categories
    final Set<String> categories = {'all', 'mastered', 'to_review'};
    for (var it in items) {
      if (it.category.isNotEmpty) categories.add(it.category.toLowerCase());
    }

    return Column(
      children: [
        // Top Action & Progress Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Circular Progress Ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: masteryRatio,
                          strokeWidth: 5,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                        ),
                      ),
                      Text(
                        '${(masteryRatio * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${items.length} Revision Flashcards',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '✓ $masteredCount Mastered',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF34D399)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '⏳ $toReviewCount Review',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.warning),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.style_rounded, size: 16),
                    label: const Text('Drill Deck', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                    onPressed: items.isEmpty
                        ? null
                        : () => _startFlashcardDrill(context, state, filtered.isNotEmpty ? filtered : items),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Search formula, shortcut, percentage, or notes...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.surfaceLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.surfaceLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryLight, width: 1.5),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        // Category Filter Chips
        Container(
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((cat) {
              String label = cat == 'all'
                  ? 'All (${items.length})'
                  : cat == 'mastered'
                      ? 'Mastered ($masteredCount)'
                      : cat == 'to_review'
                          ? 'To Review ($toReviewCount)'
                          : '${cat[0].toUpperCase()}${cat.substring(1)} (${items.where((e) => e.category.toLowerCase() == cat).length})';

              bool isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(
                    _getCategoryIcon(cat),
                    size: 14,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryLight,
                  backgroundColor: AppTheme.surface,
                  side: BorderSide(color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Items List
        Expanded(
          child: filtered.isEmpty
              ? _buildCustomDeckEmptyState(context, state, items.isEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isRevealed = _revealedCardIds.contains(item.id);
                    return _buildRevisionCard(context, state, item, isRevealed);
                  },
                ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'all':
        return Icons.dashboard_rounded;
      case 'mastered':
        return Icons.check_circle_rounded;
      case 'to_review':
        return Icons.pending_actions_rounded;
      case 'formulas':
        return Icons.functions_rounded;
      case 'percentages':
        return Icons.percent_rounded;
      case 'triplets':
        return Icons.change_history_rounded;
      case 'squares & cubes':
        return Icons.exposure_zero_rounded;
      case 'shortcuts':
        return Icons.flash_on_rounded;
      case 'tables':
        return Icons.grid_view_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  Widget _buildRevisionCard(
    BuildContext context,
    AppStateProvider state,
    RevisionItemModel item,
    bool isRevealed,
  ) {
    Color categoryColor = _getCategoryColor(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isMastered
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : AppTheme.surfaceLight.withValues(alpha: 0.9),
          width: 1.4,
        ),
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
            HapticFeedback.selectionClick();
            setState(() {
              if (isRevealed) {
                _revealedCardIds.remove(item.id);
              } else {
                _revealedCardIds.add(item.id);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Controls
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: categoryColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getCategoryIcon(item.category), size: 12, color: categoryColor),
                          const SizedBox(width: 4),
                          Text(
                            item.category.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: categoryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isMastered ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: item.isMastered ? const Color(0xFF10B981) : Colors.white38,
                        size: 22,
                      ),
                      tooltip: item.isMastered ? 'Mastered (Tap to unmark)' : 'Mark as Mastered',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        state.toggleMasterRevisionItem(item.id);
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white38, size: 20),
                      color: AppTheme.surface,
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showAddEditRevisionItemSheet(context, state, existing: item);
                        } else if (val == 'delete') {
                          _confirmDeleteItem(context, state, item);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                              SizedBox(width: 8),
                              Text('Edit Card'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.error),
                              SizedBox(width: 8),
                              Text('Delete Card'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question / Front
                Text(
                  item.question,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Revealable Answer Section
                if (isRevealed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'ANSWER',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF34D399)),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.visibility_off_outlined, color: Colors.white38, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              'Tap to hide',
                              style: TextStyle(fontSize: 10.5, color: Colors.white38),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.answer,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF34D399),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.gold, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.notes,
                              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, color: AppTheme.primaryLight.withValues(alpha: 0.8), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Tap card to reveal answer',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryLight.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'formulas':
        return const Color(0xFFA855F7); // Purple
      case 'percentages':
        return const Color(0xFF06B6D4); // Cyan
      case 'triplets':
        return const Color(0xFFF97316); // Orange
      case 'squares & cubes':
        return const Color(0xFFFBBF24); // Gold
      case 'shortcuts':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  Widget _buildCustomDeckEmptyState(BuildContext context, AppStateProvider state, bool isCompletelyEmpty) {
    if (!isCompletelyEmpty) {
      // Empty search / filter results
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search_off_rounded, size: 42, color: Colors.white54),
              ),
              const SizedBox(height: 14),
              const Text(
                'No Cards Match Filter',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try clearing your search query or switching to "All" category.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.surfaceLight),
                ),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('Reset Filter & Search'),
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'all';
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    final mistakesCount = state.allMistakes.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero Intro Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.style_rounded, size: 36, color: AppTheme.gold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Active Recall Flashcards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Store formulas, Vedic shortcuts, and difficult calculations in a digital flashcard deck for spaced revision drills.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Active Mistakes Alert Banner (If student has mistakes!)
          if (mistakesCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_edu_rounded, color: Color(0xFFF87171), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$mistakesCount Calculation Mistakes Saved',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'You can drill them directly or import them into Flashcards.',
                          style: TextStyle(fontSize: 11, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      _tabController.animateTo(1);
                    },
                    child: const Text('View Mistakes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3. Section Title
          const Text(
            'QUICK START OPTIONS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.white54),
          ),
          const SizedBox(height: 10),

          // 4. Starter Pack Action Card
          InkWell(
            onTap: () async {
              HapticFeedback.mediumImpact();
              await state.loadStarterPack();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚡ 8 Essential Formulas & Shortcuts loaded into your deck!'),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Load Starter Pack (8 Cards)',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Colors.white),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Essential algebra formulas, fractions & Vedic tricks',
                          style: TextStyle(fontSize: 11.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 5. Import Mistakes Card (if student has mistakes)
          if (mistakesCount > 0) ...[
            InkWell(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final imported = await state.importMistakesToRevisionDeck();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📥 Imported $imported calculation mistakes into Flashcards!'),
                      backgroundColor: AppTheme.accent,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFFFB923C), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Import My $mistakesCount Mistakes',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Instantly convert missed questions into active recall cards',
                            style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFB923C), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 6. Browse App Curriculum Card
          InkWell(
            onTap: () => _showAddFromAppContentSheet(context, state),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Color(0xFF22D3EE), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Browse 50+ Built-in Formulas',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Vedic tricks, Pythagorean triples & square roots',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF22D3EE), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 7. Create Custom Card
          InkWell(
            onTap: () => _showAddEditRevisionItemSheet(context, state),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Color(0xFF818CF8), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Custom Card',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Write your own personal formula, trick, or mnemonic',
                          style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF818CF8), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ADD FROM APP CONTENT BOTTOM SHEET MODAL
  // (Instant 1-Click Addition from Real App Curriculum & Mistakes)
  // ==========================================
  void _showAddFromAppContentSheet(
    BuildContext context,
    AppStateProvider state,
  ) {
    String selectedSection = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            // Gather dynamic content directly from the application
            final List<_AppContentEntry> mistakes = state.allMistakes.map((m) {
              return _AppContentEntry(
                title: 'Mistake: ${m.topicId}',
                question: '${m.prompt} = ?',
                answer: m.correctAnswer,
                category: 'Mistakes',
                notes: 'Your wrong attempt: ${m.userAnswer}',
              );
            }).toList();

            final List<_AppContentEntry> formulas = ConceptFormulaRepository.formulas.map((f) {
              return _AppContentEntry(
                title: f.title,
                question: f.formula,
                answer: f.subtitle.isNotEmpty ? f.subtitle : f.explanation,
                category: 'Formulas',
                notes: f.explanation,
              );
            }).toList();

            final List<_AppContentEntry> triples = ContentRepository.pythagoreanTriples.map((t) {
              return _AppContentEntry(
                title: 'Triple: (${t[0]}, ${t[1]}, ${t[2]})',
                question: 'Base = ${t[0]}, Perpendicular = ${t[1]} -> Hypotenuse?',
                answer: '${t[2]}  [Proof: ${t[0]}² + ${t[1]}² = ${t[2]}²]',
                category: 'Triplets',
                notes: 'Standard Exam Pythagorean Triplet (${t[0]}, ${t[1]}, ${t[2]})',
              );
            }).toList();

            final List<_AppContentEntry> tables = [];
            for (final t in [12, 13, 14, 15, 16, 17, 18, 19, 21, 23, 24, 27, 29]) {
              for (final mult in [6, 7, 8, 9, 12]) {
                tables.add(_AppContentEntry(
                  title: 'Table $t × $mult',
                  question: '$t × $mult = ?',
                  answer: '${t * mult}',
                  category: 'Tables',
                  notes: 'Multiplication table drill ($t x $mult)',
                ));
              }
            }

            final List<_AppContentEntry> powers = [];
            for (int i = 11; i <= 30; i++) {
              powers.add(_AppContentEntry(
                title: 'Square of $i',
                question: '$i\u00B2 = ?',
                answer: '${i * i}',
                category: 'Squares & Cubes',
                notes: '$i × $i = ${i * i}',
              ));
            }
            for (int i = 2; i <= 15; i++) {
              powers.add(_AppContentEntry(
                title: 'Cube of $i',
                question: '$i\u00B3 = ?',
                answer: '${i * i * i}',
                category: 'Squares & Cubes',
                notes: '$i × $i × $i = ${i * i * i}',
              ));
            }

            // Filter active list based on selected section
            List<_AppContentEntry> activeList;
            if (selectedSection == 'mistakes') {
              activeList = mistakes;
            } else if (selectedSection == 'formulas') {
              activeList = formulas;
            } else if (selectedSection == 'triples') {
              activeList = triples;
            } else if (selectedSection == 'tables') {
              activeList = tables;
            } else if (selectedSection == 'powers') {
              activeList = powers;
            } else {
              activeList = [...mistakes, ...formulas, ...triples, ...tables, ...powers];
            }

            return Container(
              height: MediaQuery.of(modalCtx).size.height * 0.85,
              padding: const EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.library_add_rounded, color: AppTheme.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add From App Content',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Tap 1-click [+ Add] to instantly revise real app material',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Horizontal category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAppContentChip('All (${activeList.length})', 'all', selectedSection, (val) {
                          setModalState(() => selectedSection = val);
                        }),
                        const SizedBox(width: 8),
                        _buildAppContentChip('Mistakes (${mistakes.length})', 'mistakes', selectedSection, (val) {
                          setModalState(() => selectedSection = val);
                        }),
                        const SizedBox(width: 8),
                        _buildAppContentChip('Formulas (${formulas.length})', 'formulas', selectedSection, (val) {
                          setModalState(() => selectedSection = val);
                        }),
                        const SizedBox(width: 8),
                        _buildAppContentChip('Triplets (${triples.length})', 'triples', selectedSection, (val) {
                          setModalState(() => selectedSection = val);
                        }),
                        const SizedBox(width: 8),
                        _buildAppContentChip('Tables (${tables.length})', 'tables', selectedSection, (val) {
                          setModalState(() => selectedSection = val);
                        }),
                        const SizedBox(width: 8),
                        _buildAppContentChip('Squares & Cubes (${powers.length})', 'powers', selectedSection, (val) {
                          setModalState(() => selectedSection = val);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // List of Content Cards
                  Expanded(
                    child: activeList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.hourglass_empty_rounded, size: 40, color: AppTheme.textSecondary),
                                const SizedBox(height: 10),
                                Text(
                                  selectedSection == 'mistakes'
                                      ? 'No mistakes recorded yet!\nAttempt quizzes to automatically capture mistakes.'
                                      : 'No items in this section.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: activeList.length,
                            separatorBuilder: (context, _) => const SizedBox(height: 10),
                            itemBuilder: (ctx, index) {
                              final item = activeList[index];
                              final isAlreadyAdded = state.revisionItems.any(
                                (r) => r.question.trim() == item.question.trim(),
                              );

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isAlreadyAdded
                                        ? Colors.green.withValues(alpha: 0.3)
                                        : AppTheme.surfaceLight,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _categoryColor(item.category).withValues(alpha: 0.18),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  item.category.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: _categoryColor(item.category),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.question,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Ans: ${item.answer}',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.accent.withValues(alpha: 0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (isAlreadyAdded)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.greenAccent, width: 1),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                                            SizedBox(width: 4),
                                            Text(
                                              'Added',
                                              style: TextStyle(
                                                color: Colors.greenAccent,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accent,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: const Icon(Icons.add_rounded, size: 16),
                                        label: const Text(
                                          'Add',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        onPressed: () async {
                                          final newItem = RevisionItemModel(
                                            id: 'rev_${DateTime.now().millisecondsSinceEpoch}_${item.question.hashCode.abs()}',
                                            title: item.title,
                                            question: item.question,
                                            answer: item.answer,
                                            category: item.category,
                                            notes: item.notes,
                                            createdAt: DateTime.now(),
                                          );
                                          await state.addRevisionItem(newItem);
                                          HapticFeedback.lightImpact();
                                          setModalState(() {});
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Added "${item.title}" to Revision Deck!'),
                                                duration: const Duration(seconds: 1),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Option: Manual Custom Card
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.edit_note_rounded, size: 16, color: AppTheme.textSecondary),
                      label: const Text(
                        'Want to type a custom card manually?',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      onPressed: () {
                        Navigator.pop(modalCtx);
                        _showAddEditRevisionItemSheet(context, state);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppContentChip(
    String label,
    String value,
    String current,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.surfaceLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Mistakes':
        return AppTheme.error;
      case 'Formulas':
        return AppTheme.accent;
      case 'Triplets':
        return Colors.purpleAccent;
      case 'Tables':
        return Colors.lightBlueAccent;
      case 'Squares & Cubes':
        return Colors.orangeAccent;
      default:
        return AppTheme.primaryLight;
    }
  }

  // ==========================================
  // ADD / EDIT REVISION CARD BOTTOM SHEET MODAL
  // ==========================================
  void _showAddEditRevisionItemSheet(
    BuildContext context,
    AppStateProvider state, {
    RevisionItemModel? existing,
  }) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final questionCtrl = TextEditingController(text: existing?.question ?? '');
    final answerCtrl = TextEditingController(text: existing?.answer ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String selectedCategory = existing?.category ?? 'Formulas';

    final presetCategories = ['Formulas', 'Percentages', 'Triplets', 'Squares & Cubes', 'Shortcuts', 'Custom'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      children: [
                        Icon(
                          existing == null ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded,
                          color: AppTheme.accent,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          existing == null ? 'Add Revision Card' : 'Edit Revision Card',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Save any formula, shortcut, fraction, or calculation to memorize and drill anytime.',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                    const SizedBox(height: 18),

                    // Category Selector
                    const Text('Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: presetCategories.map((cat) {
                        bool isSel = selectedCategory.toLowerCase() == cat.toLowerCase();
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: AppTheme.primaryLight,
                          backgroundColor: AppTheme.surface,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : Colors.white70,
                          ),
                          onSelected: (_) => setModalState(() => selectedCategory = cat),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: 'Topic / Title *',
                        hintText: 'e.g. Difference of Squares, Fraction 1/7, Triplet 7-24',
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Front / Question
                    TextField(
                      controller: questionCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Question / Formula (Front) *',
                        hintText: 'e.g. a² - b² = ?  OR  1/7 in % = ?  OR  37² = ?',
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Back / Answer
                    TextField(
                      controller: answerCtrl,
                      style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Answer / Value (Back) *',
                        hintText: 'e.g. (a - b)(a + b)  OR  14.28%  OR  1369',
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Notes / Tips (Optional)
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      decoration: InputDecoration(
                        labelText: 'Notes / Exam Tip / Trick (Optional)',
                        hintText: 'e.g. High frequency in SSC CGL Tier 2 simplification.',
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        final question = questionCtrl.text.trim();
                        final answer = answerCtrl.text.trim();
                        final notes = notesCtrl.text.trim();

                        if (title.isEmpty || question.isEmpty || answer.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in Topic, Question, and Answer!')),
                          );
                          return;
                        }

                        if (existing != null) {
                          final updated = existing.copyWith(
                            title: title,
                            question: question,
                            answer: answer,
                            category: selectedCategory,
                            notes: notes,
                          );
                          state.updateRevisionItem(updated);
                        } else {
                          final newItem = RevisionItemModel(
                            id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                            title: title,
                            question: question,
                            answer: answer,
                            category: selectedCategory,
                            notes: notes,
                            createdAt: DateTime.now(),
                          );
                          state.addRevisionItem(newItem);
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(existing == null ? 'Added to Revision Deck!' : 'Revision card updated!'),
                          ),
                        );
                      },
                      child: Text(
                        existing == null ? 'Save to Revision Deck' : 'Update Revision Card',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      titleCtrl.dispose();
      questionCtrl.dispose();
      answerCtrl.dispose();
      notesCtrl.dispose();
    });
  }

  void _confirmDeleteItem(BuildContext context, AppStateProvider state, RevisionItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Revision Card?'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              state.deleteRevisionItem(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // INTERACTIVE FLASHCARD DRILL
  // ==========================================
  void _startFlashcardDrill(
    BuildContext context,
    AppStateProvider state,
    List<RevisionItemModel> items,
  ) {
    if (items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int currentIndex = 0;
        bool isRevealed = false;
        int sessionMasteredCount = 0;

        return StatefulBuilder(
          builder: (drillCtx, setDrillState) {
            final currentItem = items[currentIndex];

            return Container(
              height: MediaQuery.of(drillCtx).size.height * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(drillCtx),
                      ),
                      Text(
                        'Card ${currentIndex + 1} of ${items.length}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white70, fontSize: 14),
                      ),
                      IconButton(
                        icon: Icon(
                          currentItem.isMastered ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: currentItem.isMastered ? const Color(0xFF10B981) : Colors.white38,
                        ),
                        onPressed: () {
                          state.toggleMasterRevisionItem(currentItem.id);
                          setDrillState(() {});
                        },
                      ),
                    ],
                  ),

                  // Progress Bar
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / items.length,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryLight),
                  ),
                  const SizedBox(height: 20),

                  // Flashcard Body
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setDrillState(() => isRevealed = !isRevealed);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isRevealed
                                ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                                : [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isRevealed ? const Color(0xFF10B981).withValues(alpha: 0.5) : AppTheme.primaryLight.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentItem.category.toUpperCase(),
                                style: const TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              currentItem.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              currentItem.question,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (isRevealed) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                                ),
                                child: Column(
                                  children: [
                                    const Text('ANSWER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF34D399))),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentItem.answer,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (currentItem.notes.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  currentItem.notes,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ] else ...[
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.touch_app_rounded, color: Colors.white54, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tap card to reveal answer',
                                    style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Controls
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          label: const Text('Review Again', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (currentIndex < items.length - 1) {
                              setDrillState(() {
                                currentIndex++;
                                isRevealed = false;
                              });
                            } else {
                              Navigator.pop(drillCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Drill completed! $sessionMasteredCount marked mastered.')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Got It! Mastered', style: TextStyle(fontWeight: FontWeight.w900)),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (!currentItem.isMastered) {
                              state.toggleMasterRevisionItem(currentItem.id);
                              sessionMasteredCount++;
                            }
                            if (currentIndex < items.length - 1) {
                              setDrillState(() {
                                currentIndex++;
                                isRevealed = false;
                              });
                            } else {
                              Navigator.pop(drillCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Drill completed! $sessionMasteredCount marked mastered.')),
                              );
                            }
                          },
                        ),
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

  // ==========================================
  // TAB 2: MISTAKE NOTEBOOK
  // ==========================================
  Widget _buildMistakeNotebookTab(BuildContext context, AppStateProvider state, List<MistakeModel> mistakes) {
    if (mistakes.isEmpty) {
      return _buildEmptyMistakesState();
    }

    final int pendingCount = mistakes.where((m) => !m.isResolved).length;
    final int masteredCount = mistakes.where((m) => m.isResolved).length;

    // Filter mistakes by topic/status if selected
    List<MistakeModel> filtered;
    if (_selectedMistakeFilter == 'all') {
      filtered = mistakes;
    } else if (_selectedMistakeFilter == 'pending') {
      filtered = mistakes.where((m) => !m.isResolved).toList();
    } else if (_selectedMistakeFilter == 'mastered') {
      filtered = mistakes.where((m) => m.isResolved).toList();
    } else if (_selectedMistakeFilter == 'addition') {
      filtered = mistakes.where((m) => m.topicId.contains('add') || m.prompt.contains('+')).toList();
    } else if (_selectedMistakeFilter == 'subtraction') {
      filtered = mistakes.where((m) => m.topicId.contains('sub') || m.prompt.contains('-') || m.prompt.contains('−')).toList();
    } else {
      filtered = mistakes.where((m) => m.topicId == _selectedMistakeFilter).toList();
    }

    return Column(
      children: [
        // Quick Action & Overview Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF312E81).withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_edu_rounded, color: AppTheme.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${mistakes.length} Lifetime Mistakes',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: pendingCount > 0
                                ? AppTheme.error.withValues(alpha: 0.2)
                                : const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pendingCount > 0 ? '⚠️ $pendingCount Pending Recall' : '🎉 0 Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: pendingCount > 0 ? const Color(0xFFF87171) : const Color(0xFF34D399),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '✓ $masteredCount Solved',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF34D399),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Stored permanently so you never repeat the same calculation error.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pendingCount > 0 ? AppTheme.primaryLight : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 18),
                label: Text(
                  pendingCount > 0 ? 'Drill Active\n($pendingCount)' : 'Drill All\n(${mistakes.length})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, height: 1.15),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _startRevisionQuiz(context, filtered.isNotEmpty ? filtered : mistakes);
                },
              ),
            ],
          ),
        ),

        // Topic & Status Filter Chips
        Container(
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _mistakeFilterChip('all', 'All (${mistakes.length})', Icons.dashboard_rounded),
              _mistakeFilterChip('pending', 'Pending ($pendingCount)', Icons.alarm_rounded),
              _mistakeFilterChip('mastered', 'Mastered ($masteredCount)', Icons.check_circle_rounded),
              _mistakeFilterChip('addition', 'Addition (${mistakes.where((m) => m.topicId.contains('add') || m.prompt.contains('+')).length})', Icons.add_rounded),
              _mistakeFilterChip('subtraction', 'Subtraction (${mistakes.where((m) => m.topicId.contains('sub') || m.prompt.contains('-') || m.prompt.contains('−')).length})', Icons.remove_rounded),
              _mistakeFilterChip('tables', 'Tables (${mistakes.where((m) => m.topicId == 'tables').length})', Icons.grid_view_rounded),
              _mistakeFilterChip('multiply', 'Multiplication (${mistakes.where((m) => m.topicId == 'multiply' || m.topicId.contains('multi')).length})', Icons.close_rounded),
              _mistakeFilterChip('squares', 'Squares (${mistakes.where((m) => m.topicId == 'squares').length})', Icons.exposure_zero_rounded),
              _mistakeFilterChip('cubes', 'Cubes (${mistakes.where((m) => m.topicId == 'cubes').length})', Icons.superscript_rounded),
              _mistakeFilterChip('fractions', 'Fractions (${mistakes.where((m) => m.topicId == 'fractions').length})', Icons.percent_rounded),
            ],
          ),
        ),

        // Mistakes List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final m = filtered[index];
              final bool isResolved = m.isResolved;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isResolved
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : AppTheme.error.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecallSolveScreen(formula: m.prompt, mistake: m),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isResolved
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : AppTheme.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isResolved ? Icons.check_circle_rounded : Icons.priority_high_rounded,
                              color: isResolved ? const Color(0xFF10B981) : AppTheme.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      m.prompt,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        m.topicId.toUpperCase(),
                                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.primaryLight),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (isResolved) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Mastered in Notebook ✅',
                                          style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Ans: ${m.correctAnswer}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ] else ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.error.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Your Attempt: "${m.userAnswer}" ❌',
                                          style: const TextStyle(color: Color(0xFFF87171), fontSize: 11, fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.warning.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.alarm_on_rounded, color: AppTheme.warning, size: 12),
                                            SizedBox(width: 4),
                                            Text(
                                              '1-Hr Recall Alert Active',
                                              style: TextStyle(color: AppTheme.warning, fontSize: 10.5, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isResolved
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : AppTheme.primaryLight,
                              side: isResolved
                                  ? const BorderSide(color: Color(0xFF10B981))
                                  : null,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: isResolved ? 0 : 2,
                            ),
                            icon: Icon(
                              isResolved ? Icons.refresh_rounded : Icons.bolt_rounded,
                              size: 16,
                              color: isResolved ? const Color(0xFF34D399) : AppTheme.gold,
                            ),
                            label: Text(
                              isResolved ? 'Re-test' : 'Solve',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isResolved ? const Color(0xFF34D399) : Colors.white,
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecallSolveScreen(formula: m.prompt, mistake: m),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _mistakeFilterChip(String id, String label, IconData icon) {
    bool isSelected = _selectedMistakeFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 13,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primaryLight,
        backgroundColor: AppTheme.surface,
        side: BorderSide(color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
        onSelected: (_) {
          HapticFeedback.selectionClick();
          setState(() => _selectedMistakeFilter = id);
        },
      ),
    );
  }

  Widget _buildEmptyMistakesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, size: 54, color: AppTheme.accent),
            ),
            const SizedBox(height: 18),
            const Text(
              'Zero Mistakes Logged!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Any calculation error you make while practicing will automatically be filed here for targeted re-drilling.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearMistakes(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear Mistakes?'),
        content: const Text('Are you sure you want to remove all saved mistake questions?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              state.clearAllMistakes();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _startRevisionQuiz(BuildContext context, List<MistakeModel> mistakes) {
    if (mistakes.isEmpty) return;
    List<QuestionModel> revQuestions = mistakes.map((m) {
      int? ansInt = int.tryParse(m.correctAnswer);
      Set<String> opts = {m.correctAnswer};
      if (ansInt != null) {
        if (ansInt.abs() < 10) {
          final pool = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5]..shuffle();
          for (int d in pool) {
            if (opts.length >= 4) break;
            int cand = ansInt + d;
            if (cand >= 0 && cand != ansInt) {
              opts.add('$cand');
            }
          }
          int step = 1;
          while (opts.length < 4) {
            if (ansInt + step >= 0) opts.add('${ansInt + step}');
            if (opts.length < 4 && ansInt - step >= 0) opts.add('${ansInt - step}');
            step++;
          }
        } else {
          int unit = (ansInt % 10).abs();
          int? userAnsInt = int.tryParse(m.userAnswer);
          if (userAnsInt != null && (userAnsInt % 10).abs() == unit && userAnsInt > 0) {
            opts.add(m.userAnswer);
          }
          int step = 1;
          while (opts.length < 4) {
            int plus = ansInt + (10 * step);
            if (plus > 0 && plus % 10 == unit) opts.add('$plus');
            if (opts.length < 4) {
              int minus = ansInt - (10 * step);
              if (minus > 0 && minus % 10 == unit) opts.add('$minus');
            }
            step++;
          }
        }
      } else {
        // Non-integer answer: e.g. percentage, fraction, decimal, or formula
        if (m.userAnswer.isNotEmpty && m.userAnswer != m.correctAnswer) {
          opts.add(m.userAnswer);
        }

        final cleanAns = m.correctAnswer.trim();
        if (cleanAns.endsWith('%')) {
          // Contextual percentage distractors
          double? pVal = double.tryParse(cleanAns.replaceAll('%', '').trim());
          if (pVal != null) {
            final deltas = [5.0, -5.0, 10.0, -10.0, 2.5, -2.5, 1.0, -1.0];
            for (double d in deltas) {
              if (opts.length >= 4) break;
              double cand = pVal + d;
              if (cand > 0) {
                opts.add(cand == cand.roundToDouble() ? '${cand.toInt()}%' : '${cand.toStringAsFixed(2)}%');
              }
            }
          }
          for (var f in ContentRepository.fractionData) {
            if (opts.length >= 4) break;
            final p = f['percent']!;
            if (!opts.contains(p)) opts.add(p);
          }
        } else if (cleanAns.contains('/')) {
          // Contextual fraction distractors
          for (var f in ContentRepository.fractionData) {
            if (opts.length >= 4) break;
            final frac = f['fraction']!;
            if (!opts.contains(frac)) opts.add(frac);
          }
        } else if (double.tryParse(cleanAns) != null) {
          // Contextual decimal distractors
          double dVal = double.parse(cleanAns);
          final deltas = [0.1, -0.1, 0.05, -0.05, 0.25, -0.25];
          for (double d in deltas) {
            if (opts.length >= 4) break;
            double cand = dVal + d;
            if (cand > 0) {
              opts.add(cand.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''));
            }
          }
        } else {
          // Contextual formula or unit text (e.g. '5 cm' or '120 m')
          final matchNum = RegExp(r'(\d+)').firstMatch(cleanAns);
          if (matchNum != null) {
            int baseNum = int.parse(matchNum.group(1)!);
            final prefix = cleanAns.substring(0, matchNum.start);
            final suffix = cleanAns.substring(matchNum.end);
            for (int diff in [2, -2, 4, -4, 10, -10]) {
              if (opts.length >= 4) break;
              int cand = baseNum + diff;
              if (cand > 0) opts.add('$prefix$cand$suffix');
            }
          }
        }

        int fallbackStep = 1;
        while (opts.length < 4) {
          opts.add('$cleanAns +$fallbackStep');
          fallbackStep++;
        }
      }
      List<String> listOpts = opts.take(4).toList()..shuffle();

      return QuestionModel(
        id: m.id,
        topicId: m.topicId,
        prompt: m.prompt,
        correctAnswer: m.correctAnswer,
        options: listOpts,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: 'revision',
            title: 'Mistake Revision Drill',
            subtitle: 'Re-attempting saved mistakes',
            type: TopicType.custom,
            iconName: 'history',
          ),
          customQuestions: revQuestions,
          isTimed: true,
          questionCount: revQuestions.length,
        ),
      ),
    );
  }
}

class _AppContentEntry {
  final String title;
  final String question;
  final String answer;
  final String category;
  final String notes;

  const _AppContentEntry({
    required this.title,
    required this.question,
    required this.answer,
    required this.category,
    this.notes = '',
  });
}
