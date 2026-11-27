import 'package:flutter/material.dart';
import '../../data/concept_formula_repository.dart';
import '../../models/concept_formula_model.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../practice/practice_quiz_screen.dart';

/// 📐 Mensuration Formula Book Screen
/// Includes:
/// - 2D Formulas (13 shapes: Rectangle, Square, Triangles, Rhombus, Trapezium, Circles)
/// - 3D Formulas (12 shapes: Cube, Cuboid, Cylinder, Cone, Sphere, Frustum, Prism, Pyramid)
/// - 250 Solved PYQs
/// - Formula MCQ Mode ("MCQ me formula Puche")
class MensurationFormulaBookScreen extends StatefulWidget {
  final int initialTab;
  const MensurationFormulaBookScreen({super.key, this.initialTab = 0});

  @override
  State<MensurationFormulaBookScreen> createState() => _MensurationFormulaBookScreenState();
}

class _MensurationFormulaBookScreenState extends State<MensurationFormulaBookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<QuestionModel> _formulaMcqQuestions = [
    QuestionModel(
      id: 'f_mcq_1',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Curved Surface Area (CSA) of a Right Circular Cone of radius r and slant height l?\nत्रिज्या r और तिर्यक ऊंचाई l वाले शंकु का वक्र पृष्ठीय क्षेत्रफल (CSA) क्या है?',
      options: ['π r l', '2π r l', 'π r (l + r)', '⅓ π r² l'],
      correctAnswer: 'π r l',
      explanation: 'CSA of cone = π r l. Total Surface Area (TSA) = π r (l + r).',
    ),
    QuestionModel(
      id: 'f_mcq_2',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Total Surface Area (TSA) of a Solid Hemisphere of radius r?\nत्रिज्या r वाले ठोस अर्धगोले का कुल पृष्ठीय क्षेत्रफल (TSA) क्या है?',
      options: ['2π r²', '3π r²', '4π r²', '⅔ π r³'],
      correctAnswer: '3π r²',
      explanation: 'Curved surface area = 2πr², circular base area = πr². Total TSA = 2πr² + πr² = 3πr².',
    ),
    QuestionModel(
      id: 'f_mcq_3',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'What is the Volume of a Frustum of a Cone with height h and radii R and r?\nऊंचाई h तथा त्रिज्याओं R एवं r वाले शंकु के छिन्नक (Frustum) का आयतन क्या है?',
      options: [
        '⅓ π h (R² + r² + Rr)',
        'π h (R² + r²)',
        '⅓ π h (R² − r²)',
        '⅔ π h (R + r)²',
      ],
      correctAnswer: '⅓ π h (R² + r² + Rr)',
      explanation: 'Volume of frustum = ⅓ π h (R² + r² + Rr). Slant height l = √[h² + (R − r)²].',
    ),
    QuestionModel(
      id: 'f_mcq_4',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Area of a Rhombus with diagonals d₁ and d₂?\nविकर्ण d₁ और d₂ वाले समचतुर्भुज का क्षेत्रफल क्या है?',
      options: ['½ × d₁ × d₂', 'd₁ × d₂', '2 × (d₁ + d₂)', '¼ × d₁ × d₂'],
      correctAnswer: '½ × d₁ × d₂',
      explanation: 'Area of rhombus = ½ × d₁ × d₂. Side s = √[(d₁/2)² + (d₂/2)²].',
    ),
    QuestionModel(
      id: 'f_mcq_5',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Area of an Equilateral Triangle with side "a"?\nभुजा "a" वाले समबाहु त्रिभुज का क्षेत्रफल क्या है?',
      options: ['(√3 / 4) a²', '(√3 / 2) a²', '½ a²', '(3 / 4) a²'],
      correctAnswer: '(√3 / 4) a²',
      explanation: 'Area = (√3 / 4) a². Height h = (√3 / 2) a. Inradius r = a / (2√3). Circumradius R = a / √3.',
    ),
    QuestionModel(
      id: 'f_mcq_6',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Volume of a Sphere of radius R?\nत्रिज्या R वाले गोले का आयतन क्या है?',
      options: ['⁴⁄₃ π R³', '4π R²', '⅔ π R³', '⅓ π R³'],
      correctAnswer: '⁴⁄₃ π R³',
      explanation: 'Volume of sphere = ⁴⁄₃ π R³. Surface area = 4π R².',
    ),
    QuestionModel(
      id: 'f_mcq_7',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Length of the Longest Diagonal of a Cuboid with dimensions l, b, h?\nविमाओं l, b, h वाले घनाभ के सबसे लम्बे विकर्ण की लम्बाई क्या है?',
      options: ['√(l² + b² + h²)', 'l + b + h', '√(l² + b²)', '2(lb + bh + hl)'],
      correctAnswer: '√(l² + b² + h²)',
      explanation: 'Longest rod / diagonal in cuboid = √(l² + b² + h²).',
    ),
    QuestionModel(
      id: 'f_mcq_8',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'What is the Volume of a Regular Right Prism?\nएक सम लम्ब प्रिज़्म (Right Prism) का आयतन क्या होता है?',
      options: [
        'Base Area × Height',
        '⅓ × Base Area × Height',
        'Base Perimeter × Height',
        '½ × Base Area × Height',
      ],
      correctAnswer: 'Base Area × Height',
      explanation: 'Prism: Volume = Base Area × Height. CSA = Base Perimeter × Height. TSA = CSA + 2(Base Area).',
    ),
    QuestionModel(
      id: 'f_mcq_9',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 2,
      prompt: 'What is the Volume of a Regular Right Pyramid?\nएक सम पिरामिड (Right Pyramid) का आयतन क्या होता है?',
      options: [
        '⅓ × Base Area × Height',
        'Base Area × Height',
        '½ × Base Area × Slant Height',
        '⅔ × Base Area × Height',
      ],
      correctAnswer: '⅓ × Base Area × Height',
      explanation: 'Pyramid: Volume = ⅓ × Base Area × Vertical Height. CSA = ½ × Base Perimeter × Slant Height.',
    ),
    QuestionModel(
      id: 'f_mcq_10',
      topicId: 'mensuration_formula',
      examBadge: 'Formula MCQ',
      difficulty: 1,
      prompt: 'What is the Area of a Trapezium with parallel sides a, b and height h?\nसमानांतर भुजाओं a, b और ऊंचाई h वाले समलम्ब चतुर्भुज (Trapezium) का क्षेत्रफल क्या है?',
      options: ['½ (a + b) × h', '(a + b) × h', '½ (a − b) × h', '2(a + b) × h'],
      correctAnswer: '½ (a + b) × h',
      explanation: 'Area = ½ (sum of parallel sides) × height = ½ (a + b) h.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMensuration = ConceptFormulaRepository.getByPillar(ConceptPillar.mensuration);
    final list2D = allMensuration.where((c) => c.id.startsWith('mens_2d_')).toList();
    final list3D = allMensuration.where((c) => c.id.startsWith('mens_3d_')).toList();
    final allPyqs = allMensuration.expand((c) => c.practiceQuestions).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('📐 Mensuration Formula Book'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.gold,
          indicatorWeight: 3,
          labelColor: AppTheme.gold,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: '2D Shapes (${list2D.length})'),
            Tab(text: '3D Shapes (${list3D.length})'),
            Tab(text: 'All PYQs (${allPyqs.length})'),
            const Tab(text: 'Formula MCQs ⚡'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShapesList(list2D, is3D: false),
          _buildShapesList(list3D, is3D: true),
          _buildPyqList(allPyqs),
          _buildFormulaMcqView(),
        ],
      ),
    );
  }

  Widget _buildShapesList(List<ConceptFormulaModel> shapes, {required bool is3D}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shapes.length,
      itemBuilder: (context, index) {
        final shape = shapes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (is3D ? const Color(0xFF8B5CF6) : const Color(0xFF06B6D4)).withValues(alpha: 0.35)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (is3D ? const Color(0xFF8B5CF6) : const Color(0xFF06B6D4)).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  is3D ? Icons.view_in_ar_rounded : Icons.crop_square_rounded,
                  color: is3D ? const Color(0xFFA78BFA) : const Color(0xFF22D3EE),
                  size: 20,
                ),
              ),
              title: Text(
                shape.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
              ),
              subtitle: Text(
                shape.subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                // Formula Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    shape.formula,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.cyan, height: 1.35),
                  ),
                ),
                const SizedBox(height: 10),
                // Key conditions
                ...shape.keyConditions.map((kc) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(kc, style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.3)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
                // Practice Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: is3D ? const Color(0xFF7C3AED) : const Color(0xFF0891B2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: Text('Practice ${shape.practiceQuestions.length} PYQs', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeQuizScreen(
                            topic: TopicModel(
                              id: shape.id,
                              title: shape.title,
                              subtitle: shape.subtitle,
                              type: TopicType.fractions, // standard practice type
                              iconName: 'view_in_ar_rounded',
                            ),
                            customQuestions: shape.practiceQuestions,
                            questionCount: shape.practiceQuestions.length,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPyqList(List<QuestionModel> questions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      q.examBadge ?? 'SSC PYQ',
                      style: const TextStyle(color: AppTheme.accent, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Q${index + 1}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                q.prompt,
                style: const TextStyle(fontSize: 13.5, color: Colors.white, height: 1.35),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ans: ${q.correctAnswer}  •  ${q.explanation}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
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

  Widget _buildFormulaMcqView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Direct Formula Recall Quiz',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Test your direct memory of 2D & 3D Mensuration formulas! No long calculations—pure formula speed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text('Start Formula Quiz (10 MCQs)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeQuizScreen(
                    topic: TopicModel(
                      id: 'mensuration_formula_mcq',
                      title: '📐 Mensuration Formula Quiz',
                      subtitle: 'Direct Formula Recall Test',
                      type: TopicType.fractions,
                      iconName: 'functions_rounded',
                    ),
                    customQuestions: _formulaMcqQuestions,
                    questionCount: _formulaMcqQuestions.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
