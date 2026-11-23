import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../theme/app_theme.dart';
import '../data/content_repository.dart';
import '../data/dynamic_question_engine.dart';
import '../models/math_models.dart';
import '../screens/revision/revision_screen.dart';
import '../screens/practice/learn_mode_screen.dart';
import '../screens/practice/daily_challenge_screen.dart';
import '../screens/practice/practice_quiz_screen.dart';
import '../screens/notifications/notifications_inbox_screen.dart';
import '../screens/alarm/math_alarm_ringing_screen.dart';
import '../screens/practice/recall_solve_screen.dart';
import '../data/concept_formula_repository.dart';
import '../screens/concepts/concept_detail_screen.dart';

typedef MistakeResolvedCallback = void Function(String prompt, String answer);

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = NotificationService();
  await service.initBackgroundOnly();
  debugPrint('Background notification response: actionId=${notificationResponse.actionId}, payload=${notificationResponse.payload}, type=${notificationResponse.notificationResponseType}');

  if (notificationResponse.actionId != null &&
      notificationResponse.actionId!.startsWith('type_answer|')) {
    await service.handleTypedAnswerAction(
      notificationResponse.actionId!,
      notificationResponse.id,
      notificationResponse.input,
    );
  } else if (notificationResponse.actionId != null &&
      notificationResponse.actionId!.startsWith('ans|')) {
    await service.handleNotificationAnswerAction(
      notificationResponse.actionId!,
      notificationResponse.id,
    );
  } else if (notificationResponse.actionId != null &&
      notificationResponse.actionId!.startsWith('snooze|')) {
    await service.handleSnoozeAction(
      notificationResponse.actionId!,
      notificationResponse.id,
    );
  } else if (notificationResponse.notificationResponseType == NotificationResponseType.notificationDismissed) {
    await service.handleNotificationDismissed(notificationResponse);
  }
}

