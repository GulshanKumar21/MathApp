import 'math_models.dart';

enum ConceptPillar {
  linesAndAngle,
  quadrilaterals,
  circle,
  mensuration,
  triangles,
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
        return 'Mensuration';
      case ConceptPillar.triangles:
        return 'Triangles';
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
        return 'Mensuration';
      case ConceptPillar.triangles:
        return 'Triangles';
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
