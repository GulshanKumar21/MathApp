import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../providers/app_state_provider.dart';
import '../../services/notification_service.dart';

class MathAlarmQuestionItem {
  final String prompt;
  final String correctAnswer;
  final List<String> twoOptions; // Exactly 2 options: Option A and Option B
  final bool isFromMistakes;

  MathAlarmQuestionItem({
    required this.prompt,
    required this.correctAnswer,
    required this.twoOptions,
    this.isFromMistakes = true,
  });
}

class MathAlarmRingingScreen extends StatefulWidget {
  const MathAlarmRingingScreen({super.key});

  @override
  State<MathAlarmRingingScreen> createState() => _MathAlarmRingingScreenState();
}

class _MathAlarmRingingScreenState extends State<MathAlarmRingingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late List<MathAlarmQuestionItem> _questions;
  int _currentIndex = 0;
  bool _isWrong = false;
  bool _isSuccessFlash = false;
  bool _isAlarmDismissed = false;

  // Sound silence state (alarm sounds silence immediately upon user answering/tapping)
  bool _isSoundSilenced = false;
  int _silenceRemainingSeconds = 35;
  Timer? _silenceCountdownTimer;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _alarmSirenLoopTimer;
  Timer? _vibrationPulseTimer;

  late AnimationController _bellPulseController;
  late Animation<double> _bellScaleAnimation;

  late AnimationController _radarController;
  late Animation<double> _radarAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bellPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _bellScaleAnimation = Tween<double>(begin: 0.90, end: 1.18).animate(
      CurvedAnimation(parent: _bellPulseController, curve: Curves.easeInOut),
    );

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _radarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );

    _prepareFiveQuestions();
    // START SIREN IMMEDIATELY: Alarm rings continuously until user taps to calculate or solves!
    _startAlarmSirenAndVibration();
  }

  void _prepareFiveQuestions() {
    final state = context.read<AppStateProvider>();
    final mistakes = List<MistakeModel>.from(state.mistakes);
    List<MathAlarmQuestionItem> list = [];

    // 1. Take up to 5 mistakes if user made mistakes in past practice
    int mistakeCountToTake = mistakes.length > 5 ? 5 : mistakes.length;
    for (int i = 0; i < mistakeCountToTake; i++) {
      final m = mistakes[i];
      final opts = _generateTwoOptions(m.prompt, m.correctAnswer);
      list.add(MathAlarmQuestionItem(
        prompt: m.prompt,
        correctAnswer: m.correctAnswer,
        twoOptions: opts,
        isFromMistakes: true,
      ));
    }

    // 2. If user had fewer than 5 mistakes, backfill so there are ALWAYS EXACTLY 5 questions
    if (list.length < 5) {
      final fallbackQuestions = [
        {'q': '17 × 7 = ?', 'a': '119'},
        {'q': '19 × 8 = ?', 'a': '152'},
        {'q': '23 × 6 = ?', 'a': '138'},
        {'q': '28 × 4 = ?', 'a': '112'},
        {'q': '16 × 9 = ?', 'a': '144'},
        {'q': '24² = ?', 'a': '576'},
        {'q': '18 × 8 = ?', 'a': '144'},
      ];

      for (var fb in fallbackQuestions) {
        if (list.length >= 5) break;
        if (!list.any((item) => item.prompt == fb['q'])) {
          final opts = _generateTwoOptions(fb['q']!, fb['a']!);
          list.add(MathAlarmQuestionItem(
            prompt: fb['q']!,
            correctAnswer: fb['a']!,
            twoOptions: opts,
            isFromMistakes: false,
          ));
        }
      }
    }

    _questions = list.take(5).toList();
  }

  // Generates EXACTLY 2 options: Correct Answer and 1 smart distractor
  List<String> _generateTwoOptions(String prompt, String correct) {
    int? correctNum = int.tryParse(correct);
    String distractor;

    if (correctNum != null) {
      // Smart distractor: ±10 or ±2
      int delta = (DateTime.now().millisecond % 2 == 0) ? 10 : -10;
      if (correctNum + delta <= 0) delta = 10;
      distractor = '${correctNum + delta}';
    } else {
      distractor = '${correct}_alt';
    }

    List<String> twoOpts = [correct, distractor]..shuffle();
    return twoOpts;
  }

  // Pure Dart Synthesized Dual-Tone High-Urgency Emergency Alarm Siren (WAV)
  Uint8List _generateAlarmSirenWav() {
    const int sampleRate = 22050;
    const double durationSeconds = 1.0;
    final int numSamples = (sampleRate * durationSeconds).round();
    final int dataSize = numSamples * 2;
    final int fileSize = 36 + dataSize;
    final ByteData byteData = ByteData(44 + dataSize);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, fileSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little); // PCM
    byteData.setUint16(22, 1, Endian.little); // Mono
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Dual-tone piercing digital alarm pulse (980 Hz and 1420 Hz alternating every 200ms)
      final double freq = ((t % 0.4) < 0.2) ? 980.0 : 1420.0;
      final double sine = sin(2 * pi * freq * t);
      final double square = sine >= 0 ? 0.85 : -0.85;
      final double mixed = (0.65 * square + 0.35 * sine);
      final int sample = (mixed * 29000).clamp(-32768, 32767).toInt();
      byteData.setInt16(offset, sample, Endian.little);
      offset += 2;
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _startAlarmSirenAndVibration() async {
    // 1. Play immediate native system alert chime
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    // 2. Start continuous loud synthesized dual-tone siren loop
    try {
      final wavBytes = _generateAlarmSirenWav();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(BytesSource(wavBytes));
    } catch (e) {
      debugPrint('Alarm audio siren note: $e');
    }

    // 3. Configure voice prompt accompaniment
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.2);
      await _flutterTts.setSpeechRate(0.5);
    } catch (_) {}

    _speakAlarmUrgentPrompt();

    // Voice announcement loop every 5.5s
    _alarmSirenLoopTimer = Timer.periodic(const Duration(milliseconds: 5500), (t) {
      if (_isAlarmDismissed || !mounted) {
        t.cancel();
        return;
      }
      _speakAlarmUrgentPrompt();
    });

    // Intense pulsating haptic buzzer every 750ms
    _vibrationPulseTimer = Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (_isAlarmDismissed || !mounted) {
        t.cancel();
        return;
      }
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    });
  }

  void _speakAlarmUrgentPrompt() {
    if (_isAlarmDismissed || !mounted) return;
    try {
      _flutterTts.speak('Wake up! Math Alarm is ringing! Solve your missed question to stop!');
    } catch (_) {}
  }

  void _stopAlarmSirenAndVibration() {
    _alarmSirenLoopTimer?.cancel();
    _vibrationPulseTimer?.cancel();
    try {
      _audioPlayer.stop();
    } catch (_) {}
    try {
      _flutterTts.stop();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isAlarmDismissed) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        // User attempted to leave app without completing all 5 questions!
        NotificationService().triggerMathAlarmNotification(
          label: '🚨 ALARM ACTIVE: Solve 5 Math Questions to Turn Off!',
        );
      } else if (state == AppLifecycleState.resumed) {
        // App returned - resume siren if not dismissed
        _restartSirenOnPenalty('🚨 ESCAPE BLOCKED! Siren resumed! Solve all 5 questions!');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _silenceCountdownTimer?.cancel();
    _stopAlarmSirenAndVibration();
    _audioPlayer.dispose();
    _bellPulseController.dispose();
    _radarController.dispose();
    if (!_isAlarmDismissed) {
      // User closed app/screen without solving all 5 questions -> Ring alarm again immediately!
      NotificationService().triggerMathAlarmNotification(
        label: '🚨 ALARM LOCKED: Solve all 5 questions to turn off!',
      );
    }
    super.dispose();
  }

  // Pauses sound when user clicks on question or wants to calculate peacefully
  void _silenceSoundForCalculation() {
    if (_isAlarmDismissed || _isSoundSilenced) return;
    _stopAlarmSirenAndVibration();
    setState(() {
      _isSoundSilenced = true;
      _isWrong = false;
      _silenceRemainingSeconds = 35;
    });

    _silenceCountdownTimer?.cancel();
    _silenceCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isAlarmDismissed || !_isSoundSilenced) {
        timer.cancel();
        return;
      }
      if (_silenceRemainingSeconds > 1) {
        setState(() {
          _silenceRemainingSeconds--;
        });
      } else {
        timer.cancel();
        // Time expired! Re-start siren to prevent falling back to sleep!
        _restartSirenOnPenalty('⚠️ TIME UP (35s)! Siren restarted! Wake up & solve the question!');
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.volume_off_rounded, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '🤫 Siren Silenced! Calculate peacefully. Solve to keep it off!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF0D9488),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Resumes siren sound immediately if user attempts wrong answer, closes early, or idles
  void _restartSirenOnPenalty(String alertMessage) {
    if (_isAlarmDismissed || !mounted) return;
    _silenceCountdownTimer?.cancel();
    setState(() {
      _isSoundSilenced = false;
      _isWrong = true;
      _silenceRemainingSeconds = 35;
    });
    _startAlarmSirenAndVibration();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alertMessage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(milliseconds: 2500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleOptionSelected(String selectedOption) {
    if (_isAlarmDismissed) return;
    final currentQ = _questions[_currentIndex];
    final isCorrect = selectedOption == currentQ.correctAnswer;
    final state = context.read<AppStateProvider>();

    if (isCorrect) {
      // Success feedback
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}

      // Resolve mistake in app state so notebook is cleared!
      state.checkAndResolveIfMistake(prompt: currentQ.prompt, answer: currentQ.correctAnswer);

      setState(() {
        _isWrong = false;
        _isSuccessFlash = true;
      });

      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _isSuccessFlash = false;
            // Keep sound silenced for the next question so user calculates peacefully!
            _isSoundSilenced = true;
            _silenceRemainingSeconds = 35;
          });
          // Restart 35s timer for next question
          _silenceCountdownTimer?.cancel();
          _silenceCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (!mounted || _isAlarmDismissed || !_isSoundSilenced) {
              timer.cancel();
              return;
            }
            if (_silenceRemainingSeconds > 1) {
              setState(() {
                _silenceRemainingSeconds--;
              });
            } else {
              timer.cancel();
              _restartSirenOnPenalty('⚠️ TIME UP (35s)! Siren restarted! Wake up & solve!');
            }
          });
        } else {
          // 🎉 ALL 5 SOLVED! DISMISS ALARM PERMANENTLY!
          _silenceCountdownTimer?.cancel();
          _stopAlarmSirenAndVibration();
          NotificationService().cancelMathWakeUpAlarm();
          NotificationService().cancelNotification(7777);
          setState(() {
            _isAlarmDismissed = true;
            _isSuccessFlash = false;
            _isSoundSilenced = true;
          });
        }
      });
    } else {
      // ❌ WRONG ANSWER: Resume alert sound if answered incorrectly or closed without solving
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
      _restartSirenOnPenalty('❌ WRONG ANSWER! Siren restarted full blast! Wake up & solve correctly!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final hourStr = hour.toString().padLeft(2, '0');
    final minStr = now.minute.toString().padLeft(2, '0');

    return PopScope(
      canPop: _isAlarmDismissed, // Strictly locked while alarm is ringing!
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // User attempted to exit/minimize without solving all 5 questions!
          _restartSirenOnPenalty('🔒 ALARM LOCKED! Siren restarted! Solve all 5 questions to turn off!');
        }
      },
      child: Scaffold(
        backgroundColor: _isWrong
            ? const Color(0xFF26050A)
            : (_isSuccessFlash ? const Color(0xFF042616) : const Color(0xFF0B0F19)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: _isAlarmDismissed
                ? _buildDismissedSuccessView()
                : _buildRingingAlarmView(hourStr, minStr, period),
          ),
        ),
      ),
    );
  }

  Widget _buildRingingAlarmView(String hourStr, String minStr, String period) {
    final currentQ = _questions[_currentIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
        // 1. Top Radar Audio Beacon & Live Digital Time
        Stack(
          alignment: Alignment.center,
          children: [
            // Animated pulsating radar wave ring
            AnimatedBuilder(
              animation: _radarAnimation,
              builder: (context, child) {
                return Container(
                  width: 90 + (_radarAnimation.value * 40),
                  height: 90 + (_radarAnimation.value * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: (1.0 - _radarAnimation.value) * 0.6),
                      width: 2.0,
                    ),
                  ),
                );
              },
            ),
            // Glowing Alarm Bell Core (Red when blaring, Green when peacefully calculating)
            ScaleTransition(
              scale: _bellScaleAnimation,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _isSoundSilenced
                        ? const [Color(0xFF10B981), Color(0xFF059669)]
                        : const [Color(0xFFEF4444), Color(0xFF991B1B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isSoundSilenced ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                          .withValues(alpha: 0.6),
                      blurRadius: 26,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _isSoundSilenced ? Icons.psychology_rounded : Icons.alarm_on_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Live Digital Clock
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$hourStr:$minStr',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Text(
                period,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFCA5A5),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _isSoundSilenced
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : const Color(0xFFDC2626).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isSoundSilenced
                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                  : const Color(0xFFDC2626).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isSoundSilenced ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: _isSoundSilenced ? const Color(0xFF34D399) : const Color(0xFFEF4444),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _isSoundSilenced
                    ? '🤫 SIREN SILENCED • TIME: ${_silenceRemainingSeconds}s'
                    : 'LOUD SIREN RINGING • SNOOZE LOCKED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _isSoundSilenced ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 2. 5-Step Segmented Glowing Progress Bar
        Row(
          children: List.generate(5, (index) {
            bool isDone = index < _currentIndex;
            bool isCurrent = index == _currentIndex;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF10B981)
                      : (isCurrent
                          ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDone
                        ? const Color(0xFF10B981)
                        : (isCurrent ? const Color(0xFFEF4444) : Colors.white12),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isCurrent ? Colors.white : Colors.white38,
                          ),
                        ),
                ),
              ),
            );
          }),
        ),

        const Spacer(),

        // 3. Question Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: currentQ.isFromMistakes
                ? const Color(0xFFEF4444).withValues(alpha: 0.18)
                : const Color(0xFF6366F1).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentQ.isFromMistakes ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentQ.isFromMistakes ? Icons.replay_circle_filled_rounded : Icons.flash_on_rounded,
                color: currentQ.isFromMistakes ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                currentQ.isFromMistakes
                    ? '⚠️ PAST MISSED QUESTION (${_currentIndex + 1} of 5)'
                    : '⚡ RAPID WAKE-UP CALCULATION (${_currentIndex + 1} of 5)',
                style: TextStyle(
                  color: currentQ.isFromMistakes ? const Color(0xFFFCA5A5) : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3.5 Prominent Silence Siren & Solve Button
        if (!_isSoundSilenced)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _silenceSoundForCalculation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2DD4BF), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_off_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    '🔇 TAP HERE OR QUESTION TO SILENCE SIREN & SOLVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.psychology_rounded, color: Color(0xFF34D399), size: 18),
                const SizedBox(width: 8),
                Text(
                  '🤫 Siren Paused for Math! (Resumes in ${_silenceRemainingSeconds}s if unsolved)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA7F3D0),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 14),

        // 4. Main Calculation Prompt Card (Tappable to Silence Siren & Calculate!)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              if (!_isSoundSilenced) {
                _silenceSoundForCalculation();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              decoration: BoxDecoration(
                color: const Color(0xFF131B2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isWrong
                      ? const Color(0xFFEF4444)
                      : (_isSuccessFlash
                          ? const Color(0xFF10B981)
                          : (_isSoundSilenced ? const Color(0xFF0D9488) : const Color(0xFF2E3D60))),
                  width: _isWrong || _isSuccessFlash || _isSoundSilenced ? 2.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isWrong
                        ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                        : (_isSoundSilenced
                            ? const Color(0xFF0D9488).withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.4)),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _isSoundSilenced ? 'CALCULATING MENTALLY (QUIET MODE)' : 'CALCULATE MENTALLY TO SILENCE ALARM',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                      color: _isSoundSilenced ? const Color(0xFF5EEAD4) : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    currentQ.prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isSoundSilenced)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, color: Color(0xFF2DD4BF), size: 14),
                          SizedBox(width: 6),
                          Text(
                            '👉 Tap this question to silence siren & calculate',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5EEAD4),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, color: Color(0xFF34D399), size: 14),
                          SizedBox(width: 6),
                          Text(
                            '✨ Siren Silenced! Pick Choice A or Choice B below',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6EE7B7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        const Spacer(),

        // 5. EXACTLY 2 CHOICES (Choice A vs Choice B) as requested!
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.touch_app_rounded, size: 14, color: Colors.white54),
            SizedBox(width: 6),
            Text(
              'Select correct answer below (2 Choices):',
              style: TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildAlarmOptionButton(
                option: currentQ.twoOptions[0],
                label: 'A',
                gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                accentColor: const Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildAlarmOptionButton(
                option: currentQ.twoOptions[1],
                label: 'B',
                gradientColors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                accentColor: const Color(0xFFA78BFA),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '🔒 Siren will NOT silence until all 5 questions are solved correctly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.white54),
          ),
        ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAlarmOptionButton({
    required String option,
    required String label,
    required List<Color> gradientColors,
    required Color accentColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _handleOptionSelected(option),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withValues(alpha: 0.25),
                gradientColors[1].withValues(alpha: 0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.65), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'CHOICE $label',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                option,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Grand Celebration View when all 5 questions are solved
  Widget _buildDismissedSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.45),
                  blurRadius: 30,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 58),
          ),
          const SizedBox(height: 28),
          const Text(
            '🎉 Alarm Dismissed!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            '5/5 Missed Calculations Solved Correctly!\nYour mind is calibrated and fully awake ⚡',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 38),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            icon: const Icon(Icons.dashboard_rounded),
            label: const Text(
              'Enter Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
