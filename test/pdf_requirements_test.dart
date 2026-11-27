import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/data/content_repository.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';
import 'package:math_speed_practice/data/product_chauraha_repository.dart';
import 'package:math_speed_practice/data/vedic_tricks_repository.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/screens/practice/practice_quiz_screen.dart';
import 'package:math_speed_practice/screens/practice/recall_solve_screen.dart';
import 'package:math_speed_practice/screens/progress/weakness_heatmap_screen.dart';
import 'package:math_speed_practice/services/notification_service.dart';
import 'package:math_speed_practice/widgets/crossroads_108_logo.dart';
import 'package:math_speed_practice/widgets/daily_planner_card.dart';
import 'package:math_speed_practice/widgets/tactile_numpad.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('1-4. Dynamic questions keep close options for small answers (<= 25) and zero Viral text', () {
    for (int i = 0; i < 4; i++) {
      final qs = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.subtraction,
        digits: 1,
        count: 20,
        maxNumberLimit: 20,
      );
      for (final q in qs) {
        final ans = int.parse(q.correctAnswer);
        for (final opt in q.options) {
          final optInt = int.parse(opt);
          expect((optInt - ans).abs(), lessThanOrEqualTo(6),
              reason: 'Small answer $ans had wide option $opt in ${q.options}');
        }
        expect(q.explanation.toLowerCase().contains('viral'), isFalse);
      }
    }

    for (final t in VedicTricksRepository.tricks) {
      expect(t.title.toLowerCase().contains('viral'), isFalse);
      expect(t.sutraName.toLowerCase().contains('viral'), isFalse);
    }
  });

  test('6 & 8. Tables and Multiplication have separate dedicated sections and Crossroads', () {
    final topics = ContentRepository.getDefaultTopics();
    expect(topics.any((t) => t.id == 'tables'), isTrue);
    expect(topics.any((t) => t.id == 'hard_multiplier'), isTrue);
    expect(topics.any((t) => t.title.toLowerCase().contains('chauraha')), isFalse);
    expect(topics.any((t) => t.title.contains('Crossroads')), isTrue);

    for (final item in ProductChaurahaRepository.getAll()) {
      expect(item.title.toLowerCase().contains('chauraha'), isFalse);
      expect(item.title.contains('Crossroads') || item.isBaseFormat, isTrue);
    }
  });

  testWidgets('7. DailyPlannerCard allows adding and removing revision items', (tester) async {
    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: DailyPlannerCard())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily planner for Speed revision'), findsOneWidget);

    await provider.addRevisionItem(
      RevisionItemModel(
        id: 'test_17',
        title: 'Table of 17 Custom',
        question: '17 × 8',
        answer: '136',
        category: 'Tables',
        createdAt: DateTime.now(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Table of 17 Custom'), findsOneWidget);

    await provider.deleteRevisionItem('test_17');
    await tester.pumpAndSettle();
    expect(find.text('Table of 17 Custom'), findsNothing);
  });

  testWidgets('8. Crossroads108Logo renders 108 and crossroads arms', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Crossroads108Logo(size: 58))),
      ),
    );
    expect(find.text('108'), findsOneWidget);
    expect(find.text('12×9'), findsOneWidget);
  });

  testWidgets('9. AI Heatmap shows Unattempted items as New instead of Fast', (tester) async {
    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: WeaknessHeatmapScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Unattempted'), findsOneWidget);
    expect(find.text('New'), findsWidgets);
    // Only the single legend label says "Fast" — zero cells should default to green Fast
    expect(find.text('Fast'), findsOneWidget);
  });

  testWidgets('11 & 3. Hard Mode (5s / Q) opens Numpad by default and shows Quick Tip button', (tester) async {
    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: PracticeQuizScreen(
            topic: TopicModel(
              id: 'subtraction_2d',
              title: 'Speed Subtraction (Two Digit)',
              subtitle: '2-Digit Drill',
              type: TopicType.subtraction,
              iconName: 'remove_rounded',
            ),
            customQuestions: [
              QuestionModel(
                id: 'q1',
                topicId: 'subtraction',
                prompt: '42 - 15 = ?',
                correctAnswer: '27',
                options: ['25', '26', '27', '28'],
              ),
            ],
            isTimed: true,
            perQuestionSeconds: 5.0,
            questionCount: 1,
            initialUseNumpad: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TactileNumpad), findsOneWidget);
    expect(find.text('Quick Tip'), findsOneWidget);

    await tester.tap(find.text('Quick Tip'));
    await tester.pumpAndSettle();
    expect(find.text('⏸ Paused'), findsOneWidget);
    expect(find.text('Resume Practice'), findsOneWidget);
  });

  testWidgets('RecallSolveScreen never renders blank "= ?" for prompts ending with colon or % answers', (tester) async {
    expect(NotificationService().cleanPrompt('Select 2 pairs of 108:'), 'Select 2 pairs of 108');
    expect(NotificationService().cleanPrompt('Table 17: 17 × 6 = ?'), '17 × 6');

    final mistake = MistakeModel(
      id: 'm_colon',
      prompt: 'Select 2 pairs of 108:',
      userAnswer: '12 × 8',
      correctAnswer: '108',
      topicId: 'product_crossroads',
      timestamp: DateTime.now(),
    );

    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: RecallSolveScreen(formula: mistake.prompt, mistake: mistake),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(' = ?'), findsNothing);
    expect(find.textContaining('108'), findsWidgets);
  });

  testWidgets('English mistakes do NOT leak into Math Recall queue and RecallSolveScreen never shows 0/1/2/3 for Discreet', (tester) async {
    final provider = AppStateProvider();
    await provider.recordEnglishAnswer(
      isCorrect: false,
      questionId: 't_discreet',
      questionText: 'Select the SYNONYM of Discreet:',
      options: ['Careless', 'Circumspect', 'Hasty', 'Loud'],
      correctIndex: 1,
      selectedIndex: 0,
      explanation: 'Discreet means careful and circumspect.',
    );

    expect(provider.englishMistakes.any((m) => m.id == 't_discreet'), isTrue);
    expect(provider.mistakes.any((m) => m.topicId.toLowerCase().startsWith('english')), isFalse);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: RecallSolveScreen(
            formula: 'Select the SYNONYM of Discreet:',
            mistake: MistakeModel(
              id: 'legacy_eng',
              prompt: 'Select the SYNONYM of Discreet:',
              userAnswer: 'Careless',
              correctAnswer: 'Circumspect',
              topicId: 'English: Verbal',
              timestamp: DateTime.now(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Circumspect'), findsOneWidget);
    expect(find.text('Select the SYNONYM of Discreet = ?'), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('RecallSolveScreen handles English prompt with = ? and null mistake by showing real words and never math 0/1/2/3', (tester) async {
    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: RecallSolveScreen(
            formula: 'Select the SYNONYM of Discreet = ?',
            mistake: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Must show VOCABULARY & ENGLISH RECALL header, not math
    expect(find.text('VOCABULARY & ENGLISH RECALL'), findsOneWidget);
    expect(find.text('WHAT IS THE RESULT?'), findsNothing);
    // Question must NOT end with = ?
    expect(find.text('Select the SYNONYM of Discreet = ?'), findsNothing);
    // Must never show math 0, 1, 2, 3
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsNothing);
    expect(find.text('3'), findsNothing);
    // Must show real English words from content bank for Discreet
    expect(find.text('Careful'), findsOneWidget);
  });

  testWidgets('RecallSolveScreen handles typed answer mode for maths revision with explanation and retry (PDF Spec Section 3)', (tester) async {
    final mistake = MistakeModel(
      id: 'm_anim_reset',
      prompt: '14 × 6 = ?',
      userAnswer: '74',
      correctAnswer: '84',
      topicId: 'tables',
      timestamp: DateTime.now(),
    );

    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: RecallSolveScreen(formula: mistake.prompt, mistake: mistake),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifies PDF Spec Section 3: "Write your answer" prompt and Submit button
    expect(find.text('Write your answer'), findsOneWidget);
    expect(find.text('Submit Answer'), findsOneWidget);

    // Enter wrong answer '74'
    await tester.enterText(find.byType(TextField), '74');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit Answer'));
    await tester.pumpAndSettle();

    // Verifies: error feedback, explanation/solution breakdown, and Try Again button
    expect(find.textContaining('Incorrect (74)'), findsOneWidget);
    expect(find.textContaining('84'), findsWidgets);
    expect(find.text('Try Again'), findsOneWidget);

    // Tap Try Again -> resets input field so user can re-attempt
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('Write your answer'), findsOneWidget);

    // Enter correct answer '84' and submit -> shows green celebration and closes
    await tester.enterText(find.byType(TextField), '84');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit Answer'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Correct!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
  });

  test('8-Stage Spaced Revision Schedule Timetable (PDF Specification Section 2)', () {
    final notifService = NotificationService();
    final mistakeTime = DateTime(2026, 11, 1, 12, 0); // 12:00 PM (outside quiet hours)

    // Stage 1: 1 hour after mistake
    final stage1Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 1,
      fromTime: mistakeTime,
    );
    expect(stage1Due.difference(mistakeTime).inHours, equals(1));

    // Stage 2: 4 hours after Stage 1
    final stage2Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 2,
      fromTime: stage1Due,
    );
    expect(stage2Due.difference(stage1Due).inHours, equals(4));

    // Stage 3: 4 hours after Stage 2
    final stage3Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 3,
      fromTime: stage2Due,
    );
    expect(stage3Due.difference(stage2Due).inHours, equals(4));

    // Stage 4: Day 2 (24 hours from original mistake)
    final stage4Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 4,
      fromTime: mistakeTime,
    );
    expect(stage4Due.difference(mistakeTime).inDays, equals(1));

    // Stage 5: Day 7 (7 days from original mistake)
    final stage5Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 5,
      fromTime: mistakeTime,
    );
    expect(stage5Due.difference(mistakeTime).inDays, equals(7));

    // Stage 6: Day 15 (15 days from original mistake)
    final stage6Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 6,
      fromTime: mistakeTime,
    );
    expect(stage6Due.difference(mistakeTime).inDays, equals(15));

    // Stage 7: Day 30 (30 days from original mistake)
    final stage7Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 7,
      fromTime: mistakeTime,
    );
    expect(stage7Due.difference(mistakeTime).inDays, equals(30));

    // Stage 8: 2 months (~60 days from original mistake)
    final stage8Due = notifService.computeNextDueTime(
      originalMistakeTime: mistakeTime,
      nextStage: 8,
      fromTime: mistakeTime,
    );
    expect(stage8Due.difference(mistakeTime).inDays, equals(60));
  });

  test('Quiet Hours Guard: Late-night reminders (10 PM to 8 AM) shift to 8:30 AM next morning', () {
    final notifService = NotificationService();

    // 11:30 PM (23:30) -> should shift to next day 8:30 AM
    final lateNight = DateTime(2026, 11, 1, 23, 30);
    final guarded = notifService.applyQuietHoursGuard(lateNight);
    expect(guarded.day, equals(2));
    expect(guarded.hour, equals(8));
    expect(guarded.minute, equals(30));

    // 3:00 AM (03:00) -> should shift to same day 8:30 AM
    final earlyMorning = DateTime(2026, 11, 2, 3, 0);
    final guardedEarly = notifService.applyQuietHoursGuard(earlyMorning);
    expect(guardedEarly.day, equals(2));
    expect(guardedEarly.hour, equals(8));
    expect(guardedEarly.minute, equals(30));

    // 2:00 PM (14:00) -> Daytime: untouched
    final daytime = DateTime(2026, 11, 2, 14, 0);
    final guardedDay = notifService.applyQuietHoursGuard(daytime);
    expect(guardedDay, equals(daytime));
  });

  test('Notification custom sound files are capped within 4 seconds duration', () {
    final assetSound = File('assets/sounds/custom_notification_sound.mp3');
    final rawSound = File('android/app/src/main/res/raw/custom_notification_sound.mp3');
    expect(assetSound.existsSync(), isTrue);
    expect(rawSound.existsSync(), isTrue);
    // 160 kbps CBR MP3 @ 4s = 80,000 bytes max (trimmed to 166 frames = 79,680 bytes = 3.984s)
    expect(assetSound.lengthSync(), lessThanOrEqualTo(82000));
    expect(rawSound.lengthSync(), lessThanOrEqualTo(82000));
  });
}
