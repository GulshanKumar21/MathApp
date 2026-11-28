import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/widgets/math_formula_view.dart';
import 'package:math_speed_practice/screens/concepts/concept_detail_screen.dart';
import 'package:math_speed_practice/models/concept_formula_model.dart';
import 'package:math_speed_practice/models/math_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MathFormulaView On-Screen Fit (No Horizontal Scroll)', () {
    testWidgets('Multi-clause formula in Hero mode renders as stacked Column without horizontal scroll', (tester) async {
      const testFormula = 'Area = l × b | Perimeter = 2(l + b) | Diagonal d = √(l² + b²)';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: MathFormulaView(
                  formula: testFormula,
                  fontSize: 15.0,
                  isHero: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify that all 3 clauses are present in the widget tree
      expect(find.textContaining('Area = l × b'), findsOneWidget);
      expect(find.textContaining('Perimeter = 2(l + b)'), findsOneWidget);
      expect(find.textContaining('Diagonal d = √(l² + b²)'), findsOneWidget);

      // Verify that NO horizontal SingleChildScrollView is used inside MathFormulaView
      final scrollViews = find.descendant(
        of: find.byType(MathFormulaView),
        matching: find.byType(SingleChildScrollView),
      );
      expect(scrollViews, findsNothing);

      // Verify it renders as a Column stacking the equations
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('Single clause formula in Hero mode fits within bounded container with FittedBox', (tester) async {
      const testFormula = 'Area = (√3 / 4) · a²';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: MathFormulaView(
                  formula: testFormula,
                  fontSize: 15.0,
                  isHero: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Area ='), findsOneWidget);
      expect(find.byType(FittedBox), findsWidgets);
    });

    testWidgets('ConceptDetailScreen formula hero card does not have horizontal scrolling', (tester) async {
      final sampleConcept = ConceptFormulaModel(
        id: 'test_rect',
        pillar: ConceptPillar.mensuration,
        title: 'Rectangle | आयत (2D Mensuration)',
        subtitle: 'Test Subtitle',
        formula: 'Area = l × b | Perimeter = 2(l + b) | Diagonal d = √(l² + b²)',
        keyConditions: ['Test condition'],
        explanation: 'Test explanation',
        solvedExamples: [
          SolvedExampleModel(
            problem: 'Find area',
            steps: ['Step 1'],
            answer: '432 cm²',
            shortcutTip: 'Fast tip',
          ),
        ],
        practiceQuestions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConceptDetailScreen(formula: sampleConcept),
        ),
      );

      await tester.pumpAndSettle();

      // Find the "EXAM FORMULA" text
      expect(find.text('EXAM FORMULA'), findsOneWidget);

      // Verify that within the formula card, there is NO horizontal scroll view
      final formulaHeroFinder = find.ancestor(
        of: find.text('EXAM FORMULA'),
        matching: find.byType(Container),
      ).first;

      final innerHorizontalScroll = find.descendant(
        of: formulaHeroFinder,
        matching: find.byWidgetPredicate(
          (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
        ),
      );

      expect(innerHorizontalScroll, findsNothing);

      // Verify that all formula equations are visible simultaneously
      expect(find.textContaining('Area = l × b'), findsOneWidget);
      expect(find.textContaining('Perimeter = 2(l + b)'), findsOneWidget);
      expect(find.textContaining('Diagonal d = √(l² + b²)'), findsOneWidget);
    });
  });
}
