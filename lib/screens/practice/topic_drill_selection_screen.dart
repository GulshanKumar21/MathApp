import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../data/dynamic_question_engine.dart';
import '../../data/lcm_hcf_concept_data.dart';
import '../../data/divisibility_rules_concept_data.dart';
import '../../data/number_system_concept_data.dart';
import '../../data/square_root_surds_concept_data.dart';
import '../../data/trigonometry_solutions_data.dart';
import '../practice/practice_quiz_screen.dart';

/// 🎯 Dedicated Topic Drill Selection & Practice Hub:
/// Opens before starting practice for:
/// - Fractions & %
/// - LCM & HCF
/// - Divisibility Rules
/// - Number System
/// - Pythagorean Triples
/// - Square Root & Surds
/// - Trigonometry
/// Allows students to choose:
/// 1. Specific sub-topic / difficulty category (Foundation, Advanced, Exam Special, Mixed Sprint)
/// 2. Questions count (10, 20, 30 questions)
/// 3. Speed Timer Mode (Easy No Timer, Medium 10s/Q, Hard 5s/Q)
class TopicDrillSelectionScreen extends StatefulWidget {
  final TopicType type;

  const TopicDrillSelectionScreen({
    super.key,
    required this.type,
  });

  @override
  State<TopicDrillSelectionScreen> createState() => _TopicDrillSelectionScreenState();
}

class _TopicDrillSelectionScreenState extends State<TopicDrillSelectionScreen> {
  int _questionCount = 10;
  QuizTimerDifficulty _timerDifficulty = QuizTimerDifficulty.medium;

  // -------------------------------------------------------------
  // TOPIC BRANDING & METADATA
  // -------------------------------------------------------------
  String get _topicTitle {
    switch (widget.type) {
      case TopicType.fractions:
        return 'Fractions & % Drills';
      case TopicType.lcmHcf:
        return 'LCM & HCF Master Drills';
      case TopicType.divisibility:
        return 'Divisibility Rules Drills';
      case TopicType.numberSystem:
        return 'Number System Drills';
      case TopicType.triples:
        return 'Pythagorean Triples Drills';
      case TopicType.squareRootSurds:
        return 'Square Root & Surds Drills';
      case TopicType.trigonometry:
        return 'Trigonometry Drills';
      default:
        return 'Speed Practice Drills';
    }
  }

  String get _topicSubtitle {
    switch (widget.type) {
      case TopicType.fractions:
        return '1/2 to 1/25 Percentage Values, Decimals & High-Speed Multipliers';
      case TopicType.lcmHcf:
        return 'Prime Factors, Fractions, Co-prime & 4 Remainder Patterns';
      case TopicType.divisibility:
        return '2–16, 72, 88, 144 & Remainder Shortcuts for SSC & Railway';
      case TopicType.numberSystem:
        return 'Unit Digits, Series Summation Σn, Cyclicity & Trailing Zeroes';
      case TopicType.triples:
        return 'Base Triples (3-4-5, 5-12-13...) & Scaled Hypotenuse Speed Drills';
      case TopicType.squareRootSurds:
        return 'Infinite Radicals, Unit Digit Extraction & Conjugate Surds';
      case TopicType.trigonometry:
        return 'Standard Angles, Complementary Pairs & Pythagorean Identities';
      default:
        return 'Targeted speed calculation practice for competitive exams';
    }
  }

  String get _symbol {
    switch (widget.type) {
      case TopicType.fractions:
        return '%';
      case TopicType.lcmHcf:
        return 'HCF';
      case TopicType.divisibility:
        return '÷';
      case TopicType.numberSystem:
        return 'Σn';
      case TopicType.triples:
        return 'Δ';
      case TopicType.squareRootSurds:
        return '√x';
      case TopicType.trigonometry:
        return 'sin';
      default:
        return '⚡';
    }
  }

