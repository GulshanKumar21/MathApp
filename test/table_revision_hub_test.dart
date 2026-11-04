import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Table Revision Hub - Starred tables bookmarking and dynamic question generation', () async {
    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    // Initial starred tables starts completely empty (zero hardcoded mock data)
    expect(provider.starredTables.isEmpty, isTrue);

    // Star Table 17 dynamically
    expect(provider.isTableStarred(17), isFalse);
    await provider.toggleStarTable(17);
    expect(provider.isTableStarred(17), isTrue);

    // Toggle star Table 23 dynamically
    expect(provider.isTableStarred(23), isFalse);
    await provider.toggleStarTable(23);
    expect(provider.isTableStarred(23), isTrue);

    // Unstar Table 17
    await provider.toggleStarTable(17);
    expect(provider.isTableStarred(17), isFalse);
    expect(provider.isTableStarred(23), isTrue);

    // Clear all starred tables
    await provider.clearAllStarredTables();
    expect(provider.starredTables.isEmpty, isTrue);
    expect(provider.isTableStarred(23), isFalse);

    // Initial custom revision deck starts completely empty (zero mock/dummy items)
    expect(provider.revisionItems.isEmpty, isTrue);
    await provider.clearAllRevisionDeck();
    expect(provider.revisionItems.isEmpty, isTrue);

    // Verify dynamic table questions generation for Table 1 to 50
    for (int tableNum in [7, 16, 17, 19, 23, 29, 36, 48]) {
      final questions = DynamicQuestionEngine.generateTableQuestions(tableNum, count: 10);
      expect(questions.length, 10);
      for (var q in questions) {
        expect(q.prompt.contains('$tableNum ×'), isTrue);
        expect(q.options.contains(q.correctAnswer), isTrue);
      }
    }

    // Verify Easy Level Table Questions (1–10)
    final easyQs = DynamicQuestionEngine.generateTableRangeQuestions(
      startTable: 1,
      endTable: 10,
      count: 10,
      maxMultiplier: 9,
    );
    expect(easyQs.length, 10);
    for (var q in easyQs) {
      expect(q.options.contains(q.correctAnswer), isTrue);
    }

    // Verify Medium Level Table Questions (11–20)
    final medQs = DynamicQuestionEngine.generateTableRangeQuestions(
      startTable: 11,
      endTable: 20,
      count: 15,
      maxMultiplier: 12,
    );
    expect(medQs.length, 15);
    for (var q in medQs) {
      expect(q.options.contains(q.correctAnswer), isTrue);
    }

    // Verify Hard Level Table Questions (21–50)
    final hardQs = DynamicQuestionEngine.generateTableRangeQuestions(
      startTable: 21,
      endTable: 50,
      count: 20,
      maxMultiplier: 15,
    );
    expect(hardQs.length, 20);
    for (var q in hardQs) {
      expect(q.options.contains(q.correctAnswer), isTrue);
    }

    // Verify Multi-Table Mix Practice (2 or 3+ tables mixture)
    final mix2Tables = [13, 17];
    final mix2Qs = DynamicQuestionEngine.generateMultiTableQuestions(
      tables: mix2Tables,
      count: 10,
      maxMultiplier: 12,
    );
    expect(mix2Qs.length, 10);
    Set<int> foundTablesInMix2 = {};
    for (var q in mix2Qs) {
      expect(q.options.contains(q.correctAnswer), isTrue);
      for (int t in mix2Tables) {
        if (q.prompt.startsWith('$t ×')) {
          foundTablesInMix2.add(t);
        }
      }
    }
    // Both tables 13 and 17 must be included in the mixed drill
    expect(foundTablesInMix2.contains(13), isTrue);
    expect(foundTablesInMix2.contains(17), isTrue);

    // Verify 3+ tables mixture (e.g. 14, 19, 23)
    final mix3Tables = [14, 19, 23];
    final mix3Qs = DynamicQuestionEngine.generateMultiTableQuestions(
      tables: mix3Tables,
      count: 15,
      maxMultiplier: 12,
    );
    expect(mix3Qs.length, 15);
    Set<int> foundTablesInMix3 = {};
    for (var q in mix3Qs) {
      expect(q.options.contains(q.correctAnswer), isTrue);
      for (int t in mix3Tables) {
        if (q.prompt.startsWith('$t ×')) {
          foundTablesInMix3.add(t);
        }
      }
    }
    expect(foundTablesInMix3.contains(14), isTrue);
    expect(foundTablesInMix3.contains(19), isTrue);
    expect(foundTablesInMix3.contains(23), isTrue);
  });

  test('Multi-Table Mix Practice - Zero hardcoded data, dynamic selection & strictly non-trivial multipliers (no 1 and no 10)', () async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Initially no hardcoded mix tables
    final initialSaved = prefs.getStringList('mix_selected_tables');
    expect(initialSaved, isNull);

    // 2. User dynamically picks tables e.g. [7, 8, 9] and saves
    await prefs.setStringList('mix_selected_tables', ['7', '8', '9']);
    final loaded = prefs.getStringList('mix_selected_tables') ?? [];
    expect(loaded, ['7', '8', '9']);

    // 3. Questions generated for user's chosen tables are 100% dynamic
    final userTables = loaded.map((e) => int.parse(e)).toList();
    final qs = DynamicQuestionEngine.generateMultiTableQuestions(
      tables: userTables,
      count: 20,
      maxMultiplier: 12,
    );
    expect(qs.length, 20);

    for (var q in qs) {
      // Must be from 7, 8, or 9
      final startsWithUserTable = userTables.any((t) => q.prompt.startsWith('$t ×'));
      expect(startsWithUserTable, isTrue, reason: 'Question prompt ${q.prompt} must be from user tables $userTables');

      // Multiplier strictly NOT 1 and NOT 10
      expect(q.prompt.contains('× 1 ='), isFalse, reason: 'Trivial × 1 must not be included');
      expect(q.prompt.contains('× 10 ='), isFalse, reason: 'Trivial × 10 must not be included');

      // Options must contain correct answer and be non-empty
      expect(q.options.contains(q.correctAnswer), isTrue);
      expect(q.options.length, 4);
    }

    // 4. Dynamic empty fallback picks random tables dynamically without crash
    final dynamicEmptyQs = DynamicQuestionEngine.generateMultiTableQuestions(
      tables: [],
      count: 10,
      maxMultiplier: 12,
    );
    expect(dynamicEmptyQs.length, 10);
    for (var q in dynamicEmptyQs) {
      expect(q.options.contains(q.correctAnswer), isTrue);
      expect(q.prompt.contains('× 1 ='), isFalse);
      expect(q.prompt.contains('× 10 ='), isFalse);
    }
  });

  test('Targeted Table 2 Drill strictly generates Table 2 questions only (No 6x9) and reaches up to 20', () {
    // 1. Table 2 with multipliers up to 20
    final q20 = DynamicQuestionEngine.generateTableQuestions(2, count: 25, maxMultiplier: 20);
    expect(q20.length, 25);
    final multipliersEncountered = <int>{};
    for (var q in q20) {
      // Must strictly start with "2 ×"
      expect(q.prompt.startsWith('2 × '), isTrue, reason: 'Expected prompt to start with "2 × ", got ${q.prompt}');
      // Cannot be from other tables (e.g., 6 x 9)
      expect(q.prompt.startsWith('6 ×'), isFalse);
      expect(q.prompt.startsWith('7 ×'), isFalse);
      expect(q.prompt.startsWith('8 ×'), isFalse);

      final parts = q.prompt.replaceAll(' = ?', '').split(' × ');
      final mult = int.parse(parts[1]);
      multipliersEncountered.add(mult);
      expect(mult >= 2 && mult <= 20, isTrue, reason: 'Multiplier $mult must be within 2..20');
      expect(q.options.contains(q.correctAnswer), isTrue);
    }
    // Verify higher multipliers (11..20) are actually generated
    expect(multipliersEncountered.any((m) => m > 10), isTrue,
        reason: 'Should contain multipliers greater than 10 when maxMultiplier is 20');

    // 2. Table 2 with multipliers up to 12
    final q12 = DynamicQuestionEngine.generateTableQuestions(2, count: 15, maxMultiplier: 12);
    for (var q in q12) {
      expect(q.prompt.startsWith('2 × '), isTrue);
      final mult = int.parse(q.prompt.replaceAll(' = ?', '').split(' × ')[1]);
      expect(mult >= 2 && mult <= 12, isTrue);
    }

    // 3. Table 2 with multipliers up to 10
    final q10 = DynamicQuestionEngine.generateTableQuestions(2, count: 15, maxMultiplier: 10);
    for (var q in q10) {
      expect(q.prompt.startsWith('2 × '), isTrue);
      final mult = int.parse(q.prompt.replaceAll(' = ?', '').split(' × ')[1]);
      expect(mult >= 2 && mult <= 10, isTrue);
    }

    // 4. Any other table (e.g. Table 19) strictly generates Table 19 only
    final q19 = DynamicQuestionEngine.generateTableQuestions(19, count: 15, maxMultiplier: 20);
    for (var q in q19) {
      expect(q.prompt.startsWith('19 × '), isTrue);
      final mult = int.parse(q.prompt.replaceAll(' = ?', '').split(' × ')[1]);
      expect(mult >= 2 && mult <= 20, isTrue);
    }
  });

  test('Drill Sets strictly guarantee zero repeated questions in 10 and 20 question sets', () {
    // 1. Table 10 with 10 questions: All 10 questions must be 100% unique (no 10 * 4 repeated!)
    final set10 = DynamicQuestionEngine.generateTableQuestions(10, count: 10, maxMultiplier: 12);
    expect(set10.length, 10);
    final prompts10 = set10.map((q) => q.prompt).toSet();
    expect(prompts10.length, 10, reason: 'All 10 prompts must be strictly unique, no duplicates');

    // 2. Table 10 with 20 questions: All 20 questions must be unique when maxMultiplier >= 20
    final set20 = DynamicQuestionEngine.generateTableQuestions(10, count: 20, maxMultiplier: 21);
    expect(set20.length, 20);
    final prompts20 = set20.map((q) => q.prompt).toSet();
    expect(prompts20.length, 20, reason: 'All 20 prompts must be strictly unique, zero duplicates (10x4 appears at most 1 time)');

    // 3. For any table (e.g. Table 2) with 20 questions, verify no prompt appears multiple times
    final set2_20 = DynamicQuestionEngine.generateTableQuestions(2, count: 20, maxMultiplier: 21);
    expect(set2_20.length, 20);
    final frequencyMap = <String, int>{};
    for (var q in set2_20) {
      frequencyMap[q.prompt] = (frequencyMap[q.prompt] ?? 0) + 1;
    }
    for (var entry in frequencyMap.entries) {
      expect(entry.value, equals(1), reason: '${entry.key} must appear at most 1 time, not ${entry.value} times');
    }
  });

  test('Consecutive drill sessions do NOT start with the same question', () {
    // Reset recent history for clean state
    DynamicQuestionEngine.clearRecentHistory();

    // Session 1 for Table 2
    final session1 = DynamicQuestionEngine.generateTableQuestions(2, count: 10, maxMultiplier: 12);
    final firstPrompt1 = session1.first.prompt;

    // Session 2 for Table 2 (must not start with firstPrompt1)
    final session2 = DynamicQuestionEngine.generateTableQuestions(2, count: 10, maxMultiplier: 12);
    final firstPrompt2 = session2.first.prompt;
    expect(firstPrompt2 != firstPrompt1, isTrue,
        reason: 'Session 2 must start with a different question than Session 1 (Session 1 started with $firstPrompt1, Session 2 with $firstPrompt2)');

    // Session 3 for Table 2 (must not start with firstPrompt2)
    final session3 = DynamicQuestionEngine.generateTableQuestions(2, count: 10, maxMultiplier: 12);
    final firstPrompt3 = session3.first.prompt;
    expect(firstPrompt3 != firstPrompt2, isTrue,
        reason: 'Session 3 must start with a different question than Session 2 (Session 2 started with $firstPrompt2, Session 3 with $firstPrompt3)');
  });

  test('Question count does NOT inflate multiplier limit: 30 questions on Table 11 with maxMultiplier 10 strictly stays <= 10', () {
    final questions = DynamicQuestionEngine.generateTableQuestions(11, count: 30, maxMultiplier: 10);
    expect(questions.length, 30);
    for (var q in questions) {
      expect(q.prompt.startsWith('11 × '), isTrue);
      final mult = int.parse(q.prompt.replaceAll(' = ?', '').split(' × ')[1]);
      expect(mult <= 10, isTrue, reason: 'Multiplier $mult exceeded chosen limit 10 despite count being 30');
      expect(mult >= 2, isTrue);
    }
  });
}
