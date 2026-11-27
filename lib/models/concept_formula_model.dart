import 'math_models.dart';

enum ConceptPillar {
  linesAndAngle,
  quadrilaterals,
  circle,
  mensuration,
  triangles,
  arithmeticProgression,
  fractionPercentage,
  algebra,
  trigonometry,
  squaresAndCubes,
  heightAndDistance,
}

extension ConceptPillarExtension on ConceptPillar {
  int get orderIndex {
    switch (this) {
      case ConceptPillar.linesAndAngle:
        return 1;
      case ConceptPillar.quadrilaterals:
        return 2;
      case ConceptPillar.circle:
        return 3;
      case ConceptPillar.mensuration:
        return 4;
      case ConceptPillar.triangles:
        return 5;
      case ConceptPillar.arithmeticProgression:
        return 6;
      case ConceptPillar.fractionPercentage:
        return 7;
      case ConceptPillar.algebra:
        return 8;
      case ConceptPillar.trigonometry:
        return 9;
      case ConceptPillar.squaresAndCubes:
        return 10;
      case ConceptPillar.heightAndDistance:
        return 11;
    }
  }

  String get ordinalLabel {
    switch (this) {
      case ConceptPillar.linesAndAngle:
        return '1st Topic';
      case ConceptPillar.quadrilaterals:
        return '2nd Topic';
      case ConceptPillar.circle:
        return '3rd Topic';
      case ConceptPillar.mensuration:
        return '4th Topic';
      case ConceptPillar.triangles:
        return '5th Topic';
      case ConceptPillar.arithmeticProgression:
        return '6th Topic';
      case ConceptPillar.fractionPercentage:
        return '7th Topic';
      case ConceptPillar.algebra:
        return '8th Topic';
      case ConceptPillar.trigonometry:
        return '9th Topic';
      case ConceptPillar.squaresAndCubes:
        return '10th Topic';
      case ConceptPillar.heightAndDistance:
        return '11th Topic';
    }
  }

  String get displayName {
    switch (this) {
      case ConceptPillar.linesAndAngle:
        return 'Lines and Angle';
      case ConceptPillar.quadrilaterals:
        return 'Quadrilaterals';
      case ConceptPillar.circle:
        return 'Circle';
      case ConceptPillar.mensuration:
        return 'Mensuration (क्षेत्रमिति 2D & 3D)';
      case ConceptPillar.triangles:
        return 'Triangles';
      case ConceptPillar.arithmeticProgression:
        return 'Arithmetic Progression (A.P.)';
      case ConceptPillar.fractionPercentage:
        return 'Fraction & Percentage Chart';
      case ConceptPillar.algebra:
        return 'Algebra (बीजगणित)';
      case ConceptPillar.trigonometry:
        return 'Trigonometry (त्रिकोणमिति)';
      case ConceptPillar.squaresAndCubes:
        return 'Squares, Cubes & Roots (वर्ग, घन एवं मूल)';
      case ConceptPillar.heightAndDistance:
        return 'Height & Distance (ऊंचाई एवं दूरी)';
    }
  }

  String get shortName {
    switch (this) {
      case ConceptPillar.linesAndAngle:
        return 'Lines & Angle';
      case ConceptPillar.quadrilaterals:
        return 'Quadrilaterals';
      case ConceptPillar.circle:
        return 'Circle';
      case ConceptPillar.mensuration:
        return 'Mensuration (क्षेत्रमिति)';
      case ConceptPillar.triangles:
        return 'Triangles';
      case ConceptPillar.arithmeticProgression:
        return 'A.P. (समांतर श्रेणी)';
      case ConceptPillar.fractionPercentage:
        return 'Fractions (भिन्न-प्रतिशत)';
      case ConceptPillar.algebra:
        return 'Algebra (बीजगणित)';
      case ConceptPillar.trigonometry:
        return 'Trigonometry (त्रिकोणमिति)';
      case ConceptPillar.squaresAndCubes:
        return 'Squares & Roots (वर्ग-घन)';
      case ConceptPillar.heightAndDistance:
        return 'Height & Dist (ऊंचाई-दूरी)';
    }
  }

  String get iconName {
    switch (this) {
      case ConceptPillar.linesAndAngle:
        return 'straighten_rounded';
      case ConceptPillar.quadrilaterals:
        return 'crop_square_rounded';
      case ConceptPillar.circle:
        return 'radio_button_unchecked_rounded';
      case ConceptPillar.mensuration:
        return 'view_in_ar_rounded';
      case ConceptPillar.triangles:
        return 'change_history_rounded';
      case ConceptPillar.arithmeticProgression:
        return 'stacked_line_chart_rounded';
      case ConceptPillar.fractionPercentage:
        return 'percent_rounded';
      case ConceptPillar.algebra:
        return 'functions_rounded';
      case ConceptPillar.trigonometry:
        return 'square_foot_rounded';
      case ConceptPillar.squaresAndCubes:
        return 'calculate_rounded';
      case ConceptPillar.heightAndDistance:
        return 'landscape_rounded';
    }
  }
}

class SolvedExampleModel {
  final String problem;
  final List<String> steps;
  final String answer;
  final String shortcutTip;

  const SolvedExampleModel({
    required this.problem,
    required this.steps,
    required this.answer,
    required this.shortcutTip,
  });
}

class ConceptFormulaModel {
  final String id;
  final ConceptPillar pillar;
  final String title;
  final String subtitle;
  final String formula;
  final String? diagramType;
  final List<String> keyConditions;
  final String explanation;
  final List<SolvedExampleModel> solvedExamples;
  final List<QuestionModel> practiceQuestions;

  const ConceptFormulaModel({
    required this.id,
    required this.pillar,
    required this.title,
    required this.subtitle,
    required this.formula,
    this.diagramType,
    required this.keyConditions,
    required this.explanation,
    required this.solvedExamples,
    required this.practiceQuestions,
  });
}
