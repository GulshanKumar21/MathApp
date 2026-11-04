import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real Cloud Leaderboard Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('LeaderboardEntryModel serialization and isCurrentUser logic', () {
      final entry = LeaderboardEntryModel(
        uid: 'user_123',
        name: 'Gulshan Kumar',
        score: 1540,
        accuracy: 96.5,
        streak: 5,
        targetExam: 'SSC CGL',
        questionsSolved: 120,
        updatedAt: DateTime.now(),
        isCurrentUser: true,
      );

      final map = entry.toMap();
      expect(map['score'], 1540);
      expect(map['accuracy'], 96.5);
      expect(map['name'], 'Gulshan Kumar');

      final fromMap = LeaderboardEntryModel.fromMap(map, currentUid: 'user_123');
      expect(fromMap.isCurrentUser, true);
      expect(fromMap.score, 1540);
    });

    test('AppStateProvider fetchRealLeaderboard populates and sorts real rankings', () async {
      final state = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await state.setLoggedInUser(name: 'Aspirant Rahul', email: 'rahul@test.com', uid: 'test_user_99');

      await state.fetchRealLeaderboard();

      expect(state.leaderboard, isNotEmpty);
      // Verify current user exists in leaderboard
      final me = state.leaderboard.firstWhere((e) => e.isCurrentUser);
      expect(me.name, 'Aspirant Rahul');
      expect(me.uid, 'test_user_99');

      // Verify strictly sorted in descending score order
      for (int i = 0; i < state.leaderboard.length - 1; i++) {
        expect(state.leaderboard[i].score >= state.leaderboard[i + 1].score, true);
      }
    });

    test('Solving practice quiz immediately updates live user score and leaderboard rank', () async {
      final state = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await state.setLoggedInUser(name: 'Top Scorer', email: 'top@test.com', uid: 'usr_top');
      await state.fetchRealLeaderboard();

      int initialScore = state.liveUserScore;

      // Complete a 20 question practice quiz with 20 correct answers
      final result = PracticeResult(
        totalQuestions: 20,
        correctCount: 20,
        wrongCount: 0,
        accuracy: 100.0,
        avgTimeSeconds: 2.1,
        score: 200,
        topicId: 'tables',
        date: DateTime.now(),
      );

      await state.recordPracticeResult(result, []);

      // Score should increase dynamically (20 questions * 10 = 200 pts bonus)
      expect(state.liveUserScore > initialScore, true);

      // Verify leaderboard entry updated live
      final myEntry = state.leaderboard.firstWhere((e) => e.isCurrentUser);
      expect(myEntry.score, state.liveUserScore);
      expect(myEntry.accuracy, 100.0);
    });
  });
}
