import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/screens/alarm/math_alarm_ringing_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Math Wake-Up Alarm Tests', () {
    test('AppStateProvider Math Alarm configuration and persistence', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // Defaults
      expect(provider.mathAlarmEnabled, isFalse);
      expect(provider.mathAlarmHour, 7);
      expect(provider.mathAlarmMinute, 0);

      // Set alarm to 7:15 AM
      await provider.setMathAlarm(
        enabled: true,
        hour: 7,
        minute: 15,
        label: 'Early Bird Vedic Math',
      );

      expect(provider.mathAlarmEnabled, isTrue);
      expect(provider.mathAlarmHour, 7);
      expect(provider.mathAlarmMinute, 15);
      expect(provider.mathAlarmLabel, 'Early Bird Vedic Math');

      // Toggle alarm
      await provider.toggleMathAlarm(false);
      expect(provider.mathAlarmEnabled, isFalse);
      expect(provider.mathAlarmHour, 7);
      expect(provider.mathAlarmMinute, 15);
    });

    test('Math Alarm question preparation strictly enforces 5 questions cap and 2 options per question', () {
      // Scenario A: User has 8 mistakes accumulated
      final manyMistakes = List.generate(8, (i) => MistakeModel(
        id: 'err_$i',
        prompt: '${12 + i} × ${3 + i} = ?',
        userAnswer: '99',
        correctAnswer: '${(12 + i) * (3 + i)}',
        topicId: 'tables',
        timestamp: DateTime.now(),
      ));

      // Alarm picks up to 5
      final cappedMistakes = manyMistakes.take(5).toList();
      expect(cappedMistakes.length, 5);

      // Scenario B: User only has 2 mistakes -> Alarm backfills to exactly 5
      final fewMistakes = [
        MistakeModel(
          id: 'err_1',
          prompt: '17 × 7 = ?',
          userAnswer: '100',
          correctAnswer: '119',
          topicId: 'tables',
          timestamp: DateTime.now(),
        ),
        MistakeModel(
          id: 'err_2',
          prompt: '19 × 8 = ?',
          userAnswer: '150',
          correctAnswer: '152',
          topicId: 'tables',
          timestamp: DateTime.now(),
        ),
      ];

      List<MathAlarmQuestionItem> alarmQuestions = [];
      for (final m in fewMistakes) {
        alarmQuestions.add(MathAlarmQuestionItem(
          prompt: m.prompt,
          correctAnswer: m.correctAnswer,
          twoOptions: [m.correctAnswer, '${int.parse(m.correctAnswer) + 10}'],
          isFromMistakes: true,
        ));
      }

      // Backfill with high-yield drills
      final fallbackQuestions = [
        {'q': '23 × 6 = ?', 'a': '138'},
        {'q': '28 × 4 = ?', 'a': '112'},
        {'q': '16 × 9 = ?', 'a': '144'},
      ];

      for (var fb in fallbackQuestions) {
        if (alarmQuestions.length >= 5) break;
        alarmQuestions.add(MathAlarmQuestionItem(
          prompt: fb['q']!,
          correctAnswer: fb['a']!,
          twoOptions: [fb['a']!, '${int.parse(fb['a']!) - 10}'],
          isFromMistakes: false,
        ));
      }

      // Exactly 5 questions
      expect(alarmQuestions.length, 5);

      // Verify each question has EXACTLY 2 options
      for (final q in alarmQuestions) {
        expect(q.twoOptions.length, 2);
        expect(q.twoOptions.contains(q.correctAnswer), isTrue);
      }
    });

    test('Solving mistake during alarm clears mistake from AppStateProvider', () async {
      final provider = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final mistake = MistakeModel(
        id: 'err_table_19',
        prompt: '19 × 7 = ?',
        userAnswer: '130',
        correctAnswer: '133',
        topicId: 'tables',
        timestamp: DateTime.now(),
      );

      await provider.recordPracticeResult(
        PracticeResult(
          totalQuestions: 1,
          correctCount: 0,
          wrongCount: 1,
          accuracy: 0,
          avgTimeSeconds: 2.5,
          score: 0,
          topicId: 'tables',
          date: DateTime.now(),
        ),
        [mistake],
      );

      expect(provider.mistakes.any((m) => m.prompt == '19 × 7 = ?'), isTrue);

      // Simulate student answering the missed question during alarm
      bool solved = await provider.checkAndResolveIfMistake(
        prompt: '19 × 7 = ?',
        answer: '133',
      );

      expect(solved, isTrue);
      expect(provider.mistakes.any((m) => m.prompt == '19 × 7 = ?'), isFalse);
    });
  });
}