class NotificationService {
  /// Plays custom notification chime for in-app / foreground heads-up alerts (capped at 4s)
  Future<void> playNotificationSound() async {
    try {
      final player = AudioPlayer();
      bool isDisposed = false;
      // ReleaseMode.stop ensures sound plays once and does NOT loop
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource('sounds/custom_notification_sound.mp3'));

      final capTimer = Timer(const Duration(seconds: 4), () async {
        if (isDisposed) return;
        isDisposed = true;
        try {
          await player.stop();
          await player.dispose();
        } catch (_) {}
      });

      player.onPlayerComplete.listen((_) {
        capTimer.cancel();
        if (isDisposed) return;
        isDisposed = true;
        try {
          player.dispose();
        } catch (_) {}
      });
    } catch (_) {}
  }

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _isAppInForeground = true;
  void setAppInForeground(bool inForeground) {
    _isAppInForeground = inForeground;
  }
  final Set<int> _programmaticallyDismissedNotifIds = {};

  /// Lightweight background initialization avoiding foreground permissions/dialogs
  Future<void> initBackgroundOnly() async {
    if (_isInitialized) return;
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          if (response.actionId != null && response.actionId!.startsWith('type_answer|')) {
            await handleTypedAnswerAction(response.actionId!, response.id, response.input);
          } else if (response.actionId != null && response.actionId!.startsWith('open_solve|')) {
            handleNotificationPayload(response.actionId!);
          } else if (response.actionId != null && response.actionId!.startsWith('ans|')) {
            await handleNotificationAnswerAction(response.actionId!, response.id);
          } else if (response.actionId != null && response.actionId!.startsWith('snooze|')) {
            await handleSnoozeAction(response.actionId!, response.id);
          } else if (response.notificationResponseType == NotificationResponseType.notificationDismissed) {
            await handleNotificationDismissed(response);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Register recall channel in background isolate so show() never fails
      const AndroidNotificationChannel recallChannel = AndroidNotificationChannel(
        'prepvanta_animated_recall_v4',
        'PrepVanta Spaced Repetition Recall',
        description: 'Spaced repetition calculation alerts for mistake revision (1hr, 3hr)',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('custom_notification_sound'),
        enableVibration: true,
        showBadge: true,
      );
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(recallChannel);

      const AndroidNotificationChannel silentFeedbackChannel = AndroidNotificationChannel(
        'prepvanta_recall_feedback_v1',
        'PrepVanta Recall Visual Updates',
        description: 'Silent status updates when answering or restoring recall notifications',
        importance: Importance.high,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );
      await androidPlugin?.createNotificationChannel(silentFeedbackChannel);

      _ensureTimezonesInitialized();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Background notification init note: $e');
    }
  }

  // Callback to inform AppStateProvider when a mistake is solved via notification action
  void _ensureTimezonesInitialized() {
    try {
      tz.initializeTimeZones();
      final offset = DateTime.now().timeZoneOffset;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offset) {
          tz.setLocalLocation(loc);
          break;
        }
      }
    } catch (_) {
      try {
        tz.initializeTimeZones();
      } catch (_) {}
    }
  }

  MistakeResolvedCallback? onMistakeResolved;

  // Active timers for repeated reminders per calculation prompt
  final Map<int, Timer> _activeReminderTimers = {};

  // Timers for tomorrow's scheduled study plan
  Timer? _studyPlanTimer;
  Timer? _studyPlanRecurringTimer;
  Timer? _streakTimer;
  Timer? _recommendationTimer;
  Timer? _hourlyTimer;
  Timer? _starredTablePeriodicTimer;
  Timer? _mathAlarmTimer;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          debugPrint('Notification clicked: payload=${response.payload}, action=${response.actionId}, type=${response.notificationResponseType}');
          if (response.actionId != null && response.actionId!.startsWith('type_answer|')) {
            await handleTypedAnswerAction(response.actionId!, response.id, response.input);
          } else if (response.actionId != null && response.actionId!.startsWith('open_solve|')) {
            handleNotificationPayload(response.actionId!);
          } else if (response.actionId != null && response.actionId!.startsWith('ans|')) {
            await handleNotificationAnswerAction(response.actionId!, response.id);
          } else if (response.actionId != null && response.actionId!.startsWith('snooze|')) {
            await handleSnoozeAction(response.actionId!, response.id);
          } else if (response.notificationResponseType == NotificationResponseType.notificationDismissed) {
            await handleNotificationDismissed(response);
          } else if (response.payload != null && response.payload!.isNotEmpty) {
            handleNotificationPayload(response.payload!);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Initialize timezone database and detect device local offset for native exact alarm scheduling
      _ensureTimezonesInitialized();

      // Explicitly register high-urgency channels on Android
      try {
        const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
          'math_alarm_channel_v5',
          'Math Wake-Up Alarm (Emergency Siren)',
          description: 'High priority loud alarm siren ringing until math questions are answered',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_siren'),
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(alarmChannel);

        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();



        const AndroidNotificationChannel recallChannel = AndroidNotificationChannel(
          'prepvanta_animated_recall_v4',
          'PrepVanta Spaced Repetition Recall',
          description: 'Spaced repetition calculation alerts for mistake revision (1hr, 3hr)',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_notification_sound'),
          enableVibration: true,
          showBadge: true,
        );
        await androidImpl?.createNotificationChannel(recallChannel);

        const AndroidNotificationChannel silentFeedbackChannel = AndroidNotificationChannel(
          'prepvanta_recall_feedback_v1',
          'PrepVanta Recall Visual Updates',
          description: 'Silent status updates when answering or restoring recall notifications',
          importance: Importance.high,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        );
        await androidImpl?.createNotificationChannel(silentFeedbackChannel);

        const AndroidNotificationChannel starredChannel = AndroidNotificationChannel(
          'math_starred_tables_v2',
          'Starred Table Revision Alerts',
          description: 'Direct calculation questions for bookmarked & starred tables',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_notification_sound'),
          enableVibration: true,
          showBadge: true,
        );
        await androidImpl?.createNotificationChannel(starredChannel);

        const AndroidNotificationChannel hourlyChannel = AndroidNotificationChannel(
          'math_hourly_channel_v3',
          'Hourly Mental Speed Challenge',
          description: 'Regular 1-hour calculation drill notifications to keep your mind sharp',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_notification_sound'),
          enableVibration: true,
          showBadge: true,
        );
        await androidImpl?.createNotificationChannel(hourlyChannel);

        const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
          'math_speed_channel_v2',
          'PrepVanta',
          description: 'Calculation drills, daily streaks, and mistake revision alerts',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_notification_sound'),
          enableVibration: true,
          showBadge: true,
        );
        await androidImpl?.createNotificationChannel(generalChannel);
      } catch (e) {
        debugPrint('Create notification channel note: $e');
      }

      // Request runtime notification permission on Android 13+
      try {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } catch (e) {
        debugPrint('Notification permission request note: $e');
      }

      // Request exact alarms permission on Android 12+ (SCHEDULE_EXACT_ALARM)
      try {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('Exact alarms permission note: $e');
      }

      // Handle cold start app launch via notification click
      try {
        final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
        if (launchDetails != null &&
            launchDetails.didNotificationLaunchApp &&
            launchDetails.notificationResponse != null) {
          final res = launchDetails.notificationResponse!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (res.actionId != null && res.actionId!.startsWith('ans|')) {
              handleNotificationAnswerAction(res.actionId!, res.id);
            } else if (res.payload != null && res.payload!.isNotEmpty) {
              handleNotificationPayload(res.payload!);
            }
          });
        }
      } catch (e) {
        debugPrint('Launch details check notice: $e');
      }

      // Purge any legacy hardcoded notifications & sanitize corrupted entries in queue
      try {
        await cancelNotification(1111);
        await cancelNotification(1112);
        await cancelNotification(1114);
        await cancelNotification(6600);
        await cancelNotification(7777);

        final prefs = await SharedPreferences.getInstance();
        // Sanitize pending_recall_queue & unnotified_mistakes_list against corrupted 'Ã·' or bad '0' answers
        for (final key in ['pending_recall_queue', 'unnotified_mistakes_list']) {
          final list = prefs.getStringList(key);
          if (list != null && list.isNotEmpty) {
            final cleaned = <String>[];
            for (final entry in list) {
              final parts = entry.split('|');
              if (parts.length < 2) continue;
              final f = cleanPrompt(parts[0].replaceAll('Ã·', '÷'));
              final a = parts[1].trim();
              if (_isValidMathFormula(f) &&
                  !_isAdditionOrSubtraction(f) &&
                  _isCleanComputedAnswer(a) &&
                  !(a == '0' && !f.contains('0'))) {
                cleaned.add('$f|$a');
              }
            }
            await prefs.setStringList(key, cleaned);
          }
        }
      } catch (_) {}

      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification init warning: $e');
    }
  }


  void handleNotificationPayload(String payload) {
    debugPrint('Handling notification payload: $payload');
    final nav = navigatorKey.currentState;
    if (nav == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationPayload(payload);
      });
      return;
    }

    if (payload.startsWith('open_solve|')) {
      final parts = payload.split('|');
      final formula = parts.length > 1 ? parts[1] : '';
      final correctAnswer = parts.length > 2 ? parts[2] : '';
      if (formula.isNotEmpty) {
        nav.push(MaterialPageRoute(
          builder: (_) => RecallSolveScreen(formula: formula, correctAnswer: correctAnswer),
        ));
      }
      return;
    } else if (payload.startsWith('persistent|')) {
      final parts = payload.split('|');
      final formula = parts.length > 2 ? parts[2] : '';
      final correctAnswer = parts.length > 3 ? parts[3] : '';
      if (formula.isNotEmpty) {
        nav.push(MaterialPageRoute(
          builder: (_) => RecallSolveScreen(formula: formula, correctAnswer: correctAnswer),
        ));
      }
      return;
    } else if (payload.startsWith('mistake:') ||
        payload.startsWith('recall_') ||
        payload.startsWith('hourly_challenge:')) {
      String formula = '';
      if (payload.startsWith('mistake:')) formula = payload.replaceFirst('mistake:', '');
      if (payload.startsWith('recall_')) formula = payload.replaceFirst('recall_', '');
      final clean = cleanPrompt(formula);
      if (clean.isNotEmpty) {
        getCorrectAnswerForFormula(clean).then((ans) {
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            Navigator.of(ctx).push(MaterialPageRoute(
              builder: (_) => RecallSolveScreen(formula: clean, correctAnswer: ans),
            ));
          }
        });
      }
      return;
    } else if (payload == 'hourly_challenge') {
      nav.push(MaterialPageRoute(builder: (_) => const DailyChallengeScreen()));
    } else if (payload.startsWith('next_drill:') ||
        payload.startsWith('flashcard:') ||
        payload == 'mistake_revision') {
      nav.push(MaterialPageRoute(builder: (_) => const RevisionScreen()));
    } else if (payload.startsWith('browse_continue:')) {
      final topicId = payload.replaceFirst('browse_continue:', '');
      final topics = ContentRepository.getDefaultTopics();
      final topic = topics.firstWhere(
        (t) => t.id == topicId || topicId.contains(t.id),
        orElse: () => topics.first,
      );
      nav.push(MaterialPageRoute(builder: (_) => LearnModeScreen(topic: topic)));
    } else if (payload == 'streak_reminder' || payload == 'streak_drill') {
      nav.push(MaterialPageRoute(builder: (_) => const DailyChallengeScreen()));
    } else if (payload == 'admin_broadcast') {
      nav.push(MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()));
    } else if (payload.startsWith('study_plan:')) {
      final topicId = payload.replaceFirst('study_plan:', '');
      if (topicId.startsWith('table_')) {
        int tableNum = int.tryParse(topicId.replaceFirst('table_', '')) ?? 12;
        final questions = DynamicQuestionEngine.generateTableQuestions(tableNum, count: 10);
        nav.push(
          MaterialPageRoute(
            builder: (_) => PracticeQuizScreen(
              topic: TopicModel(
                id: topicId,
                title: 'Table of $tableNum Target Drill',
                subtitle: 'Scheduled Target Challenge',
                type: TopicType.tables,
                iconName: 'grid_view_rounded',
              ),
              customQuestions: questions,
              isTimed: true,
              questionCount: 10,
            ),
          ),
        );
      } else if (topicId.startsWith('mistake')) {
        nav.push(MaterialPageRoute(builder: (_) => const RevisionScreen()));
      } else if (ConceptFormulaRepository.formulas.any((f) => f.id == topicId)) {
        final formula = ConceptFormulaRepository.formulas.firstWhere((f) => f.id == topicId);
        nav.push(MaterialPageRoute(builder: (_) => ConceptDetailScreen(formula: formula)));
      } else {
        final topics = ContentRepository.getDefaultTopics();
        final topic = topics.firstWhere(
          (t) => t.id == topicId || topicId.contains(t.id),
          orElse: () => topics.first,
        );
        nav.push(MaterialPageRoute(builder: (_) => LearnModeScreen(topic: topic)));
      }
    } else if (payload.startsWith('recommendation:')) {
      nav.push(MaterialPageRoute(builder: (_) => const DailyChallengeScreen()));
    } else if (payload == 'math_alarm_ringing' || payload.startsWith('math_alarm')) {
      nav.push(MaterialPageRoute(builder: (_) => const MathAlarmRingingScreen()));
    }
  }

  /// Returns true if the calculation is an addition or subtraction problem
  /// User directive: No notifications for addition or subtraction mistakes
  bool _isAdditionOrSubtraction(String formula, [String topicId = '']) {
    final tLower = topicId.toLowerCase();
    if (tLower.contains('addition') || tLower.contains('subtraction')) return true;
    final clean = cleanPrompt(formula);
    if (clean.contains('+') || clean.contains('-') || clean.contains('−')) return true;
    return false;
  }

  /// Returns true if ans is already a valid numeric, percentage, or fraction result
  bool _isCleanComputedAnswer(String ans) {
    final a = ans.trim();
    if (a.isEmpty) return false;
    if (RegExp(r'^-?\d+(\.\d+)?%?$').hasMatch(a)) return true;
    if (RegExp(r'^\d+/\d+$').hasMatch(a)) return true;
    return false;
  }

  /// Returns true if the formula is a valid math expression (not English text/empty)
  bool _isValidMathFormula(String formula) {
    if (formula.trim().isEmpty) return false;
    final clean = cleanPrompt(formula);
    if (clean.trim().isEmpty) return false;
    if (!RegExp(r'\d').hasMatch(clean)) return false;
    // Allow "25% of 400" specifically, otherwise block multi-letter English text
    final withoutOf = clean.replaceAll(RegExp(r'\s+of\s+', caseSensitive: false), ' ');
    if (RegExp(r'[a-zA-Z]{2,}').hasMatch(withoutOf)) return false;
    return RegExp(r'^[\d\s×\*\+\-−÷/\^²³√∛\.%()ofOF]+$').hasMatch(clean);
  }

  // Helper to normalize calculation prompts (e.g., "⏰ 1-Hour Recall Alert: 23 × 7 = ?" -> "23 × 7")
  String cleanPrompt(String prompt) {
    String p = prompt
        .replaceAll('Ã·', '÷')
        .replaceAll('Ã—', '×')
        .replaceAll('⏰', '')
        .replaceAll(RegExp(r'Table\s*\d+:?', caseSensitive: false), '')
        .replaceAll(RegExp(r'1-Hour\s*Recall\s*Alert:?', caseSensitive: false), '')
        .replaceAll(RegExp(r'Recall\s*Alert:?', caseSensitive: false), '')
        .replaceAll(RegExp(r'Alert:?', caseSensitive: false), '')
        .replaceAll(RegExp(r'Recall:?', caseSensitive: false), '')
        .replaceAll(RegExp(r'Check:?', caseSensitive: false), '')
        .replaceAll(' = ?', '')
        .replaceAll('?', '')
        .replaceAll('=', '')
        .trim();
    // Only strip a notification header before ':' when the trailing segment actually holds content
    if (p.contains(':')) {
      final trailing = p.split(':').last.trim();
      if (trailing.isNotEmpty && RegExp(r'\d').hasMatch(trailing)) {
        p = trailing;
      } else {
        p = p.replaceAll(RegExp(r':+\s*$'), '').trim();
      }
    }
    p = p.replaceAll(RegExp(r'\s*[\*xX\u00D7\u2715\u2716]\s*'), ' × ');
    p = p.replaceAll(RegExp(r'\s*\+\s*'), ' + ');
    p = p.replaceAll(RegExp(r'\s*[\-−\u2212]\s*'), ' - ');
    p = p.replaceAll(RegExp(r'\s*[÷/\u00F7]\s*'), ' ÷ ');
    p = p.replaceAll(RegExp(r'\s+'), ' ').trim();
    return p;
  }

  int getNotificationIdForPrompt(String prompt) {
    return (cleanPrompt(prompt).hashCode.abs() % 90000) + 1000;
  }

  // Cancel a specific notification & its repeating timer
  Future<void> cancelNotification(int id) async {
    try {
      _activeReminderTimers[id]?.cancel();
      _activeReminderTimers.remove(id);
      if (!_isInitialized) return;
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Could not cancel notification $id: $e');
    }
  }

  // Cancel all notifications & clear timers
  Future<void> cancelAllNotifications() async {
    try {
      for (var t in _activeReminderTimers.values) {
        t.cancel();
      }
      _activeReminderTimers.clear();
      if (!_isInitialized) return;
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Could not cancel all notifications: $e');
    }
  }

  // Display an immediate notification (only when app is in background, unless bypassed)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool bypassForegroundGuard = false,
  }) async {
    if (_isAppInForeground && !bypassForegroundGuard) {
      debugPrint('🛡️ App in foreground: suppressing immediate notification "$title"');
      return;
    }
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'math_speed_channel_v2',
        'PrepVanta',
        channelDescription: 'Calculation drills, daily streaks, and mistake revision alerts',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
        channelShowBadge: true,
        showWhen: true,
        colorized: false,
        color: const Color(0xFF22C55E),
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: '<font color="#22C55E"><b>$title</b></font>',
          htmlFormatContentTitle: true,
        ),
      );

      final NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Could not trigger notification: $e');
    }
  }

  // Generate 3 realistic multiple choice options for quick notification actions
  // ALL OPTIONS MUST SHARE THE EXACT SAME UNIT DIGIT!
  // NO HARDCODED DUMMY PERCENTAGES!
  List<String> generateRecallOptions(String correct, String formula) {
    String cleanCorrect = correct.trim();
    String cleanForm = cleanPrompt(formula);
    int? correctNum = int.tryParse(cleanCorrect);

    // If answer is not a pure integer or if it contains operators (i.e. is a formula like "23 × 7"):
    if (!_isCleanComputedAnswer(cleanCorrect)) {
      // First try to calculate from formula
      String calculated = _computeFallbackAnswer(cleanForm.isNotEmpty ? cleanForm : cleanCorrect);
      correctNum = int.tryParse(calculated);
      if (correctNum != null && correctNum != 0) {
        cleanCorrect = calculated;
      } else {
        // Try calculating directly from cleanCorrect
        calculated = _computeFallbackAnswer(cleanCorrect);
        correctNum = int.tryParse(calculated);
        if (correctNum != null && correctNum != 0) {
          cleanCorrect = calculated;
        }
      }
    }

    Set<String> opts = {cleanCorrect};

    if (correctNum != null && correctNum != 0) {
      if (correctNum.abs() < 10) {
        // Single-digit answer (< 10): Provide realistic nearby numbers (e.g. 4 -> 5, 8, 1, 3)
        final pool = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5]..shuffle();
        for (int d in pool) {
          if (opts.length >= 3) break;
          int cand = correctNum + d;
          if (cand >= 0 && cand != correctNum) {
            opts.add('$cand');
          }
        }
        int step = 1;
        while (opts.length < 3) {
          if (correctNum + step >= 0) opts.add('${correctNum + step}');
          if (opts.length < 3 && correctNum - step >= 0) opts.add('${correctNum - step}');
          step++;
        }
      } else {
        // Multi-digit (>= 10): Strictly preserve identical unit digit!
        final int unit = (correctNum % 10).abs();
        final pool = [10, -10, 20, -20, 30, -30, 40, -40, 50, -50]..shuffle();

        for (int d in pool) {
          if (opts.length >= 3) break;
          int cand = correctNum + d;
          if (cand > 0 && cand != correctNum && (cand % 10 == unit)) {
            opts.add('$cand');
          }
        }

        int step = 1;
        while (opts.length < 3) {
          int plus = correctNum + (10 * step);
          if (plus > 0 && plus % 10 == unit) opts.add('$plus');
          if (opts.length < 3) {
            int minus = correctNum - (10 * step);
            if (minus > 0 && minus % 10 == unit) opts.add('$minus');
          }
          step++;
        }
      }
    } else if (cleanCorrect.endsWith('%')) {
      final cleanVal = cleanCorrect.replaceAll('%', '').trim();
      final double? pct = double.tryParse(cleanVal);
      if (pct != null) {
        if (cleanVal.contains('.')) {
          opts.add('${(pct + 2.5).toStringAsFixed(2)}%');
          opts.add('${(pct - 1.5).abs().toStringAsFixed(2)}%');
        } else {
          final int pInt = pct.round();
          opts.add('${pInt + 5}%');
          opts.add('${pInt > 5 ? pInt - 5 : pInt + 10}%');
        }
      }
    } else if (double.tryParse(cleanCorrect) != null) {
      final double decVal = double.parse(cleanCorrect);
      final int decPlaces = cleanCorrect.contains('.') ? cleanCorrect.split('.')[1].length : 1;
      opts.add((decVal + 2.5).toStringAsFixed(decPlaces));
      opts.add((decVal > 2.5 ? decVal - 2.5 : decVal + 5.0).toStringAsFixed(decPlaces));
    } else {
      // Dynamic integer distractors derived mathematically from question
      int fallbackVal = int.tryParse(cleanCorrect) ?? 0;
      if (fallbackVal == 0) {
        fallbackVal = int.tryParse(_computeFallbackAnswer(cleanForm)) ?? 0;
      }
      if (fallbackVal > 0) {
        opts.add('${fallbackVal + 10}');
        opts.add('${fallbackVal > 10 ? fallbackVal - 10 : fallbackVal + 20}');
      }
    }

    final list = opts.take(3).toList()..shuffle();
    return list;
  }

  // Display persistent, non-dismissible ongoing notification with 3 action answer buttons
  // USER CANNOT SWIPE IT AWAY (ongoing: true, autoCancel: false, FLAG_NO_CLEAR, FLAG_ONGOING_EVENT) until answered correctly!
  Future<void> showPersistentRecallNotification({
    required int id,
    required String prompt,
    required String correctAnswer,
    String? wrongAttempt,
    String? summaryText,
    bool isSilent = false,
    bool bypassForegroundGuard = false,
  }) async {
    // Note: Mistake recall alerts are critical spaced learning reviews and must NEVER be suppressed by daily frequency limits!
    // 🛡️ User directive: Never post notification alerts while app is in foreground (unless reacting to notification action or explicit test)
    // Exception: isSilent=true is a swipe-dismiss re-post — MUST bypass foreground guard so sticky notification returns
    if (_isAppInForeground && wrongAttempt == null && !isSilent && !bypassForegroundGuard) {
      debugPrint('🛡️ App is in foreground: suppressing persistent notification for "$prompt"');
      return;
    }
    String formula = cleanPrompt(prompt);
    // 🛡️ Filter out any malformed / non-math questions
    if (!_isValidMathFormula(formula)) {
      debugPrint('⚠️ Refusing persistent notification for invalid math: "$formula" (original: "$prompt")');
      return;
    }
    // 🛡️ User directive: No notifications for addition or subtraction
    if (_isAdditionOrSubtraction(formula)) {
      debugPrint('🛡️ Refusing notification for addition/subtraction: "$formula"');
      return;
    }
    await _markRecallUnsolvedInPrefs(formula);
    String resolvedAnswer = correctAnswer.trim();
    if (!_isCleanComputedAnswer(resolvedAnswer)) {
      resolvedAnswer = _computeFallbackAnswer(formula.isNotEmpty ? formula : resolvedAnswer);
    }
    if (!_isCleanComputedAnswer(resolvedAnswer)) {
      debugPrint('⚠️ Refusing recall notification because answer could not be verified: "$formula" -> "$resolvedAnswer"');
      return;
    }
    final options = generateRecallOptions(resolvedAnswer, formula);

    // Persist as actively pending recall so any swipe/dismissal instantly re-posts it
    await _markRecallActiveInPrefs(formula, resolvedAnswer, id);

    String? queueSummary;
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('pending_recall_queue') ?? [];
      if (queue.length > 1) {
        final cleanF = cleanPrompt(formula);
        final pos = queue.indexWhere((item) => cleanPrompt(item.split('|').first) == cleanF);
        final displayPos = pos >= 0 ? pos + 1 : 1;
        queueSummary = 'Mistake $displayPos of ${queue.length} in queue';
      }
    } catch (_) {}

    final String title = wrongAttempt != null
        ? '❌ Wrong! $formula = ?'
        : '$formula = ?';

    await _postRecallNotificationInternal(
      id: id,
      title: title,
      formula: formula,
      options: options,
      correctAnswer: resolvedAnswer,
      wrongAttempt: wrongAttempt,
      summaryText: summaryText ?? queueSummary,
      isSilent: isSilent,
    );

    // NOTE: No short watchdog timer here — ongoing: true + FLAG_NO_CLEAR prevent swipe-away natively.
    // A 1-hour re-post timer is set separately by scheduleCalculationMistakeReminder.
    // We only need to cancel any existing watchdog for this id (clean up from previous calls).
    _activeReminderTimers[id]?.cancel();
    _activeReminderTimers.remove(id);
  }

  // ── 8-STAGE SPACED REVISION & QUIET HOURS HELPERS (PDF SPECIFICATION) ─────

  String getStageTitle(int stage) {
    switch (stage) {
      case 1:
        return 'Reminder 1 (1-Hour Recall)';
      case 2:
        return 'Reminder 2 (4-Hour Reinforce)';
      case 3:
        return 'Reminder 3 (4-Hour Reinforce)';
      case 4:
        return 'Reminder 4 (Day 2 Retrieval)';
      case 5:
        return 'Reminder 5 (Day 7 Review)';
      case 6:
        return 'Reminder 6 (Day 15 Review)';
      case 7:
        return 'Reminder 7 (Day 30 Review)';
      case 8:
        return 'Reminder 8 (2-Month Retention)';
      default:
        return 'Spaced Revision (Stage $stage/8)';
    }
  }

  /// Quiet Hours Guard (10:00 PM to 8:00 AM)
  /// Moves late night reminders to next morning at 8:30 AM
  DateTime applyQuietHoursGuard(DateTime scheduledTime) {
    final hour = scheduledTime.hour;
    if (hour >= 22 || hour < 8) {
      DateTime nextMorning;
      if (hour >= 22) {
        final tomorrow = scheduledTime.add(const Duration(days: 1));
        nextMorning = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 30);
      } else {
        nextMorning = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day, 8, 30);
      }
      return nextMorning;
    }
    return scheduledTime;
  }

  /// Calculates next due time for each of the 8 PDF Spaced Repetition stages:
  /// Reminder 1: 1 hour after mistake
  /// Reminder 2: 4 hours after Reminder 1
  /// Reminder 3: 4 hours after Reminder 2
  /// Reminder 4: Next day (Day 2 / 24 hours from original)
  /// Reminder 5: Day 7 (7 days from original)
  /// Reminder 6: Day 15 (15 days from original)
  /// Reminder 7: Day 30 (30 days from original)
  /// Reminder 8: 2 months (~60 days from original)
  DateTime computeNextDueTime({
    required DateTime originalMistakeTime,
    required int nextStage,
    DateTime? fromTime,
  }) {
    DateTime target;
    final base = fromTime ?? DateTime.now();
    switch (nextStage) {
      case 1:
        target = originalMistakeTime.add(const Duration(hours: 1));
        break;
      case 2:
        target = base.add(const Duration(hours: 4));
        break;
      case 3:
        target = base.add(const Duration(hours: 4));
        break;
      case 4:
        target = originalMistakeTime.add(const Duration(days: 1));
        break;
      case 5:
        target = originalMistakeTime.add(const Duration(days: 7));
        break;
      case 6:
        target = originalMistakeTime.add(const Duration(days: 15));
        break;
      case 7:
        target = originalMistakeTime.add(const Duration(days: 30));
        break;
      case 8:
        target = originalMistakeTime.add(const Duration(days: 60));
        break;
      default:
        target = base.add(const Duration(hours: 1));
    }

    if (fromTime == null && target.isBefore(DateTime.now())) {
      target = DateTime.now().add(const Duration(minutes: 5));
    }

    return applyQuietHoursGuard(target);
  }

  List<AndroidNotificationAction> _buildRevisionActions({
    required String formula,
    required String correctAnswer,
    List<String>? preShuffledChoices,
  }) {
    return <AndroidNotificationAction>[
      AndroidNotificationAction(
        'type_answer|$formula|$correctAnswer',
        '✏️ Write Answer',
        cancelNotification: false,
        showsUserInterface: false,
        inputs: const [
          AndroidNotificationActionInput(
            label: 'Write your answer...',
            allowFreeFormInput: true,
          ),
        ],
      ),
      AndroidNotificationAction(
        'open_solve|$formula|$correctAnswer',
        '📱 Solve Now',
        cancelNotification: false,
        showsUserInterface: true,
      ),
      AndroidNotificationAction(
        'snooze|$formula|$correctAnswer',
        '💤 Snooze',
        cancelNotification: true,
        showsUserInterface: false,
      ),
    ];
  }

  // ── NOTIFICATION OPTION HELPERS (MULTIPLE CHOICE WITH SNOOZE) ────────────────

  /// Prepares exactly 3 answer choices (1 correct answer + 2 realistic distractors)
  List<String> _buildThreeAnswerChoices(List<String> options, String correctAnswer) {
    List<String> choices = [correctAnswer.trim()];
    for (var opt in options) {
      if (opt.trim() != correctAnswer.trim() && !choices.contains(opt.trim())) {
        choices.add(opt.trim());
        if (choices.length == 3) break;
      }
    }
    while (choices.length < 3) {
      int cVal = int.tryParse(correctAnswer.trim()) ?? 0;
      int nextVal = cVal > 0 ? cVal + (10 * choices.length) : (99 + choices.length);
      choices.add('$nextVal');
    }
    choices.shuffle();
    return choices;
  }

  /// Formats notification body options:
  /// (A) choice1   (B) choice2
  /// (C) choice3   (D) ⏰ Snooze
  String _buildNotificationOptionsLine(List<String> preShuffledChoices) {
    final c0 = preShuffledChoices.isNotEmpty ? preShuffledChoices[0] : '';
    final c1 = preShuffledChoices.length > 1 ? preShuffledChoices[1] : '';
    final c2 = preShuffledChoices.length > 2 ? preShuffledChoices[2] : '';
    return '🧠 (A) $c0   (B) $c1   (C) $c2';
  }

  /// Formats question title and body for spaced repetition challenge.
  String _buildQuestionBody(String formula, {int stage = 1, String? wrongAttempt, List<String>? preShuffledChoices}) {
    final wrongHint = wrongAttempt != null && wrongAttempt.isNotEmpty
        ? '❌ Galat ($wrongAttempt)\n'
        : '';
    final opts = preShuffledChoices != null && preShuffledChoices.isNotEmpty
        ? _buildNotificationOptionsLine(preShuffledChoices)
        : '';
    return '$wrongHint$opts';
  }

  /// Builds notification action buttons:
  /// (A), (B), (C) as clickable math choices + (D) ⏰ Snooze
  List<AndroidNotificationAction> _buildFourActions({
    required String formula,
    required List<String> preShuffledChoices,
    required String correctAnswer,
  }) {
    final c0 = preShuffledChoices.isNotEmpty ? preShuffledChoices[0] : correctAnswer;
    final c1 = preShuffledChoices.length > 1 ? preShuffledChoices[1] : '${(int.tryParse(correctAnswer) ?? 0) + 10}';
    final c2 = preShuffledChoices.length > 2 ? preShuffledChoices[2] : '${(int.tryParse(correctAnswer) ?? 0) + 20}';

    return <AndroidNotificationAction>[
      AndroidNotificationAction(
        'ans|$formula|$c0|$correctAnswer',
        '(A) $c0',
        cancelNotification: false,
        showsUserInterface: false,
        contextual: false,
      ),
      AndroidNotificationAction(
        'ans|$formula|$c1|$correctAnswer',
        '(B) $c1',
        cancelNotification: false,
        showsUserInterface: false,
        contextual: false,
      ),
      AndroidNotificationAction(
        'ans|$formula|$c2|$correctAnswer',
        '(C) $c2',
        cancelNotification: false,
        showsUserInterface: false,
        contextual: false,
      ),
    ];
  }

  /// Fallback wrapper for any older call sites
  List<AndroidNotificationAction> _buildTextInputActions({
    required String formula,
    required String correctAnswer,
  }) {
    final options = generateRecallOptions(correctAnswer, formula);
    final choices = _buildThreeAnswerChoices(options, correctAnswer);
    return _buildFourActions(
      formula: formula,
      preShuffledChoices: choices,
      correctAnswer: correctAnswer,
    );
  }

  Future<void> _postRecallNotificationInternal({
    required int id,
    required String title,
    required String formula,
    required List<String> options,
    required String correctAnswer,
    String? wrongAttempt,
    String? summaryText,
    bool isSilent = false,
  }) async {
    if (_isAppInForeground && wrongAttempt == null) {
      debugPrint('🛡️ App is in foreground: strictly suppressing recall notification alert for "$formula"');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final int currentStage = prefs.getInt('repetition_stage_$formula') ?? 1;
    final bool isWrongState = wrongAttempt != null && wrongAttempt.isNotEmpty;

    final String stageName = getStageTitle(currentStage);

    final String displayTitle = isWrongState
        ? '❌ Galat ($wrongAttempt)! $formula = ?'
        : '$stageName: $formula = ?';

    final String displayBody = isWrongState
        ? '❌ Galat jawab! Sahi answer type karein ya Solve Now tap karein.'
        : 'Write your answer below or tap Solve Now:';

    final String titleHexColor = isWrongState ? '#EF4444' : '#22C55E';
    final Color accentColor = isWrongState ? const Color(0xFFEF4444) : const Color(0xFF22C55E);

    final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
      displayBody,
      htmlFormatBigText: true,
      contentTitle: '<font color="$titleHexColor"><b>$displayTitle</b></font>',
      htmlFormatContentTitle: true,
      summaryText: isWrongState
          ? 'Incorrect attempt — question stays active until solved!'
          : (summaryText ?? '8-Stage Spaced Revision (Stage $currentStage/8)'),
      htmlFormatSummaryText: true,
    );

    final actions = _buildRevisionActions(
      formula: formula,
      correctAnswer: correctAnswer,
    );

    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        isSilent ? 'prepvanta_recall_feedback_v1' : 'prepvanta_animated_recall_v4',
        isSilent ? 'PrepVanta Recall Visual Updates' : 'PrepVanta Spaced Repetition Recall',
        channelDescription: isSilent
            ? 'Silent visual feedback updates for recall notifications'
            : 'Spaced repetition alerts: 30 min, 3 hr, next day',
        importance: isSilent ? Importance.high : Importance.max,
        priority: Priority.max,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]), // FLAG_ONGOING_EVENT(2) + FLAG_NO_CLEAR(32) = Cannot dismiss with Clear All
        subText: summaryText ?? 'Stage $currentStage of 3',
        enableVibration: !isSilent,
        vibrationPattern: isSilent ? null : Int64List.fromList([0, 150, 80, 250, 80, 350, 80, 500]),
        playSound: !isSilent,
        sound: isSilent ? null : const RawResourceAndroidNotificationSound('custom_notification_sound'),
        onlyAlertOnce: isSilent,
        silent: isSilent,
        enableLights: true,
        ledColor: accentColor,
        ledOnMs: 600,
        ledOffMs: 400,
        channelShowBadge: true,
        showWhen: true,
        colorized: isWrongState,
        color: accentColor,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        styleInformation: bigTextStyle,
        actions: actions,
      );

      final NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: id,
        title: displayTitle,
        body: displayBody,
        notificationDetails: details,
        payload: 'persistent|$id|$formula|$correctAnswer',
      );
      if (!isSilent) {
        await incrementDailyNotificationCount();
      }


    } catch (e) {
      debugPrint('Persistent recall notification error: $e');
    }
  }

  /// Flashes a green confirmation banner on the OS notification before cancelling it
  Future<void> _showGreenSolvedNotification({
    required int id,
    required String formula,
    required String correctAnswer,
  }) async {
    try {
      final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
        '🎉 Memory boost locked! Clearing alert...',
        htmlFormatBigText: true,
        contentTitle: '<font color="#22C55E"><b>✅ Sahi Jawab! $formula = $correctAnswer</b></font>',
        htmlFormatContentTitle: true,
        summaryText: 'Solved Correctly',
      );
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prepvanta_recall_feedback_v1',
        'PrepVanta Recall Visual Updates',
        channelDescription: 'Silent visual feedback updates for recall notifications',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
        playSound: false,
        enableVibration: false,
        onlyAlertOnce: true,
        silent: true,
        colorized: true,
        color: const Color(0xFF22C55E),
        category: AndroidNotificationCategory.status,
        visibility: NotificationVisibility.public,
        styleInformation: bigTextStyle,
      );
      await _notificationsPlugin.show(
        id: id,
        title: '✅ Sahi Jawab! $formula = $correctAnswer',
        body: '🎉 Memory boost locked! Clearing alert...',
        notificationDetails: NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  // Intercept swipe-away / clear-all action: If user dismisses without answering, re-post silently AND schedule a 5-min AlarmManager backup!
  Future<void> handleNotificationDismissed(NotificationResponse response) async {
    debugPrint('🚨 Notification dismissed/swiped: id=${response.id}, payload=${response.payload}');

    if (response.id != null && _programmaticallyDismissedNotifIds.contains(response.id)) {
      _programmaticallyDismissedNotifIds.remove(response.id);
      return;
    }

    final payload = response.payload;
    if (payload != null && payload.startsWith('persistent|')) {
      final parts = payload.split('|');
      if (parts.length >= 4) {
        final int notifId = int.tryParse(parts[1]) ?? response.id ?? 7999;
        final String formula = cleanPrompt(parts[2]);
        final String correctAnswer = parts[3];

        final bool isSolved = await isCalculationSolved(formula);
        if (isSolved) return;

        final prefs = await SharedPreferences.getInstance();
        if (isFormulaSnoozed(formula, prefs)) return;

        debugPrint('🔒 User tried to swipe recall notification! Silent re-post + 5-min backup alarm: $formula');
        // 1. Attempt silent immediate restore (works on Android <14)
        await showPersistentRecallNotification(
          id: notifId,
          prompt: formula,
          correctAnswer: correctAnswer,
          wrongAttempt: null,
          isSilent: true,
        );

        // 2. Android 14+ fallback: Android 14 allows swiping ongoing notifications and may drop
        // immediate deleteIntent re-posts. Schedule a native AlarmManager comeback in 5 minutes!
        try {
          _ensureTimezonesInitialized();
          final int stage = prefs.getInt('repetition_stage_$formula') ?? 1;
          await _scheduleNativeAlarmFor(
            notifId: notifId,
            formula: formula,
            answer: correctAnswer,
            scheduledTz: tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5)),
            stage: stage,
          );
        } catch (e) {
          debugPrint('Swipe-backup alarm schedule error: $e');
        }
        return;
      }
    }
  }

  Future<void> _markRecallSolvedInPrefs(String formula) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = cleanPrompt(formula);
      await prefs.setBool('is_solved_$clean', true);
      await prefs.remove('active_recall_$clean');
      await prefs.remove('active_recall_id_$clean');
      await prefs.remove('snoozed_until_$clean');
    } catch (_) {}
  }

  Future<void> _markRecallUnsolvedInPrefs(String formula) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = cleanPrompt(formula);
      await prefs.remove('is_solved_$clean');
    } catch (_) {}
  }

  Future<void> _markRecallActiveInPrefs(String formula, String correctAnswer, int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = cleanPrompt(formula);
      await prefs.setString('active_recall_$clean', correctAnswer);
      await prefs.setInt('active_recall_id_$clean', id);
      await prefs.remove('is_solved_$clean');
    } catch (_) {}
  }


  // ==========================================
  // DAILY NOTIFICATION FREQUENCY CAPPING (LIMIT)
  // ==========================================
  Future<int> getDailyNotificationLimit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('daily_notification_limit') ?? 10; // Default: 10 alerts per day
    } catch (_) {
      return 10;
    }
  }

  Future<void> setDailyNotificationLimit(int limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_notification_limit', limit);
      debugPrint('🔔 Daily notification limit set to: $limit');
    } catch (_) {}
  }

  Future<int> getDailyNotificationCountToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return prefs.getInt('notif_count_$todayStr') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> incrementDailyNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final count = prefs.getInt('notif_count_$todayStr') ?? 0;
      await prefs.setInt('notif_count_$todayStr', count + 1);
      debugPrint('📢 Notification sent today: ${count + 1}');
    } catch (_) {}
  }

  Future<bool> hasReachedDailyNotificationLimit() async {
    try {
      final limit = await getDailyNotificationLimit();
      if (limit <= 0) return false; // 0 or negative = Unlimited
      final count = await getDailyNotificationCountToday();
      if (count >= limit) {
        debugPrint('🛑 Daily notification limit ($limit) reached for today ($count sent). Suppressing notification to prevent fatigue.');
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetDailyNotificationCountForTesting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.remove('notif_count_$todayStr');
    } catch (_) {}
  }

  Future<bool> isCalculationSolved(String formula) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = cleanPrompt(formula);
      if (clean.isEmpty) return true;

      // 1. Explicitly marked solved flag
      if (prefs.getBool('is_solved_$clean') == true) {
        return true;
      }

      // 2. Active Spaced Repetition stage check (Stages 1, 2, 3 are pending recall and NOT solved until Stage 4)
      final stage = prefs.getInt('repetition_stage_$clean');
      if (stage != null && stage < 4 && prefs.getBool('is_solved_$clean') != true) {
        return false;
      }

      // 3. Active starred table formula check
      final activeStarred = prefs.getString('active_starred_table_formula');
      if (activeStarred != null && cleanPrompt(activeStarred) == clean && prefs.getBool('is_solved_$clean') != true) {
        return false;
      }

      // 4. If present in pending recall queue, it is definitely UNSOLVED
      final queue = prefs.getStringList('pending_recall_queue') ?? [];
      final inQueue = queue.any((item) => cleanPrompt(item.split('|').first) == clean);
      if (inQueue) {
        return false;
      }

      // 3. If present in unnotified list, it is definitely UNSOLVED
      final unnotified = prefs.getStringList('unnotified_mistakes_list') ?? [];
      final inUnnotified = unnotified.any((item) => cleanPrompt(item.split('|').first) == clean);
      if (inUnnotified) {
        return false;
      }

      // 4. If present in notebook mistakes_list, it is definitely UNSOLVED
      final mistakes = prefs.getStringList('mistakes_list') ?? [];
      final inMistakes = mistakes.any((s) {
        try {
          final m = json.decode(s);
          return cleanPrompt(m['prompt'] ?? '') == clean;
        } catch (_) {
          return false;
        }
      });
      if (inMistakes) {
        return false;
      }

      // 5. If it was active and now removed, check active_recall key
      return !prefs.containsKey('active_recall_$clean');
    } catch (_) {
      return false;
    }
  }

  // Checks if a question has reached its scheduled spaced repetition due time (1-Hour -> +3-Hours -> +3-Hours)
  bool isCalculationDueForRecall(String formula, SharedPreferences prefs) {
    final clean = cleanPrompt(formula);
    final dueStr = prefs.getString('recall_due_at_$clean');
    if (dueStr == null || dueStr.isEmpty) {
      return true; // No deferred timer set, allowed to post
    }
    final dueTime = DateTime.tryParse(dueStr);
    if (dueTime == null) return true;
    return DateTime.now().isAfter(dueTime);
  }

  Future<int> getRepetitionStage(String formula) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = cleanPrompt(formula);
      return prefs.getInt('repetition_stage_$clean') ?? 1;
    } catch (_) {
      return 1;
    }
  }

  Future<String> getCorrectAnswerForFormula(String formula) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('active_recall_${cleanPrompt(formula)}');
      if (stored != null && _isCleanComputedAnswer(stored)) {
        return stored;
      }
    } catch (_) {}
    return _computeFallbackAnswer(formula);
  }

  String _computeFallbackAnswer(String formula) {
    final trimmed = formula.trim();
    if (trimmed.isEmpty) return '';

    if (_isCleanComputedAnswer(trimmed)) return trimmed;

    try {
      String clean = cleanPrompt(trimmed);

      // Square root (e.g. √144)
      final sqrtMatch = RegExp(r'^√\s*(\d+)$').firstMatch(clean);
      if (sqrtMatch != null) {
        int n = int.parse(sqrtMatch.group(1)!);
        int r = sqrt(n).round();
        if (r * r == n) return '$r';
        return '';
      }

      // Cube root (e.g. ∛343)
      final cbrtMatch = RegExp(r'^∛\s*(\d+)$').firstMatch(clean);
      if (cbrtMatch != null) {
        int n = int.parse(cbrtMatch.group(1)!);
        int r = pow(n, 1 / 3).round();
        if (r * r * r == n) return '$r';
        return '';
      }

      // Percentage of number (e.g. 25% of 400)
      final pctOfMatch = RegExp(r'^(\d+(?:\.\d+)?)\s*%\s*of\s*(\d+(?:\.\d+)?)$', caseSensitive: false).firstMatch(clean);
      if (pctOfMatch != null) {
        double p = double.parse(pctOfMatch.group(1)!);
        double numVal = double.parse(pctOfMatch.group(2)!);
        double res = (p / 100.0) * numVal;
        return res == res.roundToDouble() ? '${res.toInt()}' : res.toStringAsFixed(2);
      }

      // Exact single-operation square (e.g. 17² or 17^2)
      final sqMatch = RegExp(r'^(\d+)\s*(?:²|\^2)$').firstMatch(clean);
      if (sqMatch != null) {
        int n = int.parse(sqMatch.group(1)!);
        return '${n * n}';
      }

      // Exact single-operation cube (e.g. 8³ or 8^3)
      final cbMatch = RegExp(r'^(\d+)\s*(?:³|\^3)$').firstMatch(clean);
      if (cbMatch != null) {
        int n = int.parse(cbMatch.group(1)!);
        return '${n * n * n}';
      }

      // Exact multiplication: (num) × (num)
      final multMatch = RegExp(r'^(\d+)\s*[×\*xX\u00D7\u2715\u2716]\s*(\d+)$').firstMatch(clean);
      if (multMatch != null) {
        int a = int.parse(multMatch.group(1)!);
        int b = int.parse(multMatch.group(2)!);
        return '${a * b}';
      }

      // Exact addition: (num) + (num)
      final addMatch = RegExp(r'^(\d+)\s*\+\s*(\d+)$').firstMatch(clean);
      if (addMatch != null) {
        int a = int.parse(addMatch.group(1)!);
        int b = int.parse(addMatch.group(2)!);
        return '${a + b}';
      }

      // Exact subtraction: (num) - (num)
      final subMatch = RegExp(r'^(\d+)\s*[\-−\u2212]\s*(\d+)$').firstMatch(clean);
      if (subMatch != null) {
        int a = int.parse(subMatch.group(1)!);
        int b = int.parse(subMatch.group(2)!);
        return '${a - b}';
      }

      // Exact division: (num) ÷ (num)
      final divMatch = RegExp(r'^(\d+)\s*[÷/\u00F7]\s*(\d+)$').firstMatch(clean);
      if (divMatch != null) {
        int a = int.parse(divMatch.group(1)!);
        int b = int.parse(divMatch.group(2)!);
        if (b != 0) {
          if (a < b) {
            final pct = (a / b * 100);
            return pct == pct.roundToDouble()
                ? '${pct.toInt()}%'
                : '${pct.toStringAsFixed(2)}%';
          }
          if (a % b == 0) return '${a ~/ b}';
          return (a / b).toStringAsFixed(2);
        }
      }
    } catch (e) {
      debugPrint('Fallback math compute error: $e');
    }

    return '';
  }

  // Handle immediate tap on answer options directly from the notification shade

  /// Records wrong attempt stage reset in background without flashing/dismissing active UI banners
  Future<void> _recordWrongAnswerStateOnly({
    required String formula,
    required String wrongOption,
    required int notifId,
  }) async {
    try {
      final clean = cleanPrompt(formula);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('repetition_stage_$clean', 1);
      final dueAt = DateTime.now().add(const Duration(minutes: 30));
      await prefs.setString('recall_due_at_$clean', dueAt.toIso8601String());
      final ans = await getCorrectAnswerForFormula(clean);
      if (notifId >= 55000 && notifId <= 55025) {
        final activeTable = prefs.getInt('active_starred_table_number') ?? 0;
        if (activeTable > 0) {
          await _scheduleStarredTableSpaced(activeTable, delayMinutes: 30, stage: 1);
        }
      } else if (ans.isNotEmpty) {
        await schedule1HourRecallNotification(
          formula: clean,
          correctAnswer: ans,
          delayMinutes: 30,
        );
      }
    } catch (e) {
      debugPrint('Wrong answer state record note: $e');
    }
  }

  // Handle immediate tap on answer options directly from the notification shade
  Future<void> handleNotificationAnswerAction(String actionId, int? notificationId) async {
    final parts = actionId.split('|');
    if (parts.length < 4) return;
    final formula = cleanPrompt(parts[1]);
    final selectedOption = parts[2].trim();
    final correctAnswer = parts[3].trim();

    final bool isCorrect = _isAnswerCorrect(selectedOption, correctAnswer);
    final int notifId = notificationId ?? getNotificationIdForPrompt(formula);

    if (isCorrect) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
      _activeReminderTimers[notifId]?.cancel();
      _activeReminderTimers.remove(notifId);

      // Flash GREEN confirmation on the notification before removing it
      if (_isInitialized) {
        await _showGreenSolvedNotification(
          id: notifId,
          formula: formula,
          correctAnswer: correctAnswer,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final hasRepetitionStage = prefs.containsKey('repetition_stage_$formula');
      final int currentStage = prefs.getInt('repetition_stage_$formula') ?? 1;

      if (hasRepetitionStage && currentStage < 8) {
        // 8-Stage Spaced Revision Progression (PDF Specification Section 2)
        final int nextStage = currentStage + 1;
        await prefs.setInt('repetition_stage_$formula', nextStage);

        final origStr = prefs.getString('mistake_created_at_$formula');
        final originalTime = origStr != null ? (DateTime.tryParse(origStr) ?? DateTime.now()) : DateTime.now();

        final dueAt = computeNextDueTime(
          originalMistakeTime: originalTime,
          nextStage: nextStage,
        );
        await prefs.setString('recall_due_at_$formula', dueAt.toIso8601String());
        final nextDelayMinutes = dueAt.difference(DateTime.now()).inMinutes.clamp(1, 60 * 24 * 65);

        debugPrint('🎯 Spaced Repetition: $formula advanced from Stage $currentStage to Stage $nextStage. Next recall at $dueAt in ${nextDelayMinutes}m.');

        // Yield current position in active queue and promote next queued question
        await _advanceQueueAfterSolved(formula, selectedOption);

        if (notifId >= 55000 && notifId <= 55025) {
          final activeTable = prefs.getInt('active_starred_table_number') ?? 0;
          if (activeTable > 0) {
            await _scheduleStarredTableSpaced(activeTable, delayMinutes: nextDelayMinutes, stage: nextStage);
          }
        } else {
          await scheduleSpacedRecallNotification(
            formula: formula,
            correctAnswer: correctAnswer,
            stage: nextStage,
            delayMinutes: nextDelayMinutes,
          );
        }
      } else {
        // Stage 8 successfully solved: MASTERED (Stage 9)!
        await prefs.setInt('repetition_stage_$formula', 9);
        await prefs.remove('recall_due_at_$formula');
        await _markRecallSolvedInPrefs(formula);

        onMistakeResolved?.call(formula, selectedOption);
        await _saveResolvedMistakeToPrefs(formula);
        await _advanceQueueAfterSolved(formula, selectedOption);

        if (notifId >= 55000 && notifId <= 55025) {
          final activeTable = prefs.getInt('active_starred_table_number');
          if (activeTable != null && activeTable > 0) {
            final multKey = 'starred_table_${activeTable}_next_mult_idx';
            int nextMultIdx = prefs.getInt(multKey) ?? 0;
            await prefs.setInt(multKey, nextMultIdx + 1);
            await _scheduleStarredTableSpaced(activeTable, delayMinutes: 60, stage: 1);
          }
        }
      }

      if (_isInitialized) {
        await Future.delayed(const Duration(milliseconds: 1100));
      }
      _programmaticallyDismissedNotifIds.add(notifId);
      await cancelNotification(notifId);
    } else {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
      // Penalty: Reset back to Stage 1 (30-Min Recall)!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('repetition_stage_$formula', 1);
      final dueAt = DateTime.now().add(const Duration(minutes: 30));
      await prefs.setString('recall_due_at_$formula', dueAt.toIso8601String());

      // Turn OS notification RED immediately (silent), then reset back to normal after ~1.2s
      await showPersistentRecallNotification(
        id: notifId,
        prompt: formula,
        correctAnswer: correctAnswer,
        wrongAttempt: selectedOption,
        isSilent: true,
      );

      if (notifId >= 55000 && notifId <= 55025) {
        final activeTable = prefs.getInt('active_starred_table_number') ?? 0;
        if (activeTable > 0) {
          await _scheduleStarredTableSpaced(activeTable, delayMinutes: 30, stage: 1);
        }
      } else {
        await schedule1HourRecallNotification(
          formula: formula,
          correctAnswer: correctAnswer,
          delayMinutes: 30,
        );
      }

      if (_isInitialized) {
        await Future.delayed(const Duration(milliseconds: 1200));
        final solvedNow = await isCalculationSolved(formula);
        if (!solvedNow) {
          await showPersistentRecallNotification(
            id: notifId,
            prompt: formula,
            correctAnswer: correctAnswer,
            wrongAttempt: null,
            isSilent: true,
          );
        }
      }
    }
  }

  // ── TYPED ANSWER HANDLER (INLINE TEXT INPUT FROM NOTIFICATION SHADE) ─────────
  Future<void> handleTypedAnswerAction(
    String actionId,
    int? notificationId,
    String? rawInput,
  ) async {
    final parts = actionId.split('|');
    if (parts.length < 3) return;
    final formula = cleanPrompt(parts[1]);
    final correctAnswer = parts[2].trim();

    final String typed = (rawInput ?? '').trim();
    if (typed.isEmpty) return;

    debugPrint('📝 Typed Answer received from notification drawer: "$typed" (Expected: "$correctAnswer")');
    await handleNotificationAnswerAction('ans|$formula|$typed|$correctAnswer', notificationId);
  }

  /// Compares typed answer to correct answer with numeric tolerance.
  bool _isAnswerCorrect(String typed, String correct) {
    if (typed.toLowerCase().trim() == correct.toLowerCase().trim()) return true;
    final tNum = num.tryParse(typed.replaceAll(',', '').replaceAll(' ', '').trim());
    final cNum = num.tryParse(correct.replaceAll(',', '').replaceAll(' ', '').trim());
    if (tNum != null && cNum != null) {
      return (tNum - cNum).abs() < 0.001;
    }
    return false;
  }

  bool isFormulaSnoozed(String formula, SharedPreferences prefs) {
    final clean = cleanPrompt(formula);
    final str = prefs.getString('snoozed_until_$clean');
    if (str != null && str.isNotEmpty) {
      final until = DateTime.tryParse(str);
      if (until != null && DateTime.now().isBefore(until)) {
        return true;
      }
    }
    return false;
  }

  // Snooze an interactive notification so the student is not disturbed today,
  // and reschedule it natively for tomorrow morning (9:00 AM) or 24h later!
  Future<void> handleSnoozeAction(String actionId, int? notificationId) async {
    final parts = actionId.split('|');
    if (parts.length < 2) return;
    final formula = cleanPrompt(parts[1]);
    final notifId = notificationId ?? getNotificationIdForPrompt(formula);
    String correctAnswer = parts.length >= 3 ? parts[2].trim() : await getCorrectAnswerForFormula(formula);

    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0);
    if (tomorrow.isBefore(now)) {
      tomorrow = now.add(const Duration(hours: 24));
    }

    // Mark as snoozed in prefs
    await prefs.setString('snoozed_until_$formula', tomorrow.toIso8601String());

    // Dismiss active ongoing notification for today
    _activeReminderTimers[notifId]?.cancel();
    _activeReminderTimers.remove(notifId);
    _programmaticallyDismissedNotifIds.add(notifId);
    await cancelNotification(notifId);

    // Schedule native alarm for tomorrow
    try {
      final scheduledTz = tz.TZDateTime.from(tomorrow, tz.local);
      final vibPattern = Int64List.fromList([0, 180, 80, 320, 80, 180]);
      final options = generateRecallOptions(correctAnswer, formula);
      final List<String> shuffledChoices = _buildThreeAnswerChoices(options, correctAnswer);
      final optionsLine = _buildNotificationOptionsLine(shuffledChoices);
      final notifBody = optionsLine;
      final actions = _buildFourActions(
        formula: formula,
        preShuffledChoices: shuffledChoices,
        correctAnswer: correctAnswer,
      );

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prepvanta_animated_recall_v4',
        'PrepVanta Spaced Repetition Recall',
        channelDescription: 'Spaced repetition calculation alerts for mistake revision',
        importance: Importance.max,
        priority: Priority.max,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]),
        enableVibration: true,
        vibrationPattern: vibPattern,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
        colorized: false,
        color: const Color(0xFF22C55E),
        subText: 'Snoozed Recall — Kal 9 AM',
        styleInformation: BigTextStyleInformation(
          notifBody,
          htmlFormatBigText: true,
          contentTitle: '<font color="#22C55E"><b>⚡ Snoozed Recall: $formula = ?</b></font>',
          htmlFormatContentTitle: true,
          summaryText: 'Kal ke liye snoozed — ab yaad karo!',
        ),
        actions: actions,
      );

      await _notificationsPlugin.zonedSchedule(
        id: notifId,
        title: '🟢 Kal Ka Recall: $formula = ?',
        body: notifBody,
        scheduledDate: scheduledTz,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'persistent|$notifId|$formula|$correctAnswer',
      );
      debugPrint('✅ Snoozed recall scheduled for tomorrow 9AM: $formula');
    } catch (e) {
      debugPrint('Snooze zonedSchedule note: $e');
    }

    debugPrint('⏰ Calculation $formula successfully SNOOZED until ${tomorrow.toIso8601String()}');
  }

  Future<void> _saveResolvedMistakeToPrefs(String formula) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? mistakeStrings = prefs.getStringList('mistakes_list');
      if (mistakeStrings != null && mistakeStrings.isNotEmpty) {
        String target = cleanPrompt(formula);
        List<String> updated = mistakeStrings.where((s) {
          try {
            Map<String, dynamic> map = json.decode(s);
            String prompt = map['prompt'] ?? '';
            String cleanP = prompt.replaceAll(' = ?', '').replaceAll('?', '').replaceAll('=', '').trim();
            return cleanP != target;
          } catch (_) {
            return true;
          }
        }).toList();
        await prefs.setStringList('mistakes_list', updated);
      }
    } catch (e) {
      debugPrint('Error saving resolved mistake to prefs: $e');
    }
  }

  // 1. SPECIFIC CALCULATION MISTAKE REMINDER QUEUE
  // Spaced Repetition Lifecycle:
  //   t=0   Wrong answer →  zonedSchedule native alarm at t+60min (Stage 1)
  //   t+1h  Notification fires (user sees it when app is CLOSED)
  //   Correct at Stage 1  →  native alarm at t+3hr (Stage 2)
  //   Correct at Stage 2  →  native alarm at t+3hr (Stage 3)
  //   Correct at Stage 3  →  MASTERED, cleared forever
  //   Wrong at any stage  →  reset to Stage 1 (1-hr alarm again)
  //
  // CRITICAL: postImmediately is always false in production.
  // Notifications NEVER show while the app is in the foreground.
  Future<void> scheduleCalculationMistakeReminder({
    required String prompt,
    required String correctAnswer,
    required String userAnswer,
    String topicName = 'Tables',
    String userName = 'Aspirant',
    bool postImmediately = false, // Always false in production — only true in admin tests
  }) async {
    String formula = cleanPrompt(prompt);
    // 🛡️ Never schedule mistake reminder for non-math / English content
    if (!_isValidMathFormula(formula)) {
      debugPrint('⚠️ Skipping scheduleCalculationMistakeReminder for non-math content: "$formula"');
      return;
    }
    // 🛡️ User directive: No notifications for addition or subtraction
    if (_isAdditionOrSubtraction(formula, topicName)) {
      debugPrint('🛡️ Suppressing reminder notification for addition/subtraction: "$formula" ($topicName)');
      return;
    }
    await _markRecallUnsolvedInPrefs(formula);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('snoozed_until_$formula');

    String resolvedAnswer = correctAnswer.trim();
    if (!_isCleanComputedAnswer(resolvedAnswer)) {
      resolvedAnswer = _computeFallbackAnswer(formula.isNotEmpty ? formula : resolvedAnswer);
    }
    if (!_isCleanComputedAnswer(resolvedAnswer)) {
      debugPrint('⚠️ Skipping mistake schedule — invalid answer for "$formula"');
      return;
    }

    // Initialize Stage 1 (1-Hour Spaced Recall - PDF Specification Section 2)
    await prefs.setInt('repetition_stage_$formula', 1);
    final now = DateTime.now();
    await prefs.setString('mistake_created_at_$formula', now.toIso8601String());
    final dueAt = computeNextDueTime(
      originalMistakeTime: now,
      nextStage: 1,
    );
    await prefs.setString('recall_due_at_$formula', dueAt.toIso8601String());

    // Cancel generic hourly challenge (id 1111) so user mistakes take priority
    await cancelNotification(1111);
    List<String> queue = prefs.getStringList('pending_recall_queue') ?? [];

    String newEntry = '$formula|$resolvedAnswer';
    if (!queue.contains(newEntry)) {
      queue.add(newEntry);
    }
    await prefs.setStringList('pending_recall_queue', queue);
    if (queue.isNotEmpty) {
      final lead = cleanPrompt(queue.first.split('|').first);
      await prefs.setString('currently_displayed_recall_formula', lead);
    }

    List<String> unnotified = prefs.getStringList('unnotified_mistakes_list') ?? [];
    if (!unnotified.contains(newEntry)) {
      unnotified.add(newEntry);
    }
    await prefs.setStringList('unnotified_mistakes_list', unnotified);

    // Schedule 1-Hour recall via native zonedSchedule alarm (fires even when app is closed)
    // This is the ONLY way the notification gets posted — NOT via immediate show()
    await schedule1HourRecallNotification(
      formula: formula,
      correctAnswer: resolvedAnswer,
      delayMinutes: 30,
    );

    debugPrint('✅ Mistake scheduled: "$formula" → notification in 30 min (Stage 1)');

    // postImmediately=true is reserved for Admin panel test button ONLY
    if (postImmediately) {
      await postAllPendingMistakesSerial();
    }
  }

  // Batch queue all session mistakes and schedule 1-hour spaced recall alerts
  Future<void> enqueueSessionMistakesAndTrigger(
    List<MistakeModel> mistakes, {
    bool postImmediately = false,
  }) async {
    if (mistakes.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> queue = prefs.getStringList('pending_recall_queue') ?? [];
      List<String> unnotified = prefs.getStringList('unnotified_mistakes_list') ?? [];

      for (var m in mistakes) {
        final clean = cleanPrompt(m.prompt);
        // 🛡️ User directive: No notifications for addition or subtraction
        if (_isAdditionOrSubtraction(clean, m.topicId)) {
          debugPrint('🛡️ Skipping addition/subtraction mistake from notification queue: "$clean"');
          continue;
        }
        await _markRecallUnsolvedInPrefs(clean);
        await prefs.remove('snoozed_until_$clean');
        String resolvedAnswer = m.correctAnswer.trim();
        if (!_isCleanComputedAnswer(resolvedAnswer)) {
          resolvedAnswer = _computeFallbackAnswer(clean.isNotEmpty ? clean : resolvedAnswer);
        }
        final entry = '$clean|$resolvedAnswer';
        if (!queue.contains(entry)) {
          queue.add(entry);
        }
        if (!unnotified.contains(entry)) {
          unnotified.add(entry);
        }

        // Initialize Stage 1 (30-Min Spaced Recall — Scientific SM-2 first interval)
        await prefs.setInt('repetition_stage_$clean', 1);
        final dueAt = DateTime.now().add(const Duration(minutes: 30));
        await prefs.setString('recall_due_at_$clean', dueAt.toIso8601String());

        // Schedule 30-min recall notification for each mistake
        await schedule1HourRecallNotification(
          formula: clean,
          correctAnswer: resolvedAnswer,
          delayMinutes: 30,
        );
      }

      await prefs.setStringList('pending_recall_queue', queue);
      if (queue.isNotEmpty) {
        final lead = cleanPrompt(queue.first.split('|').first);
        await prefs.setString('currently_displayed_recall_formula', lead);
      }
      await prefs.setStringList('unnotified_mistakes_list', unnotified);

      // Cancel generic hourly challenge (id 1111) so user mistakes take priority
      await cancelNotification(1111);

      if (postImmediately) {
        await postAllPendingMistakesSerial();
      }
    } catch (e) {
      debugPrint('Error enqueueing session mistakes: $e');
    }
  }

  // Deprecated: Spaced repetition is managed by individual scheduled alarms
  Future<void> postAllPendingMistakesSerial() async {}

  Future<void> postLatestMistakePriority({String? targetFormula, String? targetAnswer}) async {}

  // Force-post ALL pending mistakes right now (Bypasses 60m delay for instant testing and manual verification)
  Future<int> forcePostAllPendingMistakesNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('pending_recall_queue') ?? [];
      if (queue.isEmpty) return 0;

      await cancelNotification(1111);
      int postedCount = 0;

      for (int i = 0; i < queue.length; i++) {
        final item = queue[i];
        final parts = item.split('|');
        if (parts.isEmpty) continue;
        final formula = cleanPrompt(parts[0]);
        if (formula.isEmpty) continue;

        final bool isSolved = await isCalculationSolved(formula);
        if (isSolved) continue;

        String answer = parts.length >= 2 ? parts[1].trim() : _computeFallbackAnswer(formula);
        if (!_isCleanComputedAnswer(answer)) {
          answer = _computeFallbackAnswer(formula);
        }

        final int notifId = getNotificationIdForPrompt(formula);
        _activeReminderTimers[notifId]?.cancel();
        _activeReminderTimers.remove(notifId);

        debugPrint('⚡ Instant Test Post Mistake [${i + 1}/${queue.length}]: $formula = $answer (ID: $notifId)');
        await showPersistentRecallNotification(
          id: notifId,
          prompt: formula,
          correctAnswer: answer,
        );
        postedCount++;

        if (i < queue.length - 1) {
          await Future.delayed(const Duration(milliseconds: 250));
        }
      }
      return postedCount;
    } catch (e) {
      debugPrint('Error force-posting mistakes: $e');
      return 0;
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // SPACED REPETITION — CORE RULES:
  //   Wrong answer at t=0  →  Notification fires at t+1hr (Stage 1)
  //   Correct at Stage 1   →  Notification fires at t+3hr (Stage 2)
  //   Correct at Stage 2   →  Notification fires at t+3hr (Stage 3)
  //   Correct at Stage 3   →  MASTERED, no more notifications
  //   Wrong at any stage   →  Reset to Stage 1, fire again in 1hr
  //
  // NEVER fires notifications while the app is open/foreground.
  // Notifications ONLY fire via zonedSchedule (native Android alarm) after
  // the specified delay. Dart timers are a backup ONLY for when app stays open.
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Called when app resumes from background.
  /// Re-schedules any pending alarms that may have been missed while app was killed.
  /// Does NOT immediately show any notification.
  Future<void> rescheduleAllPendingMistakeAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> queue = prefs.getStringList('pending_recall_queue') ?? [];
      if (queue.isEmpty) return;

      _ensureTimezonesInitialized();
      int rescheduled = 0;

      for (final item in queue) {
        final parts = item.split('|');
        if (parts.isEmpty) continue;
        final formula = cleanPrompt(parts[0]);
        if (formula.isEmpty) continue;

        final bool isSolved = await isCalculationSolved(formula);
        if (isSolved) continue;

        final bool isSnoozed = isFormulaSnoozed(formula, prefs);
        if (isSnoozed) continue;

        // Check if the alarm is due or in the future
        final dueStr = prefs.getString('recall_due_at_$formula');
        final dueTime = dueStr != null ? DateTime.tryParse(dueStr) : null;
        final now = DateTime.now();

        String answer = parts.length >= 2 ? parts[1].trim() : _computeFallbackAnswer(formula);
        if (!_isCleanComputedAnswer(answer)) {
          answer = _computeFallbackAnswer(formula);
        }

        final int notifId = getNotificationIdForPrompt(formula);
        final int stage = prefs.getInt('repetition_stage_$formula') ?? 1;

        if (dueTime != null && now.isBefore(dueTime)) {
          // Alarm is still in the future — re-register the native alarm
          // (in case it was cleared when app was killed)
          final remaining = dueTime.difference(now);
          debugPrint('🔁 Re-scheduling alarm for $formula in ${remaining.inMinutes}m (Stage $stage)');

          if (stage == 1) {
            await schedule1HourRecallNotification(
              formula: formula,
              correctAnswer: answer,
              delayMinutes: remaining.inMinutes.clamp(1, 30),
            );
          } else {
            await scheduleSpacedRecallNotification(
              formula: formula,
              correctAnswer: answer,
              stage: stage,
              delayMinutes: remaining.inMinutes.clamp(1, 180),
            );
          }
          rescheduled++;
        } else {
          // If dueTime has already passed, DO NOT trigger notifications while user is in the app.
          // The student is currently studying inside the app and will see mistakes in the Revision Notebook.
          debugPrint('ℹ️ Alarm for $formula has passed schedule; preserved in Revision Notebook.');
        }
      }

      debugPrint('✅ rescheduleAllPendingMistakeAlarms: $rescheduled future alarms verified');
    } catch (e) {
      debugPrint('Error in rescheduleAllPendingMistakeAlarms: $e');
    }
  }

  /// Internal helper: schedules one native zonedSchedule alarm
  Future<void> _scheduleNativeAlarmFor({
    required int notifId,
    required String formula,
    required String answer,
    required tz.TZDateTime scheduledTz,
    required int stage,
  }) async {
    try {
      final options = generateRecallOptions(answer, formula);
      // Generate shuffled choices ONCE so body text and action buttons show SAME order
      final List<String> shuffledChoices = _buildThreeAnswerChoices(options, answer);
      final optionsLine = _buildNotificationOptionsLine(shuffledChoices);
      final stageLabel = stage == 1
          ? '1-Hr Recall'
          : stage == 2
              ? '+3-Hr Reinforcement'
              : 'Final Retention Check';
      final actions = _buildFourActions(
        formula: formula,
        preShuffledChoices: shuffledChoices,
        correctAnswer: answer,
      );
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prepvanta_animated_recall_v4',
        'PrepVanta Spaced Repetition Recall',
        channelDescription: 'Spaced repetition calculation alerts for mistake revision (1hr, 3hr)',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
        enableVibration: true,
        channelShowBadge: true,
        showWhen: true,
        colorized: false,
        color: const Color(0xFF22C55E),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]),
        actions: actions,
        styleInformation: BigTextStyleInformation(
          optionsLine,
          htmlFormatBigText: true,
          contentTitle: '<font color="#22C55E"><b>⚡ $formula = ?</b></font>',
          htmlFormatContentTitle: true,
          summaryText: stageLabel,
        ),
      );
      final details = NotificationDetails(android: androidDetails);
      try {
        await _notificationsPlugin.zonedSchedule(
          id: notifId,
          title: '⏰ $stageLabel: $formula = ?',
          body: optionsLine,
          scheduledDate: scheduledTz,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'persistent|$notifId|$formula|$answer',
        );
      } catch (_) {
        await _notificationsPlugin.zonedSchedule(
          id: notifId,
          title: '⏰ $stageLabel: $formula = ?',
          body: optionsLine,
          scheduledDate: scheduledTz,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'persistent|$notifId|$formula|$answer',
        );
      }
    } catch (e) {
      debugPrint('_scheduleNativeAlarmFor error for $formula: $e');
    }
  }

  // Called whenever user arrives or returns to Home Screen
  // Intentionally a no-op to guarantee zero notifications fire when app is open or opened.
  Future<void> triggerPendingMistakeNotificationOnHome() async {
    // Intentionally empty: Never show or restore notifications on app open or home screen navigation.
  }

  // 1-Hour Scheduled Recall Notification for Past Mistake

  Future<void> schedule1HourRecallNotification({
    required String formula,
    required String correctAnswer,
    int delayMinutes = 30,
  }) async {
    try {
      _ensureTimezonesInitialized();
      final clean = cleanPrompt(formula);
      if (!_isValidMathFormula(clean)) {
        debugPrint('⚠️ Skipping schedule1HourRecallNotification for invalid math: "$clean"');
        return;
      }
      if (_isAdditionOrSubtraction(clean)) {
        debugPrint('🛡️ Skipping 30-Min recall notification for addition/subtraction: "$clean"');
        return;
      }
      String resolvedAnswer = correctAnswer.trim();
      if (!_isCleanComputedAnswer(resolvedAnswer)) {
        resolvedAnswer = _computeFallbackAnswer(clean.isNotEmpty ? clean : resolvedAnswer);
      }
      if (!_isCleanComputedAnswer(resolvedAnswer)) {
        debugPrint('⚠️ Skipping scheduled recall because answer cannot be verified: "$clean"');
        return;
      }
      final int recallNotifId = getNotificationIdForPrompt(clean);

      // Stage 1: 30-min Recall — multiple choice, sticky (can't be swiped away)
      final vibPattern = Int64List.fromList([0, 200, 100, 300, 100, 450]);
      final options = generateRecallOptions(resolvedAnswer, clean);
      final List<String> shuffledChoices = _buildThreeAnswerChoices(options, resolvedAnswer);
      final optionsLine = _buildNotificationOptionsLine(shuffledChoices);
      final notifBody = optionsLine;
      final actions = _buildFourActions(
        formula: clean,
        preShuffledChoices: shuffledChoices,
        correctAnswer: resolvedAnswer,
      );

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prepvanta_animated_recall_v4',
        'PrepVanta Spaced Repetition Recall',
        channelDescription: 'Spaced repetition calculation alerts for mistake revision',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
        enableVibration: true,
        vibrationPattern: vibPattern,
        enableLights: true,
        ledColor: const Color(0xFFEF4444),
        ledOnMs: 1000,
        ledOffMs: 500,
        channelShowBadge: true,
        showWhen: true,
        colorized: false,
        color: const Color(0xFF22C55E),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]), // Cannot be cleared via Clear All
        subText: 'Mistake Recall — Stage 1 of 3',
        actions: actions,
        styleInformation: BigTextStyleInformation(
          notifBody,
          htmlFormatBigText: true,
          contentTitle: '<font color="#22C55E"><b>⚡ 30-Min Recall: $clean = ?</b></font>',
          htmlFormatContentTitle: true,
          summaryText: 'Spaced Repetition Stage 1/3',
        ),
      );

      final details = NotificationDetails(android: androidDetails);

      // PRIMARY: native Android AlarmManager — fires even in Doze mode
      final scheduledTz = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));
      try {
        await _notificationsPlugin.zonedSchedule(
          id: recallNotifId,
          title: '🔴 30-Min Recall: $clean = ?',
          body: notifBody,
          scheduledDate: scheduledTz,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'persistent|$recallNotifId|$clean|$resolvedAnswer',
        );
        debugPrint('✅ Stage-1 (30-min) alarm set for $clean in ${delayMinutes}m');
      } catch (exactErr) {
        debugPrint('⚠️ exactAllowWhileIdle failed ($exactErr), trying inexact');
        try {
          await _notificationsPlugin.zonedSchedule(
            id: recallNotifId,
            title: '🔴 30-Min Recall: $clean = ?',
            body: notifBody,
            scheduledDate: scheduledTz,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: 'persistent|$recallNotifId|$clean|$resolvedAnswer',
          );
          debugPrint('✅ Stage-1 inexact alarm set for $clean in ${delayMinutes}m');
        } catch (inexactErr) {
          debugPrint('❌ Both alarms failed for $clean: $inexactErr');
        }
      }

      _activeReminderTimers[recallNotifId]?.cancel();
      _activeReminderTimers.remove(recallNotifId);
    } catch (e) {
      debugPrint('Error scheduling 30-min recall notification: $e');
    }
  }

  Future<void> scheduleSpacedRecallNotification({
    required String formula,
    required String correctAnswer,
    required int stage,
    int delayMinutes = 180,
  }) async {
    try {
      _ensureTimezonesInitialized();
      final clean = cleanPrompt(formula);
      if (!_isValidMathFormula(clean)) {
        debugPrint('⚠️ Skipping scheduleSpacedRecallNotification for invalid math: "$clean"');
        return;
      }
      if (_isAdditionOrSubtraction(clean)) {
        debugPrint('🛡️ Skipping spaced recall notification for addition/subtraction: "$clean"');
        return;
      }
      String resolvedAnswer = correctAnswer.trim();
      if (!_isCleanComputedAnswer(resolvedAnswer)) {
        resolvedAnswer = _computeFallbackAnswer(clean.isNotEmpty ? clean : resolvedAnswer);
      }
      if (!_isCleanComputedAnswer(resolvedAnswer)) {
        debugPrint('⚠️ Skipping scheduled recall because answer cannot be verified: "$clean"');
        return;
      }
      final int recallNotifId = getNotificationIdForPrompt(clean);

      final stageTag   = getStageTitle(stage);
      final stageEmoji = '🔁';
      final vibPattern = Int64List.fromList([0, 180, 80, 320, 80, 180]);
      final notifBody  = 'Write your answer below or tap Solve Now:';
      final actions    = _buildRevisionActions(
        formula: clean,
        correctAnswer: resolvedAnswer,
      );

      final scheduledRaw = DateTime.now().add(Duration(minutes: delayMinutes));
      final protectedTime = applyQuietHoursGuard(scheduledRaw);
      final scheduledTz = tz.TZDateTime.from(protectedTime, tz.local);

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prepvanta_animated_recall_v4',
        'PrepVanta Spaced Repetition Recall',
        channelDescription: 'Spaced repetition calculation alerts for mistake revision',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
        enableVibration: true,
        vibrationPattern: vibPattern,
        channelShowBadge: true,
        showWhen: true,
        colorized: false,
        color: const Color(0xFF22C55E),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]),
        subText: 'Mistake Recall — Stage $stage/3',
        actions: actions,
        styleInformation: BigTextStyleInformation(
          notifBody,
          htmlFormatBigText: true,
          contentTitle: '<font color="#22C55E"><b>$stageEmoji $stageTag: $clean = ?</b></font>',
          htmlFormatContentTitle: true,
          summaryText: 'Spaced Repetition Stage $stage/3',
        ),
      );

      final details = NotificationDetails(android: androidDetails);
      try {
        await _notificationsPlugin.zonedSchedule(
          id: recallNotifId,
          title: '$stageEmoji $stageTag: $clean = ?',
          body: notifBody,
          scheduledDate: scheduledTz,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'persistent|$recallNotifId|$clean|$resolvedAnswer',
        );
        debugPrint('✅ Stage-$stage alarm set for $clean');
      } catch (exactErr) {
        debugPrint('⚠️ exactAllowWhileIdle failed ($exactErr), trying inexact');
        try {
          await _notificationsPlugin.zonedSchedule(
            id: recallNotifId,
            title: '$stageEmoji $stageTag: $clean = ?',
            body: notifBody,
            scheduledDate: scheduledTz,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: 'persistent|$recallNotifId|$clean|$resolvedAnswer',
          );
        } catch (_) {}
      }

      _activeReminderTimers[recallNotifId]?.cancel();
      _activeReminderTimers.remove(recallNotifId);
    } catch (e) {
      debugPrint('Error scheduling spaced recall notification: $e');
    }
  }


  // Returns the formula of the currently displayed active recall question
  Future<String?> _getActiveQueueFormula() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('currently_displayed_recall_formula');
    } catch (_) {
      return null;
    }
  }


  // Advance the recall queue after a formula is solved
  Future<void> _advanceQueueAfterSolved(String solvedFormula, [String? solvedOption]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> queue = prefs.getStringList('pending_recall_queue') ?? [];
      List<String> unnotified = prefs.getStringList('unnotified_mistakes_list') ?? [];

      queue.removeWhere((e) => cleanPrompt(e.split('|').first) == cleanPrompt(solvedFormula));
      unnotified.removeWhere((e) => cleanPrompt(e.split('|').first) == cleanPrompt(solvedFormula));

      await prefs.setStringList('pending_recall_queue', queue);
      await prefs.setStringList('unnotified_mistakes_list', unnotified);

      if (queue.isNotEmpty) {
        final nextEntry = queue.first;
        final parts = nextEntry.split('|');
        final nextFormula = cleanPrompt(parts.first);
        await prefs.setString('currently_displayed_recall_formula', nextFormula);
      } else {
        await prefs.remove('currently_displayed_recall_formula');
      }
    } catch (e) {
      debugPrint('Error advancing queue: $e');
    }
  }

  // Restore active recalls from queue ONLY when app is not in foreground
  Future<void> restoreActiveRecallsFromQueue() async {
    if (_isAppInForeground) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('pending_recall_queue') ?? [];
      if (queue.isEmpty) return;

      int restoredCount = 0;
      for (int i = 0; i < queue.length; i++) {
        final parts = queue[i].split('|');
        if (parts.length < 2) continue;
        final formula = cleanPrompt(parts.first);
        final answer = parts[1];

        if (_isAdditionOrSubtraction(formula)) continue;
        final bool isSolved = await isCalculationSolved(formula);
        if (isSolved) continue;
        if (isFormulaSnoozed(formula, prefs)) continue;
        if (!_isValidMathFormula(formula)) continue;

        final int recallNotifId = ((formula.hashCode & 0x7FFFFFFF) % 50000) + 100000;
        final int currentStage = prefs.getInt('repetition_stage_$formula') ?? 1;
        final String? dueAtStr = prefs.getString('recall_due_at_$formula');
        if (dueAtStr != null) {
          final dueAt = DateTime.tryParse(dueAtStr);
          if (dueAt != null && DateTime.now().isBefore(dueAt)) continue;
        }

        await showPersistentRecallNotification(
          id: recallNotifId,
          prompt: formula,
          correctAnswer: answer,
          summaryText: 'Mistake ${i + 1} of ${queue.length} in queue',
        );
        restoredCount++;
        if (restoredCount >= 1) break;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('Error restoring recalls: $e');
    }
  }

