import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/data/concept_formula_repository.dart';
import 'package:math_speed_practice/models/concept_formula_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Concepts PDF Integration Tests', () {
    test('Pillars contain all 11 Topics in correct order', () {
      expect(ConceptPillar.values.contains(ConceptPillar.arithmeticProgression), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.fractionPercentage), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.algebra), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.trigonometry), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.squaresAndCubes), isTrue);
      expect(ConceptPillar.values.contains(ConceptPillar.heightAndDistance), isTrue);
      expect(ConceptPillar.values.length, 11);

      expect(ConceptPillar.linesAndAngle.orderIndex, 1);
      expect(ConceptPillar.quadrilaterals.orderIndex, 2);
      expect(ConceptPillar.circle.orderIndex, 3);
      expect(ConceptPillar.mensuration.orderIndex, 4);
      expect(ConceptPillar.triangles.orderIndex, 5);
      expect(ConceptPillar.arithmeticProgression.orderIndex, 6);
      expect(ConceptPillar.fractionPercentage.orderIndex, 7);
      expect(ConceptPillar.algebra.orderIndex, 8);
      expect(ConceptPillar.trigonometry.orderIndex, 9);
      expect(ConceptPillar.squaresAndCubes.orderIndex, 10);
      expect(ConceptPillar.heightAndDistance.orderIndex, 11);

      expect(ConceptPillar.squaresAndCubes.ordinalLabel, '10th Topic');
      expect(ConceptPillar.heightAndDistance.ordinalLabel, '11th Topic');
    });

    test('Mensuration 2D & 3D Master Guide verification (25 Concepts, 250 PYQs)', () {
      final mensConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.mensuration);
      expect(mensConcepts.length, 25);

      final allMensQuestions = mensConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allMensQuestions.length, 250);

      // Verify key 2D shapes
      expect(ConceptFormulaRepository.getById('mens_2d_rectangle'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_square'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_scalene_triangle'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_right_triangle'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_equilateral_triangle'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_rhombus'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_trapezium'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_circle'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_semicircle'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_circular_ring'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_2d_sector_segment'), isNotNull);

      // Verify key 3D shapes
      expect(ConceptFormulaRepository.getById('mens_3d_cube'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_cuboid'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_cylinder'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_cone'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_frustum'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_sphere'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_hemisphere'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_hemispherical_bowl'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_prism'), isNotNull);
      expect(ConceptFormulaRepository.getById('mens_3d_pyramid'), isNotNull);

      for (final q in allMensQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Squares, Cubes & Roots verification (3 Concepts, 25 PYQs)', () {
      final sqConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.squaresAndCubes);
      expect(sqConcepts.length, 3);

      final allSqQuestions = sqConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allSqQuestions.length, 25);

      expect(ConceptFormulaRepository.getById('sq_cubes_reference_tables'), isNotNull);
      expect(ConceptFormulaRepository.getById('sq_roots_cube_roots_methods'), isNotNull);
      expect(ConceptFormulaRepository.getById('sq_surds_algebraic_simplification'), isNotNull);

      for (final q in allSqQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Question ${q.id} correct answer "${q.correctAnswer}" not in options ${q.options}');
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Height & Distance Master Guide verification (4 Concepts, 70 PYQs)', () {
      final hdConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.heightAndDistance);
      expect(hdConcepts.length, 4);

      final allHdQuestions = hdConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allHdQuestions.length, 70);

      expect(ConceptFormulaRepository.getById('hd_standard_angle_ratios'), isNotNull);
      expect(ConceptFormulaRepository.getById('hd_double_angle_shadows'), isNotNull);
      expect(ConceptFormulaRepository.getById('hd_complementary_reflections'), isNotNull);
      expect(ConceptFormulaRepository.getById('hd_mains_high_level'), isNotNull);

      for (final q in allHdQuestions) {
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

      for (final q in allAlgQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.explanation, isNotEmpty);
        expect(q.examBadge, isNotNull);
      }
    });

    test('Trigonometry Complete Master Guide & Foundations verification (14 Concepts, 295 PYQs)', () {
      final trigConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.trigonometry);
      expect(trigConcepts.length, 14);

      final allTrigQuestions = trigConcepts.expand((c) => c.practiceQuestions).toList();
      expect(allTrigQuestions.length, 295);

      // Verify Foundations & Master Guide (PDF 1 & 2: 7 Concepts, 210 PYQs)
      expect(ConceptFormulaRepository.getById('trig_ratios_standard_angles'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_quadrant_allied_angles'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_identities_basic_higher'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_sum_identities'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_diff_identities'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_special_angle_values'), isNotNull);
      expect(ConceptFormulaRepository.getById('trig_complementary_angles'), isNotNull);

      // Verify Advanced Identities (7 Concepts, 85 PYQs)
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

    test('Search finds keywords across all 11 topics', () {
      // Mensuration 2D & 3D
      expect(ConceptFormulaRepository.search('rectangle'), isNotEmpty);
      expect(ConceptFormulaRepository.search('आयत'), isNotEmpty);
      expect(ConceptFormulaRepository.search('cylinder'), isNotEmpty);
      expect(ConceptFormulaRepository.search('बेलन'), isNotEmpty);
      expect(ConceptFormulaRepository.search('frustum'), isNotEmpty);
      expect(ConceptFormulaRepository.search('छिन्नक'), isNotEmpty);
      expect(ConceptFormulaRepository.search('rhombus'), isNotEmpty);
      expect(ConceptFormulaRepository.search('समचतुर्भुज'), isNotEmpty);

      // Squares & Cubes
      expect(ConceptFormulaRepository.search('वर्गमूल'), isNotEmpty);
      expect(ConceptFormulaRepository.search('घनमूल'), isNotEmpty);
      expect(ConceptFormulaRepository.search('cube root'), isNotEmpty);

      // Height & Distance
      expect(ConceptFormulaRepository.search('elevation'), isNotEmpty);
      expect(ConceptFormulaRepository.search('उन्नयन'), isNotEmpty);
      expect(ConceptFormulaRepository.search('height & distance'), isNotEmpty);

      // Others
      expect(ConceptFormulaRepository.search('बीजगणित'), isNotEmpty);
      expect(ConceptFormulaRepository.search('त्रिकोणमिति'), isNotEmpty);
      expect(ConceptFormulaRepository.search('समांतर'), isNotEmpty);
    });
  });
}
