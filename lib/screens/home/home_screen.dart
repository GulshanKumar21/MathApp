import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import '../../widgets/daily_planner_card.dart';
import '../../widgets/crossroads_108_logo.dart';
import '../../widgets/animated_quick_tray.dart';
import '../../widgets/animated_streak_badge.dart';
import '../../widgets/swiggy_floating_action_pill.dart';
import '../../widgets/bouncing_card.dart';
import '../practice/learn_mode_screen.dart';
import '../practice/practice_quiz_screen.dart';
import '../practice/survival_rush_screen.dart';
import '../practice/numpad_drill_screen.dart';
import '../practice/daily_challenge_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../notifications/notifications_inbox_screen.dart';
import '../practice/exam_mock_hub_screen.dart';
import '../practice/calculation_modules_hub_screen.dart';
import '../progress/weakness_heatmap_screen.dart';
import '../revision/table_revision_hub_screen.dart';
import '../revision/powers_revision_hub_screen.dart';
import '../revision/pdf_sheet_hub_screen.dart';
import '../revision/product_chauraha_hub_screen.dart';
import '../practice/arithmetic_digit_selection_screen.dart';
import '../../widgets/mental_speedometer_card.dart';
import '../tricks/interactive_vedic_simulator_screen.dart';
import '../auth/auth_screen.dart';
import '../../widgets/swiggy_flipkart_section_bar.dart';
import '../../widgets/speed_math_3d_logo.dart';
import '../../main.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    NotificationService().triggerPendingMistakeNotificationOnHome();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().triggerPendingMistakeNotificationOnHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SpeedMath3DLogo(size: 34),
        ),
        actions: [
          // Notifications Inbox Bell Icon
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white70, size: 23),
                if (state.broadcasts.isNotEmpty)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.broadcasts.length > 9 ? '9+' : state.broadcasts.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Announcements',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()));
            },
          ),
          // Dynamic Animated Streak Badge
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: AnimatedStreakBadge(
              streakDays: state.streakDays,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyChallengeScreen()));
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 🚀 Top 3D Speed Math & Alarm Bar (Enhanced 3D Segmented Controls)
            const SwiggyFlipkartSectionBar(),
            const SizedBox(height: 10),

            // 2. 🔴 1-HR RECALL ALERT CARD (Placed directly below Speed Math & Alarm Bar)
            if (state.mistakes.isNotEmpty) ...[
              SwiggyFloatingActionPill(
                mistakes: state.mistakes,
                activePlan: state.activeStudyPlan,
                isPlanDue: state.isStudyPlanDueNow,
              ),
              const SizedBox(height: 14),
            ],

            // 0. 🚀 Guest Preview Trial Barrier Banner (Shows if user is not signed in)
            if (!state.isLoggedIn) ...[
              _buildGuestTrialBanner(context, state),
              const SizedBox(height: 14),
            ],

            // 🌟 1. CORE CALCULATION PRACTICE SECTION (ALL MODULES DIRECT ON TOP & OUTSIDE)
            _buildCoreCalculationPracticeSection(context, state),
            const SizedBox(height: 18),

            // 2. 📅 Daily Planner for Speed Revision (Add & Remove items to memorize)
            const DailyPlannerCard(),
            const SizedBox(height: 18),

            // 3. 🏎️ Mental Calculation Speedometer (RPM Gauge)
            MentalSpeedometerCard(
              avgSpeedSeconds: state.overallAvgSpeedSeconds,
              totalQuestionsSolved: state.totalQuestionsAttempted,
              targetExam: state.targetExam,
            ),
            const SizedBox(height: 18),

            // 5. ⚡ Swiggy-Style Horizontal Quick Categories / Action Tray (ZERO DUPLICATES)
            AnimatedQuickTray(
              items: [
                QuickActionItem(
                  title: 'Crossroads',
                  badge: 'NEW',
                  icon: Icons.alt_route_rounded,
                  customIcon: const Crossroads108Logo(size: 46),
                  gradientColors: const [Color(0xFF2A2312), Color(0xFF1C180C)],
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductChaurahaHubScreen())),
                ),
                QuickActionItem(
                  title: 'Vedic Tricks',
                  badge: 'HACKS',
                  icon: Icons.psychology_rounded,
                  gradientColors: const [Color(0xFF26214A), Color(0xFF181530)],
                  iconColor: const Color(0xFFA78BFA),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InteractiveVedicSimulatorScreen())),
                ),
                QuickActionItem(
                  title: 'Exam Mocks',
                  badge: 'MOCKS',
                  icon: Icons.timer_rounded,
                  gradientColors: const [Color(0xFF1B2A4A), Color(0xFF121C33)],
                  iconColor: const Color(0xFF60A5FA),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamMockHubScreen())),
                ),
                QuickActionItem(
                  title: 'Leaderboard',
                  badge: 'RANK',
                  icon: Icons.leaderboard_rounded,
                  gradientColors: const [Color(0xFF332A18), Color(0xFF221C10)],
                  iconColor: const Color(0xFFFBBF24),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                ),
                QuickActionItem(
                  title: 'PDF Sheet',
                  badge: 'NOTES',
                  icon: Icons.picture_as_pdf_rounded,
                  gradientColors: const [Color(0xFF351C2C), Color(0xFF23121D)],
                  iconColor: const Color(0xFFF472B6),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfSheetHubScreen())),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 5.1. 🧠 AI Speed & Weakness Heatmap Highlight Card
            _buildAIHeatmapHighlightCard(context, state),
            const SizedBox(height: 18),



            // 7. 🔥 High-Intensity Speed Drills (Survival Blitz & Numpad Speed Drill)
            const Text(
              '🔥 High-Intensity Speed Drills',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _drillActionCard(
                    title: 'Speed Blitz',
                    sub: '5s • 15 Tricks Qs',
                    icon: Icons.bolt_rounded,
                    color: AppTheme.error,
                    onTap: () {
                      if (state.isGuestLimitReached) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen(initialIsLogin: false, isMandatory: true)));
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SurvivalRushScreen()));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _drillActionCard(
                    title: 'Numpad Drill',
                    sub: 'Direct Key Speed',
                    icon: Icons.keyboard_alt_rounded,
                    color: AppTheme.accent,
                    onTap: () {
                      if (state.isGuestLimitReached) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen(initialIsLogin: false, isMandatory: true)));
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NumpadDrillScreen()));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 8. 📚 Calculation Tricks & Learning Vault (Formulas, Vedic Hacks & All 8 Modules)
            _buildCalculationModulesVaultButton(context, state),
          ],
        ),
      ),
    );
  }

  Widget _drillActionCard({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncingCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161F30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF222F44), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                sub,
                style: const TextStyle(fontSize: 10.5, color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Master Card for Calculation Tricks & Learning Vault
  Widget _buildCalculationModulesVaultButton(BuildContext context, AppStateProvider state) {
    final bool isPro = state.isPremium;

    return BouncingCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalculationModulesHubScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827), // Clean Slate 900
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPro ? const Color(0xFF059669) : const Color(0xFF1F2937),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF222F44)),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: isPro ? const Color(0xFF34D399) : const Color(0xFF818CF8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Calculation Tricks Vault',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPro ? const Color(0xFF10B981) : AppTheme.gold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPro ? 'PRO ACTIVE' : 'LEARN & TRICKS',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Read Vedic hacks, formulas & speed tricks for Tables, Squares, Cubes, Multipliers & more',
                        style: TextStyle(fontSize: 11.5, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '📖 8 Complete Modules with Speed Tricks',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 🎯 1. CORE CALCULATION PRACTICE SECTION (ALL 8 MODULES ON THE OUTSIDE AT THE TOP!) ---
  Widget _buildCoreCalculationPracticeSection(BuildContext context, AppStateProvider state) {
    final modules = [
      {
        'title': 'Addition',
        'sub': '1, 2, 3 & 4-Digit Fast Add',
        'type': TopicType.addition,
        'icon': Icons.add_rounded,
        'color': const Color(0xFF38BDF8), // Sky Blue
        'tag': '1D–4D',
      },
      {
        'title': 'Subtraction',
        'sub': '1, 2, 3 & 4-Digit Minus',
        'type': TopicType.subtraction,
        'icon': Icons.remove_rounded,
        'color': const Color(0xFF60A5FA), // Cobalt Blue
        'tag': '1D–4D',
      },
      {
        'title': 'Division',
        'sub': '1, 2, 3 & 4-Digit Rapid Divide',
        'type': TopicType.division,
        'icon': Icons.safety_divider_rounded,
        'color': const Color(0xFF2DD4BF), // Teal Cyan
        'tag': '1D–4D',
      },
      {
        'title': 'Tables & Multiply',
        'sub': 'Tables 1–50 & 1D–4D Speed Multiply',
        'type': TopicType.tables,
        'icon': Icons.grid_view_rounded,
        'color': const Color(0xFF818CF8), // Indigo Accent
        'tag': '1–50 & ×',
      },
      {
        'title': 'Pythagorean Triples',
        'sub': 'Base Triples (3-4-5, 5-12-13...)',
        'type': TopicType.triples,
        'icon': Icons.change_history_rounded,
        'color': const Color(0xFFA78BFA), // Soft Purple
        'tag': 'TRIPLES',
      },
      {
        'title': 'Squares (1–50)',
        'sub': 'Squares & Square Roots',
        'type': TopicType.squares,
        'icon': Icons.crop_square_rounded,
        'color': const Color(0xFFFBBF24), // Warm Gold
        'tag': '1–50',
      },
      {
        'title': 'Cubes (1–30)',
        'sub': 'Cubes & Cube Roots',
        'type': TopicType.cubes,
        'icon': Icons.view_in_ar_rounded,
        'color': const Color(0xFFF472B6), // Rose Quartz
        'tag': '1–30',
      },
      {
        'title': 'Fractions & %',
        'sub': '1/2 to 1/25 Percentage Values',
        'type': TopicType.fractions,
        'icon': Icons.percent_rounded,
        'color': const Color(0xFF34D399), // Mint Emerald
        'tag': '% CONVERT',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Clean Tailwind Slate 900
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2937), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155), width: 1.0),
                ),
                child: const Icon(Icons.calculate_rounded, color: Color(0xFF818CF8), size: 19),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Core Calculation Practice',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Tap any module to start 10-question rapid drill',
                      style: TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CalculationModulesHubScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 13, color: Color(0xFFCBD5E1)),
                      SizedBox(width: 4),
                      Text(
                        'Learn & Tricks',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFCBD5E1)),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2-Column Grid of All 8 Core Calculation Modules (Clean Horizontal Pill Cards)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.85,
            ),
            itemBuilder: (context, idx) {
              final m = modules[idx];
              final Color color = m['color'] as Color;
              final TopicType type = m['type'] as TopicType;
              final String title = m['title'] as String;
              final String sub = m['sub'] as String;
              final IconData icon = m['icon'] as IconData;

              return BouncingCard(
                onTap: () => _showTopicActionModal(context, state, type, title, sub, icon, color),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30), // Solid elevated slate
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF222F44), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7.5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sub,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white60,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTopicActionModal(
    BuildContext context,
    AppStateProvider state,
    TopicType type,
    String title,
    String sub,
    IconData icon,
    Color color,
  ) {
    final matchedTopic = state.topics.firstWhere(
      (t) => t.type == type,
      orElse: () => TopicModel(
        id: type.name,
        title: title,
        subtitle: sub,
        type: type,
        iconName: 'calculate_rounded',
      ),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 1. Learn & Speed Tricks Button
                BouncingCard(
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LearnModeScreen(topic: matchedTopic)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161F30),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF222F44), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: Color(0xFF818CF8), size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📖 Learn & Speed Tricks',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Read Vedic hacks, formulas & speed rules',
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
                const SizedBox(height: 12),

                // 2. Start Practice Drill Button
                BouncingCard(
                  onTap: () {
                    Navigator.pop(ctx);
                    _startPracticeForTopic(context, state, type, title);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161F30),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.bolt_rounded, color: color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⚡ Start Practice Drill',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Single, Double, Triple digit speed drill',
                                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startPracticeForTopic(BuildContext context, AppStateProvider state, TopicType type, String title) {
    if (state.isGuestLimitReached) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(initialIsLogin: false, isMandatory: true),
        ),
      );
      return;
    }

    // 🎯 If Tables is tapped -> Open the dedicated Table Revision & Audio Hub (1 to 50 Tables)!
    if (type == TopicType.tables) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TableRevisionHubScreen(initialTable: 2),
        ),
      );
      return;
    }

    // 🎯 If Squares or Cubes is tapped -> Open 5-Part Hub (1-50 Squares & 1-30 Cubes)!
    if (type == TopicType.squares) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PowersRevisionHubScreen(isCubes: false),
        ),
      );
      return;
    }
    if (type == TopicType.cubes) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PowersRevisionHubScreen(isCubes: true),
        ),
      );
      return;
    }

    // 🎯 For Addition, Subtraction, Multiplication, Division:
    // Open dedicated Digit Selection Screen (Single, Double, Triple, Four Digit)!
    if (type == TopicType.addition ||
        type == TopicType.subtraction ||
        type == TopicType.hardMultiplier ||
        type == TopicType.division) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArithmeticDigitSelectionScreen(type: type),
        ),
      );
      return;
    }

    final questions = DynamicQuestionEngine.generateUniqueQuestions(type: type, count: 10);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: type.name,
            title: title,
            subtitle: '10-Question Speed Drill',
            type: type,
            iconName: 'calculate_rounded',
          ),
          customQuestions: questions,
          isTimed: true,
          questionCount: 10,
        ),
      ),
    );
  }

  // --- 🚀 GUEST PREVIEW TRIAL STATUS BANNER ---
  Widget _buildGuestTrialBanner(BuildContext context, AppStateProvider state) {
    final isLimitReached = state.isGuestLimitReached;
    final solved = state.guestQuestionsSolved;
    const maxQs = AppStateProvider.maxGuestQuestions;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLimitReached
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : const Color(0xFF1F2937),
          width: 1.0,
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
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AuthScreen(
                  initialIsLogin: !isLimitReached,
                  isMandatory: isLimitReached,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLimitReached
                          ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                          : const Color(0xFF222F44),
                    ),
                  ),
                  child: Icon(
                    isLimitReached ? Icons.lock_clock_rounded : Icons.person_outline_rounded,
                    color: isLimitReached ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              isLimitReached ? 'Trial Limit Reached' : 'Guest Preview Mode',
                              style: TextStyle(
                                color: isLimitReached ? Colors.redAccent : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isLimitReached ? Colors.redAccent : const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$solved/$maxQs Qs Free',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isLimitReached
                            ? 'Solved 3 questions! Free registration required to unlock full quizzes.'
                            : 'Practice 3 questions free, then register for cloud backup & rank.',
                        style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLimitReached
                          ? [Colors.redAccent, const Color(0xFFDC2626)]
                          : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isLimitReached ? 'Register' : 'Register',
                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 🧠 AI SPEED & WEAKNESS HEATMAP HIGHLIGHT CARD ---
  Widget _buildAIHeatmapHighlightCard(BuildContext context, AppStateProvider state) {
    final mistakes = state.mistakes;
    final List<Map<String, dynamic>> heatmapCells = [];

    if (mistakes.isNotEmpty) {
      for (var m in mistakes.take(5)) {
        String label = m.prompt.replaceAll(' = ?', '').replaceAll('?', '').trim();
        if (label.length > 6) label = label.substring(0, 6);
        heatmapCells.add({'label': label, 'color': AppTheme.error, 'tag': 'Weak'});
      }
    }
    if (state.starredTables.isNotEmpty) {
      for (var tNum in state.starredTables.take(3)) {
        heatmapCells.add({'label': 'T$tNum', 'color': Colors.amber, 'tag': 'Focus'});
      }
    }
    const defaults = [
      {'label': 'T12', 'color': Color(0xFF10B981), 'tag': 'Fast'},
      {'label': 'T14', 'color': Colors.amber, 'tag': 'Avg'},
      {'label': 'Sq16', 'color': Color(0xFF10B981), 'tag': 'Fast'},
      {'label': 'Sq25', 'color': Color(0xFF10B981), 'tag': 'Fast'},
      {'label': 'Cb12', 'color': Colors.amber, 'tag': 'Avg'},
    ];
    for (var d in defaults) {
      if (heatmapCells.length < 8 && !heatmapCells.any((c) => c['label'] == d['label'])) {
        heatmapCells.add(d);
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Clean Tailwind Slate 900
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2937), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161F30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF222F44), width: 1.0),
                      ),
                      child: const Icon(Icons.radar_rounded, color: Color(0xFF34D399), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'AI SPEED & WEAKNESS HEATMAP',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Text(
                            'Live diagnostic calculation matrix active',
                            style: TextStyle(fontSize: 11, color: Colors.white60),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF161F30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.35)),
                ),
                child: const Text(
                  'AI RADAR',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF34D399)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _heatmapLegendDot('Fast (<1.5s)', const Color(0xFF10B981)),
              _heatmapLegendDot('Avg (2-3s)', Colors.amber),
              _heatmapLegendDot('Weak (>3.5s)', AppTheme.error),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: heatmapCells.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cell = heatmapCells[idx];
                final col = cell['color'] as Color;
                return Container(
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: col.withValues(alpha: 0.4), width: 1.0),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cell['label'] as String,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: col),
                      ),
                      Text(
                        cell['tag'] as String,
                        style: TextStyle(fontSize: 8.5, color: col, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFFBBF24), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mistakes.isNotEmpty
                        ? 'AI Alert: ${mistakes.length} bottleneck calculation${mistakes.length > 1 ? "s" : ""} detected. Tap to inspect & clear.'
                        : 'AI Speed Audit: All 30 Tables, 50 Squares & 30 Cubes ready for latency audit.',
                    style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: const Color(0xFF042F2E),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: const Text(
                'Open Full AI Weakness Heatmap & Drills ⚡',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeaknessHeatmapScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatmapLegendDot(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 10.5, color: Colors.white60, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

}