// NOTIFY CALCULATION MASTERED
Future<void> notifyCalculationMastered({
required String prompt,
required String correctAnswer,
String userName = 'Aspirant',
String? nextPrompt,
String? nextAnswer,
}) async {
String formula = cleanPrompt(prompt);
int notifId = getNotificationIdForPrompt(prompt);
int recallNotifId = ((formula.hashCode & 0x7FFFFFFF) % 50000) + 100000;

// 1. Cancel recurring reminder and clear active recall in prefs
await _markRecallSolvedInPrefs(formula);
await cancelNotification(notifId);
await cancelNotification(recallNotifId);
_activeReminderTimers[recallNotifId]?.cancel();
_activeReminderTimers.remove(recallNotifId);
_activeReminderTimers[notifId]?.cancel();
_activeReminderTimers.remove(notifId);
await _advanceQueueAfterSolved(formula);

// Note: Absolutely NO follow-up notifications sent on correct answer.
// The user requested full silence after solving correctly (no Next Target or celebration spam).
}


// 3. HOURLY CALCULATION RECURRING NOTIFICATION (Native Android Alarm & In-App Timer)
// Ensures student gets a calculation challenge alert every 1 hour, even if app is closed!
Future<void> scheduleHourlyCalculationReminder({String userName = 'Aspirant'}) async {
// Cancel all generic hourly notifications & foreground timers so notifications ONLY fire at exact 30m -> 3hr -> Next Day schedule
_hourlyTimer?.cancel();
_hourlyTimer = null;
try {
await cancelNotification(1111);
await cancelNotification(1112);
await cancelNotification(1114);
} catch (_) {}
}