  Color get _themeColor {
    switch (widget.type) {
      case TopicType.fractions:
        return const Color(0xFF34D399); // Mint Emerald
      case TopicType.lcmHcf:
        return const Color(0xFF06B6D4); // Cyan Accent
      case TopicType.divisibility:
        return const Color(0xFFEAB308); // Amber Gold
      case TopicType.numberSystem:
        return const Color(0xFF10B981); // Emerald Green
      case TopicType.triples:
        return const Color(0xFFA78BFA); // Soft Purple
      case TopicType.squareRootSurds:
        return const Color(0xFFF97316); // Vibrant Orange
      case TopicType.trigonometry:
        return const Color(0xFFEC4899); // Pink Violet
      default:
        return AppTheme.accent;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case TopicType.fractions:
        return Icons.percent_rounded;
      case TopicType.lcmHcf:
        return Icons.hub_rounded;
      case TopicType.divisibility:
        return Icons.fact_check_rounded;
      case TopicType.numberSystem:
        return Icons.tag_rounded;
      case TopicType.triples:
        return Icons.change_history_rounded;
      case TopicType.squareRootSurds:
        return Icons.functions_rounded;
      case TopicType.trigonometry:
        return Icons.architecture_rounded;
      default:
        return Icons.calculate_rounded;
    }
  }

