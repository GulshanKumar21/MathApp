// lib/data/concept_examiner_traps.dart
import '../models/concept_formula_model.dart';

class ConceptExaminerTrap {
  final String trap;
  final String topperHack;
  final String audioSummary;

  const ConceptExaminerTrap({
    required this.trap,
    required this.topperHack,
    required this.audioSummary,
  });
}

class ConceptExaminerTrapRepository {
  static final Map<String, ConceptExaminerTrap> _trapsByConceptId = {
    // 1. Rectangle
    'mens_2d_rectangle': const ConceptExaminerTrap(
      trap: 'Crossroads (रास्ते) वाले प्रश्नों में 80% बच्चे दोनों रास्तों के बीच वाले कॉमन वर्ग (w²) का क्षेत्रफल घटाना भूल जाते हैं, या फिर outer path (+2w) और inner path (-2w) के फॉर्मूले में कन्फ्यूज हो जाते हैं।',
      topperHack: 'याद रखें: बाहरी रास्ते में हमेशा +2w (2w(l+b+2w)), अंदरूनी रास्ते में -2w (2w(l+b-2w)), और बीच वाले क्रॉसरोड में केवल सिंगल -w (w(l+b-w)) होता है!',
      audioSummary: 'आयत यानी रेक्टेंगल का क्षेत्रफल लेंथ गुणा ब्रैड्थ होता है, परिमाप 2 इन टू एल प्लस बी, और विकर्ण पाइथागोरस ट्रिपलेट से निकलता है। रास्ते वाले प्रश्नों में याद रखें: बाहरी रास्ते में प्लस टू डब्ल्यू और भीतरी रास्ते में माइनस टू डब्ल्यू लगाएं।',
    ),
    // 2. Square
    'mens_2d_square': const ConceptExaminerTrap(
      trap: 'विकर्ण (d) दिया होने पर बच्चे पहले भुजा (a = d/√2) निकालते हैं और फिर एरिया निकालते हैं, जिससे कैलकुलेशन लंबी हो जाती है और रूट में गलती होती है।',
      topperHack: 'सीधा सूत्र लगाएं: Area = d² / 2. यदि विकर्ण 10 सेमी है, तो क्षेत्रफल सीधा 100/2 = 50 सेमी² होगा!',
      audioSummary: 'वर्ग यानी स्क्वायर की चारों भुजाएं बराबर और विकर्ण रूट टू ए होता है। अगर विकर्ण दिया हो तो भुजा निकालने के बजाय सीधा डी स्क्वायर अपॉन टू से क्षेत्रफल निकालें।',
    ),
    // 3. Circle
    'circle_tangent_secant': const ConceptExaminerTrap(
      trap: 'सेकेंट थ्योरम में बच्चे PA × AB = PC × CD लिख देते हैं (यानी जीवा की लंबाई से गुणा कर देते हैं), जबकि दूरी हमेशा बाहरी बिंदु P से नापी जाती है!',
      topperHack: 'हमेशा याद रखें: "P से पहला बिंदु × P से दूसरा बिंदु"। यानी PA × PB = PC × PD या PT² = PA × PB!',
      audioSummary: 'वृत्त की स्पर्श रेखा और छेदक रेखा प्रमेय: बाहरी बिंदु पी से खींची गई स्पर्श रेखा पी टी का स्क्वायर हमेशा पी ए गुणा पी बी के बराबर होता है। याद रखें दोनों दूरियां बिंदु पी से ही नापी जाती हैं।',
    ),
    // 4. Triangles / Pythagoras
    'tri_formation_condition': const ConceptExaminerTrap(
      trap: 'त्रिभुज बनने की शर्त में केवल दो भुजाओं का योग > तीसरी भुजा देखना काफी नहीं है, दो भुजाओं का अंतर < तीसरी भुजा भी चेक करना अनिवार्य है।',
      topperHack: '|b - c| < a < b + c. एग्जाम में न्यूनतम और अधिकतम संभव मान के लिए यही सीमा सीधे उत्तर देती है!',
      audioSummary: 'त्रिभुज बनने की मूल शर्त: किसी भी त्रिभुज की कोई भुजा शेष दो भुजाओं के अंतर से बड़ी और उनके योग से हमेशा छोटी होनी चाहिए।',
    ),
    // 5. Right Triangle Altitudes
    'right_triangle_altitudes': const ConceptExaminerTrap(
      trap: 'समकोण शीर्ष से कर्ण पर लंब (p) की लंबाई निकालने में बच्चे भ्रमित हो जाते हैं और समरूपता सिद्ध करने में 2 मिनट बर्बाद कर देते हैं।',
      topperHack: 'सीधा सूत्र: लंब p = (Base × Perpendicular) / Hypotenuse. और 1/p² = 1/a² + 1/b²!',
      audioSummary: 'समकोण त्रिभुज में कर्ण पर डाले गए लंब की लंबाई दोनों लंबवत भुजाओं के गुणनफल को कर्ण से भाग देने पर निकलती है, यानी पी बराबर ए बी अपॉन सी।',
    ),
    // 6. Cylinder & Cone
    'mens_3d_solids_frustum': const ConceptExaminerTrap(
      trap: 'शंकु (Cone) के वक्र पृष्ठ CSA (πrl) में बच्चे ऊंचाई (h) को तिर्यक ऊंचाई (l) समझकर गुणा कर देते हैं, या व्यास (diameter) को त्रिज्या मान लेते हैं।',
      topperHack: 'प्रश्न में "व्यास" शब्द को तुरंत रेखांकित करें और r = d/2 लिखें। तिर्यक ऊंचाई हमेशा l = √(r² + h²) से निकालें!',
      audioSummary: 'शंकु का वक्र पृष्ठीय क्षेत्रफल पाई आर एल होता है जहां एल तिर्यक ऊंचाई है जो रूट आर स्क्वायर प्लस एच स्क्वायर से आती है। छिन्नक यानी फ्रस्टम का आयतन एक बटा तीन पाई एच आर स्क्वायर प्लस स्माल आर स्क्वायर प्लस आर आर होता है।',
    ),
    // 7. Divisibility & Remainder
    'div_rules_72_88': const ConceptExaminerTrap(
      trap: '72 की विभाज्यता चेक करने में 6 × 12 का नियम लगा देना, जबकि नियम सह-अभाज्य (Co-prime) गुणनखंडों (8 और 9) पर लागू होता है।',
      topperHack: '72 के लिए अंतिम 3 अंक 8 से कटने चाहिए और अंकों का योग 9 से। 88 के लिए 8 और 11 दोनों चेक करें!',
      audioSummary: '72 और 88 की विभाज्यता: हमेशा सह-अभाज्य गुणनखंड लें। 72 के लिए अंतिम तीन अंक 8 से और अंकों का योग 9 से कटना चाहिए। 88 के लिए 8 और 11 का नियम लगाएं।',
    ),
  };

