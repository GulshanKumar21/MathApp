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
  /// Plays custom notification chime for in-app / foreground heads-up alerts
  Future<void> playNotificationSound() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/custom_notification_sound.mp3'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (_) {}
  }

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
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
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(recallChannel);

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

      // If user has active starred tables, cancel any old generic hourly challenge (id 1111)
      try {
        final prefs = await SharedPreferences.getInstance();
        final List<String>? starred = prefs.getStringList('starred_tables');
        if (starred != null && starred.isNotEmpty) {
          await cancelNotification(1111);
        }
      } catch (_) {}

      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification init warning: $e');
    }
  }

  bool _isSolveOrSnoozeDialogShowing = false;

  void handleNotificationPayload(String payload) {
    debugPrint('Handling notification payload: $payload');
    final nav = navigatorKey.currentState;
    if (nav == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationPayload(payload);
      });
      return;
    }

    if (payload.startsWith('persistent|')) {
      final parts = payload.split('|');
      final notifId = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final formula = parts.length > 2 ? parts[2] : '';
      final correctAnswer = parts.length > 3 ? parts[3] : '';
      if (formula.isNotEmpty) {
        _showInAppSolveOrSnoozeDialog(
          nav.context,
          formula: formula,
          correctAnswer: correctAnswer,
          notifId: notifId,
        );
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
            final notifId = getNotificationIdForPrompt(clean);
            _showInAppSolveOrSnoozeDialog(
              ctx,
              formula: clean,
              correctAnswer: ans,
              notifId: notifId,
            );
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

  OverlayEntry? _activeBannerEntry;

  void _showInAppAnimatedHeadsUpBanner({
    required String formula,
    required String correctAnswer,
    required int notifId,
    required List<String> choices,
    required int stage,
  }) {
    try {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay == null) return;

      _activeBannerEntry?.remove();
      _activeBannerEntry = null;

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) => _AnimatedHeadsUpBannerWidget(
          formula: formula,
          correctAnswer: correctAnswer,
          notifId: notifId,
          choices: choices,
          stage: stage,
          onDismiss: () {
            entry.remove();
            if (_activeBannerEntry == entry) _activeBannerEntry = null;
          },
          onAnswer: (choice) async {
            entry.remove();
            if (_activeBannerEntry == entry) _activeBannerEntry = null;
            await handleNotificationAnswerAction('ans|$formula|$choice|$correctAnswer', notifId);
          },
          onSnooze: () async {
            entry.remove();
            if (_activeBannerEntry == entry) _activeBannerEntry = null;
            await handleSnoozeAction('snooze|$formula|$correctAnswer', notifId);
          },
          onTapBody: () {
            entry.remove();
            if (_activeBannerEntry == entry) _activeBannerEntry = null;
            final ctx = navigatorKey.currentContext;
            if (ctx != null) {
              _showInAppSolveOrSnoozeDialog(
                ctx,
                formula: formula,
                correctAnswer: correctAnswer,
                notifId: notifId,
              );
            }
          },
        ),
      );

      _activeBannerEntry = entry;
      overlay.insert(entry);
    } catch (e) {
      debugPrint('Error showing in-app banner: $e');
    }
  }

  Future<void> _showInAppSolveOrSnoozeDialog(
    BuildContext context, {
    required String formula,
    required String correctAnswer,
    required int notifId,
  }) async {
    if (_isSolveOrSnoozeDialogShowing) return;
    _isSolveOrSnoozeDialogShowing = true;

    final clean = cleanPrompt(formula);
    String resolvedAnswer = correctAnswer.trim();
    if (int.tryParse(resolvedAnswer) == null || resolvedAnswer.contains(RegExp(r'[\u00d7\*xX\+\-\u2212\u00f7/\^\u00b2\u00b3]'))) {
      resolvedAnswer = _computeFallbackAnswer(clean);
    }
    final options = generateRecallOptions(resolvedAnswer, clean);
    final choices = _buildThreeAnswerChoices(options, resolvedAnswer);

    try {
      await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Math Challenge',
        barrierColor: Colors.black.withValues(alpha: 0.65),
        transitionDuration: const Duration(milliseconds: 320),
        transitionBuilder: (ctx, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
          return BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 8.0 * animation.value,
              sigmaY: 8.0 * animation.value,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
            ),
          );
        },
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return _InAppChallengeDialog(
            clean: clean,
            choices: choices,
            resolvedAnswer: resolvedAnswer,
            notifId: notifId,
            onAnswer: (choice) async {
              await handleNotificationAnswerAction('ans|$clean|$choice|$resolvedAnswer', notifId);
              final isCorrect = choice.trim().toLowerCase() == resolvedAnswer.trim().toLowerCase();
              if (context.mounted && isCorrect) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🎉 Solved! "$clean = $resolvedAnswer" mastered!',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.5)),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            onSnooze: () async {
              await handleSnoozeAction('snooze|$clean|$resolvedAnswer', notifId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.alarm_on_rounded, color: AppTheme.gold, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '💤 Snoozed "$clean" until tomorrow morning (9:00 AM)',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.surfaceElevated,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          );
        },
      );
    } finally {
      _isSolveOrSnoozeDialogShowing = false;
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

  /// Returns true if the formula is a valid math expression (not English text/empty)
  bool _isValidMathFormula(String formula) {
    if (formula.trim().isEmpty) return false;
    final clean = cleanPrompt(formula);
    if (clean.trim().isEmpty) return false;
    // Must contain at least one digit
    if (!RegExp(r'\d').hasMatch(clean)) return false;
    // Must NOT contain English words (2 or more consecutive alphabet letters)
    if (RegExp(r'[a-zA-Z]{2,}').hasMatch(clean)) return false;
    // Must match valid math expression: digits, operators, powers, decimals
    return RegExp(r'^[\d\s×\*\+\-−÷/\^²³\.%()]+$').hasMatch(clean);
  }

  // Helper to normalize calculation prompts (e.g., "⏰ 1-Hour Recall Alert: 23 × 7 = ?" -> "23 × 7")
  String cleanPrompt(String prompt) {
    String p = prompt
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
    // If there's a colon from some prefix, take what's after the colon
    if (p.contains(':')) {
      p = p.split(':').last.trim();
    }
    // Standardize multiplication symbols to ' × '
    p = p.replaceAll(RegExp(r'\s*[\*xX\u00D7\u2715\u2716]\s*'), ' × ');
    // Standardize addition, subtraction, division spacing
    p = p.replaceAll(RegExp(r'\s*\+\s*'), ' + ');
    p = p.replaceAll(RegExp(r'\s*[\-−\u2212]\s*'), ' - ');
    p = p.replaceAll(RegExp(r'\s*[Ã·/\u00F7]\s*'), ' Ã· ');
    // Collapse any multiple consecutive spaces
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
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Could not cancel all notifications: $e');
    }
  }

  // Display an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'math_speed_channel_v2',
        'PrepVanta',
        channelDescription: 'Calculation drills, daily streaks, and mistake revision alerts',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('custom_notification_sound'),
        channelShowBadge: true,
        showWhen: true,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

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
    if (correctNum == null || cleanCorrect.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
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
      // Fraction percentage question (e.g. 14.28%)
      final cleanVal = cleanCorrect.replaceAll('%', '').trim();
      final double? pct = double.tryParse(cleanVal);
      if (pct != null) {
        opts.add('${(pct + 2.38).toStringAsFixed(2)}%');
        opts.add('${(pct - 1.78).abs().toStringAsFixed(2)}%');
      }
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
  }) async {
    // Note: Mistake recall alerts are critical spaced learning reviews and must NEVER be suppressed by daily frequency limits!
    String formula = cleanPrompt(prompt);
    // ðŸ›¡ï¸ Filter out any malformed / non-math questions
    if (!_isValidMathFormula(formula)) {
      debugPrint('âš ï¸ Refusing persistent notification for invalid math: "$formula" (original: "$prompt")');
      return;
    }
    // ðŸ›¡ï¸ User directive: No notifications for addition or subtraction
    if (_isAdditionOrSubtraction(formula)) {
      debugPrint('ðŸ›¡ï¸ Refusing notification for addition/subtraction: "$formula"');
      return;
    }
    await _markRecallUnsolvedInPrefs(formula);
    String resolvedAnswer = correctAnswer.trim();
    if (int.tryParse(resolvedAnswer) == null || resolvedAnswer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
      resolvedAnswer = _computeFallbackAnswer(formula.isNotEmpty ? formula : resolvedAnswer);
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
    );

    // NOTE: No short watchdog timer here â€” ongoing: true + FLAG_NO_CLEAR prevent swipe-away natively.
    // A 1-hour re-post timer is set separately by scheduleCalculationMistakeReminder.
    // We only need to cancel any existing watchdog for this id (clean up from previous calls).
    _activeReminderTimers[id]?.cancel();
    _activeReminderTimers.remove(id);
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
    return '(A) $c0   (B) $c1\n(C) $c2   (D) ⏰ Snooze';
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
      AndroidNotificationAction(
        'snooze|$formula|$correctAnswer',
        '(D) ⏰ Snooze',
        cancelNotification: true,
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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int currentStage = prefs.getInt('repetition_stage_$formula') ?? 1;

    final String stageName = currentStage == 1
        ? '🔴 30-Min Recall'
        : (currentStage == 2 ? '🟠 4-Hour Reinforcement' : '🟢 Next-Day Retention');

    final String displayTitle = wrongAttempt != null
        ? '❌ Galat! $formula = ?'
        : '$stageName: $formula = ?';

    // Generate shuffled choices ONCE so body text and action buttons show SAME order!
    final List<String> shuffledChoices = _buildThreeAnswerChoices(options, correctAnswer);
    final String optionsLine = _buildNotificationOptionsLine(shuffledChoices);

    final String displayBody = wrongAttempt != null
        ? '❌ Galat ($wrongAttempt)\n$optionsLine'
        : optionsLine;

    // Animated energetic vibration pulse pattern [delay, vibrate, pause, vibrate...]
    final vibPattern = Int64List.fromList([0, 200, 100, 300, 100, 450]);

    final Color stageColor = currentStage == 1
        ? const Color(0xFFEF4444) // 🔴 Red for 30-min urgency
        : (currentStage == 2
            ? const Color(0xFFF97316) // 🟠 Orange for 4-hr reinforcement
            : const Color(0xFF10B981)); // 🟢 Green for next-day retention

    final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
      displayBody,
      htmlFormatBigText: false,
      contentTitle: displayTitle,
      htmlFormatContentTitle: false,
      summaryText: summaryText ?? 'Scientific Spaced Repetition (Stage $currentStage/3)',
      htmlFormatSummaryText: false,
    );

    final actions = _buildFourActions(
      formula: formula,
      preShuffledChoices: shuffledChoices,
      correctAnswer: correctAnswer,
    );

    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prepvanta_animated_recall_v4',
        'PrepVanta Spaced Repetition Recall',
        channelDescription: 'Animated spaced repetition calculation alerts for mistake revision (30m, 4h, next day)',
        importance: Importance.max,
        priority: Priority.max,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]), // FLAG_ONGOING_EVENT(2) + FLAG_NO_CLEAR(32) = Cannot dismiss with Clear All
        subText: summaryText ?? 'Stage $currentStage of 3',
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 150, 80, 250, 80, 350, 80, 500]),
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
        enableLights: true,
        ledColor: stageColor,
        ledOnMs: 600,
        ledOffMs: 400,
        channelShowBadge: true,
        showWhen: true,
        colorized: true,
        color: stageColor,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        showProgress: true,
        maxProgress: 0,
        indeterminate: true,
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
      await incrementDailyNotificationCount();

      // Trigger animated in-app slide-down banner if app is currently in foreground
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showInAppAnimatedHeadsUpBanner(
            formula: formula,
            correctAnswer: correctAnswer,
            notifId: id,
            choices: shuffledChoices,
            stage: currentStage,
          );
        });
      } catch (_) {}
    } catch (e) {
      debugPrint('Persistent recall notification error: $e');
    }
  }

  // Intercept swipe-away / clear-all action: If user somehow dismisses without answering, re-post immediately!
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

        debugPrint('🔒 User tried to swipe recall notification! Re-posting: $formula');
        await showPersistentRecallNotification(
          id: notifId,
          prompt: formula,
          correctAnswer: correctAnswer,
          wrongAttempt: null,
        );
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
      debugPrint('ðŸ”” Daily notification limit set to: $limit');
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
      debugPrint('ðŸ“¢ Notification sent today: ${count + 1}');
    } catch (_) {}
  }

  Future<bool> hasReachedDailyNotificationLimit() async {
    try {
      final limit = await getDailyNotificationLimit();
      if (limit <= 0) return false; // 0 or negative = Unlimited
      final count = await getDailyNotificationCountToday();
      if (count >= limit) {
        debugPrint('ðŸ›‘ Daily notification limit ($limit) reached for today ($count sent). Suppressing notification to prevent fatigue.');
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
      if (stored != null &&
          stored.isNotEmpty &&
          !stored.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
        return stored;
      }
    } catch (_) {}
    return _computeFallbackAnswer(formula);
  }

  String _computeFallbackAnswer(String formula) {
    if (formula.trim().isEmpty) return '0';

    // First check if formula itself is already a direct integer
    final directInt = int.tryParse(formula.trim());
    if (directInt != null) return '$directInt';

    try {
      String clean = cleanPrompt(formula);

      // Check squares (e.g. 17² or 17^2)
      final sqMatch = RegExp(r'(\d+)\s*(?:²|\^2)').firstMatch(clean);
      if (sqMatch != null) {
        int n = int.parse(sqMatch.group(1)!);
        return '${n * n}';
      }

      // Check cubes (e.g. 8³ or 8^3)
      final cbMatch = RegExp(r'(\d+)\s*(?:³|\^3)').firstMatch(clean);
      if (cbMatch != null) {
        int n = int.parse(cbMatch.group(1)!);
        return '${n * n * n}';
      }

      // Multiplication: match (num) [× * x X \u00D7 \u2715 \u2716] (num)
      final multMatch = RegExp(r'(\d+)\s*[×\*xX\u00D7\u2715\u2716]\s*(\d+)').firstMatch(clean);
      if (multMatch != null) {
        int a = int.parse(multMatch.group(1)!);
        int b = int.parse(multMatch.group(2)!);
        return '${a * b}';
      }

      // Addition: match (num) + (num)
      final addMatch = RegExp(r'(\d+)\s*\+\s*(\d+)').firstMatch(clean);
      if (addMatch != null) {
        int a = int.parse(addMatch.group(1)!);
        int b = int.parse(addMatch.group(2)!);
        return '${a + b}';
      }

      // Subtraction: match (num) [- − \u2212] (num)
      final subMatch = RegExp(r'(\d+)\s*[\-−\u2212]\s*(\d+)').firstMatch(clean);
      if (subMatch != null) {
        int a = int.parse(subMatch.group(1)!);
        int b = int.parse(subMatch.group(2)!);
        return '${a - b}';
      }

      // Division: match (num) [Ã· / \u00F7] (num)
      final divMatch = RegExp(r'(\d+)\s*[Ã·/\u00F7]\s*(\d+)').firstMatch(clean);
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
          return '${a ~/ b}';
        }
      }
    } catch (e) {
      debugPrint('Fallback math compute error: $e');
    }

    return '0';
  }

  // Handle immediate tap on answer options directly from the notification shade

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

      _programmaticallyDismissedNotifIds.add(notifId);
      await cancelNotification(notifId);

      final prefs = await SharedPreferences.getInstance();
      final hasRepetitionStage = prefs.containsKey('repetition_stage_$formula');
      final int currentStage = prefs.getInt('repetition_stage_$formula') ?? 1;

      if (hasRepetitionStage && currentStage < 3) {
        // Scientific Hermann Ebbinghaus Spaced Repetition Progression:
        // Stage 1 (30-Min Recall) Correct -> Advance to Stage 2 (4-Hour Reinforcement)
        // Stage 2 (4-Hour Reinforcement) Correct -> Advance to Stage 3 (Next-Day 9:00 AM Retention)
        final int nextStage = currentStage + 1;
        await prefs.setInt('repetition_stage_$formula', nextStage);

        final int nextDelayMinutes;
        final DateTime dueAt;
        if (nextStage == 2) {
          nextDelayMinutes = 240; // 4 Hours (240 min)
          dueAt = DateTime.now().add(const Duration(hours: 4));
        } else {
          // Stage 3: Next day morning at 9:00 AM
          final now = DateTime.now();
          final nextDay9AM = DateTime(now.year, now.month, now.day + 1, 9, 0, 0);
          dueAt = nextDay9AM;
          nextDelayMinutes = nextDay9AM.difference(now).inMinutes.clamp(1, 1440);
        }
        await prefs.setString('recall_due_at_$formula', dueAt.toIso8601String());

        debugPrint('🎯 Spaced Repetition: $formula advanced from Stage $currentStage to Stage $nextStage. Next recall in ${nextDelayMinutes}m.');

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
        // Stage 3 successfully solved: MASTERED (Stage 4)!
        await prefs.setInt('repetition_stage_$formula', 4);
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
            await _scheduleStarredTableSpaced(activeTable, delayMinutes: 30, stage: 1);
          }
        }
      }
    } else {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
      // Penalty: Reset back to Stage 1 (30-Min Recall)!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('repetition_stage_$formula', 1);
      final dueAt = DateTime.now().add(const Duration(minutes: 30));
      await prefs.setString('recall_due_at_$formula', dueAt.toIso8601String());

      await showPersistentRecallNotification(
        id: notifId,
        prompt: formula,
        correctAnswer: correctAnswer,
        wrongAttempt: selectedOption,
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
        colorized: true,
        color: const Color(0xFF22C55E), // 🟢 Snoozed = next-day retention color
        subText: 'Snoozed Recall — Kal 9 AM',
        showProgress: true,
        maxProgress: 0,
        indeterminate: true,
        styleInformation: BigTextStyleInformation(
          notifBody,
          contentTitle: '🟢 Snoozed Recall: $formula = ?',
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
  //   t=0   Wrong answer â†’  zonedSchedule native alarm at t+60min (Stage 1)
  //   t+1h  Notification fires (user sees it when app is CLOSED)
  //   Correct at Stage 1  â†’  native alarm at t+3hr (Stage 2)
  //   Correct at Stage 2  â†’  native alarm at t+3hr (Stage 3)
  //   Correct at Stage 3  â†’  MASTERED, cleared forever
  //   Wrong at any stage  â†’  reset to Stage 1 (1-hr alarm again)
  //
  // CRITICAL: postImmediately is always false in production.
  // Notifications NEVER show while the app is in the foreground.
  Future<void> scheduleCalculationMistakeReminder({
    required String prompt,
    required String correctAnswer,
    required String userAnswer,
    String topicName = 'Tables',
    String userName = 'Aspirant',
    bool postImmediately = false, // Always false in production â€” only true in admin tests
  }) async {
    String formula = cleanPrompt(prompt);
    // ðŸ›¡ï¸ Never schedule mistake reminder for non-math / English content
    if (!_isValidMathFormula(formula)) {
      debugPrint('âš ï¸ Skipping scheduleCalculationMistakeReminder for non-math content: "$formula"');
      return;
    }
    // ðŸ›¡ï¸ User directive: No notifications for addition or subtraction
    if (_isAdditionOrSubtraction(formula, topicName)) {
      debugPrint('ðŸ›¡ï¸ Suppressing reminder notification for addition/subtraction: "$formula" ($topicName)');
      return;
    }
    await _markRecallUnsolvedInPrefs(formula);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('snoozed_until_$formula');

    String resolvedAnswer = correctAnswer.trim();
    if (int.tryParse(resolvedAnswer) == null || resolvedAnswer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
      resolvedAnswer = _computeFallbackAnswer(formula.isNotEmpty ? formula : resolvedAnswer);
    }

    // Initialize Stage 1 (1-Hour Spaced Recall)
    await prefs.setInt('repetition_stage_$formula', 1);
    final dueAt = DateTime.now().add(const Duration(minutes: 60));
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
    // This is the ONLY way the notification gets posted â€” NOT via immediate show()
    await schedule1HourRecallNotification(
      formula: formula,
      correctAnswer: resolvedAnswer,
      delayMinutes: 60,
    );

    debugPrint('âœ… Mistake scheduled: "$formula" â†’ notification in 60 min (Stage 1)');

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
        // ðŸ›¡ï¸ User directive: No notifications for addition or subtraction
        if (_isAdditionOrSubtraction(clean, m.topicId)) {
          debugPrint('ðŸ›¡ï¸ Skipping addition/subtraction mistake from notification queue: "$clean"');
          continue;
        }
        await _markRecallUnsolvedInPrefs(clean);
        await prefs.remove('snoozed_until_$clean');
        String resolvedAnswer = m.correctAnswer.trim();
        if (int.tryParse(resolvedAnswer) == null || resolvedAnswer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
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

  // Posts notifications for ALL pending mistake calculations serial-wise when due
  Future<void> postAllPendingMistakesSerial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> unnotified = prefs.getStringList('unnotified_mistakes_list') ?? [];

      // Check legacy single key
      final latestSingle = prefs.getString('latest_unnotified_mistake');
      if (latestSingle != null && latestSingle.isNotEmpty && !unnotified.contains(latestSingle)) {
        unnotified.add(latestSingle);
        await prefs.remove('latest_unnotified_mistake');
      }

      // If unnotified list is empty, take all unsolved from pending_recall_queue
      if (unnotified.isEmpty) {
        final queue = prefs.getStringList('pending_recall_queue') ?? [];
        unnotified = List.from(queue);
      }

      if (unnotified.isEmpty) return;

      await cancelNotification(1111);

      // Copy list to post without dropping items that are not yet due
      final toPost = List<String>.from(unnotified);
      List<String> stillPendingLater = [];
      bool postedOne = false; // ðŸ”’ MAX 1 notification at a time â€” prevents spam on app open

      for (int i = 0; i < toPost.length; i++) {
        final item = toPost[i];
        final parts = item.split('|');
        if (parts.isEmpty) continue;
        final formula = cleanPrompt(parts[0]);
        if (formula.isEmpty) continue;

        // ðŸ›¡ï¸ Skip non-math content (English sentences, vocab etc.)
        if (!_isValidMathFormula(formula)) {
          debugPrint('âš ï¸ Skipping non-math formula from recall queue: $formula');
          continue; // permanently discard â€” not a valid math recall item
        }

        // ðŸ›¡ï¸ User directive: No notifications for addition or subtraction
        if (_isAdditionOrSubtraction(formula)) {
          debugPrint('ðŸ›¡ï¸ Skipping addition/subtraction notification from post queue: $formula');
          continue;
        }

        final bool isSolved = await isCalculationSolved(formula);
        if (isSolved) continue;

        final bool isSnoozed = isFormulaSnoozed(formula, prefs);
        if (isSnoozed) {
          debugPrint('Formula $formula is snoozed until tomorrow, skipping post today.');
          stillPendingLater.add(item);
          continue;
        }

        // Spaced Repetition Due Check: Do not post if recall time is still in the future!
        if (!isCalculationDueForRecall(formula, prefs)) {
          debugPrint('â³ Formula $formula is scheduled for spaced recall later, keeping in buffer.');
          stillPendingLater.add(item);
          continue;
        }

        // ðŸ”’ Post only 1 notification per app open â€” rest stay queued for next session
        if (postedOne) {
          stillPendingLater.add(item);
          continue;
        }

        String answer = parts.length >= 2 ? parts[1].trim() : _computeFallbackAnswer(formula);
        if (int.tryParse(answer) == null || answer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
          answer = _computeFallbackAnswer(formula);
        }

        final int notifId = getNotificationIdForPrompt(formula);

        _activeReminderTimers[notifId]?.cancel();
        _activeReminderTimers.remove(notifId);

        debugPrint('ðŸš€ Posting Mistake Notification (1 at a time): $formula = $answer (ID: $notifId)');
        await showPersistentRecallNotification(
          id: notifId,
          prompt: formula,
          correctAnswer: answer,
        );
        postedOne = true; // ðŸ”’ One notification posted â€” block further spam
      }

      await prefs.setStringList('unnotified_mistakes_list', stillPendingLater);
    } catch (e) {
      debugPrint('Error posting all pending mistakes serial: $e');
    }
  }

  // Posts the newest mistake with top priority, or posts all pending mistakes
  Future<void> postLatestMistakePriority({String? targetFormula, String? targetAnswer}) async {
    if (targetFormula != null && targetFormula.isNotEmpty) {
      final formula = cleanPrompt(targetFormula);
      final answer = targetAnswer ?? _computeFallbackAnswer(formula);
      final notifId = getNotificationIdForPrompt(formula);
      await cancelNotification(1111);
      await showPersistentRecallNotification(
        id: notifId,
        prompt: formula,
        correctAnswer: answer,
      );
      await schedule1HourRecallNotification(
        formula: formula,
        correctAnswer: answer,
        delayMinutes: 60,
      );
    } else {
      await postAllPendingMistakesSerial();
    }
  }

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
        if (int.tryParse(answer) == null || answer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
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
  // SPACED REPETITION â€” CORE RULES:
  //   Wrong answer at t=0  â†’  Notification fires at t+1hr (Stage 1)
  //   Correct at Stage 1   â†’  Notification fires at t+3hr (Stage 2)
  //   Correct at Stage 2   â†’  Notification fires at t+3hr (Stage 3)
  //   Correct at Stage 3   â†’  MASTERED, no more notifications
  //   Wrong at any stage   â†’  Reset to Stage 1, fire again in 1hr
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
        if (int.tryParse(answer) == null || answer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
          answer = _computeFallbackAnswer(formula);
        }

        final int notifId = getNotificationIdForPrompt(formula);
        final int stage = prefs.getInt('repetition_stage_$formula') ?? 1;

        if (dueTime != null && now.isBefore(dueTime)) {
          // Alarm is still in the future â€” re-register the native alarm
          // (in case it was cleared when app was killed)
          final remaining = dueTime.difference(now);
          debugPrint('ðŸ” Re-scheduling alarm for $formula in ${remaining.inMinutes}m (Stage $stage)');

          if (stage == 1) {
            await schedule1HourRecallNotification(
              formula: formula,
              correctAnswer: answer,
              delayMinutes: remaining.inMinutes.clamp(1, 60),
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
          debugPrint('â„¹ï¸ Alarm for $formula has passed schedule; preserved in Revision Notebook.');
        }
      }

      debugPrint('âœ… rescheduleAllPendingMistakeAlarms: $rescheduled future alarms verified');
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
        colorized: true,
        color: const Color(0xFFEF4444),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]),
        showProgress: true,
        maxProgress: 0,
        indeterminate: true,
        actions: actions,
        styleInformation: BigTextStyleInformation(
          optionsLine,
          contentTitle: '$formula = ?',
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
  // REMOVED: no longer called on home tab tap or app open.
  // Only called externally when app is going to background (via main.dart lifecycle) â€”
  // but even then we now only RE-SCHEDULE, never immediately post while app is open.
    Future<void> triggerPendingMistakeNotificationOnHome() async {
    // ðŸ”’ SPAM FIX: Only restores 1 active recall at a time.
    // postAllPendingMistakesSerial() intentionally NOT called here to prevent spam on app open.
    try {
      await restoreActiveRecallsFromQueue();
    } catch (e) {
      debugPrint('Error triggering mistake on home: $e');
    }
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
      if (int.tryParse(resolvedAnswer) == null || resolvedAnswer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
        resolvedAnswer = _computeFallbackAnswer(clean.isNotEmpty ? clean : resolvedAnswer);
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
        colorized: true,
        color: const Color(0xFFEF4444), // 🔴 Stage 1 Red urgency
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]), // Cannot be cleared via Clear All
        subText: 'Mistake Recall — Stage 1 of 3',
        showProgress: true,
        maxProgress: 0,
        indeterminate: true,
        actions: actions,
        styleInformation: BigTextStyleInformation(
          notifBody,
          contentTitle: '🔴 30-Min Recall: $clean = ?',
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
    int delayMinutes = 240,
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
      if (int.tryParse(resolvedAnswer) == null || resolvedAnswer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
        resolvedAnswer = _computeFallbackAnswer(clean.isNotEmpty ? clean : resolvedAnswer);
      }
      final int recallNotifId = getNotificationIdForPrompt(clean);

      // Stage 2 = 4-Hour Reinforcement 🟠, Stage 3 = Next-Day 9AM Retention 🟢
      final stageTag   = stage == 2 ? '4-Hour Reinforcement' : 'Next-Day Retention';
      final stageEmoji = stage == 2 ? '🟠' : '🟢';
      final stageColor = stage == 2 ? const Color(0xFFF97316) : const Color(0xFF22C55E);
      final vibPattern = Int64List.fromList([0, 180, 80, 320, 80, 180]);
      final options    = generateRecallOptions(resolvedAnswer, clean);
      final List<String> shuffledChoices = _buildThreeAnswerChoices(options, resolvedAnswer);
      final optionsLine = _buildNotificationOptionsLine(shuffledChoices);
      final notifBody  = optionsLine;
      final actions    = _buildFourActions(
        formula: clean,
        preShuffledChoices: shuffledChoices,
        correctAnswer: resolvedAnswer,
      );

      // Stage 3: schedule at exact next-day 9AM (absolute time, not relative offset)
      final tz.TZDateTime scheduledTz;
      if (stage == 3) {
        final now = DateTime.now();
        final nextDay9AM = DateTime(now.year, now.month, now.day + 1, 9, 0, 0);
        scheduledTz = tz.TZDateTime.from(nextDay9AM, tz.local);
      } else {
        scheduledTz = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));
      }

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
        colorized: true,
        color: stageColor,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        additionalFlags: Int32List.fromList([34]),
        subText: 'Mistake Recall — Stage $stage/3',
        showProgress: true,
        maxProgress: 0,
        indeterminate: true,
        actions: actions,
        styleInformation: BigTextStyleInformation(
          notifBody,
          contentTitle: '$stageEmoji $stageTag: $clean = ?',
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
        final nextAnswer = parts.length > 1 ? parts[1] : await getCorrectAnswerForFormula(nextFormula);
        await prefs.setString('currently_displayed_recall_formula', nextFormula);
        await showPersistentRecallNotification(
          id: getNotificationIdForPrompt(nextFormula),
          prompt: nextFormula,
          correctAnswer: nextAnswer,
        );
      } else {
        await prefs.remove('currently_displayed_recall_formula');
      }
    } catch (e) {
      debugPrint('Error advancing queue: $e');
    }
  }

  // Restore active recalls from queue on app restart
  Future<void> restoreActiveRecallsFromQueue() async {
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
_ensureTimezonesInitialized();
try {
// Cancel old hardcoded hourly notifications
await cancelNotification(1111);
// Cancel only the 2 pre-scheduled alarms (1h, 3h)
await cancelNotification(1111);
await cancelNotification(1112);
await cancelNotification(1114);
} catch (_) {}

// Smart Dart timer â€” fires every 1 hour while app is open
_hourlyTimer?.cancel();
_hourlyTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
await _triggerSmartHourlyChallenge(userName: userName);
});