  // -------------------------------------------------------------
  // 4 CATEGORIES FOR EACH TOPIC
  // -------------------------------------------------------------
  List<Map<String, String>> get _categories {
    switch (widget.type) {
      case TopicType.fractions:
        return [
          {
            'level': 'LEVEL 1 • FOUNDATION',
            'title': 'Core Standard Fractions (1/2 to 1/10)',
            'desc': 'Fundamental benchmark percentages tested in every paper.',
            'formula': '1/2 = 50%  •  1/4 = 25%  •  1/6 = 16.67%  •  1/8 = 12.5%',
            'trick': '⚡ Halve & Quarter: 1/8 is half of 1/4 (12.5%). 1/6 is half of 1/3 (16.67%).',
          },
          {
            'level': 'LEVEL 2 • ADVANCED',
            'title': 'Advanced Fractions (1/11 to 1/25)',
            'desc': 'Crucial high-scoring fractions for compound interest and profit/loss.',
            'formula': '1/11 = 9.09%  •  1/12 = 8.33%  •  1/14 = 7.14%  •  1/16 = 6.25%',
            'trick': '⚡ Reciprocal Pairing: 1/9 = 11.11% and 1/11 = 9.09% flip numbers symmetrically!',
          },
          {
            'level': 'LEVEL 3 • MULTIPLES',
            'title': 'Fractional Multiples & Decimals',
            'desc': 'Multiples like 3/8, 5/8, 7/8, 2/3, 4/7 and 5/6.',
            'formula': '3/8 = 37.5%  •  5/8 = 62.5%  •  7/8 = 87.5%  •  5/6 = 83.33%',
            'trick': '⚡ Base Multiplier: 3/8 = 3 × 12.5% = 37.5%. 5/8 = 5 × 12.5% = 62.5%.',
          },
          {
            'level': 'LEVEL 4 • FULL SPRINT',
            'title': 'All-in-One Full Mixed Speed Drill',
            'desc': 'Rapid-fire randomized mix of all fractions, decimals, and percentages.',
            'formula': '1/2 to 1/25 & all multiples mixed randomly',
            'trick': '⚡ Speed Blitz: Solve within 5 seconds without paper calculation!',
          },
        ];

      case TopicType.lcmHcf:
        return [
          {
            'level': 'LEVEL 1 • FOUNDATION',
            'title': 'Basic Numbers LCM & HCF',
            'desc': 'Prime factorization, highest powers, and difference shortcut.',
            'formula': 'HCF = lowest prime powers  |  LCM = highest prime powers',
            'trick': '⚡ Difference Hack: HCF is ALWAYS either the difference between numbers or its factor!',
          },
          {
            'level': 'LEVEL 2 • FRACTIONS',
            'title': 'LCM & HCF of Fractions',
            'desc': 'Fractional inputs with numerators and denominators.',
            'formula': 'LCM = LCM(Numerators) / HCF(Denominators)\nHCF = HCF(Numerators) / LCM(Denominators)',
            'trick': '⚡ Fraction Rule: What you need (LCM/HCF) goes on TOP for numerators!',
          },
          {
            'level': 'LEVEL 3 • PRODUCT & CO-PRIME',
            'title': 'Co-Prime & Product Relationships',
            'desc': 'Product = LCM × HCF, ratio of numbers x : y, and sum of pairs.',
            'formula': 'First × Second = LCM × HCF  |  Numbers = H·x and H·y',
            'trick': '⚡ Ratio Method: If numbers are in ratio a:b, LCM = HCF × a × b!',
          },
          {
            'level': 'LEVEL 4 • REMAINDER CASES',
            'title': '4 Classic Remainder Cases & Mixed Drills',
            'desc': 'Same remainder in each case, negative difference (N − R), and bells ringing.',
            'formula': 'N = LCM(a, b, c) × k + r  |  N = LCM(a, b, c) × k − d',
            'trick': '⚡ Bells Ringing Hack: Always find LCM of time intervals in seconds, then convert to minutes.',
          },
        ];

      case TopicType.divisibility:
        return [
          {
            'level': 'LEVEL 1 • POWERS OF 2 & 5',
            'title': 'Powers of 2 & 5 (2, 4, 8, 16 & 5, 25)',
            'desc': 'Last 1, 2, 3, 4 digits rules and odd/even third digit shortcuts.',
            'formula': 'Div 4: Last 2 digits  |  Div 8: Last 3 digits  |  Div 16: Last 4 digits',
            'trick': '⚡ 8\'s Topper Trick: If 3rd digit from right is ODD, just add 4 to last 2 digits and check ÷ 8!',
          },
          {
            'level': 'LEVEL 2 • DIGITAL SUM',
            'title': 'Sum of Digits Rules (3, 9, 27)',
            'desc': 'Casting out nines and digital root cancellation.',
            'formula': 'Div 3: Sum of digits ÷ 3  |  Div 9: Digital Root = 9 or 0',
            'trick': '⚡ Casting Out Nines: Strike out 9 and pairs adding to 9 (1+8, 2+7, 3+6, 4+5) instantly!',
          },
          {
            'level': 'LEVEL 3 • SPECIAL PRIME RULES',
            'title': 'Alternating & Osculation Rules (7, 11, 13)',
            'desc': 'Alternating sum difference and 3-digit block oscillation.',
            'formula': 'Div 11: (Odd place sum − Even place sum) ÷ 11\nDiv 7: a − 2b  |  Div 13: a + 4b',
            'trick': '⚡ 3-Digit Block Method: (Block 1 − Block 2 + Block 3) checks 7, 11, and 13 simultaneously!',
          },
          {
            'level': 'LEVEL 4 • COMPOSITE EXAM DIVISORS',
            'title': 'Composite Divisors (72, 88, 99, 144)',
            'desc': 'Find missing digits x & y in numbers divisible by composite exam benchmarks.',
            'formula': '72 = 8 × 9  |  88 = 8 × 11  |  99 = 9 × 11  |  144 = 9 × 16',
            'trick': '⚡ Co-Prime Split: Always test 8 first to fix the last digit, then test 9 or 11 to fix the rest!',
          },
        ];

      case TopicType.numberSystem:
        return [
          {
            'level': 'LEVEL 1 • UNIT DIGITS',
            'title': 'Unit Digits & Cyclicity (Power mod 4)',
            'desc': 'Cyclicity of 2, 3, 7, 8 (cycle of 4), 4 & 9 (cycle of 2), and 0, 1, 5, 6.',
            'formula': 'Unit Digit: Last digit power mod 4 (Remainder 0 ➔ power 4)',
            'trick': '⚡ Divide power by 4! If remainder is 0, use power 4. 7⁴ ends in 1, 3⁴ ends in 1, 2⁴ ends in 6.',
          },
          {
            'level': 'LEVEL 2 • TRAILING ZEROES',
            'title': 'Number of Trailing Zeroes in Products & Factorials',
            'desc': 'Counting highest power of 5 in n! and factor products.',
            'formula': 'Zeroes in n! = ⌊n/5⌋ + ⌊n/25⌋ + ⌊n/125⌋ + …',
            'trick': '⚡ Successive Division: Divide n by 5, then that quotient by 5, and sum all quotients!',
          },
          {
            'level': 'LEVEL 3 • SERIES SUMMATION',
            'title': 'Series Summation (Σn, Σn², Σn³)',
            'desc': 'Natural numbers, first n even/odd, and squares/cubes formulas.',
            'formula': 'Σn = n(n+1)/2  |  Σn² = n(n+1)(2n+1)/6  |  Σn³ = [n(n+1)/2]²',
            'trick': '⚡ Even/Odd Sums: First n odd numbers sum to n². First n even numbers sum to n(n+1).',
          },
          {
            'level': 'LEVEL 4 • FACTORS & THEOREMS',
            'title': 'Factors Count, Sum & Remainder Theorems',
            'desc': 'Total factors (p+1)(q+1), odd/even factors, and Wilson/Euler remainders.',
            'formula': 'Total Factors: If N = aᵖ · bᑫ · cʳ, Count = (p+1)(q+1)(r+1)',
            'trick': '⚡ For Odd Factors: Drop the power of 2 completely and multiply the remaining (q+1)(r+1)!',
          },
        ];

      case TopicType.triples:
        return [
          {
            'level': 'LEVEL 1 • PRIMARY TRIPLES',
            'title': 'Primary Base Triples (3-4-5, 5-12-13...)',
            'desc': 'The 5 most frequently tested right-angled triangle triples.',
            'formula': '(3, 4, 5)  •  (5, 12, 13)  •  (7, 24, 25)  •  (8, 15, 17)  •  (9, 40, 41)',
            'trick': '⚡ Odd Number Generator: For odd number m, other sides are (m²−1)/2 and (m²+1)/2!',
          },
          {
            'level': 'LEVEL 2 • HIGHER TRIPLES',
            'title': 'Higher & Tier-II Triples',
            'desc': 'Advanced triples asked in SSC CGL Tier-II and CDS exams.',
            'formula': '(11, 60, 61)  •  (12, 35, 37)  •  (13, 84, 85)  •  (16, 63, 65)  •  (20, 21, 29)',
            'trick': '⚡ Consecutive Hypotenuse: Notice 60-61, 84-85, 40-41 differ by only 1!',
          },
          {
            'level': 'LEVEL 3 • SCALED MULTIPLIERS',
            'title': 'Scaled Multipliers (2×, 3×, 5× Base Triples)',
            'desc': 'Triples scaled by a constant factor k.',
            'formula': 'k × (3, 4, 5) ➔ 6-8-10, 9-12-15, 12-16-20, 15-20-25',
            'trick': '⚡ Reduce First: Divide given numbers by their HCF to reveal the base triple immediately!',
          },
          {
            'level': 'LEVEL 4 • MIXED SPRINT',
            'title': 'Rapid Hypotenuse & Leg Speed Sprint',
            'desc': 'Instant recall of missing side in right-angled triangles and rectangles.',
            'formula': 'Hypotenuse c = √(a² + b²)  |  Leg a = √(c² − b²)',
            'trick': '⚡ 3-Second Recall: Recognize the family without squaring big numbers.',
          },
        ];

      case TopicType.squareRootSurds:
        return [
          {
            'level': 'LEVEL 1 • PERFECT ROOTS',
            'title': 'Perfect Square Roots (1 to 10,000)',
            'desc': 'Unit digit elimination and tens place pairing for instant extraction.',
            'formula': 'Last digits: 1➔1/9, 4➔2/8, 5➔5, 6➔4/6, 9➔3/7, 0➔0',
            'trick': '⚡ 2-Digit Strike: Drop last 2 digits, find biggest square below rest, pick unit digit by parity!',
          },
          {
            'level': 'LEVEL 2 • NON-PERFECT APPROX',
            'title': 'Non-Perfect Root Approximations',
            'desc': 'Differential approximation formula for roots like √10, √29, √47.',
            'formula': '√(A ± b) ≈ √A ± b / (2√A), where A is nearest perfect square',
            'trick': '⚡ Fast Mental Root: For √29, A=25, b=4. √29 ≈ 5 + 4/(2×5) = 5.4 in 2 seconds!',
          },
          {
            'level': 'LEVEL 3 • INFINITE RADICALS',
            'title': 'Infinite Radical Series & Patterns',
            'desc': 'Standard SSC patterns of √(x + √(x + …)) and √(x · √(x · …)).',
            'formula': '√(n(n+1) + √(n(n+1) + …)) = n+1  |  √(x · √(x · …)) = x',
            'trick': '⚡ Factorize into Consecutive Numbers: For √(12 + √(12 + …)), 12 = 3×4 ➔ Ans: 4 (larger)!',
          },
          {
            'level': 'LEVEL 4 • SURDS COMPARISON',
            'title': 'Surds Rationalization & Size Comparison',
            'desc': 'Comparing (√a + √b) vs (√c + √d) when sum or difference is constant.',
            'formula': 'Rationalize: 1 / (√a + √b) = (√a − √b) / (a − b)',
            'trick': '⚡ If (a+b) is equal, the pair with the LARGEST product (a×b) is LARGER!',
          },
        ];

      case TopicType.trigonometry:
        return [
          {
            'level': 'LEVEL 1 • TABLE VALUES',
            'title': 'Standard Table Values (0°, 30°, 45°, 60°, 90°)',
            'desc': 'Ratios of sin, cos, tan, cot, sec, and cosec.',
            'formula': 'sin: 0, 1/2, 1/√2, √3/2, 1  |  tan: 0, 1/√3, 1, √3, ∞',
            'trick': '⚡ 0-1-2-3-4 Rule: Take square root of (n/4) for n = 0,1,2,3,4 to generate all sin values!',
          },
          {
            'level': 'LEVEL 2 • COMPLEMENTARY PAIRS',
            'title': 'Complementary Angles (Sum = 90°)',
            'desc': 'Product of tan A · tan B = 1, sin²A + sin²B = 1 when A + B = 90°.',
            'formula': 'If A + B = 90°: tan A · tan B = 1  |  sin A = cos B',
            'trick': '⚡ Symmetry Cancellation: In tan 10° ··· tan 80°, all complementary pairs multiply to 1!',
          },
          {
            'level': 'LEVEL 3 • IDENTITIES & CONJUGATES',
            'title': 'Pythagorean Identities & Conjugate Rules',
            'desc': 'sec²θ − tan²θ = 1 and cosec²θ − cot²θ = 1.',
            'formula': 'If sec θ + tan θ = k, then sec θ − tan θ = 1/k\nsec θ = (k² + 1)/(2k)',
            'trick': '⚡ Reciprocal Inversion: If sec + tan = 5, then sec − tan is directly 1/5 = 0.2!',
          },
          {
            'level': 'LEVEL 4 • MAXIMA & FULL SPRINT',
            'title': 'Maximum & Minimum Values & Mixed Sprint',
            'desc': 'Bounds for a sin θ + b cos θ and a sin²θ + b cosec²θ.',
            'formula': 'Max / Min of (a sin θ + b cos θ) = ± √(a² + b²)\nMin of (a sin²θ + b cosec²θ) = 2√(ab)',
            'trick': '⚡ 2√ab Shortcut: Whenever term and its reciprocal are squared, minimum is 2√(ab)!',
          },
        ];

      default:
        return [
          {
            'level': 'LEVEL 1 • FOUNDATION',
            'title': 'Core Standard Drill',
            'desc': 'Foundational questions to build speed and accuracy.',
            'formula': 'Standard competitive exam formulation',
            'trick': '⚡ Focus on 5-second rapid mental calculation.',
          },
        ];
    }
  }

