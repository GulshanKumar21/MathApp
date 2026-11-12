import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/services/notification_service.dart';
import 'package:math_speed_practice/data/dynamic_question_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Table 16 calculation mistake reminder and mastery resolution loop', () async {
    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    // 1. Student attempts 16 × 3, enters wrong answer '50' (Correct is '48')
    final mistake = MistakeModel(
      id: 'table_16_3_err',
      prompt: '16 × 3 = ?',
      userAnswer: '50',
      correctAnswer: '48',
      topicId: 'tables',
      timestamp: DateTime.now(),
    );

    await provider.recordPracticeResult(
      PracticeResult(
        totalQuestions: 1,
        correctCount: 0,
        wrongCount: 1,
        accuracy: 0,
        avgTimeSeconds: 2.0,
        score: 0,
        topicId: 'tables',
        date: DateTime.now(),
      ),
      [mistake],
    );

    // Verify mistake is stored
    expect(provider.mistakes.length, 1);
    expect(provider.mistakes.first.prompt, '16 × 3 = ?');
    expect(provider.mistakes.first.userAnswer, '50');
    expect(provider.mistakes.first.correctAnswer, '48');

    // Notification ID check
    int notifId = NotificationService().getNotificationIdForPrompt('16 × 3 = ?');
    expect(notifId, isPositive);

    // Verify mistake alert asks question and does NOT leak the answer
    final recallAlert = provider.broadcasts.firstWhere((b) => b.id.contains('table_16_3_err'));
    expect(recallAlert.title, '🔁 Recall Check: What is 16 × 3?');
    expect(recallAlert.title.contains('48'), isFalse);

    // 2. Student now answers correctly ('48') for '16 × 3 = ?'
    bool resolved = await provider.checkAndResolveIfMistake(
      prompt: '16 × 3 = ?',
      answer: '48',
    );

    expect(resolved, isTrue);
    // Mistake list must now be empty
    expect(provider.mistakes.isEmpty, isTrue);

    // No unwanted 'Mastered' notification sent on correct answer (user requested silence)
    expect(provider.broadcasts.any((b) => b.title.contains('Mastered')), isFalse);
  });

  test('NotificationService: recall options generation and notification actions', () async {
    final notifService = NotificationService();

    // 1. Prompt cleaning
    expect(notifService.cleanPrompt('17 × 8 = ?'), '17 × 8');

    // 2. Realistic options generation
    final options = notifService.generateRecallOptions('136', '17 × 8');
    expect(options.length, 3);
    expect(options.contains('136'), isTrue);
    // Ensure all 3 options are unique
    expect(options.toSet().length, 3);
    // Verify ALL options have the EXACT SAME unit digit (136 % 10 = 6)
    for (var opt in options) {
      expect(int.parse(opt) % 10, equals(6));
    }

    // 3. Notification action resolution callback
    String? resolvedPrompt;
    String? resolvedAns;
    notifService.onMistakeResolved = (prompt, answer) {
      resolvedPrompt = prompt;
      resolvedAns = answer;
    };

    // User chooses correct answer via action button 'ans|17 × 8|136|136'
    await notifService.handleNotificationAnswerAction('ans|17 × 8|136|136', 101);
    expect(resolvedPrompt, '17 × 8');
    expect(resolvedAns, '136');
  });

  test('1-Hour Recall - Wrong attempt triggers notification and records mistake, Correct attempt silences notifications', () async {
    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    // 1. Student answers wrong during 1-hour recall (enters '95', correct is '98')
    await provider.recordWrongRecallAttempt(
      prompt: '14 × 7',
      wrongAnswer: '95',
      correctAnswer: '98',
    );

    expect(provider.mistakes.length, 1);
    expect(provider.mistakes.first.prompt, '14 × 7');
    expect(provider.mistakes.first.userAnswer, '95');
    expect(provider.mistakes.first.correctAnswer, '98');

    // 2. Student now answers correctly ('98')
    final resolved = await provider.checkAndResolveIfMistake(
      prompt: '14 × 7',
      answer: '98',
    );

    expect(resolved, isTrue);
    expect(provider.mistakes.isEmpty, isTrue);
  });

  test('All math question options strictly share identical unit digit to prevent guessing (for multi-digit answers >= 10)', () {
    final topics = [
      TopicType.addition,
      TopicType.subtraction,
      TopicType.tables,
      TopicType.hardMultiplier,
      TopicType.squares,
      TopicType.cubes,
      TopicType.division,
      TopicType.triples,
    ];

    for (var topic in topics) {
      final questions = DynamicQuestionEngine.generateUniqueQuestions(type: topic, count: 10);
      for (var q in questions) {
        expect(q.options.length, 4, reason: 'Topic ${topic.name} must have 4 options');
        expect(q.options.contains(q.correctAnswer), isTrue, reason: 'Options must contain correct answer');
        
        final correctInt = int.tryParse(q.correctAnswer);
        if (correctInt != null) {
          if (correctInt.abs() >= 100) {
            final expectedUnit = (correctInt % 10).abs();
            for (var opt in q.options) {
              final optInt = int.tryParse(opt);
              expect(optInt, isNotNull, reason: 'Option $opt should be an integer for topic ${topic.name}');
              expect(
                (optInt! % 10).abs(),
                equals(expectedUnit),
                reason: 'Option $opt must have unit digit $expectedUnit (same as $correctInt) in topic ${topic.name}',
              );
            }
          } else {
            for (var opt in q.options) {
              final optInt = int.tryParse(opt);
              expect(optInt, isNotNull, reason: 'Option $opt should be an integer for topic ${topic.name}');
              expect(
                (optInt! - correctInt).abs(),
                lessThanOrEqualTo(correctInt.abs() <= 25 ? 6 : 25),
                reason: 'Option $opt must stay tight/close to $correctInt in topic ${topic.name}',
              );
            }
          }
        }
      }
    }
  });

  test('Single-digit options do NOT share unit digit and provide realistic nearby options (e.g. 2+2=4 -> 4, 5, 8, 1 and NOT 4, 14, 24, 34)', () {
    // 1. Single digit addition from DynamicQuestionEngine
    final questions = DynamicQuestionEngine.generateDigitSpecificQuestions(
      type: TopicType.addition,
      digits: 1,
      count: 20,
    );
    for (var q in questions) {
      final ans = int.parse(q.correctAnswer);
      if (ans < 10) {
        expect(q.options.contains('$ans'), isTrue);
        // Verify options do NOT all share the exact same unit digit
        final sameUnitCount = q.options.where((opt) => (int.parse(opt) % 10) == (ans % 10)).length;
        expect(sameUnitCount < 4, isTrue, reason: 'Single digit $ans should not have all options sharing unit digit');
        // Verify options are reasonable nearby numbers (not huge like +10, +20, +30)
        for (var opt in q.options) {
          final optNum = int.parse(opt);
          expect(optNum, greaterThanOrEqualTo(0));
          expect((optNum - ans).abs(), lessThanOrEqualTo(10), reason: 'Distractors for single digit $ans should be nearby');
        }
      }
    }

    // 2. NotificationService generateRecallOptions for single-digit 4 (from 2+2=4)
    final notifOpts = NotificationService().generateRecallOptions('4', '2 + 2');
    expect(notifOpts.length, 3);
    expect(notifOpts.contains('4'), isTrue);
    expect(notifOpts.contains('14'), isFalse, reason: 'Option for single digit 4 should not be 14');
    expect(notifOpts.contains('24'), isFalse, reason: 'Option for single digit 4 should not be 24');

    // 3. Multi-digit numbers (>= 10) still strictly share identical unit digit
    final multiOpts = NotificationService().generateRecallOptions('75', '15 × 5');
    expect(multiOpts.length, 3);
    for (var opt in multiOpts) {
      expect(int.parse(opt) % 10, equals(5));
    }
  });

  test('Addition mistake correctly queues and triggers notification for the EXACT addition question (NOT multiplication)', () async {
    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    // Student attempts addition drill, misses '47 + 38 = ?' (Answer: 85, Entered: 75)
    final addMistake = MistakeModel(
      id: 'add_47_38',
      prompt: '47 + 38 = ?',
      userAnswer: '75',
      correctAnswer: '85',
      topicId: 'addition',
      timestamp: DateTime.now(),
    );

    await provider.recordPracticeResult(
      PracticeResult(
        totalQuestions: 1,
        correctCount: 0,
        wrongCount: 1,
        accuracy: 0,
        avgTimeSeconds: 3.0,
        score: 0,
        topicId: 'addition',
        date: DateTime.now(),
      ),
      [addMistake],
    );

    // Verify addition mistake is recorded
    expect(provider.mistakes.first.prompt, '47 + 38 = ?');
    expect(provider.mistakes.first.correctAnswer, '85');
    expect(provider.mistakes.first.topicId, 'addition');

    // Verify the in-app alert prompt is addition, NOT multiplication
    final notifAlert = provider.broadcasts.firstWhere((b) => b.id.contains('add_47_38'));
    expect(notifAlert.title, contains('47 + 38'));
    expect(notifAlert.title.contains('×'), isFalse);

    // Verify recall options generated for this addition question all end in unit digit 5
    final opts = NotificationService().generateRecallOptions('85', '47 + 38');
    expect(opts.length, 3);
    expect(opts.contains('85'), isTrue);
    for (var opt in opts) {
      expect(int.parse(opt) % 10, equals(5));
    }
  });

  test('Multi-mistake session queues line-wise (Option A: 1-by-1): only 1 active at a time, advances on correct answer', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final notifService = NotificationService();

    // 1. Student makes 3 mistakes in a single quiz session
    await notifService.scheduleCalculationMistakeReminder(
      prompt: '13 × 7 = ?',
      correctAnswer: '91',
      userAnswer: '81',
    );
    await notifService.scheduleCalculationMistakeReminder(
      prompt: '14 × 6 = ?',
      correctAnswer: '84',
      userAnswer: '94',
    );
    await notifService.scheduleCalculationMistakeReminder(
      prompt: '17 × 4 = ?',
      correctAnswer: '68',
      userAnswer: '78',
    );

    // Queue must contain all 3 mistakes in order
    final queue = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queue.length, 3);
    expect(queue[0], '13 × 7|91');
    expect(queue[1], '14 × 6|84');
    expect(queue[2], '17 × 4|68');

    // ONLY the first question is actively displayed (Option A focused learning)
    expect(prefs.getString('currently_displayed_recall_formula'), '13 × 7');

    // 2. Student answers 1st question correctly via notification action
    await notifService.handleNotificationAnswerAction('ans|13 × 7|91|91', 101);

    // 1st question is cleared, 2nd question is now promoted as active!
    final queueAfter1 = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queueAfter1.length, 2);
    expect(queueAfter1[0], '14 × 6|84');
    expect(prefs.getString('currently_displayed_recall_formula'), '14 × 6');

    // 3. Student answers 2nd question correctly
    await notifService.handleNotificationAnswerAction('ans|14 × 6|84|84', 102);

    // 2nd question cleared, 3rd question promoted as active!
    final queueAfter2 = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queueAfter2.length, 1);
    expect(queueAfter2[0], '17 × 4|68');
    expect(prefs.getString('currently_displayed_recall_formula'), '17 × 4');

    // 4. Student answers 3rd question correctly
    await notifService.handleNotificationAnswerAction('ans|17 × 4|68|68', 103);

    // Queue is empty, active formula is removed, silence maintained!
    final queueAfter3 = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queueAfter3.isEmpty, isTrue);
    expect(prefs.getString('currently_displayed_recall_formula'), isNull);
  });

  test('Session mistakes enqueue after quiz ends: 1-by-1 serial delivery, 2nd blocked until 1st solved', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final notifService = NotificationService();

    // Student makes 2 mistakes during quiz session
    final mistakes = [
      MistakeModel(
        id: 'm1',
        prompt: '15 × 5 = ?',
        userAnswer: '65',
        correctAnswer: '75',
        topicId: 'tables',
        timestamp: DateTime.now(),
      ),
      MistakeModel(
        id: 'm2',
        prompt: '18 × 4 = ?',
        userAnswer: '82',
        correctAnswer: '72',
        topicId: 'tables',
        timestamp: DateTime.now(),
      ),
    ];

    // After quiz completes / user navigates home, mistakes are enqueued
    await notifService.enqueueSessionMistakesAndTrigger(mistakes);

    // Queue contains both questions
    final queue = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queue.length, 2);
    expect(queue[0], '15 × 5|75');
    expect(queue[1], '18 × 4|72');

    // ONLY the 1st question is active
    expect(prefs.getString('currently_displayed_recall_formula'), '15 × 5');

    // Student taps WRONG answer ('65') on 1st notification
    await notifService.handleNotificationAnswerAction('ans|15 × 5|65|75', 1001);

    // 1st question is STILL active, 2nd question STILL NOT promoted!
    expect(prefs.getString('currently_displayed_recall_formula'), '15 × 5');
    final queueStill2 = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queueStill2.length, 2);

    // Student now taps CORRECT answer ('75') on 1st notification
    await notifService.handleNotificationAnswerAction('ans|15 × 5|75|75', 1001);

    // 1st cleared, 2nd question immediately promoted!
    final queueAfter1 = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queueAfter1.length, 1);
    expect(queueAfter1[0], '18 × 4|72');
    expect(prefs.getString('currently_displayed_recall_formula'), '18 × 4');

    // Student now answers 2nd question correctly ('72')
    await notifService.handleNotificationAnswerAction('ans|18 × 4|72|72', 1002);

    // All cleared, full silence
    final queueFinal = prefs.getStringList('pending_recall_queue') ?? [];
    expect(queueFinal.isEmpty, isTrue);
    expect(prefs.getString('currently_displayed_recall_formula'), isNull);
  });

  test('Notification Snooze: Student snoozes question to tomorrow, suppressed today', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final notifService = NotificationService();

    final formula = '19 × 6';
    final answer = '114';

    // 1. Initially formula is not snoozed
    expect(notifService.isFormulaSnoozed(formula, prefs), isFalse);

    // 2. Student clicks Snooze action on notification
    await notifService.handleSnoozeAction('snooze|$formula|$answer', 70196);

    // 3. Formula is now marked as snoozed until tomorrow
    expect(notifService.isFormulaSnoozed(formula, prefs), isTrue);
    final snoozedStr = prefs.getString('snoozed_until_$formula');
    expect(snoozedStr, isNotNull);
    final snoozedDate = DateTime.parse(snoozedStr!);
    expect(snoozedDate.isAfter(DateTime.now()), isTrue);

    // 4. MistakeModel supports Spaced Repetition stage and snoozedUntil
    final model = MistakeModel(
      id: 'm_19_6',
      prompt: '$formula = ?',
      userAnswer: '104',
      correctAnswer: answer,
      topicId: 'tables',
      timestamp: DateTime.now(),
      repetitionStage: 1,
      snoozedUntil: snoozedDate,
    );

    final map = model.toMap();
    expect(map['repetitionStage'], 1);
    expect(map['snoozedUntil'], snoozedStr);

    final restored = MistakeModel.fromMap(map);
    expect(restored.repetitionStage, 1);
    expect(restored.snoozedUntil, isNotNull);

    // 5. Correct answer clears snooze
    await notifService.handleNotificationAnswerAction('ans|$formula|$answer|$answer', 70196);
    expect(prefs.getString('snoozed_until_$formula'), isNull);
  });

  test('Daily Notification Frequency Capping: User sets limit (e.g. 10), suppresses alerts beyond limit', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final notifService = NotificationService();

    // 1. Default limit is 10
    expect(await notifService.getDailyNotificationLimit(), equals(10));
    expect(await notifService.getDailyNotificationCountToday(), equals(0));
    expect(await notifService.hasReachedDailyNotificationLimit(), isFalse);

    // 2. User sets limit to 2
    await notifService.setDailyNotificationLimit(2);
    expect(await notifService.getDailyNotificationLimit(), equals(2));

    // 3. First notification sent
    await notifService.incrementDailyNotificationCount();
    expect(await notifService.getDailyNotificationCountToday(), equals(1));
    expect(await notifService.hasReachedDailyNotificationLimit(), isFalse);

    // 4. Second notification sent -> reaches limit
    await notifService.incrementDailyNotificationCount();
    expect(await notifService.getDailyNotificationCountToday(), equals(2));
    expect(await notifService.hasReachedDailyNotificationLimit(), isTrue);

    // 5. Third notification attempt is suppressed because limit (2) is reached
    expect(await notifService.hasReachedDailyNotificationLimit(), isTrue);

    // 6. User sets limit to 0 (Unlimited) -> hasReachedDailyNotificationLimit returns false
    await notifService.setDailyNotificationLimit(0);
    expect(await notifService.hasReachedDailyNotificationLimit(), isFalse);

    // 7. Reset daily count resets today's count back to 0
    await notifService.resetDailyNotificationCountForTesting();
    expect(await notifService.getDailyNotificationCountToday(), equals(0));
  });

  test('Performance-based Spaced Repetition (1 Hr ➔ +3 Hrs ➔ +3 Hrs): Zero immediate disturbance & Stage Progression', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final notifService = NotificationService();

    final formula = '23 × 7';
    final answer = '161';

    // 1. Student makes error on 23 × 7 -> Recorded with postImmediately: false
    await notifService.scheduleCalculationMistakeReminder(
      prompt: formula,
      correctAnswer: answer,
      userAnswer: '151',
      postImmediately: false,
    );

    // Verify Stage 1 is initialized and due time is ~60 minutes in future
    expect(prefs.getInt('repetition_stage_$formula'), equals(1));
    expect(await notifService.getRepetitionStage(formula), equals(1));

    final dueStr = prefs.getString('recall_due_at_$formula');
    expect(dueStr, isNotNull);
    final dueTime = DateTime.parse(dueStr!);
    expect(dueTime.isAfter(DateTime.now()), isTrue);

    // Crucial: Zero immediate disturbance! Is due for recall right now? FALSE!
    expect(notifService.isCalculationDueForRecall(formula, prefs), isFalse);

    // 2. Stage 1 (1-Hour Recall): Student answers CORRECTLY!
    // System must NOT discard the question yet — must advance to Stage 2 (+3-Hour Recall)!
    await notifService.handleNotificationAnswerAction('ans|$formula|$answer|$answer', 12345);

    expect(prefs.getInt('repetition_stage_$formula'), equals(2));
    expect(await notifService.getRepetitionStage(formula), equals(2));
    expect(await notifService.isCalculationSolved(formula), isFalse); // NOT marked solved yet!

    final stage2DueStr = prefs.getString('recall_due_at_$formula');
    expect(stage2DueStr, isNotNull);
    final stage2Due = DateTime.parse(stage2DueStr!);
    // Due ~3 hours later
    expect(stage2Due.difference(DateTime.now()).inMinutes, greaterThanOrEqualTo(170));
    expect(notifService.isCalculationDueForRecall(formula, prefs), isFalse);

    // 3. Stage 2 (+3-Hour Recall): Student answers CORRECTLY again!
    // Advances to Stage 3 (+3-Hour Final Retention Check)
    await notifService.handleNotificationAnswerAction('ans|$formula|$answer|$answer', 12345);

    expect(prefs.getInt('repetition_stage_$formula'), equals(3));
    expect(await notifService.getRepetitionStage(formula), equals(3));
    expect(await notifService.isCalculationSolved(formula), isFalse); // Still in active recall!

    final stage3DueStr = prefs.getString('recall_due_at_$formula');
    expect(stage3DueStr, isNotNull);
    final stage3Due = DateTime.parse(stage3DueStr!);
    // Due ~3 hours later
    expect(stage3Due.difference(DateTime.now()).inMinutes, greaterThanOrEqualTo(170));
    expect(notifService.isCalculationDueForRecall(formula, prefs), isFalse);

    // 4. Stage 3 (Final Retention Check): Student answers CORRECTLY!
    // 3 spaced intervals completed -> MASTERED (Stage 4)!
    bool mistakeResolvedCalled = false;
    notifService.onMistakeResolved = (p, a) {
      mistakeResolvedCalled = true;
    };

    await notifService.handleNotificationAnswerAction('ans|$formula|$answer|$answer', 12345);

    expect(prefs.getInt('repetition_stage_$formula'), equals(4));
    expect(await notifService.isCalculationSolved(formula), isTrue); // Now MASTERED!
    expect(mistakeResolvedCalled, isTrue);
    expect(prefs.getString('recall_due_at_$formula'), isNull);
  });

  test('Spaced Repetition Penalty: Wrong answer at any stage resets back to Stage 1 (1-Hour Recall)', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final notifService = NotificationService();

    final formula = '27 × 4';
    final answer = '108';

    // Start at Stage 2
    await prefs.setInt('repetition_stage_$formula', 2);

    // User answers WRONG ('104')
    await notifService.handleNotificationAnswerAction('ans|$formula|104|$answer', 99999);

    // Must be penalized back to Stage 1!
    expect(prefs.getInt('repetition_stage_$formula'), equals(1));
    final resetDueStr = prefs.getString('recall_due_at_$formula');
    expect(resetDueStr, isNotNull);
    final resetDue = DateTime.parse(resetDueStr!);
    // Due in ~60 minutes
    expect(resetDue.difference(DateTime.now()).inMinutes, greaterThanOrEqualTo(55));
    expect(notifService.isCalculationDueForRecall(formula, prefs), isFalse);
  });

  test('Starred Table Spaced Repetition: Zero immediate notification, 1-Hour initial drill, +3-Hour intervals', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final notifService = NotificationService();

    await notifService.scheduleStarredTableNotification(19);

    expect(prefs.getInt('active_starred_table_number'), equals(19));
    final formula = '19 × 2';
    expect(prefs.getInt('repetition_stage_$formula'), equals(1));

    // Zero immediate alert! Due time is ~60 minutes in future
    final dueStr = prefs.getString('recall_due_at_$formula');
    expect(dueStr, isNotNull);
    final due = DateTime.parse(dueStr!);
    expect(due.isAfter(DateTime.now()), isTrue);
    expect(notifService.isCalculationDueForRecall(formula, prefs), isFalse);

    // Answer correct on Starred Table Stage 1 -> Advances to Stage 2 (+3-Hour Recall)
    await notifService.handleNotificationAnswerAction('ans|$formula|38|38', 55000);
    expect(prefs.getInt('repetition_stage_$formula'), equals(2));
    final stage2Due = DateTime.parse(prefs.getString('recall_due_at_$formula')!);
    expect(stage2Due.difference(DateTime.now()).inMinutes, greaterThanOrEqualTo(170));
  });

  test('Four notification options: Exactly 3 answer-related choices with identical unit digit + 4th Snooze option', () {
    final notifService = NotificationService();

    final options = notifService.generateRecallOptions('136', '17 × 8');
    expect(options.length, 3);
    expect(options.contains('136'), isTrue);

    // All 3 options share the same unit digit (6)
    for (var opt in options) {
      expect(int.parse(opt) % 10, equals(6));
    }
  });
}


