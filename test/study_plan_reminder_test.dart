import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/models/math_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Tomorrow study plan scheduling and automatic achievement completion loop', () async {
    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    // 1. Student creates a plan for tomorrow: Table of 17 at 9:00 AM
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledTarget = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);

    await provider.setStudyPlan(
      topicId: 'table_17',
      topicTitle: 'Table of 17',
      targetTime: scheduledTarget,
      sampleQuestion: '17 × 7 = ?',
    );

    // Verify study plan is active and stored
    expect(provider.activeStudyPlan, isNotNull);
    expect(provider.activeStudyPlan!.topicTitle, 'Table of 17');
    expect(provider.activeStudyPlan!.topicId, 'table_17');
    expect(provider.activeStudyPlan!.isCompleted, isFalse);
    // Because it's scheduled for tomorrow, it shouldn't be due right now
    expect(provider.isStudyPlanDueNow, isFalse);

    // Verify in-app broadcast announcement
    expect(provider.broadcasts.any((b) => b.title.contains('Study Plan Scheduled: Table of 17')), isTrue);

    // 2. Student practices Table 17
    await provider.recordPracticeResult(
      PracticeResult(
        totalQuestions: 10,
        correctCount: 9,
        wrongCount: 1,
        accuracy: 90.0,
        avgTimeSeconds: 2.1,
        score: 88,
        topicId: 'table_17',
        date: DateTime.now(),
      ),
      [],
    );

    // Verify that active study plan is automatically completed!
    expect(provider.activeStudyPlan!.isCompleted, isTrue);

    // Verify celebration announcement appears
    expect(provider.broadcasts.any((b) => b.title.contains('Target Achieved: Table of 17')), isTrue);
  });
}
