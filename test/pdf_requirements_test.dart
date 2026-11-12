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

  test('6 & 8. Topics combine Tables & Multiply and rename Chauraha to Crossroads', () {
    final topics = ContentRepository.getDefaultTopics();
    expect(topics.any((t) => t.title.contains('Tables & Speed Multiply')), isTrue);
    expect(topics.any((t) => t.id == 'hard_multiplier'), isFalse);
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
    expect(find.text('108'), findsOneWidget);
  });
}
