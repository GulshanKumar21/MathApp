import 'package:flutter_test/flutter_test.dart';
import 'package:mathapp/services/ai_tutor_engine.dart';

void main() {
  group('AiTutorEngine Tests', () {
    test('Solves fractional percentage: 16.66% of 720', () {
      final res = AiTutorEngine.solve('What is 16.66% of 720?');
      expect(res['topic'], contains('Percentage'));
      expect(res['answer'], equals('120'));
      expect(res['speedTrick'], contains('1/6'));
    });

    test('Solves multiplication: 124 * 15', () {
      final res = AiTutorEngine.solve('124 * 15');
      expect(res['topic'], contains('Multiplication'));
      expect(res['answer'], equals('1860'));
    });

    test('Solves division: 450 / 9', () {
      final res = AiTutorEngine.solve('450 / 9');
      expect(res['topic'], contains('Division'));
      expect(res['answer'], equals('50'));
    });

    test('Solves subtraction: 1000 - 347', () {
      final res = AiTutorEngine.solve('1000 - 347');
      expect(res['topic'], contains('Subtraction'));
      expect(res['answer'], equals('653'));
    });

    test('Solves Rectangle 2D: length 12 breadth 5', () {
      final res = AiTutorEngine.solve('Rectangle with length 12 and breadth 5');
      expect(res['topic'], contains('Rectangle'));
      expect(res['answer'], contains('Area = 60'));
      expect(res['answer'], contains('Perimeter = 34'));
      expect(res['answer'], contains('Diagonal = 13'));
      expect(res['speedTrick'], contains('Triplet'));
    });

    test('Solves Circle 2D: radius 14', () {
      final res = AiTutorEngine.solve('Radius of circle is 14');
      expect(res['topic'], contains('Circle'));
      expect(res['answer'], contains('Area = 616'));
      expect(res['answer'], contains('Circumference = 88'));
    });

    test('Solves Algebra: x + 1/x = 3', () {
      final res = AiTutorEngine.solve('x + 1/x = 3');
      expect(res['topic'], contains('Algebraic Reciprocal'));
      expect(res['answer'], contains('x² + 1/x² = 7'));
      expect(res['answer'], contains('x³ + 1/x³ = 18'));
    });

    test('Solves Number System LCM: LCM of 24 and 36', () {
      final res = AiTutorEngine.solve('LCM of 24 and 36');
      expect(res['topic'], contains('LCM'));
      expect(res['answer'], equals('72'));
    });

    test('Solves Number System HCF: HCF of 48 and 72', () {
      final res = AiTutorEngine.solve('HCF of 48 and 72');
      expect(res['topic'], contains('HCF'));
      expect(res['answer'], equals('24'));
    });

    test('Solves Square: square of 45', () {
      final res = AiTutorEngine.solve('square of 45');
      expect(res['topic'], contains('Squaring'));
      expect(res['answer'], equals('2025'));
    });

    test('Solves Square Root: sqrt(1024)', () {
      final res = AiTutorEngine.solve('sqrt of 1024');
      expect(res['topic'], contains('Square Root'));
      expect(res['answer'], equals('32'));
    });

    test('Solves Divisibility Rule: divisibility rule of 8', () {
      final res = AiTutorEngine.solve('divisibility rule of 8');
      expect(res['topic'], contains('Divisibility Rule for 8'));
      expect(res['speedTrick'], contains('Hundreds digit'));
    });

    test('Solves Trigonometric Value: sin 30', () {
      final res = AiTutorEngine.solve('sin 30');
      expect(res['topic'], contains('SIN 30'));
      expect(res['answer'], contains('1/2'));
    });

    test('Searches Concept Repository: Intercept Theorem', () {
      final res = AiTutorEngine.solve('What is Intercept Theorem?');
      expect(res['topic'], contains('Intercept Theorem'));
      expect(res['formula'], contains('AB / BC'));
    });

    test('Searches Blackbook Vocabulary: Discreet vs Discrete', () {
      final res = AiTutorEngine.solve('Difference between Discreet and Discrete');
      expect(res['topic'], contains('Discreet vs Discrete'));
    });
  });
}