  // -------------------------------------------------------------
  // QUESTION GENERATION ENGINE (CATEGORY TARGETED)
  // -------------------------------------------------------------
  List<QuestionModel> _getQuestionsForCategory(int categoryIndex, int count) {
    switch (widget.type) {
      case TopicType.fractions:
        return _generateFractionCategoryQuestions(categoryIndex, count);

      case TopicType.triples:
        return _generateTriplesCategoryQuestions(categoryIndex, count);

      case TopicType.lcmHcf:
        final all = List<QuestionModel>.from(LcmHcfConceptData.questions)..shuffle();
        return all.take(count).toList();

      case TopicType.divisibility:
        final all = List<QuestionModel>.from(DivisibilityRulesConceptData.questions)..shuffle();
        return all.take(count).toList();

      case TopicType.numberSystem:
        final all = List<QuestionModel>.from(NumberSystemConceptData.questions)..shuffle();
        return all.take(count).toList();

      case TopicType.squareRootSurds:
        final all = List<QuestionModel>.from(SquareRootSurdsConceptData.questions)..shuffle();
        return all.take(count).toList();

      case TopicType.trigonometry:
        final all = List<QuestionModel>.from(TrigonometrySolutionsData.questions)..shuffle();
        return all.take(count).toList();

      default:
        return DynamicQuestionEngine.generateUniqueQuestions(type: widget.type, count: count);
    }
  }

