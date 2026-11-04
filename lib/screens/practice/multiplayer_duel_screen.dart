import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../data/dynamic_question_engine.dart';
import '../../services/cloud_firestore_sync_service.dart';

class MultiplayerDuelScreen extends StatefulWidget {
  const MultiplayerDuelScreen({super.key});

  @override
  State<MultiplayerDuelScreen> createState() => _MultiplayerDuelScreenState();
}

class _MultiplayerDuelScreenState extends State<MultiplayerDuelScreen> {
  int _player1Score = 0;
  int _player2Score = 0;
  int _currentRound = 1;
  static const int totalRounds = 7;
  bool _isGameOver = false;

  late QuestionModel _currentQ;
  Timer? _roundTimer;
  int _secondsLeft = 5;

  @override
  void initState() {
    super.initState();
    _loadRound();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _loadRound() {
    _currentQ = DynamicQuestionEngine.generateUniqueQuestions(
      type: TopicType.tables,
      count: 1,
    ).first;
    _secondsLeft = 5;

    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        _nextRound();
      }
    });
  }

  void _handlePlayerTap({required int player, required String answer}) {
    if (_isGameOver) return;

    if (answer == _currentQ.correctAnswer) {
      if (player == 1) {
        _player1Score += 10;
      } else {
        _player2Score += 10;
      }
      _nextRound();
    }
  }

  void _nextRound() {
    _roundTimer?.cancel();
    if (_currentRound < totalRounds) {
      setState(() {
        _currentRound++;
        _loadRound();
      });
    } else {
      setState(() {
        _isGameOver = true;
      });
      // Sync match to Firebase Cloud
      String winner = _player1Score > _player2Score
          ? 'Player 1'
          : (_player2Score > _player1Score ? 'Player 2' : 'Draw');
      CloudFirestoreSyncService().recordDuelMatch(
        player1Name: 'Player 1',
        player1Score: _player1Score,
        player2Name: 'Player 2',
        player2Score: _player2Score,
        winner: winner,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ 1v1 Split-Screen Speed Duel'),
      ),
      body: SafeArea(
        child: _isGameOver ? _buildVictoryScreen() : _buildBattleArena(),
      ),
    );
  }

  Widget _buildBattleArena() {
    return Column(
      children: [
        // Player 2 Side (Inverted for face-to-face dual play on single phone)
        Expanded(
          child: RotatedBox(
            quarterTurns: 2,
            child: _playerSection(
              playerNum: 2,
              score: _player2Score,
              color: Colors.deepPurpleAccent,
            ),
          ),
        ),

        // Middle Arena Divider & Prompt
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppTheme.surfaceLight.withValues(alpha: 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Round $_currentRound/$totalRounds', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              Text(_currentQ.prompt, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.gold)),
              Text('⏱️ ${_secondsLeft}s', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            ],
          ),
        ),

        // Player 1 Side
        Expanded(
          child: _playerSection(
            playerNum: 1,
            score: _player1Score,
            color: AppTheme.primaryLight,
          ),
        ),
      ],
    );
  }

  Widget _playerSection({required int playerNum, required int score, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Player $playerNum', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              Text('$score pts', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
            ],
          ),
          const Spacer(),
          // 4 Options Grid for this player
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _currentQ.options.map((opt) {
              return SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surface,
                    foregroundColor: Colors.white,
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _handlePlayerTap(player: playerNum, answer: opt),
                  child: Text(opt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildVictoryScreen() {
    String winner = _player1Score > _player2Score
        ? 'Player 1 Wins! 🏆'
        : (_player2Score > _player1Score ? 'Player 2 Wins! 🏆' : 'It\'s a Draw! 🤝');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_rounded, size: 72, color: AppTheme.gold),
          const SizedBox(height: 16),
          Text(winner, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text('Player 1: $_player1Score pts  |  Player 2: $_player2Score pts', style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryLight, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
            onPressed: () {
              setState(() {
                _player1Score = 0;
                _player2Score = 0;
                _currentRound = 1;
                _isGameOver = false;
                _loadRound();
              });
            },
            child: const Text('Play Rematch', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
