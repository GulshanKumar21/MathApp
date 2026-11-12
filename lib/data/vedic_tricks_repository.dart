class VedicTrick {
  final String title;
  final String sutraName;
  final String category;
  final String rule;
  final String example;
  final String explanation;
  final String examTip;

  const VedicTrick({
    required this.title,
    required this.sutraName,
    required this.category,
    required this.rule,
    required this.example,
    required this.explanation,
    this.examTip = '100% helpful for SSC CGL, Bank PO & Railway simplification.',
  });
}

class VedicTricksRepository {
  static const List<VedicTrick> tricks = [
    VedicTrick(
      title: 'Square of Numbers Ending in 5',
      sutraName: 'One More Than the Previous (N × (N + 1) | 25)',
      category: 'Squares',
      rule: 'Multiply the leading digit (N) by (N + 1), then append 25 at the end.',
      example: '65² = ?\nStep 1: 6 × (6 + 1) = 6 × 7 = 42\nStep 2: Append 25 at the end\nAnswer: 4225',
      explanation: 'Formula: [N × (N + 1)] | 25. Any number ending in 5 (15, 25, 35, 45, 65, 75, 85, 95...) can be squared mentally in 1 second!',
      examTip: 'Best shortcut for Compound Interest powers like 1.05², 1.15², and 1.25².',
    ),
    VedicTrick(
      title: 'Same First Digit & Last Digits Sum to 10',
      sutraName: 'Tens Same, Units Sum = 10 ([T × (T + 1)] | [U1 × U2])',
      category: 'Multiplication',
      rule: 'Multiply the identical leading digit by (T + 1), then append the product of the unit digits (in 2 digits).',
      example: '74 × 76 = ?\nStep 1: Leading digit = 7 ➔ 7 × (7 + 1) = 56\nStep 2: Unit digits = 4 × 6 = 24\nAnswer: 5624',
      explanation: 'Condition: Both numbers start with the same digit (e.g. 7 and 7) and their unit digits add up to 10 (4 + 6 = 10).',
      examTip: 'Saves 20–25 seconds per question in Banking Simplification and Data Interpretation.',
    ),
    VedicTrick(
      title: 'Fast Multiply Any Number by 11',
      sutraName: 'Sandwich Neighbor Addition Rule',
      category: 'Multiplication',
      rule: 'Keep the outer digits on the ends and add adjacent digits together for the middle digits (carry over if ≥ 10).',
      example: '52 × 11 = 5 [5+2] 2 ➔ 572\n78 × 11 = 7 [7+8] 8 = 7 [15] 8 ➔ 858',
      explanation: 'No traditional long multiplication needed! Write both outer digits and insert pairwise sums between them.',
      examTip: 'Super fast for Mensuration problems involving π (22/7 = 2 × 11 / 7).',
    ),
    VedicTrick(
      title: 'Multiply Numbers Near & Below 100',
      sutraName: 'Base-100 Deficit Method',
      category: 'Base Method',
      rule: 'Find each deficit from 100. Cross-subtract for the left part, then multiply the deficits (2 digits) for the right part.',
      example: '97 × 94 = ?\nDeficits: -3 and -6\nLeft part: 97 - 6 = 91\nRight part: (-3) × (-6) = 18\nAnswer: 9118',
      explanation: 'Left part = either number minus the other\'s deficit. Right part = product of both deficits in 2 digits. Instant 2-second answer!',
      examTip: 'Appears frequently in SSC CGL Tier 1 & Tier 2 simplification.',
    ),
    VedicTrick(
      title: 'Multiply Numbers Near & Above 100 (100+)',
      sutraName: 'Base-100 Surplus Method',
      category: 'Base Method',
      rule: 'Find how much each exceeds 100. Cross-add for the left part, then multiply the surpluses (2 digits) for the right part.',
      example: '104 × 107 = ?\nSurpluses: +4 and +7\nLeft part: 104 + 7 = 111\nRight part: 4 × 7 = 28\nAnswer: 11128',
      explanation: 'Left part = 104 + 7 = 111. Right part = 4 × 7 = 28. Works identically for numbers near 1000 as well.',
      examTip: 'Very useful for Percentage & Profit-Loss calculations such as 104% of 107.',
    ),
    VedicTrick(
      title: 'Multiply Any 2-Digit Number by 99 or 999',
      sutraName: 'Subtract 1 & Complement Rule ((N - 1) | (100 - N))',
      category: 'Multiplication',
      rule: 'Subtract 1 from the number for the left part, then subtract the number from 100 for the right part.',
      example: '74 × 99 = ?\nStep 1: 74 - 1 = 73 (Left part)\nStep 2: 100 - 74 = 26 (Right part)\nAnswer: 7326',
      explanation: 'Formula: (N - 1) | (100 - N). Turns messy multiplication into effortless single-step subtraction.',
      examTip: 'Write the exact answer without pen or paper whenever × 99 or × 999 appears.',
    ),
    VedicTrick(
      title: 'Fast Squares from 51 to 59',
      sutraName: 'Base-50 / 25 Shortcut ((25 + U) | U²)',
      category: 'Squares',
      rule: 'Add the unit digit (U) to 25 for the left part, then write U² in 2 digits for the right part.',
      example: '54² = ?\nLeft part: 25 + 4 = 29\nRight part: 4² = 16\nAnswer: 2916\n58² = (25 + 8) | 64 ➔ 3364',
      explanation: 'Since 50 is half of 100, we anchor at 25: (25 + unit digit) | (unit digit squared).',
      examTip: 'Squares between 2500 and 3600 take less than 1 second mentally.',
    ),
    VedicTrick(
      title: 'Universal 2-Digit Multiply (Criss-Cross)',
      sutraName: 'Vertical & Crosswise (Criss-Cross Rule)',
      category: 'Universal Multiplication',
      rule: 'Multiply right digits ➔ Cross-multiply & add ➔ Multiply left digits (propagating carries).',
      example: '23 × 14 = ?\n1) Right vertical: 3 × 4 = 12 (Write 2, Carry 1)\n2) Cross-multiply: (2×4) + (3×1) + 1 = 12 (Write 2, Carry 1)\n3) Left vertical: (2×1) + 1 = 3\nAnswer: 322',
      explanation: 'Universal master formula for multiplying ANY two 2-digit numbers on a single line without 3 intermediate rows.',
      examTip: 'Most essential speed calculation technique across all competitive exams.',
    ),
    VedicTrick(
      title: 'Percentage to Fraction Direct Shortcut',
      sutraName: 'Fraction Equivalent Conversion',
      category: 'Percentages',
      rule: 'Convert decimal percentages to clean fractions: 12.5% = 1/8, 25% = 1/4, 37.5% = 3/8.',
      example: '12.5% of 640 = ?\nInstead of 640 × 12.5 ÷ 100:\n640 ÷ 8 = 80 (Instant mental answer!)',
      explanation: 'Memorizing base fractions (1/2 through 1/20) cuts Quantitative Aptitude solving time by up to 40%.',
      examTip: 'Indispensable for Bank PO and SBI PO Data Interpretation (DI) charts.',
    ),
    VedicTrick(
      title: 'Multiply Numbers Near & Below 1000',
      sutraName: 'Base-1000 Deficit Rule (3-Digit Right Part)',
      category: 'Base Method',
      rule: 'Find each deficit from 1000. Cross-subtract for the left part, then write the product of deficits in 3 digits.',
      example: '994 × 997 = ?\nDeficits: -6 and -3\nLeft part: 994 - 3 = 991\nRight part: (-6) × (-3) = 018 (3 digits!)\nAnswer: 991018',
      explanation: 'Since 1000 has 3 zeros, the right part must always be 3 digits wide (pad 18 as 018).',
      examTip: 'Saves valuable seconds on large-number simplification problems.',
    ),
    VedicTrick(
      title: 'Product of Consecutive Numbers (n × (n + 1))',
      sutraName: 'Square + Smaller Number (n² + n)',
      category: 'Consecutive Numbers',
      rule: 'n × (n + 1) = Smaller number squared + Smaller number.',
      example: '12 × 13 = 12² + 12 = 144 + 12 = 156\n17 × 18 = 17² + 17 = 289 + 17 = 306\n24 × 25 = 24² + 24 = 576 + 24 = 600',
      explanation: 'Instead of full multiplication, just add the smaller number to its own square for a 1-second answer.',
      examTip: 'Frequently tested in Bank PO & SSC CGL number series and approximations.',
    ),
    VedicTrick(
      title: 'Multiply Numbers with a Gap of 2',
      sutraName: 'Midpoint Difference of Squares (N² - 1)',
      category: 'Consecutive Numbers',
      rule: 'When two numbers differ by 2: Square the middle number and subtract 1.',
      example: '11 × 13 = 12² - 1 = 144 - 1 = 143\n13 × 15 = 14² - 1 = 196 - 1 = 195\n17 × 19 = 18² - 1 = 324 - 1 = 323\n24 × 26 = 25² - 1 = 625 - 1 = 624',
      explanation: '(N - 1)(N + 1) = N² - 1. Square the number right between them and subtract 1 mentally!',
      examTip: 'High-yield shortcut for Banking approximation and fast mental math.',
    ),
    VedicTrick(
      title: 'Multiply Numbers Ending in 5 with a Gap of 10',
      sutraName: 'Vedic Unit 5 Gap-10 Rule',
      category: 'Special Multiplications',
      rule: 'Both end in 5 and differ by 10: Always ends in 75, and the left part = (Larger tens digit)² - 1.',
      example: '15 × 25 = (2² - 1) | 75 = 375\n25 × 35 = (3² - 1) | 75 = 875\n35 × 45 = (4² - 1) | 75 = 1575\n45 × 55 = (5² - 1) | 75 = 2475',
      explanation: 'Formula: [(Larger tens digit)² - 1] | 75. Instant 1-second solution without pen and paper.',
      examTip: 'Great time saver in simplification and percentage questions.',
    ),
    VedicTrick(
      title: 'Fast Multiply by 25, 125 & 625',
      sutraName: 'Divide-Instead-of-Multiply Rule',
      category: 'Special Multipliers',
      rule: '× 25 = Divide by 4, then × 100\n× 125 = Divide by 8, then × 1000\n× 625 = Divide by 16, then × 10000',
      example: '12 × 25 = (12 ÷ 4) × 100 = 300\n24 × 25 = (24 ÷ 4) × 100 = 600\n16 × 125 = (16 ÷ 8) × 1000 = 2000\n48 × 125 = (48 ÷ 8) × 1000 = 6000',
      explanation: 'Since 25 = 100/4 and 125 = 1000/8, dividing by 4 or 8 is 5× faster than direct multiplication.',
      examTip: 'Essential for quick percentage & ratio breakdowns in Data Interpretation (DI).',
    ),
  ];
}