  List<QuestionModel> _generateFractionCategoryQuestions(int categoryIndex, int count) {
    final rnd = math.Random();
    final allTable = [
      {'f': '1/2', 'p': '50%', 'd': '0.5'},
      {'f': '1/3', 'p': '33.33%', 'd': '0.333'},
      {'f': '1/4', 'p': '25%', 'd': '0.25'},
      {'f': '1/5', 'p': '20%', 'd': '0.2'},
      {'f': '1/6', 'p': '16.67%', 'd': '0.167'},
      {'f': '1/7', 'p': '14.29%', 'd': '0.143'},
      {'f': '1/8', 'p': '12.5%', 'd': '0.125'},
      {'f': '1/9', 'p': '11.11%', 'd': '0.111'},
      {'f': '1/10', 'p': '10%', 'd': '0.1'},
      {'f': '1/11', 'p': '9.09%', 'd': '0.091'},
      {'f': '1/12', 'p': '8.33%', 'd': '0.083'},
      {'f': '1/13', 'p': '7.69%', 'd': '0.077'},
      {'f': '1/14', 'p': '7.14%', 'd': '0.071'},
      {'f': '1/15', 'p': '6.67%', 'd': '0.067'},
      {'f': '1/16', 'p': '6.25%', 'd': '0.0625'},
      {'f': '1/17', 'p': '5.88%', 'd': '0.059'},
      {'f': '1/18', 'p': '5.56%', 'd': '0.056'},
      {'f': '1/19', 'p': '5.26%', 'd': '0.053'},
      {'f': '1/20', 'p': '5%', 'd': '0.05'},
      {'f': '1/24', 'p': '4.17%', 'd': '0.042'},
      {'f': '1/25', 'p': '4%', 'd': '0.04'},
      {'f': '3/8', 'p': '37.5%', 'd': '0.375'},
      {'f': '5/8', 'p': '62.5%', 'd': '0.625'},
      {'f': '7/8', 'p': '87.5%', 'd': '0.875'},
      {'f': '2/3', 'p': '66.67%', 'd': '0.667'},
      {'f': '3/4', 'p': '75%', 'd': '0.75'},
      {'f': '4/5', 'p': '80%', 'd': '0.8'},
      {'f': '4/7', 'p': '57.14%', 'd': '0.571'},
      {'f': '5/6', 'p': '83.33%', 'd': '0.833'},
    ];

    List<Map<String, String>> subset;
    if (categoryIndex == 0) {
      // 1/2 to 1/10
      subset = allTable.take(9).toList();
    } else if (categoryIndex == 1) {
      // 1/11 to 1/25
      subset = allTable.sublist(9, 21);
    } else if (categoryIndex == 2) {
      // Multiples
      subset = allTable.sublist(21);
    } else {
      // All
      subset = allTable;
    }

    List<QuestionModel> questions = [];
    final pool = List<Map<String, String>>.from(subset)..shuffle(rnd);
    for (int i = 0; i < count; i++) {
      final item = pool[i % pool.length];
      final askDecimal = rnd.nextBool();
      final target = askDecimal ? item['d']! : item['p']!;

      final Set<String> opts = {target};
      while (opts.length < 4) {
        final other = allTable[rnd.nextInt(allTable.length)];
        opts.add(askDecimal ? other['d']! : other['p']!);
      }
      final listOpts = opts.toList()..shuffle(rnd);

      questions.add(
        QuestionModel(
          id: 'frac_drill_${categoryIndex}_$i',
          topicId: 'fractions',
          prompt: '${item['f']} in ${askDecimal ? 'decimal' : 'percentage'} = ?',
          correctAnswer: target,
          options: listOpts,
          explanation: '${item['f']} = ${item['p']} = ${item['d']}',
          examBadge: 'Speed Percentage Drill',
          difficulty: 1,
        ),
      );
    }
    return questions;
  }