Future<void> _scheduleNativeHourlyReminders({String userName = 'Aspirant'}) async {}

Future<void> _triggerSmartHourlyChallenge({String userName = 'Aspirant'}) async {}

// Generates a dynamic challenge question based on user's real study progress:
// 1. User's Starred Tables (if any)
// 2. User's Past Mistakes from Notebook (if any)
// 3. Dynamic Calculation Engine (Tables 11â€“30, Multipliers 2â€“12)
Future<Map<String, String>> _generateDynamicChallengeQuestion() async {
final random = Random();
try {
final prefs = await SharedPreferences.getInstance();
// 1. Check if user has starred tables
final List<String>? starred = prefs.getStringList('starred_tables');
if (starred != null && starred.isNotEmpty) {
final validStarred = starred.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
if (validStarred.isNotEmpty) {
final tableNum = validStarred[random.nextInt(validStarred.length)];
final mult = tableMultipliers[random.nextInt(tableMultipliers.length)]; // 2 to 12
return {
'formula': '$tableNum × $mult',
'answer': '${tableNum * mult}',
};
}
}

// 2. Check if user has past mistakes in notebook
final List<String>? mistakeStrings = prefs.getStringList('mistakes_list');
if (mistakeStrings != null && mistakeStrings.isNotEmpty) {
final randomMistake = mistakeStrings[random.nextInt(mistakeStrings.length)];
final map = json.decode(randomMistake);
final prompt = cleanPrompt(map['prompt'] ?? '');
final ans = (map['correctAnswer'] ?? '').toString().trim();
if (prompt.isNotEmpty) {
final realAns = (ans.isNotEmpty && int.tryParse(ans) != null)
? ans
: _computeFallbackAnswer(prompt);
return {
'formula': prompt,
'answer': realAns,
};
}
}
} catch (_) {}

// No random hardcoded multiplication questions — return empty when user has no starred/mistakes
return {'formula': '', 'answer': ''};
}

  /// Dispatches an immediate test notification with 4 interactive options (A, B, C, D Snooze).
  /// Always bypasses foreground suppression so developers and users can instantly verify notifications work.
  Future<void> triggerInstantTestNotification() async {
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}

    await showPersistentRecallNotification(
      id: 9999,
      prompt: '14 × 7',
      correctAnswer: '98',
      bypassForegroundGuard: true,
      summaryText: '🔔 Test Notification — Swipe-proof & Interactive',
    );
  }

  // Instant Hourly Challenge (manual trigger or test)
  Future<void> triggerInstantHourlyChallenge({String userName = 'Aspirant', String? customFormula}) async {
    if (customFormula != null) {
      await showPersistentRecallNotification(
        id: 1111,
        prompt: customFormula,
        correctAnswer: _computeFallbackAnswer(customFormula),
        bypassForegroundGuard: true,
      );
    } else {
      await _triggerSmartHourlyChallenge(userName: userName);
    }
  }


