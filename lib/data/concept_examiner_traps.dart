// lib/data/concept_examiner_traps.dart
import '../models/concept_formula_model.dart';

class ConceptExaminerTrap {
  final String trap;
  final String topperHack;
  final String audioSummary;
  final String desiJugaad;
  final String? confusingTwinTitle;
  final String? confusingTwinComparison;
  final String? reverseChallengeProblem;
  final List<String>? reverseChallengeOptions;
  final String? reverseChallengeAnswer;

  const ConceptExaminerTrap({
    required this.trap,
    required this.topperHack,
    required this.audioSummary,
    this.desiJugaad = '',
    this.confusingTwinTitle,
    this.confusingTwinComparison,
    this.reverseChallengeProblem,
    this.reverseChallengeOptions,
    this.reverseChallengeAnswer,
  });
}

class ConceptExaminerTrapRepository {
  static final Map<String, ConceptExaminerTrap> _trapsByConceptId = {
    // 1. Rectangle
    'mens_2d_rectangle': const ConceptExaminerTrap(
      trap: 'Crossroads (रास्ते) वाले प्रश्नों में 80% बच्चे दोनों रास्तों के बीच वाले कॉमन वर्ग (w²) का क्षेत्रफल घटाना भूल जाते हैं, या फिर outer path (+2w) और inner path (-2w) के फॉर्मूले में कन्फ्यूज हो जाते हैं।',
      topperHack: 'याद रखें: बाहरी रास्ते में हमेशा +2w (2w(l+b+2w)), अंदरूनी रास्ते में -2w (2w(l+b-2w)), और बीच वाले क्रॉसरोड में केवल सिंगल -w (w(l+b-w)) होता है!',
      audioSummary: 'आयत यानी रेक्टेंगल का क्षेत्रफल लेंथ गुणा ब्रैड्थ होता है, परिमाप 2 इन टू एल प्लस बी, और विकर्ण पाइथागोरस ट्रिपलेट से निकलता है। रास्ते वाले प्रश्नों में याद रखें: बाहरी रास्ते में प्लस टू डब्ल्यू और भीतरी रास्ते में माइनस टू डब्ल्यू लगाएं।',
      desiJugaad: '🎯 देसी जुगाड़: "बाहर चलो तो +2w, अंदर आओ तो -2w, बीच में काटो तो सिर्फ -w!"',
      confusingTwinTitle: '⚔️ Outer vs Inner vs Crossroads Path',
      confusingTwinComparison: '• Outer Path (+2w): 2w(l + b + 2w)\n• Inner Path (-2w): 2w(l + b − 2w)\n• Crossroads (-w): w(l + b − w)',
      reverseChallengeProblem: 'If Area = 432 cm² and Breadth = 12 cm, what is the Length of the rectangle?',
      reverseChallengeOptions: ['36 cm', '24 cm', '18 cm', '48 cm'],
      reverseChallengeAnswer: '36 cm',
    ),
    // 2. Square
    'mens_2d_square': const ConceptExaminerTrap(
      trap: 'विकर्ण (d) दिया होने पर बच्चे पहले भुजा (a = d/√2) निकालते हैं और फिर एरिया निकालते हैं, जिससे कैलकुलेशन लंबी हो जाती है और रूट में गलती होती है।',
      topperHack: 'सीधा सूत्र लगाएं: Area = d² / 2. यदि विकर्ण 10 सेमी है, तो क्षेत्रफल सीधा 100/2 = 50 सेमी² होगा!',
      audioSummary: 'वर्ग यानी स्क्वायर की चारों भुजाएं बराबर और विकर्ण रूट टू ए होता है। अगर विकर्ण दिया हो तो भुजा निकालने के बजाय सीधा डी स्क्वायर अपॉन टू से क्षेत्रफल निकालें।',
      desiJugaad: '🎯 देसी जुगाड़: "विकर्ण दिया हो तो भुजा भूल जाओ, सीधा विकर्ण का स्क्वायर आधा कर आओ!" (d²/2)',
      confusingTwinTitle: '⚔️ Side vs Diagonal Area Formula',
      confusingTwinComparison: '• When Side given: Area = a²\n• When Diagonal given: Area = d² / 2\n• Perimeter: 4a = 2√2 d',
      reverseChallengeProblem: 'If Diagonal of a square is 10 cm, what is its Area?',
      reverseChallengeOptions: ['50 cm²', '100 cm²', '25 cm²', '75 cm²'],
      reverseChallengeAnswer: '50 cm²',
    ),
    // 3. Circle
    'circle_tangent_secant': const ConceptExaminerTrap(
      trap: 'सेकेंट थ्योरम में बच्चे PA × AB = PC × CD लिख देते हैं (यानी जीवा की लंबाई से गुणा कर देते हैं), जबकि दूरी हमेशा बाहरी बिंदु P से नापी जाती है!',
      topperHack: 'हमेशा याद रखें: "P से पहला बिंदु × P से दूसरा बिंदु"। यानी PA × PB = PC × PD या PT² = PA × PB!',
      audioSummary: 'वृत्त की स्पर्श रेखा और छेदक रेखा प्रमेय: बाहरी बिंदु पी से खींची गई स्पर्श रेखा पी टी का स्क्वायर हमेशा पी ए गुणा पी बी के बराबर होता है। याद रखें दोनों दूरियां बिंदु पी से ही नापी जाती हैं।',
      desiJugaad: '🎯 देसी जुगाड़: "P को मत छोड़ना! दूरी हमेशा P से ही नपेगी: P से A गुणा P से B = P से T का स्क्वायर!"',
      confusingTwinTitle: '⚔️ Tangent-Secant vs Chords Intersection',
      confusingTwinComparison: '• External Point: PT² = PA × PB = PC × PD\n• Internal Chords: PA × PB = PC × PD (Cross intersection inside)',
      reverseChallengeProblem: 'If PA = 4 cm and AB = 5 cm (Secant PAB), what is Tangent length PT?',
      reverseChallengeOptions: ['6 cm', '4.5 cm', '5 cm', '8 cm'],
      reverseChallengeAnswer: '6 cm',
    ),
    // 4. Triangles / Pythagoras
    'tri_formation_condition': const ConceptExaminerTrap(
      trap: 'त्रिभुज बनने की शर्त में केवल दो भुजाओं का योग > तीसरी भुजा देखना काफी नहीं है, दो भुजाओं का अंतर < तीसरी भुजा भी चेक करना अनिवार्य है।',
      topperHack: '|b - c| < a < b + c. एग्जाम में न्यूनतम और अधिकतम संभव मान के लिए यही सीमा सीधे उत्तर देती है!',
      audioSummary: 'त्रिभुज बनने की मूल शर्त: किसी भी त्रिभुज की कोई भुजा शेष दो भुजाओं के अंतर से बड़ी और उनके योग से हमेशा छोटी होनी चाहिए।',
      desiJugaad: '🎯 देसी जुगाड़: "अंतर से बड़ा और जोड़ से छोटा — यही है त्रिभुज बनने का असली कोटा!"',
      confusingTwinTitle: '⚔️ Triangle Formation vs Angle Types',
      confusingTwinComparison: '• Formation: |b − c| < a < b + c\n• Acute Triangle: c² < a² + b²\n• Right Triangle: c² = a² + b²\n• Obtuse Triangle: c² > a² + b²',
      reverseChallengeProblem: 'If two sides of a triangle are 7 cm and 10 cm, which of these CANNOT be the third side?',
      reverseChallengeOptions: ['2 cm', '4 cm', '10 cm', '15 cm'],
      reverseChallengeAnswer: '2 cm',
    ),
    // 5. Right Triangle Altitudes
    'right_triangle_altitudes': const ConceptExaminerTrap(
      trap: 'समकोण शीर्ष से कर्ण पर लंब (p) की लंबाई निकालने में बच्चे भ्रमित हो जाते हैं और समरूपता सिद्ध करने में 2 मिनट बर्बाद कर देते हैं।',
      topperHack: 'सीधा सूत्र: लंब p = (Base × Perpendicular) / Hypotenuse. और 1/p² = 1/a² + 1/b²!',
      audioSummary: 'समकोण त्रिभुज में कर्ण पर डाले गए लंब की लंबाई दोनों लंबवत भुजाओं के गुणनफल को कर्ण से भाग देने पर निकलती है, यानी पी बराबर ए बी अपॉन सी।',
      desiJugaad: '🎯 देसी जुगाड़: "कर्ण पर लंब = दोनों भुजाओं की गुणा बटे कर्ण!" (p = a·b / c)',
      confusingTwinTitle: '⚔️ Altitude to Hypotenuse vs Inradius',
      confusingTwinComparison: '• Altitude to Hypotenuse: p = (a · b) / c\n• Inradius: r = (a + b − c) / 2\n• Circumradius: R = c / 2',
      reverseChallengeProblem: 'In a 6-8-10 right triangle, what is the length of altitude to hypotenuse?',
      reverseChallengeOptions: ['4.8 cm', '5.0 cm', '4.2 cm', '6.0 cm'],
      reverseChallengeAnswer: '4.8 cm',
    ),
    // 6. Cylinder & Cone
    'mens_3d_solids_frustum': const ConceptExaminerTrap(
      trap: 'शंकु (Cone) के वक्र पृष्ठ CSA (πrl) में बच्चे ऊंचाई (h) को तिर्यक ऊंचाई (l) समझकर गुणा कर देते हैं, या व्यास (diameter) को त्रिज्या मान लेते हैं।',
      topperHack: 'प्रश्न में "व्यास" शब्द को तुरंत रेखांकित करें और r = d/2 लिखें। तिर्यक ऊंचाई हमेशा l = √(r² + h²) से निकालें!',
      audioSummary: 'शंकु का वक्र पृष्ठीय क्षेत्रफल पाई आर एल होता है जहां एल तिर्यक ऊंचाई है जो रूट आर स्क्वायर प्लस एच स्क्वायर से आती है। छिन्नक यानी फ्रस्टम का आयतन एक बटा तीन पाई एच आर स्क्वायर प्लस स्माल आर स्क्वायर प्लस आर आर होता है।',
      desiJugaad: '🎯 देसी जुगाड़: "शंकु में h नहीं l चलता है, और l पाइथागोरस रूट(r²+h²) से ही निकलता है!"',
      confusingTwinTitle: '⚔️ Cone vs Cylinder Surface Area',
      confusingTwinComparison: '• Cylinder CSA: 2πrh • TSA: 2πr(h + r)\n• Cone CSA: πrl • TSA: πr(l + r)\n• Slant Height: l = √(r² + h²)',
      reverseChallengeProblem: 'In a cone with radius r = 7 cm and slant height l = 10 cm, what is its CSA (π = 22/7)?',
      reverseChallengeOptions: ['220 cm²', '440 cm²', '154 cm²', '308 cm²'],
      reverseChallengeAnswer: '220 cm²',
    ),
    // 7. Divisibility & Remainder
    'div_rules_72_88': const ConceptExaminerTrap(
      trap: '72 की विभाज्यता चेक करने में 6 × 12 का नियम लगा देना, जबकि नियम सह-अभाज्य (Co-prime) गुणनखंडों (8 और 9) पर लागू होता है।',
      topperHack: '72 के लिए अंतिम 3 अंक 8 से कटने चाहिए और अंकों का योग 9 से। 88 के लिए 8 और 11 दोनों चेक करें!',
      audioSummary: '72 और 88 की विभाज्यता: हमेशा सह-अभाज्य गुणनखंड लें। 72 के लिए अंतिम तीन अंक 8 से और अंकों का योग 9 से कटना चाहिए। 88 के लिए 8 और 11 का नियम लगाएं।',
      desiJugaad: '🎯 देसी जुगाड़: "72 का मतलब 8 और 9, 88 का मतलब 8 और 11 — हमेशा को-प्राइम जोड़ी ही चलेगी!"',
      confusingTwinTitle: '⚔️ Divisibility of 72 vs 88 vs 99',
      confusingTwinComparison: '• 72: Must be divisible by 8 AND 9\n• 88: Must be divisible by 8 AND 11\n• 99: Must be divisible by 9 AND 11',
      reverseChallengeProblem: 'If 7-digit number 5432a1b is divisible by 72, which rule will you check first?',
      reverseChallengeOptions: ['Divisibility of 8 (Last 3 digits)', 'Divisibility of 9', 'Divisibility of 6', 'Divisibility of 12'],
      reverseChallengeAnswer: 'Divisibility of 8 (Last 3 digits)',
    ),
  };

