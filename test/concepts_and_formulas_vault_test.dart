import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/models/concept_formula_model.dart';
import 'package:math_speed_practice/data/concept_formula_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ConceptFormulaRepository covers exactly the 5 main topics in order', () {
    final pillars = ConceptPillar.values;
    expect(pillars.length, 5);

    expect(pillars[0], ConceptPillar.linesAndAngle);
    expect(pillars[0].orderIndex, 1);
    expect(pillars[0].ordinalLabel, '1st Topic');
    expect(pillars[0].displayName, 'Lines and Angle');

    expect(pillars[1], ConceptPillar.quadrilaterals);
    expect(pillars[1].orderIndex, 2);
    expect(pillars[1].ordinalLabel, '2nd Topic');
    expect(pillars[1].displayName, 'Quadrilaterals');

    expect(pillars[2], ConceptPillar.circle);
    expect(pillars[2].orderIndex, 3);
    expect(pillars[2].ordinalLabel, '3rd Topic');
    expect(pillars[2].displayName, 'Circle');

    expect(pillars[3], ConceptPillar.mensuration);
    expect(pillars[3].orderIndex, 4);
    expect(pillars[3].ordinalLabel, '4th Topic');
    expect(pillars[3].displayName, 'Mensuration');

    expect(pillars[4], ConceptPillar.triangles);
    expect(pillars[4].orderIndex, 5);
    expect(pillars[4].ordinalLabel, '5th Topic');
    expect(pillars[4].displayName, 'Triangles');

    for (final pillar in pillars) {
      final items = ConceptFormulaRepository.getByPillar(pillar);
      expect(
        items.isNotEmpty,
        isTrue,
        reason: 'Pillar ${pillar.displayName} must have at least one formula model defined',
      );
    }
  });

  test('Every formula model contains valid formulas, key conditions, solved examples, and practice questions', () {
    for (final f in ConceptFormulaRepository.formulas) {
      expect(f.title.isNotEmpty, isTrue);
      expect(f.formula.isNotEmpty, isTrue);
      expect(f.explanation.isNotEmpty, isTrue);
      expect(f.keyConditions.isNotEmpty, isTrue);
      expect(f.solvedExamples.isNotEmpty, isTrue);
      expect(f.practiceQuestions.isNotEmpty, isTrue);

      for (final ex in f.solvedExamples) {
        expect(ex.problem.isNotEmpty, isTrue);
        expect(ex.steps.isNotEmpty, isTrue);
        expect(ex.answer.isNotEmpty, isTrue);
      }

      for (final q in f.practiceQuestions) {
        expect(q.prompt.isNotEmpty, isTrue);
        expect(q.options.length, greaterThanOrEqualTo(4));
        expect(q.options.contains(q.correctAnswer), isTrue,
            reason: 'Options must contain correct answer in question ${q.prompt}');
      }
    }
  });

  test('Lines and Angles has 4 concepts with 32 MCQs and diagrams', () {
    final linesConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.linesAndAngle);
    expect(linesConcepts.length, 4);

    expect(linesConcepts[0].id, 'lines_intercept_theorem');
    expect(linesConcepts[0].diagramType, 'lines_intercept_theorem');
    expect(linesConcepts[0].practiceQuestions.length, 8);

    expect(linesConcepts[1].id, 'lines_arrow_rule');
    expect(linesConcepts[1].diagramType, 'lines_arrow_rule');
    expect(linesConcepts[1].practiceQuestions.length, 8);

    expect(linesConcepts[2].id, 'lines_zigzag_rule');
    expect(linesConcepts[2].diagramType, 'lines_zigzag_rule');
    expect(linesConcepts[2].practiceQuestions.length, 8);

    expect(linesConcepts[3].id, 'lines_transversal_angles');
    expect(linesConcepts[3].diagramType, 'lines_transversal_angles');
    expect(linesConcepts[3].practiceQuestions.length, 8);

    final totalLinesQs = linesConcepts.fold<int>(0, (sum, c) => sum + c.practiceQuestions.length);
    expect(totalLinesQs, 32);
  });

  test('Triangles has 18 concepts from official PYQ syllabus with 80+ MCQs and diagrams', () {
    final triConcepts = ConceptFormulaRepository.getByPillar(ConceptPillar.triangles);
    expect(triConcepts.length, 18);

    final totalTriQs = triConcepts.fold<int>(0, (sum, c) => sum + c.practiceQuestions.length);
    expect(totalTriQs, greaterThanOrEqualTo(80));

    for (final c in triConcepts) {
      expect(c.diagramType, isNotNull);
      expect(c.diagramType, isNotEmpty);
      expect(c.practiceQuestions.length, greaterThanOrEqualTo(4));
    }
  });

  test('Live search queries retrieve relevant concept formulas for 5 main topics', () {
    final intercept = ConceptFormulaRepository.search('Intercept');
    expect(intercept.any((f) => f.id == 'lines_intercept_theorem'), isTrue);

    final arrow = ConceptFormulaRepository.search('Arrow');
    expect(arrow.any((f) => f.id == 'lines_arrow_rule'), isTrue);

    final zigzag = ConceptFormulaRepository.search('Zig-Zag');
    expect(zigzag.any((f) => f.id == 'lines_zigzag_rule'), isTrue);

    final transversal = ConceptFormulaRepository.search('Transversal');
    expect(transversal.any((f) => f.id == 'lines_transversal_angles'), isTrue);

    final parallelogram = ConceptFormulaRepository.search('Parallelogram');
    expect(parallelogram.any((f) => f.id == 'quad_parallelogram_properties'), isTrue);

    final rhombus = ConceptFormulaRepository.search('Rhombus');
    expect(rhombus.any((f) => f.id == 'quad_rhombus_trapezium'), isTrue);

    final cyclicQuad = ConceptFormulaRepository.search('Ptolemy');
    expect(cyclicQuad.any((f) => f.id == 'quad_cyclic_ptolemy'), isTrue);

    final secant = ConceptFormulaRepository.search('Secant');
    expect(secant.any((f) => f.id == 'circle_tangent_secant'), isTrue);

    final tangents = ConceptFormulaRepository.search('Tangents');
    expect(tangents.any((f) => f.id == 'circle_common_tangents'), isTrue);

    final circleAngles = ConceptFormulaRepository.search('Subtended');
    expect(circleAngles.any((f) => f.id == 'circle_angle_theorems'), isTrue);

    final mens2d = ConceptFormulaRepository.search('Perimeter');
    expect(mens2d.any((f) => f.id == 'mens_2d_areas_perimeters'), isTrue);

    final frustum = ConceptFormulaRepository.search('Frustum');
    expect(frustum.any((f) => f.id == 'mens_3d_solids_frustum'), isTrue);

    final apollonius = ConceptFormulaRepository.search('Apollonius');
    expect(apollonius.any((f) => f.id == 'tri_apollonius_medians'), isTrue);

    final inradius = ConceptFormulaRepository.search('Incentre');
    expect(inradius.any((f) => f.id == 'tri_centres_properties'), isTrue);

    final thales = ConceptFormulaRepository.search('Thales');
    expect(thales.any((f) => f.id == 'tri_similarity_thales'), isTrue);
  });

  test('All concept formulas have at least 4 practice questions', () {
    for (final f in ConceptFormulaRepository.formulas) {
      expect(
        f.practiceQuestions.length,
        greaterThanOrEqualTo(4),
        reason: 'Formula ${f.id} should have at least 4 practice questions',
      );
    }
  });
}