// Instant Mistake Alert (general)
Future<void> triggerMistakeReminder({
required String topicName,
required String detail,
String userName = 'Aspirant',
}) async {
int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
String formula = cleanPrompt(detail);
final answer = await getCorrectAnswerForFormula(formula);

await showPersistentRecallNotification(
id: notificationId,
prompt: formula,
correctAnswer: answer,
);
}

// Disabled hardcoded generic streak spam — cancel any previously scheduled ID 7777
Future<void> scheduleDailyStreakReminder({String userName = 'Aspirant'}) async {
_streakTimer?.cancel();
await cancelNotification(7777);
}

// Admin Broadcast notification
Future<void> triggerAdminBroadcast({required String title, required String body}) async {
await showNotification(
id: 9999,
title: '📢 $title',
body: body,
payload: 'admin_broadcast',
);
}

  // ── DAILY STARRED QUESTIONS PRACTICE (PDF SPECIFICATION SECTION 5) ─────────
  /// Selects up to 5 questions from the user's starred list with fair rotation
  /// and prompts the learner to practice daily. If 0 starred questions, sends nothing.
  Future<void> scheduleDailyStarredPractice({
    List<String>? starredList,
    int preferredHour = 10,
    int preferredMinute = 0,
  }) async {
    try {
      _ensureTimezonesInitialized();
      final prefs = await SharedPreferences.getInstance();
      final list = starredList ??
          prefs.getStringList('starred_questions') ??
          prefs.getStringList('starred_tables') ??
          [];
      if (list.isEmpty) {
        await cancelNotification(55000);
        return;
      }

      final int offset = prefs.getInt('starred_daily_rotation_offset') ?? 0;
      final int count = list.length < 5 ? list.length : 5;
      final List<String> selected = [];
      for (int i = 0; i < count; i++) {
        selected.add(list[(offset + i) % list.length]);
      }
      await prefs.setInt('starred_daily_rotation_offset', (offset + count) % list.length);

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, preferredHour, preferredMinute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      final scheduledTz = tz.TZDateTime.from(applyQuietHoursGuard(scheduledDate), tz.local);

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'math_starred_tables_v2',
        'Starred Questions Daily Practice',
        channelDescription: 'Daily revision drills for your bookmarked & starred questions',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
        enableVibration: true,
        channelShowBadge: true,
        showWhen: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      );

      await _notificationsPlugin.zonedSchedule(
        id: 55000,
        title: '⭐ Daily Starred Questions Practice',
        body: 'You have ${selected.length} bookmarked question(s) ready for daily practice!',
        scheduledDate: scheduledTz,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'starred_practice',
      );
    } catch (e) {
      debugPrint('Error scheduling daily starred practice: $e');
    }
  }

  // Standard competitive exam multipliers for Table Practice (2 to 12)
