import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathapp/models/math_models.dart';
import 'package:mathapp/screens/practice/topic_drill_selection_screen.dart';

void main() {
  Widget createTestWidget(TopicType type) {
    return MaterialApp(
      home: TopicDrillSelectionScreen(type: type),
    );
  }

  group('TopicDrillSelectionScreen Widget Tests', () {
    testWidgets('Renders Fractions & % selection screen with 4 categories', (tester) async {
      await tester.pumpWidget(createTestWidget(TopicType.fractions));
      await tester.pumpAndSettle();

      expect(find.text('Fractions & % Drills'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('Core Standard Fractions (1/2 to 1/10)'), findsOneWidget);
      expect(find.text('Advanced Fractions (1/11 to 1/25)'), findsOneWidget);
      expect(find.text('Fractional Multiples & Decimals'), findsOneWidget);
      expect(find.text('All-in-One Full Mixed Speed Drill'), findsOneWidget);
      expect(find.text('Questions Count:'), findsOneWidget);
      expect(find.text('Speed Timer Pace:'), findsOneWidget);
    });

    testWidgets('Renders LCM & HCF selection screen with 4 categories', (tester) async {
      await tester.pumpWidget(createTestWidget(TopicType.lcmHcf));
      await tester.pumpAndSettle();

      expect(find.text('LCM & HCF Master Drills'), findsOneWidget);
      expect(find.text('Basic Numbers LCM & HCF'), findsOneWidget);
      expect(find.text('LCM & HCF of Fractions'), findsOneWidget);
      expect(find.text('Co-Prime & Product Relationships'), findsOneWidget);
      expect(find.text('4 Classic Remainder Cases & Mixed Drills'), findsOneWidget);
    });

    testWidgets('Renders Divisibility Rules selection screen with 4 categories', (tester) async {
      await tester.pumpWidget(createTestWidget(TopicType.divisibility));
      await tester.pumpAndSettle();

      expect(find.text('Divisibility Rules Drills'), findsOneWidget);
      expect(find.text('Powers of 2 & 5 (2, 4, 8, 16 & 5, 25)'), findsOneWidget);
      expect(find.text('Sum of Digits Rules (3, 9, 27)'), findsOneWidget);
      expect(find.text('Alternating & Osculation Rules (7, 11, 13)'), findsOneWidget);
      expect(find.text('Composite Divisors (72, 88, 99, 144)'), findsOneWidget);
    });

    testWidgets('Renders Number System selection screen with 4 categories', (tester) async {
      await tester.pumpWidget(createTestWidget(TopicType.numberSystem));
      await tester.pumpAndSettle();

      expect(find.text('Number System Drills'), findsOneWidget);
      expect(find.text('Unit Digits & Cyclicity (Power mod 4)'), findsOneWidget);
      expect(find.text('Number of Trailing Zeroes in Products & Factorials'), findsOneWidget);
      expect(find.text('Series Summation (Σn, Σn², Σn³)'), findsOneWidget);
      expect(find.text('Factors Count, Sum & Remainder Theorems'), findsOneWidget);
    });

    testWidgets('Renders Pythagorean Triples selection screen with 4 categories', (tester) async {
      await tester.pumpWidget(createTestWidget(TopicType.triples));
      await tester.pumpAndSettle();

      expect(find.text('Pythagorean Triples Drills'), findsOneWidget);
      expect(find.text('Primary Base Triples (3-4-5, 5-12-13...)'), findsOneWidget);
      expect(find.text('Higher & Tier-II Triples'), findsOneWidget);
      expect(find.text('Scaled Multipliers (2×, 3×, 5× Base Triples)'), findsOneWidget);
      expect(find.text('Rapid Hypotenuse & Leg Speed Sprint'), findsOneWidget);
    });

    testWidgets('Renders Square Root & Surds selection screen with 4 categories', (tester) async {
      await tester.pumpWidget(createTestWidget(TopicType.squareRootSurds));
      await tester.pumpAndSettle();

      expect(find.text('Square Root & Surds Drills'), findsOneWidget);
      expect(find.text('Perfect Square Roots (1 to 10,000)'), findsOneWidget);
      expect(find.text('Non-Perfect Root Approximations'), findsOneWidget);
      expect(find.text('Infinite Radical Series & Patterns'), findsOneWidget);
      expect(find.text('Surds Rationalization & Size Comparison'), findsOneWidget);
    });

    testWidgets('Renders Trigonometry selection screen with 4 categories', (tester) async {
      await tester.pumpWidget(createTestWidget(TopicType.trigonometry));
      await tester.pumpAndSettle();

      expect(find.text('Trigonometry Drills'), findsOneWidget);
      expect(find.text('Standard Table Values (0°, 30°, 45°, 60°, 90°)'), findsOneWidget);
      expect(find.text('Complementary Angles (Sum = 90°)'), findsOneWidget);
      expect(find.text('Pythagorean Identities & Conjugate Rules'), findsOneWidget);
      expect(find.text('Maximum & Minimum Values & Mixed Sprint'), findsOneWidget);
    });
  });
}
