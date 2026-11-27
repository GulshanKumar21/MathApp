import '../models/concept_formula_model.dart';
import '../models/math_models.dart';

class PythagorasTripletsConceptData {
  static final List<ConceptFormulaModel> formulas = [
    // =========================================================================
    // CONCEPT 19: PYTHAGORAS TRIPLETS & GENERATION FORMULAS | पाइथागोरस त्रिक
    // =========================================================================
    ConceptFormulaModel(
      id: 'tri_pythagoras_triplets_guide',
      pillar: ConceptPillar.triangles,
      title: 'Pythagoras Triplets & Generation Formulas',
      subtitle: 'पाइथागोरस त्रिक, निर्माण सूत्र, मास्टर तालिका एवं परीक्षा PYQs',
      formula: 'a² + b² = c²  |  Odd: (n, (n²−1)/2, (n²+1)/2)  |  Even: (2n, n²−1, n²+1)',
      diagramType: null,
      keyConditions: [
        'Fundamental Relation: a² + b² = c², where c is the hypotenuse (longest side, c > a, b).',
        'Scaling Property: Multiplying or dividing a primitive triplet (a, b, c) by any positive factor k produces another valid triplet (ka, kb, kc).',
        'Odd Smallest Side (n ≥ 3): Triplet is (n, (n² − 1)/2, (n² + 1)/2). Square n, halve it, then take 0.5 below and 0.5 above. Example: n = 7 ⇒ 49/2 = 24.5 ⇒ (7, 24, 25).',
        'Even Smallest Side (2n, n ≥ 2): Triplet is (2n, n² − 1, n² + 1). Halve the number to get n, then compute n² − 1 and n² + 1. Example: 2n = 8 (n = 4) ⇒ (8, 15, 17).',
        'Euclid\'s General Formula (m > n > 0): (m² − n², 2mn, m² + n²). Generates all primitive triplets when m, n are coprime of opposite parity.',
        'Trigonometry Link: If (m² − n²) sin θ + 2mn cos θ = m² + n², then tan θ = (m² − n²) / 2mn.',
      ],
      explanation:
          'Pythagorean triplets are the single most powerful speed tool in quantitative aptitude. Instead of calculating squares and square roots, identifying triplets instantly solves right triangles, circles, rhombuses, trapeziums, 3D cones, and even speed-time-distance problems in 5 seconds flat.',
      solvedExamples: [
        SolvedExampleModel(
          problem:
              'Generate a Pythagorean triplet whose smallest side is 11.',
          steps: [
            'Step 1: Since 11 is odd, use odd rule: (n, (n² − 1)/2, (n² + 1)/2).',
            'Step 2: Square 11: 11² = 121.',
            'Step 3: Halve the square: 121 / 2 = 60.5.',
            'Step 4: Take 0.5 below and 0.5 above: 60 and 61.',
            'Step 5: The triplet is (11, 60, 61).',
          ],
          answer: '(11, 60, 61)',
          shortcutTip:
              'Square and halve: 11² = 121 / 2 = 60.5 ⇒ (11, 60, 61) in 2 seconds!',
        ),
        SolvedExampleModel(
          problem:
              'Generate a Pythagorean triplet whose smallest side is 12.',
          steps: [
            'Step 1: Since 12 is even, 2n = 12 ⇒ n = 6.',
            'Step 2: Compute n² − 1 = 6² − 1 = 35.',
            'Step 3: Compute n² + 1 = 6² + 1 = 37.',
            'Step 4: The triplet is (12, 35, 37).',
          ],
          answer: '(12, 35, 37)',
          shortcutTip:
              'Halve and square: 12/2 = 6 ⇒ 6² ± 1 = 35 and 37 ⇒ (12, 35, 37)!',
        ),
      ],
      practiceQuestions: [
        QuestionModel(
          id: 'pyth_q1_cgl_chords',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC CGL Tier-II',
          difficulty: 2,
          prompt:
              'Two parallel chords of lengths 30 cm and 16 cm lie on the opposite sides of the centre of a circle of radius 17 cm. What is the distance between the two chords?\n\n17 सेमी त्रिज्या वाले एक वृत्त के केंद्र के विपरीत दिशाओं में स्थित दो समानांतर जीवाओं की लंबाई 30 सेमी और 16 सेमी है। दोनों जीवाओं के बीच की दूरी क्या है?',
          options: ['7 cm', '15 cm', '23 cm', '25 cm'],
          correctAnswer: '23 cm',
          explanation:
              'Half-chords: 30/2 = 15 cm and 16/2 = 8 cm. With radius r = 17 cm, using triplet (8, 15, 17), perpendicular distances from centre are d₁ = 8 cm and d₂ = 15 cm. Distance between opposite chords = 8 + 15 = 23 cm. Option (C).',
        ),
        QuestionModel(
          id: 'pyth_q2_cpo_dct',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'Two circles of radii 15 cm and 8 cm have their centres 25 cm apart. Find the length of their direct common tangent (DCT).\n\n15 सेमी और 8 सेमी त्रिज्या वाले दो वृत्तों के केंद्रों के बीच की दूरी 25 सेमी है। उनकी उभयनिष्ठ अनुस्पर्श रेखा (DCT) की लंबाई ज्ञात कीजिए।',
          options: ['20 cm', '22 cm', '24 cm', '26 cm'],
          correctAnswer: '24 cm',
          explanation:
              'DCT = √[d² − (R − r)²] = √[25² − (15 − 8)²] = √(25² − 7²). By triplet (7, 24, 25), DCT = 24 cm. Option (C).',
        ),
        QuestionModel(
          id: 'pyth_q3_chsl_radii',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC CHSL',
          difficulty: 2,
          prompt:
              'The sides of a triangle are 33 cm, 56 cm, and 65 cm. Find the circumradius (R) and inradius (r) of the triangle.\n\nएक त्रिभुज की भुजाएँ 33 सेमी, 56 सेमी और 65 सेमी हैं। त्रिभुज की परित्रिज्या (R) और अंतःत्रिज्या (r) ज्ञात कीजिए।',
          options: ['32.5 cm, 12 cm', '32.5 cm, 14 cm', '30 cm, 12 cm', '35 cm, 14 cm'],
          correctAnswer: '32.5 cm, 12 cm',
          explanation:
              '(33, 56, 65) is a Pythagorean triplet (right-angled triangle). Circumradius R = Hypotenuse / 2 = 65 / 2 = 32.5 cm. Inradius r = (P + B − H) / 2 = (33 + 56 − 65) / 2 = 24 / 2 = 12 cm. Option (A).',
        ),
        QuestionModel(
          id: 'pyth_q4_ntpc_rhombus',
          topicId: 'pythagoras_triplets',
          examBadge: 'RRB NTPC',
          difficulty: 2,
          prompt:
              'The perimeter of a rhombus is 148 cm and one of its diagonals is 24 cm. Find the area of the rhombus.\n\nएक समचतुर्भुज का परिमाप 148 सेमी है और इसका एक विकर्ण 24 सेमी है। समचतुर्भुज का क्षेत्रफल ज्ञात कीजिए।',
          options: ['720 cm²', '840 cm²', '960 cm²', '1080 cm²'],
          correctAnswer: '840 cm²',
          explanation:
              'Side a = 148 / 4 = 37 cm. Half diagonal d₁/2 = 24 / 2 = 12 cm. Diagonals bisect at 90°. By triplet (12, 35, 37), other half diagonal d₂/2 = 35 cm ⇒ d₂ = 70 cm. Area = (1/2) × 24 × 70 = 840 cm². Option (B).',
        ),
        QuestionModel(
          id: 'pyth_q5_cgl_trapezium',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC CGL',
          difficulty: 2,
          prompt:
              'In an isosceles trapezium, the parallel sides are 26 cm and 44 cm, and each non-parallel side is 41 cm. Find the area of the trapezium.\n\nएक समद्विबाहु समलंब चतुर्भुज की समानांतर भुजाएँ 26 सेमी और 44 सेमी हैं, तथा प्रत्येक असमानांतर भुजा 41 सेमी है। समलंब चतुर्भुज का क्षेत्रफल ज्ञात कीजिए।',
          options: ['1200 cm²', '1360 cm²', '1400 cm²', '1440 cm²'],
          correctAnswer: '1400 cm²',
          explanation:
              'Base projection on each side = (44 − 26) / 2 = 9 cm; slant side = 41 cm. By triplet (9, 40, 41), height h = 40 cm. Area = (1/2) × (26 + 44) × 40 = 35 × 40 = 1400 cm². Option (C).',
        ),
        QuestionModel(
          id: 'pyth_q6_cpo_cone',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC CPO',
          difficulty: 2,
          prompt:
              'The curved surface area of a right circular cone is 2310 cm² and its radius is 21 cm. Find its volume (π = 22/7).\n\nएक लंब वृत्तीय शंकु का वक्र पृष्ठीय क्षेत्रफल 2310 सेमी² है और इसकी त्रिज्या 21 सेमी है। इसका आयतन ज्ञात कीजिए (π = 22/7)।',
          options: ['12936 cm³', '13860 cm³', '14520 cm³', '15246 cm³'],
          correctAnswer: '12936 cm³',
          explanation:
              'πrl = 2310 ⇒ (22/7) × 21 × l = 2310 ⇒ 66l = 2310 ⇒ l = 35 cm. Radius r = 21 cm, slant height l = 35 cm. By triplet (21, 28, 35) [7 × (3,4,5)], height h = 28 cm. Volume = (1/3) × (22/7) × 21 × 21 × 28 = 12936 cm³. Option (A).',
        ),
        QuestionModel(
          id: 'pyth_q7_ibps_rectangle',
          topicId: 'pythagoras_triplets',
          examBadge: 'IBPS PO / Banking',
          difficulty: 2,
          prompt:
              'A rectangular park has a diagonal of 53 m and a perimeter of 146 m. Find the cost of levelling the park at ₹15 per m².\n\nएक आयताकार पार्क का विकर्ण 53 मीटर और परिमाप 146 मीटर है। ₹15 प्रति वर्ग मीटर की दर से पार्क को समतल करने की लागत ज्ञात कीजिए।',
          options: ['₹16,800', '₹18,900', '₹20,400', '₹21,600'],
          correctAnswer: '₹18,900',
          explanation:
              '2(l + b) = 146 ⇒ l + b = 73 m, and diagonal d = 53 m. Recall triplet (28, 45, 53): 28 + 45 = 73! So l = 45 m, b = 28 m. Area = 45 × 28 = 1260 m²; Cost = 1260 × 15 = ₹18,900. Option (B).',
        ),
        QuestionModel(
          id: 'pyth_q8_cgl_trig',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC CGL',
          difficulty: 2,
          prompt:
              'If (x² − y²) sin θ + 2xy cos θ = x² + y², then what is the value of tan θ?\n\nयदि (x² − y²) sin θ + 2xy cos θ = x² + y² है, तो tan θ का मान क्या होगा?',
          options: ['(x² − y²)/2xy', '2xy/(x² − y²)', '(x² + y²)/2xy', '2xy/(x² + y²)'],
          correctAnswer: '(x² − y²)/2xy',
          explanation:
              'Compare with P sin θ + B cos θ = H, where (x² − y², 2xy, x² + y²) is Euclid\'s Pythagorean triplet. Here P = x² − y² and B = 2xy ⇒ tan θ = P/B = (x² − y²) / 2xy. Option (A).',
        ),
        QuestionModel(
          id: 'pyth_q9_cgl_algebra',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC CGL Tier-II',
          difficulty: 2,
          prompt:
              'If x, y, z are positive integers forming a primitive Pythagorean triplet with x < y < z and z − y = 1, find x when y + z = 169.\n\nयदि x, y, z एक मौलिक पाइथागोरस त्रिक बनाने वाले धनात्मक पूर्णांक हैं जहाँ x < y < z तथा z − y = 1 और y + z = 169 है, तो x का मान ज्ञात कीजिए।',
          options: ['11', '13', '15', '17'],
          correctAnswer: '13',
          explanation:
              'x² = z² − y² = (z − y)(z + y). Given z − y = 1 and z + y = 169: x² = 1 × 169 = 169 ⇒ x = 13 (Triplet: 13, 84, 85). Option (B).',
        ),
        QuestionModel(
          id: 'pyth_q10_groupd_speed',
          topicId: 'pythagoras_triplets',
          examBadge: 'RRB Group D',
          difficulty: 2,
          prompt:
              'Two cyclists start from the same junction; one rides North at 18 km/h and the other rides East at 24 km/h. What is the shortest distance between them after 2.5 hours?\n\nदो साइकिल चालक एक ही चौराहे से चलना शुरू करते हैं; एक उत्तर की ओर 18 किमी/घंटा और दूसरा पूर्व की ओर 24 किमी/घंटा से चलता है। 2.5 घंटे बाद उनके बीच की न्यूनतम दूरी क्या होगी?',
          options: ['60 km', '70 km', '75 km', '80 km'],
          correctAnswer: '75 km',
          explanation:
              'Speeds 18 and 24 form triplet (18, 24, 30) [6 × (3,4,5)], so relative separation speed = 30 km/h. Shortest distance after 2.5 hours = 30 × 2.5 = 75 km. Option (C).',
        ),
        QuestionModel(
          id: 'pyth_q11_selpost_count',
          topicId: 'pythagoras_triplets',
          examBadge: 'SSC Selection Post',
          difficulty: 2,
          prompt:
              'How many primitive Pythagorean triplets have 65 as their hypotenuse?\n\nऐसे कितने मौलिक पाइथागोरस त्रिक (primitive Pythagorean triplets) हैं जिनका कर्ण (hypotenuse) 65 है?',
          options: ['1', '2', '3', '4'],
          correctAnswer: '2',
          explanation:
              'Hypotenuse c = m² + n² = 65. Expressing 65 as sum of two squares: 8² + 1² = 65 ⇒ (63, 16, 65) and 7² + 4² = 65 ⇒ (33, 56, 65). Both are primitive (gcd = 1). Thus, there are exactly 2 such primitive triplets. Option (B).',
        ),
      ],
    ),
  ];
}
