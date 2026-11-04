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
    this.examTip = 'SSC CGL, Bank PO aur Railway exams ke simplification me 100% helpful.',
  });
}

class VedicTricksRepository {
  static const List<VedicTrick> tricks = [
    VedicTrick(
      title: 'Aakhiri me 5 wale numbers ka Square',
      sutraName: 'Ekadhikena Purvena (Pehle digit ko agle number se guna)',
      category: 'Squares',
      rule: 'Pehle digit (N) ko uske agle number (N + 1) se guna karo, aur aakhiri me 25 chipka do.',
      example: '65² = ?\nStep 1: 6 × (6 + 1) = 6 × 7 = 42\nStep 2: Aakhiri me 25 likho\nAnswer: 4225',
      explanation: 'Formula: [N × (N + 1)] | 25. Sabhi numbers jinke aakhiri me 5 ho (15, 25, 35, 45, 65, 75, 85, 95...) sirf 1 second me bina pen ke solve hote hain!',
      examTip: 'Compound Interest me 1.05², 1.15² ya 1.25² nikaalne ke liye sabse best trick hai.',
    ),
    VedicTrick(
      title: 'Pehla Digit Same & Last Digits ka Jod = 10',
      sutraName: 'Antyayordashake\'pi (Aakhiri digits ka jod 10 ho)',
      category: 'Multiplication',
      rule: 'Pehle same digit ko agle number se multiply karo, aur aakhiri dono digits ko aapas me guna karo.',
      example: '74 × 76 = ?\nStep 1: Pehla digit = 7 ➔ 7 × (7 + 1) = 56\nStep 2: Aakhiri digits = 4 × 6 = 24\nAnswer: 5624',
      explanation: 'Shart: Pehla digit barabar hona chahiye (jaise 7 aur 7), aur aakhiri dono digits ka jod 10 hona chahiye (4 + 6 = 10). Formula: [T × (T + 1)] | [U1 × U2].',
      examTip: 'Banking Simplification aur Data Interpretation me har sawal par 20 se 25 seconds bachta hai.',
    ),
    VedicTrick(
      title: 'Kisi bhi Number ko 11 se Fast Multiply',
      sutraName: 'Antyayoreva (Kinare ke digits likho aur padosi jodo)',
      category: 'Multiplication',
      rule: 'Kinare ke digits shuru aur aakhiri me likho, aur beech me padosi digits ko aapas me jod do.',
      example: '52 × 11 = 5 [5+2] 2 ➔ 572\n78 × 11 = 7 [7+8] 8 = 7 [15] 8 ➔ 858',
      explanation: 'Traditional multiply karne ki zaroorat nahi hai! Dono taraf ke digits likhkar beech me unhe add karte jao.',
      examTip: 'Mensuration me jahan π (22/7 = 2 × 11/7) ka multiply hota hai, wahan ye trick sabse tez kaam karti hai.',
    ),
    VedicTrick(
      title: '100 se Chhote Numbers ka Multiply (Near 100)',
      sutraName: 'Nikhilam Navatashcaramam Dashatah (100 se kami dekho)',
      category: 'Base Method',
      rule: 'Dono 100 se kitna kam hain dekho. Cross-minus karo, phir dono kami ko aapas me guna karo.',
      example: '97 × 94 = ?\nKami: -3 aur -6\nLeft part: 97 - 6 = 91\nRight part: (-3) × (-6) = 18\nAnswer: 9118',
      explanation: 'Pehla hissa = Kisi bhi ek number me se dusre ki kami ghatao. Aakhiri hissa = Dono kami ka guna (2 digits). Instant 2-second answer!',
      examTip: 'SSC CGL Tier 1 & Tier 2 simplification me lagataar aata hai.',
    ),
    VedicTrick(
      title: '100 se Bade Numbers ka Multiply (100+)',
      sutraName: 'Nikhilam (100 se kitna zyada hai dekho)',
      category: 'Base Method',
      rule: 'Dono 100 se kitna zyada hain dekho. Cross-add karo, phir extra ko aapas me guna karo.',
      example: '104 × 107 = ?\nExtra: +4 aur +7\nLeft part: 104 + 7 = 111\nRight part: 4 × 7 = 28\nAnswer: 11128',
      explanation: 'Pehla hissa = 104 me dusre ka extra (7) jodo = 111. Aakhiri hissa = 4 × 7 = 28. Result = 11128. 1000 ke paas wale numbers me bhi same tarike se kaam karta hai.',
      examTip: 'Percentage aur Profit & Loss jaise 104% of 107 solve karne me bahut faydemand hai.',
    ),
    VedicTrick(
      title: 'Kisi 2-Digit Number ko 99, 999 se Multiply',
      sutraName: 'Ekanyunena Purvena (1 kam karo aur 100 se minus)',
      category: 'Multiplication',
      rule: 'Number me se 1 ghatao (pehla hissa), phir 100 me se us number ko minus karke aage likho.',
      example: '74 × 99 = ?\nStep 1: 74 - 1 = 73 (Pehla hissa)\nStep 2: 100 - 74 = 26 (Aakhiri hissa)\nAnswer: 7326',
      explanation: 'Formula: (N - 1) | (100 - N). Badi guna ko aasan single-digit ghatane me badal deta hai.',
      examTip: 'Quantitative section me × 99 ya × 999 aane par bina pen chalaye seedha answer likhein.',
    ),
    VedicTrick(
      title: '51 se 59 tak ke Numbers ka Fast Square',
      sutraName: 'Yavadunam (50 ke aage unit digit jodo)',
      category: 'Squares',
      rule: '25 me aakhiri digit (U) jodo, aur aage U² (2 digits me) likh do.',
      example: '54² = ?\nLeft part: 25 + 4 = 29\nRight part: 4² = 16\nAnswer: 2916\n58² = (25 + 8) | 64 ➔ 3364',
      explanation: 'Chunke 50, 100 ka aadha hai, isliye base 25 use hota hai. Kisi bhi 50s number ke liye: (25 + Aakhiri digit) | (Aakhiri digit ka square).',
      examTip: '2500 se 3600 ke beech ke squares 1 second me bina pen ke solve hote hain.',
    ),
    VedicTrick(
      title: 'Universal 2-Digit Multiply (Criss-Cross)',
      sutraName: 'Urdhva Tiryagbhyam (Sidha aur Tirchha Guna)',
      category: 'Universal Multiplication',
      rule: 'Sidha guna ➔ Cross guna karke jodo ➔ Sidha guna.',
      example: '23 × 14 = ?\n1) Right sidha: 3 × 4 = 12 (Likho 2, Carry 1)\n2) Cross guna: (2×4) + (3×1) + 1 = 12 (Likho 2, Carry 1)\n3) Left sidha: (2×1) + 1 = 3\nAnswer: 322',
      explanation: 'Kisi bhi 2-digit number ko multiply karne ka universal master formula. 3 line ke purane method ko 1 line me badalta hai.',
      examTip: 'Har competitive exam ke calculation speed ke liye sabse important trick hai.',
    ),
    VedicTrick(
      title: 'Percentage to Fraction Direct Shortcut',
      sutraName: 'Bhinnank Vidhi (Percentage ko Fraction me badlo)',
      category: 'Percentages',
      rule: 'Point wale percentages ko aasan fraction me badlo: 12.5% = 1/8, 25% = 1/4, 37.5% = 3/8.',
      example: '12.5% of 640 = ?\n640 × 12.5 ÷ 100 karne ke badle:\n640 ÷ 8 = 80 (Instant mental answer!)',
      explanation: 'Base fractions (1/2 se 1/20 tak) yaad rakhne se quantitative aptitude me 40% time bachta hai.',
      examTip: 'Bank PO aur SBI PO ke Data Interpretation (DI) me compulsory use hota hai.',
    ),
    VedicTrick(
      title: '1000 ke Paas wale Numbers ka Multiply',
      sutraName: 'Nikhilam Sahasram (1000 se kami dekho)',
      category: 'Base Method',
      rule: '1000 se kitna kam hai dekho. Cross-minus karo, aur dono kami ka guna 3 digits me likho.',
      example: '994 × 997 = ?\nKami: -6 aur -3\nLeft part: 994 - 3 = 991\nRight part: (-6) × (-3) = 018 (3 digits!)\nAnswer: 991018',
      explanation: '1000 me 3 zero hote hain, isliye aakhiri hissa hamesha 3 digits ka hona chahiye (18 ke badle 018).',
      examTip: 'Bade numbers ke simplification me calculate karne me seconds bachata hai.',
    ),
    VedicTrick(
      title: 'Lagaatar Numbers ka Multiply (n × (n + 1))',
      sutraName: 'Varga Sanyoga (Chhote number ka square + Chhota number)',
      category: 'Consecutive Numbers',
      rule: 'n × (n + 1) = Chhote number ka square + Chhota number.',
      example: '12 × 13 = 12² + 12 = 144 + 12 = 156\n17 × 18 = 17² + 17 = 289 + 17 = 306\n24 × 25 = 24² + 24 = 576 + 24 = 600',
      explanation: 'Alag se guna karne ke badle chhote number ke square me wahi number jod do. 1 second me solve hoga.',
      examTip: 'Bank PO aur SSC CGL ke number series aur simplification me bar-bar aata hai.',
    ),
    VedicTrick(
      title: '2 ke Gap wale Numbers ka Multiply',
      sutraName: 'Varga Antara Vidhi (Beech ke number ka square - 1)',
      category: 'Consecutive Numbers',
      rule: 'Jab do numbers ke beech 2 ka gap ho: Beech ke number ka square - 1.',
      example: '11 × 13 = 12² - 1 = 144 - 1 = 143\n13 × 15 = 14² - 1 = 196 - 1 = 195\n17 × 19 = 18² - 1 = 324 - 1 = 323\n24 × 26 = 25² - 1 = 625 - 1 = 624',
      explanation: 'Dono ke beech wale number ka square karke 1 ghatao. Seedha 1 second me answer!',
      examTip: 'Banking approximation aur fast calculation me sabse high-yield shortcut hai.',
    ),
    VedicTrick(
      title: '10 ke Gap wale Numbers jinke last me 5 ho',
      sutraName: 'Viral Maths Unit 5 Rule',
      category: 'Special Multiplications',
      rule: 'Dono ke last me 5 ho aur gap 10 ka ho: Last me hamesha 75 aayega, aur pehla hissa = (Bade tens digit)² - 1.',
      example: '15 × 25 = (2² - 1) | 75 = 375\n25 × 35 = (3² - 1) | 75 = 875\n35 × 45 = (4² - 1) | 75 = 1575\n45 × 55 = (5² - 1) | 75 = 2475',
      explanation: 'Formula: (Bada tens digit)² - 1 aur aage 75. Bina pen-paper ke 1 second me exact solution.',
      examTip: 'Exam me aane wale multiplication me instant time saver.',
    ),
    VedicTrick(
      title: '25, 125, 625 se Fast Multiply',
      sutraName: 'Gunita Samuchyah (Guna karne ke badle divide karo)',
      category: 'Special Multipliers',
      rule: '× 25 = 4 se divide karke 100 se guna\n× 125 = 8 se divide karke 1000 se guna\n× 625 = 16 se divide karke 10000 se guna',
      example: '12 × 25 = (12 ÷ 4) × 100 = 300\n24 × 25 = (24 ÷ 4) × 100 = 600\n16 × 125 = (16 ÷ 8) × 1000 = 2000\n48 × 125 = (48 ÷ 8) × 1000 = 6000',
      explanation: '25 = 100/4 aur 125 = 1000/8 hota hai. Badi guna karne ke badle 4 ya 8 se divide karna 5 guna tez hota hai.',
      examTip: 'Data Interpretation (DI) charts me fast calculation ke liye zaroori hai.',
    ),
  ];
}
