import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/models/english_models.dart';
import 'package:math_speed_practice/data/english_content_bank.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnglishContentBank Content Integrity Tests', () {
    test('100 Fixed Prepositions (Q151 to Q250) are loaded and valid', () {
      final list = EnglishContentBank.fixedPrepositions;
      expect(list.length, equals(100));

      for (int i = 0; i < list.length; i++) {
        final q = list[i];
        expect(q.number, equals(151 + i));
        expect(q.sentence.isNotEmpty, isTrue, reason: 'Q${q.number} must have a non-empty sentence');
        expect(q.options.length, equals(4), reason: 'Q${q.number} must have 4 options');
        expect(q.correctIndex >= 0 && q.correctIndex < 4, isTrue,
            reason: 'Q${q.number} must have valid correctIndex');
        expect(q.correctOptionText.isNotEmpty, isTrue);
        expect(q.rule.isNotEmpty, isTrue, reason: 'Q${q.number} must have an explanation rule');
      }
    });

    test('10 Thematic Idioms Groups have English themes, idioms, and meanings', () {
      final groups = EnglishContentBank.thematicIdioms;
      expect(groups.length, greaterThanOrEqualTo(10));

      for (final g in groups) {
        expect(g.theme.isNotEmpty, isTrue);
        expect(g.displayTheme.isNotEmpty, isTrue);
        expect(g.idioms.isNotEmpty, isTrue, reason: '${g.theme} must have idioms');
        for (final item in g.idioms) {
          expect(item.idiom.isNotEmpty, isTrue);
          expect(item.meaning.isNotEmpty, isTrue);
        }
      }
    });

    test('18 Vocabulary Topics are loaded with pure English headwords, synonyms, antonyms, and MCQs', () {
      final topics = EnglishContentBank.topics;
      expect(topics.length, equals(18));

      for (final t in topics) {
        expect(t.word.isNotEmpty, isTrue);
        expect(t.partOfSpeech.isNotEmpty, isTrue);
        expect(t.displayTitle, equals('${t.word} (${t.partOfSpeech})'));
        expect(t.synonyms.length, greaterThanOrEqualTo(10), reason: '${t.word} should have 10+ synonyms');
        expect(t.antonyms.length, greaterThanOrEqualTo(10), reason: '${t.word} should have 10+ antonyms');
        expect(t.exercises.length, greaterThanOrEqualTo(4), reason: '${t.word} should have 4+ MCQs');
        for (final ex in t.exercises) {
          expect(ex.id.isNotEmpty, isTrue);
          expect(ex.questionText.isNotEmpty, isTrue);
          expect(ex.options.length, equals(4));
          expect(ex.correctIndex >= 0 && ex.correctIndex < 4, isTrue);
          expect(ex.explanation.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('English Model Serialization Tests', () {
    test('EnglishMistake toMap and fromMap roundtrip', () {
      final mistake = EnglishMistake(
        id: 'test_1',
        questionText: 'Select the synonym of Assuage:',
        options: ['Relieve', 'Provoke', 'Agitate', 'Worsen'],
        correctIndex: 0,
        selectedIndex: 1,
        explanation: 'Assuage means to soothe.',
        timestamp: DateTime(2026, 10, 23, 12, 0),
      );

      final map = mistake.toMap();
      final revived = EnglishMistake.fromMap(map);

      expect(revived.id, equals(mistake.id));
      expect(revived.questionText, equals(mistake.questionText));
      expect(revived.options, equals(mistake.options));
      expect(revived.correctIndex, equals(mistake.correctIndex));
      expect(revived.selectedIndex, equals(mistake.selectedIndex));
      expect(revived.explanation, equals(mistake.explanation));
      expect(revived.timestamp, equals(mistake.timestamp));
    });

    test('EnglishExerciseQuestion toMap and fromMap roundtrip', () {
      const q = EnglishExerciseQuestion(
        id: 'ex_1',
        questionText: 'Select the antonym of Slipshod:',
        options: ['Careless', 'Careful', 'Rash', 'Hasty'],
        correctIndex: 1,
        type: 'antonym',
        explanation: 'Slipshod means careless; opposite is Careful.',
      );

      final map = q.toMap();
      final revived = EnglishExerciseQuestion.fromMap(map);

      expect(revived.id, equals(q.id));
      expect(revived.questionText, equals(q.questionText));
      expect(revived.options, equals(q.options));
      expect(revived.correctIndex, equals(q.correctIndex));
      expect(revived.type, equals(q.type));
      expect(revived.explanation, equals(q.explanation));
    });
  });

  group('AppStateProvider English State Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Recording English answers updates accuracy and saves mistakes', () async {
      final state = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(state.englishQuestionsAttempted, equals(0));
      expect(state.englishQuestionsCorrect, equals(0));
      expect(state.englishAccuracy, equals(0.0));
      expect(state.englishMistakes.isEmpty, isTrue);

      // Record correct answer
      await state.recordEnglishAnswer(
        isCorrect: true,
        questionId: 'q1',
        questionText: 'Q1 Text',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        selectedIndex: 0,
        explanation: 'Correct explanation',
      );

      expect(state.englishQuestionsAttempted, equals(1));
      expect(state.englishQuestionsCorrect, equals(1));
      expect(state.englishAccuracy, equals(100.0));
      expect(state.englishMistakes.isEmpty, isTrue);

      // Record wrong answer
      await state.recordEnglishAnswer(
        isCorrect: false,
        questionId: 'q2',
        questionText: 'Q2 Text',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 2,
        selectedIndex: 1,
        explanation: 'Wrong attempt explanation',
      );

      expect(state.englishQuestionsAttempted, equals(2));
      expect(state.englishQuestionsCorrect, equals(1));
      expect(state.englishAccuracy, equals(50.0));
      expect(state.englishMistakes.length, equals(1));
      expect(state.englishMistakes.first.id, equals('q2'));

      // Remove mistake
      await state.removeEnglishMistake('q2');
      expect(state.englishMistakes.isEmpty, isTrue);

      // Bookmarks
      expect(state.isEnglishWordBookmarked('SLIPSHOD'), isFalse);
      await state.toggleEnglishBookmark('slipshod');
      expect(state.isEnglishWordBookmarked('SLIPSHOD'), isTrue);
      await state.toggleEnglishBookmark('SLIPSHOD');
      expect(state.isEnglishWordBookmarked('SLIPSHOD'), isFalse);

      // Completed topics
      expect(state.completedEnglishTopics.contains(1), isFalse);
      await state.markEnglishTopicCompleted(1);
      expect(state.completedEnglishTopics.contains(1), isTrue);
    });
  });
}
