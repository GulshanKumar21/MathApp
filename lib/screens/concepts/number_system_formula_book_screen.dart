import 'package:flutter/material.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';

/// 🔢 Number System Formula Book Screen
/// Includes:
/// - Core Formulas & Rules (Divisibility 2..99, Unit Digit Cyclicity, Remainder Theorem, Factors, Sequences, Trailing Zeros)
/// - Authentic Solved PYQs (SSC CGL, CHSL, CPO, RRB NTPC)
/// - Formula MCQ Mode ("MCQ me formula Puche")
class NumberSystemFormulaBookScreen extends StatefulWidget {
  final int initialTab;
  const NumberSystemFormulaBookScreen({super.key, this.initialTab = 0});

  @override
  State<NumberSystemFormulaBookScreen> createState() => _NumberSystemFormulaBookScreenState();
}

class _NumberSystemFormulaBookScreenState extends State<NumberSystemFormulaBookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<QuestionModel> _formulaMcqQuestions = [
    QuestionModel(
      id: 'ns_mcq_1',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'If N = pᵃ · qᵇ · rᶜ (where p, q, r are distinct prime numbers), what is the Total Number of Factors of N?\nयदि N = pᵃ · qᵇ · rᶜ (जहाँ p, q, r अभाज्य संख्याएँ हैं), तो N के कुल गुणनखंडों की संख्या क्या है?',
      options: [
        '(a + 1)(b + 1)(c + 1)',
        'a · b · c',
        '(a - 1)(b - 1)(c - 1)',
        'a + b + c',
      ],
      correctAnswer: '(a + 1)(b + 1)(c + 1)',
      explanation: 'Total number of factors for prime factorization N = pᵃ · qᵇ · rᶜ is given by (a + 1)(b + 1)(c + 1).',
    ),
    QuestionModel(
      id: 'ns_mcq_2',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the sum of the first n natural numbers (1 + 2 + 3 + ... + n)?\nप्रथम n प्राकृतिक संख्याओं का योग (1 + 2 + 3 + ... + n) क्या है?',
      options: [
        'n(n + 1) / 2',
        'n(n - 1) / 2',
        'n²',
        'n(n + 1)(2n + 1) / 6',
      ],
      correctAnswer: 'n(n + 1) / 2',
      explanation: 'Sum of first n natural numbers Σn = n(n + 1) / 2.',
    ),
    QuestionModel(
      id: 'ns_mcq_3',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'What is the sum of squares of the first n natural numbers (1² + 2² + 3² + ... + n²)?\nप्रथम n प्राकृतिक संख्याओं के वर्गों का योग क्या है?',
      options: [
        'n(n + 1)(2n + 1) / 6',
        '[n(n + 1) / 2]²',
        'n(n + 1) / 2',
        'n(2n + 1) / 3',
      ],
      correctAnswer: 'n(n + 1)(2n + 1) / 6',
      explanation: 'Sum of squares Σn² = n(n + 1)(2n + 1) / 6.',
    ),
    QuestionModel(
      id: 'ns_mcq_4',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'For an odd positive integer n, the expression (xⁿ + aⁿ) is always divisible by which factor?\nएक विषम धनात्मक पूर्णांक n के लिए, व्यंजक (xⁿ + aⁿ) सदैव किससे विभाज्य होता है?',
      options: [
        '(x + a)',
        '(x - a)',
        '(x² - a²)',
        '(x² + a²)',
      ],
      correctAnswer: '(x + a)',
      explanation: 'When n is odd, (xⁿ + aⁿ) has (x + a) as an algebraic factor because (-a)ⁿ + aⁿ = -aⁿ + aⁿ = 0.',
    ),
    QuestionModel(
      id: 'ns_mcq_5',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Cyclicity of the unit digit for numbers ending in digits 2, 3, 7, and 8?\n2, 3, 7, और 8 पर समाप्त होने वाली संख्याओं के इकाई अंक की चक्रीयता (Cyclicity) क्या है?',
      options: [
        '4',
        '2',
        '1',
        '6',
      ],
      correctAnswer: '4',
      explanation: 'Digits 2, 3, 7, and 8 repeat their unit digit pattern after every 4 powers (Cyclicity = 4). To find the unit digit, divide power by 4 and take remainder.',
    ),
    QuestionModel(
      id: 'ns_mcq_6',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'According to Fermat\'s Little Theorem, if p is prime and gcd(a, p) = 1, then aᵖ⁻¹ mod p equals:\nफर्मेट के प्रमेय के अनुसार, यदि p अभाज्य है और gcd(a, p) = 1 है, तो aᵖ⁻¹ mod p किसके बराबर होगा?',
      options: [
        '1',
        '0',
        'p - 1',
        'a',
      ],
      correctAnswer: '1',
      explanation: 'Fermat\'s Little Theorem states: a^(p-1) ≡ 1 (mod p) when p is a prime number and gcd(a, p) = 1.',
    ),
    QuestionModel(
      id: 'ns_mcq_7',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'What is the sum of cubes of the first n natural numbers (1³ + 2³ + 3³ + ... + n³)?\nप्रथम n प्राकृतिक संख्याओं के घनों का योग क्या है?',
      options: [
        '[n(n + 1) / 2]²',
        'n(n + 1)(2n + 1) / 6',
        'n²(n + 1)² / 2',
        'n³(n + 1) / 4',
      ],
      correctAnswer: '[n(n + 1) / 2]²',
      explanation: 'Sum of cubes Σn³ = [n(n + 1) / 2]² = (Σn)².',
    ),
    QuestionModel(
      id: 'ns_mcq_8',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'What is the formula for the Product of all factors of a natural number N having T total factors?\nT कुल गुणनखंडों वाली प्राकृतिक संख्या N के सभी गुणनखंडों का गुणनफल क्या है?',
      options: [
        'N^(T / 2)',
        'N^T',
        '(N / 2)^T',
        'N^(T - 1)',
      ],
      correctAnswer: 'N^(T / 2)',
      explanation: 'Factors pair up to multiply to N. Since each pair gives N, Product of all factors = N^(Total Factors / 2).',
    ),
    QuestionModel(
      id: 'ns_mcq_9',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'A number is divisible by 72 if and only if it is simultaneously divisible by:\nकोई संख्या 72 से विभाज्य होती है यदि और केवल यदि वह एक साथ किससे विभाज्य हो?',
      options: [
        '8 and 9',
        '6 and 12',
        '4 and 18',
        '2 and 36',
      ],
      correctAnswer: '8 and 9',
      explanation: 'For composite divisors, use co-prime factors: 72 = 8 × 9 where gcd(8, 9) = 1. Therefore test divisibility by 8 and 9.',
    ),
    QuestionModel(
      id: 'ns_mcq_10',
      topicId: 'number_system_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'How is the number of trailing zeros in n! (factorial) calculated?\nn! में अनुगामी शून्यों (trailing zeros) की संख्या कैसे ज्ञात की जाती है?',
      options: [
        '⌊n/5⌋ + ⌊n/25⌋ + ⌊n/125⌋ + ...',
        '⌊n/2⌋ + ⌊n/4⌋ + ⌊n/8⌋ + ...',
        '⌊n/10⌋ + ⌊n/100⌋ + ...',
        '⌊n/5⌋ × ⌊n/2⌋',
      ],
      correctAnswer: '⌊n/5⌋ + ⌊n/25⌋ + ⌊n/125⌋ + ...',
      explanation: 'Legendre\'s formula for power of 5 in n!: E₅(n!) = ⌊n/5⌋ + ⌊n/5²⌋ + ⌊n/5³⌋ + ... Each pair of (2 × 5) gives one zero, and 5 is the limiting factor.',
    ),
  ];

  int _selectedMcqIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  int _mcqScore = 0;
  final Set<int> _answeredMcqs = {};

  final List<Map<String, dynamic>> _coreRuleTopics = [
    {
      'title': '1. Divisibility Master Rules (विभाज्यता नियम)',
      'subtitle': 'Rules for 2, 3, 4, 5, 6, 7, 8, 9, 11, 13, 72, 88, 99',
      'icon': Icons.calculate_rounded,
      'color': Color(0xFF3B82F6),
      'rules': [
        {'divisor': '2', 'rule': 'Last digit is even (0, 2, 4, 6, 8).'},
        {'divisor': '3', 'rule': 'Sum of all digits is divisible by 3.'},
        {'divisor': '4', 'rule': 'Number formed by last 2 digits is divisible by 4.'},
        {'divisor': '5', 'rule': 'Last digit is 0 or 5.'},
        {'divisor': '6', 'rule': 'Divisible by both 2 and 3.'},
        {'divisor': '7', 'rule': 'Double the last digit and subtract from remaining number. Result divisible by 7 (or 3-digit alternating block rule).'},
        {'divisor': '8', 'rule': 'Number formed by last 3 digits is divisible by 8.'},
        {'divisor': '9', 'rule': 'Sum of all digits is divisible by 9 (Digital Root).'},
        {'divisor': '11', 'rule': '(Sum of digits at odd places) - (Sum of digits at even places) = 0 or multiple of 11.'},
        {'divisor': '13', 'rule': 'Add 4 times the last digit to the remaining number. Result divisible by 13.'},
        {'divisor': '72', 'rule': 'Co-prime pair: Must be divisible by both 8 and 9.'},
        {'divisor': '88', 'rule': 'Co-prime pair: Must be divisible by both 8 and 11.'},
        {'divisor': '99', 'rule': 'Co-prime pair: Must be divisible by both 9 and 11.'},
      ],
    },
    {
      'title': '2. Unit Digit & Cyclicity Rules (इकाई अंक और चक्रीयता)',
      'subtitle': 'Find unit digits of any massive power in 5 seconds',
      'icon': Icons.repeat_rounded,
      'color': Color(0xFF10B981),
      'rules': [
        {'divisor': '0, 1, 5, 6', 'rule': 'Cyclicity = 1. Unit digit never changes for any positive power! (...5ⁿ ends in 5, ...6ⁿ ends in 6).'},
        {'divisor': '4 and 9', 'rule': 'Cyclicity = 2.\n4^odd = 4, 4^even = 6.\n9^odd = 9, 9^even = 1.'},
        {'divisor': '2, 3, 7, 8', 'rule': 'Cyclicity = 4.\nStep 1: Divide the power by 4 to get remainder r = power mod 4.\nStep 2: If r = 0, treat exponent as 4. Unit digit = (Last digit)ʳ.'},
      ],
    },
    {
      'title': '3. Remainder Theorem & Algebraic Factors (शेषफल प्रमेय)',
      'subtitle': 'Divisor relations, Fermat, Euler, Wilson & powers',
      'icon': Icons.pie_chart_outline_rounded,
      'color': Color(0xFFF59E0B),
      'rules': [
        {'divisor': 'Euclid Division', 'rule': 'Dividend = (Divisor × Quotient) + Remainder, where 0 ≤ Remainder < Divisor.'},
        {'divisor': 'Fermat\'s Little Theorem', 'rule': 'If p is prime and gcd(a, p) = 1, then a^(p - 1) mod p = 1.'},
        {'divisor': 'Wilson\'s Theorem', 'rule': 'If p is prime, then (p - 1)! mod p = p - 1 (or -1 mod p).'},
        {'divisor': '(xⁿ + aⁿ)', 'rule': 'Always divisible by (x + a) when n is ODD.'},
        {'divisor': '(xⁿ - aⁿ)', 'rule': 'Always divisible by (x - a) for ALL n; and divisible by (x + a) when n is EVEN.'},
      ],
    },
    {
      'title': '4. Factors & Multiples Formulas (गुणनखंड सूत्र)',
      'subtitle': 'N = pᵃ · qᵇ · rᶜ formulas for SSC & Railway exams',
      'icon': Icons.hub_rounded,
      'color': Color(0xFF8B5CF6),
      'rules': [
        {'divisor': 'Total Factors', 'rule': 'T = (a + 1)(b + 1)(c + 1).'},
        {'divisor': 'Even Factors (p=2)', 'rule': 'T_even = a(b + 1)(c + 1) [power of 2 is not incremented by 1].'},
        {'divisor': 'Odd Factors', 'rule': 'T_odd = (b + 1)(c + 1) [completely ignore power of 2].'},
        {'divisor': 'Sum of Factors', 'rule': 'Sum = [(pᵃ⁺¹ - 1)/(p - 1)] × [(qᵇ⁺¹ - 1)/(q - 1)] × [(rᶜ⁺¹ - 1)/(r - 1)].'},
        {'divisor': 'Product of Factors', 'rule': 'Product = N^(Total Factors / 2).'},
        {'divisor': 'Prime Factors Count', 'rule': 'Number of prime factors = a + b + c. Number of distinct prime factors = 3 (p, q, r).'},
      ],
    },
    {
      'title': '5. Series Sum & Natural Numbers (श्रेणी सूत्र)',
      'subtitle': 'Sum of N numbers, squares, cubes & AP/GP',
      'icon': Icons.functions_rounded,
      'color': Color(0xFFEC4899),
      'rules': [
        {'divisor': 'Sum of First n Natural Numbers', 'rule': 'Σn = n(n + 1) / 2.'},
        {'divisor': 'Sum of First n Even Numbers', 'rule': '2 + 4 + ... + 2n = n(n + 1).'},
        {'divisor': 'Sum of First n Odd Numbers', 'rule': '1 + 3 + ... + (2n - 1) = n².'},
        {'divisor': 'Sum of Squares', 'rule': 'Σn² = n(n + 1)(2n + 1) / 6.'},
        {'divisor': 'Sum of Cubes', 'rule': 'Σn³ = [n(n + 1) / 2]² = (Σn)².'},
      ],
    },
    {
      'title': '6. Trailing Zeros in Factorials (अनुगामी शून्य)',
      'subtitle': 'Legendre\'s formula for counting trailing zeros',
      'icon': Icons.exposure_zero_rounded,
      'color': Color(0xFF06B6D4),
      'rules': [
        {'divisor': 'Trailing Zeros in n!', 'rule': 'Zeros = ⌊n/5⌋ + ⌊n/25⌋ + ⌊n/125⌋ + ⌊n/625⌋ + ... until quotient becomes 0.'},
        {'divisor': 'Concept Note', 'rule': 'Zero is formed by 2 × 5. In factorials, factor 2 is abundant, so the number of 5s determines the zeros.'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _solvedPyqs = [
    {
      'exam': 'SSC CGL 2023 Tier-1',
      'topic': 'Divisibility by 88',
      'question': 'If the 8-digit number 888x53y4 is divisible by 72, then what is the value of (2x + 3y) for the largest possible value of y?',
      'solution': 'Step 1: 72 = 8 × 9 (co-prime factors).\nStep 2: For divisibility by 8, last 3 digits 3y4 must be divisible by 8. Testing largest y: for y=8, 384/8 = 48 (Exact divisible). So y = 8.\nStep 3: For divisibility by 9, sum of digits = 8+8+8+x+5+3+8+4 = 44 + x. For this to be divisible by 9, x = 1 (45).\nStep 4: (2x + 3y) = 2(1) + 3(8) = 2 + 24 = 26.',
      'answer': '26',
      'trick': 'Test largest y downward from 9: 394 no, 384 divisible! Then digital root gives x in 2 seconds.',
    },
    {
      'exam': 'SSC CHSL 2024 Tier-1',
      'topic': 'Unit Digit Cyclicity',
      'question': 'What is the unit digit of (432)⁴¹² × (433)⁴¹³ × (437)⁴¹⁵?',
      'solution': 'Step 1: For base 432, unit digit 2 has cyclicity 4. Power 412 mod 4 = 0 -> use 2⁴ = 16 -> unit digit = 6.\nStep 2: For base 433, unit digit 3 has cyclicity 4. Power 413 mod 4 = 1 -> 3¹ = 3.\nStep 3: For base 437, unit digit 7 has cyclicity 4. Power 415 mod 4 = 3 -> 7³ = 343 -> unit digit = 3.\nStep 4: Multiply unit digits: 6 × 3 × 3 = 54 -> Unit digit = 4.',
      'answer': '4',
      'trick': 'Powers: 412%4=4 -> 6; 413%4=1 -> 3; 415%4=3 -> 3. 6 × 3 × 3 = 54 -> 4!',
    },
    {
      'exam': 'RRB NTPC CBT-2',
      'topic': 'Total & Even Factors',
      'question': 'Find the number of even factors and odd factors of 1440.',
      'solution': 'Step 1: Prime factorization of 1440 = 2⁵ × 3² × 5¹.\nStep 2: Total factors = (5+1)(2+1)(1+1) = 6 × 3 × 2 = 36.\nStep 3: Odd factors = completely omit 2 -> (2+1)(1+1) = 3 × 2 = 6.\nStep 4: Even factors = Total - Odd = 36 - 6 = 30 [or 5 × 3 × 2 = 30].',
      'answer': 'Even = 30, Odd = 6',
      'trick': 'Even factors = a(b+1)(c+1) = 5 × 3 × 2 = 30. Direct 3-second calculation!',
    },
    {
      'exam': 'SSC CPO 2023',
      'topic': 'Remainder Theorem',
      'question': 'What is the remainder when (17²⁰⁰) is divided by 18?',
      'solution': 'Step 1: Use negative remainder: 17 ≡ -1 (mod 18).\nStep 2: (17)²⁰⁰ ≡ (-1)²⁰⁰ (mod 18).\nStep 3: (-1)²⁰⁰ = +1.\nStep 4: Remainder = 1.',
      'answer': '1',
      'trick': 'Negative remainder shortcut: 17 = 18 - 1. (-1)^even power = +1. Instant 1-second answer!',
    },
    {
      'exam': 'SSC CGL Tier-2 2023',
      'topic': 'Trailing Zeros',
      'question': 'Find the number of trailing zeros in 126! (factorial).',
      'solution': 'Step 1: Use Legendre\'s formula E₅(126!).\nStep 2: ⌊126 / 5⌋ = 25.\nStep 3: ⌊25 / 5⌋ = 5.\nStep 4: ⌊5 / 5⌋ = 1.\nStep 5: Total zeros = 25 + 5 + 1 = 31.',
      'answer': '31',
      'trick': 'Continuous division by 5: 126/5=25; 25/5=5; 5/5=1. Sum = 25 + 5 + 1 = 31.',
    },
    {
      'exam': 'SSC CGL Tier-1 2024',
      'topic': 'Divisibility of xⁿ - aⁿ',
      'question': 'The expression (49¹⁵ - 1) is completely divisible by which of the following numbers? (Options: 50, 51, 29, 8)',
      'solution': 'Step 1: (49¹⁵ - 1) = (7³⁰ - 1).\nStep 2: (xⁿ - 1) is divisible by (x - 1) for all n. Here (49 - 1) = 48.\nStep 3: Since 48 is divisible by 8 (48 = 6 × 8), (49¹⁵ - 1) is completely divisible by 8.',
      'answer': '8',
      'trick': '49 - 1 = 48. Factors of 48: 8 divides 48, so 8 is the correct answer!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13192B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.format_list_numbered_rounded, color: Color(0xFF3B82F6), size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number System Formula Book',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'संख्या पद्धति • Rules, Solved PYQs & Formula MCQs',
                    style: TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Core Formulas'),
            Tab(text: 'Solved PYQs'),
            Tab(text: 'Formula MCQs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoreFormulasTab(),
          _buildSolvedPyqsTab(),
          _buildFormulaMcqTab(),
        ],
      ),
    );
  }

  Widget _buildCoreFormulasTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _coreRuleTopics.length,
      itemBuilder: (context, index) {
        final topic = _coreRuleTopics[index];
        final Color col = topic['color'] as Color;
        final List<Map<String, String>> rules = (topic['rules'] as List).cast<Map<String, String>>();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF13192B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: col.withValues(alpha: 0.3)),
          ),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: col.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(topic['icon'] as IconData, color: col, size: 22),
            ),
            title: Text(
              topic['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.5),
            ),
            subtitle: Text(
              topic['subtitle'] as String,
              style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.6)),
            ),
            childrenPadding: const EdgeInsets.all(14),
            children: rules.map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: col.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r['divisor']!,
                        style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r['rule']!,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSolvedPyqsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _solvedPyqs.length,
      itemBuilder: (context, index) {
        final q = _solvedPyqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13192B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      q['exam']!,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    q['topic']!,
                    style: const TextStyle(fontSize: 11.5, color: Colors.white60, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                q['question']!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  q['solution']!,
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, color: AppTheme.accent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '5-Sec Trick: ${q['trick']}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormulaMcqTab() {
    final currentQ = _formulaMcqQuestions[_selectedMcqIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_selectedMcqIndex + 1} of ${_formulaMcqQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Score: $_mcqScore',
                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF13192B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Direct Formula MCQ',
                    style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 10.5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentQ.prompt,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(currentQ.options.length, (optIdx) {
            final opt = currentQ.options[optIdx];
            final bool isSelected = _selectedAnswerIndex == optIdx;
            final bool isCorrect = opt == currentQ.correctAnswer;
            Color borderCol = Colors.white12;
            Color bgCol = const Color(0xFF13192B);

            if (_isAnswerSubmitted) {
              if (isCorrect) {
                borderCol = AppTheme.accent;
                bgCol = AppTheme.accent.withValues(alpha: 0.15);
              } else if (isSelected) {
                borderCol = AppTheme.error;
                bgCol = AppTheme.error.withValues(alpha: 0.15);
              }
            } else if (isSelected) {
              borderCol = const Color(0xFF3B82F6);
              bgCol = const Color(0xFF3B82F6).withValues(alpha: 0.15);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isAnswerSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswerIndex = optIdx;
                        });
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgCol,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderCol, width: isSelected || (_isAnswerSubmitted && isCorrect) ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: borderCol.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          String.fromCharCode(65 + optIdx),
                          style: TextStyle(fontWeight: FontWeight.bold, color: borderCol, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt,
                          style: const TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          if (!_isAnswerSubmitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedAnswerIndex == null
                    ? null
                    : () {
                        setState(() {
                          _isAnswerSubmitted = true;
                          _answeredMcqs.add(_selectedMcqIndex);
                          if (currentQ.options[_selectedAnswerIndex!] == currentQ.correctAnswer) {
                            _mcqScore += 10;
                          }
                        });
                      },
                child: const Text('Submit Answer (उत्तर जाँचें)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          if (_isAnswerSubmitted) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explanation (व्याख्या):', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    currentQ.explanation,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (_selectedMcqIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedMcqIndex--;
                          _selectedAnswerIndex = null;
                          _isAnswerSubmitted = false;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_selectedMcqIndex > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_selectedMcqIndex < _formulaMcqQuestions.length - 1) {
                          _selectedMcqIndex++;
                          _selectedAnswerIndex = null;
                          _isAnswerSubmitted = false;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('All MCQs Completed! Final Score: $_mcqScore'),
                              backgroundColor: AppTheme.accent,
                            ),
                          );
                        }
                      });
                    },
                    child: Text(_selectedMcqIndex < _formulaMcqQuestions.length - 1 ? 'Next Question' : 'Finish Quiz'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