  /// Fallback trap generator based on pillar
  static ConceptExaminerTrap getTrapForConcept(ConceptFormulaModel formula) {
    if (_trapsByConceptId.containsKey(formula.id)) {
      return _trapsByConceptId[formula.id]!;
    }

    switch (formula.pillar) {
      case ConceptPillar.mensuration:
        return ConceptExaminerTrap(
          trap: 'क्षेत्रमिति के प्रश्नों में 75% गलतियाँ इकाई परिवर्तन (मीटर को सेमी या लीटर में बदलने) और व्यास (Diameter) को त्रिज्या (Radius) मान लेने से होती हैं।',
          topperHack: 'उत्तर टिक करने से पहले 2 सेकंड रुकें: चेक करें कि प्रश्न में व्यास पूछा है या त्रिज्या, और इकाइयां समान (cm² vs m²) हैं या नहीं!',
          audioSummary: '${formula.title} का मुख्य सूत्र: ${formula.formula}. एग्जाम में इकाइयों और व्यास को त्रिज्या में बदलने का विशेष ध्यान रखें.',
          desiJugaad: '🎯 देसी जुगाड़: "सवाल पढ़ते ही व्यास दिखे तो तुरंत आधा करके त्रिज्या r लिखो, नहीं तो 2.5 नंबर कटेगा!"',
          confusingTwinTitle: '⚔️ Perimeter vs Area Units',
          confusingTwinComparison: '• Length / Perimeter: Linear units (cm, m)\n• Area: Square units (cm², m²)\n• Volume: Cubic units (cm³, m³, Litres)',
          reverseChallengeProblem: 'If ratio of radii of two circles is 2:3, what is the ratio of their Areas?',
          reverseChallengeOptions: ['4:9', '2:3', '8:27', '1:2'],
          reverseChallengeAnswer: '4:9',
        );
      case ConceptPillar.triangles:
      case ConceptPillar.linesAndAngle:
      case ConceptPillar.quadrilaterals:
      case ConceptPillar.circle:
        return ConceptExaminerTrap(
          trap: 'ज्यामिति में आकृति देखकर अनुपात उल्टा लिख देना (जैसे AB/AC के बजाय AC/AB) या गलत शीर्ष (vertex) से संगत भुजाएं मिलाना।',
          topperHack: 'हमेशा कोणों के सामने वाली सम्मुख भुजाओं के आधार पर समरूपता (Similarity) का अनुपात लिखें!',
          audioSummary: '${formula.title} का महत्वपूर्ण परिणाम: ${formula.formula}. समरूपता और पाइथागोरस ट्रिपलेट सीधे समय बचाते हैं.',
          desiJugaad: '🎯 देसी जुगाड़: "बराबर कोणों के सामने वाली भुजाएं ही अनुपात में आएंगी, अपनी मर्जी से नहीं!"',
          confusingTwinTitle: '⚔️ Congruency (सर्वांगसमता) vs Similarity (समरूपता)',
          confusingTwinComparison: '• Similarity (∼): Angles equal, sides in ratio (Area ratio = k²)\n• Congruency (≅): Angles equal AND sides exactly equal (k = 1)',
          reverseChallengeProblem: 'If ΔABC ∼ ΔDEF with side ratio 3:5, what is Area(ABC) / Area(DEF)?',
          reverseChallengeOptions: ['9/25', '3/5', '27/125', '6/10'],
          reverseChallengeAnswer: '9/25',
        );
      case ConceptPillar.algebra:
        return ConceptExaminerTrap(
          trap: 'बीजगणित में चिन्हों की गलती (खासकर x + 1/x = k से x - 1/x निकालते वक्त k² - 4 के स्थान पर k² + 4 कर देना)।',
          topperHack: 'माइनस से प्लस जाते समय +4 होता है (√(k² + 4)), प्लस से माइनस आते समय -4 होता है (√(k² - 4))!',
          audioSummary: 'बीजगणित का सूत्र: ${formula.formula}. चिन्हों का ध्यान रखें, प्लस से माइनस जाने पर अंडररूट के स्क्वायर माइनस चार होता है.',
          desiJugaad: '🎯 देसी जुगाड़: "प्लस से माइनस जाना है तो -4 करो, माइनस से प्लस जाना है तो +4 करो!"',
          confusingTwinTitle: '⚔️ x² + 1/x² vs x³ + 1/x³',
          confusingTwinComparison: '• If x + 1/x = k:\n  x² + 1/x² = k² − 2\n  x³ + 1/x³ = k³ − 3k\n  x − 1/x = √(k² − 4)',
          reverseChallengeProblem: 'If x + 1/x = 3, what is x² + 1/x²?',
          reverseChallengeOptions: ['7', '9', '11', '6'],
          reverseChallengeAnswer: '7',
        );
      case ConceptPillar.trigonometry:
      case ConceptPillar.heightAndDistance:
        return ConceptExaminerTrap(
          trap: 'चतुर्थांश (Quadrant) बदलते समय त्रिकोणमितीय अनुपातों के धनात्मक/ऋणात्मक चिन्ह भूल जाना, या sin(90+θ) को -cosθ लिख देना।',
          topperHack: 'ASTC नियम (All Silver Tea Cups) याद रखें: दूसरे चतुर्थांश में sin और cosec धनात्मक होते हैं!',
          audioSummary: 'त्रिकोणमिति सूत्र: ${formula.formula}. 0 से 90 डिग्री के मान और चतुर्थांश चिन्हों को तुरंत मन में रिकॉल करें.',
          desiJugaad: '🎯 देसी जुगाड़: "All Silver Tea Cups (ASTC): पहले में सब +, दूसरे में Sin, तीसरे में Tan, चौथे में Cos!"',
          confusingTwinTitle: '⚔️ sin(90 ± θ) vs sin(180 ± θ)',
          confusingTwinComparison: '• 90° & 270°: Ratio CHANGES (sin ↔ cos, tan ↔ cot)\n• 180° & 360°: Ratio DOES NOT CHANGE (sin remains sin)',
          reverseChallengeProblem: 'If sin θ + cosec θ = 2, what is sin⁸θ + cosec⁸θ?',
          reverseChallengeOptions: ['2', '1', '4', '8'],
          reverseChallengeAnswer: '2',
        );
      default:
        return ConceptExaminerTrap(
          trap: 'कैलकुलेशन में बेसिक नियम भूल जाना या विकल्प में समान दिखने वाले उत्तरों में भ्रमित होकर जल्दबाजी में गलत टिक करना।',
          topperHack: 'अंतिम अंक (Unit Digit) या डिजिटल सम (Digital Sum) से 2 सेकंड में उत्तर री-चेक करें!',
          audioSummary: '${formula.title} सूत्र: ${formula.formula}.',
          desiJugaad: '🎯 देसी जुगाड़: "पूरा हल मत करो, पहले यूनिट डिजिट और डिजिटल सम से ऑप्शन काटो!"',
          confusingTwinTitle: '⚔️ Calculation Shortcut Check',
          confusingTwinComparison: '• Step 1: Check unit digit of options\n• Step 2: Use digital sum cancellation\n• Step 3: Exact calculation only if needed',
          reverseChallengeProblem: 'What is 15% of 240?',
          reverseChallengeOptions: ['36', '32', '40', '48'],
          reverseChallengeAnswer: '36',
        );
    }
  }
}
