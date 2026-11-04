import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';
import 'package:math_speed_practice/models/math_models.dart';

void main() {
  group('Arithmetic Dynamic Limit Boundary Tests', () {
    test('Addition respects maxNumberLimit <= 20 with 30 questions', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.addition,
        digits: 2,
        count: 30,
        maxNumberLimit: 20,
      );

      expect(questions.length, 30);
      for (final q in questions) {
        // Prompt is in format "$a + $b = ?"
        final parts = q.prompt.replaceAll(' = ?', '').split(' + ');
        final a = int.parse(parts[0].trim());
        final b = int.parse(parts[1].trim());

        expect(a, lessThanOrEqualTo(20), reason: 'Operand a was $a in "${q.prompt}"');
        expect(b, lessThanOrEqualTo(20), reason: 'Operand b was $b in "${q.prompt}"');
        expect(int.parse(q.correctAnswer), equals(a + b));
        expect(q.options.contains(q.correctAnswer), isTrue);
      }
    });

    test('Subtraction respects maxNumberLimit <= 20 with 30 questions', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.subtraction,
        digits: 2,
        count: 30,
        maxNumberLimit: 20,
      );

      expect(questions.length, 30);
      for (final q in questions) {
        // Prompt format: "$a − $b = ?"
        final parts = q.prompt.replaceAll(' = ?', '').split(' − ');
        final a = int.parse(parts[0].trim());
        final b = int.parse(parts[1].trim());

        expect(a, lessThanOrEqualTo(20), reason: 'Minuend a was $a in "${q.prompt}"');
        expect(b, lessThanOrEqualTo(20), reason: 'Subtrahend b was $b in "${q.prompt}"');
        expect(a, greaterThan(b), reason: 'Minuend must be greater than subtrahend');
        expect(int.parse(q.correctAnswer), equals(a - b));
        expect(q.options.contains(q.correctAnswer), isTrue);
      }
    });

    test('Multiplication respects maxNumberLimit <= 20 with 30 questions', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.hardMultiplier,
        digits: 2,
        count: 30,
        maxNumberLimit: 20,
      );

      expect(questions.length, 30);
      for (final q in questions) {
        // Prompt format: "$a × $b = ?"
        final parts = q.prompt.replaceAll(' = ?', '').split(' × ');
        final a = int.parse(parts[0].trim());
        final b = int.parse(parts[1].trim());

        expect(a, lessThanOrEqualTo(20), reason: 'Operand a was $a in "${q.prompt}"');
        expect(b, lessThanOrEqualTo(20), reason: 'Operand b was $b in "${q.prompt}"');
        expect(int.parse(q.correctAnswer), equals(a * b));
        expect(q.options.contains(q.correctAnswer), isTrue);
      }
    });

    test('Division respects maxNumberLimit <= 20 with 30 questions', () {
      final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.division,
        digits: 2,
        count: 30,
        maxNumberLimit: 20,
      );

      expect(questions.length, 30);
      for (final q in questions) {
        // Prompt format: "$dividend ÷ $divisor = ?"
        final parts = q.prompt.replaceAll(' = ?', '').split(' ÷ ');
        final dividend = int.parse(parts[0].trim());
        final divisor = int.parse(parts[1].trim());
        final quotient = int.parse(q.correctAnswer);

        expect(dividend, lessThanOrEqualTo(20), reason: 'Dividend was $dividend in "${q.prompt}"');
        expect(divisor, lessThanOrEqualTo(20), reason: 'Divisor was $divisor in "${q.prompt}"');
        expect(quotient, lessThanOrEqualTo(20), reason: 'Quotient was $quotient in "${q.prompt}"');
        expect(dividend, equals(divisor * quotient));
        expect(q.options.contains(q.correctAnswer), isTrue);
      }
    });

    test('Multiplication and Addition respect maxNumberLimit <= 50 with 50 questions', () {
      final multQuestions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.hardMultiplier,
        digits: 2,
        count: 50,
        maxNumberLimit: 50,
      );
      for (final q in multQuestions) {
        final parts = q.prompt.replaceAll(' = ?', '').split(' × ');
        final a = int.parse(parts[0].trim());
        final b = int.parse(parts[1].trim());
        expect(a, lessThanOrEqualTo(50));
        expect(b, lessThanOrEqualTo(50));
      }

      final addQuestions = DynamicQuestionEngine.generateDigitSpecificQuestions(
        type: TopicType.addition,
        digits: 2,
        count: 50,
        maxNumberLimit: 50,
      );
      for (final q in addQuestions) {
        final parts = q.prompt.replaceAll(' = ?', '').split(' + ');
        final a = int.parse(parts[0].trim());
        final b = int.parse(parts[1].trim());
        expect(a, lessThanOrEqualTo(50));
        expect(b, lessThanOrEqualTo(50));
      }
    });
  });
}
