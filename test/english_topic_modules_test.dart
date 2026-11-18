import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/models/english_models.dart';
import 'package:math_speed_practice/data/english_topics_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnglishTopicsRepository Tests (Topic-Wise Modules)', () {
    test('All English topic modules are loaded and have rules and questions', () {
      final modules = EnglishTopicsRepository.getModules();
      expect(modules.length, greaterThanOrEqualTo(8));

      for (final m in modules) {
        expect(m.id.isNotEmpty, isTrue);
        expect(m.title.isNotEmpty, isTrue);
        expect(m.subtitle.isNotEmpty, isTrue);
        expect(m.category.isNotEmpty, isTrue);
        expect(m.examTag.isNotEmpty, isTrue);
        expect(m.rules.isNotEmpty, isTrue, reason: '${m.title} must have rules to learn');
        expect(m.questions.isNotEmpty, isTrue, reason: '${m.title} must have questions to practice');

        for (final r in m.rules) {
          expect(r.ruleTitle.isNotEmpty, isTrue);
          expect(r.explanation.isNotEmpty, isTrue);
        }

        for (final q in m.questions) {
          expect(q.id.isNotEmpty, isTrue);
          expect(q.questionText.isNotEmpty, isTrue);
          expect(q.options.length, equals(4), reason: '${q.id} in ${m.title} must have 4 options');
          expect(q.correctIndex >= 0 && q.correctIndex < 4, isTrue);
        }
      }
    });

    test('Category filtering works correctly', () {
      final grammar = EnglishTopicsRepository.getModulesByCategory('Grammar');
      expect(grammar.length, greaterThanOrEqualTo(2));
      for (final m in grammar) {
        expect(m.category, equals('Grammar'));
      }

      final vocab = EnglishTopicsRepository.getModulesByCategory('Vocabulary');
      expect(vocab.length, greaterThanOrEqualTo(3));
      for (final m in vocab) {
        expect(m.category, equals('Vocabulary'));
      }

      final preps = EnglishTopicsRepository.getModulesByCategory('Fixed Prepositions');
      expect(preps.length, equals(1));
      expect(preps.first.questions.length, equals(100));

      final idioms = EnglishTopicsRepository.getModulesByCategory('Idioms');
      expect(idioms.length, equals(1));
      expect(idioms.first.questions.length, greaterThanOrEqualTo(20));

      final vaults = EnglishTopicsRepository.getModulesByCategory('Word Vaults');
      expect(vaults.length, equals(18));
      for (final m in vaults) {
        expect(m.wordTopic, isNotNull);
      }
    });
  });
}