static const List<int> tableMultipliers = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

// 🌟 3.5 STARRED TABLE REVISION NOTIFICATIONS (Spaced Repetition: 1 Hr âž” +3 Hrs âž” +3 Hrs)
// Ensures student gets calculation questions cycling through multipliers of the starred table(s)
// with ZERO immediate disturbance, first drill at 1-hour, then spaced reinforcement at 3-hour intervals.
Future<void> scheduleStarredTableNotification(int tableNumber, {bool onlyIfNotScheduled = false}) async {
try {
if (onlyIfNotScheduled) {
  final prefs = await SharedPreferences.getInstance();
  final activeFormula = prefs.getString('active_starred_table_formula');
  if (activeFormula != null && activeFormula.isNotEmpty) {
    final dueStr = prefs.getString('recall_due_at_$activeFormula');
    final dueAt = dueStr != null ? DateTime.tryParse(dueStr) : null;
    if (dueAt != null && DateTime.now().isBefore(dueAt)) {
      debugPrint('⭐ Starred table alarm already scheduled for $dueAt — preserving exact timing on app open.');
      return;
    }
  }
}
// 1. Cancel previous starred table timers & notifications
_starredTablePeriodicTimer?.cancel();
for (int id = 55000; id <= 55025; id++) {
await cancelNotification(id);
}
// Cancel generic hourly notification (1111) so it never clashes with starred table alerts!
await cancelNotification(1111);

// Save tableNumber in SharedPreferences
try {
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('active_starred_table_number', tableNumber);
} catch (_) {}

// 2. Schedule first question after 1 hour (60 minutes) - Stage 1 (NO immediate popup!)
await _scheduleStarredTableSpaced(tableNumber, delayMinutes: 30, stage: 1);
debugPrint('⭐ Starred Table $tableNumber first spaced drill scheduled in 1 hour (Zero immediate notification)');
} catch (e) {
debugPrint('Error scheduling starred table notification: $e');
}
}

