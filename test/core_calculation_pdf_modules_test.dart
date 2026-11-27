import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/data/content_repository.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';
import 'package:math_speed_practice/data/lcm_hcf_concept_data.dart';
import 'package:math_speed_practice/data/divisibility_rules_concept_data.dart';
import 'package:math_speed_practice/data/number_system_concept_data.dart';
import 'package:math_speed_practice/data/square_root_surds_concept_data.dart';
import 'package:math_speed_practice/data/trigonometry_solutions_data.dart';

void main() {
  group('Core Calculation PDF Modules Integration Tests', () {
    test('1. ContentRepository includes all 5 PDF modules in default topics', () {
      final topics = ContentRepository.getDefaultTopics();
      final types = topics.map((t) => t.type).toSet();

      expect(types.contains(TopicType.lcmHcf), isTrue, reason: 'LCM & HCF must be in default topics');
      expect(types.contains(TopicType.divisibility), isTrue, reason: 'Divisibility must be in default topics');
      expect(types.contains(TopicType.numberSystem), isTrue, reason: 'Number System must be in default topics');
      expect(types.contains(TopicType.squareRootSurds), isTrue, reason: 'Square Root & Surds must be in default topics');
      expect(types.contains(TopicType.trigonometry), isTrue, reason: 'Trigonometry must be in default topics');
    });

    test('2. DynamicQuestionEngine generates valid questions for LCM & HCF', () {
      final questions = DynamicQuestionEngine.generateUniqueQuestions(
        type: TopicType.lcmHcf,
        count: 15,
      );

      expect(questions.length, equals(15));
      for (final q in questions) {
        expect(q.prompt.isNotEmpty, isTrue);
        expect(q.correctAnswer.isNotEmpty, isTrue);
        expect(q.options.length, equals(4));
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });

    test('3. DynamicQuestionEngine generates valid questions for Divisibility Rules', () {
      final questions = DynamicQuestionEngine.generateUniqueQuestions(
        type: TopicType.divisibility,
        count: 15,
      );

      expect(questions.length, equals(15));
      for (final q in questions) {
        expect(q.prompt.isNotEmpty, isTrue);
        expect(q.correctAnswer.isNotEmpty, isTrue);
        expect(q.options.length, equals(4));
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });

    test('4. DynamicQuestionEngine generates valid questions for Number System', () {
      final questions = DynamicQuestionEngine.generateUniqueQuestions(
        type: TopicType.numberSystem,
        count: 15,
      );

      expect(questions.length, equals(15));
      for (final q in questions) {
        expect(q.prompt.isNotEmpty, isTrue);
        expect(q.correctAnswer.isNotEmpty, isTrue);
        expect(q.options.length, equals(4));
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });

    test('5. DynamicQuestionEngine generates valid questions for Square Root & Surds', () {
      final questions = DynamicQuestionEngine.generateUniqueQuestions(
        type: TopicType.squareRootSurds,
        count: 15,
      );

      expect(questions.length, equals(15));
      for (final q in questions) {
        expect(q.prompt.isNotEmpty, isTrue);
        expect(q.correctAnswer.isNotEmpty, isTrue);
        expect(q.options.length, equals(4));
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });

    test('6. DynamicQuestionEngine generates valid questions for Trigonometry', () {
      final questions = DynamicQuestionEngine.generateUniqueQuestions(
        type: TopicType.trigonometry,
        count: 15,
      );

      expect(questions.length, equals(15));
      for (final q in questions) {
        expect(q.prompt.isNotEmpty, isTrue);
        expect(q.correctAnswer.isNotEmpty, isTrue);
        expect(q.options.length, equals(4));
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });

    test('7. PDF Question Banks contain rich sets of authentic MCQs', () {
      expect(LcmHcfConceptData.questions.length, greaterThanOrEqualTo(20));
      expect(DivisibilityRulesConceptData.questions.length, greaterThanOrEqualTo(20));
      expect(NumberSystemConceptData.questions.length, greaterThanOrEqualTo(20));
      expect(SquareRootSurdsConceptData.questions.length, greaterThanOrEqualTo(20));
      expect(TrigonometrySolutionsData.questions.length, greaterThanOrEqualTo(20));
    });

    test('8. Core Concept Rules have valid structure and tags', () {
      for (final rule in LcmHcfConceptData.coreRules) {
        expect(rule['title'], isNotNull);
        expect(rule['formula'], isNotNull);
        expect(rule['hindi'], isNotNull);
        expect(rule['tag'], isNotNull);
      }

      for (final rule in DivisibilityRulesConceptData.coreRules) {
        expect(rule['title'], isNotNull);
        expect(rule['formula'], isNotNull);
        expect(rule['hindi'], isNotNull);
        expect(rule['tag'], isNotNull);
      }

      for (final rule in NumberSystemConceptData.coreRules) {
        expect(rule['title'], isNotNull);
        expect(rule['formula'], isNotNull);
        expect(rule['hindi'], isNotNull);
        expect(rule['tag'], isNotNull);
      }

      for (final rule in SquareRootSurdsConceptData.coreRules) {
        expect(rule['title'], isNotNull);
        expect(rule['formula'], isNotNull);
        expect(rule['hindi'], isNotNull);
        expect(rule['tag'], isNotNull);
      }

      for (final rule in TrigonometrySolutionsData.coreRules) {
        expect(rule['title'], isNotNull);
        expect(rule['formula'], isNotNull);
        expect(rule['hindi'], isNotNull);
        expect(rule['tag'], isNotNull);
      }
    });
  });
}
