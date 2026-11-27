import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/data/concept_formula_repository.dart';
import 'package:math_speed_practice/models/concept_formula_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Concepts PDF Integration Tests', () {
    test('Pillars contain Arithmetic Progression and Fraction-Percentage', () {
      expect(ConceptPillar.values.contains(ConceptPillar.arithmeticProgression), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.fractionPercentage), isTrue);
      expect(ConceptPillar.values.length, 7);

      expect(ConceptPillar.arithmeticProgression.orderIndex, 6);
      expect(ConceptPillar.fractionPercentage.orderIndex, 7);
      expect(ConceptPillar.arithmeticProgression.ordinalLabel, '6th Topic');
      expect(ConceptPillar.fractionPercentage.ordinalLabel, '7th Topic');
    });

    test('Arithmetic Progression repository data verification', () {
      final apConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.arithmeticProgression);
      expect(apConcepts.length, 5);

      final allApQuestions = apConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allApQuestions.length, greaterThanOrEqualTo(21));

      for (final q in allApQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Fraction-Percentage repository data verification', () {
      final fracConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.fractionPercentage);
      expect(fracConcepts.length, 4);

      final allFracQuestions = fracConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allFracQuestions.length, 25);

      for (final q in allFracQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Search finds both English and Hindi keywords in new topics', () {
      final apSearchHindi = ConceptFormulaRepository.search('समांतर');
      expect(apSearchHindi, isNotEmpty);

      final apSearchEnglish = ConceptFormulaRepository.search('arithmetic');
      expect(apSearchEnglish, isNotEmpty);

      final fracSearchHindi = ConceptFormulaRepository.search('भिन्न');
      expect(fracSearchHindi, isNotEmpty);

      final fracSearchNumber = ConceptFormulaRepository.search('14.28%');
      expect(fracSearchNumber, isNotEmpty);
    });
  });
}
