import '../models/concept_formula_model.dart';
import '../models/math_models.dart';

class FractionPercentageConceptFormulas {
  static final List<ConceptFormulaModel> formulas = [
    // =========================================================================
    // CONCEPT 1: STANDARD FRACTION-PERCENTAGE CONVERSION CHART (1/1 to 1/20)
    // =========================================================================
    ConceptFormulaModel(
      id: 'frac_concept_1_standard_chart',
      pillar: ConceptPillar.fractionPercentage,
      title: 'Concept 1: Standard Fraction-Percentage Chart',
      subtitle: 'मानक भिन्न–प्रतिशत तालिका (1/1 से 1/20 तक)',
      formula: 'Fraction (1/n) × 100 = Percentage (%) | 5-Second Mental Math Rule',
      diagramType: null,
      keyConditions: [
        'Core Speed Rule: Converting awkward decimals and mixed percentages (like 16.66%, 14.28%, 12.5%, 8.33%) directly into standard fractions reduces 60-second pen-and-paper calculations into 5-second mental operations.',
        '1/1 = 100% | 1/2 = 50% | 1/3 = 33 ⅓% (33.33%) | 1/4 = 25%',
        '1/5 = 20% | 1/6 = 16 ⅔% (16.66%) | 1/7 = 14 2/7% (14.28%) | 1/8 = 12 ½% (12.5%)',
        '1/9 = 11 1/9% (11.11%) | 1/10 = 10% | 1/11 = 9 1/11% (9.09%) | 1/12 = 8 ⅓% (8.33%)',
        '1/13 = 7 9/13% (7.69%) | 1/14 = 7 1/7% (7.14%) | 1/15 = 6 ⅔% (6.66%) | 1/16 = 6 ¼% (6.25%)',
        '1/17 = 5 15/17% (5.88%) | 1/18 = 5 5/9% (5.55%) | 1/19 = 5 5/19% (5.26%) | 1/20 = 5%',
        'Pattern 1/9 vs 1/11: 1/9 has multiples of 11.11% (repeats 11), while 1/11 has multiples of 9.09% (repeats 09)!',
      ],
      explanation:
          'In competitive exams like SSC CGL, CHSL, Railway NTPC, and Banking, examiners craft questions with awkward percentages that look intimidating (e.g. 16.66% of 480). When converted to 1/6, it simply becomes 480 ÷ 6 = 80 without any scratch work.',
      solvedExamples: [
        SolvedExampleModel(
          problem: 'Find the value of: 16.66% of 480 + 14.28% of 350.',
          steps: [
            'Step 1: Replace awkward percentages with their exact fractional equivalents.',
            'Step 2: 16.66% = 1/6 and 14.28% = 1/7.',
            'Step 3: Expression becomes: (1/6) × 480 + (1/7) × 350.',
            'Step 4: (480 / 6) + (350 / 7) = 80 + 50 = 130.',
          ],
          answer: '130',
          shortcutTip:
              'Mental Step: 480/6 = 80, 350/7 = 50. Sum = 80 + 50 = 130 in under 3 seconds!',
        ),
        SolvedExampleModel(
          problem: 'Evaluate: 6.25% of 1600 + 6.66% of 450.',
          steps: [
            'Step 1: Recall fractional conversions: 6.25% = 1/16 and 6.66% = 1/15.',
            'Step 2: Substitute: (1/16) × 1600 + (1/15) × 450.',
            'Step 3: 1600 / 16 = 100, and 450 / 15 = 30.',
            'Step 4: 100 + 30 = 130.',
          ],
          answer: '130',
          shortcutTip:
              'Direct division: 1600/16 = 100; 450/15 = 30; 100 + 30 = 130!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'frac_q1_cgl',
          topicId: 'frac_standard',
          examBadge: 'SSC CGL',
          difficulty: 1,
          prompt:
              'Find the value of: 37.5% of 640 + 66.66% of 270 = ?\n\nमान ज्ञात कीजिए: 640 का 37.5% + 270 का 66.66% = ?',
          options: ['400', '420', '440', '460'],
          correctAnswer: '420',
          explanation:
              '37.5% = 3/8, 66.66% = 2/3. Expression = (3/8) × 640 + (2/3) × 270 = 240 + 180 = 420. Option (B).',
        ),
        QuestionModel(
          id: 'frac_q2_chsl',
          topicId: 'frac_standard',
          examBadge: 'SSC CHSL',
          difficulty: 1,
          prompt:
              'Simplify: 16.66% of 480 + 14.28% of 350 = ?\n\nसरल कीजिए: 480 का 16.66% + 350 का 14.28% = ?',
          options: ['120', '125', '130', '140'],
          correctAnswer: '130',
          explanation:
              '16.66% = 1/6, 14.28% = 1/7. Expression = (1/6) × 480 + (1/7) × 350 = 80 + 50 = 130. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q3_ntpc',
          topicId: 'frac_standard',
          examBadge: 'RRB NTPC',
          difficulty: 1,
          prompt:
              'Evaluate: 62.5% of 512 − 33.33% of 240 = ?\n\nमान निकालिए: 512 का 62.5% − 240 का 33.33% = ?',
          options: ['220', '240', '260', '280'],
          correctAnswer: '240',
          explanation:
              '62.5% = 5/8, 33.33% = 1/3. Expression = (5/8) × 512 − (1/3) × 240 = 320 − 80 = 240. Option (B).',
        ),
        QuestionModel(
          id: 'frac_q4_ibps',
          topicId: 'frac_standard',
          examBadge: 'IBPS Clerk',
          difficulty: 1,
          prompt:
              'Find the value of: 83.33% of 720 + 12.5% of 400 = ?\n\nमान ज्ञात कीजिए: 720 का 83.33% + 400 का 12.5% = ?',
          options: ['600', '625', '650', '675'],
          correctAnswer: '650',
          explanation:
              '83.33% = 5/6, 12.5% = 1/8. Expression = (5/6) × 720 + (1/8) × 400 = 600 + 50 = 650. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q5_cpo',
          topicId: 'frac_standard',
          examBadge: 'SSC CPO',
          difficulty: 1,
          prompt:
              'Simplify: 28.57% of 490 + 44.44% of 270 = ?\n\nसरल कीजिए: 490 का 28.57% + 270 का 44.44% = ?',
          options: ['240', '250', '260', '270'],
          correctAnswer: '260',
          explanation:
              '28.57% = 2/7, 44.44% = 4/9. Expression = (2/7) × 490 + (4/9) × 270 = 140 + 120 = 260. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q6_cgl',
          topicId: 'frac_standard',
          examBadge: 'SSC CGL',
          difficulty: 1,
          prompt:
              'Find the value of: 87.5% of 960 − 11.11% of 810 = ?\n\nमान ज्ञात कीजिए: 960 का 87.5% − 810 का 11.11% = ?',
          options: ['720', '750', '780', '800'],
          correctAnswer: '750',
          explanation:
              '87.5% = 7/8, 11.11% = 1/9. Expression = (7/8) × 960 − (1/9) × 810 = 840 − 90 = 750. Option (B).',
        ),
      ],
    ),

    // =========================================================================
    // CONCEPT 2: HIGH-FREQUENCY DERIVED FRACTIONS
    // =========================================================================
    ConceptFormulaModel(
      id: 'frac_concept_2_derived_fractions',
      pillar: ConceptPillar.fractionPercentage,
      title: 'Concept 2: High-Frequency Derived Fractions',
      subtitle: 'अति-महत्वपूर्ण व्युत्पन्न भिन्न एवं उनके गुणन खंड',
      formula: 'k / n = k × (1 / n) | Multiples of 1/7, 1/8, 1/9, 1/11, 1/12',
      diagramType: null,
      keyConditions: [
        'Multiples of 1/8 (12.5%): 3/8 = 37.5% | 5/8 = 62.5% | 7/8 = 87.5%',
        'Multiples of 1/7 (14.28%): 2/7 = 28.57% | 3/7 = 42.85% | 4/7 = 57.14% | 5/7 = 71.42%',
        'Multiples of 1/9 (11.11%): 2/9 = 22.22% | 4/9 = 44.44% | 5/9 = 55.55% | 7/9 = 77.77%',
        'Multiples of 1/11 (9.09%): 2/11 = 18.18% | 3/11 = 27.27% | 4/11 = 36.36% | 5/11 = 45.45% | 7/11 = 63.63%',
        'Multiples of 1/12 (8.33%): 5/12 = 41.66% | 7/12 = 58.33% | 11/12 = 91.66%',
        'Multiples of 1/16 (6.25%): 3/16 = 18.75% | 5/16 = 31.25%',
        'Other standard forms: 2/3 = 66.66% | 3/4 = 75% | 5/6 = 83.33%',
      ],
      explanation:
          'Derived fractions are created by multiplying base fractions. For instance, knowing 1/7 = 14.28% gives 4/7 = 4 × 14.28% = 57.14% immediately. Recognizing these patterns eliminates memorizing dozens of arbitrary decimal values.',
      solvedExamples: [
        SolvedExampleModel(
          problem: 'Evaluate: 57.14% of 630 + 9.09% of 550.',
          steps: [
            'Step 1: Identify derived fractions: 57.14% = 4/7 (since 4 × 14.28% = 57.14%).',
            'Step 2: 9.09% = 1/11.',
            'Step 3: Calculate: (4/7) × 630 + (1/11) × 550.',
            'Step 4: (4 × 90) + (50) = 360 + 50 = 410.',
          ],
          answer: '410',
          shortcutTip:
              'Mental calculation: 630/7 = 90; 90 × 4 = 360; 550/11 = 50; 360 + 50 = 410!',
        ),
        SolvedExampleModel(
          problem: 'Simplify: 42.85% of 420 + 8.33% of 360.',
          steps: [
            'Step 1: 42.85% = 3/7; 8.33% = 1/12.',
            'Step 2: (3/7) × 420 + (1/12) × 360.',
            'Step 3: (3 × 60) + (30) = 180 + 30 = 210.',
          ],
          answer: '210',
          shortcutTip:
              '3 × 60 = 180; 360/12 = 30; 180 + 30 = 210 in 2 seconds!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'frac_q7_groupd',
          topicId: 'frac_derived',
          examBadge: 'RRB Group D',
          difficulty: 1,
          prompt:
              'Evaluate: 57.14% of 630 + 9.09% of 550 = ?\n\nमान निकालिए: 630 का 57.14% + 550 का 9.09% = ?',
          options: ['390', '400', '410', '420'],
          correctAnswer: '410',
          explanation:
              '57.14% = 4/7, 9.09% = 1/11. Expression = (4/7) × 630 + (1/11) × 550 = 360 + 50 = 410. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q8_sbipo',
          topicId: 'frac_derived',
          examBadge: 'SBI PO',
          difficulty: 2,
          prompt:
              'Simplify: 42.85% of 420 + 8.33% of 360 = ?\n\nसरल कीजिए: 420 का 42.85% + 360 का 8.33% = ?',
          options: ['190', '200', '210', '220'],
          correctAnswer: '210',
          explanation:
              '42.85% = 3/7, 8.33% = 1/12. Expression = (3/7) × 420 + (1/12) × 360 = 180 + 30 = 210. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q9_mts',
          topicId: 'frac_derived',
          examBadge: 'SSC MTS',
          difficulty: 1,
          prompt:
              'Find the value of: 18.18% of 440 + 22.22% of 450 = ?\n\nमान ज्ञात कीजिए: 440 का 18.18% + 450 का 22.22% = ?',
          options: ['160', '170', '180', '190'],
          correctAnswer: '180',
          explanation:
              '18.18% = 2/11, 22.22% = 2/9. Expression = (2/11) × 440 + (2/9) × 450 = 80 + 100 = 180. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q10_alp',
          topicId: 'frac_derived',
          examBadge: 'RRB ALP',
          difficulty: 1,
          prompt:
              'Evaluate: 6.25% of 1600 + 6.66% of 450 = ?\n\nमान निकालिए: 1600 का 6.25% + 450 का 6.66% = ?',
          options: ['120', '130', '140', '150'],
          correctAnswer: '130',
          explanation:
              '6.25% = 1/16, 6.66% = 1/15. Expression = (1/16) × 1600 + (1/15) × 450 = 100 + 30 = 130. Option (B).',
        ),
        QuestionModel(
          id: 'frac_q11_chsl',
          topicId: 'frac_derived',
          examBadge: 'SSC CHSL',
          difficulty: 2,
          prompt:
              'Simplify: 55.55% of 360 + 27.27% of 330 = ?\n\nसरल कीजिए: 360 का 55.55% + 330 का 27.27% = ?',
          options: ['270', '280', '290', '300'],
          correctAnswer: '290',
          explanation:
              '55.55% = 5/9, 27.27% = 3/11. Expression = (5/9) × 360 + (3/11) × 330 = 200 + 90 = 290. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q12_ibpspo',
          topicId: 'frac_derived',
          examBadge: 'IBPS PO',
          difficulty: 2,
          prompt:
              'Find the value of: 71.42% of 280 + 7.69% of 260 = ?\n\nमान ज्ञात कीजिए: 280 का 71.42% + 260 का 7.69% = ?',
          options: ['200', '210', '220', '240'],
          correctAnswer: '220',
          explanation:
              '71.42% = 5/7, 7.69% = 1/13. Expression = (5/7) × 280 + (1/13) × 260 = 200 + 20 = 220. Option (C).',
        ),
      ],
    ),

    // =========================================================================
    // CONCEPT 3: BASE > 100% & COMPOUNDED PERCENTAGES
    // =========================================================================
    ConceptFormulaModel(
      id: 'frac_concept_3_base_shift',
      pillar: ConceptPillar.fractionPercentage,
      title: 'Concept 3: Base > 100% & Cascaded Percentages',
      subtitle: '100% से अधिक प्रतिशत का विभाजन एवं सतत प्रतिशत गणना',
      formula: '(100 + x)% = 1 + Fraction | A% of B% of C = (f₁ · f₂) × C',
      diagramType: null,
      keyConditions: [
        'Percentages > 100% are decomposed as 100% + fractional residue.',
        '116.66% = 100% + 16.66% = 1 + 1/6 = 7/6.',
        '112.5% = 100% + 12.5% = 1 + 1/8 = 9/8.',
        '133.33% = 100% + 33.33% = 1 + 1/3 = 4/3.',
        '137.5% = 100% + 37.5% = 1 + 3/8 = 11/8.',
        '114.28% = 100% + 14.28% = 1 + 1/7 = 8/7.',
        '216.66% = 200% + 16.66% = 2 + 1/6 = 13/6.',
        'Compounded % of %: A% of B% of C = f_A × f_B × C. Cancel out numerators and denominators before multiplying.',
      ],
      explanation:
          'When dealing with percentages over 100% like 116.66% or 216.66%, split into integer + standard fraction. For cascading operations (A% of B% of C), multiply all fractions first; cross-cancellation frequently reduces the whole problem to trivial arithmetic.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'Find the value of: 116.66% of 360 + 112.5% of 240.',
          steps: [
            'Step 1: Decompose: 116.66% = 100% + 16.66% = 1 + 1/6 = 7/6.',
            'Step 2: Decompose: 112.5% = 100% + 12.5% = 1 + 1/8 = 9/8.',
            'Step 3: (7/6) × 360 = 7 × 60 = 420.',
            'Step 4: (9/8) × 240 = 9 × 30 = 270.',
            'Step 5: 420 + 270 = 690.',
          ],
          answer: '690',
          shortcutTip:
              '7 × 60 = 420; 9 × 30 = 270; 420 + 270 = 690!',
        ),
        SolvedExampleModel(
          problem:
              'Evaluate: 66.66% of 37.5% of 480.',
          steps: [
            'Step 1: Convert both percentages: 66.66% = 2/3, 37.5% = 3/8.',
            'Step 2: Multiply fractions: (2/3) × (3/8) = 2/8 = 1/4.',
            'Step 3: (1/4) × 480 = 120.',
          ],
          answer: '120',
          shortcutTip:
              'The 3 in 2/3 cancels with 3 in 3/8: result is 2/8 = 1/4. 480 / 4 = 120 in 1 second!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'frac_q13_cgl',
          topicId: 'frac_shift',
          examBadge: 'SSC CGL',
          difficulty: 2,
          prompt:
              'Evaluate: 41.66% of 480 − 7.14% of 280 = ?\n\nमान निकालिए: 480 का 41.66% − 280 का 7.14% = ?',
          options: ['160', '170', '180', '190'],
          correctAnswer: '180',
          explanation:
              '41.66% = 5/12, 7.14% = 1/14. Expression = (5/12) × 480 − (1/14) × 280 = 200 − 20 = 180. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q14_ntpc',
          topicId: 'frac_shift',
          examBadge: 'RRB NTPC',
          difficulty: 2,
          prompt:
              'Simplify: 58.33% of 720 + 15% of 400 = ?\n\nसरल कीजिए: 720 का 58.33% + 400 का 15% = ?',
          options: ['460', '480', '500', '520'],
          correctAnswer: '480',
          explanation:
              '58.33% = 7/12, 15% = 3/20. Expression = (7/12) × 720 + (3/20) × 400 = 420 + 60 = 480. Option (B).',
        ),
        QuestionModel(
          id: 'frac_q15_cgl_tier2',
          topicId: 'frac_shift',
          examBadge: 'SSC CGL Tier-II',
          difficulty: 2,
          prompt:
              'Find the value of: 116.66% of 360 + 112.5% of 240 = ?\n\nमान ज्ञात कीजिए: 360 का 116.66% + 240 का 112.5% = ?',
          options: ['660', '680', '690', '710'],
          correctAnswer: '690',
          explanation:
              '116.66% = 7/6, 112.5% = 9/8. Expression = (7/6) × 360 + (9/8) × 240 = 420 + 270 = 690. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q16_cpo',
          topicId: 'frac_shift',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'Evaluate: 133.33% of 450 − 125% of 240 = ?\n\nमान निकालिए: 450 का 133.33% − 240 का 125% = ?',
          options: ['250', '280', '300', '320'],
          correctAnswer: '300',
          explanation:
              '133.33% = 4/3, 125% = 5/4. Expression = (4/3) × 450 − (5/4) × 240 = 600 − 300 = 300. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q17_sbiclerk',
          topicId: 'frac_shift',
          examBadge: 'SBI Clerk',
          difficulty: 2,
          prompt:
              'Simplify: 137.5% of 320 + 114.28% of 210 = ?\n\nसरल कीजिए: 320 का 137.5% + 210 का 114.28% = ?',
          options: ['640', '660', '680', '700'],
          correctAnswer: '680',
          explanation:
              '137.5% = 11/8, 114.28% = 8/7. Expression = (11/8) × 320 + (8/7) × 210 = 440 + 240 = 680. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q18_selpost',
          topicId: 'frac_shift',
          examBadge: 'SSC Selection Post',
          difficulty: 2,
          prompt:
              'Find the value of: 216.66% of 180 + 120% of 150 = ?\n\nमान ज्ञात कीजिए: 180 का 216.66% + 150 का 120% = ?',
          options: ['540', '550', '570', '590'],
          correctAnswer: '570',
          explanation:
              '216.66% = 13/6, 120% = 6/5. Expression = (13/6) × 180 + (6/5) × 150 = 390 + 180 = 570. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q19_cgl',
          topicId: 'frac_shift',
          examBadge: 'SSC CGL',
          difficulty: 2,
          prompt:
              'Evaluate: 66.66% of 37.5% of 480 = ?\n\nमान निकालिए: 480 के 37.5% का 66.66% = ?',
          options: ['100', '120', '140', '160'],
          correctAnswer: '120',
          explanation:
              '(2/3) × (3/8) × 480 = (1/4) × 480 = 120. Option (B).',
        ),
        QuestionModel(
          id: 'frac_q20_je',
          topicId: 'frac_shift',
          examBadge: 'RRB JE',
          difficulty: 2,
          prompt:
              'Simplify: 14.28% of 87.5% of 640 = ?\n\nसरल कीजिए: 640 के 87.5% का 14.28% = ?',
          options: ['60', '70', '80', '90'],
          correctAnswer: '80',
          explanation:
              '14.28% = 1/7, 87.5% = 7/8. Expression = (1/7) × (7/8) × 640 = (1/8) × 640 = 80. Option (C).',
        ),
      ],
    ),

    // =========================================================================
    // CONCEPT 4: SPEED SIMPLIFICATION DRILL (TIER-I & TIER-II)
    // =========================================================================
    ConceptFormulaModel(
      id: 'frac_concept_4_speed_drills',
      pillar: ConceptPillar.fractionPercentage,
      title: 'Concept 4: Speed Simplification Master Drill',
      subtitle: 'परीक्षा-स्तरीय मिश्रित सरलीकरण एवं मल्टी-स्टेप कैलकुलेशन',
      formula: 'Mental Fraction Substitution → Direct Factor Cancellation',
      diagramType: null,
      keyConditions: [
        'Notice common denominators: 36.36% (4/11) and 45.45% (5/11) share denominator 11.',
        '18.75% = 3/16 and 31.25% = 5/16 share denominator 16.',
        '77.77% = 7/9 and 63.63% = 7/11.',
        '91.66% = 11/12 and 5.88% = 1/17.',
        'Triple cascading multiplication: 12.5% of 16.66% of 14.28% of 3360 = (1/8) × (1/6) × (1/7) × 3360 = 3360 ÷ (8 × 6 × 7) = 3360 ÷ 336 = 10!',
      ],
      explanation:
          'Tier-I and Tier-II exams frequently combine 2 or 3 distinct fractions with matching factors in the target numbers. Spotting the common factor allows eliminating denominator products in one stroke.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'Evaluate: 12.5% of 16.66% of 14.28% of 3360.',
          steps: [
            'Step 1: Convert all three percentages: 12.5% = 1/8, 16.66% = 1/6, 14.28% = 1/7.',
            'Step 2: Chain product: (1/8) × (1/6) × (1/7) × 3360.',
            'Step 3: Denominator product: 8 × 6 × 7 = 8 × 42 = 336.',
            'Step 4: Divide: 3360 ÷ 336 = 10.',
          ],
          answer: '10',
          shortcutTip:
              '8 × 6 × 7 = 336. 3360 / 336 = 10. Solve in 3 seconds!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'frac_q21_ibpsclerk',
          topicId: 'frac_speed',
          examBadge: 'IBPS Clerk',
          difficulty: 2,
          prompt:
              'Find the value of: 36.36% of 550 + 45.45% of 220 = ?\n\nमान ज्ञात कीजिए: 550 का 36.36% + 220 का 45.45% = ?',
          options: ['280', '290', '300', '310'],
          correctAnswer: '300',
          explanation:
              '36.36% = 4/11, 45.45% = 5/11. Expression = (4/11) × 550 + (5/11) × 220 = 200 + 100 = 300. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q22_chsl',
          topicId: 'frac_speed',
          examBadge: 'SSC CHSL',
          difficulty: 2,
          prompt:
              'Evaluate: 18.75% of 640 + 31.25% of 320 = ?\n\nमान निकालिए: 640 का 18.75% + 320 का 31.25% = ?',
          options: ['200', '210', '220', '240'],
          correctAnswer: '220',
          explanation:
              '18.75% = 3/16, 31.25% = 5/16. Expression = (3/16) × 640 + (5/16) × 320 = 120 + 100 = 220. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q23_cgl',
          topicId: 'frac_speed',
          examBadge: 'SSC CGL',
          difficulty: 2,
          prompt:
              'Simplify: 77.77% of 450 − 63.63% of 220 = ?\n\nसरल कीजिए: 450 का 77.77% − 220 का 63.63% = ?',
          options: ['190', '200', '210', '220'],
          correctAnswer: '210',
          explanation:
              '77.77% = 7/9, 63.63% = 7/11. Expression = (7/9) × 450 − (7/11) × 220 = 350 − 140 = 210. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q24_ntpc',
          topicId: 'frac_speed',
          examBadge: 'RRB NTPC',
          difficulty: 2,
          prompt:
              'Find the value of: 91.66% of 240 + 5.88% of 340 = ?\n\nमान ज्ञात कीजिए: 240 का 91.66% + 340 का 5.88% = ?',
          options: ['220', '230', '240', '250'],
          correctAnswer: '240',
          explanation:
              '91.66% = 11/12, 5.88% = 1/17. Expression = (11/12) × 240 + (1/17) × 340 = 220 + 20 = 240. Option (C).',
        ),
        QuestionModel(
          id: 'frac_q25_cgl_tier2',
          topicId: 'frac_speed',
          examBadge: 'SSC CGL Tier-II',
          difficulty: 3,
          prompt:
              'Evaluate: 12.5% of 16.66% of 14.28% of 3360 = ?\n\nमान निकालिए: 3360 के 14.28% के 16.66% का 12.5% = ?',
          options: ['8', '10', '12', '15'],
          correctAnswer: '10',
          explanation:
              '(1/8) × (1/6) × (1/7) × 3360 = 3360 ÷ (8 × 6 × 7) = 3360 ÷ 336 = 10. Option (B).',
        ),
      ],
    ),
  ];
}
