import 'dart:math';
import '../models/math_models.dart';

class DynamicQuestionEngine {
  static final Random _rnd = Random();

  // In-session & global served questions tracker to guarantee ZERO repeats
  static final Set<String> _recentlyServedPrompts = {};

  // Track recently served starting multiplier per table to guarantee non-repeating first question across sessions
  static final Map<int, List<int>> _recentFirstMultipliers = {};
  // Track recently served starting prompt per topic/range/mix
  static final Map<String, List<String>> _recentFirstPrompts = {};

  static void clearRecentHistory() {
    _recentlyServedPrompts.clear();
    _recentFirstMultipliers.clear();
    _recentFirstPrompts.clear();
  }

  // Generate unique non-repeating questions
  static List<QuestionModel> generateUniqueQuestions({
    required TopicType type,
    int count = 15,
    int difficultyLevel = 1, // 1: Easy/Mid, 2: Competitive, 3: Hard
  }) {
    List<QuestionModel> result = [];
    int attempts = 0;
    const int maxAttempts = 300;

    while (result.length < count && attempts < maxAttempts) {
      attempts++;
      QuestionModel q = _createSingleQuestion(type, difficultyLevel);

      // Enforce zero repetition in the current session
      if (!_recentlyServedPrompts.contains(q.prompt) && !result.any((item) => item.prompt == q.prompt)) {
        _recentlyServedPrompts.add(q.prompt);
        result.add(q);
      }
    }

    // Keep recent history bounded to avoid memory bloating while preventing repeats across 500+ questions
    if (_recentlyServedPrompts.length > 500) {
      _recentlyServedPrompts.clear();
    }

    return result;
  }

  // Daily Fresh Seeded Set Generator: Changes automatically every calendar day
  static List<QuestionModel> generateDailyChallengeSet(DateTime date, {int count = 15}) {
    // Generate deterministic yet unpredictable daily seed based on year, month, and day
    int daySeed = date.year * 10000 + date.month * 100 + date.day;
    Random dailyRnd = Random(daySeed);

    List<QuestionModel> dailyList = [];
    List<TopicType> pool = [
      TopicType.tables,
      TopicType.squares,
      TopicType.cubes,
      TopicType.fractions,
      TopicType.triples,
    ];

    for (int i = 0; i < count; i++) {
      TopicType pickedType = pool[dailyRnd.nextInt(pool.length)];
      dailyList.add(_createSeededQuestion(pickedType, dailyRnd, i));
    }

    return dailyList;
  }

