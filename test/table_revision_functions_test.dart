import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';
import 'package:math_speed_practice/services/voice_reciter_helper.dart';

void main() {
  group('Table Hub Functions & Question Generation Tests', () {
    test('generateTableQuestions produces strictly 10 unique multipliers for 1-10 table drill', () {
      final questions = DynamicQuestionEngine.generateTableQuestions(
        17,
        count: 10,
        maxMultiplier: 10,
      );

      expect(questions.length, equals(10));
      final multipliers = questions.map((q) {
        // "17 × 4 = ?" -> parse 4
        final parts = q.prompt.split(' ');
        return int.parse(parts[2]);
      }).toSet();

      // All 10 multipliers from 1 to 10 should be present
      expect(multipliers.length, equals(10), reason: 'Multipliers 1 to 10 must have zero duplicates in a 10 Q drill');
      for (int m = 1; m <= 10; m++) {
        expect(multipliers.contains(m), isTrue, reason: 'Multiplier $m should be present');
      }

      for (final q in questions) {
        final parts = q.prompt.split(' ');
        final t = int.parse(parts[0]);
        final m = int.parse(parts[2]);
        expect(t, equals(17));
        expect(int.parse(q.correctAnswer), equals(17 * m));
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.options.length, equals(4));
      }
    });

    test('generateTableQuestions with 1-12 multipliers produces valid unique questions', () {
      final questions = DynamicQuestionEngine.generateTableQuestions(
        13,
        count: 10,
        maxMultiplier: 12,
      );

      expect(questions.length, equals(10));
      final prompts = questions.map((q) => q.prompt).toSet();
      expect(prompts.length, equals(10), reason: '10 questions from 12 multipliers should be 100% unique');

      for (final q in questions) {
        final parts = q.prompt.split(' ');
        final m = int.parse(parts[2]);
        expect(m, inInclusiveRange(1, 12));
      }
    });

    test('generateTableQuestions with 1-20 multipliers produces 20 unique questions', () {
      final questions = DynamicQuestionEngine.generateTableQuestions(
        19,
        count: 20,
        maxMultiplier: 20,
      );

      expect(questions.length, equals(20));
      final multipliers = questions.map((q) => int.parse(q.prompt.split(' ')[2])).toSet();
      expect(multipliers.length, equals(20), reason: 'All 20 multipliers must be unique in 20 Q drill');
    });

    test('generateTableRangeQuestions generates correct questions across ranges', () {
      // 1-10 Basics (Tables 2 to 10)
      final basics = DynamicQuestionEngine.generateTableRangeQuestions(
        startTable: 2,
        endTable: 10,
        count: 10,
        maxMultiplier: 10,
      );
      expect(basics.length, equals(10));
      for (final q in basics) {
        final parts = q.prompt.split(' ');
        final t = int.parse(parts[0]);
        final m = int.parse(parts[2]);
        expect(t, inInclusiveRange(2, 10));
        expect(m, inInclusiveRange(1, 10));
        expect(int.parse(q.correctAnswer), equals(t * m));
      }

      // 11-20 Core
      final core = DynamicQuestionEngine.generateTableRangeQuestions(
        startTable: 11,
        endTable: 20,
        count: 15,
        maxMultiplier: 12,
      );
      expect(core.length, equals(15));
      for (final q in core) {
        final parts = q.prompt.split(' ');
        final t = int.parse(parts[0]);
        final m = int.parse(parts[2]);
        expect(t, inInclusiveRange(11, 20));
        expect(m, inInclusiveRange(1, 12));
      }

      // 21-50 Pro
      final pro = DynamicQuestionEngine.generateTableRangeQuestions(
        startTable: 21,
        endTable: 50,
        count: 10,
        maxMultiplier: 10,
      );
      expect(pro.length, equals(10));
      for (final q in pro) {
        final parts = q.prompt.split(' ');
        final t = int.parse(parts[0]);
        final m = int.parse(parts[2]);
        expect(t, inInclusiveRange(21, 50));
        expect(m, inInclusiveRange(1, 10));
      }
    });

    test('generateMultiTableQuestions supports user-picked mix tables', () {
      final mix = DynamicQuestionEngine.generateMultiTableQuestions(
        tables: [14, 16, 18],
        count: 12,
        maxMultiplier: 12,
      );

      expect(mix.length, equals(12));
      for (final q in mix) {
        final parts = q.prompt.split(' ');
        final t = int.parse(parts[0]);
        final m = int.parse(parts[2]);
        expect([14, 16, 18].contains(t), isTrue);
        expect(m, inInclusiveRange(1, 12));
        expect(int.parse(q.correctAnswer), equals(t * m));
      }
    });

    test('generateMultiTableQuestions handles empty list fallback safely', () {
      final fallback = DynamicQuestionEngine.generateMultiTableQuestions(
        tables: [],
        count: 10,
        maxMultiplier: 10,
      );
      expect(fallback.length, equals(10));
    });

    test('VoiceReciterHelper formats speech text correctly across all recital styles', () {
      // School chanting
      expect(
        VoiceReciterHelper.getTableSpeechText(table: 17, mult: 2, style: 'school'),
        equals('17 two za 34'),
      );
      expect(
        VoiceReciterHelper.getTableSpeechText(table: 17, mult: 1, style: 'school'),
        equals('17 one za 17'),
      );

      // Times style
      expect(
        VoiceReciterHelper.getTableSpeechText(table: 17, mult: 5, style: 'times'),
        equals('17 times 5 is 85'),
      );

      // Vedic fast drill
      expect(
        VoiceReciterHelper.getTableSpeechText(table: 12, mult: 8, style: 'vedic'),
        equals('12 into 8, 96'),
      );

      // Quiz mode (Question vs Answer)
      expect(
        VoiceReciterHelper.getTableSpeechText(table: 19, mult: 4, style: 'quiz', isQuestionOnly: true),
        equals('19 times 4 is'),
      );
      expect(
        VoiceReciterHelper.getTableSpeechText(table: 19, mult: 4, style: 'quiz', isQuestionOnly: false),
        equals('76'),
      );
    });
  });
}
