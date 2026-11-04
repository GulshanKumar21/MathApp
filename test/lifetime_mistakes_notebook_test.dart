import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/models/math_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lifetime Mistake Notebook vs Active 1-Hour Recall Tests', () {
    test('Mistake is stored in lifetime notebook and remains even after being resolved', () async {
      final state = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // Simulate a practice result with 2 mistakes
      final m1 = MistakeModel(
        id: 'mistake_1',
        prompt: '14 × 7',
        userAnswer: '88',
        correctAnswer: '98',
        topicId: 'tables',
        timestamp: DateTime.now(),
      );
      final m2 = MistakeModel(
        id: 'mistake_2',
        prompt: '19 × 6',
        userAnswer: '104',
        correctAnswer: '114',
        topicId: 'tables',
        timestamp: DateTime.now(),
      );

      final result = PracticeResult(
        totalQuestions: 10,
        correctCount: 8,
        wrongCount: 2,
        accuracy: 80.0,
        avgTimeSeconds: 3.0,
        score: 80,
        topicId: 'tables',
        date: DateTime.now(),
      );

      await state.recordPracticeResult(result, [m1, m2]);

      // Both active recall queue (mistakes) and lifetime notebook (allMistakes) have 2
      expect(state.mistakes.length, equals(2));
      expect(state.allMistakes.length, equals(2));
      expect(state.allMistakes.every((m) => !m.isResolved), isTrue);

      // Now student solves mistake_1 correctly
      await state.resolveMistake('mistake_1');

      // 1. Active recall queue removes mistake_1 (so 1-hr recall alert on top clears)
      expect(state.mistakes.length, equals(1));
      expect(state.mistakes.any((m) => m.id == 'mistake_1'), isFalse);

      // 2. Lifetime notebook KEEPS mistake_1 permanently!
      expect(state.allMistakes.length, equals(2));
      final resolvedM1 = state.allMistakes.firstWhere((m) => m.id == 'mistake_1');
      expect(resolvedM1.isResolved, isTrue);
      expect(resolvedM1.resolvedAt, isNotNull);

      // And mistake_2 is still pending
      final pendingM2 = state.allMistakes.firstWhere((m) => m.id == 'mistake_2');
      expect(pendingM2.isResolved, isFalse);
    });

    test('checkAndResolveIfMistake marks lifetime notebook as resolved and clears active queue', () async {
      final state = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      await state.recordWrongRecallAttempt(
        prompt: '25 × 4 = ?',
        wrongAnswer: '90',
        correctAnswer: '100',
        topicId: 'tables',
      );

      expect(state.mistakes.length, equals(1));
      expect(state.allMistakes.length, equals(1));
      expect(state.allMistakes.first.isResolved, isFalse);

      // Student solves it correctly via recall solve
      final resolved = await state.checkAndResolveIfMistake(
        prompt: '25 × 4 = ?',
        answer: '100',
      );

      expect(resolved, isTrue);
      // Cleared from active queue (so top recall card clears)
      expect(state.mistakes.isEmpty, isTrue);

      // Still stored in lifetime notebook as resolved
      expect(state.allMistakes.length, equals(1));
      expect(state.allMistakes.first.isResolved, isTrue);
    });
  });
}
