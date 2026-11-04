import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedExamFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _examFilters = [
    'All',
    'SSC CGL & CHSL',
    'Banking (IBPS/SBI PO)',
    'Railways & Defense',
    'CAT & MBA',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().fetchRealLeaderboard();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final allEntries = state.leaderboard;

    // Filter by search query and selected exam
    List<LeaderboardEntryModel> filtered = allEntries.where((entry) {
      if (_searchQuery.isNotEmpty &&
          !entry.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedExamFilter != 'All') {
        final exam = entry.targetExam.toLowerCase();
        final filter = _selectedExamFilter.toLowerCase();
        if (filter.contains('ssc')) {
          if (!exam.contains('ssc') && !exam.contains('cgl') && !exam.contains('chsl')) return false;
        } else if (filter.contains('bank')) {
          if (!exam.contains('bank') && !exam.contains('ibps') && !exam.contains('sbi') && !exam.contains('po') && !exam.contains('clerk')) return false;
        } else if (filter.contains('railway')) {
          if (!exam.contains('rail') && !exam.contains('rrb') && !exam.contains('ntpc') && !exam.contains('group d') && !exam.contains('defense') && !exam.contains('defence')) return false;
        } else if (filter.contains('cat')) {
          if (!exam.contains('cat') && !exam.contains('xat') && !exam.contains('mba') && !exam.contains('ipmat')) return false;
        }
      }
      return true;
    }).toList();

    // Find current user's live rank in the entire list
    int currentUserRank = allEntries.indexWhere((e) => e.isCurrentUser);
    if (currentUserRank != -1) {
      currentUserRank += 1; // 1-based rank
    }

    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏆 All-India Speed Leaderboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Real-Time Cloud Firestore Sync',
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: state.isLeaderboardLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold),
                  )
                : const Icon(Icons.refresh_rounded, color: AppTheme.gold),
            tooltip: 'Refresh Real Leaderboard',
            onPressed: state.isLeaderboardLoading
                ? null
                : () async {
                    await state.fetchRealLeaderboard(forceRefresh: true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚡ Live rankings updated from Cloud Database!'),
                          duration: Duration(seconds: 2),
                          backgroundColor: AppTheme.surfaceLight,
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.gold,
        backgroundColor: AppTheme.surface,
        onRefresh: () => state.fetchRealLeaderboard(forceRefresh: true),
        child: state.isLeaderboardLoading && allEntries.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.gold),
                    SizedBox(height: 16),
                    Text(
                      'Connecting to All-India Leaderboard Server...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                children: [
                  // 1. Current User Live Rank Spotlight Card
                  _buildMyLiveRankCard(state, currentUserRank, numberFormat),
                  const SizedBox(height: 16),

                  // 2. Real Podium (Top 3)
                  if (filtered.isNotEmpty) ...[
                    _buildRealPodiumCard(filtered, numberFormat),
                    const SizedBox(height: 20),
                  ],

                  // 3. Search and Exam Filters
                  _buildFilterBar(),
                  const SizedBox(height: 14),

                  // 4. Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Aspirant Rankings (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Colors.greenAccent),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.greenAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 5. Ranking List or Empty State
                  if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    ...List.generate(filtered.length, (index) {
                      final item = filtered[index];
                      // Actual rank is based on sorted index + 1
                      final rank = index + 1;
                      return _buildRankRow(item, rank, numberFormat);
                    }),
                ],
              ),
      ),
    );
  }

  // Spotlight Banner for Current User
  Widget _buildMyLiveRankCard(AppStateProvider state, int myRank, NumberFormat numberFormat) {
    final rankText = myRank > 0 ? '#$myRank' : 'Unranked';
    final ptsText = numberFormat.format(state.liveUserScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.accent, Color(0xFF4338CA)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            state.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppTheme.gold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${state.targetExam} • ${state.totalQuestionsAttempted} Questions Solved',
                      style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rankText,
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const Text(
                    'All-India Rank',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statMiniPill('Total Score', '$ptsText pts', Icons.stars_rounded, AppTheme.gold),
                Container(width: 1, height: 18, color: Colors.white12),
                _statMiniPill('Accuracy', '${state.overallAccuracy.toStringAsFixed(1)}%', Icons.check_circle_outline_rounded, AppTheme.accent),
                Container(width: 1, height: 18, color: Colors.white12),
                _statMiniPill('Streak', '${state.streakDays} Days', Icons.local_fire_department_rounded, Colors.orangeAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statMiniPill(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.white54)),
          ],
        ),
      ],
    );
  }

  // Real Top 3 Podium Card
  Widget _buildRealPodiumCard(List<LeaderboardEntryModel> list, NumberFormat numberFormat) {
    final first = list.isNotEmpty ? list[0] : null;
    final second = list.length > 1 ? list[1] : null;
    final third = list.length > 2 ? list[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium_rounded, color: AppTheme.gold, size: 18),
              SizedBox(width: 6),
              Text(
                'TOP SPEED PODIUM',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place (Silver)
              if (second != null)
                _podiumColumn(second, '2nd', Colors.grey[300]!, 68, numberFormat)
              else
                _emptyPodiumColumn('2nd', Colors.grey[400]!, 68),

              // 1st Place (Gold)
              if (first != null)
                _podiumColumn(first, '1st', AppTheme.gold, 95, numberFormat)
              else
                _emptyPodiumColumn('1st', AppTheme.gold, 95),

              // 3rd Place (Bronze)
              if (third != null)
                _podiumColumn(third, '3rd', const Color(0xFFCD7F32), 56, numberFormat)
              else
                _emptyPodiumColumn('3rd', const Color(0xFFCD7F32), 56),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumColumn(LeaderboardEntryModel item, String place, Color crownColor, double height, NumberFormat numberFormat) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: crownColor, size: place == '1st' ? 32 : 24),
          const SizedBox(height: 4),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: item.isCurrentUser ? AppTheme.accent : Colors.white,
            ),
          ),
          Text(
            '${numberFormat.format(item.score)} pts',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: crownColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: crownColor.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: crownColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  place,
                  style: TextStyle(
                    fontSize: place == '1st' ? 20 : 16,
                    fontWeight: FontWeight.w900,
                    color: crownColor,
                  ),
                ),
                Text(
                  '${item.accuracy.toStringAsFixed(0)}% acc',
                  style: const TextStyle(fontSize: 8.5, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPodiumColumn(String place, Color color, double height) {
    return Expanded(
      child: Column(
        children: [
          Icon(Icons.military_tech_outlined, color: color.withValues(alpha: 0.4), size: 24),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            alignment: Alignment.center,
            child: Text(
              place,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.3)),
            ),
          ),
        ],
      ),
    );
  }

  // Filter Bar (Search + Exam Chips)
  Widget _buildFilterBar() {
    return Column(
      children: [
        // Search Input
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search aspirant by name...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 18),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 10),

        // Exam Filter Chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _examFilters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final filter = _examFilters[idx];
              final isSelected = _selectedExamFilter == filter;
              return ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.gold,
                backgroundColor: AppTheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedExamFilter = filter);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Row Item for each ranked aspirant
  Widget _buildRankRow(LeaderboardEntryModel item, int rank, NumberFormat numberFormat) {
    final isMe = item.isCurrentUser;
    Color rankColor;
    if (rank == 1) {
      rankColor = AppTheme.gold;
    } else if (rank == 2) {
      rankColor = Colors.grey[300]!;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = Colors.white54;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryLight.withValues(alpha: 0.18) : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? AppTheme.accent : AppTheme.surfaceLight.withValues(alpha: 0.5),
          width: isMe ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar Circle with initial
          CircleAvatar(
            radius: 16,
            backgroundColor: isMe ? AppTheme.accent.withValues(alpha: 0.3) : AppTheme.surfaceElevated,
            child: Text(
              item.name.isNotEmpty ? item.name[0].toUpperCase() : 'A',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMe ? AppTheme.accent : Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Aspirant Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isMe ? AppTheme.accent : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppTheme.accent),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.targetExam} • ${item.accuracy.toStringAsFixed(1)}% acc • ${item.streak}d streak',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ),

          // Points Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${numberFormat.format(item.score)} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.gold,
                  fontSize: 14,
                ),
              ),
              if (item.questionsSolved > 0)
                Text(
                  '${item.questionsSolved} solved',
                  style: const TextStyle(fontSize: 9.5, color: Colors.white38),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.military_tech_outlined, size: 44, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'No Aspirants Found',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            _searchQuery.isNotEmpty
                ? 'No matching results for "$_searchQuery". Try clearing your search.'
                : 'Solve your daily practice questions to record your score and claim Rank #1!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
