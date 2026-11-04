import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';
import 'package:math_speed_practice/models/math_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Standard tables strictly capped up to 30 and multiplier strictly 2 to 9 (No 1 and No 10)', () {
    // Generate 50 questions for TopicType.tables
    final questions = DynamicQuestionEngine.generateUniqueQuestions(
      type: TopicType.tables,
      count: 50,
    );

    for (var q in questions) {
      // Prompt format is "a × b = ?"
      final parts = q.prompt.replaceAll(' = ?', '').split(' × ');
      final a = int.parse(parts[0]);
      final b = int.parse(parts[1]);

      expect(a <= 30, isTrue, reason: 'Table base should be <= 30, got $a');
      expect(b >= 2 && b <= 9, isTrue, reason: 'Multiplier should be strictly 2 to 9 (no 1 or 10), got $b');
    }

    // Specific table question generation (e.g. Table 17) should strictly use multipliers 2 to 9
    final table17Questions = DynamicQuestionEngine.generateTableQuestions(17, count: 8);
    for (var q in table17Questions) {
      final parts = q.prompt.replaceAll(' = ?', '').split(' × ');
      final mult = int.parse(parts[1]);
      expect(mult >= 2 && mult <= 9, isTrue, reason: 'Multiplier in Table 17 should be 2..9, got $mult');
      expect(q.prompt.contains('17 × 1 '), isFalse);
      expect(q.prompt.contains('17 × 10 '), isFalse);
    }

    // Division test: Divisors should be strictly 2 to 9 (no 1 and no 10)
    final divQuestions = DynamicQuestionEngine.generateUniqueQuestions(
      type: TopicType.division,
      count: 30,
    );
    for (var q in divQuestions) {
      final parts = q.prompt.replaceAll(' = ?', '').split(' ÷ ');
      final divisor = int.parse(parts[1]);
      expect(divisor >= 2 && divisor <= 9, isTrue, reason: 'Divisor should be strictly 2 to 9, got $divisor');
    }
  });

  test('Hard-On Pro Multiplier generates 2-digit x 2-digit calculations with Vedic explanations', () {
    final hardQuestions = DynamicQuestionEngine.generateHardMultiplierQuestions(count: 20);

    expect(hardQuestions.isNotEmpty, isTrue);
    for (var q in hardQuestions) {
      final parts = q.prompt.replaceAll(' = ?', '').split(' × ');
      final a = int.parse(parts[0]);
      final b = int.parse(parts[1]);

      expect(a >= 13, isTrue, reason: 'Hard multiplier first operand should be >= 13, got $a');
      expect(b >= 14, isTrue, reason: 'Hard multiplier second operand should be >= 14, got $b');
      expect(q.explanation.contains('Vedic'), isTrue);
      expect(q.topicId, equals('hard_multiplier'));
    }
  });

  test('Pythagorean Triples generates valid right-triangle triples and non-empty options', () {
    final triples = DynamicQuestionEngine.generateUniqueQuestions(
      type: TopicType.triples,
      count: 20,
    );

    expect(triples.length, 20);
    for (var q in triples) {
      expect(q.prompt.contains('➔'), isTrue);
      expect(q.options.length, greaterThanOrEqualTo(4));
      expect(q.options.contains(q.correctAnswer), isTrue);
      expect(q.explanation.contains('Pythagorean'), isTrue);
    }
  });

  test('All 4 arithmetic operations (Addition, Subtraction, Multiplication, Division) generate 1D to 4D questions with identical unit-digit options', () {
    final operations = [
      TopicType.addition,
      TopicType.subtraction,
      TopicType.hardMultiplier,
      TopicType.division,
    ];

    for (final op in operations) {
      for (int digits = 1; digits <= 4; digits++) {
        final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
          type: op,
          digits: digits,
          count: 5,
        );

        expect(questions.length, 5, reason: 'Must generate requested count for $op $digits-digit');
        for (final q in questions) {
          expect(q.options.length, greaterThanOrEqualTo(4));
          expect(q.options.contains(q.correctAnswer), isTrue);

          final correctVal = int.tryParse(q.correctAnswer);
          if (correctVal != null && correctVal.abs() >= 10) {
            final correctLastChar = q.correctAnswer.substring(q.correctAnswer.length - 1);
            for (final opt in q.options) {
              expect(
                opt.endsWith(correctLastChar),
                isTrue,
                reason: 'Option $opt must end with $correctLastChar in question ${q.prompt}',
              );
            }
          } else if (correctVal != null) {
            // Single-digit answers (< 10) have realistic nearby distractors
            for (final opt in q.options) {
              final optVal = int.tryParse(opt);
              if (optVal != null) {
                expect(
                  (optVal - correctVal).abs(),
                  lessThanOrEqualTo(10),
                  reason: 'Option $opt must be close to single-digit answer $correctVal in question ${q.prompt}',
                );
              }
            }
          }
        }
      }
    }
  });
}

