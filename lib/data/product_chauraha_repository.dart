import 'dart:math';
import '../models/product_chauraha_model.dart';

/// Repository containing curated Product Chaurahas (Multiplication Crossroads)
/// based on competitive exam pedagogy (SSC CGL, CHSL, Banking & CDS).
class ProductChaurahaRepository {
  static final List<ProductChaurahaModel> chaurahas = [
    // 1. 108 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_108',
      title: '108 Chauraha',
      subtitle: 'The 4-Way Multiplication Crossway',
      targetNumber: 108,
      primeFactorization: '108 = 2² × 3³ = 4 × 27',
      examTip: 'Frequent in Time & Work (LCM of 12, 18, 27, 36), Geometry (Area of regular hexagon with side √3), and simplification drills.',
      topBranch: ChaurahaBranch(label: '12 × 9', factorA: 12, factorB: 9, product: 108),
      bottomBranch: ChaurahaBranch(label: '18 × 6', factorA: 18, factorB: 6, product: 108),
      leftBranch: ChaurahaBranch(label: '27 × 4', factorA: 27, factorB: 4, product: 108),
      rightBranch: ChaurahaBranch(label: '36 × 3', factorA: 36, factorB: 3, product: 108),
      extraBranch1: ChaurahaBranch(label: '54 × 2', factorA: 54, factorB: 2, product: 108, badge: 'Double'),
      allFactorPairs: ['12 × 9 = 108', '18 × 6 = 108', '27 × 4 = 108', '36 × 3 = 108', '54 × 2 = 108'],
      questions: [
        ChaurahaQuestion(
          id: 'q_108_1',
          prompt: 'Which 2 pairs multiply to give 108?',
          target: 108,
          options: ['12 × 9', '14 × 8', '27 × 4', '16 × 7'],
          correctIndices: [0, 2],
          explanation: '12 × 9 = 108 and 27 × 4 = 108. (14 × 8 = 112, 16 × 7 = 112)',
        ),
        ChaurahaQuestion(
          id: 'q_108_2',
          prompt: 'Identify the 2 factor pairs of 108 from this Chauraha:',
          target: 108,
          options: ['19 × 6', '36 × 3', '18 × 6', '15 × 7'],
          correctIndices: [1, 2],
          explanation: '36 × 3 = 108 and 18 × 6 = 108. (19 × 6 = 114, 15 × 7 = 105)',
        ),
        ChaurahaQuestion(
          id: 'q_108_3',
          prompt: 'Select BOTH pairs that belong to the 108 crossroads:',
          target: 108,
          options: ['18 × 6', '13 × 8', '17 × 6', '12 × 9'],
          correctIndices: [0, 3],
          explanation: '18 × 6 = 108 and 12 × 9 = 108. (13 × 8 = 104, 17 × 6 = 102)',
        ),
      ],
    ),