Future<void> _scheduleStarredTableSpaced(int tableNumber, {int delayMinutes = 30, int stage = 1}) async {
try {
_ensureTimezonesInitialized();
final prefs = await SharedPreferences.getInstance();
final multKey = 'starred_table_${tableNumber}_next_mult_idx';
int nextMultIdx = prefs.getInt(multKey) ?? 0;
if (nextMultIdx >= tableMultipliers.length) {
nextMultIdx = 0;
await prefs.setInt(multKey, 0);
}
final m = tableMultipliers[nextMultIdx];
final formula = '$tableNumber × $m';
final correctAnswer = '${tableNumber * m}';

await prefs.setInt('repetition_stage_$formula', stage);
final dueAt = DateTime.now().add(Duration(minutes: delayMinutes));
await prefs.setString('recall_due_at_$formula', dueAt.toIso8601String());
await prefs.setString('active_starred_table_formula', formula);


final notifId = 55000;
final options = generateRecallOptions(correctAnswer, formula);
final shuffledChoices = _buildThreeAnswerChoices(options, correctAnswer);
final optionsLine = _buildNotificationOptionsLine(shuffledChoices);

final stageTag = stage == 1
? 'Table $tableNumber: 1-Hr Spaced Drill'
: (stage == 2 ? 'Table $tableNumber: 3-Hr Spaced Drill' : 'Table $tableNumber: Retention Check');

final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
'math_starred_tables_v2',
'Starred Table Revision Alerts',
channelDescription: 'Direct calculation questions for bookmarked & starred tables',
importance: Importance.max,
priority: Priority.max,
ongoing: true,
autoCancel: false,
playSound: true,
sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
enableVibration: true,
colorized: false,
color: const Color(0xFF22C55E),
category: AndroidNotificationCategory.reminder,
actions: _buildFourActions(
formula: formula,
preShuffledChoices: shuffledChoices,
correctAnswer: correctAnswer,
),
styleInformation: BigTextStyleInformation(
optionsLine,
htmlFormatBigText: true,
contentTitle: '<font color="#22C55E"><b>⭐ $formula = ?</b></font>',
htmlFormatContentTitle: true,
summaryText: stageTag,
),
);

final details = NotificationDetails(android: androidDetails);
final scheduledTz = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));

try {
await _notificationsPlugin.zonedSchedule(
id: notifId,
title: '$formula = ?',
body: 'Tap the correct answer below:',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
payload: 'persistent|$notifId|$formula|$correctAnswer',
);
} catch (_) {
try {
await _notificationsPlugin.zonedSchedule(
id: notifId,
title: '$formula = ?',
body: 'Tap the correct answer below:',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
payload: 'persistent|$notifId|$formula|$correctAnswer',
);
} catch (_) {}
}

_activeReminderTimers[notifId]?.cancel();
_activeReminderTimers[notifId] = Timer(Duration(minutes: delayMinutes), () async {
if (_isAppInForeground) return;
final isSolved = await isCalculationSolved(formula);
if (!isSolved) {
await _triggerSingleStarredTableQuestion(tableNumber: tableNumber, notifId: notifId, customMultiplier: m);
}
});
} catch (e) {
debugPrint('Error in _scheduleStarredTableSpaced: $e');
}
}

/// Triggers the next multiplier question of the starred table in sequential order.
/// When user solves 23 × 2, this sends 23 × 3, then 23 × 4, ... through 23 × 12.
/// If user starred multiple tables (e.g. 23 & 29), advances to next table when one completes!
Future<void> triggerNextStarredTableQuestion({int notifId = 55000}) async {
try {
final prefs = await SharedPreferences.getInstance();
final List<String>? starred = prefs.getStringList('starred_tables');
final validStarred = (starred ?? []).map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();

if (validStarred.isEmpty) {
await cancelNotification(notifId);
return;
}

int currentTable = prefs.getInt('active_starred_table_number') ?? validStarred.first;
if (!validStarred.contains(currentTable)) {
currentTable = validStarred.first;
}

final multKey = 'starred_table_${currentTable}_next_mult_idx';
int nextMultIdx = prefs.getInt(multKey) ?? 0;

// If user has completed all multipliers for currentTable (2 to 12):
if (nextMultIdx >= tableMultipliers.length) {
nextMultIdx = 0;
await prefs.setInt(multKey, 0);

// Advance to next starred table if multiple tables are starred
if (validStarred.length > 1) {
int tableIdx = validStarred.indexOf(currentTable);
int nextTableIdx = (tableIdx + 1) % validStarred.length;
currentTable = validStarred[nextTableIdx];
await prefs.setInt('active_starred_table_number', currentTable);
}
}

final m = tableMultipliers[nextMultIdx];
// Increment index for the next question
await prefs.setInt(multKey, nextMultIdx + 1);

await _triggerSingleStarredTableQuestion(
tableNumber: currentTable,
notifId: notifId,
customMultiplier: m,
);
} catch (e) {
debugPrint('Error triggering next starred table question: $e');
}
}

Future<void> _triggerSingleStarredTableQuestion({
required int tableNumber,
required int notifId,
int? customMultiplier,
}) async {
if (_isAppInForeground) {
  debugPrint('🛡️ App is in foreground: suppressing starred table question');
  return;
}
try {
final m = customMultiplier ?? tableMultipliers[Random().nextInt(tableMultipliers.length)];
final formula = '$tableNumber × $m';
final correctAnswer = '${tableNumber * m}';

try {
final prefs = await SharedPreferences.getInstance();
await prefs.setString('active_starred_table_formula', formula);
} catch (_) {}

if (await hasReachedDailyNotificationLimit()) {
debugPrint('Daily notification limit reached for today. Suppressing starred table alert.');
return;
}

final options = generateRecallOptions(correctAnswer, formula);
final shuffledChoices = _buildThreeAnswerChoices(options, correctAnswer);
final String optionsLine = _buildNotificationOptionsLine(shuffledChoices);

final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
optionsLine,
htmlFormatBigText: true,
contentTitle: '<font color="#22C55E"><b>⭐ Table $tableNumber: $formula = ?</b></font>',
htmlFormatContentTitle: true,
);

final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
'math_starred_tables_v2',
'Starred Table Revision Alerts',
channelDescription: 'Direct calculation questions for bookmarked & starred tables',
importance: Importance.max,
priority: Priority.max,
ongoing: true,
autoCancel: false,
playSound: true,
sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
enableVibration: true,
colorized: false,
color: const Color(0xFF22C55E),
styleInformation: bigTextStyle,
category: AndroidNotificationCategory.reminder,
actions: _buildFourActions(
formula: formula,
preShuffledChoices: shuffledChoices,
correctAnswer: correctAnswer,
),
);

final NotificationDetails details = NotificationDetails(android: androidDetails);

await _notificationsPlugin.show(
id: notifId,
title: '$formula = ?',
body: 'Tap the correct answer below:',
notificationDetails: details,
payload: 'persistent|$notifId|$formula|$correctAnswer',
);
await incrementDailyNotificationCount();

await _markRecallActiveInPrefs(formula, correctAnswer, notifId);
} catch (e) {
debugPrint('Error triggering single starred table question: $e');
}
}

Future<void> cancelStarredTableNotification(int tableNumber) async {
try {
_starredTablePeriodicTimer?.cancel();
for (int id = 55000; id <= 55025; id++) {
await cancelNotification(id);
}
try {
final prefs = await SharedPreferences.getInstance();
final activeFormula = prefs.getString('active_starred_table_formula');
if (activeFormula != null) {
await _markRecallSolvedInPrefs(activeFormula);
await prefs.remove('active_starred_table_formula');
}
await prefs.remove('active_starred_table_number');
} catch (_) {}
} catch (e) {
debugPrint('Error canceling starred table notification: $e');
}
}

// =========================================================================
// 🌟 3.6 3-DAY SPACED RETENTION TABLE RECALL NOTIFICATION (Ideas 1 + 3)
// Ensures that whenever student reads or practices ANY table (e.g. Table of 24),
// a single, interactive, high-retention recall question fires in 3 days.
// =========================================================================
Future<void> schedule3DayTableRecallNotification(int tableNumber) async {
try {
_ensureTimezonesInitialized();
final notifId = 60000 + tableNumber;
await cancelNotification(notifId);

// Randomly pick a challenging multiplier to test (3, 4, 6, 7, 8, 9)
final challengingMultipliers = [3, 4, 6, 7, 8, 9];
final m = challengingMultipliers[(DateTime.now().millisecond + tableNumber) % challengingMultipliers.length];
final formula = '$tableNumber × $m';
final correctAnswer = '${tableNumber * m}';

final prefs = await SharedPreferences.getInstance();
await prefs.setString('table_3day_formula_$tableNumber', formula);
await prefs.setString('table_3day_due_$tableNumber', DateTime.now().add(const Duration(days: 3)).toIso8601String());

final options = generateRecallOptions(correctAnswer, formula);
final shuffledChoices = _buildThreeAnswerChoices(options, correctAnswer);
final optionsLine = _buildNotificationOptionsLine(shuffledChoices);

final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
'math_starred_tables_v2',
'3-Day Table Spaced Recall',
channelDescription: '3-Day interval retention challenge for practiced tables',
importance: Importance.max,
priority: Priority.max,
ongoing: true,
autoCancel: false,
playSound: true,
sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
enableVibration: true,
colorized: false,
color: const Color(0xFF22C55E),
category: AndroidNotificationCategory.reminder,
actions: _buildFourActions(
formula: formula,
preShuffledChoices: shuffledChoices,
correctAnswer: correctAnswer,
),
styleInformation: BigTextStyleInformation(
'⚡ 3-Day Retention Check: $formula = ?\n$optionsLine',
htmlFormatBigText: true,
contentTitle: '<font color="#22C55E"><b>🧠 Table of $tableNumber: $formula = ?</b></font>',
htmlFormatContentTitle: true,
summaryText: '3-Day Retention Alert',
),
);

final details = NotificationDetails(android: androidDetails);
// Fires in 3 days (72 hours)
final scheduledTz = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));

