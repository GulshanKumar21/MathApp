import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../data/dynamic_question_engine.dart';
import 'practice_quiz_screen.dart';
import '../auth/auth_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late List<QuestionModel> _todaysSet;

  @override
  void initState() {
    super.initState();
    // Daily set generated dynamically based on today's calendar date seed
    _todaysSet = DynamicQuestionEngine.generateDailyChallengeSet(DateTime.now(), count: 15);
  }
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final customQs = state.adminQuestions;
    final activeQuestions = customQs.isNotEmpty ? customQs : _todaysSet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Daily Speed Target & Streak'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          customQs.isNotEmpty ? 'ADMIN HAND-PICKED' : 'FRESH DAILY DRILL',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Today's Non-Repeating Speed Challenge",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Complete this set today to maintain your consecutive daily study streak. Missing a day resets streak to 0!",
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Question Set", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${activeQuestions.length} Fresh Qs', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            ...activeQuestions.map((q) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star_rounded, color: AppTheme.gold, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          q.prompt,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.check_circle_outline, color: Colors.white24, size: 20),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Daily Streak Challenge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () {
                if (state.isGuestLimitReached) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthScreen(
                        initialIsLogin: false,
                        isMandatory: true,
                      ),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PracticeQuizScreen(
                      topic: TopicModel(
                        id: 'daily_challenge',
                        title: 'Daily Streak Target',
                        subtitle: 'Non-repeating calculation set',
                        type: TopicType.custom,
                        iconName: 'star',
                      ),
                      customQuestions: activeQuestions,
                      isTimed: true,
                      questionCount: activeQuestions.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