// Schedule native OS alarms for upcoming hours (1h, 2h, 3h, 4h, 5h, 6h)
// so alerts arrive reliably even when phone is locked or app is closed!
await _scheduleNativeHourlyReminders(userName: userName);
debugPrint('âœ… Smart hourly challenge started (shows pending wrong Qs first, then random + native OS alarms)');
}

// Pre-schedules native OS alarms for future hours (+1h, +2h, +3h, +4h, +5h, +6h)
Future<void> _scheduleNativeHourlyReminders({String userName = 'Aspirant'}) async {
try {
_ensureTimezonesInitialized();
final prefs = await SharedPreferences.getInstance();

final List<String>? starred = prefs.getStringList('starred_tables');
final validStarred = (starred ?? []).map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
final List<String> queue = prefs.getStringList('pending_recall_queue') ?? [];

// ðŸ”’ SPAM FIX: Daily gate - only schedule if NOT already done today
final String todayKey = 'hourly_reminders_scheduled_${DateTime.now().toIso8601String().substring(0, 10)}';
if (prefs.getBool(todayKey) == true) {
debugPrint('â­ï¸ Hourly reminders already scheduled today, skipping.');
return;
}
await prefs.setBool(todayKey, true);

// ðŸ”’ SPAM FIX: Max 2 native OS alarms (+1h, +3h) instead of 6
for (int h = 1; h <= 2; h++) {
final int actualHours = h == 1 ? 1 : 3; // +1h and +3h only
final int notifId = 1110 + actualHours;
final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(hours: actualHours));

String formula;
String correctAnswer;

// Priority 1: Unsolved mistake from queue
if (h - 1 < queue.length) {
final parts = queue[h - 1].split('|');
formula = cleanPrompt(parts[0]);
correctAnswer = parts.length >= 2 ? parts[1].trim() : _computeFallbackAnswer(formula);
if (int.tryParse(correctAnswer) == null || correctAnswer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
correctAnswer = _computeFallbackAnswer(formula);
}
} else if (validStarred.isNotEmpty) {
// Priority 2: Starred tables drill
final tNum = validStarred[(h - 1) % validStarred.length];
final mult = tableMultipliers[(h * 2 + 1) % tableMultipliers.length];
formula = '$tNum × $mult';
correctAnswer = '${tNum * mult}';
} else {
// Priority 3: Dynamic math speed challenge
final question = await _generateDynamicChallengeQuestion();
formula = question['formula']!;
correctAnswer = question['answer']!;
}

final options = generateRecallOptions(correctAnswer, formula);
final shuffledChoices = _buildThreeAnswerChoices(options, correctAnswer);
final optionsLine = _buildNotificationOptionsLine(shuffledChoices);

final actions = _buildFourActions(
formula: formula,
preShuffledChoices: shuffledChoices,
correctAnswer: correctAnswer,
);

final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
'math_hourly_channel_v3',
'Hourly Mental Speed Challenge',
channelDescription: 'Regular 1-hour calculation drill notifications to keep your mind sharp',
importance: Importance.max,
priority: Priority.high,
playSound: true,
sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
enableVibration: true,
ongoing: true,
autoCancel: false,
category: AndroidNotificationCategory.reminder,
actions: actions,
styleInformation: BigTextStyleInformation(
'👇 Tap an option below:\n$optionsLine',
contentTitle: '$formula = ?',
summaryText: 'Hourly Mental Math Challenge',
),
);

final details = NotificationDetails(android: androidDetails);

try {
await _notificationsPlugin.zonedSchedule(
id: notifId,
title: '$formula = ?',
body: optionsLine,
scheduledDate: scheduledTime,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
payload: 'persistent|$notifId|$formula|$correctAnswer',
);
} catch (_) {
try {
await _notificationsPlugin.zonedSchedule(
id: notifId,
title: '$formula = ?',
body: optionsLine,
scheduledDate: scheduledTime,
notificationDetails: details,
androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
payload: 'persistent|$notifId|$formula|$correctAnswer',
);
} catch (_) {}
}
}
} catch (e) {
debugPrint('Error scheduling native hourly reminders: $e');
}
}

