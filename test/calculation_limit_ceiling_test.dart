import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';
import 'package:math_speed_practice/models/math_models.dart';

void main() {
  group('Calculation Limit Ceiling & Digit Complexity Tests', () {
    test('Addition with limit 20 produces distinct questions with operands <= 20', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.addition,
        digits: 2,
        count: 10,
        maxNumberLimit: 20,
      );

      expect(questions.length, equals(10));
      final prompts = questions.map((q) => q.prompt).toSet();
      // Ensure all 10 questions are distinct (no duplicate 10+10)
      expect(prompts.length, equals(10), reason: 'All 10 questions should be distinct');

      for (final q in questions) {
        // e.g. "14 + 18 = ?"
        final parts = q.prompt.split(' ');
        final a = int.parse(parts[0]);
        final b = int.parse(parts[2]);
        expect(a, greaterThanOrEqualTo(10));
        expect(a, lessThanOrEqualTo(20));
        expect(b, greaterThanOrEqualTo(10));
        expect(b, lessThanOrEqualTo(20));
        expect(int.parse(q.correctAnswer), equals(a + b));
        expect(q.options.contains(q.correctAnswer), isTrue);
      }
    });

    test('Addition with limit 50 produces double-digit questions with operands <= 50', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.addition,
        digits: 2,
        count: 15,
        maxNumberLimit: 50,
      );

      expect(questions.length, equals(15));
      final prompts = questions.map((q) => q.prompt).toSet();
      expect(prompts.length, equals(15));

      for (final q in questions) {
        final parts = q.prompt.split(' ');
        final a = int.parse(parts[0]);
        final b = int.parse(parts[2]);
        expect(a, inInclusiveRange(10, 50));
        expect(b, inInclusiveRange(10, 50));
        expect(int.parse(q.correctAnswer), equals(a + b));
      }
    });

    test('Addition for 3-Digit with limit <= 20 adapts gracefully without crashing', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.addition,
        digits: 3,
        count: 10,
        maxNumberLimit: 20,
      );

      expect(questions.length, equals(10));
      for (final q in questions) {
        final parts = q.prompt.split(' ');
        final a = int.parse(parts[0]);
        final b = int.parse(parts[2]);
        expect(a, inInclusiveRange(100, 999));
        expect(b, inInclusiveRange(2, 20));
        expect(int.parse(q.correctAnswer), equals(a + b));
      }
    });

    test('Subtraction with limit 20 produces positive results with operands <= 20', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.subtraction,
        digits: 2,
        count: 10,
        maxNumberLimit: 20,
      );

      expect(questions.length, equals(10));
      final prompts = questions.map((q) => q.prompt).toSet();
      expect(prompts.length, equals(10));

      for (final q in questions) {
        // e.g. "18 − 12 = ?"
        final parts = q.prompt.split(' ');
        final a = int.parse(parts[0]);
        final b = int.parse(parts[2]);
        expect(a, inInclusiveRange(10, 20));
        expect(b, inInclusiveRange(2, 19));
        expect(a, greaterThan(b));
        expect(int.parse(q.correctAnswer), equals(a - b));
      }
    });

    test('Multiplication with limit 20 produces multipliers <= 20', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.tables,
        digits: 2,
        count: 10,
        maxNumberLimit: 20,
      );

      expect(questions.length, equals(10));
      final prompts = questions.map((q) => q.prompt).toSet();
      expect(prompts.length, equals(10));

      for (final q in questions) {
        final parts = q.prompt.split(' ');
        final a = int.parse(parts[0]);
        final b = int.parse(parts[2]);
        expect(a, inInclusiveRange(10, 20));
        expect(b, inInclusiveRange(2, 20));
        expect(int.parse(q.correctAnswer), equals(a * b));
      }
    });

    test('Division with limit 20 produces valid integer division without remainder', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.division,
        digits: 2,
        count: 10,
        maxNumberLimit: 20,
      );

      expect(questions.length, equals(10));
      for (final q in questions) {
        final parts = q.prompt.split(' ');
        final dividend = int.parse(parts[0]);
        final divisor = int.parse(parts[2]);
        final quotient = int.parse(q.correctAnswer);
        expect(divisor, inInclusiveRange(2, 20));
        expect(dividend, equals(divisor * quotient));
        expect(quotient, greaterThanOrEqualTo(10), reason: '2-digit division should have 2-digit quotient');
      }
    });

    test('Single-digit drills respect limit ceiling', () {
      for (final topic in [TopicType.addition, TopicType.subtraction, TopicType.hardMultiplier, TopicType.division]) {
        final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
          type: topic,
          digits: 1,
          count: 8,
          maxNumberLimit: 20,
        );
        expect(questions.length, equals(8));
        for (final q in questions) {
          expect(q.options.contains(q.correctAnswer), isTrue);
          expect(q.options.length, equals(4));
        }
      }
    });
  });
}
