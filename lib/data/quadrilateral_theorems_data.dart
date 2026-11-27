import '../models/concept_formula_model.dart';
import '../models/math_models.dart';

class QuadrilateralTheoremsData {
  static final List<ConceptFormulaModel> formulas = [
    // =========================================================================
    // THEOREM 1: MIDPOINTS OF DIAGONALS OF A TRAPEZIUM
    // =========================================================================
    ConceptFormulaModel(
      id: 'quad_midpoints_diagonals_trapezium',
      pillar: ConceptPillar.quadrilaterals,
      title: 'Midpoints of Diagonals of a Trapezium',
      subtitle: 'समलंब चतुर्भुज के विकर्णों के मध्य-बिंदुओं को मिलाने वाले रेखाखंड की लंबाई',
      formula: 'PQ = (AB − CD) / 2  (where AB ∥ CD and AB > CD)',
      diagramType: null,
      keyConditions: [
        'In a trapezium ABCD where AB ∥ CD and AB > CD, let P be the midpoint of diagonal AC and Q be the midpoint of diagonal BD.',
        'The length of line segment PQ is strictly equal to half the positive difference of the parallel sides: PQ = (AB − CD) / 2.',
        'Line segment PQ is parallel to both bases AB and CD: PQ ∥ AB ∥ CD.',
        'Important distinction: Do not confuse PQ with the median joining the midpoints of the non-parallel legs, which equals (AB + CD) / 2.',
        'If given non-parallel sides midpoint segment (Median M) and diagonal midpoints segment (PQ): AB = M + PQ, and CD = M − PQ.',
      ],
      explanation:
          'When the diagonals of a trapezium intersect, connecting their midpoints forms a segment strictly parallel to the parallel bases. Its length is exactly half the difference of the parallel sides. This theorem frequently appears in SSC CGL, CPO, and RRB NTPC examinations.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'In a trapezium ABCD, AB ∥ DC, AB = 26 cm, and DC = 14 cm. If P and Q are the midpoints of diagonals AC and BD respectively, find the length of PQ.',
          steps: [
            'Step 1: Identify given parallel sides: AB = 26 cm, DC = 14 cm.',
            'Step 2: Formula: PQ = (AB − DC) / 2.',
            'Step 3: PQ = (26 − 14) / 2 = 12 / 2 = 6 cm.',
          ],
          answer: '6 cm',
          shortcutTip:
              'Direct formula: Half of (26 − 14) = 12 / 2 = 6 cm in 2 seconds!',
        ),
        SolvedExampleModel(
          problem:
              'In a trapezium ABCD (AB ∥ CD), the line segment joining the midpoints of non-parallel sides is 18 cm, and the segment joining the midpoints of diagonals is 4 cm. Find the lengths of AB and CD.',
          steps: [
            'Step 1: Median of legs M = (AB + CD) / 2 = 18 cm ⇒ AB + CD = 36 cm.',
            'Step 2: Diagonals midpoints segment PQ = (AB − CD) / 2 = 4 cm ⇒ AB − CD = 8 cm.',
            'Step 3: Add both equations: 2 × AB = 44 ⇒ AB = 22 cm.',
            'Step 4: Subtract equations: 2 × CD = 28 ⇒ CD = 14 cm.',
          ],
          answer: 'AB = 22 cm, CD = 14 cm',
          shortcutTip:
              'Super Shortcut: Longer side = M + PQ = 18 + 4 = 22 cm; Shorter side = M − PQ = 18 − 4 = 14 cm!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'quad_trap_q1_cgl',
          topicId: 'quad_trapezium',
          examBadge: 'SSC CGL Tier-1',
          difficulty: 1,
          prompt:
              'In a trapezium ABCD, AB is parallel to DC, AB = 26 cm, and DC = 14 cm. If P and Q are the midpoints of diagonals AC and BD respectively, find the length of PQ.\n\nसमलंब चतुर्भुज ABCD में AB ∥ DC, AB = 26 सेमी और DC = 14 सेमी है। यदि P और Q विकर्णों AC और BD के मध्य-बिंदु हैं, तो PQ की लंबाई ज्ञात कीजिए।',
          options: ['20 cm', '6 cm', '12 cm', '8 cm'],
          correctAnswer: '6 cm',
          explanation:
              'PQ = (AB − DC) / 2 = (26 − 14) / 2 = 12 / 2 = 6 cm. Option (B).',
        ),
        QuestionModel(
          id: 'quad_trap_q2_ntpc',
          topicId: 'quad_trapezium',
          examBadge: 'RRB NTPC CBT-1',
          difficulty: 1,
          prompt:
              'In a trapezium PQRS, PQ ∥ RS with PQ = 32 cm and RS = 18 cm. M and N are the midpoints of diagonals PR and QS respectively. What is the length of MN?\n\nसमलंब चतुर्भुज PQRS में PQ ∥ RS, PQ = 32 सेमी और RS = 18 सेमी है। M और N विकर्णों PR और QS के मध्य-बिंदु हैं। MN की लंबाई क्या है?',
          options: ['7 cm', '14 cm', '25 cm', '9 cm'],
          correctAnswer: '7 cm',
          explanation:
              'MN = (PQ − RS) / 2 = (32 − 18) / 2 = 14 / 2 = 7 cm. Option (A).',
        ),
        QuestionModel(
          id: 'quad_trap_q3_chsl',
          topicId: 'quad_trapezium',
          examBadge: 'SSC CHSL Tier-1',
          difficulty: 1,
          prompt:
              'In trapezium ABCD (AB ∥ CD, AB > CD), the distance between the midpoints of the two diagonals is 5.5 cm. If the shorter parallel side CD is 13 cm, find the length of AB.\n\nसमलंब चतुर्भुज ABCD (AB ∥ CD) में दोनों विकर्णों के मध्य-बिंदुओं के बीच की दूरी 5.5 सेमी है। यदि छोटी भुजा CD = 13 सेमी है, तो AB की लंबाई ज्ञात कीजिए।',
          options: ['18.5 cm', '22 cm', '24 cm', '26 cm'],
          correctAnswer: '24 cm',
          explanation:
              '(AB − CD) / 2 = 5.5 ⇒ AB − 13 = 11 ⇒ AB = 24 cm. Option (C).',
        ),
        QuestionModel(
          id: 'quad_trap_q4_cpo',
          topicId: 'quad_trapezium',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'In trapezium PQRS, PQ ∥ RS and PQ > RS. The length of the line segment joining the midpoints of diagonals PR and QS is 4.5 cm. If the sum of the lengths of the two parallel sides is 35 cm, find the length of the longer parallel side PQ.\n\nसमलंब चतुर्भुज PQRS में विकर्णों के मध्य-बिंदुओं को मिलाने वाले रेखाखंड की लंबाई 4.5 सेमी है। यदि दोनों समांतर भुजाओं का योग 35 सेमी है, तो लंबी भुजा PQ की लंबाई ज्ञात कीजिए।',
          options: ['22 cm', '24 cm', '19.5 cm', '26 cm'],
          correctAnswer: '22 cm',
          explanation:
              '(PQ − RS) / 2 = 4.5 ⇒ PQ − RS = 9. Given PQ + RS = 35. Adding both: 2PQ = 44 ⇒ PQ = 22 cm. Option (A).',
        ),
        QuestionModel(
          id: 'quad_trap_q5_groupd',
          topicId: 'quad_trapezium',
          examBadge: 'RRB Group D',
          difficulty: 2,
          prompt:
              'The parallel sides of a trapezium are in the ratio 7 : 3. If the segment joining the midpoints of its diagonals measures 10 cm, find the length of the shorter parallel side.\n\nसमलंब चतुर्भुज की समांतर भुजाओं का अनुपात 7 : 3 है। यदि इसके विकर्णों के मध्य-बिंदुओं को मिलाने वाला रेखाखंड 10 सेमी है, तो छोटी भुजा की लंबाई ज्ञात कीजिए।',
          options: ['12 cm', '15 cm', '20 cm', '35 cm'],
          correctAnswer: '15 cm',
          explanation:
              'Let sides be 7x and 3x. (7x − 3x) / 2 = 10 ⇒ 2x = 10 ⇒ x = 5. Shorter side = 3(5) = 15 cm. Option (B).',
        ),
        QuestionModel(
          id: 'quad_trap_q6_ntpc_cbt2',
          topicId: 'quad_trapezium',
          examBadge: 'RRB NTPC CBT-2',
          difficulty: 2,
          prompt:
              'In a trapezium ABCD (AB ∥ CD), the ratio of parallel sides AB : CD is 5 : 2. If the distance between the midpoints of the two diagonals is 9 cm, find the length of the line segment joining the midpoints of the non-parallel sides AD and BC.\n\nसमलंब चतुर्भुज ABCD में समांतर भुजाओं AB : CD का अनुपात 5 : 2 है। यदि विकर्णों के मध्य-बिंदुओं की दूरी 9 सेमी है, तो असमांतर भुजाओं के मध्य-बिंदुओं को मिलाने वाले रेखाखंड की लंबाई ज्ञात कीजिए।',
          options: ['18 cm', '21 cm', '24 cm', '27 cm'],
          correctAnswer: '21 cm',
          explanation:
              '(5x − 2x) / 2 = 1.5x = 9 ⇒ x = 6. AB = 30 cm, CD = 12 cm. Median of non-parallel legs = (30 + 12) / 2 = 21 cm. Option (B).',
        ),
        QuestionModel(
          id: 'quad_trap_q7_cgl_tier2',
          topicId: 'quad_trapezium',
          examBadge: 'SSC CGL Tier-2',
          difficulty: 3,
          prompt:
              'In a trapezium ABCD (AB ∥ CD), the sum of the parallel sides is 40 cm and the segment joining the midpoints of the diagonals is 6 cm. What is the ratio of the longer parallel side to the shorter parallel side?\n\nसमलंब चतुर्भुज ABCD में समांतर भुजाओं का योग 40 सेमी है और विकर्णों के मध्य-बिंदुओं का रेखाखंड 6 सेमी है। लंबी भुजा और छोटी भुजा का अनुपात क्या है?',
          options: ['13 : 7', '11 : 9', '5 : 3', '7 : 3'],
          correctAnswer: '13 : 7',
          explanation:
              'AB + CD = 40 and AB − CD = 12. Solving gives AB = 26 cm, CD = 14 cm. Ratio = 26 : 14 = 13 : 7. Option (A).',
        ),
        QuestionModel(
          id: 'quad_trap_q8_cgl_tier2',
          topicId: 'quad_trapezium',
          examBadge: 'SSC CGL Tier-2',
          difficulty: 3,
          prompt:
              'In a trapezium ABCD with AB ∥ CD, the line segment joining the midpoints of non-parallel sides AD and BC is 18 cm, while the segment joining the midpoints of diagonals AC and BD is 4 cm. Find the lengths of AB and CD.\n\nसमलंब चतुर्भुज ABCD में असमांतर भुजाओं के मध्य-बिंदुओं का रेखाखंड 18 सेमी है तथा विकर्णों के मध्य-बिंदुओं का रेखाखंड 4 सेमी है। AB और CD की लंबाइयाँ ज्ञात कीजिए।',
          options: ['20 cm, 16 cm', '22 cm, 14 cm', '24 cm, 12 cm', '26 cm, 10 cm'],
          correctAnswer: '22 cm, 14 cm',
          explanation:
              '(AB + CD) / 2 = 18 ⇒ AB + CD = 36; (AB − CD) / 2 = 4 ⇒ AB − CD = 8. Adding gives 2AB = 44 ⇒ AB = 22 cm, CD = 14 cm. Option (B).',
        ),
      ],
    ),

    // =========================================================================
    // THEOREM 2: TANGENCY POINTS OF TWO INCIRCLES IN A QUADRILATERAL
    // =========================================================================
    ConceptFormulaModel(
      id: 'quad_tangency_two_incircles',
      pillar: ConceptPillar.quadrilaterals,
      title: 'Tangency Points of Two Incircles in a Quadrilateral',
      subtitle: 'चतुर्भुज के विकर्ण पर बने दो अंतःवृत्तों के स्पर्श-बिंदुओं के बीच की दूरी',
      formula: 'PQ = |(a + b) − (c + d)| / 2',
      diagramType: null,
      keyConditions: [
        'Consider quadrilateral ABCD with side lengths AB = a, BC = b, CD = c, and DA = d divided into △ABD and △BCD by diagonal BD.',
        'If the incircle of △ABD touches diagonal BD at P, and the incircle of △BCD touches BD at Q:',
        'Distance PQ between the tangency points = |(a + b) − (c + d)| / 2.',
        'Here (a + b) is the sum of adjacent sides meeting at vertex B, and (c + d) is the sum of adjacent sides meeting at vertex D.',
        'Special Touchpoint Case: If both incircles touch the common diagonal at the EXACT same point (PQ = 0), then a + b = c + d.',
      ],
      explanation:
          'In advanced geometry, a diagonal splits a quadrilateral into two triangles, each possessing an incircle. By applying tangent properties from vertices B and D, the distance between touchpoints on the diagonal simplifies cleanly to half the difference between the side sums (a + b) and (c + d).',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'In quadrilateral ABCD, AB = 15 cm, BC = 19 cm, CD = 11 cm, DA = 13 cm. Incircles of △ABD and △BCD touch diagonal BD at P and Q. Find length PQ.',
          steps: [
            'Step 1: Identify sides meeting at vertex B: a + b = 15 + 19 = 34 cm.',
            'Step 2: Identify sides meeting at vertex D: c + d = 11 + 13 = 24 cm.',
            'Step 3: Apply formula: PQ = |(a + b) − (c + d)| / 2.',
            'Step 4: PQ = |34 − 24| / 2 = 10 / 2 = 5 cm.',
          ],
          answer: '5 cm',
          shortcutTip:
              'Direct shortcut: |(15 + 19) − (11 + 13)| / 2 = 10 / 2 = 5 cm in 3 seconds!',
        ),
        SolvedExampleModel(
          problem:
              'In quadrilateral ABCD, the incircles of △ABD and △BCD touch common diagonal BD at the same point. If AB = 13 cm, BC = 17 cm, and CD = 11 cm, find side DA.',
          steps: [
            'Step 1: When touchpoints coincide, PQ = 0.',
            'Step 2: Therefore: a + b = c + d.',
            'Step 3: 13 + 17 = 11 + DA ⇒ 30 = 11 + DA.',
            'Step 4: DA = 30 − 11 = 19 cm.',
          ],
          answer: 'DA = 19 cm',
          shortcutTip:
              'Same point condition: 13 + 17 = 11 + DA ⇒ DA = 30 − 11 = 19 cm!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'quad_incircles_q9_chsl',
          topicId: 'quad_incircles',
          examBadge: 'SSC CHSL Tier-1',
          difficulty: 1,
          prompt:
              'In a quadrilateral ABCD, AB = 15 cm, BC = 19 cm, CD = 11 cm, and DA = 13 cm. The incircles of △ABD and △BCD touch the diagonal BD at points P and Q respectively. Find the length of segment PQ.\n\nचतुर्भुज ABCD में AB = 15 सेमी, BC = 19 सेमी, CD = 11 सेमी और DA = 13 सेमी है। △ABD और △BCD के अंतःवृत्त विकर्ण BD को क्रमशः P और Q पर स्पर्श करते हैं। रेखाखंड PQ की लंबाई ज्ञात कीजिए।',
          options: ['3 cm', '4 cm', '5 cm', '2.5 cm'],
          correctAnswer: '5 cm',
          explanation:
              'PQ = |(15 + 19) − (11 + 13)| / 2 = |34 − 24| / 2 = 10 / 2 = 5 cm. Option (C).',
        ),
        QuestionModel(
          id: 'quad_incircles_q10_ntpc',
          topicId: 'quad_incircles',
          examBadge: 'RRB NTPC CBT-1',
          difficulty: 1,
          prompt:
              'In a quadrilateral ABCD, AB = 10 cm, BC = 14 cm, CD = 8 cm, and DA = 12 cm. If the incircles of △ABD and △BCD touch diagonal BD at P and Q respectively, find PQ.\n\nचतुर्भुज ABCD में AB = 10 सेमी, BC = 14 सेमी, CD = 8 सेमी और DA = 12 सेमी है। यदि अंतःवृत्त विकर्ण BD को P और Q पर स्पर्श करते हैं, तो PQ ज्ञात कीजिए।',
          options: ['1 cm', '2 cm', '3 cm', '4 cm'],
          correctAnswer: '2 cm',
          explanation:
              'PQ = |(10 + 14) − (8 + 12)| / 2 = |24 − 20| / 2 = 4 / 2 = 2 cm. Option (B).',
        ),
        QuestionModel(
          id: 'quad_incircles_q11_cgl',
          topicId: 'quad_incircles',
          examBadge: 'SSC CGL Tier-1',
          difficulty: 1,
          prompt:
              'In a quadrilateral PQRS, PQ = 21 cm, QR = 25 cm, RS = 17 cm, and SP = 19 cm. The incircles of △PQS and △RQS touch the diagonal QS at points M and N respectively. What is the length of MN?\n\nचतुर्भुज PQRS में PQ = 21 सेमी, QR = 25 सेमी, RS = 17 सेमी और SP = 19 सेमी है। △PQS और △RQS के अंतःवृत्त विकर्ण QS को M और N पर स्पर्श करते हैं। MN की लंबाई क्या है?',
          options: ['3.5 cm', '4 cm', '5 cm', '6 cm'],
          correctAnswer: '5 cm',
          explanation:
              'MN = |(21 + 25) − (17 + 19)| / 2 = |46 − 36| / 2 = 10 / 2 = 5 cm. Option (C).',
        ),
        QuestionModel(
          id: 'quad_incircles_q12_cgl_tier2',
          topicId: 'quad_incircles',
          examBadge: 'SSC CGL Tier-2',
          difficulty: 2,
          prompt:
              'In a quadrilateral ABCD, diagonal BD divides it into △ABD and △BCD whose incircles touch BD at P and Q respectively. If AB = 12 cm, BC = 16 cm, DA = 18 cm, and PQ = 3 cm (with AB + BC > CD + DA), find the length of side CD.\n\nचतुर्भुज ABCD में विकर्ण BD इसे दो त्रिभुजों में बांटता है जिनके अंतःवृत्त BD को P और Q पर स्पर्श करते हैं। यदि AB = 12 सेमी, BC = 16 सेमी, DA = 18 सेमी और PQ = 3 सेमी है, तो भुजा CD की लंबाई ज्ञात कीजिए।',
          options: ['4 cm', '6 cm', '8 cm', '10 cm'],
          correctAnswer: '4 cm',
          explanation:
              '[(12 + 16) − (CD + 18)] / 2 = 3 ⇒ 28 − CD − 18 = 6 ⇒ 10 − CD = 6 ⇒ CD = 4 cm. Option (A).',
        ),
        QuestionModel(
          id: 'quad_incircles_q13_cpo',
          topicId: 'quad_incircles',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'In quadrilateral ABCD, AB = 14 cm, BC = 18 cm, and CD = 15 cm. The incircles of △ABD and △BCD touch diagonal BD at P and Q with PQ = 4 cm. If AB + BC > CD + DA, find DA.\n\nचतुर्भुज ABCD में AB = 14 सेमी, BC = 18 सेमी और CD = 15 सेमी है। विकर्ण BD पर स्पर्श-बिंदुओं की दूरी PQ = 4 सेमी है। यदि AB + BC > CD + DA, तो DA की लंबाई ज्ञात कीजिए।',
          options: ['7 cm', '8 cm', '9 cm', '11 cm'],
          correctAnswer: '9 cm',
          explanation:
              '[(14 + 18) − (15 + DA)] / 2 = 4 ⇒ 32 − 15 − DA = 8 ⇒ 17 − DA = 8 ⇒ DA = 9 cm. Option (C).',
        ),
        QuestionModel(
          id: 'quad_incircles_q14_ntpc_cbt2',
          topicId: 'quad_incircles',
          examBadge: 'RRB NTPC CBT-2',
          difficulty: 2,
          prompt:
              'The perimeter of a quadrilateral ABCD is 60 cm. The incircles of △ABD and △BCD touch diagonal BD at P and Q such that PQ = 4 cm. If AB + BC > CD + DA, find the value of AB + BC.\n\nचतुर्भुज ABCD का परिमाप 60 सेमी है। इसके विकर्ण BD पर दोनों अंतःवृत्तों के स्पर्श-बिंदुओं के बीच की दूरी PQ = 4 सेमी है। AB + BC का मान ज्ञात कीजिए।',
          options: ['26 cm', '32 cm', '34 cm', '38 cm'],
          correctAnswer: '34 cm',
          explanation:
              '(a + b) + (c + d) = 60 and (a + b) − (c + d) = 8. Adding equations: 2(a + b) = 68 ⇒ a + b = 34 cm. Option (C).',
        ),
        QuestionModel(
          id: 'quad_incircles_q15_selpost',
          topicId: 'quad_incircles',
          examBadge: 'SSC Selection Post',
          difficulty: 2,
          prompt:
              'In quadrilateral ABCD, the ratio (AB + BC) : (CD + DA) is 5 : 3. If the distance between the tangency points of the incircles of △ABD and △BCD on diagonal BD is 7 cm, find the perimeter of quadrilateral ABCD.\n\nचतुर्भुज ABCD में (AB + BC) : (CD + DA) = 5 : 3 है। यदि विकर्ण BD पर स्पर्श-बिंदुओं की दूरी 7 सेमी है, तो चतुर्भुज का परिमाप ज्ञात कीजिए।',
          options: ['48 cm', '56 cm', '64 cm', '42 cm'],
          correctAnswer: '56 cm',
          explanation:
              'Let a + b = 5x, c + d = 3x. (5x − 3x) / 2 = x = 7. Perimeter = 8x = 8(7) = 56 cm. Option (B).',
        ),
        QuestionModel(
          id: 'quad_incircles_q16_cgl_tier2',
          topicId: 'quad_incircles',
          examBadge: 'SSC CGL Tier-2',
          difficulty: 3,
          prompt:
              'In a quadrilateral ABCD, the incircles of △ABD and △BCD touch the common diagonal BD at the exact same point. If AB = 13 cm, BC = 17 cm, and CD = 11 cm, find the length of side DA.\n\nचतुर्भुज ABCD में △ABD और △BCD के अंतःवृत्त उभयनिष्ठ विकर्ण BD को ठीक एक ही बिंदु पर स्पर्श करते हैं। यदि AB = 13 सेमी, BC = 17 सेमी और CD = 11 सेमी है, तो भुजा DA की लंबाई ज्ञात कीजिए।',
          options: ['15 cm', '17 cm', '19 cm', '21 cm'],
          correctAnswer: '19 cm',
          explanation:
              'PQ = 0 ⇒ a + b = c + d ⇒ 13 + 17 = 11 + DA ⇒ 30 = 11 + DA ⇒ DA = 19 cm. Option (C).',
        ),
      ],
    ),

    // =========================================================================
    // THEOREM 3: AREA RATIO IN A PARALLELOGRAM (MIDPOINTS OF ADJACENT SIDES)
    // =========================================================================
    ConceptFormulaModel(
      id: 'quad_area_ratio_parallelogram_midpoints',
      pillar: ConceptPillar.quadrilaterals,
      title: 'Area Ratio in Parallelogram (Adjacent Midpoints)',
      subtitle: 'समांतर चतुर्भुज की दो आसन्न भुजाओं के मध्य-बिंदुओं से बने त्रिभुज का क्षेत्रफल',
      formula: 'Area(△APQ) / Area(▱ABCD) = 3 / 8 (37.5%)',
      diagramType: null,
      keyConditions: [
        'In any parallelogram ABCD (including rectangle, rhombus, square), let P be the midpoint of BC and Q be the midpoint of adjacent side CD.',
        'When vertex A is connected to midpoints P and Q, the triangle △APQ occupies exactly 3/8 (37.5%) of total parallelogram area.',
        'Corner Triangle Breakdown:',
        '• Area(△ABP) = 1/4 of ▱ABCD',
        '• Area(△ADQ) = 1/4 of ▱ABCD',
        '• Area(△PCQ) = 1/8 of ▱ABCD',
        'Combined Area of remaining 3 corner triangles = 1/4 + 1/4 + 1/8 = 5/8 (62.5%) of ▱ABCD.',
      ],
      explanation:
          'This 3/8 ratio is one of the most frequently asked geometry results in SSC CGL, CHSL, and Railway exams. Whether applied to a generic parallelogram, a rectangle, a rhombus, or a square, the triangle formed by connecting one corner to the midpoints of the opposite two sides is always 3/8 of the total area.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'ABCD is a parallelogram whose total area is 96 cm². P and Q are midpoints of BC and CD respectively. Find Area(△APQ).',
          steps: [
            'Step 1: Formula: Area(△APQ) = (3/8) × Area(▱ABCD).',
            'Step 2: Area(△APQ) = (3/8) × 96 cm².',
            'Step 3: 96 ÷ 8 = 12; 12 × 3 = 36 cm².',
          ],
          answer: '36 cm²',
          shortcutTip:
              'Mental Trick: 3/8 of 96 = 3 × 12 = 36 cm² in 2 seconds!',
        ),
        SolvedExampleModel(
          problem:
              'A rectangle ABCD has length 16 cm and breadth 10 cm. P and Q are midpoints of BC and CD. Find Area(△APQ).',
          steps: [
            'Step 1: Total area of rectangle = 16 × 10 = 160 cm².',
            'Step 2: Since a rectangle is a parallelogram, Area(△APQ) = (3/8) × 160 cm².',
            'Step 3: (3/8) × 160 = 3 × 20 = 60 cm².',
          ],
          answer: '60 cm²',
          shortcutTip:
              '160 × 3 / 8 = 60 cm² directly!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'quad_area_q17_ntpc',
          topicId: 'quad_area_ratio',
          examBadge: 'RRB NTPC CBT-1',
          difficulty: 1,
          prompt:
              'ABCD is a parallelogram whose total area is 96 cm². If P and Q are the midpoints of sides BC and CD respectively, what is the area of △APQ?\n\nABCD एक समांतर चतुर्भुज है जिसका कुल क्षेत्रफल 96 सेमी² है। यदि P और Q क्रमशः भुजाओं BC और CD के मध्य-बिंदु हैं, तो △APQ का क्षेत्रफल क्या है?',
          options: ['36 cm²', '48 cm²', '32 cm²', '24 cm²'],
          correctAnswer: '36 cm²',
          explanation:
              'Area(△APQ) = (3/8) × Area(ABCD) = (3/8) × 96 = 36 cm². Option (A).',
        ),
        QuestionModel(
          id: 'quad_area_q18_chsl',
          topicId: 'quad_area_ratio',
          examBadge: 'SSC CHSL Tier-1',
          difficulty: 1,
          prompt:
              'In a parallelogram ABCD, P and Q are the midpoints of sides BC and CD respectively. If the area of △APQ is 27 cm², find the total area of parallelogram ABCD.\n\nसमांतर चतुर्भुज ABCD में P और Q क्रमशः भुजाओं BC और CD के मध्य-बिंदु हैं। यदि △APQ का क्षेत्रफल 27 सेमी² है, तो समांतर चतुर्भुज ABCD का कुल क्षेत्रफल ज्ञात कीजिए।',
          options: ['64 cm²', '72 cm²', '81 cm²', '90 cm²'],
          correctAnswer: '72 cm²',
          explanation:
              '(3/8) × Area = 27 ⇒ Area = 27 × (8/3) = 72 cm². Option (B).',
        ),
        QuestionModel(
          id: 'quad_area_q19_cgl',
          topicId: 'quad_area_ratio',
          examBadge: 'SSC CGL Tier-1',
          difficulty: 1,
          prompt:
              'A rectangle ABCD has length 16 cm and breadth 10 cm. If P and Q are the midpoints of sides BC and CD respectively, find the area of △APQ.\n\nएक आयत ABCD की लंबाई 16 सेमी और चौड़ाई 10 सेमी है। यदि P और Q क्रमशः भुजाओं BC और CD के मध्य-बिंदु हैं, तो △APQ का क्षेत्रफल ज्ञात कीजिए।',
          options: ['50 cm²', '60 cm²', '70 cm²', '80 cm²'],
          correctAnswer: '60 cm²',
          explanation:
              'Area of rectangle = 16 × 10 = 160 cm². Area(△APQ) = (3/8) × 160 = 60 cm². Option (B).',
        ),
        QuestionModel(
          id: 'quad_area_q20_alp',
          topicId: 'quad_area_ratio',
          examBadge: 'RRB Group D / ALP',
          difficulty: 2,
          prompt:
              'A rhombus ABCD has diagonals of lengths 16 cm and 20 cm. M and N are the midpoints of adjacent sides BC and CD respectively. Calculate the area of △AMN.\n\nएक समचतुर्भुज ABCD के विकर्णों की लंबाई 16 सेमी और 20 सेमी है। M और N क्रमशः आसन्न भुजाओं BC और CD के मध्य-बिंदु हैं। △AMN का क्षेत्रफल ज्ञात कीजिए।',
          options: ['45 cm²', '60 cm²', '75 cm²', '80 cm²'],
          correctAnswer: '60 cm²',
          explanation:
              'Area of rhombus = (1/2) × 16 × 20 = 160 cm². Area(△AMN) = (3/8) × 160 = 60 cm². Option (B).',
        ),
        QuestionModel(
          id: 'quad_area_q21_cpo',
          topicId: 'quad_area_ratio',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'In a square ABCD of side 12 cm, P and Q are the midpoints of sides BC and CD respectively. What is the area of △APQ?\n\n12 सेमी भुजा वाले वर्ग ABCD में P और Q क्रमशः भुजाओं BC और CD के मध्य-बिंदु हैं। △APQ का क्षेत्रफल क्या है?',
          options: ['48 cm²', '54 cm²', '60 cm²', '72 cm²'],
          correctAnswer: '54 cm²',
          explanation:
              'Area of square = 12² = 144 cm². Area(△APQ) = (3/8) × 144 = 54 cm². Option (B).',
        ),
        QuestionModel(
          id: 'quad_area_q22_selpost',
          topicId: 'quad_area_ratio',
          examBadge: 'SSC Selection Post',
          difficulty: 2,
          prompt:
              'In a rectangle ABCD, E and F are the midpoints of sides BC and CD respectively. If the area of △CEF is 15 cm², what is the area of △AEF?\n\nएक आयत ABCD में E और F क्रमशः भुजाओं BC और CD के मध्य-बिंदु हैं। यदि △CEF का क्षेत्रफल 15 सेमी² है, तो △AEF का क्षेत्रफल क्या है?',
          options: ['30 cm²', '45 cm²', '60 cm²', '52.5 cm²'],
          correctAnswer: '45 cm²',
          explanation:
              'Area(△CEF) = (1/8) × Area(ABCD) = 15 ⇒ Area(ABCD) = 120 cm². Area(△AEF) = (3/8) × 120 = 45 cm². Option (B).',
        ),
        QuestionModel(
          id: 'quad_area_q23_ntpc_cbt2',
          topicId: 'quad_area_ratio',
          examBadge: 'RRB NTPC CBT-2',
          difficulty: 2,
          prompt:
              'In a parallelogram ABCD of area 128 cm², P and Q are the midpoints of BC and CD respectively. Find the combined area of the three corner triangles △ABP, △ADQ, and △PCQ.\n\n128 सेमी² क्षेत्रफल वाले समांतर चतुर्भुज ABCD में P और Q क्रमशः BC और CD के मध्य-बिंदु हैं। तीनों कोने वाले त्रिभुजों △ABP, △ADQ और △PCQ का कुल क्षेत्रफल ज्ञात कीजिए।',
          options: ['48 cm²', '64 cm²', '80 cm²', '96 cm²'],
          correctAnswer: '80 cm²',
          explanation:
              'Corner triangles occupy 1 − 3/8 = 5/8 of total area. Combined area = (5/8) × 128 = 80 cm². Option (C).',
        ),
        QuestionModel(
          id: 'quad_area_q24_cgl_tier2',
          topicId: 'quad_area_ratio',
          examBadge: 'SSC CGL Tier-2',
          difficulty: 3,
          prompt:
              'In a parallelogram ABCD, AB = 20 cm, AD = 16 cm, and ∠BAD = 30°. If P and Q are the midpoints of sides BC and CD respectively, calculate the area of △APQ.\n\nसमांतर चतुर्भुज ABCD में AB = 20 सेमी, AD = 16 सेमी और ∠BAD = 30° है। यदि P और Q क्रमशः भुजाओं BC और CD के मध्य-बिंदु हैं, तो △APQ का क्षेत्रफल ज्ञात कीजिए।',
          options: ['45 cm²', '60 cm²', '75 cm²', '90 cm²'],
          correctAnswer: '60 cm²',
          explanation:
              'Area(ABCD) = AB × AD × sin 30° = 20 × 16 × (1/2) = 160 cm². Area(△APQ) = (3/8) × 160 = 60 cm². Option (B).',
        ),
      ],
    ),
  ];
}