  List<QuestionModel> _generateTriplesCategoryQuestions(int categoryIndex, int count) {
    final rnd = math.Random();
    final List<List<int>> baseTriples = [
      [3, 4, 5],
      [5, 12, 13],
      [7, 24, 25],
      [8, 15, 17],
      [9, 40, 41],
    ];
    final List<List<int>> higherTriples = [
      [11, 60, 61],
      [12, 35, 37],
      [13, 84, 85],
      [16, 63, 65],
      [20, 21, 29],
      [28, 45, 53],
    ];
    final List<List<int>> scaledTriples = [
      [6, 8, 10],
      [9, 12, 15],
      [12, 16, 20],
      [15, 20, 25],
      [10, 24, 26],
      [14, 48, 50],
      [16, 30, 34],
    ];

    List<List<int>> subset;
    if (categoryIndex == 0) {
      subset = baseTriples;
    } else if (categoryIndex == 1) {
      subset = higherTriples;
    } else if (categoryIndex == 2) {
      subset = scaledTriples;
    } else {
      subset = [...baseTriples, ...higherTriples, ...scaledTriples];
    }

    List<QuestionModel> questions = [];
    final pool = List<List<int>>.from(subset)..shuffle(rnd);
    for (int i = 0; i < count; i++) {
      final triple = pool[i % pool.length];
      final askHypo = rnd.nextBool();
      String prompt;
      String ans;

      if (askHypo) {
        prompt = 'In a right triangle with legs ${triple[0]} and ${triple[1]}, find Hypotenuse (कर्ण).';
        ans = '${triple[2]}';
      } else {
        prompt = 'In a right triangle with hypotenuse ${triple[2]} and one leg ${triple[0]}, find other leg.';
        ans = '${triple[1]}';
      }

      final int correctVal = int.parse(ans);
      final Set<String> opts = {ans};
      while (opts.length < 4) {
        final offset = (rnd.nextInt(5) + 1) * (rnd.nextBool() ? 1 : -1);
        final dummy = correctVal + offset;
        if (dummy > 0 && dummy != correctVal) {
          opts.add(dummy.toString());
        }
      }

      questions.add(
        QuestionModel(
          id: 'triple_drill_${categoryIndex}_$i',
          topicId: 'triples',
          prompt: prompt,
          correctAnswer: ans,
          options: opts.toList()..shuffle(rnd),
          explanation: 'Pythagorean Triplet: (${triple[0]}, ${triple[1]}, ${triple[2]}) where ${triple[0]}² + ${triple[1]}² = ${triple[2]}²',
          examBadge: 'Pythagorean Triplet Drill',
          difficulty: 1,
        ),
      );
    }
    return questions;
  }

