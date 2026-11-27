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

    test('Quadrilateral Type-Wise Theorems repository data verification', () {
      final quadConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.quadrilaterals);
      // Previously 3 + 3 new theorems = 6
      expect(quadConcepts.length, 6);

      final midpointsTrapezium = ConceptFormulaRepository.getById('quad_midpoints_diagonals_trapezium');
      expect(midpointsTrapezium, isNotNull);
      expect(midpointsTrapezium!.practiceQuestions.length, 8);

      final incirclesQuad = ConceptFormulaRepository.getById('quad_tangency_two_incircles');
      expect(incirclesQuad, isNotNull);
      expect(incirclesQuad!.practiceQuestions.length, 8);

      final areaRatioParallelogram = ConceptFormulaRepository.getById('quad_area_ratio_parallelogram_midpoints');
      expect(areaRatioParallelogram, isNotNull);
      expect(areaRatioParallelogram!.practiceQuestions.length, 8);

      final newQuadQuestions = [
        ...midpointsTrapezium.practiceQuestions,
        ...incirclesQuad.practiceQuestions,
        ...areaRatioParallelogram.practiceQuestions,
      ];
      expect(newQuadQuestions.length, 24);

      for (final q in newQuadQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Pythagoras Triplets concept guide and PYQs verification', () {
      final pythConcept = ConceptFormulaRepository.getById('tri_pythagoras_triplets_guide');
      expect(pythConcept, isNotNull);
      expect(pythConcept!.pillar, ConceptPillar.triangles);
      expect(pythConcept.practiceQuestions.length, 11);

      for (final q in pythConcept.practiceQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Search finds keywords across all new topics', () {
      expect(ConceptFormulaRepository.search('समांतर'), isNotEmpty);
      expect(ConceptFormulaRepository.search('arithmetic'), isNotEmpty);
      expect(ConceptFormulaRepository.search('भिन्न'), isNotEmpty);
      expect(ConceptFormulaRepository.search('14.28%'), isNotEmpty);
      expect(ConceptFormulaRepository.search('trapezium'), isNotEmpty);
      expect(ConceptFormulaRepository.search('incircle'), isNotEmpty);
      expect(ConceptFormulaRepository.search('पाइथागोरस'), isNotEmpty);
      expect(ConceptFormulaRepository.search('triplet'), isNotEmpty);
    });
  });
}