// Smart hourly challenge:
// Priority 1 â†’ Pending unsolved wrong questions from queue (Round-robin: earlier + new mistakes baari-baari!)
// Priority 2 â†’ Random question if no pending mistakes
Future<void> _triggerSmartHourlyChallenge({String userName = 'Aspirant'}) async {
try {
final prefs = await SharedPreferences.getInstance();
final List<String> queue = prefs.getStringList('pending_recall_queue') ?? [];

if (queue.isNotEmpty) {
// Rotate through pending mistakes in queue (both earlier and new ones!)
int lastIndex = prefs.getInt('hourly_recall_queue_index') ?? 0;
if (lastIndex >= queue.length) {
lastIndex = 0;
}

final targetItem = queue[lastIndex];
final nextIndex = (lastIndex + 1) % queue.length;
await prefs.setInt('hourly_recall_queue_index', nextIndex);

final parts = targetItem.split('|');
final String formula = cleanPrompt(parts[0]);
String correctAnswer = parts.length >= 2 ? parts[1].trim() : _computeFallbackAnswer(formula);
if (int.tryParse(correctAnswer) == null || correctAnswer.contains(RegExp(r'[×\*xX\+\-−Ã·/\^²³]'))) {
correctAnswer = _computeFallbackAnswer(formula);
}

final int notifId = getNotificationIdForPrompt(formula);
await prefs.setString('currently_displayed_recall_formula', formula);

debugPrint('⏰ Hourly Recall: Recalling mistake ($formula = $correctAnswer) [Q ${lastIndex + 1}/${queue.length}]');
await showPersistentRecallNotification(
id: notifId,
prompt: formula,
correctAnswer: correctAnswer,
);
return;
} else {
// If user already has active starred tables, do NOT post a second clashing notification (id 1111) with random tables like 17!
final List<String>? starred = prefs.getStringList('starred_tables');
final validStarred = (starred ?? []).map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
if (validStarred.isNotEmpty) {
await cancelNotification(1111);
return;
}

// No pending wrong questions & no starred tables â†’ generate fresh dynamic question
final question = await _generateDynamicChallengeQuestion();
debugPrint('⏰ Hourly: Dynamic challenge: ${question['formula']}');
await showPersistentRecallNotification(
id: 1111,
prompt: question['formula']!,
correctAnswer: question['answer']!,
);
}
} catch (e) {
debugPrint('Smart hourly challenge error: $e');
}
}

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