  // -------------------------------------------------------------
  // LAUNCH PRACTICE QUIZ
  // -------------------------------------------------------------
  void _startDrill(int categoryIndex) {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final cat = _categories[categoryIndex];
    final categoryTitle = cat['title'] ?? 'Speed Drill';

    final questions = _getQuestionsForCategory(categoryIndex, _questionCount);

    final double? perQuestionSeconds = switch (_timerDifficulty) {
      QuizTimerDifficulty.easy => null,
      QuizTimerDifficulty.medium => 10.0,
      QuizTimerDifficulty.hard => 5.0,
    };
    final bool isTimed = _timerDifficulty != QuizTimerDifficulty.easy;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizScreen(
          topic: TopicModel(
            id: '${widget.type.name}_cat$categoryIndex',
            title: '$_topicTitle: $categoryTitle',
            subtitle: 'Targeted Speed Practice Drill',
            type: widget.type,
            iconName: 'calculate_rounded',
          ),
          customQuestions: questions,
          onRegenerateQuestions: () => _getQuestionsForCategory(categoryIndex, _questionCount),
          isTimed: isTimed,
          perQuestionSeconds: perQuestionSeconds,
          questionCount: _questionCount,
          initialUseNumpad: _timerDifficulty == QuizTimerDifficulty.hard,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // UI BUILD
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final color = _themeColor;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(_icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _topicTitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.22),
                    const Color(0xFF13192B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [color, color.withValues(alpha: 0.6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _symbol,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Drill Mode & Level',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _topicSubtitle,
                          style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Quick Settings Bar (Questions Count & Timer Speed Mode)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF13192B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Questions Count:',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      _buildCountChip(10),
                      const SizedBox(width: 6),
                      _buildCountChip(20),
                      const SizedBox(width: 6),
                      _buildCountChip(30),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Speed Timer Pace:',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimerDifficultyButton(
                          difficulty: QuizTimerDifficulty.easy,
                          title: 'Easy',
                          sub: 'No Timer',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTimerDifficultyButton(
                          difficulty: QuizTimerDifficulty.medium,
                          title: 'Medium',
                          sub: '10s / Q',
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTimerDifficultyButton(
                          difficulty: QuizTimerDifficulty.hard,
                          title: 'Hard',
                          sub: '5s / Q',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. Section Title
            const Text(
              '🎯 Choose Practice Category & Start Drill:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),

            // 4. Category Cards
            ..._categories.asMap().entries.map((entry) {
              final idx = entry.key;
              final cat = entry.value;
              return _buildCategoryCard(idx, cat, color);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(int index, Map<String, String> cat, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13192B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              cat['level'] ?? '',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title & Description
          Text(
            cat['title'] ?? '',
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(
            cat['desc'] ?? '',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65), height: 1.3),
          ),
          const SizedBox(height: 12),

          // Formula Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F1D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              cat['formula'] ?? '',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Short Topper Trick
          if (cat['trick'] != null)
            Text(
              cat['trick']!,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFFFBBF24), height: 1.3),
            ),
          const SizedBox(height: 14),

          // Start Drill CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                shadowColor: color.withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: Text(
                'Start Drill ($_questionCount Questions)',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, letterSpacing: 0.2),
              ),
              onPressed: () => _startDrill(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(int count) {
    final isSelected = _questionCount == count;
    final color = _themeColor;

    return InkWell(
      onTap: () => setState(() => _questionCount = count),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.white12),
        ),
        child: Text(
          '$count Qs',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDifficultyButton({
    required QuizTimerDifficulty difficulty,
    required String title,
    required String sub,
    required Color color,
  }) {
    final isSelected = _timerDifficulty == difficulty;

    return InkWell(
      onTap: () => setState(() => _timerDifficulty = difficulty),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isSelected ? color : Colors.white70,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