    // 2. 180 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_180',
      title: '180 Chauraha',
      subtitle: 'The Geometry & Percentage Master',
      targetNumber: 180,
      primeFactorization: '180 = 2² × 3² × 5 = 4 × 9 × 5',
      examTip: '180° is the sum of angles of a triangle! Also equals 50% of 360° in DI pie charts, and common speed conversion 18 km/h = 5 m/s (180 = 36 × 5).',
      topBranch: ChaurahaBranch(label: '12 × 15', factorA: 12, factorB: 15, product: 180),
      bottomBranch: ChaurahaBranch(label: '36 × 5', factorA: 36, factorB: 5, product: 180),
      leftBranch: ChaurahaBranch(label: '45 × 4', factorA: 45, factorB: 4, product: 180),
      rightBranch: ChaurahaBranch(label: '20 × 9', factorA: 20, factorB: 9, product: 180),
      extraBranch1: ChaurahaBranch(label: '18 × 10', factorA: 18, factorB: 10, product: 180, badge: 'Decimal'),
      extraBranch2: ChaurahaBranch(label: '30 × 6', factorA: 30, factorB: 6, product: 180),
      allFactorPairs: ['12 × 15 = 180', '36 × 5 = 180', '45 × 4 = 180', '20 × 9 = 180', '18 × 10 = 180', '30 × 6 = 180'],
      questions: [
        ChaurahaQuestion(
          id: 'q_180_1',
          prompt: 'Which 2 pairs multiply to give 180?',
          target: 180,
          options: ['12 × 15', '22 × 8', '36 × 5', '16 × 11'],
          correctIndices: [0, 2],
          explanation: '12 × 15 = 180 and 36 × 5 = 180. (22 × 8 = 176, 16 × 11 = 176)',
        ),
        ChaurahaQuestion(
          id: 'q_180_2',
          prompt: 'Select 2 correct branches for the 180 Chauraha:',
          target: 180,
          options: ['45 × 4', '14 × 13', '20 × 9', '25 × 7'],
          correctIndices: [0, 2],
          explanation: '45 × 4 = 180 and 20 × 9 = 180. (14 × 13 = 182, 25 × 7 = 175)',
        ),
        ChaurahaQuestion(
          id: 'q_180_3',
          prompt: 'Which 2 pairs share the exact product 180?',
          target: 180,
          options: ['32 × 6', '36 × 5', '18 × 11', '12 × 15'],
          correctIndices: [1, 3],
          explanation: '36 × 5 = 180 and 12 × 15 = 180. (32 × 6 = 192, 18 × 11 = 198)',
        ),
      ],
    ),

    // 3. 144 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_144',
      title: '144 Chauraha',
      subtitle: 'The Gross Square Crossroads (12²)',
      targetNumber: 144,
      primeFactorization: '144 = 2⁴ × 3² = 16 × 9 = 12²',
      examTip: '144 is 12² and one of the most frequent LCM numbers in Time, Speed & Distance (16 km/h, 18 km/h, 24 km/h, 36 km/h all meet at 144).',
      topBranch: ChaurahaBranch(label: '18 × 8', factorA: 18, factorB: 8, product: 144),
      bottomBranch: ChaurahaBranch(label: '16 × 9', factorA: 16, factorB: 9, product: 144),
      leftBranch: ChaurahaBranch(label: '24 × 6', factorA: 24, factorB: 6, product: 144),
      rightBranch: ChaurahaBranch(label: '36 × 4', factorA: 36, factorB: 4, product: 144),
      extraBranch1: ChaurahaBranch(label: '12 × 12', factorA: 12, factorB: 12, product: 144, badge: '12² Square'),
      extraBranch2: ChaurahaBranch(label: '48 × 3', factorA: 48, factorB: 3, product: 144),
      allFactorPairs: ['18 × 8 = 144', '16 × 9 = 144', '24 × 6 = 144', '36 × 4 = 144', '12 × 12 = 144', '48 × 3 = 144'],
      questions: [
        ChaurahaQuestion(
          id: 'q_144_1',
          prompt: 'Which 2 pairs multiply to give 144?',
          target: 144,
          options: ['24 × 6', '15 × 10', '16 × 9', '17 × 8'],
          correctIndices: [0, 2],
          explanation: '24 × 6 = 144 and 16 × 9 = 144. (15 × 10 = 150, 17 × 8 = 136)',
        ),
        ChaurahaQuestion(
          id: 'q_144_2',
          prompt: 'Select 2 pairs that belong to the 144 Gross Chauraha:',
          target: 144,
          options: ['19 × 7', '18 × 8', '13 × 11', '36 × 4'],
          correctIndices: [1, 3],
          explanation: '18 × 8 = 144 and 36 × 4 = 144. (19 × 7 = 133, 13 × 11 = 143)',
        ),
        ChaurahaQuestion(
          id: 'q_144_3',
          prompt: 'Which 2 pairs equal 144?',
          target: 144,
          options: ['12 × 12', '14 × 10', '48 × 3', '26 × 5'],
          correctIndices: [0, 2],
          explanation: '12 × 12 = 144 (12²) and 48 × 3 = 144. (14 × 10 = 140, 26 × 5 = 130)',
        ),
      ],
    ),

    // 4. 216 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_216',
      title: '216 Chauraha',
      subtitle: 'The Cube of 6 Multiplier Crossway',
      targetNumber: 216,
      primeFactorization: '216 = 2³ × 3³ = 6³ = 8 × 27',
      examTip: '216 is the volume of a 6×6×6 cube! Also appears in sphere mensuration and compound interest rate calculations at 20% for 3 years (1.2³ = 1.728, 6³ = 216).',
      topBranch: ChaurahaBranch(label: '12 × 18', factorA: 12, factorB: 18, product: 216),
      bottomBranch: ChaurahaBranch(label: '6³ (Cube)', factorA: 36, factorB: 6, product: 216, badge: '6³ = 216'),
      leftBranch: ChaurahaBranch(label: '24 × 9', factorA: 24, factorB: 9, product: 216),
      rightBranch: ChaurahaBranch(label: '36 × 6', factorA: 36, factorB: 6, product: 216),
      extraBranch1: ChaurahaBranch(label: '27 × 8', factorA: 27, factorB: 8, product: 216),
      extraBranch2: ChaurahaBranch(label: '54 × 4', factorA: 54, factorB: 4, product: 216),
      allFactorPairs: ['12 × 18 = 216', '24 × 9 = 216', '36 × 6 = 216', '27 × 8 = 216', '54 × 4 = 216', '6³ = 216'],
      questions: [
        ChaurahaQuestion(
          id: 'q_216_1',
          prompt: 'Which 2 pairs multiply to give 216?',
          target: 216,
          options: ['24 × 9', '22 × 10', '12 × 18', '19 × 11'],
          correctIndices: [0, 2],
          explanation: '24 × 9 = 216 and 12 × 18 = 216. (22 × 10 = 220, 19 × 11 = 209)',
        ),
        ChaurahaQuestion(
          id: 'q_216_2',
          prompt: 'Identify the 2 factor pairs of 216 (Cube of 6):',
          target: 216,
          options: ['27 × 8', '35 × 6', '36 × 6', '28 × 7'],
          correctIndices: [0, 2],
          explanation: '27 × 8 = 216 and 36 × 6 = 216. (35 × 6 = 210, 28 × 7 = 196)',
        ),
      ],
    ),

    // 5. 192 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_192',
      title: '192 Chauraha',
      subtitle: 'The Mensuration Multiplier Crossroads',
      targetNumber: 192,
      primeFactorization: '192 = 2⁶ × 3 = 64 × 3',
      examTip: 'Frequent in Cylinder, Cone, and Trigonometric product values (64 × 3, 24 × 8, 12 × 16).',
      topBranch: ChaurahaBranch(label: '12 × 16', factorA: 12, factorB: 16, product: 192),
      bottomBranch: ChaurahaBranch(label: '64 × 3', factorA: 64, factorB: 3, product: 192),
      leftBranch: ChaurahaBranch(label: '24 × 8', factorA: 24, factorB: 8, product: 192),
      rightBranch: ChaurahaBranch(label: '96 × 2', factorA: 96, factorB: 2, product: 192),
      extraBranch1: ChaurahaBranch(label: '32 × 6', factorA: 32, factorB: 6, product: 192),
      extraBranch2: ChaurahaBranch(label: '48 × 4', factorA: 48, factorB: 4, product: 192),
      allFactorPairs: ['12 × 16 = 192', '24 × 8 = 192', '96 × 2 = 192', '64 × 3 = 192', '32 × 6 = 192', '48 × 4 = 192'],
      questions: [
        ChaurahaQuestion(
          id: 'q_192_1',
          prompt: 'Which 2 pairs multiply to give 192?',
          target: 192,
          options: ['24 × 8', '18 × 11', '12 × 16', '15 × 13'],
          correctIndices: [0, 2],
          explanation: '24 × 8 = 192 and 12 × 16 = 192. (18 × 11 = 198, 15 × 13 = 195)',
        ),
        ChaurahaQuestion(
          id: 'q_192_2',
          prompt: 'Select 2 correct branches for the 192 Chauraha:',
          target: 192,
          options: ['64 × 3', '96 × 2', '74 × 2', '28 × 7'],
          correctIndices: [0, 1],
          explanation: '64 × 3 = 192 and 96 × 2 = 192. (74 × 2 = 148, 28 × 7 = 196)',
        ),
      ],
    ),

    // 6. Base 25 Multipliers Crossroads (The 6th box in the Adda247 page!)
    const ProductChaurahaModel(
      id: 'chauraha_base_25',
      title: 'Base 25 Crossroads',
      subtitle: 'The 4-Way Multipliers of 25',
      targetNumber: 25,
      isBaseFormat: true,
      baseNumber: 25,
      primeFactorization: '25 × N = (N ÷ 4) × 100',
      examTip: 'To multiply any number by 25: Divide by 4 and append two zeroes! 25 × 12 = 300, 25 × 24 = 600, 25 × 15 = 375, 25 × 25 = 625.',
      topBranch: ChaurahaBranch(label: '× 12 = 300', factorA: 25, factorB: 12, product: 300, isBaseFormat: true),
      bottomBranch: ChaurahaBranch(label: '× 24 = 600', factorA: 25, factorB: 24, product: 600, isBaseFormat: true),
      leftBranch: ChaurahaBranch(label: '15 × = 375', factorA: 25, factorB: 15, product: 375, isBaseFormat: true),
      rightBranch: ChaurahaBranch(label: '× 25 = 625', factorA: 25, factorB: 25, product: 625, badge: '25² Square', isBaseFormat: true),
      extraBranch1: ChaurahaBranch(label: '× 16 = 400', factorA: 25, factorB: 16, product: 400, isBaseFormat: true),
      extraBranch2: ChaurahaBranch(label: '× 28 = 700', factorA: 25, factorB: 28, product: 700, isBaseFormat: true),
      allFactorPairs: ['25 × 12 = 300', '25 × 24 = 600', '25 × 15 = 375', '25 × 25 = 625 (25²)', '25 × 16 = 400', '25 × 28 = 700'],
      questions: [
        ChaurahaQuestion(
          id: 'q_25_1',
          prompt: 'Which 2 calculations with base 25 give 300 and 600?',
          target: 25,
          options: ['25 × 12 = 300', '25 × 14 = 350', '25 × 24 = 600', '25 × 20 = 500'],
          correctIndices: [0, 2],
          explanation: '25 × 12 = 300 and 25 × 24 = 600. (Trick: 12÷4=3 ➔ 300; 24÷4=6 ➔ 600)',
        ),
        ChaurahaQuestion(
          id: 'q_25_2',
          prompt: 'Select 2 correct branches from the Base 25 Crossroads:',
          target: 25,
          options: ['25 × 15 = 375', '25 × 18 = 425', '25 × 25 = 625', '25 × 22 = 525'],
          correctIndices: [0, 2],
          explanation: '25 × 15 = 375 and 25 × 25 = 625. (25 × 18 = 450, 25 × 22 = 550)',
        ),
      ],
    ),

    // 7. 72 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_72',
      title: '72 Chauraha',
      subtitle: 'The Divisibility & Rate Chauraha',
      targetNumber: 72,
      primeFactorization: '72 = 2³ × 3² = 8 × 9',
      examTip: 'Divisibility rule of 72 (divisible by both 8 & 9) is tested in almost every SSC CGL exam! Pairs 8×9, 12×6, 18×4, 24×3, 36×2.',
      topBranch: ChaurahaBranch(label: '8 × 9', factorA: 8, factorB: 9, product: 72),
      bottomBranch: ChaurahaBranch(label: '18 × 4', factorA: 18, factorB: 4, product: 72),
      leftBranch: ChaurahaBranch(label: '12 × 6', factorA: 12, factorB: 6, product: 72),
      rightBranch: ChaurahaBranch(label: '24 × 3', factorA: 24, factorB: 3, product: 72),
      extraBranch1: ChaurahaBranch(label: '36 × 2', factorA: 36, factorB: 2, product: 72),
      allFactorPairs: ['8 × 9 = 72', '12 × 6 = 72', '18 × 4 = 72', '24 × 3 = 72', '36 × 2 = 72'],
      questions: [
        ChaurahaQuestion(
          id: 'q_72_1',
          prompt: 'Which 2 pairs multiply to give 72?',
          target: 72,
          options: ['12 × 6', '15 × 5', '18 × 4', '14 × 5'],
          correctIndices: [0, 2],
          explanation: '12 × 6 = 72 and 18 × 4 = 72. (15 × 5 = 75, 14 × 5 = 70)',
        ),
        ChaurahaQuestion(
          id: 'q_72_2',
          prompt: 'Select 2 pairs that give the product 72:',
          target: 72,
          options: ['8 × 9', '16 × 5', '24 × 3', '13 × 6'],
          correctIndices: [0, 2],
          explanation: '8 × 9 = 72 and 24 × 3 = 72. (16 × 5 = 80, 13 × 6 = 78)',
        ),
      ],
    ),

    // 8. 96 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_96',
      title: '96 Chauraha',
      subtitle: 'The Standard Capacity Crossroads',
      targetNumber: 96,
      primeFactorization: '96 = 2⁵ × 3 = 32 × 3',
      examTip: 'Frequent in Pipes & Cisterns and Time & Work capacity values. (12 × 8, 16 × 6, 24 × 4, 32 × 3).',
      topBranch: ChaurahaBranch(label: '12 × 8', factorA: 12, factorB: 8, product: 96),
      bottomBranch: ChaurahaBranch(label: '16 × 6', factorA: 16, factorB: 6, product: 96),
      leftBranch: ChaurahaBranch(label: '24 × 4', factorA: 24, factorB: 4, product: 96),
      rightBranch: ChaurahaBranch(label: '32 × 3', factorA: 32, factorB: 3, product: 96),
      extraBranch1: ChaurahaBranch(label: '48 × 2', factorA: 48, factorB: 2, product: 96),
      allFactorPairs: ['12 × 8 = 96', '16 × 6 = 96', '24 × 4 = 96', '32 × 3 = 96', '48 × 2 = 96'],
      questions: [
        ChaurahaQuestion(
          id: 'q_96_1',
          prompt: 'Which 2 pairs multiply to give 96?',
          target: 96,
          options: ['12 × 8', '14 × 7', '16 × 6', '15 × 6'],
          correctIndices: [0, 2],
          explanation: '12 × 8 = 96 and 16 × 6 = 96. (14 × 7 = 98, 15 × 6 = 90)',
        ),
        ChaurahaQuestion(
          id: 'q_96_2',
          prompt: 'Select 2 correct branches for the 96 Chauraha:',
          target: 96,
          options: ['24 × 4', '18 × 5', '32 × 3', '22 × 4'],
          correctIndices: [0, 2],
          explanation: '24 × 4 = 96 and 32 × 3 = 96. (18 × 5 = 90, 22 × 4 = 88)',
        ),
      ],
    ),

    // 9. 120 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_120',
      title: '120 Chauraha',
      subtitle: 'The 5! Factorial & LCM Super-Hub',
      targetNumber: 120,
      primeFactorization: '120 = 2³ × 3 × 5 = 5! (Factorial)',
      examTip: '120 is 5! and the most common LCM in Time & Work for 15, 20, 24, 30 days! (15×8, 12×10, 20×6, 24×5, 30×4, 40×3).',
      topBranch: ChaurahaBranch(label: '15 × 8', factorA: 15, factorB: 8, product: 120),
      bottomBranch: ChaurahaBranch(label: '24 × 5', factorA: 24, factorB: 5, product: 120),
      leftBranch: ChaurahaBranch(label: '12 × 10', factorA: 12, factorB: 10, product: 120),
      rightBranch: ChaurahaBranch(label: '20 × 6', factorA: 20, factorB: 6, product: 120),
      extraBranch1: ChaurahaBranch(label: '30 × 4', factorA: 30, factorB: 4, product: 120),
      extraBranch2: ChaurahaBranch(label: '40 × 3', factorA: 40, factorB: 3, product: 120),
      allFactorPairs: ['15 × 8 = 120', '12 × 10 = 120', '20 × 6 = 120', '24 × 5 = 120', '30 × 4 = 120', '40 × 3 = 120'],
      questions: [
        ChaurahaQuestion(
          id: 'q_120_1',
          prompt: 'Which 2 pairs multiply to give 120?',
          target: 120,
          options: ['15 × 8', '14 × 9', '24 × 5', '16 × 7'],
          correctIndices: [0, 2],
          explanation: '15 × 8 = 120 and 24 × 5 = 120. (14 × 9 = 126, 16 × 7 = 112)',
        ),
        ChaurahaQuestion(
          id: 'q_120_2',
          prompt: 'Identify the 2 factor pairs of 120:',
          target: 120,
          options: ['18 × 7', '12 × 10', '20 × 6', '22 × 5'],
          correctIndices: [1, 2],
          explanation: '12 × 10 = 120 and 20 × 6 = 120. (18 × 7 = 126, 22 × 5 = 110)',
        ),
      ],
    ),

    // 10. 240 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_240',
      title: '240 Chauraha',
      subtitle: 'The Speed, Time & Distance Double Gross',
      targetNumber: 240,
      primeFactorization: '240 = 2⁴ × 3 × 5 = 16 × 15',
      examTip: 'Frequent distance in train and boat & stream problems. (15 × 16, 12 × 20, 24 × 10, 30 × 8, 40 × 6, 48 × 5, 60 × 4).',
      topBranch: ChaurahaBranch(label: '15 × 16', factorA: 15, factorB: 16, product: 240),
      bottomBranch: ChaurahaBranch(label: '30 × 8', factorA: 30, factorB: 8, product: 240),
      leftBranch: ChaurahaBranch(label: '12 × 20', factorA: 12, factorB: 20, product: 240),
      rightBranch: ChaurahaBranch(label: '24 × 10', factorA: 24, factorB: 10, product: 240),
      extraBranch1: ChaurahaBranch(label: '40 × 6', factorA: 40, factorB: 6, product: 240),
      extraBranch2: ChaurahaBranch(label: '48 × 5', factorA: 48, factorB: 5, product: 240),
      allFactorPairs: ['15 × 16 = 240', '12 × 20 = 240', '24 × 10 = 240', '30 × 8 = 240', '40 × 6 = 240', '48 × 5 = 240', '60 × 4 = 240'],
      questions: [
        ChaurahaQuestion(
          id: 'q_240_1',
          prompt: 'Which 2 pairs multiply to give 240?',
          target: 240,
          options: ['15 × 16', '14 × 17', '30 × 8', '18 × 13'],
          correctIndices: [0, 2],
          explanation: '15 × 16 = 240 and 30 × 8 = 240. (14 × 17 = 238, 18 × 13 = 234)',
        ),
      ],
    ),

    // 11. 360 Chauraha
    const ProductChaurahaModel(
      id: 'chauraha_360',
      title: '360 Chauraha',
      subtitle: 'The Complete Circle & Pie Chart Master',
      targetNumber: 360,
      primeFactorization: '360 = 2³ × 3² × 5 = 36 × 10',
      examTip: 'A full circle is 360°! Crucial in Data Interpretation Pie Charts (converting degrees to percentage: 3.6° = 1%).',
      topBranch: ChaurahaBranch(label: '15 × 24', factorA: 15, factorB: 24, product: 360),
      bottomBranch: ChaurahaBranch(label: '18 × 20', factorA: 18, factorB: 20, product: 360),
      leftBranch: ChaurahaBranch(label: '12 × 30', factorA: 12, factorB: 30, product: 360),
      rightBranch: ChaurahaBranch(label: '36 × 10', factorA: 36, factorB: 10, product: 360),
      extraBranch1: ChaurahaBranch(label: '40 × 9', factorA: 40, factorB: 9, product: 360),
      extraBranch2: ChaurahaBranch(label: '45 × 8', factorA: 45, factorB: 8, product: 360),
      allFactorPairs: ['15 × 24 = 360', '18 × 20 = 360', '12 × 30 = 360', '36 × 10 = 360', '40 × 9 = 360', '45 × 8 = 360', '72 × 5 = 360'],
      questions: [
        ChaurahaQuestion(
          id: 'q_360_1',
          prompt: 'Which 2 pairs multiply to give 360 (Pie Chart Circle)?',
          target: 360,
          options: ['15 × 24', '17 × 21', '18 × 20', '16 × 22'],
          correctIndices: [0, 2],
          explanation: '15 × 24 = 360 and 18 × 20 = 360. (17 × 21 = 357, 16 × 22 = 352)',
        ),
      ],
    ),
  ];

  /// Returns all available chaurahas
  static List<ProductChaurahaModel> getAll() => chaurahas;

  /// Find a specific chauraha by ID or target number
  static ProductChaurahaModel? getById(String id) {
    try {
      return chaurahas.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static ProductChaurahaModel? getByTarget(int target) {
    try {
      return chaurahas.firstWhere((c) => c.targetNumber == target);
    } catch (_) {
      return null;
    }
  }

  /// Flattens all questions across all chaurahas into a unified practice deck
  static List<ChaurahaQuestion> getAllQuestions() {
    final List<ChaurahaQuestion> all = [];
    for (var c in chaurahas) {
      all.addAll(c.questions);
    }
    return all;
  }

  /// Dynamically generates a random 2-correct multi-select question for practice drills
  static ChaurahaQuestion generateRandomQuestion([Random? random]) {
    final rng = random ?? Random();
    final chauraha = chaurahas[rng.nextInt(chaurahas.length)];

    if (chauraha.isBaseFormat) {
      // Base 25 question
      final List<String> correctPairs = [
        '25 × 12 = 300',
        '25 × 24 = 600',
      ];
      final List<String> distractors = [
        '25 × 14 = 350',
        '25 × 18 = 425',
      ];
      final options = [correctPairs[0], distractors[0], correctPairs[1], distractors[1]]..shuffle(rng);
      final c0 = options.indexOf(correctPairs[0]);
      final c1 = options.indexOf(correctPairs[1]);

      return ChaurahaQuestion(
        id: 'dyn_25_${DateTime.now().microsecondsSinceEpoch}',
        prompt: 'Select BOTH calculations that give 300 and 600 with Base 25:',
        target: 25,
        options: options,
        correctIndices: [min(c0, c1), max(c0, c1)],
        explanation: '${correctPairs[0]} and ${correctPairs[1]} are the correct branches of Base 25.',
      );
    }

    // Pick 2 distinct correct factor pairs
    final pairs = List<ChaurahaBranch>.from([
      chauraha.topBranch,
      chauraha.bottomBranch,
      chauraha.leftBranch,
      chauraha.rightBranch,
      if (chauraha.extraBranch1 != null) chauraha.extraBranch1!,
      if (chauraha.extraBranch2 != null) chauraha.extraBranch2!,
    ])..shuffle(rng);

    final pairA = '${pairs[0].factorA} × ${pairs[0].factorB}';
    final pairB = '${pairs[1].factorA} × ${pairs[1].factorB}';

    // Generate 2 plausible distractors near the target product
    final List<String> distractors = [];
    int attempts = 0;
    while (distractors.length < 2 && attempts < 20) {
      attempts++;
      final baseFactor = pairs[rng.nextInt(pairs.length)].factorA;
      final offset = (rng.nextBool() ? 1 : -1) * (rng.nextInt(2) + 1);
      final wrongOther = (chauraha.targetNumber ~/ baseFactor) + offset;
      if (wrongOther > 1 && (baseFactor * wrongOther) != chauraha.targetNumber) {
        final distStr = '$baseFactor × $wrongOther';
        if (!distractors.contains(distStr) && distStr != pairA && distStr != pairB) {
          distractors.add(distStr);
        }
      }
    }
    while (distractors.length < 2) {
      final fakeA = 13 + rng.nextInt(6);
      final fakeB = 7 + rng.nextInt(5);
      distractors.add('$fakeA × $fakeB');
    }

    final allOptions = [pairA, distractors[0], pairB, distractors[1]]..shuffle(rng);
    final idxA = allOptions.indexOf(pairA);
    final idxB = allOptions.indexOf(pairB);

    return ChaurahaQuestion(
      id: 'dyn_${chauraha.targetNumber}_${DateTime.now().microsecondsSinceEpoch}',
      prompt: 'Which 2 pairs multiply to give ${chauraha.targetNumber}?',
      target: chauraha.targetNumber,
      options: allOptions,
      correctIndices: [min(idxA, idxB), max(idxA, idxB)],
      explanation: '$pairA = ${chauraha.targetNumber} and $pairB = ${chauraha.targetNumber}.',
    );
  }
}
