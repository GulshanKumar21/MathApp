import 'dart:math' as math;
import '../data/concept_formula_repository.dart';
import '../data/concept_examiner_traps.dart';
import '../data/blackbook_vocabulary_bank.dart';
import '../models/concept_formula_model.dart';

/// 🧠 Comprehensive AI Tutor Engine:
/// An intelligent, multi-disciplinary solver for competitive exam students (SSC, Railway, Banking).
/// Dynamically solves:
/// 1. Arithmetic (Multiplication, Division, Addition, Subtraction, BODMAS, Powers, Roots)
/// 2. Percentages & Fractional Equivalents (e.g. 16.66% = 1/6)
/// 3. 2D & 3D Geometry/Mensuration (Rectangle, Square, Circle, Triangle, Cylinder, Cone, Sphere, etc.)
/// 4. Algebra (x + 1/x = k identities, expansions, quadratic)
/// 5. Number System (LCM, HCF, Divisibility rules)
/// 6. Trigonometry (Standard angle values, complementary products, identities)
/// 7. 300+ Pre-loaded Concept Formulas & Traps from ConceptFormulaRepository
/// 8. English Blackbook Vocabulary, Homophones, and Idioms
/// 9. Natural language Hinglish/English doubt queries
class AiTutorEngine {
  static Map<String, dynamic> solve(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return _buildEmptyResponse();
    }

    final lower = query.toLowerCase();

