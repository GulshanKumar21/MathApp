import '../models/math_models.dart';
import 'dynamic_question_engine.dart';

class ContentRepository {
  // Topics catalogue
  static List<TopicModel> getDefaultTopics() {
    return [
      TopicModel(
        id: 'addition',
        title: '➕ Speed Addition',
        subtitle: '1-Digit, 2-Digit, 3-Digit & 4-Digit Mental Addition Drills',
        type: TopicType.addition,
        iconName: 'add_rounded',
        isPremium: false,
        totalItems: 50,
      ),
      TopicModel(
        id: 'subtraction',
        title: '➖ Speed Subtraction',
        subtitle: '1-Digit, 2-Digit, 3-Digit & 4-Digit Fast Mental Subtraction',
        type: TopicType.subtraction,
        iconName: 'remove_rounded',
        isPremium: false,
        totalItems: 50,
      ),
      TopicModel(
        id: 'tables',
        title: '✖️ Tables & Speed Multiply (1–50)',
        subtitle: 'Tables 1 to 50 & 1D–4D Speed Multiplication inside one hub',
        type: TopicType.tables,
        iconName: 'grid_view_rounded',
        isPremium: false,
        totalItems: 50,
      ),
      TopicModel(
        id: 'division',
        title: '➗ Speed Division',
        subtitle: '1-Digit, 2-Digit, 3-Digit & 4-Digit Rapid Mental Division',
        type: TopicType.division,
        iconName: 'safety_divider_rounded',
        isPremium: false,
        totalItems: 30,
      ),
      TopicModel(
        id: 'triples',
        title: '🔺 Pythagorean Triples',
        subtitle: 'Exam-vital triples (3,4,5), (5,12,13) & scaled triplets',
        type: TopicType.triples,
        iconName: 'change_history_rounded',
        isPremium: false,
        totalItems: 30,
      ),
      TopicModel(
        id: 'squares',
        title: 'Square Numbers',
        subtitle: 'Squares 1 to 50 for quick mental recall',
        type: TopicType.squares,
        iconName: 'crop_square_rounded',
        isPremium: false,
        totalItems: 50,
      ),
      TopicModel(
        id: 'cubes',
        title: 'Cube Numbers',
        subtitle: 'Cubes 1 to 30 for high-speed calculation',
        type: TopicType.cubes,
        iconName: 'view_in_ar_rounded',
        isPremium: false,
        totalItems: 30,
      ),
      TopicModel(
        id: 'fractions',
        title: 'Fraction to Percentage & Decimal',
        subtitle: '1/2 to 1/25 essential conversions',
        type: TopicType.fractions,
        iconName: 'percent_rounded',
        isPremium: true,
        totalItems: 25,
      ),
      TopicModel(
        id: 'product_chauraha',
        title: '✖️ Important Products (Crossroads)',
        subtitle: 'Key product crossroads (108, 144, 180, 216, Base 25) with 2-answer drills',
        type: TopicType.productChauraha,
        iconName: 'alt_route_rounded',
        isPremium: false,
        totalItems: 35,
      ),
    ];
  }

  // Guaranteed non-repeating dynamic question generation
  static List<QuestionModel> generateQuestions(TopicType type, {int count = 15, int maxNum = 50}) {
    return DynamicQuestionEngine.generateUniqueQuestions(
      type: type,
      count: count,
    );
  }

  // Fraction data dictionary (Exam-standard rounding & conversions)
  static final List<Map<String, String>> fractionData = [
    {'fraction': '1/2', 'percent': '50%', 'decimal': '0.5'},
    {'fraction': '1/3', 'percent': '33.33%', 'decimal': '0.333'},
    {'fraction': '1/4', 'percent': '25%', 'decimal': '0.25'},
    {'fraction': '1/5', 'percent': '20%', 'decimal': '0.2'},
    {'fraction': '1/6', 'percent': '16.67%', 'decimal': '0.167'},
    {'fraction': '1/7', 'percent': '14.29%', 'decimal': '0.143'},
    {'fraction': '1/8', 'percent': '12.5%', 'decimal': '0.125'},
    {'fraction': '1/9', 'percent': '11.11%', 'decimal': '0.111'},
    {'fraction': '1/10', 'percent': '10%', 'decimal': '0.1'},
    {'fraction': '1/11', 'percent': '9.09%', 'decimal': '0.091'},
    {'fraction': '1/12', 'percent': '8.33%', 'decimal': '0.083'},
    {'fraction': '1/13', 'percent': '7.69%', 'decimal': '0.077'},
    {'fraction': '1/14', 'percent': '7.14%', 'decimal': '0.071'},
    {'fraction': '1/15', 'percent': '6.67%', 'decimal': '0.067'},
    {'fraction': '1/16', 'percent': '6.25%', 'decimal': '0.0625'},
    {'fraction': '1/17', 'percent': '5.88%', 'decimal': '0.059'},
    {'fraction': '1/18', 'percent': '5.56%', 'decimal': '0.056'},
    {'fraction': '1/19', 'percent': '5.26%', 'decimal': '0.053'},
    {'fraction': '1/20', 'percent': '5%', 'decimal': '0.05'},
    {'fraction': '1/24', 'percent': '4.17%', 'decimal': '0.042'},
    {'fraction': '1/25', 'percent': '4%', 'decimal': '0.04'},
    {'fraction': '2/3', 'percent': '66.67%', 'decimal': '0.667'},
    {'fraction': '3/4', 'percent': '75%', 'decimal': '0.75'},
    {'fraction': '3/8', 'percent': '37.5%', 'decimal': '0.375'},
    {'fraction': '5/8', 'percent': '62.5%', 'decimal': '0.625'},
    {'fraction': '7/8', 'percent': '87.5%', 'decimal': '0.875'},
    {'fraction': '4/7', 'percent': '57.14%', 'decimal': '0.571'},
    {'fraction': '5/6', 'percent': '83.33%', 'decimal': '0.833'},
  ];

  // Pythagorean Triples dataset
  static final List<List<int>> pythagoreanTriples = [
    // --- Core Primitive Triplets ---
    [3, 4, 5],
    [5, 12, 13],
    [7, 24, 25],
    [8, 15, 17],
    [9, 40, 41],
    [11, 60, 61],
    [12, 35, 37],
    [13, 84, 85],
    [16, 63, 65],
    [20, 21, 29],
    [28, 45, 53],
    [33, 56, 65],
    [36, 77, 85],
    [39, 80, 89],
    [48, 55, 73],
    [65, 72, 97],
    [20, 99, 101], // Added from standard competitive exam chart (20² + 99² = 101²)
    // --- Scaled Triplets from Base Families (×2, ×3, ×4, ×5) ---
    [6, 8, 10],   // (3, 4, 5) × 2
    [9, 12, 15],  // (3, 4, 5) × 3
    [12, 16, 20], // (3, 4, 5) × 4
    [15, 20, 25], // (3, 4, 5) × 5
    [10, 24, 26], // (5, 12, 13) × 2
    [15, 36, 39], // (5, 12, 13) × 3
    [14, 48, 50], // (7, 24, 25) × 2
    [21, 72, 75], // (7, 24, 25) × 3
  ];
}
