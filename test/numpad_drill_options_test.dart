import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/screens/practice/numpad_drill_screen.dart';
import 'package:math_speed_practice/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    NotificationService().cancelAllTimers();
  });

  Widget createTestWidget({
    TopicType? initialTopicType,
    String? initialSubOption,
    int? initialQuestionCount,
  }) {
    return ChangeNotifierProvider<AppStateProvider>(
      create: (_) => AppStateProvider(),
      child: MaterialApp(
        home: NumpadDrillScreen(
          initialTopicType: initialTopicType,
          initialSubOption: initialSubOption,
          initialQuestionCount: initialQuestionCount,
        ),
      ),
    );
  }

  testWidgets('Numpad Drill renders all topic chips and sub-options', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify key topic chips are present
    expect(find.text('⚡ Mixed Speed'), findsOneWidget);
    expect(find.text('✖️ Tables (1–50)'), findsOneWidget);
    expect(find.text('² Squares (1–50)'), findsOneWidget);

    // Verify settings button & mode toggle
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.text('⌨️ Keypad'), findsOneWidget);
    expect(find.text('🎯 MCQ'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    NotificationService().cancelAllTimers();
  });

  testWidgets('Numpad Drill switches to Tables topic and shows sub-options (1-10, 11-20, Mix, etc.)', (tester) async {
    await tester.pumpWidget(createTestWidget(
      initialTopicType: TopicType.tables,
      initialSubOption: '11-20',
    ));
    await tester.pumpAndSettle();

    // Verify Tables sub-options are rendered
    expect(find.text('1–10 (Easy)'), findsOneWidget);
    expect(find.text('11–20 (Core)'), findsOneWidget);
    expect(find.text('21–30 (Adv)'), findsOneWidget);
    expect(find.text('All 1–50'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    NotificationService().cancelAllTimers();
  });

  testWidgets('Numpad Drill switches between Keypad and MCQ mode', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Initially in Keypad mode -> shows 'TYPE ANSWER DIRECTLY'
    expect(find.text('TYPE ANSWER DIRECTLY'), findsOneWidget);

    // Tap MCQ tab
    await tester.tap(find.text('🎯 MCQ'));
    await tester.pumpAndSettle();

    // Now in MCQ mode -> shows 'SELECT THE CORRECT ANSWER'
    expect(find.text('SELECT THE CORRECT ANSWER'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    NotificationService().cancelAllTimers();
  });

  testWidgets('Numpad Drill opens settings sheet and shows Target Qs & Timer modes', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Open settings sheet
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    // Verify settings sheet content
    expect(find.text('Drill Configuration & Pace'), findsOneWidget);
    expect(find.text('Target Questions:'), findsOneWidget);
    expect(find.text('10 Qs'), findsOneWidget);
    expect(find.text('15 Qs'), findsOneWidget);
    expect(find.text('25 Qs'), findsOneWidget);
    expect(find.text('♾️ Endless'), findsOneWidget);
    expect(find.text('Speed Timer Mode:'), findsOneWidget);
    expect(find.text('No Timer (Untimed)'), findsOneWidget);
    expect(find.text('5s Speed Drill'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    NotificationService().cancelAllTimers();
  });
}