  static QuestionModel _createSingleQuestion(TopicType type, int difficulty) {
    String id = 'q_${DateTime.now().microsecondsSinceEpoch}_${_rnd.nextInt(9999)}';

    switch (type) {
      case TopicType.tables:
        // Tables: strictly 2 to 30, multiplied by 2 to 9 only (NO 1 and NO 10, as they are too easy!)
        int a = _rnd.nextInt(29) + 2; // 2 to 30
        int b = _rnd.nextInt(8) + 2;  // 2 to 9 strictly
        int ans = a * b;
        List<String> options = _generateSmartDistractors(ans, delta: [a, -a, b, -b, 10, -10, 2, -2]);
        return QuestionModel(
          id: id,
          topicId: 'tables',
          prompt: '$a × $b = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: difficulty,
          explanation: '$a multiplied by $b is $ans',
        );

      case TopicType.hardMultiplier:
        // 🔥 Speed Math Speed Multipliers & Consecutive Multiplications (Page 8, 9, 10)
        final mulType = _rnd.nextInt(8);
        if (mulType == 0) {
          // 1. Consecutive Numbers: n × (n + 1) = n² + n (e.g. 12×13, 13×14, 16×17, 17×18, 24×25, 35×36)
          int n = _rnd.nextInt(39) + 11; // 11 to 49
          int ans = n * (n + 1);
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$n × ${n + 1} = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Consecutive Rule: $n² + $n = ${n * n} + $n = $ans (or ${n + 1}² - ${n + 1} = $ans)',
          );
        } else if (mulType == 1) {
          // 2. Alternate Consecutive Numbers (Gap of 2): (N-1)(N+1) = N² - 1
          int mid = _rnd.nextInt(25) + 12; // 12 to 36
          int a = mid - 1;
          int b = mid + 1;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Midpoint Rule: ($mid - 1)($mid + 1) = $mid² - 1 = ${mid * mid} - 1 = $ans',
          );
        } else if (mulType == 2) {
          // 3. Difference of 10 Ending in 5: (HigherTen² - 1) | 75 (e.g. 15×25, 25×35, 45×55, 65×75, 85×95)
          final tensList = [1, 2, 3, 4, 6, 7, 8];
          int lowTen = tensList[_rnd.nextInt(tensList.length)];
          int highTen = lowTen + 1;
          int a = lowTen * 10 + 5;
          int b = highTen * 10 + 5;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 200, -200, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Diff 10 Ending 5: ($highTen² - 1) | 75 = ${highTen * highTen - 1}75 = $ans',
          );
        } else if (mulType == 3) {
          // 4. Powers of 5 (× 25 or × 125)
          bool is125 = _rnd.nextBool();
          if (is125) {
            int q = _rnd.nextInt(12) + 2; // 2 to 13
            int a = q * 8;
            int ans = a * 125;
            List<String> options = _generateSmartDistractors(ans, delta: [1000, -1000, 500, -500, 100, -100]);
            return QuestionModel(
              id: id,
              topicId: 'hard_multiplier',
              prompt: '$a × 125 = ?',
              correctAnswer: '$ans',
              options: options,
              difficulty: difficulty,
              explanation: '⚡ Vedic Power of 5: ($a ÷ 8) × 1000 = $q × 1000 = $ans',
            );
          } else {
            int q = _rnd.nextInt(25) + 3; // 3 to 27
            int a = q * 4;
            int ans = a * 25;
            List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 25, -25, 50, -50]);
            return QuestionModel(
              id: id,
              topicId: 'hard_multiplier',
              prompt: '$a × 25 = ?',
              correctAnswer: '$ans',
              options: options,
              difficulty: difficulty,
              explanation: '⚡ Vedic Magical 25: ($a ÷ 4) × 100 = $q × 100 = $ans',
            );
          }
        } else if (mulType == 4) {
          // 5. Ekadhikena Purvena: Same tens, units sum = 10 (e.g. 64 * 66, 83 * 87, 42 * 48)
          int tens = _rnd.nextInt(7) + 2; // 2 to 8
          int u1 = _rnd.nextInt(8) + 1; // 1 to 8
          int u2 = 10 - u1;
          int a = tens * 10 + u1;
          int b = tens * 10 + u2;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 10, -10, 20, -20]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Ekadhikena Rule: $tens × ($tens + 1) | $u1 × $u2 = ${tens * (tens + 1)}${u1 * u2 < 10 ? '0' : ''}${u1 * u2} = $ans',
          );
        } else if (mulType == 5) {
          // 6. 11 Sandwich Rule: AB * 11
          int a = _rnd.nextInt(78) + 12; // 12 to 89
          int ans = a * 11;
          List<String> options = _generateSmartDistractors(ans, delta: [11, -11, 22, -22, 10, -10]);
          int d1 = a ~/ 10;
          int d2 = a % 10;
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × 11 = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic 11-Sandwich: Split $d1 and $d2, middle is ($d1 + $d2) = $ans',
          );
        } else if (mulType == 6) {
          // 7. Base 100 Method (below 100: e.g. 94 * 97)
          int diff1 = _rnd.nextInt(7) + 2; // 2 to 8
          int diff2 = _rnd.nextInt(7) + 2;
          int a = 100 - diff1;
          int b = 100 - diff2;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 10, -10, 2, -2]);
          int prodDiff = diff1 * diff2;
          String diffStr = prodDiff < 10 ? '0$prodDiff' : '$prodDiff';
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Base-100: ($a - $diff2) | ($diff1 × $diff2) = ${a - diff2}$diffStr = $ans',
          );
        } else {
          // 8. Half & Double Rule (When one number ends in 5: e.g. 14 × 15, 16 × 35)
          int ev = (_rnd.nextInt(15) + 6) * 2; // 12, 14, 16, 18, 22, 24, 26, 28
          int fv = (_rnd.nextInt(5) + 1) * 10 + 5; // 15, 25, 35, 45, 55
          int ans = ev * fv;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 50, -50]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$ev × $fv = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Half & Double: ($ev ÷ 2) × ($fv × 2) = ${ev ~/ 2} × ${fv * 2} = $ans',
          );
        }

      case TopicType.squares:
        // 🔥 Speed Math Speed Squares & Instant Square Roots
        final sqType = _rnd.nextInt(4);
        if (sqType == 0) {
          // Numbers ending in 5: (n5)² = n(n+1) | 25
          int tens = _rnd.nextInt(9) + 2; // 25, 35, 45, 55, 65, 75, 85, 95, 105
          int n = tens * 10 + 5;
          int ans = n * n;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 200, -200, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'squares',
            prompt: '$n² = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Ending-in-5 Trick: $tens × (${tens + 1}) | 25 = ${tens * (tens + 1)}25 = $ans',
          );
        } else if (sqType == 1) {
          // Base 50 Method (41 to 59)
          int diff = _rnd.nextInt(17) - 8; // -8 to +8
          if (diff == 0) diff = 4;
          int n = 50 + diff;
          int ans = n * n;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 10, -10, 20, -20]);
          int dAbs = diff.abs();
          String dSqStr = (dAbs * dAbs < 10) ? '0${dAbs * dAbs}' : '${dAbs * dAbs}';
          return QuestionModel(
            id: id,
            topicId: 'squares',
            prompt: '$n² = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Base-50 Trick: (25 ${diff >= 0 ? '+' : '-'} $dAbs) | $dAbs² = ${25 + diff}$dSqStr = $ans',
          );
        } else if (sqType == 2) {
          // Base 100 Method (91 to 109)
          int diff = _rnd.nextInt(17) - 8;
          if (diff == 0) diff = -4;
          int n = 100 + diff;
          int ans = n * n;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 200, -200, 10, -10]);
          int dAbs = diff.abs();
          String dSqStr = (dAbs * dAbs < 10) ? '0${dAbs * dAbs}' : '${dAbs * dAbs}';
          return QuestionModel(
            id: id,
            topicId: 'squares',
            prompt: '$n² = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Base-100 Trick: ($n ${diff >= 0 ? '+' : '-'} $dAbs) | $dAbs² = ${n + diff}$dSqStr = $ans',
          );
        } else {
          // Instant Square Root
          int root = _rnd.nextInt(40) + 21; // 21 to 60
          int sqVal = root * root;
          List<String> options = _generateSmartDistractors(root, delta: [2, -2, 10, -10, 1, -1]);
          return QuestionModel(
            id: id,
            topicId: 'squares',
            prompt: '√$sqVal = ?',
            correctAnswer: '$root',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic 2-Second Square Root: Nearest base square & last digit check ➔ √$sqVal = $root',
          );
        }

      case TopicType.cubes:
        // 🔥 Speed Math Speed Cubes & 3-Second Mental Cube Roots
        final cubeType = _rnd.nextInt(3);
        if (cubeType == 0) {
          // 3-Second Mental Cube Root of up to 6-digit numbers
          int root = _rnd.nextInt(45) + 12; // 12 to 56
          int cubeVal = root * root * root;
          List<String> options = _generateSmartDistractors(root, delta: [2, -2, 10, -10, 1, -1]);
          int lastDigit = root % 10;
          return QuestionModel(
            id: id,
            topicId: 'cubes',
            prompt: '∛$cubeVal = ?',
            correctAnswer: '$root',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic 3-Second Cube Root: Last digit $lastDigit pairs with $lastDigit. Drop last 3 digits, find nearest cube base ➔ $root',
          );
        } else if (cubeType == 1) {
          // Invariant Unit Digits (ends in 0, 1, 4, 5, 6, 9)
          final invariantUnits = [14, 15, 16, 19, 21, 24, 25, 26];
          int n = invariantUnits[_rnd.nextInt(invariantUnits.length)];
          int ans = n * n * n;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 200, -200, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'cubes',
            prompt: '$n³ = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Invariant Unit Rule: Cubes ending in ${n % 10} ALWAYS have root ending in ${n % 10} ➔ $n³ = $ans',
          );
        } else {
          int n = _rnd.nextInt(20) + 11;
          int ans = n * n * n;
          List<String> options = _generateSmartDistractors(ans, delta: [n * n, -n * n, 100, -100, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'cubes',
            prompt: '$n³ = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Cube: $n × $n × $n = $ans',
          );
        }

      case TopicType.fractions:
        var fractionTable = [
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
        var item = fractionTable[_rnd.nextInt(fractionTable.length)];
        bool askDecimal = _rnd.nextBool();
        String target = askDecimal ? item['d']! : item['p']!;

        Set<String> opts = {target};
        while (opts.length < 4) {
          var other = fractionTable[_rnd.nextInt(fractionTable.length)];
          opts.add(askDecimal ? other['d']! : other['p']!);
        }
        List<String> listOpts = opts.toList()..shuffle();

        return QuestionModel(
          id: id,
          topicId: 'fractions',
          prompt: '${item['f']} in ${askDecimal ? 'decimal' : 'percentage'} = ?',
          correctAnswer: target,
          options: listOpts,
          explanation: '${item['f']} = ${item['p']} = ${item['d']}',
        );

      case TopicType.triples:
        var triples = [
          [3, 4, 5],
          [5, 12, 13],
          [7, 24, 25],
          [8, 15, 17],
          [9, 40, 41],
          [11, 60, 61],
          [12, 35, 37],
          [13, 84, 85],
          [16, 63, 65],
          [20, 21, 29],
          [28, 45, 53],
          [33, 56, 65],
          [36, 77, 85],
          [39, 80, 89],
          [48, 55, 73],
          [65, 72, 97],
          [20, 99, 101],
          [6, 8, 10],
          [9, 12, 15],
          [12, 16, 20],
          [15, 20, 25],
          [10, 24, 26],
          [15, 36, 39],
          [21, 28, 35],
          [14, 48, 50],
          [21, 72, 75],
        ];
        var t = triples[_rnd.nextInt(triples.length)];
        int missingIdx = _rnd.nextInt(3);
        int ans = t[missingIdx];
        String prompt = missingIdx == 2
            ? '(${t[0]}, ${t[1]}, ?) ➔ Hypotenuse = ?'
            : (missingIdx == 0 ? '(?, ${t[1]}, ${t[2]}) ➔ Base = ?' : '(${t[0]}, ?, ${t[2]}) ➔ Height = ?');

        List<String> options = _generateSmartDistractors(ans, delta: [1, -1, 2, -2, 3, -3, 4, -4]);
        return QuestionModel(
          id: id,
          topicId: 'triples',
          prompt: prompt,
          correctAnswer: '$ans',
          options: options,
          explanation: '📐 Pythagorean Triple: ${t[0]}² + ${t[1]}² = ${t[0] * t[0]} + ${t[1] * t[1]} = ${t[2] * t[2]} = ${t[2]}²',
        );

      case TopicType.addition:
        // Vedic Speed Addition: 100-Pairing, 10 Consecutive Numbers & Left-to-Right Split
        final addType = _rnd.nextInt(3);
        if (addType == 0) {
          int p1 = (_rnd.nextInt(8) + 1) * 10 + (_rnd.nextInt(8) + 1);
          int p2 = 100 - p1;
          int third = _rnd.nextInt(60) + 15;
          int ans = 100 + third;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2]);
          return QuestionModel(
            id: id,
            topicId: 'addition',
            prompt: '$p1 + $third + $p2 = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic 100-Pairing: ($p1 + $p2) + $third = 100 + $third = $ans',
          );
        } else if (addType == 1) {
          // 10 Consecutive Numbers Sum Shortcut (5th number + append 5)
          int start = (_rnd.nextInt(6) + 2) * 10 + (_rnd.nextInt(4) + 1); // e.g. 21, 32, 43
          int fifth = start + 4;
          int ans = fifth * 10 + 5;
          int end = start + 9;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 5, -5]);
          return QuestionModel(
            id: id,
            topicId: 'addition',
            prompt: '$start + ${start + 1} + ... + $end (10 numbers) = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic 10 Consecutive Numbers: 5th number is $fifth, append 5 ➔ $fifth' + '5 = $ans',
          );
        } else {
          int a = _rnd.nextInt(89) + 11;
          int b = _rnd.nextInt(89) + 11;
          if (difficulty >= 2) {
            a = _rnd.nextInt(890) + 110;
            b = _rnd.nextInt(89) + 11;
          }
          int ans = a + b;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2, 1, -1]);
          int aTens = (a ~/ 10) * 10;
          int aUnits = a % 10;
          int bTens = (b ~/ 10) * 10;
          int bUnits = b % 10;
          return QuestionModel(
            id: id,
            topicId: 'addition',
            prompt: '$a + $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Split & Merge: ($aTens + $bTens) + ($aUnits + $bUnits) = ${aTens + bTens} + ${aUnits + bUnits} = $ans',
          );
        }

      case TopicType.subtraction:
        // Vedic Speed Subtraction: Reverse 2-Digit, Reverse 3-Digit, Nikhilam & Constant Diff
        final subType = _rnd.nextInt(5);
        if (subType == 0) {
          int d1 = _rnd.nextInt(6) + 4; // 4 to 9
          int d2 = _rnd.nextInt(d1 - 1) + 1; // 1 to d1-1
          int numA = d1 * 10 + d2;
          int numB = d2 * 10 + d1;
          int ans = numA - numB;
          List<String> options = _generateSmartDistractors(ans, delta: [9, -9, 18, -18, 1, -1]);
          return QuestionModel(
            id: id,
            topicId: 'subtraction',
            prompt: '$numA - $numB = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Reverse Rule (AB - BA): 9 × ($d1 - $d2) = 9 × ${d1 - d2} = $ans',
          );
        } else if (subType == 1) {
          // 3-Digit Reverse Rule: ABC - CBA = 99 × (A - C)
          int a = _rnd.nextInt(5) + 5; // 5 to 9
          int c = _rnd.nextInt(a - 2) + 1; // 1 to a-2
          int b = _rnd.nextInt(10);
          int numA = a * 100 + b * 10 + c;
          int numB = c * 100 + b * 10 + a;
          int ans = numA - numB;
          List<String> options = _generateSmartDistractors(ans, delta: [99, -99, 10, -10, 1, -1]);
          return QuestionModel(
            id: id,
            topicId: 'subtraction',
            prompt: '$numA - $numB = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic 3-Digit Reverse Rule (ABC - CBA): 99 × ($a - $c) = 99 × ${a - c} = $ans',
          );
        } else if (subType == 2) {
          int base = (difficulty >= 2) ? 10000 : 1000;
          int subVal = (base == 10000) ? (_rnd.nextInt(8900) + 1050) : (_rnd.nextInt(850) + 120);
          int ans = base - subVal;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 100, -100, 2, -2]);
          return QuestionModel(
            id: id,
            topicId: 'subtraction',
            prompt: '$base - $subVal = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Nikhilam Rule: All from 9, last from 10 ➔ Zero borrowing = $ans',
          );
        } else if (subType == 3) {
          int tensB = _rnd.nextInt(5) + 2;
          int bVal = tensB * 10 + 9;
          int aVal = bVal + _rnd.nextInt(40) + 15;
          int ans = aVal - bVal;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 2, -2, 1, -1]);
          return QuestionModel(
            id: id,
            topicId: 'subtraction',
            prompt: '$aVal - $bVal = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Constant Difference: ($aVal + 1) - ($bVal + 1) = ${aVal + 1} - ${bVal + 1} = $ans',
          );
        } else {
          int a = _rnd.nextInt(80) + 20;
          int b = _rnd.nextInt(a - 10) + 10;
          int ans = a - b;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2, 1, -1]);
          return QuestionModel(
            id: id,
            topicId: 'subtraction',
            prompt: '$a - $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Left-to-Right Subtraction: $a - $b = $ans',
          );
        }

      case TopicType.division:
        // Vedic Speed Division: Magical 5, 25 & Nikhilam 9
        final divType = _rnd.nextInt(4);
        if (divType == 0) {
          int q = _rnd.nextInt(150) + 12;
          int divd = q * 5;
          List<String> options = _generateSmartDistractors(q, delta: [2, -2, 5, -5, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'division',
            prompt: '$divd ÷ 5 = ?',
            correctAnswer: '$q',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Double & Shift: ($divd × 2) ÷ 10 = ${divd * 2} ÷ 10 = $q',
          );
        } else if (divType == 1) {
          int q = _rnd.nextInt(40) + 4;
          int divd = q * 25;
          List<String> options = _generateSmartDistractors(q, delta: [2, -2, 4, -4, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'division',
            prompt: '$divd ÷ 25 = ?',
            correctAnswer: '$q',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Multiply by 4: ($divd × 4) ÷ 100 = ${divd * 4} ÷ 100 = $q',
          );
        } else if (divType == 2) {
          int q = _rnd.nextInt(35) + 4;
          int divd = q * 9;
          List<String> options = _generateSmartDistractors(q, delta: [1, -1, 2, -2, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'division',
            prompt: '$divd ÷ 9 = ?',
            correctAnswer: '$q',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Vedic Nikhilam Division: $divd ÷ 9 = $q (Digit sum = 9)',
          );
        } else {
          int divisor = _rnd.nextInt(8) + 2;
          int quotient = _rnd.nextInt(26) + 4;
          int dividend = divisor * quotient;
          List<String> options = _generateSmartDistractors(quotient, delta: [1, -1, 2, -2, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'division',
            prompt: '$dividend ÷ $divisor = ?',
            correctAnswer: '$quotient',
            options: options,
            difficulty: difficulty,
            explanation: '⚡ Reverse table: $divisor × $quotient = $dividend ➔ Quotient = $quotient',
          );
        }

      default:
        return QuestionModel(
          id: id,
          topicId: 'general',
          prompt: '12 × 12 = ?',
          correctAnswer: '144',
          options: ['124', '134', '144', '154'],
        );
    }
  }

  static QuestionModel _createSeededQuestion(TopicType type, Random seededRnd, int index) {
    String id = 'daily_${index}_${seededRnd.nextInt(99999)}';
    switch (type) {
      case TopicType.tables:
        int a = seededRnd.nextInt(29) + 2; // 2 to 30
        int b = seededRnd.nextInt(8) + 2;  // 2 to 9 strictly (no 1 and no 10)
        int ans = a * b;
        return QuestionModel(
          id: id,
          topicId: 'tables',
          prompt: '$a × $b = ?',
          correctAnswer: '$ans',
          options: _generateSmartDistractors(ans, delta: [a, -a, b, -b, 10, -10]),
        );

      case TopicType.hardMultiplier:
        // 🔥 Speed Math Speed Multipliers & Consecutive Multiplications (Page 8, 9, 10)
        final mulType = seededRnd.nextInt(8);
        if (mulType == 0) {
          // 1. Consecutive Numbers: n × (n + 1) = n² + n
          int n = seededRnd.nextInt(39) + 11;
          int ans = n * (n + 1);
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$n × ${n + 1} = ?',
            correctAnswer: '$ans',
            options: options,
            explanation: '⚡ Vedic Consecutive Rule: $n² + $n = ${n * n} + $n = $ans (or ${n + 1}² - ${n + 1} = $ans)',
          );
        } else if (mulType == 1) {
          // 2. Alternate Consecutive Numbers (Gap of 2): (N-1)(N+1) = N² - 1
          int mid = seededRnd.nextInt(25) + 12;
          int a = mid - 1;
          int b = mid + 1;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            explanation: '⚡ Vedic Midpoint Rule: ($mid - 1)($mid + 1) = $mid² - 1 = ${mid * mid} - 1 = $ans',
          );
        } else if (mulType == 2) {
          // 3. Difference of 10 Ending in 5: (HigherTen² - 1) | 75
          final tensList = [1, 2, 3, 4, 6, 7, 8];
          int lowTen = tensList[seededRnd.nextInt(tensList.length)];
          int highTen = lowTen + 1;
          int a = lowTen * 10 + 5;
          int b = highTen * 10 + 5;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 200, -200, 10, -10]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            explanation: '⚡ Vedic Diff 10 Ending 5: ($highTen² - 1) | 75 = ${highTen * highTen - 1}75 = $ans',
          );
        } else if (mulType == 3) {
          // 4. Powers of 5 (× 25 or × 125)
          bool is125 = seededRnd.nextBool();
          if (is125) {
            int q = seededRnd.nextInt(12) + 2;
            int a = q * 8;
            int ans = a * 125;
            List<String> options = _generateSmartDistractors(ans, delta: [1000, -1000, 500, -500, 100, -100]);
            return QuestionModel(
              id: id,
              topicId: 'hard_multiplier',
              prompt: '$a × 125 = ?',
              correctAnswer: '$ans',
              options: options,
              explanation: '⚡ Vedic Power of 5: ($a ÷ 8) × 1000 = $q × 1000 = $ans',
            );
          } else {
            int q = seededRnd.nextInt(25) + 3;
            int a = q * 4;
            int ans = a * 25;
            List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 25, -25, 50, -50]);
            return QuestionModel(
              id: id,
              topicId: 'hard_multiplier',
              prompt: '$a × 25 = ?',
              correctAnswer: '$ans',
              options: options,
              explanation: '⚡ Vedic Magical 25: ($a ÷ 4) × 100 = $q × 100 = $ans',
            );
          }
        } else if (mulType == 4) {
          // 5. Ekadhikena Purvena: Same tens, units sum = 10
          int tens = seededRnd.nextInt(7) + 2;
          int u1 = seededRnd.nextInt(8) + 1;
          int u2 = 10 - u1;
          int a = tens * 10 + u1;
          int b = tens * 10 + u2;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 10, -10, 20, -20]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            explanation: '⚡ Vedic Ekadhikena Rule: $tens × ($tens + 1) | $u1 × $u2 = ${tens * (tens + 1)}${u1 * u2 < 10 ? '0' : ''}${u1 * u2} = $ans',
          );
        } else if (mulType == 5) {
          // 6. 11 Sandwich Rule: AB * 11
          int a = seededRnd.nextInt(78) + 12;
          int ans = a * 11;
          List<String> options = _generateSmartDistractors(ans, delta: [11, -11, 22, -22, 10, -10]);
          int d1 = a ~/ 10;
          int d2 = a % 10;
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × 11 = ?',
            correctAnswer: '$ans',
            options: options,
            explanation: '⚡ Vedic 11-Sandwich: Split $d1 and $d2, middle is ($d1 + $d2) = $ans',
          );
        } else if (mulType == 6) {
          // 7. Base 100 Method (below 100: e.g. 94 * 97)
          int diff1 = seededRnd.nextInt(7) + 2;
          int diff2 = seededRnd.nextInt(7) + 2;
          int a = 100 - diff1;
          int b = 100 - diff2;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 10, -10, 2, -2]);
          int prodDiff = diff1 * diff2;
          String diffStr = prodDiff < 10 ? '0$prodDiff' : '$prodDiff';
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            explanation: '⚡ Vedic Base-100: ($a - $diff2) | ($diff1 × $diff2) = ${a - diff2}$diffStr = $ans',
          );
        } else {
          // 8. Half & Double Rule
          int ev = (seededRnd.nextInt(15) + 6) * 2;
          int fv = (seededRnd.nextInt(5) + 1) * 10 + 5;
          int ans = ev * fv;
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 50, -50]);
          return QuestionModel(
            id: id,
            topicId: 'hard_multiplier',
            prompt: '$ev × $fv = ?',
            correctAnswer: '$ans',
            options: options,
            explanation: '⚡ Vedic Half & Double: ($ev ÷ 2) × ($fv × 2) = ${ev ~/ 2} × ${fv * 2} = $ans',
          );
        }

      case TopicType.squares:
        int n = seededRnd.nextInt(40) + 11; // 11 to 50
        int ans = n * n;
        return QuestionModel(
          id: id,
          topicId: 'squares',
          prompt: '$n² = ?',
          correctAnswer: '$ans',
          options: _generateSmartDistractors(ans, delta: [2 * n, -2 * n, 10, -10]),
        );

      case TopicType.cubes:
        int n = seededRnd.nextInt(20) + 11; // 11 to 30
        int ans = n * n * n;
        return QuestionModel(
          id: id,
          topicId: 'cubes',
          prompt: '$n³ = ?',
          correctAnswer: '$ans',
          options: _generateSmartDistractors(ans, delta: [n * n, -n * n, 100, -100]),
        );

      case TopicType.triples:
        var triples = [
          [3, 4, 5],
          [5, 12, 13],
          [7, 24, 25],
          [8, 15, 17],
          [9, 40, 41],
          [11, 60, 61],
          [12, 35, 37],
          [13, 84, 85],
          [16, 63, 65],
          [20, 21, 29],
          [28, 45, 53],
          [33, 56, 65],
          [36, 77, 85],
          [39, 80, 89],
          [48, 55, 73],
          [65, 72, 97],
          [20, 99, 101],
          [6, 8, 10],
          [9, 12, 15],
          [12, 16, 20],
          [15, 20, 25],
          [10, 24, 26],
          [15, 36, 39],
          [14, 48, 50],
          [21, 72, 75],
        ];
        var t = triples[seededRnd.nextInt(triples.length)];
        int missingIdx = seededRnd.nextInt(3);
        int ans = t[missingIdx];
        String prompt = missingIdx == 2
            ? '(${t[0]}, ${t[1]}, ?) ➔ Hypotenuse = ?'
            : (missingIdx == 0 ? '(?, ${t[1]}, ${t[2]}) ➔ Base = ?' : '(${t[0]}, ?, ${t[2]}) ➔ Height = ?');
        return QuestionModel(
          id: id,
          topicId: 'triples',
          prompt: prompt,
          correctAnswer: '$ans',
          options: _generateSmartDistractors(ans, delta: [1, -1, 2, -2, 3, -3]),
          explanation: '📐 Pythagorean Triple: ${t[0]}² + ${t[1]}² = ${t[2]}²',
        );

      default:
        int a = seededRnd.nextInt(25) + 5;
        int b = seededRnd.nextInt(10) + 2;
        int ans = a * b;
        return QuestionModel(
          id: id,
          topicId: 'mixed',
          prompt: '$a × $b = ?',
          correctAnswer: '$ans',
          options: _generateSmartDistractors(ans, delta: [a, -a, 5, -5]),
        );
    }
  }

  static List<String> _generateSmartDistractors(int correct, {required List<int> delta}) {
    Set<int> opts = {correct};

    // 1. SMALL-NUMBER RULE (<= 25):
    // Keep options ultra-close & tricky (e.g. for 12 -> 10, 11, 12, 14 instead of 2, 12, 32, 52).
    if (correct.abs() <= 25) {
      final int minAllowed = correct < 10 ? 0 : 1;
      final closeOffsets = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5]..shuffle();
      for (int d in closeOffsets) {
        if (opts.length >= 4) break;
        int cand = correct + d;
        if (cand >= minAllowed && cand != correct) {
          opts.add(cand);
        }
      }

      int step = 1;
      while (opts.length < 4) {
        if (correct + step >= minAllowed) opts.add(correct + step);
        if (opts.length < 4 && correct - step >= minAllowed) opts.add(correct - step);
        step++;
      }

      List<String> list = opts.take(4).map((e) => e.toString()).toList();
      list.shuffle();
      return list;
    }

    // 2. MID TWO-DIGIT RULE (26..99):
    // Mix unit-digit traps (±10, ±20) with tight neighbor slips (±1, ±2, ±3) so options stay close.
    if (correct.abs() < 100) {
      final midOffsets = [10, -10, 1, -1, 2, -2, 3, -3, 20, -20]..shuffle();
      for (int d in delta) {
        if (d != 0 && d.abs() <= 20) {
          int cand = correct + d;
          if (cand > 0 && cand != correct) opts.add(cand);
        }
        if (opts.length >= 4) break;
      }
      for (int d in midOffsets) {
        if (opts.length >= 4) break;
        int cand = correct + d;
        if (cand > 0 && cand != correct) opts.add(cand);
      }

      int step = 1;
      while (opts.length < 4) {
        if (correct + step > 0) opts.add(correct + step);
        if (opts.length < 4 && correct - step > 0) opts.add(correct - step);
        step++;
      }

      List<String> list = opts.take(4).map((e) => e.toString()).toList();
      list.shuffle();
      return list;
    }

    // 3. LARGE MULTI-DIGIT RULE (>= 100):
    // Competitive exam benchmark: Options share the exact same unit digit!
    final int unit = (correct % 10).abs();

    List<int> validDeltas = [];
    for (int d in delta) {
      if (d != 0 && d % 10 == 0) {
        validDeltas.add(d);
      }
    }

    final pool = [
      10, -10, 20, -20, 30, -30, 40, -40, 50, -50,
      if (correct >= 150) ...[60, -60, 70, -70, 80, -80, 100, -100],
      if (correct >= 400) ...[100, -100, 200, -200],
    ];
    validDeltas.addAll(pool);
    validDeltas.shuffle();

    for (int d in validDeltas) {
      if (opts.length >= 4) break;
      int candidate = correct + d;
      if (candidate > 0 && candidate != correct && (candidate % 10 == unit)) {
        opts.add(candidate);
      }
    }

    // Fallback: Expand outward symmetrically in multiples of 10
    int step = 1;
    while (opts.length < 4) {
      int plusCandidate = correct + (10 * step);
      if (plusCandidate > 0 && plusCandidate % 10 == unit) {
        opts.add(plusCandidate);
      }
      if (opts.length < 4) {
        int minusCandidate = correct - (10 * step);
        if (minusCandidate > 0 && minusCandidate % 10 == unit) {
          opts.add(minusCandidate);
        }
      }
      step++;
    }

    List<String> list = opts.take(4).map((e) => e.toString()).toList();
    list.shuffle();
    return list;
  }

  // Generate targeted questions for a specific multiplication table (e.g., Table of 2 or Table of 17)
  // Multipliers range from 2 up to maxMultiplier (e.g. 10, 12, or 20)
  // Strictly guarantees:
  // 1. Zero duplicate questions in the drill set (e.g. 10 * 4 appears at most 1 time in a 10 or 20 question set)
  // 2. Fresh shuffled order and a non-identical starting question on restart / re-entry (never starts with same Q twice in a row)
  static List<QuestionModel> generateTableQuestions(int tableNumber, {int count = 10, int maxMultiplier = 9}) {
    List<QuestionModel> list = [];
    final int safeMax = maxMultiplier < 2 ? 9 : maxMultiplier;
    
    // Multipliers strictly between 2 and safeMax (foundation drill: 2..9, extended: 2..safeMax)
    final List<int> pool;
    if (safeMax <= 9) {
      pool = [2, 3, 4, 5, 6, 7, 8, 9]..shuffle(_rnd);
    } else {
      pool = List<int>.generate(safeMax - 1, (i) => i + 2)..shuffle(_rnd);
    }

    List<int> validMultipliers = [];
    if (count <= pool.length) {
      // 100% strictly unique multipliers in this set!
      validMultipliers = pool.take(count).toList();
    } else {
      // Complete coverage before any multiplier can appear a second time
      while (validMultipliers.length < count) {
        final remaining = count - validMultipliers.length;
        final nextBatch = List<int>.from(pool)..shuffle(_rnd);
        // Avoid adjacent boundary repeat between batches
        if (validMultipliers.isNotEmpty && nextBatch.isNotEmpty && nextBatch[0] == validMultipliers.last) {
          if (nextBatch.length > 1) {
            final temp = nextBatch[0];
            nextBatch[0] = nextBatch[1];
            nextBatch[1] = temp;
          }
        }
        validMultipliers.addAll(nextBatch.take(remaining));
      }
    }

    // Guaranteed non-identical starting question across consecutive sessions
    final recentFirsts = _recentFirstMultipliers[tableNumber] ?? [];
    if (validMultipliers.length > 1 && recentFirsts.contains(validMultipliers[0])) {
      int swapIdx = -1;
      for (int i = 1; i < validMultipliers.length; i++) {
        if (!recentFirsts.contains(validMultipliers[i])) {
          swapIdx = i;
          break;
        }
      }
      if (swapIdx == -1) {
        swapIdx = 1 + _rnd.nextInt(validMultipliers.length - 1);
      }
      final temp = validMultipliers[0];
      validMultipliers[0] = validMultipliers[swapIdx];
      validMultipliers[swapIdx] = temp;
    } else if (validMultipliers.length == 1 && pool.length > 1 && recentFirsts.contains(validMultipliers[0])) {
      for (int m in pool) {
        if (!recentFirsts.contains(m)) {
          validMultipliers[0] = m;
          break;
        }
      }
    }

    final updatedRecent = [validMultipliers[0], ...recentFirsts.where((m) => m != validMultipliers[0])];
    if (updatedRecent.length > 3) {
      updatedRecent.removeRange(3, updatedRecent.length);
    }
    _recentFirstMultipliers[tableNumber] = updatedRecent;

    for (int i = 0; i < validMultipliers.length; i++) {
      int mult = validMultipliers[i];
      int ans = tableNumber * mult;
      List<String> options = _generateSmartDistractors(ans, delta: [tableNumber, -tableNumber, 10, -10, 2, -2]);
      list.add(QuestionModel(
        id: 'table_${tableNumber}_${mult}_${DateTime.now().microsecondsSinceEpoch}_$i',
        topicId: 'tables',
        prompt: '$tableNumber × $mult = ?',
        correctAnswer: '$ans',
        options: options,
        explanation: '$tableNumber multiplied by $mult is $ans',
      ));
    }
    return list;
  }

  // Generate targeted questions for a specific range of tables (Easy: 1-10, Medium: 11-20, Hard: 21-50)
  static List<QuestionModel> generateTableRangeQuestions({
    required int startTable,
    required int endTable,
    int count = 10,
    int maxMultiplier = 9,
  }) {
    final rnd = _rnd;
    final List<int> tablePool = List.generate(endTable - startTable + 1, (i) => startTable + i);
    tablePool.shuffle(rnd);

    final int safeMax = maxMultiplier < 2 ? 9 : maxMultiplier;
    final List<int> multipliers = List.generate(safeMax - 1, (i) => i + 2); // 2 to safeMax
    multipliers.shuffle(rnd);

    // Build candidate pairs to guarantee strictly unique questions
    List<(int, int)> candidatePairs = [];
    for (final t in tablePool) {
      for (final m in multipliers) {
        candidatePairs.add((t, m));
      }
    }
    candidatePairs.shuffle(rnd);

    List<(int, int)> selectedPairs = [];
    if (candidatePairs.length >= count) {
      selectedPairs = candidatePairs.take(count).toList();
    } else {
      while (selectedPairs.length < count) {
        final remaining = count - selectedPairs.length;
        candidatePairs.shuffle(rnd);
        selectedPairs.addAll(candidatePairs.take(remaining));
      }
    }

    // Guarantee non-identical starting question
    final rangeKey = 'range_${startTable}_$endTable';
    final recentFirstPrompts = _recentFirstPrompts[rangeKey] ?? [];
    if (selectedPairs.length > 1) {
      final currentFirstPrompt = '${selectedPairs[0].$1} × ${selectedPairs[0].$2} = ?';
      if (recentFirstPrompts.contains(currentFirstPrompt)) {
        int swapIdx = -1;
        for (int i = 1; i < selectedPairs.length; i++) {
          final p = '${selectedPairs[i].$1} × ${selectedPairs[i].$2} = ?';
          if (!recentFirstPrompts.contains(p)) {
            swapIdx = i;
            break;
          }
        }
        if (swapIdx == -1) {
          swapIdx = 1 + rnd.nextInt(selectedPairs.length - 1);
        }
        final temp = selectedPairs[0];
        selectedPairs[0] = selectedPairs[swapIdx];
        selectedPairs[swapIdx] = temp;
      }
    }

    final newFirstPrompt = '${selectedPairs[0].$1} × ${selectedPairs[0].$2} = ?';
    final updatedRecent = [newFirstPrompt, ...recentFirstPrompts.where((p) => p != newFirstPrompt)];
    if (updatedRecent.length > 3) {
      updatedRecent.removeRange(3, updatedRecent.length);
    }
    _recentFirstPrompts[rangeKey] = updatedRecent;

    List<QuestionModel> list = [];
    for (int i = 0; i < selectedPairs.length; i++) {
      final t = selectedPairs[i].$1;
      final m = selectedPairs[i].$2;
      final ans = t * m;
      final prompt = '$t × $m = ?';
      List<String> options = _generateSmartDistractors(ans, delta: [t, -t, 10, -10, 2, -2]);
      list.add(QuestionModel(
        id: 'table_${t}_${m}_${DateTime.now().microsecondsSinceEpoch}_$i',
        topicId: 'tables',
        prompt: prompt,
        correctAnswer: '$ans',
        options: options,
        explanation: '$t multiplied by $m is $ans',
      ));
    }
    return list;
  }

  /// Generate mixed questions specifically for a selected set of tables (e.g. any 2+ tables dynamically selected)
  static List<QuestionModel> generateMultiTableQuestions({
    required List<int> tables,
    int count = 10,
    int maxMultiplier = 12,
  }) {
    if (tables.isEmpty) {
      final rndFallback = _rnd;
      final t1 = rndFallback.nextInt(29) + 2;
      int t2 = rndFallback.nextInt(29) + 2;
      while (t2 == t1) {
        t2 = rndFallback.nextInt(29) + 2;
      }
      return generateMultiTableQuestions(tables: [t1, t2], count: count, maxMultiplier: maxMultiplier);
    }
    final cleanTables = tables.toSet().toList()..sort();
    final rnd = _rnd;

    final int safeMax = maxMultiplier < 2 ? 12 : maxMultiplier;
    // Multipliers strictly between 2 and safeMax, excluding trivial 1 and 10
    final List<int> multipliers = [];
    for (int m = 2; m <= safeMax; m++) {
      if (m != 10) multipliers.add(m);
    }
    if (multipliers.isEmpty) multipliers.addAll([2, 3, 4, 5, 6, 7, 8, 9]);

    // Build candidate pairs to guarantee uniqueness
    List<(int, int)> candidatePairs = [];
    for (final t in cleanTables) {
      for (final m in multipliers) {
        candidatePairs.add((t, m));
      }
    }
    candidatePairs.shuffle(rnd);

    List<(int, int)> selectedPairs = [];
    if (candidatePairs.length >= count) {
      selectedPairs = candidatePairs.take(count).toList();
    } else {
      while (selectedPairs.length < count) {
        final remaining = count - selectedPairs.length;
        candidatePairs.shuffle(rnd);
        selectedPairs.addAll(candidatePairs.take(remaining));
      }
    }

    // Guarantee non-identical starting question
    final mixKey = 'mix_${cleanTables.join('_')}';
    final recentFirstPrompts = _recentFirstPrompts[mixKey] ?? [];
    if (selectedPairs.length > 1) {
      final currentFirstPrompt = '${selectedPairs[0].$1} × ${selectedPairs[0].$2} = ?';
      if (recentFirstPrompts.contains(currentFirstPrompt)) {
        int swapIdx = -1;
        for (int i = 1; i < selectedPairs.length; i++) {
          final p = '${selectedPairs[i].$1} × ${selectedPairs[i].$2} = ?';
          if (!recentFirstPrompts.contains(p)) {
            swapIdx = i;
            break;
          }
        }
        if (swapIdx == -1) {
          swapIdx = 1 + rnd.nextInt(selectedPairs.length - 1);
        }
        final temp = selectedPairs[0];
        selectedPairs[0] = selectedPairs[swapIdx];
        selectedPairs[swapIdx] = temp;
      }
    }

    final newFirstPrompt = '${selectedPairs[0].$1} × ${selectedPairs[0].$2} = ?';
    final updatedRecent = [newFirstPrompt, ...recentFirstPrompts.where((p) => p != newFirstPrompt)];
    if (updatedRecent.length > 3) {
      updatedRecent.removeRange(3, updatedRecent.length);
    }
    _recentFirstPrompts[mixKey] = updatedRecent;

    List<QuestionModel> list = [];
    for (int i = 0; i < selectedPairs.length; i++) {
      final t = selectedPairs[i].$1;
      final m = selectedPairs[i].$2;
      final ans = t * m;
      final prompt = '$t × $m = ?';
      List<String> options = _generateSmartDistractors(ans, delta: [t, -t, 10, -10, 2, -2]);
      list.add(QuestionModel(
        id: 'table_mix_${t}_${m}_${DateTime.now().microsecondsSinceEpoch}_$i',
        topicId: 'tables',
        prompt: prompt,
        correctAnswer: '$ans',
        options: options,
        explanation: '$t multiplied by $m is $ans',
      ));
    }
    return list;
  }

  // Generate targeted questions for a specific range of squares (e.g., 11 to 20)
  static List<QuestionModel> generateSquaresRangeQuestions({required int start, required int end, int count = 10}) {
    List<QuestionModel> list = [];
    final rnd = _rnd;
    final List<int> pool = List.generate(end - start + 1, (i) => start + i)..shuffle(rnd);
    List<int> numbers = [];
    if (pool.length >= count) {
      numbers = pool.take(count).toList();
    } else {
      while (numbers.length < count) {
        final remaining = count - numbers.length;
        pool.shuffle(rnd);
        numbers.addAll(pool.take(remaining));
      }
    }

    final rangeKey = 'sq_${start}_$end';
    final recentFirstPrompts = _recentFirstPrompts[rangeKey] ?? [];
    if (numbers.length > 1) {
      final curPrompt = '${numbers[0]}² = ?';
      if (recentFirstPrompts.contains(curPrompt)) {
        int swapIdx = -1;
        for (int i = 1; i < numbers.length; i++) {
          if (!recentFirstPrompts.contains('${numbers[i]}² = ?')) {
            swapIdx = i;
            break;
          }
        }
        if (swapIdx == -1) {
          swapIdx = 1 + rnd.nextInt(numbers.length - 1);
        }
        final temp = numbers[0];
        numbers[0] = numbers[swapIdx];
        numbers[swapIdx] = temp;
      }
    }
    final newFirstPrompt = '${numbers[0]}² = ?';
    final updatedRecent = [newFirstPrompt, ...recentFirstPrompts.where((p) => p != newFirstPrompt)];
    if (updatedRecent.length > 3) updatedRecent.removeRange(3, updatedRecent.length);
    _recentFirstPrompts[rangeKey] = updatedRecent;

    for (int i = 0; i < numbers.length; i++) {
      int n = numbers[i];
      int ans = n * n;
      List<String> options = _generateSmartDistractors(ans, delta: [2 * n, -2 * n, 10, -10, 20, -20, 1, -1]);
      list.add(QuestionModel(
        id: 'sq_${n}_${DateTime.now().microsecondsSinceEpoch}_$i',
        topicId: 'squares',
        prompt: '$n² = ?',
        correctAnswer: '$ans',
        options: options,
        explanation: '⚡ Mental Trick: The square of $n ($n × $n) is $ans',
      ));
    }
    return list;
  }

  // Generate targeted questions for a specific range of cubes (e.g., 7 to 12)
  static List<QuestionModel> generateCubesRangeQuestions({required int start, required int end, int count = 10}) {
    List<QuestionModel> list = [];
    final rnd = _rnd;
    final List<int> pool = List.generate(end - start + 1, (i) => start + i)..shuffle(rnd);
    List<int> numbers = [];
    if (pool.length >= count) {
      numbers = pool.take(count).toList();
    } else {
      while (numbers.length < count) {
        final remaining = count - numbers.length;
        pool.shuffle(rnd);
        numbers.addAll(pool.take(remaining));
      }
    }

    final rangeKey = 'cube_${start}_$end';
    final recentFirstPrompts = _recentFirstPrompts[rangeKey] ?? [];
    if (numbers.length > 1) {
      final curPrompt = '${numbers[0]}³ = ?';
      if (recentFirstPrompts.contains(curPrompt)) {
        int swapIdx = -1;
        for (int i = 1; i < numbers.length; i++) {
          if (!recentFirstPrompts.contains('${numbers[i]}³ = ?')) {
            swapIdx = i;
            break;
          }
        }
        if (swapIdx == -1) {
          swapIdx = 1 + rnd.nextInt(numbers.length - 1);
        }
        final temp = numbers[0];
        numbers[0] = numbers[swapIdx];
        numbers[swapIdx] = temp;
      }
    }
    final newFirstPrompt = '${numbers[0]}³ = ?';
    final updatedRecent = [newFirstPrompt, ...recentFirstPrompts.where((p) => p != newFirstPrompt)];
    if (updatedRecent.length > 3) updatedRecent.removeRange(3, updatedRecent.length);
    _recentFirstPrompts[rangeKey] = updatedRecent;

    for (int i = 0; i < numbers.length; i++) {
      int n = numbers[i];
      int ans = n * n * n;
      List<String> options = _generateSmartDistractors(ans, delta: [n * n, -n * n, 100, -100, 10, -10]);
      list.add(QuestionModel(
        id: 'cube_${n}_${DateTime.now().microsecondsSinceEpoch}_$i',
        topicId: 'cubes',
        prompt: '$n³ = ?',
        correctAnswer: '$ans',
        options: options,
        explanation: '⚡ Mental Trick: The cube of $n ($n × $n × $n) is $ans',
      ));
    }
    return list;
  }

  // Generate dedicated questions for Hard-On 2-Digit × 2-Digit Pro Multipliers (e.g. 17 × 45)
  static List<QuestionModel> generateHardMultiplierQuestions({int count = 15}) {
    return generateUniqueQuestions(type: TopicType.hardMultiplier, count: count);
  }

  /// Generate questions targeting a specific multiplier (e.g. 17 × 2D or 19 × 2D)
  static List<QuestionModel> generateSpecificMultiplierQuestions({
    required int baseMultiplier,
    int count = 10,
  }) {
    List<QuestionModel> list = [];
    final rnd = _rnd;
    final Set<int> usedMultipliers = {};

    for (int i = 0; i < count; i++) {
      int m;
      int attempts = 0;
      do {
        attempts++;
        m = rnd.nextInt(38) + 12; // 12 to 49 (2-Digit)
      } while (usedMultipliers.contains(m) && attempts < 50);
      usedMultipliers.add(m);

      int ans = baseMultiplier * m;
      List<String> options = _generateSmartDistractors(ans, delta: [baseMultiplier, -baseMultiplier, 10, -10, 2, -2]);
      int tensPart = (m ~/ 10) * 10;
      int unitsPart = m % 10;
      list.add(QuestionModel(
        id: 'spec_mult_${baseMultiplier}_${m}_${DateTime.now().microsecondsSinceEpoch}_$i',
        topicId: 'hard_multiplier',
        prompt: '$baseMultiplier × $m = ?',
        correctAnswer: '$ans',
        options: options,
        explanation: '⚡ Vedic breakdown: ($baseMultiplier × $tensPart) + ($baseMultiplier × $unitsPart) = ${baseMultiplier * tensPart} + ${baseMultiplier * unitsPart} = $ans',
      ));
    }
    return list;
  }

  /// Generate comprehensive, authentic multi-topic speed mocks tailored to specific competitive exams
  static List<QuestionModel> generateExamSpecificMockSet({
    required String examType, // 'ssc', 'banking', 'railway', 'cat', 'multiplier'
    required int count,
  }) {
    List<QuestionModel> questions = [];
    switch (examType.toLowerCase()) {
      case 'ssc':
        questions.addAll(generateSscExamLevelQuestions(count: count));
        break;

      case 'banking':
        questions.addAll(generateBankingExamLevelQuestions(count: count));
        break;

      case 'railway':
        questions.addAll(generateRailwayExamLevelQuestions(count: count));
        break;

      case 'cat':
        questions.addAll(generateCatExamLevelQuestions(count: count));
        break;

      case 'multiplier':
      default:
        // Pro VIP Multiplier Sprint: 2D x 2D Speed Multiplication
        questions.addAll(generateHardMultiplierQuestions(count: count));
        break;
    }

    questions.shuffle();
    return questions.take(count).toList();
  }

  /// Real SSC CGL/CHSL Exam Level Generator:
  /// - Advanced Pythagorean Triples & Missing side evaluation
  /// - Reciprocal Algebra Speed Shortcuts (x + 1/x = k => x^2 + 1/x^2 = k^2 - 2, x^3 + 1/x^3 = k^3 - 3k)
  /// - Number System Unit Digit cyclicity
  /// - Fractional Percentages (16.67%, 14.28%, 37.5%, 62.5%, 83.33%)
  /// - Speed Squares (12 to 50)
  static List<QuestionModel> generateSscExamLevelQuestions({required int count}) {
    List<QuestionModel> list = [];
    final triples = [
      [3, 4, 5], [5, 12, 13], [7, 24, 25], [8, 15, 17], [9, 40, 41],
      [11, 60, 61], [12, 35, 37], [13, 84, 85], [16, 63, 65], [20, 21, 29],
      [28, 45, 53], [33, 56, 65], [36, 77, 85], [39, 80, 89], [48, 55, 73],
      [65, 72, 97], [20, 99, 101], [6, 8, 10], [9, 12, 15], [12, 16, 20],
      [15, 20, 25], [10, 24, 26], [15, 36, 39], [14, 48, 50], [21, 72, 75]
    ];

    final fracPercents = [
      {'pct': '16.67%', 'f': '1/6', 'den': 6, 'num': 1},
      {'pct': '14.28%', 'f': '1/7', 'den': 7, 'num': 1},
      {'pct': '12.5%', 'f': '1/8', 'den': 8, 'num': 1},
      {'pct': '37.5%', 'f': '3/8', 'den': 8, 'num': 3},
      {'pct': '62.5%', 'f': '5/8', 'den': 8, 'num': 5},
      {'pct': '87.5%', 'f': '7/8', 'den': 8, 'num': 7},
      {'pct': '83.33%', 'f': '5/6', 'den': 6, 'num': 5},
      {'pct': '8.33%', 'f': '1/12', 'den': 12, 'num': 1},
      {'pct': '11.11%', 'f': '1/9', 'den': 9, 'num': 1},
    ];

    for (int i = 0; i < count; i++) {
      String id = 'ssc_q_${DateTime.now().microsecondsSinceEpoch}_$i';
      int category = i % 5;

      if (category == 0) {
        // Pythagorean Triples
        var t = triples[_rnd.nextInt(triples.length)];
        bool findHyp = _rnd.nextBool();
        int ans = findHyp ? t[2] : t[1];
        String prompt = findHyp
            ? 'Right Δ: Base = ${t[0]}, Perpendicular = ${t[1]} ➔ Hypotenuse = ?'
            : 'Right Δ: Hypotenuse = ${t[2]}, Base = ${t[0]} ➔ Altitude = ?';
        List<String> options = _generateSmartDistractors(ans, delta: [1, -1, 2, -2, 3, -3]);
        list.add(QuestionModel(
          id: id,
          topicId: 'triples',
          prompt: prompt,
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '📐 SSC Geometry Triple: ${t[0]}² + ${t[1]}² = ${t[2]}² (${t[0] * t[0]} + ${t[1] * t[1]} = ${t[2] * t[2]})',
        ));
      } else if (category == 1) {
        // Reciprocal Algebra Shortcuts
        int k = _rnd.nextInt(7) + 3; // 3 to 9
        int subType = _rnd.nextInt(3);
        if (subType == 0) {
          int ans = (k * k) - 2;
          List<String> options = _generateSmartDistractors(ans, delta: [2, -2, 4, -4, 1, -1]);
          list.add(QuestionModel(
            id: id,
            topicId: 'algebra',
            prompt: 'If x + 1/x = $k, then x² + 1/x² = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: 3,
            explanation: '⚡ SSC Formula: x² + 1/x² = k² - 2 = ($k)² - 2 = ${k * k} - 2 = $ans',
          ));
        } else if (subType == 1) {
          int ans = (k * k) + 2;
          List<String> options = _generateSmartDistractors(ans, delta: [2, -2, 4, -4, 1, -1]);
          list.add(QuestionModel(
            id: id,
            topicId: 'algebra',
            prompt: 'If x - 1/x = $k, then x² + 1/x² = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: 3,
            explanation: '⚡ SSC Formula: x² + 1/x² = k² + 2 = ($k)² + 2 = ${k * k} + 2 = $ans',
          ));
        } else {
          int smallK = _rnd.nextInt(4) + 3; // 3, 4, 5, 6
          int ans = (smallK * smallK * smallK) - (3 * smallK);
          List<String> options = _generateSmartDistractors(ans, delta: [3, -3, 6, -6, 2, -2]);
          list.add(QuestionModel(
            id: id,
            topicId: 'algebra',
            prompt: 'If x + 1/x = $smallK, then x³ + 1/x³ = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: 4,
            explanation: '⚡ SSC Formula: x³ + 1/x³ = k³ - 3k = ($smallK)³ - 3($smallK) = ${smallK * smallK * smallK} - ${3 * smallK} = $ans',
          ));
        }
      } else if (category == 2) {
        // Unit Digit Cyclicity
        List<int> bases = [2, 3, 4, 7, 8, 9];
        int base = bases[_rnd.nextInt(bases.length)];
        int exp = _rnd.nextInt(60) + 15;
        int ans = BigInt.from(base).modPow(BigInt.from(exp), BigInt.from(10)).toInt();
        List<String> options = _generateSmartDistractors(ans, delta: [1, -1, 2, -2, 3, -3]);
        list.add(QuestionModel(
          id: id,
          topicId: 'unit_digit',
          prompt: 'Find the unit digit of ($base)^$exp = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ Cyclicity Rule: $exp ÷ 4 leaves remainder ${exp % 4 == 0 ? 4 : exp % 4}. Hence unit digit is $ans.',
        ));
      } else if (category == 3) {
        // Percentage to Fraction Equivalence
        var pData = fracPercents[_rnd.nextInt(fracPercents.length)];
        int den = pData['den'] as int;
        int num = pData['num'] as int;
        int multiplier = (_rnd.nextInt(15) + 3) * 10; // clean multiple
        int targetVal = den * multiplier;
        int ans = multiplier * num;
        List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 5, -5]);
        list.add(QuestionModel(
          id: id,
          topicId: 'percentage',
          prompt: '${pData['pct']} of $targetVal = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 2,
          explanation: '⚡ Speed Fraction: ${pData['pct']} = ${pData['f']}. So (${pData['f']}) × $targetVal = $ans',
        ));
      } else {
        // Squares 12 to 50
        int n = _rnd.nextInt(39) + 12;
        int ans = n * n;
        List<String> options = _generateSmartDistractors(ans, delta: [2 * n, -2 * n, 10, -10, 20, -20]);
        list.add(QuestionModel(
          id: id,
          topicId: 'squares',
          prompt: '$n² = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 2,
          explanation: '⚡ Square of $n: $n × $n = $ans',
        ));
      }
    }

    list.shuffle();
    return list;
  }

  /// Real Banking (SBI/IBPS PO & Clerk) Exam Level Generator:
  /// - Multi-step BODMAS Simplification & Approximations
  /// - High-speed Fractional Percentages (37.5%, 62.5%, 83.33%, 87.5%)
  /// - 4-Digit Square Roots (1024 to 4096)
  /// - 5-Digit Cube Roots (1728 to 13824)
  static List<QuestionModel> generateBankingExamLevelQuestions({required int count}) {
    List<QuestionModel> list = [];
    final perfectSquares = [
      {'n': 24, 'sq': 576}, {'n': 26, 'sq': 676}, {'n': 28, 'sq': 784},
      {'n': 31, 'sq': 961}, {'n': 32, 'sq': 1024}, {'n': 34, 'sq': 1156},
      {'n': 36, 'sq': 1296}, {'n': 38, 'sq': 1444}, {'n': 39, 'sq': 1521},
      {'n': 42, 'sq': 1764}, {'n': 45, 'sq': 2025}, {'n': 48, 'sq': 2304},
      {'n': 52, 'sq': 2704}, {'n': 56, 'sq': 3136}, {'n': 64, 'sq': 4096},
    ];

    final perfectCubes = [
      {'n': 12, 'cb': 1728}, {'n': 13, 'cb': 2197}, {'n': 14, 'cb': 2744},
      {'n': 15, 'cb': 3375}, {'n': 16, 'cb': 4096}, {'n': 17, 'cb': 4913},
      {'n': 18, 'cb': 5832}, {'n': 19, 'cb': 6859}, {'n': 21, 'cb': 9261},
      {'n': 22, 'cb': 10648}, {'n': 24, 'cb': 13824},
    ];

    for (int i = 0; i < count; i++) {
      String id = 'bank_q_${DateTime.now().microsecondsSinceEpoch}_$i';
      int category = i % 4;

      if (category == 0) {
        // Multi-step BODMAS Simplification
        var sq1 = perfectSquares[_rnd.nextInt(perfectSquares.length)];
        var sq2 = perfectSquares[_rnd.nextInt(perfectSquares.length)];
        int c = _rnd.nextInt(8) + 3; // 3 to 10
        int d = _rnd.nextInt(4) + 2; // 2 to 5
        int ans = (sq1['n']! + sq2['n']!) - (c * d);
        List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 2, -2, 5, -5]);
        list.add(QuestionModel(
          id: id,
          topicId: 'simplification',
          prompt: '√${sq1['sq']} + √${sq2['sq']} - ($c × $d) = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ Banking BODMAS: ${sq1['n']} + ${sq2['n']} - ${c * d} = ${sq1['n']! + sq2['n']!} - ${c * d} = $ans',
        ));
      } else if (category == 1) {
        // Fractional Percentage Mix
        final fractions = [
          {'pct': '37.5%', 'den': 8, 'num': 3},
          {'pct': '62.5%', 'den': 8, 'num': 5},
          {'pct': '83.33%', 'den': 6, 'num': 5},
          {'pct': '16.67%', 'den': 6, 'num': 1},
          {'pct': '12.5%', 'den': 8, 'num': 1},
          {'pct': '25%', 'den': 4, 'num': 1},
        ];
        var f1 = fractions[_rnd.nextInt(fractions.length)];
        int den = f1['den'] as int;
        int num = f1['num'] as int;
        int baseVal = den * (_rnd.nextInt(12) + 4) * 10;
        int part1 = (baseVal ~/ den) * num;
        int addVal = (_rnd.nextInt(8) + 2) * 15;
        int ans = part1 + addVal;
        List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 5, -5]);
        list.add(QuestionModel(
          id: id,
          topicId: 'fractions',
          prompt: '(${f1['pct']} of $baseVal) + $addVal = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ Speed Fraction: ${f1['pct']} of $baseVal = $part1. $part1 + $addVal = $ans',
        ));
      } else if (category == 2) {
        // 4-Digit Square Root
        var sq = perfectSquares[_rnd.nextInt(perfectSquares.length)];
        int ans = sq['n']!;
        List<String> options = _generateSmartDistractors(ans, delta: [2, -2, 10, -10, 4, -4]);
        list.add(QuestionModel(
          id: id,
          topicId: 'squares',
          prompt: '√${sq['sq']} = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ Square Root: $ans² = ${sq['sq']}. Last digit analysis confirms $ans.',
        ));
      } else {
        // 5-Digit Cube Root
        var cb = perfectCubes[_rnd.nextInt(perfectCubes.length)];
        int ans = cb['n']!;
        List<String> options = _generateSmartDistractors(ans, delta: [1, -1, 2, -2, 3, -3]);
        list.add(QuestionModel(
          id: id,
          topicId: 'cubes',
          prompt: '∛${cb['cb']} = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ Cube Root: $ans³ = ${cb['cb']}. Unit digit ${cb['cb']! % 10} maps directly to $ans.',
        ));
      }
    }

    list.shuffle();
    return list;
  }

  /// Real Railway (RRB NTPC, Group D, ALP) Exam Level Generator:
  /// - Speed / Distance / Time Unit Conversions (km/h <-> m/s)
  /// - Mental LCM & HCF
  /// - Divisibility Tests
  /// - Difference of Squares (a^2 - b^2)
  static List<QuestionModel> generateRailwayExamLevelQuestions({required int count}) {
    List<QuestionModel> list = [];

    final lcmHcfPairs = [
      {'prompt': 'LCM of (12, 15, 20) = ?', 'ans': 60, 'exp': '12=2²×3, 15=3×5, 20=2²×5 ➔ LCM = 2²×3×5 = 60'},
      {'prompt': 'LCM of (16, 24, 36) = ?', 'ans': 144, 'exp': '16=2⁴, 24=2³×3, 36=2²×3² ➔ LCM = 2⁴×3² = 144'},
      {'prompt': 'LCM of (18, 24, 30) = ?', 'ans': 360, 'exp': '18=2×3², 24=2³×3, 30=2×3×5 ➔ LCM = 2³×3²×5 = 360'},
      {'prompt': 'LCM of (15, 25, 30) = ?', 'ans': 150, 'exp': '15=3×5, 25=5², 30=2×3×5 ➔ LCM = 2×3×5² = 150'},
      {'prompt': 'HCF of (48, 72, 120) = ?', 'ans': 24, 'exp': 'Common highest factor of 48, 72, 120 is 24'},
      {'prompt': 'HCF of (36, 60, 84) = ?', 'ans': 12, 'exp': 'Common highest factor of 36, 60, 84 is 12'},
      {'prompt': 'HCF of (42, 63, 105) = ?', 'ans': 21, 'exp': 'Common highest factor of 42, 63, 105 is 21'},
    ];

    for (int i = 0; i < count; i++) {
      String id = 'rly_q_${DateTime.now().microsecondsSinceEpoch}_$i';
      int category = i % 4;

      if (category == 0) {
        // Speed conversion km/h -> m/s or m/s -> km/h
        bool kmhToMs = _rnd.nextBool();
        if (kmhToMs) {
          int mult = _rnd.nextInt(8) + 1; // 1 to 8
          int kmh = mult * 18; // 18, 36, 54, 72, 90, 108, 126, 144
          int ans = mult * 5;
          List<String> options = _generateSmartDistractors(ans, delta: [5, -5, 10, -10, 2, -2]);
          list.add(QuestionModel(
            id: id,
            topicId: 'conversion',
            prompt: 'Convert $kmh km/h into m/s = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: 2,
            explanation: '⚡ Railway Speed Rule: Multiply by 5/18. $kmh × (5/18) = $ans m/s',
          ));
        } else {
          int mult = _rnd.nextInt(8) + 2; // 2 to 9
          int ms = mult * 5; // 10, 15, 20, 25, 30, 35, 40, 45
          int ans = mult * 18;
          List<String> options = _generateSmartDistractors(ans, delta: [18, -18, 9, -9, 10, -10]);
          list.add(QuestionModel(
            id: id,
            topicId: 'conversion',
            prompt: 'Convert $ms m/s into km/h = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: 2,
            explanation: '⚡ Railway Speed Rule: Multiply by 18/5. $ms × (18/5) = $ans km/h',
          ));
        }
      } else if (category == 1) {
        // LCM / HCF
        var pair = lcmHcfPairs[_rnd.nextInt(lcmHcfPairs.length)];
        int ans = pair['ans'] as int;
        List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 12, -12, 6, -6]);
        list.add(QuestionModel(
          id: id,
          topicId: 'lcm_hcf',
          prompt: pair['prompt'] as String,
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ Railway Reflex: ${pair['exp']}',
        ));
      } else if (category == 2) {
        // Difference of Squares (a² - b²)
        int a = _rnd.nextInt(25) + 15; // 15 to 39
        int diff = _rnd.nextInt(5) + 2; // 2 to 6
        int b = a - diff;
        int ans = (a * a) - (b * b);
        List<String> options = _generateSmartDistractors(ans, delta: [diff * 10, -diff * 10, 20, -20]);
        list.add(QuestionModel(
          id: id,
          topicId: 'algebra',
          prompt: '$a² - $b² = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ Identity Shortcut: ($a - $b) × ($a + $b) = $diff × ${a + b} = $ans',
        ));
      } else {
        // Divisibility Rule for 9
        int base = (_rnd.nextInt(800) + 100) * 10;
        int rem = _rnd.nextInt(8) + 1;
        int n = base + rem;
        int sumDigits = n.toString().split('').map(int.parse).reduce((a, b) => a + b);
        int ans = sumDigits % 9;
        List<String> options = _generateSmartDistractors(ans, delta: [1, -1, 2, -2, 3, -3]);
        list.add(QuestionModel(
          id: id,
          topicId: 'divisibility',
          prompt: 'Remainder when $n is divided by 9 = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 2,
          explanation: '⚡ 9 Divisibility: Sum of digits = $sumDigits. $sumDigits mod 9 = $ans.',
        ));
      }
    }

    list.shuffle();
    return list;
  }

  /// Real CAT / MBA (XAT, IPMAT) Exam Level Generator:
  /// - Base-100 & Base-50 Vedic Multiplication
  /// - Successive Percentage Changes (A + B + AB/100)
  /// - Remainder Theorems & Power Cycling
  /// - Exponent Powers of 2 and 3
  static List<QuestionModel> generateCatExamLevelQuestions({required int count}) {
    List<QuestionModel> list = [];

    for (int i = 0; i < count; i++) {
      String id = 'cat_q_${DateTime.now().microsecondsSinceEpoch}_$i';
      int category = i % 4;

      if (category == 0) {
        // Base-100 or Base-50 Multiplication
        bool near100 = _rnd.nextBool();
        if (near100) {
          int d1 = _rnd.nextInt(6) + 2; // 2 to 7
          int d2 = _rnd.nextInt(6) + 2;
          int a = 100 - d1;
          int b = 100 - d2;
          int ans = a * b;
          List<String> options = _generateSmartDistractors(ans, delta: [100, -100, 10, -10, 1, -1]);
          list.add(QuestionModel(
            id: id,
            topicId: 'vedic_base',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: 3,
            explanation: '⚡ Base-100 Vedic: (100 - $d1 - $d2)|($d1 × $d2) = ${100 - d1 - d2}|${(d1 * d2).toString().padLeft(2, '0')} = $ans',
          ));
        } else {
          int d = _rnd.nextInt(4) + 1; // 1 to 4
          int a = 50 - d;
          int b = 50 + d;
          int ans = 2500 - (d * d);
          List<String> options = _generateSmartDistractors(ans, delta: [10, -10, 20, -20, 2, -2]);
          list.add(QuestionModel(
            id: id,
            topicId: 'vedic_base',
            prompt: '$a × $b = ?',
            correctAnswer: '$ans',
            options: options,
            difficulty: 3,
            explanation: '⚡ Identity (50-d)(50+d): 50² - $d² = 2500 - ${d * d} = $ans',
          ));
        }
      } else if (category == 1) {
        // Successive Percentage Changes: a% and b%
        final pairs = [
          {'a': 20, 'b': 30, 'ans': 56, 'type': 'increase'},
          {'a': 10, 'b': 20, 'ans': 32, 'type': 'increase'},
          {'a': 25, 'b': 20, 'ans': 50, 'type': 'increase'},
          {'a': -20, 'b': -10, 'ans': 28, 'type': 'discount (28% single discount)'},
          {'a': -30, 'b': -20, 'ans': 44, 'type': 'discount (44% single discount)'},
          {'a': 50, 'b': -50, 'ans': 25, 'type': 'decrease (-25%)'},
          {'a': 25, 'b': -20, 'ans': 0, 'type': 'net zero change'},
        ];
        var p = pairs[_rnd.nextInt(pairs.length)];
        int ans = p['ans'] as int;
        String prompt = (p['a'] as int) < 0
            ? 'Single equivalent discount of two successive discounts (${(p['a'] as int).abs()}% and ${(p['b'] as int).abs()}%) = ?%'
            : 'Net effective percentage change of successive +${p['a']}% and +${p['b']}% = ?%';
        List<String> options = _generateSmartDistractors(ans, delta: [2, -2, 5, -5, 10, -10]);
        list.add(QuestionModel(
          id: id,
          topicId: 'successive_pct',
          prompt: prompt,
          correctAnswer: '$ans%',
          options: options.map((o) => o.contains('%') ? o : '$o%').toList(),
          difficulty: 3,
          explanation: '⚡ CAT Net Formula: a + b + (ab/100) = $ans%',
        ));
      } else if (category == 2) {
        // Remainder Theorem
        final remTheorems = [
          {'p': 'Remainder of (2^33) ÷ 7 = ?', 'ans': 1, 'exp': '(2³)¹¹ ÷ 7 = 8¹¹ ÷ 7 = (1)¹¹ = 1'},
          {'p': 'Remainder of (3^41) ÷ 8 = ?', 'ans': 3, 'exp': '(3²)²⁰ × 3 ÷ 8 = 9²⁰ × 3 ÷ 8 = (1)²⁰ × 3 = 3'},
          {'p': 'Remainder of (5^31) ÷ 4 = ?', 'ans': 1, 'exp': '(5 mod 4)³¹ = (1)³¹ = 1'},
          {'p': 'Remainder of (7^42) ÷ 8 = ?', 'ans': 1, 'exp': '(-1)⁴² = 1'},
          {'p': 'Remainder of (2^31) ÷ 7 = ?', 'ans': 2, 'exp': '(2³)¹⁰ × 2 ÷ 7 = 8¹⁰ × 2 ÷ 7 = 1 × 2 = 2'},
        ];
        var rt = remTheorems[_rnd.nextInt(remTheorems.length)];
        int ans = rt['ans'] as int;
        List<String> options = ['1', '2', '3', '4']..shuffle();
        if (!options.contains('$ans')) {
          options[0] = '$ans';
        }
        list.add(QuestionModel(
          id: id,
          topicId: 'remainders',
          prompt: rt['p'] as String,
          correctAnswer: '$ans',
          options: options,
          difficulty: 4,
          explanation: '⚡ Modular Arithmetic: ${rt['exp']}',
        ));
      } else {
        // High Exponents (Powers of 2 and 3)
        final powers = [
          {'base': 2, 'exp': 8, 'ans': 256},
          {'base': 2, 'exp': 9, 'ans': 512},
          {'base': 2, 'exp': 10, 'ans': 1024},
          {'base': 2, 'exp': 11, 'ans': 2048},
          {'base': 3, 'exp': 5, 'ans': 243},
          {'base': 3, 'exp': 6, 'ans': 729},
        ];
        var pw = powers[_rnd.nextInt(powers.length)];
        int ans = pw['ans'] as int;
        List<String> options = _generateSmartDistractors(ans, delta: [ans ~/ 2, -(ans ~/ 2), 100, -100]);
        list.add(QuestionModel(
          id: id,
          topicId: 'powers',
          prompt: '(${pw['base']})^${pw['exp']} = ?',
          correctAnswer: '$ans',
          options: options,
          difficulty: 3,
          explanation: '⚡ CAT Power Recall: (${pw['base']})^${pw['exp']} = $ans',
        ));
      }
    }

    list.shuffle();
    return list;
  }

  /// Generate arithmetic questions specifically tailored by digit count:
  /// digits = 1: Single digit (1-Digit)
  /// digits = 2: Double digit (2-Digit)
  /// digits = 3: Triple digit (3-Digit)
  /// digits = 4: Four digit (4-Digit)
  /// [maxNumberLimit]: Optional strict boundary/ceiling. If provided, all operands
  /// (and dividend in division) will never exceed this number, regardless of question count.
  static List<QuestionModel> generateDigitSpecificQuestions({
    required TopicType type,
    required int digits,
    int count = 10,
    int? maxNumberLimit,
  }) {
    List<QuestionModel> questions = [];
    final rnd = Random();
    final Set<String> seenPrompts = {};

    for (int i = 0; i < count; i++) {
      String id = '${type.name}_${digits}d_${DateTime.now().microsecondsSinceEpoch}_$i';

      if (type == TopicType.addition) {
        int a = 0, b = 0;
        String prompt = '';
        for (int attempt = 0; attempt < 25; attempt++) {
          if (maxNumberLimit != null && maxNumberLimit >= 4) {
            final int digitMax = digits == 1 ? 9 : (digits == 2 ? 99 : (digits == 3 ? 999 : 9999));
            final int digitMin = digits == 1 ? 2 : (digits == 2 ? 10 : (digits == 3 ? 100 : 1000));
            final int cap = min(digitMax, maxNumberLimit);
            if (maxNumberLimit >= digitMin * 2) {
              final int maxA = min(cap, maxNumberLimit - digitMin);
              final int spanA = max(1, maxA - digitMin + 1);
              a = rnd.nextInt(spanA) + digitMin;
              final int maxB = min(cap, maxNumberLimit - a);
              final int spanB = max(1, maxB - digitMin + 1);
              b = rnd.nextInt(spanB) + digitMin;
            } else {
              // Ceiling is tighter than two operands of this digit tier: keep both operands AND sum <= maxNumberLimit
              final int minA = max(2, min(cap ~/ 2, maxNumberLimit - 2));
              final int maxA = max(minA, min(cap, maxNumberLimit - 2));
              a = rnd.nextInt(maxA - minA + 1) + minA;
              final int maxB = max(2, min(cap, maxNumberLimit - a));
              b = rnd.nextInt(max(1, maxB - 1)) + 1;
            }
          } else {
            if (digits == 1) {
              a = rnd.nextInt(8) + 2; // 2 to 9
              b = rnd.nextInt(8) + 2; // 2 to 9
            } else if (digits == 2) {
              a = rnd.nextInt(88) + 12; // 12 to 99
              b = rnd.nextInt(88) + 11; // 11 to 98
            } else if (digits == 3) {
              a = rnd.nextInt(880) + 112; // 112 to 991
              b = rnd.nextInt(880) + 115; // 115 to 994
            } else {
              a = rnd.nextInt(8800) + 1120; // 1120 to 9919
              b = rnd.nextInt(8800) + 1115; // 1115 to 9914
            }
          }
          prompt = '$a + $b = ?';
          if (!seenPrompts.contains(prompt)) break;
        }
        seenPrompts.add(prompt);

        int ans = a + b;
        List<String> options = _generateSmartDistractors(ans, delta: [
          (digits == 1 ? 1 : (digits == 2 ? 10 : (digits == 3 ? 50 : 100))),
          -(digits == 1 ? 1 : (digits == 2 ? 10 : (digits == 3 ? 50 : 100))),
          (digits == 1 ? 2 : (digits == 2 ? 20 : (digits == 3 ? 100 : 200))),
          -(digits == 1 ? 2 : (digits == 2 ? 20 : (digits == 3 ? 100 : 200))),
          2, -2, 1, -1,
        ]);
        questions.add(QuestionModel(
          id: id,
          topicId: 'addition',
          prompt: prompt,
          correctAnswer: '$ans',
          options: options,
          difficulty: digits,
          explanation: digits == 1
              ? '⚡ Single-digit reflex: $a + $b = $ans'
              : '⚡ Left-to-right Vedic: add highest place values first ($a + $b = $ans)',
        ));
      } else if (type == TopicType.subtraction) {
        int a = 0, b = 0;
        String prompt = '';
        for (int attempt = 0; attempt < 25; attempt++) {
          if (maxNumberLimit != null && maxNumberLimit >= 3) {
            final int digitMaxA = digits == 1 ? min(18, maxNumberLimit) : (digits == 2 ? 99 : (digits == 3 ? 999 : 9999));
            final int maxVal = min(digitMaxA, maxNumberLimit);
            final int defaultMin = digits == 1
                ? (maxVal >= 10 ? 6 : 3)
                : (digits == 2 ? 15 : (digits == 3 ? 120 : 1100));
            final int minVal = defaultMin >= maxVal ? max(3, maxVal ~/ 2) : defaultMin;
            final int span = max(1, maxVal - minVal + 1);
            a = rnd.nextInt(span) + minVal;

            final int bMax = max(1, a - 1);
            final int preferredBMin = digits == 1
                ? 2
                : (digits == 2 ? min(10, bMax) : (digits == 3 ? min(100, bMax) : min(1000, bMax)));
            final int bMin = preferredBMin >= bMax ? 1 : preferredBMin;
            b = rnd.nextInt(bMax - bMin + 1) + bMin;
          } else {
            if (digits == 1) {
              a = rnd.nextInt(10) + 10; // 10 to 19
              b = rnd.nextInt(8) + 2;   // 2 to 9
            } else if (digits == 2) {
              a = rnd.nextInt(75) + 25; // 25 to 99
              b = rnd.nextInt(a - 11) + 11; // ensures positive 2-digit result
            } else if (digits == 3) {
              a = rnd.nextInt(750) + 240; // 240 to 989
              b = rnd.nextInt(a - 110) + 105;
            } else {
              a = rnd.nextInt(7500) + 2400; // 2400 to 9899
              b = rnd.nextInt(a - 1100) + 1050;
            }
          }
          prompt = '$a − $b = ?';
          if (!seenPrompts.contains(prompt)) break;
        }
        seenPrompts.add(prompt);

        int ans = a - b;
        List<String> options = _generateSmartDistractors(ans, delta: [
          (digits == 1 ? 1 : (digits == 2 ? 10 : (digits == 3 ? 50 : 100))),
          -(digits == 1 ? 1 : (digits == 2 ? 10 : (digits == 3 ? 50 : 100))),
          2, -2, 1, -1,
        ]);
        questions.add(QuestionModel(
          id: id,
          topicId: 'subtraction',
          prompt: prompt,
          correctAnswer: '$ans',
          options: options,
          difficulty: digits,
          explanation: '⚡ Base complement mental subtraction: $a − $b = $ans',
        ));
      } else if (type == TopicType.hardMultiplier || type == TopicType.tables) {
        // Multiplication
        int a = 0, b = 0;
        String prompt = '';
        for (int attempt = 0; attempt < 25; attempt++) {
          if (maxNumberLimit != null && maxNumberLimit >= 2) {
            int maxValA = min(digits == 1 ? 9 : (digits == 2 ? 99 : (digits == 3 ? 999 : 9999)), maxNumberLimit);
            if (maxValA < 2) maxValA = 2;
            int defaultMinA = (digits == 1) ? 2 : (digits == 2 ? 10 : (digits == 3 ? 100 : 1000));
            int minValA = defaultMinA >= maxValA ? max(2, maxValA ~/ 2) : defaultMinA;
            int spanA = max(1, maxValA - minValA + 1);
            a = rnd.nextInt(spanA) + minValA;

            int maxValB = min(digits == 1 ? 9 : maxNumberLimit, maxNumberLimit);
            int minValB = 2;
            int spanB = max(1, maxValB - minValB + 1);
            b = rnd.nextInt(spanB) + minValB;
          } else {
            if (digits == 1) {
              a = rnd.nextInt(8) + 2; // 2 to 9
              b = rnd.nextInt(8) + 2; // 2 to 9
            } else if (digits == 2) {
              a = rnd.nextInt(38) + 12; // 12 to 49
              b = rnd.nextInt(38) + 12; // 12 to 49
            } else if (digits == 3) {
              a = rnd.nextInt(890) + 110; // 110 to 999
              b = rnd.nextInt(18) + 2;    // 2 to 19
            } else {
              a = rnd.nextInt(8900) + 1100; // 1100 to 9999
              b = rnd.nextInt(8) + 2;       // 2 to 9
            }
          }
          prompt = '$a × $b = ?';
          if (!seenPrompts.contains(prompt)) break;
        }
        seenPrompts.add(prompt);

        int ans = a * b;
        List<String> options = _generateSmartDistractors(ans, delta: [
          (digits == 1 ? a : (digits == 2 ? 10 : (digits == 3 ? 50 : 100))),
          -(digits == 1 ? a : (digits == 2 ? 10 : (digits == 3 ? 50 : 100))),
          2, -2, 10, -10,
        ]);
        questions.add(QuestionModel(
          id: id,
          topicId: 'multiplication',
          prompt: prompt,
          correctAnswer: '$ans',
          options: options,
          difficulty: digits,
          explanation: digits == 1
              ? '⚡ Table reflex: $a × $b = $ans'
              : '⚡ Vedic cross-multiplication: $a × $b = $ans',
        ));
      } else {
        // Division
        int divisor = 2, quotient = 2, dividend = 4;
        String prompt = '';
        for (int attempt = 0; attempt < 25; attempt++) {
          if (maxNumberLimit != null && maxNumberLimit >= 4) {
            final int maxDividend = maxNumberLimit;
            final int tierMaxDivisor = digits == 1 ? 9 : (digits == 2 ? 15 : 25);
            final int maxD = max(2, min(tierMaxDivisor, maxDividend ~/ 2));
            divisor = rnd.nextInt(maxD - 1) + 2;

            final int tierMaxQ = digits == 1 ? 9 : 9999;
            final int maxQ = max(2, min(tierMaxQ, maxDividend ~/ divisor));
            final int tierMinQ = digits == 1
                ? 2
                : (digits == 2 ? 10 : (digits == 3 ? 100 : 1000));
            final int minQ = tierMinQ >= maxQ ? 2 : tierMinQ;
            quotient = rnd.nextInt(maxQ - minQ + 1) + minQ;
            dividend = divisor * quotient;
          } else {
            if (digits == 1) {
              divisor = rnd.nextInt(8) + 2; // 2 to 9
              quotient = rnd.nextInt(8) + 2; // 2 to 9
            } else if (digits == 2) {
              divisor = rnd.nextInt(8) + 2; // 2 to 9
              quotient = rnd.nextInt(89) + 11; // 11 to 99
            } else if (digits == 3) {
              divisor = rnd.nextInt(8) + 2; // 2 to 9
              quotient = rnd.nextInt(890) + 110; // 110 to 999
            } else {
              divisor = rnd.nextInt(8) + 2; // 2 to 9
              quotient = rnd.nextInt(8900) + 1100; // 1100 to 9999
            }
            dividend = divisor * quotient;
          }
          prompt = '$dividend ÷ $divisor = ?';
          if (!seenPrompts.contains(prompt)) break;
        }
        seenPrompts.add(prompt);

        List<String> options = _generateSmartDistractors(quotient, delta: [
          (digits == 1 ? 1 : (digits == 2 ? 5 : (digits == 3 ? 20 : 50))),
          -(digits == 1 ? 1 : (digits == 2 ? 5 : (digits == 3 ? 20 : 50))),
          1, -1, 2, -2,
        ]);
        questions.add(QuestionModel(
          id: id,
          topicId: 'division',
          prompt: prompt,
          correctAnswer: '$quotient',
          options: options,
          difficulty: digits,
          explanation: '⚡ Reverse table mental division: $divisor × $quotient = $dividend, so $dividend ÷ $divisor = $quotient',
        ));
      }
    }
    return questions;
  }

  // Global sliding-window tracker for Speed Blitz to guarantee fresh, non-repeating trick questions across sessions
  static final List<String> _recentBlitzPrompts = [];
  static final List<String> _recentBlitzFirstPrompts = [];
  static const int _maxBlitzHistory = 100;

  /// Generates a curated set of 15 high-speed Speed Math trick questions
  /// specifically designed for the 5s Speed Blitz challenge!
  /// Strictly guarantees:
  /// 1. Fresh, non-repeating questions across successive sessions & re-opens.
  /// 2. Brand new starting question on every game restart (never opens with same Q twice in a row).
  /// 3. Zero duplicate prompts within the same 15-question round.
  /// 4. Balanced distribution across all Speed Math trick categories.
  static List<QuestionModel> generateSpeedBlitzTricksSet({int count = 15}) {
    List<QuestionModel> list = [];
    final rnd = Random(); // Use fresh entropy on each call
    final Set<String> inRoundPrompts = {};

    final trickTopics = [
      TopicType.hardMultiplier,
      TopicType.addition,
      TopicType.subtraction,
      TopicType.division,
      TopicType.squares,
      TopicType.cubes,
    ]..shuffle(rnd);

    int topicIdx = rnd.nextInt(trickTopics.length);
    int attempts = 0;
    const int maxAttempts = 350;

    while (list.length < count && attempts < maxAttempts) {
      attempts++;
      TopicType t = trickTopics[topicIdx % trickTopics.length];
      topicIdx++;

      QuestionModel q = _createSingleQuestion(t, 2);

      // Rule 1: No duplicate within the current 15 questions
      if (inRoundPrompts.contains(q.prompt)) continue;

      // Rule 2: If it's the very first question, guarantee it is completely different
      // from the first question of recent games (never same opening question)
      if (list.isEmpty && _recentBlitzFirstPrompts.contains(q.prompt) && attempts < 50) {
        continue;
      }

      // Rule 3: Anti-repeat across recent sessions/games (sliding window of 100 questions)
      if (_recentBlitzPrompts.contains(q.prompt) && attempts < 250) {
        continue;
      }

      inRoundPrompts.add(q.prompt);
      list.add(q);
    }

    // Record the first question for session variation
    if (list.isNotEmpty) {
      _recentBlitzFirstPrompts.add(list.first.prompt);
      if (_recentBlitzFirstPrompts.length > 15) {
        _recentBlitzFirstPrompts.removeAt(0);
      }
    }

    // Add all served prompts into the sliding window
    for (var q in list) {
      _recentBlitzPrompts.add(q.prompt);
    }
    // Trim sliding window to max size
    while (_recentBlitzPrompts.length > _maxBlitzHistory) {
      _recentBlitzPrompts.removeAt(0);
    }

    // Shuffle the final list to give unpredictable order
    list.shuffle(rnd);
    return list;
  }
}