// 3. Dynamic multiplication table (tables 11 to 30, multiplier 2 to 9)
final t = random.nextInt(20) + 11; // 11 to 30
final mult = random.nextInt(8) + 2; // 2 to 9
return {
'formula': '$t × $mult',
'answer': '${t * mult}',
};
}

// Instant Hourly Challenge (manual trigger or test)
Future<void> triggerInstantHourlyChallenge({String userName = 'Aspirant', String? customFormula}) async {
if (customFormula != null) {
await showPersistentRecallNotification(
id: 1111,
prompt: customFormula,
correctAnswer: _computeFallbackAnswer(customFormula),
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

// Daily Inactivity Streak-Saver Alarm (Personalized with student name)
Future<void> scheduleDailyStreakReminder({String userName = 'Aspirant'}) async {
try {
_streakTimer?.cancel();
_streakTimer = Timer(const Duration(hours: 8), () async {
await showNotification(
id: 7777,
title: '🔥 Save Your Study Streak!',
body: 'Solve 10 questions to keep your streak alive.',
payload: 'streak_reminder',
);
});
} catch (e) {
debugPrint('Streak alarm notice: $e');
}
}

// Admin Broadcast notification
Future<void> triggerAdminBroadcast({required String title, required String body}) async {
await showNotification(
id: 9999,
title: 'ðŸ“¢ $title',
body: body,
payload: 'admin_broadcast',
);
}

// Standard competitive exam multipliers for Table Practice (2 to 12)
static const List<int> tableMultipliers = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

// 🌟 3.5 STARRED TABLE REVISION NOTIFICATIONS (Spaced Repetition: 1 Hr âž” +3 Hrs âž” +3 Hrs)
// Ensures student gets calculation questions cycling through multipliers of the starred table(s)
// with ZERO immediate disturbance, first drill at 1-hour, then spaced reinforcement at 3-hour intervals.
Future<void> scheduleStarredTableNotification(int tableNumber) async {
try {
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
await _scheduleStarredTableSpaced(tableNumber, delayMinutes: 60, stage: 1);
debugPrint('â­ Starred Table $tableNumber first spaced drill scheduled in 1 hour (Zero immediate notification)');
} catch (e) {
debugPrint('Error scheduling starred table notification: $e');
}
}

Future<void> _scheduleStarredTableSpaced(int tableNumber, {int delayMinutes = 60, int stage = 1}) async {
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
category: AndroidNotificationCategory.reminder,
actions: _buildFourActions(
formula: formula,
preShuffledChoices: shuffledChoices,
correctAnswer: correctAnswer,
),
styleInformation: BigTextStyleInformation(
'👇 Tap an option below:\n$optionsLine',
contentTitle: '$formula = ?',
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
'👇 Tap an option below to answer:\n$optionsLine',
htmlFormatBigText: false,
contentTitle: 'Table $tableNumber: $formula = ?',
htmlFormatContentTitle: false,
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
ongoing: false,
autoCancel: true,
playSound: true,
sound: const RawResourceAndroidNotificationSound('custom_notification_sound'),
enableVibration: true,
category: AndroidNotificationCategory.reminder,
actions: _buildFourActions(
formula: formula,
preShuffledChoices: shuffledChoices,
correctAnswer: correctAnswer,
),
styleInformation: BigTextStyleInformation(
'⚡ 3-Day Retention Check: $formula = ?\nTap the correct option below to keep your Table of $tableNumber at 100% Mastered:\n$optionsLine',
contentTitle: '🧠  Table of $tableNumber: $formula = ?',
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
debugPrint('ðŸ“… Scheduled 3-day spaced recall for Table $tableNumber ($formula) in 3 days.');
} catch (e) {
debugPrint('Error scheduling 3-day table recall: $e');
}
}

// 4. SMART ENGAGEMENT / BROWSE-ABANDONMENT NUDGE (Flipkart/Amazon Style)
Future<void> scheduleBrowsedTopicNudge({
required String topicId,
required String topicTitle,
String? sampleQuestion,
String userName = 'Aspirant',
}) async {
try {
// ðŸ”’ SPAM FIX: Only fire if no browse nudge was sent in the last 30 minutes
final prefs = await SharedPreferences.getInstance();
final lastNudgeMs = prefs.getInt('last_browse_nudge_ms') ?? 0;
final nowMs = DateTime.now().millisecondsSinceEpoch;
if (nowMs - lastNudgeMs < 30 * 60 * 1000) {
debugPrint('â­ï¸ Browse nudge skipped - sent less than 30 min ago');
return;
}
await prefs.setInt('last_browse_nudge_ms', nowMs);

int nudgeId = 4400 + (topicId.hashCode.abs() % 1000);
Future.delayed(const Duration(minutes: 90), () async {
String q = sampleQuestion != null ? cleanPrompt(sampleQuestion) : '';
// ðŸ›¡ï¸ Validate formula before posting
if (!_isValidMathFormula(q)) {
final dyn = await _generateDynamicChallengeQuestion();
q = dyn['formula']!;
}
final ans = await getCorrectAnswerForFormula(q);
final opts = generateRecallOptions(ans, q);
await showNotification(
id: nudgeId,
title: '$q = ?',
body: '(A) ${opts[0]}   (B) ${opts[1]}   (C) ${opts[2]}',
payload: 'browse_continue:$topicId',
);
});
} catch (e) {
debugPrint('Browse nudge notice: $e');
}
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

// 6. DAILY SMART TOPIC RECOMMENDATION (Personalized high-frequency exam drills)
Future<void> scheduleDailySmartTopicRecommendation({
required String recommendedTopic,
String userName = 'Aspirant',
}) async {
try {
_recommendationTimer?.cancel();
_recommendationTimer = Timer(const Duration(hours: 6), () async {
await showNotification(
id: 6600,
title: 'ðŸŽ¯ Today\'s Recommended Focus for $userName',
body: 'High exam weightage alert! Practice $recommendedTopic today for 2x faster calculation speed.',
payload: 'recommendation:$recommendedTopic',
);
});
} catch (e) {
debugPrint('Recommendation notice: $e');
}
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
await showNotification(
id: 3300,
title: 'ðŸŽ¯ Target Time: Study ${plan.topicTitle}!',
body: 'Hey $userName! Practice session scheduled for ${plan.topicTitle}. Quick question: What is ${plan.sampleQuestion}? Tap to start!',
payload: 'study_plan:${plan.topicId}',
);

// Persistent reminder every 45 minutes until completed
_studyPlanRecurringTimer?.cancel();
_studyPlanRecurringTimer = Timer.periodic(const Duration(minutes: 45), (_) async {
await showNotification(
id: 3300,
title: 'ðŸŽ¯ Study Reminder: ${plan.topicTitle} Today',
body: 'Hey $userName! Quick reminder for your practice goal: What is ${plan.sampleQuestion}? Tap to complete your 10-question drill!',
payload: 'study_plan:${plan.topicId}',
);
});
}

if (delayMs <= 0) {
// Time is now or already passed today
triggerPlanAlerts();
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
body: 'ðŸš¨ Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
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
body: 'ðŸš¨ Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
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
body: 'ðŸš¨ Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
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
body: 'ðŸš¨ Solve 5 Math Questions to Turn Off Alarm! Tap to Dismiss!',
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
body: 'ðŸš¨ Solve 5 of your past mistake questions (2 choices) to turn off the alarm!',
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

// ── IN-APP ANIMATED HEADS-UP NOTIFICATION BANNER ──────────────────────────────

class _AnimatedHeadsUpBannerWidget extends StatefulWidget {
  final String formula;
  final String correctAnswer;
  final int notifId;
  final List<String> choices;
  final int stage;
  final VoidCallback onDismiss;
  final Function(String) onAnswer;
  final VoidCallback onSnooze;
  final VoidCallback onTapBody;

  const _AnimatedHeadsUpBannerWidget({
    required this.formula,
    required this.correctAnswer,
    required this.notifId,
    required this.choices,
    required this.stage,
    required this.onDismiss,
    required this.onAnswer,
    required this.onSnooze,
    required this.onTapBody,
  });

  @override
  State<_AnimatedHeadsUpBannerWidget> createState() => _AnimatedHeadsUpBannerWidgetState();
}

class _AnimatedHeadsUpBannerWidgetState extends State<_AnimatedHeadsUpBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
    NotificationService().playNotificationSound();
    _autoDismissTimer = Timer(const Duration(seconds: 9), _dismiss);
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    if (mounted) {
      _animController.reverse().then((_) {
        widget.onDismiss();
      });
    } else {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final stageColor = widget.stage == 1
        ? const Color(0xFFEF4444)
        : (widget.stage == 2 ? const Color(0xFFF97316) : const Color(0xFF10B981));
    final stageLabel = widget.stage == 1
        ? '🔴 30-Min Recall'
        : (widget.stage == 2 ? '🟠 4-Hour Reinforcement' : '🟢 Next-Day Retention');

    return Positioned(
      top: topPadding + 10,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTapBody,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: stageColor.withValues(alpha: 0.65), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: stageColor.withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: stageColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              stageLabel,
                              style: TextStyle(
                                color: stageColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _dismiss,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Formula Question
                    Text(
                      '${widget.formula} = ?',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 4 Action Chips
                    Row(
                      children: [
                        ...List.generate(widget.choices.length.clamp(0, 3), (i) {
                          final label = ['(A)', '(B)', '(C)'][i];
                          final val = widget.choices[i];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF334155),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  _autoDismissTimer?.cancel();
                                  widget.onAnswer(val);
                                },
                                child: Text(
                                  '$label $val',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        }),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFBBF24),
                                side: const BorderSide(color: Color(0xFFF59E0B)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                _autoDismissTimer?.cancel();
                                widget.onSnooze();
                              },
                              child: const Text(
                                '⏰ Snooze',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── IN-APP MULTIPLE-CHOICE RECALL CHALLENGE DIALOG ─────────────────────────
class _InAppChallengeDialog extends StatefulWidget {
  final String clean;
  final List<String> choices;
  final String resolvedAnswer;
  final int notifId;
  final Function(String) onAnswer;
  final VoidCallback onSnooze;

  const _InAppChallengeDialog({
    required this.clean,
    required this.choices,
    required this.resolvedAnswer,
    required this.notifId,
    required this.onAnswer,
    required this.onSnooze,
  });

  @override
  State<_InAppChallengeDialog> createState() => _InAppChallengeDialogState();
}

class _InAppChallengeDialogState extends State<_InAppChallengeDialog>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool? _isCorrect;
  bool _dismissed = false;

  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  late Animation<Color?> _celebrationColor;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _entryController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    // Pulse animation: breathing glowing border around question box
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Staggered Entry animation for options
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    // Shake controller for wrong attempts
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Celebration controller on correct solve
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _celebrationController, curve: Curves.easeInOut));
    _celebrationColor = ColorTween(
      begin: const Color(0xFF334155),
      end: const Color(0xFF16A34A),
    ).animate(CurvedAnimation(parent: _celebrationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entryController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _onTapOption(int index) async {
    if (_dismissed || _selectedIndex != null) return;
    final choice = widget.choices[index];
    final isCorrect = choice.trim().toLowerCase() == widget.resolvedAnswer.trim().toLowerCase();

    setState(() {
      _selectedIndex = index;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
      await _celebrationController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
      _shakeController.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 450));
    }

    if (mounted && !_dismissed) {
      _dismissed = true;
      Navigator.of(context).pop();
      await widget.onAnswer(choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header Bar with animated pulsing dot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.psychology_rounded, color: Color(0xFF818CF8), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Spaced Recall Check',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Animated breathing dot
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.4 + 0.6 * _pulseAnimation.value),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.6 * _pulseAnimation.value),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animated Formula Question Box (Pulses glow + Shakes on error)
            AnimatedBuilder(
              animation: Listenable.merge([_celebrationController, _pulseAnimation, _shakeController]),
              builder: (context, child) {
                final bgColor = _isCorrect == true
                    ? (_celebrationColor.value ?? const Color(0xFF1E293B))
                    : const Color(0xFF1E293B);

                // Horizontal shake offset
                final shakeOffset = _isCorrect == false && _shakeController.isAnimating
                    ? sin(_shakeController.value * 4 * pi) * 10
                    : 0.0;

                return Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: Transform.scale(
                    scale: _isCorrect == true ? _celebrationScale.value : 1.0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: _isCorrect == true ? 0.6 : 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isCorrect == true
                              ? const Color(0xFF22C55E)
                              : _isCorrect == false
                                  ? const Color(0xFFEF4444)
                                  : Color.lerp(const Color(0xFF6366F1), const Color(0xFF38BDF8), _pulseAnimation.value)!,
                          width: _isCorrect != null ? 2.2 : (1.2 + 0.8 * _pulseAnimation.value),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isCorrect == true
                                    ? const Color(0xFF22C55E)
                                    : (_isCorrect == false
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF6366F1)))
                                .withValues(alpha: 0.2 + 0.3 * _pulseAnimation.value),
                            blurRadius: 12 + 10 * _pulseAnimation.value,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${widget.clean} = ?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (_isCorrect == false) ...[
                            const SizedBox(height: 8),
                            Text(
                              '❌ Galat jawab! Dobara try karein.',
                              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 3 Staggered Animated Multiple Choice Options
            ...List.generate(widget.choices.length.clamp(0, 3), (i) {
              final label = ['(A)', '(B)', '(C)'][i];
              final choice = widget.choices[i];
              final isSelected = _selectedIndex == i;
              final isCorrectOption = choice.trim().toLowerCase() == widget.resolvedAnswer.trim().toLowerCase();

              Color bgColor = const Color(0xFF334155);
              Color borderColor = Colors.transparent;
              if (isSelected) {
                bgColor = isCorrectOption ? const Color(0xFF166534) : const Color(0xFF7F1D1D);
                borderColor = isCorrectOption ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
              }

              final itemAnim = CurvedAnimation(
                parent: _entryController,
                curve: Interval(i * 0.15, 1.0, curve: Curves.easeOutBack),
              );

              return AnimatedBuilder(
                animation: itemAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1.0 - itemAnim.value)),
                    child: Opacity(
                      opacity: itemAnim.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _selectedIndex != null ? null : () => _onTapOption(i),
                      child: Text(
                        '$label $choice',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 6),

            // (D) ⏰ Snooze Button (Staggered Animation Item 4)
            AnimatedBuilder(
              animation: _entryController,
              builder: (context, child) {
                final snoozeAnim = CurvedAnimation(
                  parent: _entryController,
                  curve: const Interval(0.45, 1.0, curve: Curves.easeOutBack),
                );
                return Transform.translate(
                  offset: Offset(0, 20 * (1.0 - snoozeAnim.value)),
                  child: Opacity(
                    opacity: snoozeAnim.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFFBBF24),
                    side: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _selectedIndex != null
                      ? null
                      : () async {
                          if (_dismissed) return;
                          _dismissed = true;
                          Navigator.of(context).pop();
                          widget.onSnooze();
                        },
                  icon: const Icon(Icons.alarm_rounded, size: 18),
                  label: const Text(
                    '(D) ⏰ Snooze until Tomorrow (9 AM)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
