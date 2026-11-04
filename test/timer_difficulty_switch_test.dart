import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/screens/practice/practice_quiz_screen.dart';
import 'package:math_speed_practice/services/notification_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    NotificationService().cancelAllTimers();
  });

  testWidgets('PracticeQuizScreen timer difficulty pill switches to Easy, Hard, and Med smoothly', (WidgetTester tester) async {
    final state = AppStateProvider();

    final testTopic = TopicModel(
      id: 'table_7',
      title: 'Table 7 Speed Drill',
      subtitle: 'Targeted Table Mastery',
      type: TopicType.tables,
      iconName: 'grid_view_rounded',
    );

    final questions = [
      QuestionModel(
        id: 'q1',
        prompt: '7 × 8 = ?',
        options: ['56', '54', '48', '62'],
        correctAnswer: '56',
        explanation: '7 × 8 = 56',
        topicId: 'table_7',
      ),
      QuestionModel(
        id: 'q2',
        prompt: '7 × 9 = ?',
        options: ['63', '61', '58', '65'],
        correctAnswer: '63',
        explanation: '7 × 9 = 63',
        topicId: 'table_7',
      ),
    ];

    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: state,
        child: MaterialApp(
          home: PracticeQuizScreen(
            topic: testTopic,
            customQuestions: questions,
            isTimed: true,
            perQuestionSeconds: 10.0,
            questionCount: 2,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Initially in Medium Pace: displays 'Med (10s)'
    expect(find.text('Med (10s)'), findsOneWidget);

    // Tap on the timer pill to open PopupMenu
    await tester.tap(find.text('Med (10s)'));
    await tester.pumpAndSettle();

    // Verify popup menu items are visible
    expect(find.text('Easy (No Timer)'), findsOneWidget);
    expect(find.text('Medium (10s / Q)'), findsOneWidget);
    expect(find.text('Hard (5s / Q)'), findsOneWidget);

    // Tap on 'Easy (No Timer)'
    await tester.tap(find.text('Easy (No Timer)'));
    await tester.pumpAndSettle();

    // Verify it changed to 'Easy' mode!
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Med (10s)'), findsNothing);

    // Open menu again from 'Easy'
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    // Select 'Hard (5s / Q)'
    await tester.tap(find.text('Hard (5s / Q)'));
    await tester.pumpAndSettle();

    // Verify it changed to 'Hard (5s)'
    expect(find.text('Hard (5s)'), findsOneWidget);
    expect(find.text('Easy'), findsNothing);

    // Open menu again from 'Hard (5s)'
    await tester.tap(find.text('Hard (5s)'));
    await tester.pumpAndSettle();

    // Select 'Medium (10s / Q)'
    await tester.tap(find.text('Medium (10s / Q)'));
    await tester.pumpAndSettle();

    // Verify it returned to 'Med (10s)'
    expect(find.text('Med (10s)'), findsOneWidget);
    expect(find.text('Hard (5s)'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    NotificationService().cancelAllTimers();
  });
}
