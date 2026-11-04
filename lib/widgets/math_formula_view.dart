import 'package:flutter/material.dart';

/// A specialized mathematical formula display widget that renders real
/// mathematical vertical fractions (numerator on top, fraction bar in middle,
/// denominator on bottom) with elegant typography.
class MathFormulaView extends StatelessWidget {
  final String formula;
  final String? formulaId;
  final double fontSize;
  final Color? color;
  final Color? accentColor;
  final bool isHero;

  const MathFormulaView({
    super.key,
    required this.formula,
    this.formulaId,
    this.fontSize = 12.5,
    this.color,
    this.accentColor,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white;
    final effectiveAccent = accentColor ?? const Color(0xFF06B6D4);
    final double fs = isHero ? (fontSize * 1.35) : fontSize;

    // Check if we have a tailored structured layout for this formula
    final Widget? tailoredWidget = _getTailoredFormula(formulaId, fs, effectiveColor, effectiveAccent);
    if (tailoredWidget != null) {
      return tailoredWidget;
    }

    // Dynamic fallback parser that detects fractions with '/' and splits by '|'
    return _buildDynamicFallback(formula, fs, effectiveColor, effectiveAccent);
  }

  /// Builds a fraction with numerator on top, horizontal bar in the middle,
  /// and denominator on bottom.
  static Widget buildFraction(
    String numerator,
    String denominator, {
    required double fontSize,
    required Color color,
    Color? barColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  numerator.trim(),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: color,
                    fontFamily: 'monospace',
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              height: 1.4,
              color: barColor ?? color.withValues(alpha: 0.8),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  denominator.trim(),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: color,
                    fontFamily: 'monospace',
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text element styled matching the mathematical font
  static Widget buildMathText(
    String text, {
    required double fontSize,
    required Color color,
    bool isBold = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          color: color,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  /// Vertical separator pill between formula clauses
  static Widget buildClauseDivider({Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 16,
      width: 1.5,
      color: (color ?? Colors.white).withValues(alpha: 0.25),
    );
  }

  /// Dynamic fallback parser that handles generic "numerator / denominator" patterns
  Widget _buildDynamicFallback(String rawFormula, double fs, Color color, Color accent) {
    final clauses = rawFormula.split('|');

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
      children: clauses.asMap().entries.map((entry) {
        final idx = entry.key;
        final clause = entry.value.trim();

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (idx > 0) buildClauseDivider(color: accent),
            ..._parseSingleClause(clause, fs, color),
          ],
        );
      }).toList(),
    );
  }

  List<Widget> _parseSingleClause(String clause, double fs, Color color) {
    List<Widget> widgets = [];
    final pattern = RegExp(r'(\([^\)]+\)|[A-Za-z0-9²³α-ωΑ-Ω·\+\−\-\*\s]+?)\s*/\s*(\([^\)]+\)|[A-Za-z0-9²³α-ωΑ-Ω·\+\−\-\*]+)');

    int lastIndex = 0;
    for (final match in pattern.allMatches(clause)) {
      if (match.start > lastIndex) {
        final textBefore = clause.substring(lastIndex, match.start);
        if (textBefore.trim().isNotEmpty) {
          widgets.add(buildMathText(textBefore, fontSize: fs, color: color));
        }
      }

      String num = match.group(1) ?? '';
      String den = match.group(2) ?? '';
      if (num.startsWith('(') && num.endsWith(')')) num = num.substring(1, num.length - 1);
      if (den.startsWith('(') && den.endsWith(')')) den = den.substring(1, den.length - 1);

      widgets.add(buildFraction(num, den, fontSize: fs * 0.95, color: color));
      lastIndex = match.end;
    }

    if (lastIndex < clause.length) {
      final remainder = clause.substring(lastIndex);
      if (remainder.trim().isNotEmpty) {
        widgets.add(buildMathText(remainder, fontSize: fs, color: color));
      }
    }

    if (widgets.isEmpty) {
      widgets.add(buildMathText(clause, fontSize: fs, color: color));
    }

    return widgets;
  }

  /// Tailored, pixel-perfect mathematical fraction layouts for the core 30 concepts
  Widget? _getTailoredFormula(String? id, double fs, Color color, Color accent) {
    if (id == null) return null;

    final subFs = fs * 0.95;

    switch (id) {
      // 1. Intercept Theorem
      case 'lines_intercept_theorem':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('AB', 'BC', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('DE', 'EF', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('m', 'n', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('BE = ', fontSize: fs, color: color),
                buildFraction('a·n + b·m', 'm + n', fontSize: subFs, color: color),
              ],
            ),
          ],
        );

      // 2. Arrow Rule
      case 'lines_arrow_rule':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('∠ABO + ∠CDO + ∠BOD = 360°', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('α + β + γ = 360°', fontSize: fs, color: accent),
          ],
        );

      // 3. Zig-Zag Rule
      case 'lines_zigzag_rule':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('α + β + γ = m + n + o', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('Σ LHS = Σ RHS', fontSize: fs, color: accent),
          ],
        );

      // 4. Transversal Angles
      case 'lines_transversal_angles':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('∠1 = ∠5 (Corr)', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('∠3 = ∠5 (Alt)', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('∠4 + ∠5 = 180°', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('∠EGF = 90°', fontSize: fs, color: accent),
          ],
        );

      // 5. Parallelogram Properties
      case 'quad_parallelogram_properties':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('Area = Base × Height', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('2(a² + b²) = d₁² + d₂²', fontSize: fs, color: accent),
          ],
        );

      // 6. Rhombus & Trapezium
      case 'quad_rhombus_trapezium':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('Rhombus: Area = ', fontSize: fs, color: color),
                buildFraction('1', '2', fontSize: subFs, color: color),
                buildMathText(' × d₁ × d₂', fontSize: fs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            buildMathText('4a² = d₁² + d₂²', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('Trap: Area = ', fontSize: fs, color: color),
                buildFraction('a + b', '2', fontSize: subFs, color: color),
                buildMathText(' × h', fontSize: fs, color: color),
              ],
            ),
          ],
        );

      // 7. Cyclic Quadrilateral & Ptolemy
      case 'quad_cyclic_ptolemy':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('∠A + ∠C = 180°', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('AC × BD = (AB × CD) + (BC × AD)', fontSize: fs, color: accent),
          ],
        );

      // 8. Tangent & Secant Theorem
      case 'circle_tangent_secant':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('PT² = PA × PB', fontSize: fs, color: accent),
            buildClauseDivider(color: accent),
            buildMathText('PA × PB = PC × PD (Chords)', fontSize: fs, color: color),
          ],
        );

      // 9. Common Tangents (DCT & TCT)
      case 'circle_common_tangents':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('DCT = √[d² − (R − r)²]', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('TCT = √[d² − (R + r)²]', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('Direct Touch: 2√(R·r)', fontSize: fs, color: accent),
          ],
        );

      // 10. Circle Subtended Angles
      case 'circle_angle_theorems':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('∠Centre = 2 × ∠Circumference', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('∠Semicircle = 90°', fontSize: fs, color: accent),
          ],
        );

      // 11. 2D Mensuration
      case 'mens_2d_areas_perimeters':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('Hero: √[s(s−a)(s−b)(s−c)]', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('Ring: π(R² − r²)', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('Sector: ', fontSize: fs, color: color),
                buildFraction('θ', '360°', fontSize: subFs, color: color),
                buildMathText(' × πr²', fontSize: fs, color: color),
              ],
            ),
          ],
        );

      // 12. 3D Solids & Frustum
      case 'mens_3d_solids_frustum':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('Cylinder: πr²h', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('Cone: ', fontSize: fs, color: color),
                buildFraction('1', '3', fontSize: subFs, color: color),
                buildMathText('πr²h', fontSize: fs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('Sphere: ', fontSize: fs, color: color),
                buildFraction('4', '3', fontSize: subFs, color: color),
                buildMathText('πr³', fontSize: fs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('Frustum: ', fontSize: fs, color: color),
                buildFraction('1', '3', fontSize: subFs, color: color),
                buildMathText('πh(R² + r² + R·r)', fontSize: fs, color: accent),
              ],
            ),
          ],
        );

      // 13. Triangle Formation Condition
      case 'tri_formation_condition':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('|b − c| < a < b + c', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('Side < ', fontSize: fs, color: color),
                buildFraction('Perimeter', '2', fontSize: subFs, color: accent),
              ],
            ),
          ],
        );

      // 14. Triangle Type Identification
      case 'tri_type_identification':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('c² < a² + b² (Acute)', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('c² = a² + b² (Right)', fontSize: fs, color: accent),
            buildClauseDivider(color: accent),
            buildMathText('c² > a² + b² (Obtuse)', fontSize: fs, color: color),
          ],
        );

      // 15. Triangle Similarity
      case 'tri_similarity':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('ΔABC ∼ ΔDEF ➔ ', fontSize: fs, color: color),
                buildFraction('BC', 'EF', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('AC', 'DF', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('AB', 'DE', fontSize: subFs, color: color),
                buildMathText(' = k', fontSize: fs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('Area₁', 'Area₂', fontSize: subFs, color: accent),
                buildMathText(' = k²', fontSize: fs, color: accent),
              ],
            ),
          ],
        );

      // 16. Triangle Congruency
      case 'tri_congruency':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('ΔABC ≅ ΔDEF', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('CPCT (Corresponding Parts Equal)', fontSize: fs, color: accent),
          ],
        );

      // 17. Sine Rule
      case 'tri_sine_rule':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('a', 'sin A', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('b', 'sin B', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('c', 'sin C', fontSize: subFs, color: color),
                buildMathText(' = 2R', fontSize: fs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            buildMathText('a = 2R sin A', fontSize: fs, color: accent),
          ],
        );

      // 18. Cosine Rule
      case 'tri_cosine_rule':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('cos A = ', fontSize: fs, color: color),
                buildFraction('b² + c² − a²', '2bc', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            buildMathText('a² = b² + c² − 2bc cos A', fontSize: fs, color: accent),
          ],
        );

      // 19. Triangle Centres (Incenter, Circumcenter, Centroid)
      case 'tri_centres_properties':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('∠BIC = 90° + ', fontSize: fs, color: color),
                buildFraction('A', '2', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            buildMathText('∠BHC = 180° − A', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('r = ', fontSize: fs, color: color),
                buildFraction('Δ', 's', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('R = ', fontSize: fs, color: color),
                buildFraction('abc', '4Δ', fontSize: subFs, color: accent),
              ],
            ),
          ],
        );

      // 20. Angle Bisector Results
      case 'tri_angle_bisector_results':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('∠BEC = ', fontSize: fs, color: color),
                buildFraction('1', '2', fontSize: subFs, color: color),
                buildMathText('∠BAC', fontSize: fs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('∠DAE = ', fontSize: fs, color: color),
                buildFraction('|∠B − ∠C|', '2', fontSize: subFs, color: accent),
              ],
            ),
          ],
        );

      // 21. Interior Bisector Theorem
      case 'tri_interior_bisector_theorem':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('AB', 'AC', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('BD', 'DC', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            buildMathText('AD² = AB·AC − BD·DC', fontSize: fs, color: accent),
          ],
        );

      // 22. Exterior Bisector Theorem
      case 'tri_exterior_bisector_theorem':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('AB', 'AC', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('DB', 'DC', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('x + BC', 'x', fontSize: subFs, color: accent),
                buildMathText(' = ', fontSize: fs, color: accent),
                buildFraction('AB', 'AC', fontSize: subFs, color: accent),
              ],
            ),
          ],
        );

      // 23. Angle Bisector Length Formula
      case 'tri_angle_bisector_length':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('CD = x = ', fontSize: fs, color: color),
                buildFraction('2ab cos θ', 'a + b', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            buildMathText('θ = ½∠C (Half Angle)', fontSize: fs, color: accent),
          ],
        );

      // 24. Ceva's Theorem
      case 'tri_ceva_theorem':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildMathText('(', fontSize: fs, color: color),
                buildFraction('AF', 'FB', fontSize: subFs, color: color),
                buildMathText(') × (', fontSize: fs, color: color),
                buildFraction('BD', 'DC', fontSize: subFs, color: color),
                buildMathText(') × (', fontSize: fs, color: color),
                buildFraction('CE', 'EA', fontSize: subFs, color: color),
                buildMathText(') = 1', fontSize: fs, color: accent),
              ],
            ),
          ],
        );

      // 25. Thales Theorem (BPT)
      case 'tri_thales_theorem':
      case 'tri_similarity_thales':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('AD', 'DB', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('AE', 'EC', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('DE', 'BC', fontSize: subFs, color: color),
                buildMathText(' = ', fontSize: fs, color: color),
                buildFraction('AD', 'AB', fontSize: subFs, color: color),
              ],
            ),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('Area(ADE)', 'Area(ABC)', fontSize: subFs, color: accent),
                buildMathText(' = (', fontSize: fs, color: accent),
                buildFraction('AD', 'AB', fontSize: subFs, color: accent),
                buildMathText(')²', fontSize: fs, color: accent),
              ],
            ),
          ],
        );

      // 26. Stewart Theorem
      case 'tri_stewart_theorem':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('a²n + b²m = x²c + mnc', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('Equilateral: x² = a² − mn', fontSize: fs, color: accent),
          ],
        );

      // 27. British Flag Theorem
      case 'tri_british_flag_theorem':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('PA² + PC² = PB² + PD²', fontSize: fs, color: accent),
          ],
        );

      // 28. Apollonius Theorem & Medians
      case 'tri_apollonius_medians':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('AB² + AC² = 2(AD² + BD²)', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('3(AB² + BC² + CA²) = 4(m₁² + m₂² + m₃²)', fontSize: fs, color: accent),
          ],
        );

      // 29. Right Triangle Altitudes
      case 'tri_altitude_hypotenuse':
      case 'right_triangle_altitudes':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('CD² = BD × AD', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('BC² = BD × AB', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildFraction('BC²', 'CA²', fontSize: subFs, color: accent),
                buildMathText(' = ', fontSize: fs, color: accent),
                buildFraction('BD', 'DA', fontSize: subFs, color: accent),
              ],
            ),
          ],
        );

      // 30. Incircle Tangent Lengths
      case 'tri_incircle_tangent_lengths':
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          alignment: isHero ? WrapAlignment.center : WrapAlignment.start,
          children: [
            buildMathText('x = s − a', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('y = s − b', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('z = s − c', fontSize: fs, color: color),
            buildClauseDivider(color: accent),
            buildMathText('Area = √[s · xyz]', fontSize: fs, color: accent),
          ],
        );

      default:
        return null;
    }
  }
}
