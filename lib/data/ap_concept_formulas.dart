import '../models/concept_formula_model.dart';
import '../models/math_models.dart';

class APConceptFormulas {
  static final List<ConceptFormulaModel> formulas = [
    // =========================================================================
    // CONCEPT 1: FIRST TERM (a) & COMMON DIFFERENCE (d) | प्रथम पद एवं सार्व अंतर
    // =========================================================================
    ConceptFormulaModel(
      id: 'ap_concept_1_first_term_and_diff',
      pillar: ConceptPillar.arithmeticProgression,
      title: 'Concept 1: First Term & Common Difference',
      subtitle: 'प्रथम पद (a) एवं सार्व अंतर (d) की पहचान व गुण',
      formula: 'Common Difference (d) = a₂ − a₁ = a₃ − a₂ = aₙ − aₙ₋₁',
      diagramType: null,
      keyConditions: [
        'An Arithmetic Progression (A.P.) is a sequence where the difference between any two consecutive terms remains constant throughout.',
        'समांतर श्रेणी (A.P.) संख्याओं की वह श्रृंखला है जिसमें किन्हीं भी दो लगातार पदों के बीच का अंतर हमेशा एक समान रहता है।',
        'First Term (a): The initial starting value of the sequence (श्रेणी की पहली संख्या)।',
        'Common Difference (d): d = aₙ − aₙ₋₁. Note that d can be positive (बढ़ती श्रेणी), negative (घटती श्रेणी), or zero (अपरिवर्तनीय श्रेणी)।',
        'Three consecutive terms condition: If a, b, c are in A.P., then 2b = a + c or b − a = c − b.',
      ],
      explanation:
          'In an A.P., the common difference d connects all terms sequentially. If consecutive terms contain an unknown variable (e.g. k + 2, 4k − 6, 3k − 2), equate (T₂ − T₁) = (T₃ − T₂) to directly isolate and solve for the unknown in seconds.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'If (k + 2), (4k − 6), and (3k − 2) are three consecutive terms of an A.P., find the value of k.',
          steps: [
            'Step 1: In an A.P., the common difference between consecutive terms is equal: (a₂ − a₁) = (a₃ − a₂).',
            'Step 2: Set up the equation: (4k − 6) − (k + 2) = (3k − 2) − (4k − 6).',
            'Step 3: Simplify both sides: 3k − 8 = −k + 4.',
            'Step 4: Transpose terms: 3k + k = 4 + 8 ⇒ 4k = 12 ⇒ k = 3.',
          ],
          answer: 'k = 3',
          shortcutTip:
              'Shortcut: 2b = a + c ⇒ 2(4k − 6) = (k + 2) + (3k − 2) ⇒ 8k − 12 = 4k ⇒ 4k = 12 ⇒ k = 3!',
        ),
        SolvedExampleModel(
          problem:
              'Find the common difference of the A.P.: 1/p, (1 − p)/p, (1 − 2p)/p, ...',
          steps: [
            'Step 1: Common difference d = a₂ − a₁.',
            'Step 2: Subtract first term from second term: d = [(1 − p)/p] − [1/p].',
            'Step 3: Combine under common denominator: d = (1 − p − 1) / p = −p / p = −1.',
          ],
          answer: 'd = −1',
          shortcutTip:
              'Mental Trick: Split fractions: 1/p, 1/p − 1, 1/p − 2... Each step decreases by 1, so d = −1 immediately!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'ap_q1_chsl',
          topicId: 'ap_basics',
          examBadge: 'SSC CHSL',
          difficulty: 1,
          prompt:
              'If (k + 2), (4k − 6), and (3k − 2) are three consecutive terms of an A.P., then what is the value of k?\n\nयदि (k + 2), (4k − 6) और (3k − 2) एक समांतर श्रेणी के तीन क्रमागत पद हैं, तो k का मान क्या है?',
          options: ['2', '3', '4', '5'],
          correctAnswer: '3',
          explanation:
              'For terms in A.P., 2b = a + c ⇒ 2(4k − 6) = (k + 2) + (3k − 2) ⇒ 8k − 12 = 4k ⇒ 4k = 12 ⇒ k = 3. Option (B).',
        ),
        QuestionModel(
          id: 'ap_q2_ntpc',
          topicId: 'ap_basics',
          examBadge: 'RRB NTPC',
          difficulty: 1,
          prompt:
              'What is the common difference of the A.P. 1/p, (1 − p)/p, (1 − 2p)/p, ...?\n\nसमांतर श्रेणी 1/p, (1 − p)/p, (1 − 2p)/p, ... का सार्व अंतर क्या है?',
          options: ['p', '−p', '−1', '1'],
          correctAnswer: '−1',
          explanation:
              'd = a₂ − a₁ = [(1 − p)/p] − [1/p] = (1 − p − 1)/p = −p/p = −1. Option (C).',
        ),
      ],
    ),

    // =========================================================================
    // CONCEPT 2: n-th TERM (Tn), LAST TERM (l) & TERM FROM END | n-वाँ पद
    // =========================================================================
    ConceptFormulaModel(
      id: 'ap_concept_2_nth_term',
      pillar: ConceptPillar.arithmeticProgression,
      title: 'Concept 2: n-th Term & Term from End',
      subtitle: 'n-वाँ पद (Tₙ), अंतिम पद (l) एवं अंत से n-वाँ पद',
      formula: 'Tₙ = a + (n − 1)d   |   From End: Tₙ\' = l − (n − 1)d',
      diagramType: null,
      keyConditions: [
        'To find any term at position n without writing the entire series: Tₙ = a + (n − 1)d.',
        'If the series is finite with total n terms, the n-th term is the last term l = a + (n − 1)d.',
        'Term from the End (अंत से n-वाँ पद): Tₙ (from end) = l − (n − 1)d, where l is the last term.',
        'Shortcut for difference of two terms: Tₚ − T_q = (p − q)d. This allows finding d directly without solving for a!',
        'Special Exam Identity: If m · Tₘ = n · Tₙ, then Tₘ₊ₙ = 0.',
        'First negative term condition: Set Tₙ < 0 and solve for integer n > (a + d) / d.',
      ],
      explanation:
          'The n-th term formula allows jumping directly to any index in the progression. Whenever given two arbitrary terms T_p and T_q, avoid setting up simultaneous equations: simply divide (T_p − T_q) by (p − q) to get the common difference d instantly.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'Find the 25th term of the arithmetic progression 7, 13, 19, 25, ...',
          steps: [
            'Step 1: Identify given parameters: First term a = 7, common difference d = 13 − 7 = 6, term index n = 25.',
            'Step 2: Apply formula: T₂₅ = a + (n − 1)d.',
            'Step 3: T₂₅ = 7 + (25 − 1) × 6 = 7 + 24 × 6 = 7 + 144 = 151.',
          ],
          answer: 'T₂₅ = 151',
          shortcutTip:
              'Mental Math: 24 × 6 = 144. Add 7 = 151 in less than 3 seconds!',
        ),
        SolvedExampleModel(
          problem:
              'The 6th term of an A.P. is 12 and its 16th term is 42. Find the 21st term.',
          steps: [
            'Step 1: Difference between 16th and 6th terms: T₁₆ − T₆ = (16 − 6)d = 10d.',
            'Step 2: 42 − 12 = 10d ⇒ 30 = 10d ⇒ d = 3.',
            'Step 3: To find 21st term from 16th term: T₂₁ = T₁₆ + (21 − 16)d = 42 + 5(3) = 42 + 15 = 57.',
          ],
          answer: 'T₂₁ = 57',
          shortcutTip:
              'No need to calculate a! Step from T₁₆ to T₂₁ directly: 42 + 5 × 3 = 57!',
        ),
        SolvedExampleModel(
          problem:
              'Find the 11th term from the end of the A.P.: 10, 7, 4, ..., −62.',
          steps: [
            'Step 1: Identify last term l = −62 and common difference d = 7 − 10 = −3.',
            'Step 2: Formula from end: T₁₁\' = l − (n − 1)d.',
            'Step 3: T₁₁\' = −62 − (11 − 1)(−3) = −62 − 10(−3) = −62 + 30 = −32.',
          ],
          answer: '−32',
          shortcutTip:
              'Alternative: Reverse the series: −62, −59, ... with new a = −62 and new d = +3. T₁₁ = −62 + 10(3) = −32!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'ap_q3_cgl',
          topicId: 'ap_nth_term',
          examBadge: 'SSC CGL',
          difficulty: 1,
          prompt:
              'Find the 25th term of the arithmetic progression 7, 13, 19, 25, ...\n\nसमांतर श्रेणी 7, 13, 19, 25, ... का 25वाँ पद ज्ञात कीजिए।',
          options: ['145', '151', '157', '163'],
          correctAnswer: '151',
          explanation:
              'Here a = 7, d = 13 − 7 = 6, n = 25. T₂₅ = a + (25 − 1)d = 7 + 24 × 6 = 7 + 144 = 151. Option (B).',
        ),
        QuestionModel(
          id: 'ap_q4_cpo',
          topicId: 'ap_nth_term',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'The 6th term of an A.P. is 12 and its 16th term is 42. Find the 21st term of the A.P.\n\nएक समांतर श्रेणी का 6ठा पद 12 है और इसका 16वाँ पद 42 है। श्रेणी का 21वाँ पद ज्ञात कीजिए।',
          options: ['54', '57', '60', '63'],
          correctAnswer: '57',
          explanation:
              'T₁₆ − T₆ = 10d ⇒ 42 − 12 = 10d ⇒ d = 3. T₂₁ = T₁₆ + 5d = 42 + 5(3) = 57. Option (B).',
        ),
        QuestionModel(
          id: 'ap_q5_groupd',
          topicId: 'ap_nth_term',
          examBadge: 'RRB Group D',
          difficulty: 2,
          prompt:
              'Find the 11th term from the end of the A.P. 10, 7, 4, ..., −62.\n\nसमांतर श्रेणी 10, 7, 4, ..., −62 के अंत से 11वाँ पद ज्ञात कीजिए।',
          options: ['−32', '−29', '−35', '−26'],
          correctAnswer: '−32',
          explanation:
              'l = −62, d = 7 − 10 = −3. Term from end = l − (n − 1)d = −62 − (11 − 1)(−3) = −62 + 30 = −32. Option (A).',
        ),
        QuestionModel(
          id: 'ap_q6_cgl_tier2',
          topicId: 'ap_nth_term',
          examBadge: 'SSC CGL Tier-II',
          difficulty: 2,
          prompt:
              'If 7 times the 7th term of an A.P. is equal to 11 times its 11th term, then what is its 18th term?\n\nयदि किसी समांतर श्रेणी के 7वें पद का 7 गुना उसके 11वें पद के 11 गुने के बराबर है, तो उसका 18वाँ पद क्या होगा?',
          options: ['1', '−1', '0', '18'],
          correctAnswer: '0',
          explanation:
              'Standard Identity: If m · Tₘ = n · Tₙ, then Tₘ₊ₙ = 0. Here 7 · T₇ = 11 · T₁₁ ⇒ T₁₈ = 0. Option (C).',
        ),
        QuestionModel(
          id: 'ap_q7_chsl',
          topicId: 'ap_nth_term',
          examBadge: 'SSC CHSL',
          difficulty: 2,
          prompt:
              'Which term of the A.P. 24, 21, 18, ... is the first negative term?\n\nसमांतर श्रेणी 24, 21, 18, ... का कौन-सा पद पहला ऋणात्मक पद है?',
          options: ['8th', '9th', '10th', '11th'],
          correctAnswer: '10th',
          explanation:
              'a = 24, d = −3. Set Tₙ < 0 ⇒ 24 + (n − 1)(−3) < 0 ⇒ 27 − 3n < 0 ⇒ 3n > 27 ⇒ n > 9. Thus the 10th term is the first negative term (T₁₀ = −3). Option (C).',
        ),
        QuestionModel(
          id: 'ap_q8_alp',
          topicId: 'ap_nth_term',
          examBadge: 'RRB ALP',
          difficulty: 2,
          prompt:
              'The sum of the 4th and 8th terms of an A.P. is 24, and the sum of the 6th and 10th terms is 44. Find the first term.\n\nएक समांतर श्रेणी के चौथे और 8वें पदों का योग 24 है, तथा छठे और 10वें पदों का योग 44 है। प्रथम पद ज्ञात कीजिए।',
          options: ['−13', '−8', '5', '−10'],
          correctAnswer: '−13',
          explanation:
              '(a + 3d) + (a + 7d) = 2a + 10d = 24 ...(i); (a + 5d) + (a + 9d) = 2a + 14d = 44 ...(ii). Subtracting (i) from (ii): 4d = 20 ⇒ d = 5. Substituting in (i): 2a + 50 = 24 ⇒ 2a = −26 ⇒ a = −13. Option (A).',
        ),
      ],
    ),

    // =========================================================================
    // CONCEPT 3: NUMBER OF TERMS (n) & DIVISIBILITY SHORTCUTS | पदों की संख्या
    // =========================================================================
    ConceptFormulaModel(
      id: 'ap_concept_3_number_of_terms',
      pillar: ConceptPillar.arithmeticProgression,
      title: 'Concept 3: Number of Terms & Divisibility',
      subtitle: 'पदों की संख्या (n) एवं विभाज्यता (Divisibility) शॉर्टकट ट्रिक्स',
      formula: 'n = [(l − a) / d] + 1',
      diagramType: null,
      keyConditions: [
        'Fundamental Count Formula: n = [(Last Term − First Term) / Common Difference] + 1.',
        'Divisible between two limits: First find the smallest multiple (a) ≥ lower limit, and largest multiple (l) ≤ upper limit. Then apply the count formula.',
        'Divisible by multiple numbers (e.g. divisible by 4, 5, and 6): Find numbers divisible by LCM(4, 5, 6) = 60.',
        'Wordings matter: \"Between A and B\" excludes boundary values A and B; \"From A to B\" includes both ends if eligible.',
        'Remainder r when divided by k: Terms form an A.P. with common difference d = k, and each term of the form k · m + r.',
      ],
      explanation:
          'Divisibility problems in SSC and Railway exams are purely A.P. questions in disguise. Instead of manually listing candidates, find the first term a and last term l, then use n = [(l − a) / d] + 1 to compute the exact total in 5 seconds flat.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'How many numbers between 200 and 500 are divisible by 13?',
          steps: [
            'Step 1: Find first multiple of 13 after 200: 200 ÷ 13 = 15.38 ⇒ 16th multiple: a = 13 × 16 = 208.',
            'Step 2: Find last multiple of 13 before 500: 500 ÷ 13 = 38.46 ⇒ 38th multiple: l = 13 × 38 = 494.',
            'Step 3: Common difference d = 13.',
            'Step 4: Count n = [(494 − 208) / 13] + 1 = (286 / 13) + 1 = 22 + 1 = 23.',
          ],
          answer: 'n = 23',
          shortcutTip:
              'Super Shortcut: Floor(499 / 13) − Floor(200 / 13) = 38 − 15 = 23! Instant mental math!',
        ),
        SolvedExampleModel(
          problem:
              'How many numbers between 100 and 600 are divisible by both 4 and 6?',
          steps: [
            'Step 1: A number divisible by both 4 and 6 must be divisible by LCM(4, 6) = 12.',
            'Step 2: First multiple after 100: 12 × 9 = 108 (a = 108).',
            'Step 3: Last multiple before 600: 600 is excluded (between 100 and 600), so 600 − 12 = 588 (l = 588).',
            'Step 4: n = [(588 − 108) / 12] + 1 = (480 / 12) + 1 = 40 + 1 = 41.',
          ],
          answer: 'n = 41',
          shortcutTip:
              'Quotient Trick: Floor(599 / 12) − Floor(100 / 12) = 49 − 8 = 41!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'ap_q9_cgl',
          topicId: 'ap_count',
          examBadge: 'SSC CGL',
          difficulty: 1,
          prompt:
              'How many numbers between 200 and 500 are divisible by 13?\n\n200 और 500 के बीच कितनी संख्याएँ 13 से विभाज्य हैं?',
          options: ['22', '23', '24', '25'],
          correctAnswer: '23',
          explanation:
              'First multiple = 208, last multiple = 494, d = 13. n = [(494 − 208) / 13] + 1 = (286 / 13) + 1 = 22 + 1 = 23. Option (B).',
        ),
        QuestionModel(
          id: 'ap_q10_ntpc',
          topicId: 'ap_count',
          examBadge: 'RRB NTPC',
          difficulty: 1,
          prompt:
              'How many two-digit numbers are divisible by 3?\n\nदो अंकों की कितनी संख्याएँ 3 से विभाज्य हैं?',
          options: ['29', '30', '31', '32'],
          correctAnswer: '30',
          explanation:
              'Two digit multiples of 3 are 12, 15, ..., 99. Here a = 12, l = 99, d = 3. n = [(99 − 12)/3] + 1 = (87/3) + 1 = 29 + 1 = 30. Option (B).',
        ),
        QuestionModel(
          id: 'ap_q11_cpo',
          topicId: 'ap_count',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'How many natural numbers between 300 and 1000 leave a remainder of 3 when divided by 7?\n\n300 और 1000 के बीच कितनी प्राकृत संख्याएँ हैं जिन्हें 7 से विभाजित करने पर शेषफल 3 बचता है?',
          options: ['98', '99', '100', '101'],
          correctAnswer: '100',
          explanation:
              'Numbers: 7k + 3. First number > 300 is 7(43) + 3 = 304. Last number < 1000 is 7(142) + 3 = 997. n = [(997 − 304) / 7] + 1 = (693 / 7) + 1 = 99 + 1 = 100. Option (C).',
        ),
        QuestionModel(
          id: 'ap_q12_selpost',
          topicId: 'ap_count',
          examBadge: 'SSC Selection Post',
          difficulty: 2,
          prompt:
              'How many numbers between 100 and 600 are divisible by both 4 and 6?\n\n100 और 600 के बीच कितनी संख्याएँ 4 और 6 दोनों से विभाज्य हैं?',
          options: ['40', '41', '42', '43'],
          correctAnswer: '41',
          explanation:
              'LCM(4, 6) = 12. Multiples strictly between 100 and 600: 108, 120, ..., 588. n = [(588 − 108)/12] + 1 = 40 + 1 = 41. Option (B).',
        ),
        QuestionModel(
          id: 'ap_q13_je',
          topicId: 'ap_count',
          examBadge: 'RRB JE',
          difficulty: 2,
          prompt:
              'How many three-digit numbers leave a remainder of 2 when divided by 5?\n\nतीन अंकों की ऐसी कितनी संख्याएँ हैं जिन्हें 5 से विभाजित करने पर शेषफल 2 प्राप्त होता है?',
          options: ['179', '180', '181', '182'],
          correctAnswer: '180',
          explanation:
              'First 3-digit number = 102, last 3-digit number = 997, d = 5. n = [(997 − 102)/5] + 1 = (895/5) + 1 = 179 + 1 = 180. Option (B).',
        ),
      ],
    ),

    // =========================================================================
    // CONCEPT 4: SUM OF FIRST n TERMS (Sn) & SERIES SHORTCUTS | n पदों का योग
    // =========================================================================
    ConceptFormulaModel(
      id: 'ap_concept_4_sum_of_terms',
      pillar: ConceptPillar.arithmeticProgression,
      title: 'Concept 4: Sum of First n Terms (Sn)',
      subtitle: 'प्रथम n पदों का योगफल (Sₙ), औसत संबंध एवं परीक्षा ट्रिक्स',
      formula: 'Sₙ = (n / 2)[2a + (n − 1)d] = (n / 2)(a + l) = n × Average',
      diagramType: null,
      keyConditions: [
        'Standard Formula: Sₙ = (n/2)[2a + (n − 1)d]. Use this when a, d, and n are known.',
        'Last Term Shortcut: Sₙ = (n/2)(a + l). Use when first and last terms are known.',
        'Average / Middle Term Trick: Average of an A.P. is exactly (a + l)/2. Therefore, Sum = n × Middle Term (when n is odd).',
        'Relationship between Sₙ and Tₙ: Tₙ = Sₙ − Sₙ₋₁. If Sₙ is quadratic of the form An² + Bn, then common difference d = 2A and first term a = A + B.',
        'Ratio of Sums to Ratio of Terms: If Sₙ / Sₙ\' = f(n) / g(n), then the ratio of their k-th terms is obtained by replacing n with (2k − 1).',
        'Symmetry Identity: If Sₚ = S_q (where p ≠ q), then Sₚ₊_q = 0.',
      ],
      explanation:
          'Sum of A.P. questions often present algebraic shortcuts. When S_n is given as An² + Bn, the common difference is simply 2A (double the coefficient of n²). For consecutive odd/even terms, the sum divided by n instantly yields the central term!',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'Find the sum of the first 20 terms of the A.P.: 5, 9, 13, 17, ...',
          steps: [
            'Step 1: Identify given values: a = 5, d = 9 − 5 = 4, n = 20.',
            'Step 2: Apply formula: S₂₀ = (20/2) [2(5) + (20 − 1) × 4].',
            'Step 3: S₂₀ = 10 × [10 + 19 × 4] = 10 × [10 + 76] = 10 × 86 = 860.',
          ],
          answer: 'S₂₀ = 860',
          shortcutTip:
              'Fast Calculation: 19 × 4 = 76; 76 + 10 = 86; 86 × 10 = 860!',
        ),
        SolvedExampleModel(
          problem:
              'If Sₙ = 3n² + 5n, find the 15th term (T₁₅).',
          steps: [
            'Step 1: Recognize quadratic form Sₙ = An² + Bn with A = 3, B = 5.',
            'Step 2: Common difference d = 2A = 2(3) = 6.',
            'Step 3: First term a = S₁ = 3(1)² + 5(1) = 8.',
            'Step 4: 15th term T₁₅ = a + 14d = 8 + 14(6) = 8 + 84 = 92.',
          ],
          answer: 'T₁₅ = 92',
          shortcutTip:
              'Super Hack: Tₙ = d/dn(Sₙ) − A = 6n + 5 − 3 = 6n + 2. Put n = 15: 6(15) + 2 = 90 + 2 = 92!',
        ),
        SolvedExampleModel(
          problem:
              'The sum of 5 consecutive odd numbers in an A.P. is 145. Find the largest number.',
          steps: [
            'Step 1: Since count is odd (n = 5), the middle (3rd) term is exactly the average.',
            'Step 2: Middle term T₃ = Sum / 5 = 145 / 5 = 29.',
            'Step 3: Consecutive odd numbers differ by 2: terms are 25, 27, 29, 31, 33.',
            'Step 4: The largest number is 33.',
          ],
          answer: '33',
          shortcutTip:
              'Middle term = 29. Two steps ahead = 29 + 2(2) = 33 in 2 seconds!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'ap_q14_cgl',
          topicId: 'ap_sum',
          examBadge: 'SSC CGL',
          difficulty: 1,
          prompt:
              'Find the sum of the first 20 terms of the A.P. 5, 9, 13, 17, ...\n\nसमांतर श्रेणी 5, 9, 13, 17, ... के प्रथम 20 पदों का योग ज्ञात कीजिए।',
          options: ['820', '840', '860', '880'],
          correctAnswer: '860',
          explanation:
              'a = 5, d = 4, n = 20. S₂₀ = (20/2)[2(5) + 19(4)] = 10[10 + 76] = 860. Option (C).',
        ),
        QuestionModel(
          id: 'ap_q15_chsl',
          topicId: 'ap_sum',
          examBadge: 'SSC CHSL',
          difficulty: 2,
          prompt:
              'What is the sum of all natural numbers between 100 and 200 which are multiples of 3?\n\n100 और 200 के बीच उन सभी प्राकृत संख्याओं का योग क्या है जो 3 की गुणज हैं?',
          options: ['4950', '4980', '5000', '5100'],
          correctAnswer: '4950',
          explanation:
              'Multiples: 102, 105, ..., 198. n = [(198 − 102)/3] + 1 = 33. S₃₃ = (33/2)(102 + 198) = (33/2) × 300 = 33 × 150 = 4950. Option (A).',
        ),
        QuestionModel(
          id: 'ap_q16_ntpc',
          topicId: 'ap_sum',
          examBadge: 'RRB NTPC',
          difficulty: 1,
          prompt:
              'The first term of an A.P. is 5, the last term is 45, and the sum of all terms is 400. Find the number of terms (n).\n\nएक समांतर श्रेणी का प्रथम पद 5 है, अंतिम पद 45 है और सभी पदों का योग 400 है। पदों की संख्या (n) ज्ञात कीजिए।',
          options: ['14', '15', '16', '18'],
          correctAnswer: '16',
          explanation:
              'Sₙ = (n/2)(a + l) ⇒ 400 = (n/2)(5 + 45) = 25n ⇒ n = 400 / 25 = 16. Option (C).',
        ),
        QuestionModel(
          id: 'ap_q17_cgl_tier2',
          topicId: 'ap_sum',
          examBadge: 'SSC CGL Tier-II',
          difficulty: 2,
          prompt:
              'If the sum of the first n terms of an A.P. is Sₙ = 3n² + 5n, then find its 15th term.\n\nयदि किसी समांतर श्रेणी के प्रथम n पदों का योग Sₙ = 3n² + 5n है, तो इसका 15वाँ पद ज्ञात कीजिए।',
          options: ['86', '92', '95', '98'],
          correctAnswer: '92',
          explanation:
              'For Sₙ = An² + Bn: d = 2A = 6, a = A + B = 8. T₁₅ = a + 14d = 8 + 14(6) = 8 + 84 = 92. Option (B).',
        ),
        QuestionModel(
          id: 'ap_q18_cpo',
          topicId: 'ap_sum',
          examBadge: 'SSC CPO',
          difficulty: 3,
          prompt:
              'The ratio of the sums of the first n terms of two A.P.s is (7n + 1) : (4n + 27). Find the ratio of their 9th terms.\n\nदो समांतर श्रेणियों के प्रथम n पदों के योगफल का अनुपात (7n + 1) : (4n + 27) है। उनके 9वें पदों का अनुपात ज्ञात कीजिए।',
          options: ['24 : 19', '19 : 24', '15 : 11', '11 : 15'],
          correctAnswer: '24 : 19',
          explanation:
              'Direct Trick: Replace n with (2k − 1). For 9th term, replace n with 2(9) − 1 = 17. Ratio = [7(17) + 1] / [4(17) + 27] = (119 + 1) / (68 + 27) = 120 / 95 = 24 / 19. Option (A).',
        ),
        QuestionModel(
          id: 'ap_q19_groupd',
          topicId: 'ap_sum',
          examBadge: 'RRB Group D',
          difficulty: 2,
          prompt:
              'How many terms of the A.P. 9, 17, 25, ... must be taken to give a sum of 636?\n\nसमांतर श्रेणी 9, 17, 25, ... के कितने पद लिए जाने चाहिए ताकि उनका योग 636 प्राप्त हो?',
          options: ['10', '11', '12', '13'],
          correctAnswer: '12',
          explanation:
              'a = 9, d = 8. Sₙ = (n/2)[18 + (n − 1)8] = n(4n + 5) = 636. Testing options: for n = 12, 12 × (48 + 5) = 12 × 53 = 636. Option (C).',
        ),
        QuestionModel(
          id: 'ap_q20_cgl',
          topicId: 'ap_sum',
          examBadge: 'SSC CGL',
          difficulty: 1,
          prompt:
              'The sum of 5 consecutive odd numbers in an A.P. is 145. What is the largest of these 5 numbers?\n\nएक समांतर श्रेणी में 5 क्रमागत विषम संख्याओं का योग 145 है। इनमें से सबसे बड़ी संख्या कौन-सी है?',
          options: ['29', '31', '33', '35'],
          correctAnswer: '33',
          explanation:
              'Middle (3rd) term = 145 / 5 = 29. Series: 25, 27, 29, 31, 33. Largest number = 33. Option (C).',
        ),
        QuestionModel(
          id: 'ap_q21_mts_railway',
          topicId: 'ap_sum',
          examBadge: 'SSC MTS / Railway',
          difficulty: 2,
          prompt:
              'If the sum of the first 10 terms of an A.P. is equal to the sum of its first 15 terms, then what is the sum of its first 25 terms?\n\nयदि किसी समांतर श्रेणी के प्रथम 10 पदों का योग उसके प्रथम 15 पदों के योग के बराबर है, तो उसके प्रथम 25 पदों का योग क्या होगा?',
          options: ['25', '1', '0', '−25'],
          correctAnswer: '0',
          explanation:
              'Standard Identity: If Sₚ = S_q (for p ≠ q), then Sₚ₊_q = 0. Here p = 10, q = 15 ⇒ S₂₅ = 0. Option (C).',
        ),
      ],
    ),

    // =========================================================================
    // CONCEPT 5: QUICK REVISION FORMULA TABLE & PROPERTIES | त्वरित सूत्र तालिका
    // =========================================================================
    ConceptFormulaModel(
      id: 'ap_concept_5_quick_revision',
      pillar: ConceptPillar.arithmeticProgression,
      title: 'Concept 5: Quick Revision Cheat Sheet',
      subtitle: 'त्वरित सूत्र तालिका, A.P. गुणधर्म एवं परीक्षा रामबाण नियम',
      formula: 'd = aₙ − aₙ₋₁  |  Tₙ = a + (n−1)d  |  n = [(l−a)/d]+1  |  Sₙ = (n/2)(a+l)',
      diagramType: null,
      keyConditions: [
        'Common Difference: d = a₂ − a₁ = aₙ − aₙ₋₁ (Constant for all consecutive pairs).',
        'n-th Term: Tₙ = a + (n − 1)d; From end: Tₙ\' = l − (n − 1)d.',
        'Number of Terms: n = [(l − a) / d] + 1 (Essential for divisibility count questions).',
        'Sum of n Terms: Sₙ = (n/2)[2a + (n − 1)d] = (n/2)(a + l) = n × Average.',
        'Term from Sum: Tₙ = Sₙ − Sₙ₋₁.',
        '3 Terms Assumption: Choose (a − d), a, (a + d) with sum = 3a (simplifies algebra).',
        '4 Terms Assumption: Choose (a − 3d), (a − d), (a + d), (a + 3d) with common difference 2d.',
        'Linearity Property: If a constant k is added, subtracted, multiplied or divided to each term of an A.P., the resulting sequence remains an A.P.',
      ],
      explanation:
          'Mastering these 8 standard formulas and identities allows solving any Tier-I or Tier-II Arithmetic Progression problem in under 30 seconds without lengthy scratch calculations.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'Three numbers are in A.P. whose sum is 21 and their product is 315. Find the numbers.',
          steps: [
            'Step 1: Let the three terms be (a − d), a, and (a + d).',
            'Step 2: Sum = (a − d) + a + (a + d) = 3a = 21 ⇒ a = 7.',
            'Step 3: Product = (7 − d) × 7 × (7 + d) = 315 ⇒ (49 − d²) × 7 = 315.',
            'Step 4: 49 − d² = 45 ⇒ d² = 4 ⇒ d = ±2.',
            'Step 5: The numbers are 5, 7, 9.',
          ],
          answer: '5, 7, 9',
          shortcutTip:
              'Always use (a − d), a, (a + d). The middle term is immediately Sum / 3 = 21 / 3 = 7!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'ap_q22_revision',
          topicId: 'ap_revision',
          examBadge: 'SSC CGL',
          difficulty: 1,
          prompt:
              'If each term of an A.P. 3, 7, 11, 15, ... is multiplied by 4, what will be the common difference of the new A.P.?\n\nयदि समांतर श्रेणी 3, 7, 11, 15, ... के प्रत्येक पद को 4 से गुणा किया जाए, तो नई समांतर श्रेणी का सार्व अंतर क्या होगा?',
          options: ['4', '8', '12', '16'],
          correctAnswer: '16',
          explanation:
              'Original common difference d = 7 − 3 = 4. When every term of an A.P. is multiplied by k, the new common difference becomes k × d = 4 × 4 = 16. Option (D).',
        ),
      ],
    ),
  ];
}