    // -------------------------------------------------------------
    // PRIORITY 1: Percentage Calculations (e.g. "What is 16.66% of 720?")
    // -------------------------------------------------------------
    final pctMatch = RegExp(r'(\d+(?:\.\d+)?)\s*%\s*(?:of)\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(lower);
    if (pctMatch != null) {
      return _solvePercentage(double.parse(pctMatch.group(1)!), double.parse(pctMatch.group(2)!));
    }

    // -------------------------------------------------------------
    // PRIORITY 2: Algebra: x + 1/x = k or x - 1/x = k
    // -------------------------------------------------------------
    final algMatchPlus = RegExp(r'x\s*\+\s*1/x\s*=\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(lower);
    if (algMatchPlus != null) {
      final k = double.parse(algMatchPlus.group(1)!);
      return _solveAlgebraReciprocalPlus(k);
    }
    final algMatchMinus = RegExp(r'x\s*[-−]\s*1/x\s*=\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(lower);
    if (algMatchMinus != null) {
      final k = double.parse(algMatchMinus.group(1)!);
      return _solveAlgebraReciprocalMinus(k);
    }

    // -------------------------------------------------------------
    // PRIORITY 3: Squares & Cubes (e.g. "square of 45", "45^2", "cube of 12")
    // -------------------------------------------------------------
    final sqMatch = RegExp(r'(?:square\s+(?:of\s+)?(\d+)|(\d+)\s*(?:\^2|²))', caseSensitive: false).firstMatch(lower);
    if (sqMatch != null) {
      final n = int.parse(sqMatch.group(1) ?? sqMatch.group(2)!);
      return _solveSquare(n);
    }

    final cubeMatch = RegExp(r'(?:cube\s+(?:of\s+)?(\d+)|(\d+)\s*(?:\^3|³))', caseSensitive: false).firstMatch(lower);
    if (cubeMatch != null) {
      final n = int.parse(cubeMatch.group(1) ?? cubeMatch.group(2)!);
      return _solveCube(n);
    }

    // -------------------------------------------------------------
    // PRIORITY 4: Square Roots & Cube Roots (e.g. "sqrt(144)", "√625", "cbrt(1728)")
    // -------------------------------------------------------------
    final sqrtMatch = RegExp(r'(?:sqrt|√|square\s+root\s+(?:of\s+)?)[\s\(]*(\d+)[\)]*', caseSensitive: false).firstMatch(lower);
    if (sqrtMatch != null) {
      final n = int.parse(sqrtMatch.group(1)!);
      return _solveSquareRoot(n);
    }

    final cbrtMatch = RegExp(r'(?:cbrt|∛|cube\s+root\s+(?:of\s+)?)[\s\(]*(\d+)[\)]*', caseSensitive: false).firstMatch(lower);
    if (cbrtMatch != null) {
      final n = int.parse(cbrtMatch.group(1)!);
      return _solveCubeRoot(n);
    }

    // -------------------------------------------------------------
    // PRIORITY 5: Number System (LCM, HCF & Divisibility)
    // -------------------------------------------------------------
    final lcmMatch = RegExp(r'lcm\s+(?:of\s+)?(\d+)(?:\s*(?:,|and|&)\s*(\d+))(?:\s*(?:,|and|&)\s*(\d+))?', caseSensitive: false).firstMatch(lower);
    if (lcmMatch != null) {
      final a = int.parse(lcmMatch.group(1)!);
      final b = int.parse(lcmMatch.group(2)!);
      final c = lcmMatch.group(3) != null ? int.parse(lcmMatch.group(3)!) : null;
      return _solveLcm(a, b, c);
    }

    final hcfMatch = RegExp(r'(?:hcf|gcd)\s+(?:of\s+)?(\d+)(?:\s*(?:,|and|&)\s*(\d+))(?:\s*(?:,|and|&)\s*(\d+))?', caseSensitive: false).firstMatch(lower);
    if (hcfMatch != null) {
      final a = int.parse(hcfMatch.group(1)!);
      final b = int.parse(hcfMatch.group(2)!);
      final c = hcfMatch.group(3) != null ? int.parse(hcfMatch.group(3)!) : null;
      return _solveHcf(a, b, c);
    }

    final divMatch = RegExp(r'(?:divisible|divisibility)\s*(?:by|rule\s+of)?\s*(\d+)', caseSensitive: false).firstMatch(lower);
    if (divMatch != null) {
      final d = int.parse(divMatch.group(1)!);
      return _solveDivisibilityRule(d, query);
    }

    // -------------------------------------------------------------
    // PRIORITY 6: Mensuration & Geometry Calculations
    // -------------------------------------------------------------
    // 6A. Rectangle
    if (lower.contains('rectangle') || lower.contains('आयत')) {
      final res = _trySolveRectangle(query, lower);
      if (res != null) return res;
    }

    // 6B. Circle
    if (lower.contains('circle') || lower.contains('वृत्त')) {
      final res = _trySolveCircle(query, lower);
      if (res != null) return res;
    }

    // 6C. Triangle
    if (lower.contains('triangle') || lower.contains('त्रिभुज')) {
      final res = _trySolveTriangle(query, lower);
      if (res != null) return res;
    }

    // 6D. Cylinder
    if (lower.contains('cylinder') || lower.contains('बेलन')) {
      final res = _trySolveCylinder(query, lower);
      if (res != null) return res;
    }

    // 6E. Cone
    if (lower.contains('cone') || lower.contains('शंकु')) {
      final res = _trySolveCone(query, lower);
      if (res != null) return res;
    }

    // 6F. Sphere / Hemisphere
    if (lower.contains('sphere') || lower.contains('hemisphere') || lower.contains('गोला') || lower.contains('अर्धगोला')) {
      final res = _trySolveSphere(query, lower);
      if (res != null) return res;
    }

    // 6G. Rhombus
    if (lower.contains('rhombus') || lower.contains('समचतुर्भुज')) {
      final res = _trySolveRhombus(query, lower);
      if (res != null) return res;
    }

    // 6H. Square Shape
    if ((lower.contains('square') || lower.contains('वर्ग')) && !lower.contains('square of') && !lower.contains('square root')) {
      final res = _trySolveSquareShape(query, lower);
      if (res != null) return res;
    }

    // -------------------------------------------------------------
    // PRIORITY 7: Trigonometry Queries (Standard Angles & Identities)
    // -------------------------------------------------------------
    final trigValRes = _trySolveTrigValues(lower);
    if (trigValRes != null) return trigValRes;

    // -------------------------------------------------------------
    // PRIORITY 8: Arithmetic (Multiplication, Division, Addition, Subtraction)
    // -------------------------------------------------------------
    // Multiplication: a * b or multiply a by b or a into b
    final multMatch = RegExp(r'(\d+(?:\.\d+)?)\s*[\*×xX]\s*(\d+(?:\.\d+)?)').firstMatch(query) ??
        RegExp(r'(?:multiply|into)\s*(\d+(?:\.\d+)?)\s*(?:by|and|\*|x)?\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(query);
    if (multMatch != null) {
      final a = double.parse(multMatch.group(1)!);
      final b = double.parse(multMatch.group(2)!);
      return _solveMultiplication(a, b);
    }

    // Division: a / b or divide a by b
    final divMathMatch = RegExp(r'(\d+(?:\.\d+)?)\s*[\/÷]\s*(\d+(?:\.\d+)?)').firstMatch(query) ??
        RegExp(r'(?:divide)\s*(\d+(?:\.\d+)?)\s*(?:by|\/)\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(query);
    if (divMathMatch != null) {
      final a = double.parse(divMathMatch.group(1)!);
      final b = double.parse(divMathMatch.group(2)!);
      return _solveDivision(a, b);
    }

    // Subtraction: a - b
    final subMatch = RegExp(r'(\d+(?:\.\d+)?)\s*[-−]\s*(\d+(?:\.\d+)?)').firstMatch(query);
    if (subMatch != null) {
      final a = double.parse(subMatch.group(1)!);
      final b = double.parse(subMatch.group(2)!);
      return _solveSubtraction(a, b);
    }

    // Addition: a + b
    final addMatch = RegExp(r'(\d+(?:\.\d+)?)\s*\+\s*(\d+(?:\.\d+)?)').firstMatch(query);
    if (addMatch != null) {
      final a = double.parse(addMatch.group(1)!);
      final b = double.parse(addMatch.group(2)!);
      return _solveAddition(a, b);
    }

    // -------------------------------------------------------------
    // PRIORITY 9: Search App Concept Formula Repository (300+ formulas)
    // -------------------------------------------------------------
    final conceptResult = _trySearchConceptRepository(query, lower);
    if (conceptResult != null) return conceptResult;

    // -------------------------------------------------------------
    // PRIORITY 10: English Vocabulary, Homophones, Idioms
    // -------------------------------------------------------------
    final vocabResult = _trySearchVocabulary(lower);
    if (vocabResult != null) return vocabResult;

    // -------------------------------------------------------------
    // PRIORITY 11: Intelligent Fallback with Extracted Entities
    // -------------------------------------------------------------
    return _solveGeneralNaturalQuery(query);
  }

  // =========================================================================
  // SOLVER IMPLEMENTATIONS
  // =========================================================================

  /// 1. Percentage Solver
  static Map<String, dynamic> _solvePercentage(double pct, double num) {
    final ans = (pct / 100.0) * num;
    final formattedAns = ans % 1 == 0 ? ans.toInt().toString() : ans.toStringAsFixed(2);
    final formattedPct = pct % 1 == 0 ? pct.toInt().toString() : pct.toString();
    final formattedNum = num % 1 == 0 ? num.toInt().toString() : num.toString();

    // Check for standard fractional equivalents
    String fractionText = '';
    String trick = '';
    if ((pct - 16.66).abs() < 0.1 || (pct - 16.67).abs() < 0.1 || (pct - 16.6).abs() < 0.1) {
      fractionText = '16.66% ≈ 1/6';
      trick = '⚡ Fractional Shortcut: 16.66% = 1/6. Simply divide $formattedNum by 6 ➔ $formattedNum ÷ 6 = $formattedAns (in 1 second)!';
    } else if ((pct - 14.28).abs() < 0.1 || (pct - 14.29).abs() < 0.1) {
      fractionText = '14.28% ≈ 1/7';
      trick = '⚡ Fractional Shortcut: 14.28% = 1/7. Simply divide $formattedNum by 7 ➔ $formattedNum ÷ 7 = $formattedAns!';
    } else if ((pct - 12.5).abs() < 0.1) {
      fractionText = '12.5% = 1/8';
      trick = '⚡ Fractional Shortcut: 12.5% = 1/8. Halve three times: $formattedNum ÷ 8 = $formattedAns!';
    } else if ((pct - 11.11).abs() < 0.1) {
      fractionText = '11.11% = 1/9';
      trick = '⚡ Fractional Shortcut: 11.11% = 1/9. Divide by 9 ➔ $formattedNum ÷ 9 = $formattedAns!';
    } else if ((pct - 9.09).abs() < 0.1) {
      fractionText = '9.09% = 1/11';
      trick = '⚡ Fractional Shortcut: 9.09% = 1/11. Divide by 11 ➔ $formattedNum ÷ 11 = $formattedAns!';
    } else if ((pct - 8.33).abs() < 0.1) {
      fractionText = '8.33% = 1/12';
      trick = '⚡ Fractional Shortcut: 8.33% = 1/12. Divide by 12 ➔ $formattedNum ÷ 12 = $formattedAns!';
    } else if ((pct - 37.5).abs() < 0.1) {
      fractionText = '37.5% = 3/8';
      trick = '⚡ Fractional Shortcut: 37.5% = 3/8. Take ⅛th ($formattedNum ÷ 8 = ${(num / 8).toStringAsFixed(1)}) and multiply by 3 ➔ $formattedAns!';
    } else if ((pct - 62.5).abs() < 0.1) {
      fractionText = '62.5% = 5/8';
      trick = '⚡ Fractional Shortcut: 62.5% = 5/8. Take ⅛th ($formattedNum ÷ 8) and multiply by 5 ➔ $formattedAns!';
    } else if ((pct - 20).abs() < 0.01) {
      fractionText = '20% = 1/5';
      trick = '⚡ Rapid Division: 20% = 1/5. Double $formattedNum and drop a zero ➔ $formattedAns!';
    } else if ((pct - 25).abs() < 0.01) {
      fractionText = '25% = 1/4';
      trick = '⚡ Quarter Trick: 25% = 1/4. Halve twice: $formattedNum ÷ 2 ÷ 2 = $formattedAns!';
    } else {
      fractionText = '$formattedPct% = $formattedPct / 100';
      trick = '⚡ Split & Multiply: Split $formattedPct% into friendly round numbers (e.g. 10% + 5% or 50% - 1%) to compute mentally!';
    }

    return {
      'topic': 'Percentage to Fraction Conversion (प्रतिशत-भिन्न नियम)',
      'category': 'Arithmetic Mastery',
      'formula': 'Percentage Value = (P / 100) × N  |  $fractionText',
      'steps': [
        'Given: $formattedPct% of $formattedNum = ?',
        if (fractionText.isNotEmpty && fractionText.contains('/'))
          'Convert percentage to benchmark fraction: $formattedPct% ➔ $fractionText.'
        else
          'Write formula: ($formattedPct / 100) × $formattedNum.',
        'Multiply and simplify: ($formattedPct × $formattedNum) ÷ 100 = $formattedAns.',
        'Final Calculated Value = $formattedAns.',
      ],
      'speedTrick': trick,
      'pitfall': 'Never multiply by decimals on paper in exam! Always convert standard percentages (12.5%, 16.66%, 14.28%, 37.5%) to their exact fractions.',
      'answer': formattedAns,
    };
  }

  /// 2. Algebra x + 1/x = k
  static Map<String, dynamic> _solveAlgebraReciprocalPlus(double k) {
    final sqVal = (k * k) - 2;
    final cubeVal = (k * k * k) - (3 * k);
    final quadVal = (sqVal * sqVal) - 2;

    final kStr = k % 1 == 0 ? k.toInt().toString() : k.toString();
    final sqStr = sqVal % 1 == 0 ? sqVal.toInt().toString() : sqVal.toStringAsFixed(2);
    final cubeStr = cubeVal % 1 == 0 ? cubeVal.toInt().toString() : cubeVal.toStringAsFixed(2);
    final quadStr = quadVal % 1 == 0 ? quadVal.toInt().toString() : quadVal.toStringAsFixed(2);

    return {
      'topic': 'Algebraic Reciprocal Identities: x + 1/x = k (बीजगणित सूत्र)',
      'category': 'Algebra Master Class',
      'formula': 'x² + 1/x² = k² − 2  |  x³ + 1/x³ = k³ − 3k  |  x⁴ + 1/x⁴ = (k² − 2)² − 2',
      'steps': [
        'Given: x + 1/x = $kStr.',
        '1. Square identity: (x + 1/x)² = x² + 1/x² + 2 ⇒ x² + 1/x² = $kStr² − 2 = ${k * k} − 2 = $sqStr.',
        '2. Cube identity: (x + 1/x)³ = x³ + 1/x³ + 3(x + 1/x) ⇒ x³ + 1/x³ = $kStr³ − 3($kStr) = ${k * k * k} − ${3 * k} = $cubeStr.',
        '3. Degree 4 identity: (x² + 1/x²)² − 2 = $sqStr² − 2 = $quadStr.',
      ],
      'speedTrick': '⚡ 2-Second Exam Hack: If x + 1/x = $kStr, just square and subtract 2 for square ($kStr² − 2 = $sqStr), or cube and subtract 3k for cube ($kStr³ − 3×$kStr = $cubeStr)!',
      'pitfall': 'When x + 1/x = k, sign is MINUS 2 (k² − 2). When x − 1/x = k, sign is PLUS 2 (k² + 2). Don\'t flip the signs!',
      'answer': 'x² + 1/x² = $sqStr, x³ + 1/x³ = $cubeStr',
    };
  }

  /// Algebra x - 1/x = k
  static Map<String, dynamic> _solveAlgebraReciprocalMinus(double k) {
    final sqVal = (k * k) + 2;
    final cubeVal = (k * k * k) + (3 * k);

    final kStr = k % 1 == 0 ? k.toInt().toString() : k.toString();
    final sqStr = sqVal % 1 == 0 ? sqVal.toInt().toString() : sqVal.toStringAsFixed(2);
    final cubeStr = cubeVal % 1 == 0 ? cubeVal.toInt().toString() : cubeVal.toStringAsFixed(2);

    return {
      'topic': 'Algebraic Reciprocal Identities: x − 1/x = k (बीजगणित सूत्र)',
      'category': 'Algebra Master Class',
      'formula': 'x² + 1/x² = k² + 2  |  x³ − 1/x³ = k³ + 3k',
      'steps': [
        'Given: x − 1/x = $kStr.',
        '1. Square identity: (x − 1/x)² = x² + 1/x² − 2 ⇒ x² + 1/x² = $kStr² + 2 = ${k * k} + 2 = $sqStr.',
        '2. Cube identity: (x − 1/x)³ = x³ − 1/x³ − 3(x − 1/x) ⇒ x³ − 1/x³ = $kStr³ + 3($kStr) = ${k * k * k} + ${3 * k} = $cubeStr.',
      ],
      'speedTrick': '⚡ Exam Rule: Notice that with minus (x − 1/x), both shortcuts ADD: k² + 2 = $sqStr, k³ + 3k = $cubeStr!',
      'pitfall': 'Do not calculate x² − 1/x² using k² + 2; that is (x + 1/x)(x − 1/x).',
      'answer': 'x² + 1/x² = $sqStr, x³ − 1/x³ = $cubeStr',
    };
  }

  /// 3. Square of N
  static Map<String, dynamic> _solveSquare(int n) {
    final ans = n * n;
    String trick = '';

    if (n % 10 == 5) {
      final lead = n ~/ 10;
      final leadMult = lead * (lead + 1);
      trick = '⚡ Ekadhikena Purvena (Ending in 5): Multiply leading digit $lead by next integer ${lead + 1} ($lead × ${lead + 1} = $leadMult) and append 25 ➔ $ans!';
    } else if (n >= 90 && n <= 110) {
      final diff = n - 100;
      final part1 = n + diff;
      final part2 = (diff * diff).toString().padLeft(2, '0');
      trick = '⚡ Base 100 Deficit Rule: $n has deviation $diff from 100. First part: $n + ($diff) = $part1; Second part: ($diff)² = $part2 ➔ $ans!';
    } else if (n >= 40 && n <= 60) {
      final diff = n - 50;
      final part1 = 25 + diff;
      final part2 = (diff * diff).toString().padLeft(2, '0');
      trick = '⚡ Base 50 Rule: Deviation from 50 is $diff. First part: 25 + ($diff) = $part1; Second part: ($diff)² = $part2 ➔ $ans!';
    } else {
      final tens = (n ~/ 10) * 10;
      final units = n % 10;
      trick = '⚡ (a + b)² Expansion: $n² = ($tens + $units)² = ${tens * tens} + ${2 * tens * units} + ${units * units} = $ans.';
    }

    return {
      'topic': 'Vedic Rapid Squaring (वर्ग निकालने की वैदिक विधि)',
      'category': 'Speed Calculation',
      'formula': 'n² = (a + b)² = a² + 2ab + b²  |  Base 100: (100 ± d)² = (100 ± 2d)·100 + d²',
      'steps': [
        'Given Number: $n',
        'Mathematical Value: $n × $n = $ans.',
        trick,
        'Final Square = $ans.',
      ],
      'speedTrick': trick,
      'pitfall': 'SSC questions often test squares up to 50 directly. Memorizing 1–30 and using base 50/100 rules for 31–125 saves 40+ seconds.',
      'answer': '$ans',
    };
  }

  /// 4. Cube of N
  static Map<String, dynamic> _solveCube(int n) {
    final ans = n * n * n;
    return {
      'topic': 'Cube Calculation (घन निकालने का नियम)',
      'category': 'Speed Calculation',
      'formula': '(a + b)³ = a³ + 3a²b + 3ab² + b³',
      'steps': [
        'Given Number: $n',
        'Step 1: Square of $n = ${n * n}.',
        'Step 2: Multiply by $n again: ${n * n} × $n = $ans.',
        'Final Cube = $ans.',
      ],
      'speedTrick': '⚡ Last Digit Rule: The last digit of a cube is unique for all 10 digits (1➔1, 2➔8, 3➔7, 4➔4, 5➔5, 6➔6, 7➔3, 8➔2, 9➔9, 0➔0). For $n, last digit of cube is ${ans % 10}!',
      'pitfall': 'Do not confuse (2n)³ with 2n³. (2n)³ = 8n³.',
      'answer': '$ans',
    };
  }

  /// 5. Square Root of N
  static Map<String, dynamic> _solveSquareRoot(int n) {
    final root = math.sqrt(n);
    final isPerfect = root % 1 == 0;
    final ansStr = isPerfect ? root.toInt().toString() : root.toStringAsFixed(2);

    return {
      'topic': 'Square Root Extraction (वर्गमूल ज्ञात करना)',
      'category': 'Number System & Speed Maths',
      'formula': isPerfect
          ? '√n = Exact Integer Factor (Unit Digit Pairing Method)'
          : 'Approximation: √(A ± b) ≈ √A ± b / (2√A)',
      'steps': [
        'Given Number: $n',
        if (isPerfect) ...[
          'Identify unit digit: ${n % 10}.',
          'Notice that (${root.toInt()})² = $n exactly.',
          'Therefore, √$n = ${root.toInt()}.',
        ] else ...[
          'Find nearest perfect square below $n.',
          'Using differential approximation: √$n ≈ $ansStr.',
        ],
        'Final Answer = $ansStr.',
      ],
      'speedTrick': isPerfect
          ? '⚡ Unit Digit Elimination: For square ending in ${n % 10}, possible root unit digits are narrowed instantly! Strike last 2 digits to read the tens place.'
          : '⚡ Approximation Hack: Nearest square is ${(root.floor() * root.floor())}. √$n ≈ ${root.floor()} + ${(n - (root.floor() * root.floor()))} / (2 × ${root.floor()}) = $ansStr.',
      'pitfall': 'Square roots of non-perfect numbers must be handled with the fractional approximation in SSC exams.',
      'answer': ansStr,
    };
  }

  /// 6. Cube Root of N
  static Map<String, dynamic> _solveCubeRoot(int n) {
    final cbrt = math.pow(n, 1.0 / 3.0).round();
    final isExact = cbrt * cbrt * cbrt == n;
    final ansStr = isExact ? cbrt.toString() : math.pow(n, 1.0 / 3.0).toStringAsFixed(2);

    return {
      'topic': 'Vedic Cube Root in 2 Seconds (घनमूल शॉर्टकट)',
      'category': 'Number System',
      'formula': 'Pair last 3 digits: Unit digit uniquely maps ➔ Remaining digits give tens place',
      'steps': [
        'Given Number: $n',
        'Look at unit digit: ${n % 10}. Cube roots have unique 1-to-1 endings (2↔8, 3↔7, others stay same).',
        'Unit digit of root must be: ${isExact ? (cbrt % 10) : "approx"}.',
        if (isExact) 'Tens place is from remaining digits: $cbrt.' else 'Approximate value: $ansStr.',
        'Final Cube Root = $ansStr.',
      ],
      'speedTrick': '⚡ 2-Second Vedic Trick: Strike out last 3 digits! For the rest, find the largest cube that fits. For the unit digit, 2 becomes 8, 3 becomes 7, 7 becomes 3, 8 becomes 2. Answer is instant!',
      'pitfall': 'This rapid method works for perfect cubes up to 6 digits (up to 1,000,000).',
      'answer': ansStr,
    };
  }

  /// 7. LCM of 2 or 3 numbers
  static Map<String, dynamic> _solveLcm(int a, int b, [int? c]) {
    int gcd(int x, int y) => y == 0 ? x : gcd(y, x % y);
    int lcm(int x, int y) => (x * y) ~/ gcd(x, y);

    final lcmAB = lcm(a, b);
    final finalLcm = c != null ? lcm(lcmAB, c) : lcmAB;
    final numbersList = c != null ? '$a, $b, $c' : '$a, $b';

    return {
      'topic': 'Lowest Common Multiple (लघुत्तम समापवर्त्य - LCM)',
      'category': 'Number System',
      'formula': 'LCM(a, b) = (a × b) / HCF(a, b)  |  Product of Two Numbers = LCM × HCF',
      'steps': [
        'Find LCM of ($numbersList).',
        'Prime Factorization method or Ladder division:',
        'HCF($a, $b) = ${gcd(a, b)}.',
        'LCM($a, $b) = ($a × $b) ÷ ${gcd(a, b)} = $lcmAB.',
        if (c != null) ...[
          'Now compute LCM with third number $c: LCM($lcmAB, $c).',
          'HCF($lcmAB, $c) = ${gcd(lcmAB, c)}.',
          'LCM = ($lcmAB × $c) ÷ ${gcd(lcmAB, c)} = $finalLcm.',
        ],
        'Final LCM = $finalLcm.',
      ],
      'speedTrick': '⚡ Highest Number Scaling: Take the largest number and check its multiples until all smaller numbers divide into it evenly. LCM is $finalLcm!',
      'pitfall': 'Remember: Product = LCM × HCF is ONLY valid for two numbers, not directly for three numbers without mutual pairwise terms.',
      'answer': '$finalLcm',
    };
  }

  /// 8. HCF of 2 or 3 numbers
  static Map<String, dynamic> _solveHcf(int a, int b, [int? c]) {
    int gcd(int x, int y) => y == 0 ? x : gcd(y, x % y);

    final hcfAB = gcd(a, b);
    final finalHcf = c != null ? gcd(hcfAB, c) : hcfAB;
    final diff = (a - b).abs();
    final numbersList = c != null ? '$a, $b, $c' : '$a, $b';

    return {
      'topic': 'Highest Common Factor (महत्तम समापवर्तक - HCF/GCD)',
      'category': 'Number System',
      'formula': 'HCF is always a factor of the difference between any two numbers!',
      'steps': [
        'Find HCF of ($numbersList).',
        'Difference method: Difference between $a and $b = |$a − $b| = $diff.',
        'The HCF cannot exceed $diff; it must divide $diff, $a, and $b.',
        if (c != null) ...[
          'Pairwise GCD($a, $b) = $hcfAB.',
          'GCD($hcfAB, $c) = $finalHcf.',
        ] else ...[
          'Largest common divisor = $finalHcf.',
        ],
        'Final HCF = $finalHcf.',
      ],
      'speedTrick': '⚡ Difference Trick: The HCF of any numbers is ALWAYS either their difference or a factor of their difference! Here difference = $diff ➔ HCF = $finalHcf in 2 seconds!',
      'pitfall': 'Do not waste time doing long division when the difference between two numbers is small.',
      'answer': '$finalHcf',
    };
  }

  /// 9. Divisibility Rule Solver
  static Map<String, dynamic> _solveDivisibilityRule(int d, String query) {
    String rule = '';
    String trick = '';
    String example = '';

    switch (d) {
      case 2:
        rule = 'Last digit must be even (0, 2, 4, 6, 8).';
        trick = '⚡ Check only the units digit.';
        example = '348 ends in 8 ➔ Divisible by 2.';
        break;
      case 3:
        rule = 'Sum of all digits must be divisible by 3.';
        trick = '⚡ Digit cancellation: Strike out 3, 6, 9 and pairs adding to 3 or 6 without adding up the whole number!';
        example = '741: 7+4+1 = 12 (divisible by 3) ➔ Divisible by 3.';
        break;
      case 4:
        rule = 'Last two digits formed as a number must be divisible by 4.';
        trick = '⚡ Double the tens digit and add the units digit: (2 × Tens + Units) divisible by 4.';
        example = '584: Last 2 digits are 84 (84 ÷ 4 = 21) ➔ Divisible by 4.';
        break;
      case 5:
        rule = 'Last digit must be 0 or 5.';
        trick = '⚡ Look strictly at the unit digit.';
        example = '935 ends in 5 ➔ Divisible by 5.';
        break;
      case 6:
        rule = 'Must be simultaneously divisible by both 2 (even) and 3 (sum of digits divisible by 3).';
        trick = '⚡ First check evenness, then strike multiples of 3.';
        example = '438 is even and 4+3+8=15 (÷3) ➔ Divisible by 6.';
        break;
      case 7:
        rule = 'Double the last digit and subtract it from the remaining truncated number. Result must be 0 or multiple of 7.';
        trick = '⚡ 3-Digit Block Oscillation: Split large number into 3-digit blocks from right: (Block 1 − Block 2 + Block 3) must be divisible by 7, 11, or 13!';
        example = '343: 34 − (2 × 3) = 34 − 6 = 28 (÷7) ➔ Divisible by 7.';
        break;
      case 8:
        rule = 'Last three digits formed as a number must be divisible by 8.';
        trick = '⚡ Shortcut: If hundreds digit is EVEN, check only last 2 digits. If hundreds digit is ODD, add 4 to last 2 digits!';
        example = '3128: Hundreds digit is 1 (ODD) ➔ Check 28 + 4 = 32 (÷8 = 4) ➔ Divisible by 8 in 1 second!';
        break;
      case 9:
        rule = 'Sum of all digits (digital root) must be divisible by 9.';
        trick = '⚡ Casting Out Nines: Drop all 9s and pairs adding to 9 (e.g. 1+8, 2+7, 3+6, 4+5) instantly!';
        example = '6831: 6+3=9 (drop), 8+1=9 (drop), remainder 0 ➔ Divisible by 9.';
        break;
      case 11:
        rule = 'Difference between sum of digits at odd places and sum of digits at even places must be 0 or divisible by 11.';
        trick = '⚡ Alternating Sum: (+, −, +, −) from right to left. Result is remainder mod 11!';
        example = '1364: (4 + 3) − (6 + 1) = 7 − 7 = 0 ➔ Divisible by 11.';
        break;
      case 13:
        rule = 'Multiply last digit by 4 and ADD to remaining truncated number. Repeat if needed.';
        trick = '⚡ Osculator for 13 is +4: a + 4b. Or use the 3-digit alternating block method.';
        example = '169: 16 + (4 × 9) = 16 + 36 = 52 (52 ÷ 13 = 4) ➔ Divisible by 13.';
        break;
      default:
        rule = 'Check co-prime factors: For composite number $d = x × y where gcd(x, y) = 1, test divisibility by both x and y.';
        trick = '⚡ e.g. For 72, test 8 and 9. For 88, test 8 and 11. For 99, test 9 and 11.';
        example = 'For composite divisors in SSC CGL, factorize into co-primes!';
    }

    return {
      'topic': 'Divisibility Rule for $d (विभाज्यता नियम)',
      'category': 'Number System Fundamentals',
      'formula': rule,
      'steps': [
        'Divisibility Criterion for $d:',
        '• $rule',
        '• Practical Example: $example',
      ],
      'speedTrick': trick,
      'pitfall': 'In SSC exams, questions usually ask to find missing digit * in a number divisible by 72, 88, or 99. Always test co-primes (8 & 9, or 8 & 11).',
      'answer': 'Rule Explained for $d',
    };
  }

  /// 10. Mensuration: Rectangle
  static Map<String, dynamic>? _trySolveRectangle(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (numbers.length >= 2) {
      final l = numbers[0];
      final b = numbers[1];
      final area = l * b;
      final perimeter = 2 * (l + b);
      final diagonal = math.sqrt((l * l) + (b * b));

      final lStr = l % 1 == 0 ? l.toInt().toString() : l.toString();
      final bStr = b % 1 == 0 ? b.toInt().toString() : b.toString();
      final areaStr = area % 1 == 0 ? area.toInt().toString() : area.toStringAsFixed(2);
      final periStr = perimeter % 1 == 0 ? perimeter.toInt().toString() : perimeter.toStringAsFixed(2);
      final diagStr = diagonal % 1 == 0 ? diagonal.toInt().toString() : diagonal.toStringAsFixed(2);

      // Check if triplet
      String tripletText = '';
      if (diagonal % 1 == 0) {
        tripletText = '⚡ Golden Pythagorean Triplet ($lStr, $bStr, $diagStr) Detected! Diagonal is directly $diagStr without calculation.';
      } else {
        tripletText = '⚡ 5-Sec Trick: Perimeter = 2(Sum) = 2(${l + b}) = $periStr. Area = $lStr × $bStr = $areaStr.';
      }

      return {
        'topic': 'Rectangle 2D Mensuration (आयत क्षेत्रमिति)',
        'category': 'Geometry & Mensuration 2D',
        'formula': 'Area = l × b  |  Perimeter = 2(l + b)  |  Diagonal d = √(l² + b²)',
        'steps': [
          'Given Dimensions: Length (l) = $lStr, Breadth (b) = $bStr.',
          '1. Area = l × b = $lStr × $bStr = $areaStr sq units.',
          '2. Perimeter = 2(l + b) = 2($lStr + $bStr) = 2 × ${l + b} = $periStr units.',
          '3. Diagonal = √(l² + b²) = √($lStr² + $bStr²) = √(${l * l + b * b}) = $diagStr units.',
          'Pathway Formulas (Important for SSC):',
          '• Outer Path (रास्ता बाहर): Area = 2w(l + b + 2w)',
          '• Inner Path (रास्ता अंदर): Area = 2w(l + b − 2w)',
          '• Crossroads Path (क्रॉस सड़कें): Area = w(l + b − w)',
        ],
        'speedTrick': tripletText,
        'pitfall': 'In pathway questions, students often forget that outer path increases dimensions by 2w, not just w.',
        'answer': 'Area = $areaStr, Perimeter = $periStr, Diagonal = $diagStr',
      };
    }
    return null;
  }

  /// 11. Mensuration: Circle
  static Map<String, dynamic>? _trySolveCircle(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (numbers.isNotEmpty) {
      double r = numbers[0];
      if (lower.contains('diameter') || lower.contains('व्यास')) {
        r = r / 2.0;
      }

      final area = (22.0 / 7.0) * r * r;
      final circum = 2 * (22.0 / 7.0) * r;
      final rStr = r % 1 == 0 ? r.toInt().toString() : r.toString();
      final areaStr = area % 1 == 0 ? area.toInt().toString() : area.toStringAsFixed(2);
      final circumStr = circum % 1 == 0 ? circum.toInt().toString() : circum.toStringAsFixed(2);

      String trick = '';
      if (r % 7 == 0) {
        final scale = (r / 7.0).toInt();
        trick = '⚡ Standard Circle Benchmark (r = 7 ➔ C = 44, Area = 154): Here radius scale factor k = $scale. Circumference = 44 × $scale = $circumStr; Area = 154 × $scale² = $areaStr (Solved in 2 seconds)!';
      } else {
        trick = '⚡ Benchmark Ratio: Always relate to standard r=7 benchmark (C=44, A=154) to eliminate π calculations.';
      }

      return {
        'topic': 'Circle 2D Mensuration (वृत्त क्षेत्रमिति)',
        'category': 'Geometry & Mensuration 2D',
        'formula': 'Circumference = 2 π r  |  Area = π r²  |  Diameter = 2r',
        'steps': [
          'Given Radius (r) = $rStr.',
          '1. Circumference = 2 × (22/7) × $rStr = $circumStr units.',
          '2. Area = (22/7) × $rStr² = (22/7) × ${r * r} = $areaStr sq units.',
          '3. Semicircle: Perimeter = (36/7) r = ${(36.0 / 7.0 * r).toStringAsFixed(2)}; Area = ½ π r².',
        ],
        'speedTrick': trick,
        'pitfall': 'Perimeter of semicircle is (πr + 2r) = 36/7 r, NOT just πr!',
        'answer': 'Area = $areaStr, Circumference = $circumStr',
      };
    }
    return null;
  }

  /// 12. Mensuration: Triangle
  static Map<String, dynamic>? _trySolveTriangle(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (lower.contains('equilateral') || lower.contains('समबाहु')) {
      if (numbers.isNotEmpty) {
        final a = numbers[0];
        final area = (math.sqrt(3) / 4.0) * a * a;
        final height = (math.sqrt(3) / 2.0) * a;
        final inradius = a / (2 * math.sqrt(3));
        final circumradius = a / math.sqrt(3);

        return {
          'topic': 'Equilateral Triangle (समबाहु त्रिभुज)',
          'category': 'Geometry & Mensuration 2D',
          'formula': 'Area = (√3/4) a²  |  Height h = (√3/2) a  |  Inradius r = a/(2√3)  |  Circumradius R = a/√3',
          'steps': [
            'Given Side a = $a.',
            '1. Area = (√3 / 4) × $a² = ${(area).toStringAsFixed(2)} sq units (${(a * a / 4.0).toStringAsFixed(1)}√3).',
            '2. Height (Altitude) = (√3 / 2) × $a = ${(height).toStringAsFixed(2)} units.',
            '3. Inradius r = a / 2√3 = ${(inradius).toStringAsFixed(2)}.',
            '4. Circumradius R = a / √3 = ${(circumradius).toStringAsFixed(2)} (Note: R : r = 2 : 1).',
          ],
          'speedTrick': '⚡ Standard Benchmark (side a = 2): Area = √3, Height = √3, Inradius = 1/√3, Circumradius = 2/√3. Scale proportionally!',
          'pitfall': 'In equilateral triangle, circumradius R is always exactly TWICE the inradius r (R = 2r).',
          'answer': 'Area = ${(area).toStringAsFixed(2)}, Height = ${(height).toStringAsFixed(2)}',
        };
      }
    }

    if (numbers.length >= 2) {
      final b = numbers[0];
      final h = numbers[1];
      final area = 0.5 * b * h;
      return {
        'topic': 'Triangle Mensuration (त्रिभुज क्षेत्रफल)',
        'category': 'Geometry & Mensuration 2D',
        'formula': 'Area = ½ × Base × Height  |  Heron\'s: √[s(s−a)(s−b)(s−c)]',
        'steps': [
          'Given Base = $b, Height = $h.',
          'Area = ½ × $b × $h = $area sq units.',
        ],
        'speedTrick': '⚡ Half the even number first: ½ × $b × $h = ${(0.5 * b)} × $h = $area in 1 second!',
        'pitfall': 'Ensure height is strictly perpendicular to base, not the slanted leg.',
        'answer': 'Area = $area',
      };
    }
    return null;
  }

  /// 13. Mensuration: Cylinder
  static Map<String, dynamic>? _trySolveCylinder(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (numbers.length >= 2) {
      final r = numbers[0];
      final h = numbers[1];
      final vol = (22.0 / 7.0) * r * r * h;
      final csa = 2 * (22.0 / 7.0) * r * h;
      final tsa = 2 * (22.0 / 7.0) * r * (r + h);

      return {
        'topic': 'Right Circular Cylinder 3D Mensuration (बेलन)',
        'category': 'Geometry & Mensuration 3D',
        'formula': 'Volume = π r² h  |  CSA = 2 π r h  |  TSA = 2 π r (r + h)',
        'steps': [
          'Given: Radius (r) = $r, Height (h) = $h.',
          '1. Curved Surface Area (CSA) = 2 × (22/7) × $r × $h = ${csa.toStringAsFixed(2)}.',
          '2. Total Surface Area (TSA) = 2 × (22/7) × $r × ($r + $h) = ${tsa.toStringAsFixed(2)}.',
          '3. Volume = (22/7) × $r² × $h = ${vol.toStringAsFixed(2)} cubic units.',
        ],
        'speedTrick': '⚡ 11 Divisibility Check: In SSC MCQs, π involves 22/7 (multiple of 11). Test option divisibility by 11 to solve in 3 seconds!',
        'pitfall': 'Do not confuse CSA (lateral wall) with TSA (includes 2 circular caps 2πr²).',
        'answer': 'Vol = ${vol.toStringAsFixed(1)}, CSA = ${csa.toStringAsFixed(1)}, TSA = ${tsa.toStringAsFixed(1)}',
      };
    }
    return null;
  }

  /// 14. Mensuration: Cone
  static Map<String, dynamic>? _trySolveCone(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (numbers.length >= 2) {
      final r = numbers[0];
      final h = numbers[1];
      final l = math.sqrt((r * r) + (h * h));
      final csa = (22.0 / 7.0) * r * l;
      final tsa = (22.0 / 7.0) * r * (r + l);
      final vol = (1.0 / 3.0) * (22.0 / 7.0) * r * r * h;

      return {
        'topic': 'Right Circular Cone 3D Mensuration (शंकु)',
        'category': 'Geometry & Mensuration 3D',
        'formula': 'Slant Height l = √(r² + h²)  |  CSA = π r l  |  TSA = π r (r + l)  |  Vol = ⅓ π r² h',
        'steps': [
          'Given: Radius (r) = $r, Height (h) = $h.',
          '1. Slant Height (l) = √($r² + $h²) = √(${r * r + h * h}) = ${l.toStringAsFixed(2)}.',
          '2. Curved Surface Area (CSA) = (22/7) × $r × ${l.toStringAsFixed(2)} = ${csa.toStringAsFixed(2)}.',
          '3. Total Surface Area (TSA) = π r (r + l) = ${tsa.toStringAsFixed(2)}.',
          '4. Volume = ⅓ π r² h = ${vol.toStringAsFixed(2)} cubic units.',
        ],
        'speedTrick': '⚡ Triplet Check: Notice if (r, h, l) forms a Pythagorean triplet (e.g. 7, 24, 25 or 3, 4, 5). If so, l is instant!',
        'pitfall': 'For CSA, always use slant height l, NEVER vertical height h.',
        'answer': 'l = ${l.toStringAsFixed(1)}, CSA = ${csa.toStringAsFixed(1)}, Vol = ${vol.toStringAsFixed(1)}',
      };
    }
    return null;
  }

  /// 15. Mensuration: Sphere
  static Map<String, dynamic>? _trySolveSphere(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (numbers.isNotEmpty) {
      final r = numbers[0];
      final isHemi = lower.contains('hemi') || lower.contains('अर्ध');

      if (isHemi) {
        final vol = (2.0 / 3.0) * (22.0 / 7.0) * r * r * r;
        final csa = 2 * (22.0 / 7.0) * r * r;
        final tsa = 3 * (22.0 / 7.0) * r * r;
        return {
          'topic': 'Hemisphere 3D Mensuration (अर्धगोला)',
          'category': 'Geometry & Mensuration 3D',
          'formula': 'Volume = ⅔ π r³  |  CSA = 2 π r²  |  TSA = 3 π r²',
          'steps': [
            'Given Radius r = $r.',
            '1. Curved Surface Area (CSA) = 2 π r² = ${csa.toStringAsFixed(2)}.',
            '2. Total Surface Area (TSA) = 3 π r² = ${tsa.toStringAsFixed(2)} (includes circular flat top).',
            '3. Volume = ⅔ π r³ = ${vol.toStringAsFixed(2)} cubic units.',
          ],
          'speedTrick': '⚡ TSA of hemisphere is 3πr², NOT 2πr² (it has a flat base of area πr²)!',
          'pitfall': 'Hollow hemisphere inner vs outer TSA has different rules.',
          'answer': 'TSA = ${tsa.toStringAsFixed(1)}, Vol = ${vol.toStringAsFixed(1)}',
        };
      } else {
        final vol = (4.0 / 3.0) * (22.0 / 7.0) * r * r * r;
        final sa = 4 * (22.0 / 7.0) * r * r;
        return {
          'topic': 'Sphere 3D Mensuration (गोला)',
          'category': 'Geometry & Mensuration 3D',
          'formula': 'Surface Area = 4 π r²  |  Volume = 4/3 π r³',
          'steps': [
            'Given Radius r = $r.',
            '1. Surface Area = 4 × (22/7) × $r² = ${sa.toStringAsFixed(2)} sq units.',
            '2. Volume = (4/3) × (22/7) × $r³ = ${vol.toStringAsFixed(2)} cubic units.',
          ],
          'speedTrick': '⚡ When radius is scaled by k, Area scales by k², Volume scales by k³!',
          'pitfall': 'Sphere has only one surface area: CSA and TSA are identical (4πr²).',
          'answer': 'Surface Area = ${sa.toStringAsFixed(1)}, Volume = ${vol.toStringAsFixed(1)}',
        };
      }
    }
    return null;
  }

  /// 16. Mensuration: Rhombus
  static Map<String, dynamic>? _trySolveRhombus(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (numbers.length >= 2) {
      final d1 = numbers[0];
      final d2 = numbers[1];
      final area = 0.5 * d1 * d2;
      final side = math.sqrt((d1 / 2.0) * (d1 / 2.0) + (d2 / 2.0) * (d2 / 2.0));
      final perimeter = 4 * side;

      return {
        'topic': 'Rhombus Diagonals & Perimeter (समचतुर्भुज)',
        'category': 'Geometry & Mensuration 2D',
        'formula': 'Area = ½ × d₁ × d₂  |  Side s = √[(d₁/2)² + (d₂/2)²]  |  Perimeter = 4s',
        'steps': [
          'Given Diagonals: d₁ = $d1, d₂ = $d2.',
          '1. Area = ½ × $d1 × $d2 = $area sq units.',
          '2. Half Diagonals: d₁/2 = ${d1 / 2}, d₂/2 = ${d2 / 2}.',
          '3. Diagonals bisect at 90°: Side s = √[(${d1 / 2})² + (${d2 / 2})²] = ${side.toStringAsFixed(2)}.',
          '4. Perimeter = 4 × s = ${perimeter.toStringAsFixed(2)} units.',
        ],
        'speedTrick': '⚡ Triplet on Half-Diagonals: Half the diagonals (${d1 / 2}, ${d2 / 2}) directly form the two legs of a right triangle! The hypotenuse is the side.',
        'pitfall': 'Do not square full diagonals without dividing by 2 first.',
        'answer': 'Area = $area, Side = ${side.toStringAsFixed(1)}, Perimeter = ${perimeter.toStringAsFixed(1)}',
      };
    }
    return null;
  }

  /// 17. Mensuration: Square Shape
  static Map<String, dynamic>? _trySolveSquareShape(String query, String lower) {
    final numbers = _extractNumbers(query);
    if (numbers.isNotEmpty) {
      final a = numbers[0];
      final area = a * a;
      final peri = 4 * a;
      final diag = a * math.sqrt(2);

      return {
        'topic': 'Square 2D Mensuration (वर्ग क्षेत्रमिति)',
        'category': 'Geometry & Mensuration 2D',
        'formula': 'Area = a² = d² / 2  |  Perimeter = 4a  |  Diagonal d = a√2',
        'steps': [
          'Given Side a = $a.',
          '1. Area = $a² = $area sq units.',
          '2. Perimeter = 4 × $a = $peri units.',
          '3. Diagonal = $a × √2 = ${diag.toStringAsFixed(2)} units.',
        ],
        'speedTrick': '⚡ If diagonal d is given, Area is simply d² / 2 without finding side!',
        'pitfall': 'Remember that diagonal of square is a√2, whereas diagonal of cube is a√3.',
        'answer': 'Area = $area, Perimeter = $peri, Diagonal = ${diag.toStringAsFixed(2)}',
      };
    }
    return null;
  }

  /// 18. Trigonometry Values
  static Map<String, dynamic>? _trySolveTrigValues(String lower) {
    final Map<String, String> standardValues = {
      'sin 0': '0',
      'sin 30': '1/2 (0.5)',
      'sin 45': '1/√2 (0.707)',
      'sin 60': '√3/2 (0.866)',
      'sin 90': '1',
      'cos 0': '1',
      'cos 30': '√3/2 (0.866)',
      'cos 45': '1/√2 (0.707)',
      'cos 60': '1/2 (0.5)',
      'cos 90': '0',
      'tan 0': '0',
      'tan 30': '1/√3 (0.577)',
      'tan 45': '1',
      'tan 60': '√3 (1.732)',
      'tan 90': 'Undefined (∞)',
      'cot 45': '1',
      'cot 30': '√3',
      'cot 60': '1/√3',
      'sec 0': '1',
      'sec 60': '2',
      'sec 45': '√2',
      'sec 30': '2/√3',
      'cosec 30': '2',
      'cosec 45': '√2',
      'cosec 60': '2/√3',
      'cosec 90': '1',
    };

    for (final entry in standardValues.entries) {
      if (lower.contains(entry.key)) {
        return {
          'topic': 'Trigonometric Table Value: ${entry.key.toUpperCase()} (त्रिकोणमिति मान)',
          'category': 'Trigonometry Foundations',
          'formula': '${entry.key} = ${entry.value}  |  sin θ / cos θ = tan θ',
          'steps': [
            'Standard Trigonometric Table Entry:',
            'Angle: ${entry.key}.',
            'Exact Value = ${entry.value}.',
            'Reciprocal check: sin = 1/cosec, cos = 1/sec, tan = 1/cot.',
          ],
          'speedTrick': '⚡ Finger Trick / 0-1-2-3-4 Rule: √(0/4), √(1/4), √(2/4), √(3/4), √(4/4) directly gives sin 0°, 30°, 45°, 60°, 90°!',
          'pitfall': 'Notice complementary pairs: sin 30° = cos 60°, tan 30° = cot 60°.',
          'answer': entry.value,
        };
      }
    }
    return null;
  }

  /// 19. Arithmetic Multiplication
  static Map<String, dynamic> _solveMultiplication(double a, double b) {
    final ans = a * b;
    final aStr = a % 1 == 0 ? a.toInt().toString() : a.toString();
    final bStr = b % 1 == 0 ? b.toInt().toString() : b.toString();
    final ansStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toStringAsFixed(2);

    String trick = '';
    if (b == 11 || a == 11) {
      final other = b == 11 ? a.toInt() : b.toInt();
      trick = '⚡ Multiplied by 11 (Sandwich Trick): Insert the sum of adjacent digits between the outer digits! $other × 11 = $ansStr in 1 second flat!';
    } else if (b == 5 || a == 5) {
      final other = b == 5 ? a : b;
      trick = '⚡ Multiplied by 5: Halve the number and append 0 (or multiply by 10): ($other ÷ 2) × 10 = $ansStr!';
    } else if (b == 25 || a == 25) {
      final other = b == 25 ? a : b;
      trick = '⚡ Multiplied by 25: Divide by 4 and multiply by 100: ($other ÷ 4) × 100 = $ansStr!';
    } else if (b == 99 || a == 99) {
      final other = b == 99 ? a.toInt() : b.toInt();
      trick = '⚡ Multiplied by 99: Multiply by 100 and subtract original number: ($other × 100) − $other = $ansStr!';
    } else {
      trick = '⚡ Urdhva Tiryagbhyam (Vertical & Crosswise): Multiply units, cross-multiply diagonals and sum, multiply tens. Fast mental cross-multiplication eliminates paper scratching!';
    }

    return {
      'topic': 'Vedic Mental Multiplication (वैदिक गुणनफल)',
      'category': 'Speed Calculation',
      'formula': 'a × b  |  Urdhva Tiryagbhyam (ऊर्ध्वतिर्यग्भ्याम्)',
      'steps': [
        'Given Expression: $aStr × $bStr = ?',
        'Breakdown: $aStr × $bStr = $ansStr.',
        trick,
        'Final Product = $ansStr.',
      ],
      'speedTrick': trick,
      'pitfall': 'Never write vertical columns for 2-digit numbers in SSC Tier-I. Use cross-multiplication or distributive splitting.',
      'answer': ansStr,
    };
  }

  /// 20. Arithmetic Division
  static Map<String, dynamic> _solveDivision(double a, double b) {
    if (b == 0) {
      return {
        'topic': 'Division by Zero (शून्य से भाग)',
        'category': 'Mathematical Laws',
        'formula': 'a / 0 is Undefined',
        'steps': ['Division by zero is undefined in mathematics.'],
        'speedTrick': 'Division by 0 does not yield a finite number.',
        'answer': 'Undefined',
      };
    }

    final ans = a / b;
    final aStr = a % 1 == 0 ? a.toInt().toString() : a.toString();
    final bStr = b % 1 == 0 ? b.toInt().toString() : b.toString();
    final ansStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toStringAsFixed(3);

    String trick = '';
    if (b == 5) {
      trick = '⚡ Divided by 5: Double the number $aStr (➔ ${a * 2}) and divide by 10 (shift decimal 1 place left) ➔ $ansStr!';
    } else if (b == 25) {
      trick = '⚡ Divided by 25: Multiply $aStr by 4 (➔ ${a * 4}) and shift decimal 2 places left ➔ $ansStr!';
    } else {
      trick = '⚡ Factor Simplification: Cancel common factors before dividing to minimize calculation load.';
    }

    return {
      'topic': 'Rapid Mental Division (तीव्र भाग विधि)',
      'category': 'Speed Calculation',
      'formula': 'Dividend = Divisor × Quotient + Remainder',
      'steps': [
        'Given Problem: $aStr ÷ $bStr = ?',
        'Calculate: $aStr / $bStr = $ansStr.',
        trick,
        'Final Quotient = $ansStr.',
      ],
      'speedTrick': trick,
      'pitfall': 'Don\'t perform long division for divisors like 5, 25, 50. Multiply numerator instead and shift decimals!',
      'answer': ansStr,
    };
  }

  /// 21. Arithmetic Subtraction
  static Map<String, dynamic> _solveSubtraction(double a, double b) {
    final ans = a - b;
    final aStr = a % 1 == 0 ? a.toInt().toString() : a.toString();
    final bStr = b % 1 == 0 ? b.toInt().toString() : b.toString();
    final ansStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toStringAsFixed(2);

    String trick = '';
    if (a == 100 || a == 1000 || a == 10000) {
      trick = '⚡ All From 9 and Last From 10 (Nikhilam Rule): Subtract each digit from 9, and the last non-zero digit from 10. Direct subtraction from base 10!';
    } else {
      final bInt = b.toInt();
      final roundB = ((bInt ~/ 10) + 1) * 10;
      final diff = roundB - bInt;
      trick = '⚡ Round & Compensate: $aStr − $bStr = ($aStr − $roundB) + $diff = $ansStr. Takes 1.5 seconds in head!';
    }

    return {
      'topic': 'Vedic Mental Subtraction (वैदिक घटाव)',
      'category': 'Speed Calculation',
      'formula': 'a − b = (a − Round_B) + Compensation',
      'steps': [
        'Given Problem: $aStr − $bStr = ?',
        'Direct Difference: $aStr − $bStr = $ansStr.',
        trick,
        'Final Answer = $ansStr.',
      ],
      'speedTrick': trick,
      'pitfall': 'Never carry-over backward on paper. Subtract round tens forward to eliminate cognitive friction!',
      'answer': ansStr,
    };
  }

  /// 22. Arithmetic Addition
  static Map<String, dynamic> _solveAddition(double a, double b) {
    final ans = a + b;
    final aStr = a % 1 == 0 ? a.toInt().toString() : a.toString();
    final bStr = b % 1 == 0 ? b.toInt().toString() : b.toString();
    final ansStr = ans % 1 == 0 ? ans.toInt().toString() : ans.toStringAsFixed(2);

    return {
      'topic': 'Left-to-Right Mental Addition (बाएँ से दाएँ जोड़)',
      'category': 'Speed Calculation',
      'formula': '(Tens₁ + Tens₂) + (Units₁ + Units₂) = Sum',
      'steps': [
        'Given Problem: $aStr + $bStr = ?',
        'Add largest place values first from left to right.',
        'Result: $aStr + $bStr = $ansStr.',
      ],
      'speedTrick': '⚡ Highest Place First: Adding hundreds, then tens, then units eliminates carrying memory overhead!',
      'pitfall': 'Traditional right-to-left paper addition creates mental carry-over bottlenecks.',
      'answer': ansStr,
    };
  }

  /// 23. Search Concept Formula Repository (300+ formulas)
  static Map<String, dynamic>? _trySearchConceptRepository(String query, String lower) {
    // 1. Try exact concept search
    final matches = ConceptFormulaRepository.search(query);
    if (matches.isNotEmpty) {
      final concept = matches.first;
      final trap = ConceptExaminerTrapRepository.getTrapForConcept(concept);
      final rhyme = trap.desiJugaad;

      List<String> steps = [
        '📖 Core Principle: ${concept.explanation.split('\n').first}',
        for (final cond in concept.keyConditions.take(4)) '• $cond',
      ];

      if (concept.solvedExamples.isNotEmpty) {
        final ex = concept.solvedExamples.first;
        steps.add('📝 Exam Example: ${ex.problem.split('\n').first}');
        for (final s in ex.steps.take(3)) {
          steps.add('   $s');
        }
        steps.add('   Ans: ${ex.answer}');
      }

      String trick = '';
      if (concept.solvedExamples.isNotEmpty && concept.solvedExamples.first.shortcutTip.isNotEmpty) {
        trick = '⚡ Topper Trick: ${concept.solvedExamples.first.shortcutTip}';
      } else if (rhyme.isNotEmpty) {
        trick = rhyme;
      } else {
        trick = '⚡ Speed Revision: Memorize key conditions and check options with unit digits / triplet scaling.';
      }

      final String pitfall = trap.trap.isNotEmpty ? trap.trap : 'Do not skip boundary conditions in Tier-II questions.';

      return {
        'topic': concept.title,
        'category': concept.pillar.displayName,
        'formula': concept.formula,
        'steps': steps,
        'speedTrick': trick,
        'pitfall': pitfall,
        'answer': concept.solvedExamples.isNotEmpty ? concept.solvedExamples.first.answer : 'Concept Verified',
      };
    }

    // 2. Keyword fallback matching
    final keywords = ['intercept', 'inradius', 'circumradius', 'centroid', 'orthocenter', 'heron', 'triplet', 'ptolemy', 'stewart', 'tangent', 'secant', 'cyclic'];
    for (final kw in keywords) {
      if (lower.contains(kw)) {
        final kwMatches = ConceptFormulaRepository.search(kw);
        if (kwMatches.isNotEmpty) {
          final concept = kwMatches.first;
          return {
            'topic': concept.title,
            'category': concept.pillar.displayName,
            'formula': concept.formula,
            'steps': [
              'Underlying Exam Rule:',
              concept.explanation.split('\n').first,
              for (final c in concept.keyConditions.take(3)) '• $c',
            ],
            'speedTrick': concept.solvedExamples.isNotEmpty ? '⚡ ${concept.solvedExamples.first.shortcutTip}' : '⚡ Rapid application via formula anchor.',
            'pitfall': 'Check problem constraints carefully before applying shortcuts.',
            'answer': concept.solvedExamples.isNotEmpty ? concept.solvedExamples.first.answer : 'Verified',
          };
        }
      }
    }

    return null;
  }

  /// 24. Vocabulary & English Search
  static Map<String, dynamic>? _trySearchVocabulary(String lower) {
    if (lower.contains('discreet') || lower.contains('discrete')) {
      return {
        'topic': 'Blackbook Homophones: Discreet vs Discrete (शब्द-भेद)',
        'category': 'English Vocabulary (Blackbook)',
        'formula': 'Discreet (ee = keep secret / cautious) vs Discrete (t separates e = separate / distinct)',
        'steps': [
          '1. DISCREET (Adjective): Careful, prudent, secretive in speech or action.',
          '   Hindi: विचारशील, सावधान, गुप्त रखने वाला।',
          '   Example: "She made discreet inquiries about his job offer."',
          '2. DISCRETE (Adjective): Individually separate, distinct, disconnected.',
          '   Hindi: अलग, भिन्न, पृथक।',
          '   Example: "Speech sounds are produced as a continuous signal rather than discrete units."',
        ],
        'speedTrick': '⚡ Memory Hook: In "discrEEt", the two "e"s are hiding together inside = secretive! In "discrE-T-E", the "T" separates the two "e"s = separate/distinct!',
        'pitfall': 'SSC frequently tests this pair in Error Spotting and Cloze Test sentences.',
        'answer': 'Discreet = Prudent / Secretive; Discrete = Distinct / Separate',
      };
    }

    // 1. Homonyms check
    for (final h in BlackbookVocabularyBank.topHomonyms) {
      if (lower.contains(h.word1.toLowerCase()) || lower.contains(h.word2.toLowerCase())) {
        return {
          'topic': 'Blackbook Homophones: ${h.word1} vs ${h.word2} (शब्द-भेद)',
          'category': 'English Vocabulary (Blackbook)',
          'formula': '${h.word1} (${h.meaning1})  vs  ${h.word2} (${h.meaning2})',
          'steps': [
            '1. ${h.word1.toUpperCase()} (${h.pos1}): ${h.meaning1}',
            '   Hindi: ${h.hindi1}',
            '2. ${h.word2.toUpperCase()} (${h.pos2}): ${h.meaning2}',
            '   Hindi: ${h.hindi2}',
          ],
          'speedTrick': '⚡ Memory Anchor: Differentiate ${h.word1} and ${h.word2} by spelling and context.',
          'pitfall': 'SSC frequently tests this pair in Error Detection, Fill in the Blanks, and Cloze Tests.',
          'answer': '${h.word1} = ${h.hindi1}; ${h.word2} = ${h.hindi2}',
        };
      }
    }

    // 2. OWS check
    for (final ows in BlackbookVocabularyBank.topOws) {
      if (lower.contains(ows.word.toLowerCase())) {
        return {
          'topic': 'One Word Substitution: ${ows.word} (एक शब्द)',
          'category': 'English Vocabulary (Blackbook)',
          'formula': '${ows.word}: ${ows.phrase}',
          'steps': [
            'Word: ${ows.word} (${ows.partOfSpeech})',
            'Phrase / Definition: ${ows.phrase}',
            'Hindi Meaning: ${ows.hindiMeaning}',
            'Exam Frequency: Asked ${ows.repetitionCount} times in SSC CGL / CHSL / CPO.',
          ],
          'speedTrick': '⚡ High-Yield Blackbook Word: Memorize root word for instant recognition in exam!',
          'pitfall': 'Look for subtle differences in options (e.g. egoist vs egotist, altruist vs philanthropist).',
          'answer': '${ows.word} = ${ows.hindiMeaning}',
        };
      }
    }

    // 3. Idiom check
    for (final idm in BlackbookVocabularyBank.topIdioms) {
      if (lower.contains(idm.idiom.toLowerCase())) {
        return {
          'topic': 'Blackbook Idiom: ${idm.idiom} (मुहावरे)',
          'category': 'English Idioms & Phrases',
          'formula': '${idm.idiom} = ${idm.englishMeaning}',
          'steps': [
            'Idiom: "${idm.idiom}"',
            'English Meaning: ${idm.englishMeaning}',
            'Hindi Meaning: ${idm.hindiMeaning}',
            if (idm.example.isNotEmpty) 'Example Sentence: "${idm.example}"',
            'Exam Repetition: Asked ${idm.repetitionCount} times in SSC exams.',
          ],
          'speedTrick': '⚡ Visual Hook: Connect idiom to literal imagery to never forget the figurative meaning.',
          'pitfall': 'Idioms must be taken figuratively, never literally in comprehension tests.',
          'answer': idm.hindiMeaning,
        };
      }
    }

    return null;
  }

  /// 25. General / Free-Form Doubt Solver
  static Map<String, dynamic> _solveGeneralNaturalQuery(String query) {
    final numbers = _extractNumbers(query);

    return {
      'topic': 'AI Doubt Breakdown: Concept & Solution',
      'category': 'Comprehensive Exam Solution',
      'formula': 'Identify Given Parameters ➔ Map Core SSC Formula ➔ Apply 5-Second Speed Trick',
      'steps': [
        'User Question: $query',
        if (numbers.isNotEmpty)
          'Extracted Quantities from query: ${numbers.map((n) => n % 1 == 0 ? n.toInt() : n).join(', ')}.',
        'Step 1: Identify the underlying mathematical category (Arithmetic, Algebra, Geometry, or Vocab).',
        'Step 2: Relate to foundational concept or identity.',
        'Step 3: Solve systematically and eliminate unreasonable options using unit digits or parity.',
      ],
      'speedTrick': '⚡ Exam Tip: Substitute extreme or friendly values (0, 1, 45°) to test options directly in under 10 seconds!',
      'pitfall': 'Avoid lengthy descriptive steps during speed drills. Focus on direct formula anchors.',
      'answer': numbers.isNotEmpty ? 'Evaluated with ${numbers.length} parameter(s)' : 'Concept Explained',
    };
  }

  static Map<String, dynamic> _buildEmptyResponse() {
    return {
      'topic': 'Empty Query',
      'category': 'AI Tutor',
      'formula': 'Please enter a valid question or math expression.',
      'steps': ['Type any question or tap a sample chip above.'],
      'speedTrick': 'Enter any math expression like 65 - 29 or 16.66% of 720!',
      'answer': 'Ready',
    };
  }

  static List<double> _extractNumbers(String text) {
    final matches = RegExp(r'\b\d+(?:\.\d+)?\b').allMatches(text);
    return matches.map((m) => double.tryParse(m.group(0)!) ?? 0.0).toList();
  }
}