  /// Fallback trap generator based on pillar
  static ConceptExaminerTrap getTrapForConcept(ConceptFormulaModel formula) {
    if (_trapsByConceptId.containsKey(formula.id)) {
      return _trapsByConceptId[formula.id]!;
    }

    // Smart fallback based on pillar
    switch (formula.pillar) {
      case ConceptPillar.mensuration:
        return ConceptExaminerTrap(
          trap: 'क्षेत्रमिति के प्रश्नों में 75% गलतियाँ इकाई परिवर्तन (मीटर को सेमी या लीटर में बदलने) और व्यास (Diameter) को त्रिज्या (Radius) मान लेने से होती हैं।',
          topperHack: 'उत्तर टिक करने से पहले 2 सेकंड रुकें: चेक करें कि प्रश्न में व्यास पूछा है या त्रिज्या, और इकाइयां समान (cm² vs m²) हैं या नहीं!',
          audioSummary: '${formula.title} का मुख्य सूत्र: ${formula.formula}. एग्जाम में इकाइयों और व्यास को त्रिज्या में बदलने का विशेष ध्यान रखें.',
        );
      case ConceptPillar.triangles:
      case ConceptPillar.linesAndAngle:
      case ConceptPillar.quadrilaterals:
      case ConceptPillar.circle:
        return ConceptExaminerTrap(
          trap: 'ज्यामिति में आकृति देखकर अनुपात उल्टा लिख देना (जैसे AB/AC के बजाय AC/AB) या गलत शीर्ष (vertex) से संगत भुजाएं मिलाना।',
          topperHack: 'हमेशा कोणों के सामने वाली सम्मुख भुजाओं के आधार पर समरूपता (Similarity) का अनुपात लिखें!',
          audioSummary: '${formula.title} का महत्वपूर्ण परिणाम: ${formula.formula}. समरूपता और पाइथागोरस ट्रिपलेट सीधे समय बचाते हैं.',
        );
      case ConceptPillar.algebra:
        return ConceptExaminerTrap(
          trap: 'बीजगणित में चिन्हों की गलती (खासकर x + 1/x = k से x - 1/x निकालते वक्त k² - 4 के स्थान पर k² + 4 कर देना)।',
          topperHack: 'माइनस से प्लस जाते समय +4 होता है (√(k² + 4)), प्लस से माइनस आते समय -4 होता है (√(k² - 4))!',
          audioSummary: 'बीजगणित का सूत्र: ${formula.formula}. चिन्हों का ध्यान रखें, प्लस से माइनस जाने पर अंडररूट के स्क्वायर माइनस चार होता है.',
        );
      case ConceptPillar.trigonometry:
      case ConceptPillar.heightAndDistance:
        return ConceptExaminerTrap(
          trap: 'चतुर्थांश (Quadrant) बदलते समय त्रिकोणमितीय अनुपातों के धनात्मक/ऋणात्मक चिन्ह भूल जाना, या sin(90+θ) को -cosθ लिख देना।',
          topperHack: 'ASTC नियम (All Silver Tea Cups) याद रखें: दूसरे चतुर्थांश में sin और cosec धनात्मक होते हैं!',
          audioSummary: 'त्रिकोणमिति सूत्र: ${formula.formula}. 0 से 90 डिग्री के मान और चतुर्थांश चिन्हों को तुरंत मन में रिकॉल करें.',
        );
      default:
        return ConceptExaminerTrap(
          trap: 'कैलकुलेशन में बेसिक नियम भूल जाना या विकल्प में समान दिखने वाले उत्तरों में भ्रमित होकर जल्दबाजी में गलत टिक करना।',
          topperHack: 'अंतिम अंक (Unit Digit) या डिजिटल सम (Digital Sum) से 2 सेकंड में उत्तर री-चेक करें!',
          audioSummary: '${formula.title} सूत्र: ${formula.formula}.',
        );
    }
  }
}