try {
await _notificationsPlugin.zonedSchedule(
id: notifId,
title: '🧠  Table of $tableNumber: $formula = ?',
body: 'Tap the correct answer below to keep your memory 100%:',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
payload: 'persistent|$notifId|$formula|$correctAnswer',
);
} catch (_) {
try {
await _notificationsPlugin.zonedSchedule(
id: notifId,
title: '🧠  Table of $tableNumber: $formula = ?',
body: 'Tap the correct answer below to keep your memory 100%:',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
payload: 'persistent|$notifId|$formula|$correctAnswer',
);
} catch (_) {}
}
debugPrint('📅 Scheduled 3-day spaced recall for Table $tableNumber ($formula) in 3 days.');
} catch (e) {
debugPrint('Error scheduling 3-day table recall: $e');
}
}

// Disabled unsolicited browse nudge spam (user directive: no hardcoded/random nudges)
Future<void> scheduleBrowsedTopicNudge({
required String topicId,
required String topicTitle,
String? sampleQuestion,
String userName = 'Aspirant',
}) async {
return;
}

// 5. DIRECT QUESTION IN NOTIFICATION
Future<void> triggerDirectQuestionFlashcardNotification({
required String prompt,
String? topicTitle,
String userName = 'Aspirant',
}) async {
String formula = cleanPrompt(prompt);
int flashId = 5500 + (formula.hashCode.abs() % 1000);
final ans = await getCorrectAnswerForFormula(formula);
final opts = generateRecallOptions(ans, formula);
await showNotification(
id: flashId,
title: '$formula = ?',
body: '(A) ${opts[0]}   (B) ${opts[1]}   (C) ${opts[2]}',
payload: 'flashcard:$formula',
);
}

// Disabled hardcoded generic topic recommendation spam — cancel any previously scheduled ID 6600
Future<void> scheduleDailySmartTopicRecommendation({
required String recommendedTopic,
String userName = 'Aspirant',
}) async {
_recommendationTimer?.cancel();
await cancelNotification(6600);
}

// 7. TOMORROW'S SCHEDULED STUDY PLAN REMINDER LOOP
// When student plans to learn a topic tomorrow (e.g. Table of 17 at 9:00 AM),
// this triggers at that scheduled time tomorrow and keeps reminding until completed!
Future<void> scheduleStudyPlanReminder({
required StudyPlanModel plan,
String userName = 'Aspirant',
}) async {
_studyPlanTimer?.cancel();
_studyPlanRecurringTimer?.cancel();

DateTime now = DateTime.now();
int delayMs = plan.scheduledDate.difference(now).inMilliseconds;

void triggerPlanAlerts() async {
if (_isAppInForeground) return;
if (plan.topicTitle.trim().isEmpty) return;
final qPart = plan.sampleQuestion.trim().isNotEmpty ? ' Quick check: ${plan.sampleQuestion}' : '';
await showNotification(
id: 3300,
title: '🎯 Target Time: ${plan.topicTitle}!',
body: 'Practice session scheduled for ${plan.topicTitle}.$qPart',
payload: 'study_plan:${plan.topicId}',
);

// Persistent reminder every 45 minutes until completed (only when app is backgrounded)
_studyPlanRecurringTimer?.cancel();
_studyPlanRecurringTimer = Timer.periodic(const Duration(minutes: 45), (_) async {
if (_isAppInForeground) return;
await showNotification(
id: 3300,
title: '🎯 Study Reminder: ${plan.topicTitle}',
body: 'Complete your planned practice for ${plan.topicTitle}.$qPart',
payload: 'study_plan:${plan.topicId}',
);
});
}

if (delayMs <= 0) {
// Already passed while user was away — do NOT fire notification on app open!
return;
} else {
// Scheduled for tomorrow (or later today)
_studyPlanTimer = Timer(Duration(milliseconds: delayMs), () {
triggerPlanAlerts();
});
}
}

  Future<void> cancelStudyPlanReminder() async {
    _studyPlanTimer?.cancel();
    _studyPlanRecurringTimer?.cancel();
    await cancelNotification(3300);
  }

  /// Schedules spaced native reminders across ALL core concepts for Addition,
  /// Subtraction, or Division when requested from Learn Mode.
  Future<int> scheduleTopicConceptReminders(TopicType topicType) async {
    final List<Map<String, String>> concepts;
    final int baseId;
    final String topicName;

    switch (topicType) {
      case TopicType.addition:
        baseId = 64100;
        topicName = 'Speed Addition';
        concepts = const [
          {'concept': 'Split & Merge (Left-to-Right)', 'q': '68 + 57', 'a': '125'},
          {'concept': 'Friend Number (Base-10 Rounding)', 'q': '89 + 46', 'a': '135'},
          {'concept': 'Complementary 100s Pairing', 'q': '28 + 72 + 34 + 66', 'a': '200'},
          {'concept': '10 Consecutive Numbers Sum', 'q': '41 + 42 + ... + 50', 'a': '455'},
          {'concept': 'Decimal Equalizer Balancing', 'q': '4.7 + 0.38', 'a': '5.08'},
          {'concept': '3-Digit Chunking Method', 'q': '348 + 526', 'a': '874'},
        ];
        break;
      case TopicType.subtraction:
        baseId = 64200;
        topicName = 'Speed Subtraction';
        concepts = const [
          {'concept': 'Nikhilam (All from 9, Last from 10)', 'q': '10000 - 3648', 'a': '6352'},
          {'concept': '2-Digit Reverse Rule (AB - BA)', 'q': '83 - 38', 'a': '45'},
          {'concept': '3-Digit Reverse Rule (ABC - CBA)', 'q': '752 - 257', 'a': '495'},
          {'concept': 'Constant Difference Rule', 'q': '84 - 39', 'a': '45'},
          {'concept': 'Shopkeeper Step-Up Method', 'q': '143 - 88', 'a': '55'},
          {'concept': 'Left-to-Right Staged Subtraction', 'q': '642 - 275', 'a': '367'},
        ];
        break;
      case TopicType.division:
        baseId = 64300;
        topicName = 'Speed Division';
        concepts = const [
          {'concept': 'Division by 5 (Double & Shift)', 'q': '312 ÷ 5', 'a': '62.4'},
          {'concept': 'Division by 25 (×4 & Shift 2)', 'q': '450 ÷ 25', 'a': '18'},
          {'concept': 'Division by 125 (×8 & Shift 3)', 'q': '350 ÷ 125', 'a': '2.8'},
          {'concept': 'Nikhilam Division by 9', 'q': '126 ÷ 9', 'a': '14'},
          {'concept': 'Double & Divide by 100 (÷ 50)', 'q': '750 ÷ 50', 'a': '15'},
          {'concept': 'Proportional Approximation', 'q': '4850 ÷ 20', 'a': '242.5'},
        ];
        break;
      default:
        return 0;
    }

    try {
      final nowTz = tz.TZDateTime.now(tz.local);
      for (int i = 0; i < concepts.length; i++) {
        final c = concepts[i];
        final delayMinutes = 30 + (i * 150);
        final scheduledTz = nowTz.add(Duration(minutes: delayMinutes));
        final int notifId = baseId + i;
        final String formula = c['q']!;
        final String answer = c['a']!;
        final String conceptLabel = c['concept']!;

        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'prepvanta_concept_reminders',
          'Topic Concept Reminders',
          channelDescription: 'Spaced reminders covering every trick concept in Addition, Subtraction & Division',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('custom_notification_sound'),
          enableVibration: true,
          visibility: NotificationVisibility.public,
        );
        const details = NotificationDetails(android: androidDetails);

        try {
          await _notificationsPlugin.zonedSchedule(
            id: notifId,
            title: '🧠 $topicName: $conceptLabel',
            body: 'Quick recall: $formula = ? (Tap to solve & lock in)',
            scheduledDate: scheduledTz,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: 'persistent|$notifId|$formula|$answer',
          );
        } catch (_) {
          await _notificationsPlugin.zonedSchedule(
            id: notifId,
            title: '🧠 $topicName: $conceptLabel',
            body: 'Quick recall: $formula = ? (Tap to solve & lock in)',
            scheduledDate: scheduledTz,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: 'persistent|$notifId|$formula|$answer',
          );
        }
      }
      return concepts.length;
    } catch (e) {
      debugPrint('scheduleTopicConceptReminders error: $e');
      return 0;
    }
  }

// Schedule Math Wake-Up Alarm ("Solve 5 mistakes to dismiss alarm")
Future<void> scheduleMathWakeUpAlarm({
required int hour,
required int minute,
required String label,
}) async {
_mathAlarmTimer?.cancel();
await cancelNotification(7777);

final now = DateTime.now();
DateTime alarmTarget = DateTime(now.year, now.month, now.day, hour, minute);
if (alarmTarget.isBefore(now)) {
alarmTarget = alarmTarget.add(const Duration(days: 1));
}
final delay = alarmTarget.difference(now);

// 1. In-memory timer fallback if app is active in foreground
_mathAlarmTimer = Timer(delay, () async {
await triggerMathAlarmNotification(label: label);
});

// 2. Native OS exact scheduled alarm that rings even when phone is locked or app is closed!
try {
_ensureTimezonesInitialized();
// GUARANTEED EXACT: Take tz.local now and add the exact delay difference!
final scheduledTz = tz.TZDateTime.now(tz.local).add(delay);

final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
'math_alarm_channel_v5',
'Math Wake-Up Alarm (Emergency Siren)',
channelDescription: 'High priority loud alarm siren ringing until math questions are answered',
importance: Importance.max,
priority: Priority.max,
fullScreenIntent: true,
category: AndroidNotificationCategory.alarm,
audioAttributesUsage: AudioAttributesUsage.alarm,
ongoing: true,
autoCancel: false,
visibility: NotificationVisibility.public,
showWhen: true,
playSound: true,
sound: const RawResourceAndroidNotificationSound('alarm_siren'),
enableVibration: true,
additionalFlags: Int32List.fromList([4]),
);

final NotificationDetails details = NotificationDetails(android: androidDetails);

try {
await _notificationsPlugin.zonedSchedule(
id: 7777,
title: '⏰ $label (RINGING NOW!)',
body: '🚨 Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
payload: 'math_alarm_ringing',
);
debugPrint('Native Alarm Scheduled at: $scheduledTz (in ${delay.inMinutes} mins / ${delay.inSeconds}s)');
} catch (exactErr) {
debugPrint('Exact alarm failed, scheduling with inexactAllowWhileIdle: $exactErr');
await _notificationsPlugin.zonedSchedule(
id: 7777,
title: '⏰ $label (RINGING NOW!)',
body: '🚨 Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
payload: 'math_alarm_ringing',
);
}
} catch (e) {
debugPrint('ZonedSchedule alarm error: $e');
}
}

// Quick Test Alarm (fires in N seconds to immediately test native exact ring & question flow)
Future<void> scheduleQuickTestAlarm({
int seconds = 10,
String label = 'Math Wake-Up Test Alarm',
}) async {
_mathAlarmTimer?.cancel();
await cancelNotification(7777);


// In-memory fallback
_mathAlarmTimer = Timer(Duration(seconds: seconds), () async {
await triggerMathAlarmNotification(label: label);
});

try {
_ensureTimezonesInitialized();
final scheduledTz = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
'math_alarm_channel_v5',
'Math Wake-Up Alarm (Emergency Siren)',
channelDescription: 'High priority loud alarm siren ringing until math questions are answered',
importance: Importance.max,
priority: Priority.max,
fullScreenIntent: true,
category: AndroidNotificationCategory.alarm,
audioAttributesUsage: AudioAttributesUsage.alarm,
ongoing: true,
autoCancel: false,
visibility: NotificationVisibility.public,
showWhen: true,
playSound: true,
sound: const RawResourceAndroidNotificationSound('alarm_siren'),
enableVibration: true,
additionalFlags: Int32List.fromList([4]),
);

final NotificationDetails details = NotificationDetails(android: androidDetails);

try {
await _notificationsPlugin.zonedSchedule(
id: 7777,
title: '⏰ $label (RINGING NOW!)',
body: '🚨 Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
payload: 'math_alarm_ringing',
);
debugPrint('Native quick test alarm scheduled in $seconds seconds at $scheduledTz');
} catch (exactErr) {
debugPrint('Exact quick test failed, falling back to inexactAllowWhileIdle: $exactErr');
await _notificationsPlugin.zonedSchedule(
id: 7777,
title: '⏰ $label (RINGING NOW!)',
body: '🚨 Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
scheduledDate: scheduledTz,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
payload: 'math_alarm_ringing',
);
}
} catch (e) {
debugPrint('Native quick test zonedSchedule note: $e');
}
}

Future<void> cancelMathWakeUpAlarm() async {
_mathAlarmTimer?.cancel();
await cancelNotification(7777);
}

Future<void> triggerMathAlarmNotification({String label = 'Math Wake-Up Alarm'}) async {
try {
final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
'math_alarm_channel_v5',
'Math Wake-Up Alarm (Emergency Siren)',
channelDescription: 'High priority loud alarm siren ringing until math questions are answered',
importance: Importance.max,
priority: Priority.max,
fullScreenIntent: true,
category: AndroidNotificationCategory.alarm,
audioAttributesUsage: AudioAttributesUsage.alarm,
ongoing: true,
autoCancel: false,
playSound: true,
sound: const RawResourceAndroidNotificationSound('alarm_siren'),
enableVibration: true,
additionalFlags: Int32List.fromList([4]),
);

final NotificationDetails details = NotificationDetails(android: androidDetails);

await _notificationsPlugin.show(
id: 7777,
title: '⏰ $label (RINGING NOW!)',
body: '🚨 Solve 5 of your past mistake questions (2 choices) to turn off the alarm!',
notificationDetails: details,
payload: 'math_alarm_ringing',
);

// Directly open MathAlarmRingingScreen with full sound & siren!
final nav = navigatorKey.currentState;
if (nav != null) {
nav.push(MaterialPageRoute(builder: (_) => const MathAlarmRingingScreen()));
}
} catch (e) {
debugPrint('Math alarm notification error: $e');
}
}

  void cancelAllTimers() {
    _studyPlanTimer?.cancel();
    _studyPlanRecurringTimer?.cancel();
    _streakTimer?.cancel();
    _recommendationTimer?.cancel();
    _hourlyTimer?.cancel();
    _starredTablePeriodicTimer?.cancel();
    for (var t in _activeReminderTimers.values) {
      t.cancel();
    }
    _activeReminderTimers.clear();
  }
}
