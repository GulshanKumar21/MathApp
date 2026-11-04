import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import 'home/home_screen.dart';
import 'revision/revision_screen.dart';
import 'progress/progress_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'alarm/math_alarm_hub_screen.dart';
import 'english/english_hub_screen.dart';
import 'concepts/concepts_hub_screen.dart';
import '../services/notification_service.dart';

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;
  int _previousSection = 0;

  final List<Widget> _mathScreens = const [
    HomeScreen(),
    ConceptsHubScreen(),
    RevisionScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    // DEDICATED ADMIN PORTAL WORKSPACE:
    // When logged in as Admin, the app stays strictly in the Admin Portal!
    // Admin is never turned into or shown as a normal user.
    if (state.isAdmin) {
      return const AdminPanelScreen();
    }

    final int currentSection = state.currentAppSection;
    final bool isMovingRight = currentSection >= _previousSection;
    _previousSection = currentSection;

    // Flipkart & Swiggy 3-Department Hierarchy:
    // 0 = Math (Full Speed Math practice, quizzes, tables, modules, analytics)
    // 1 = Alarm (Dedicated Math Wake-Up Alarm Command Hub with anti-snooze protocol)
    // 2 = English (Dedicated English verbal preparation hub with Coming Soon badge)
    Widget activeBody;
    if (currentSection == 1) {
      activeBody = const KeyedSubtree(
        key: ValueKey<int>(1),
        child: MathAlarmHubScreen(isRootTab: true),
      );
    } else if (currentSection == 2) {
      activeBody = const KeyedSubtree(
        key: ValueKey<int>(2),
        child: EnglishHubScreen(),
      );
    } else {
      activeBody = KeyedSubtree(
        key: const ValueKey<int>(0),
        child: IndexedStack(
          index: _currentIndex,
          children: _mathScreens,
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // If Admin is temporarily testing student view, display clear return banner
          if (state.isAdmin && state.isAdminStudentPreview)
            SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Admin Previewing Student View',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 14),
                      label: const Text('Back to Admin Portal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => state.setAdminStudentPreview(false),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final slideAnim = Tween<Offset>(
                  begin: Offset(isMovingRight ? 0.22 : -0.22, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  child: SlideTransition(
                    position: slideAnim,
                    child: child,
                  ),
                );
              },
              child: activeBody,
            ),
          ),
        ],
      ),
      bottomNavigationBar: currentSection == 0
          ? Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(color: AppTheme.surfaceLight, width: 1),
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  indicatorColor: AppTheme.primaryLight.withValues(alpha: 0.18),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11);
                    }
                    return const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 11);
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: AppTheme.primaryLight, size: 24);
                    }
                    return const IconThemeData(color: AppTheme.textSecondary, size: 22);
                  }),
                ),
                child: NavigationBar(
                  height: 64,
                  elevation: 0,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) {
                    setState(() => _currentIndex = idx);
                    // NOTE: Do NOT call triggerPendingMistakeNotificationOnHome() here.
                    // Notifications fire via zonedSchedule/alarm after 1hr/3hr delay.
                    // Calling it here would post notifications while app is open.
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.flash_on_outlined),
                      selectedIcon: Icon(Icons.flash_on_rounded),
                      label: 'Speed Math',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.functions_outlined),
                      selectedIcon: Icon(Icons.functions_rounded),
                      label: 'Concepts',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history_edu_outlined),
                      selectedIcon: Icon(Icons.history_edu_rounded),
                      label: 'Revision',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics_rounded),
                      label: 'Progress',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.account_circle_outlined),
                      selectedIcon: Icon(Icons.account_circle_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
