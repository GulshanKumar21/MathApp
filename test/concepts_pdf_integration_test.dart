import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/data/concept_formula_repository.dart';
import 'package:math_speed_practice/models/concept_formula_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Concepts PDF Integration Tests', () {
    test('Pillars contain all 9 Topics in correct order', () {
      expect(ConceptPillar.values.contains(ConceptPillar.arithmeticProgression), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.fractionPercentage), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.algebra), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.trigonometry), isTrue);
      expect(ConceptPillar.values.length, 9);

      expect(ConceptPillar.arithmeticProgression.orderIndex, 6);
      expect(ConceptPillar.fractionPercentage.orderIndex, 7);
      expect(ConceptPillar.algebra.orderIndex, 8);
      expect(ConceptPillar.trigonometry.orderIndex, 9);

      expect(ConceptPillar.arithmeticProgression.ordinalLabel, '6th Topic');
      expect(ConceptPillar.fractionPercentage.ordinalLabel, '7th Topic');
      expect(ConceptPillar.algebra.ordinalLabel, '8th Topic');
      expect(ConceptPillar.trigonometry.ordinalLabel, '9th Topic');
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

    test('Algebra Identities repository data verification (17 Concepts, 72 PYQs)', () {
      final algConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.algebra);
      expect(algConcepts.length, 17);

      final allAlgQuestions = algConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allAlgQuestions.length, 72);

      // Verify specific concepts exist
      expect(ConceptFormulaRepository.getById('alg_diff_squares'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_perfect_squares'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_reciprocal_powers'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_higher_powers'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_ap_identities'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_master_cubic'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_conditional_cubic'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_sum_squares_zero'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_biquadratic'), isNotNull);
      expect(ConceptFormulaRepository.getById('alg_roots_coefficients'), isNotNull);

      for (final q in allAlgQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Trigonometry Identities repository data verification (7 Concepts, 85 PYQs)', () {
      final trigConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.trigonometry);
      expect(trigConcepts.length, 7);

      final allTrigQuestions = trigConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allTrigQuestions.length, 85);

      // Verify specific concepts exist
      expect(ConceptFormulaRepository.getById('trig_double_angle'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_triple_angle'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_product_sum_cd'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_properties_special_values'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_reciprocal_sums_min_max'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_product_to_sum_series'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_sum_to_product_triangle'), isNotNull);

      for (final q in allTrigQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Search finds keywords across Algebra, Trigonometry, and all topics', () {
      expect(ConceptFormulaRepository.search('समांतर'), isNotEmpty);
      expect(ConceptFormulaRepository.search('arithmetic'), isNotEmpty);
      expect(ConceptFormulaRepository.search('भिन्न'), isNotEmpty);
      expect(ConceptFormulaRepository.search('14.28%'), isNotEmpty);
      expect(ConceptFormulaRepository.search('trapezium'), isNotEmpty);
      expect(ConceptFormulaRepository.search('incircle'), isNotEmpty);
      expect(ConceptFormulaRepository.search('पाइथागोरस'), isNotEmpty);
      expect(ConceptFormulaRepository.search('triplet'), isNotEmpty);

      // Algebra keywords
      expect(ConceptFormulaRepository.search('बीजगणित'), isNotEmpty);
      expect(ConceptFormulaRepository.search('squares'), isNotEmpty);
      expect(ConceptFormulaRepository.search('reciprocal'), isNotEmpty);
      expect(ConceptFormulaRepository.search('biquadratic'), isNotEmpty);
      expect(ConceptFormulaRepository.search('coefficients'), isNotEmpty);

      // Trigonometry keywords
      expect(ConceptFormulaRepository.search('त्रिकोणमिति'), isNotEmpty);
      expect(ConceptFormulaRepository.search('double angle'), isNotEmpty);
      expect(ConceptFormulaRepository.search('triple angle'), isNotEmpty);
      expect(ConceptFormulaRepository.search('sin 2a'), isNotEmpty);
      expect(ConceptFormulaRepository.search('c–d'), isNotEmpty);
    });
  });
}
