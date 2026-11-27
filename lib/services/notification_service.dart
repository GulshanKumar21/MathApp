// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/math_models.dart';


@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  final svc = NotificationService();
  await svc.initBackgroundOnly();
  if (response.notificationResponseType ==
      NotificationResponseType.selectedNotificationAction) {
    if (response.input != null && response.input!.isNotEmpty) {
      await svc.handleTypedAnswerAction(
          response.input!, response.id, response.payload);
    }
  } else if (response.notificationResponseType ==
      NotificationResponseType.notificationDismissed) {
    await svc.handleNotificationDismissed(response.id, response.payload);
  } else if (response.payload != null && response.payload!.isNotEmpty) {
    // tap on body → handle payload
    await svc.handleNotificationPayload(response.payload!);
  }
}

typedef MistakeResolvedCallback = void Function(String prompt, String answer);


const int _kStarredDailyId = 7001;
const int _kStudyPlanId = 7002;
const int _kMathAlarmId = 7003;
const int _kAdminBroadcastId = 7004;
const int _kInstantTestId = 7005;
const int _kMasteredId = 7006;
const int _kActiveRecallNotificationId = 7010;

// Channel IDs
const String _kRecallChannel = 'prepvanta_recall_v1';
const String _kStarredChannel = 'prepvanta_starred_v1';
const String _kGeneralChannel = 'prepvanta_general_v1';
const String _kAlarmChannel = 'math_alarm_v1';

// SharedPreferences keys
const String _kPendingQueue = 'pending_recall_queue';
const String _kRepStagePrefix = 'repetition_stage_';
const String _kRecallDuePrefix = 'recall_due_at_';
const String _kRecallOriginalPrefix = 'recall_original_at_';
const String _kIsSolvedPrefix = 'is_solved_';
const String _kSnoozeUntilPrefix = 'snoozed_until_';
const String _kDailyCountPrefix = 'daily_notif_count_';
const String _kDailyLimit = 'daily_notif_limit';
const String _kMathAlarmHour = 'math_alarm_hour';
const String _kMathAlarmMinute = 'math_alarm_minute';
const String _kStarredTables = 'starred_tables';
const String _kRotationOffset = 'starred_daily_rotation_offset';
const String _kActiveStudyPlan = 'active_study_plan';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Competitive exam multipliers for starred table drill
  static const List<int> tableMultipliers = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  /// Navigator key for MaterialApp — used by main.dart.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isAppInForeground = true;

  /// Provider sets this to get notified when a mistake is resolved.
  MistakeResolvedCallback? onMistakeResolved;

  // ─────────────────────────────── INIT ────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;
    _ensureTimezones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: darwinInit);

    // flutter_local_notifications v22 — all named params
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createChannels();
    await _requestPermissions();
    _isInitialized = true;

    // One-time startup purge of legacy/stuck notifications & queue deduplication
    try {
      await _plugin.cancelAll();
      final prefs = await SharedPreferences.getInstance();
      final rawQueue = prefs.getStringList(_kPendingQueue) ?? [];
      if (rawQueue.isNotEmpty) {
        final List<String> sanitized = [];
        final Set<String> seen = {};
        for (final item in rawQueue) {
          final parts = item.split('|');
          if (parts.length < 2) continue;
          final f = cleanPrompt(parts[0]);
          final a = parts[1].trim();
          if (f.isNotEmpty && !seen.contains(f) && !_isSolved(prefs, f)) {
            seen.add(f);
            sanitized.add('$f|$a');
          }
        }
        await prefs.setStringList(_kPendingQueue, sanitized);
        if (sanitized.isNotEmpty) {
          await prefs.setString('currently_displayed_recall_formula', sanitized.first.split('|')[0]);
        } else {
          await prefs.remove('currently_displayed_recall_formula');
        }
      }
    } catch (_) {}

    // Cold-start tap
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 600), () {
          handleNotificationPayload(payload);
        });
      }
    }
  }

  /// Lightweight init for background isolate.
  Future<void> initBackgroundOnly() async {
    if (_isInitialized) return;
    _ensureTimezones();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: initSettings);
    _isInitialized = true;
  }

  // ─────────────────────────────── STATE ───────────────────────────────────

  void setAppInForeground(bool inForeground) {
    _isAppInForeground = inForeground;
  }

  // ─────────────────────────────── HELPERS ─────────────────────────────────

  String cleanPrompt(String prompt) {
    String s = prompt.trim();
    final tablePrefix = RegExp(r'^Table\s+\d+:\s*', caseSensitive: false);
    if (tablePrefix.hasMatch(s)) {
      s = s.replaceFirst(tablePrefix, '').trim();
    }
    s = s.replaceAll(RegExp(r'=\s*\?$'), '').trim();
    s = s.replaceAll(RegExp(r'\?$'), '').trim();
    s = s.replaceAll(RegExp(r'=$'), '').trim();
    s = s.replaceAll(RegExp(r':$'), '').trim();
    // Normalize multiplication signs (x, X, *, ×) to standard '×'
    s = s.replaceAll(RegExp(r'\s*[\*xX×]\s*'), ' × ');
    // Normalize subtraction signs (−, –, -) to standard '-'
    s = s.replaceAll(RegExp(r'\s*[−–]\s*'), ' - ');
    // Collapse any repeated whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  int getNotificationIdForPrompt(String formula) {
    return formula.hashCode.abs() % 900000 + 10000;
  }

  bool _isAnswerCorrect(String typed, String correct) {
    String clean(String s) =>
        s.trim().replaceAll(RegExp(r'[,\s]'), '').toLowerCase();
    return clean(typed) == clean(correct);
  }

  /// Returns delay in minutes for a given stage, measured from originalMistakeTime.
  int _stageDelayMinutes(int stage, DateTime originalMistakeTime) {
    final now = DateTime.now();
    switch (stage) {
      case 1:
        return 60;
      case 2:
        return 60 + 240;
      case 3:
        return 60 + 240 + 240;
      case 4:
        final day2 =
            originalMistakeTime.add(const Duration(days: 1));
        return day2.difference(now).inMinutes.clamp(5, 99999);
      case 5:
        final day7 =
            originalMistakeTime.add(const Duration(days: 7));
        return day7.difference(now).inMinutes.clamp(5, 99999);
      case 6:
        final day15 =
            originalMistakeTime.add(const Duration(days: 15));
        return day15.difference(now).inMinutes.clamp(5, 99999);
      case 7:
        final day30 =
            originalMistakeTime.add(const Duration(days: 30));
        return day30.difference(now).inMinutes.clamp(5, 99999);
      case 8:
        final day60 =
            originalMistakeTime.add(const Duration(days: 60));
        return day60.difference(now).inMinutes.clamp(5, 99999);
      default:
        return 60;
    }
  }

  /// Push dt out of quiet hours (10 PM – 8 AM → next 8:30 AM).
  DateTime applyQuietHoursGuard(DateTime dt) {
    final hour = dt.hour;
    if (hour >= 22 || hour < 8) {
      final base = hour >= 22 ? dt.add(const Duration(days: 1)) : dt;
      return DateTime(base.year, base.month, base.day, 8, 30, 0);
    }
    return dt;
  }

  DateTime _applyQuietHours(DateTime dt) => applyQuietHoursGuard(dt);

  /// Section 2 timetable computation
  DateTime computeNextDueTime({
    required DateTime originalMistakeTime,
    required int nextStage,
    required DateTime fromTime,
  }) {
    switch (nextStage) {
      case 1:
        return fromTime.add(const Duration(hours: 1));
      case 2:
        return fromTime.add(const Duration(hours: 4));
      case 3:
        return fromTime.add(const Duration(hours: 4));
      case 4:
        return originalMistakeTime.add(const Duration(days: 1));
      case 5:
        return originalMistakeTime.add(const Duration(days: 7));
      case 6:
        return originalMistakeTime.add(const Duration(days: 15));
      case 7:
        return originalMistakeTime.add(const Duration(days: 30));
      case 8:
        return originalMistakeTime.add(const Duration(days: 60));
      default:
        return fromTime.add(const Duration(hours: 1));
    }
  }

  void cancelAllTimers() {
    // In-memory timer cancellation for test harnesses
  }

  List<String> generateRecallOptions(String answer, String prompt) {
    final ansInt = int.tryParse(answer);
    if (ansInt == null) return [answer];
    if (ansInt < 10) {
      final Set<int> options = {ansInt};
      if (ansInt + 1 < 10) options.add(ansInt + 1);
      if (ansInt > 0) options.add(ansInt - 1);
      if (ansInt + 2 < 10) options.add(ansInt + 2);
      if (ansInt > 1) options.add(ansInt - 2);
      while (options.length < 3) {
        options.add((ansInt + options.length) % 10);
      }
      final list = options.take(3).map((e) => e.toString()).toList();
      list.sort();
      return list;
    }
    final Set<int> options = {ansInt};
    int d1 = ansInt >= 20 ? ansInt - 10 : ansInt + 10;
    int d2 = ansInt >= 30 ? ansInt - 20 : ansInt + 20;
    options.add(d1);
    options.add(d2);
    while (options.length < 3) {
      options.add(ansInt + (options.length * 10));
    }
    final list = options.map((e) => e.toString()).toList();
    list.sort();
    return list;
  }

  Future<void> handleNotificationAnswerAction(
      String actionPayload, int notifId) async {
    final parts = actionPayload.split('|');
    if (parts.length < 4) return;
    final formula = parts[1];
    final selectedAnswer = parts[2];
    final correctAnswer = parts[3];

    final prefs = await SharedPreferences.getInstance();

    if (_isAnswerCorrect(selectedAnswer, correctAnswer)) {
      onMistakeResolved?.call(formula, correctAnswer);

      final queue = prefs.getStringList(_kPendingQueue) ?? [];
      final target = cleanPrompt(formula);
      queue.removeWhere((e) => cleanPrompt(e.split('|')[0]) == target || e == formula);
      await prefs.setStringList(_kPendingQueue, queue);

      await cancelNotification(notifId);
      await cancelNotification(_kActiveRecallNotificationId);

      if (queue.isNotEmpty) {
        final nextParts = queue.first.split('|');
        final nextFormula = nextParts[0];
        final nextAns = nextParts.length > 1 ? nextParts[1] : '';
        await prefs.setString('currently_displayed_recall_formula', nextFormula);

        // Schedule next question in line
        final nextDue = _applyQuietHours(DateTime.now().add(const Duration(minutes: 60)));
        await prefs.setString('$_kRecallDuePrefix$nextFormula', nextDue.toIso8601String());
        await _scheduleRecallAtTime(
          formula: nextFormula,
          correctAnswer: nextAns,
          dueAt: nextDue,
        );
      } else {
        await prefs.remove('currently_displayed_recall_formula');
      }

      await prefs.remove('$_kSnoozeUntilPrefix$formula');

      final currentStage = prefs.getInt('$_kRepStagePrefix$formula') ?? 1;
      final nextStage = currentStage + 1;
      await prefs.setInt('$_kRepStagePrefix$formula', nextStage);

      if (nextStage >= 4) {
        await prefs.setBool('$_kIsSolvedPrefix$formula', true);
        await prefs.remove('$_kRecallDuePrefix$formula');
      } else {
        await prefs.setBool('$_kIsSolvedPrefix$formula', false);
        final nextDue = DateTime.now().add(const Duration(hours: 3));
        await prefs.setString(
            '$_kRecallDuePrefix$formula', nextDue.toIso8601String());
      }
    } else {
      await prefs.setInt('$_kRepStagePrefix$formula', 1);
      final resetDue = DateTime.now().add(const Duration(minutes: 60));
      await prefs.setString(
          '$_kRecallDuePrefix$formula', resetDue.toIso8601String());
      await _scheduleRecallAtTime(
        formula: formula,
        correctAnswer: correctAnswer,
        dueAt: resetDue,
      );
    }
  }

  bool isFormulaSnoozed(String formula, [SharedPreferences? prefs]) {
    if (prefs == null) return false;
    final snoozedStr = prefs.getString('$_kSnoozeUntilPrefix$formula');
    if (snoozedStr == null) return false;
    final date = DateTime.tryParse(snoozedStr);
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  Future<void> handleSnoozeAction(String actionPayload, int notifId) async {
    final parts = actionPayload.split('|');
    if (parts.length >= 2) {
      final formula = parts[1];
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          '$_kSnoozeUntilPrefix$formula', tomorrow.toIso8601String());
      await cancelNotification(notifId);
    }
  }

  Future<int> getDailyNotificationLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kDailyLimit) ?? 10;
  }

  Future<int> getDailyNotificationCountToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_todayKey()) ?? 0;
  }

  Future<bool> hasReachedDailyNotificationLimit() async {
    final limit = await getDailyNotificationLimit();
    if (limit == 0) return false;
    final count = await getDailyNotificationCountToday();
    return count >= limit;
  }

  Future<void> incrementDailyNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await _incrementDailyCount(prefs);
  }

  Future<void> resetDailyNotificationCountForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todayKey());
  }

  Future<int> getRepetitionStage(String formula) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_kRepStagePrefix$formula') ?? 1;
  }

  Future<bool> isCalculationSolved(String formula) async {
    final prefs = await SharedPreferences.getInstance();
    return _isSolved(prefs, formula);
  }

  bool isCalculationDueForRecall(String formula, [SharedPreferences? prefs]) {
    if (prefs == null) return false;
    final dueStr = prefs.getString('$_kRecallDuePrefix$formula');
    if (dueStr == null) return false;
    final due = DateTime.tryParse(dueStr);
    if (due == null) return false;
    return !due.isAfter(DateTime.now());
  }

  bool _isSolved(SharedPreferences prefs, String formula) =>
      prefs.getBool('$_kIsSolvedPrefix$formula') ?? false;

  String _todayKey() {
    final now = DateTime.now();
    return '$_kDailyCountPrefix${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<bool> _canSendNotification(SharedPreferences prefs) async {
    final limit = prefs.getInt(_kDailyLimit) ?? 0;
    if (limit == 0) return true;
    return (prefs.getInt(_todayKey()) ?? 0) < limit;
  }

  Future<void> _incrementDailyCount(SharedPreferences prefs) async {
    final key = _todayKey();
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  void _ensureTimezones() {
    try {
      tz_data.initializeTimeZones();
    } catch (_) {}
  }

  tz.TZDateTime _tzFrom(DateTime dt) {
    try {
      return tz.TZDateTime.from(dt, tz.getLocation('Asia/Kolkata'));
    } catch (_) {
      return tz.TZDateTime.from(dt, tz.local);
    }
  }

  // ─────────────────────────────── CHANNELS ────────────────────────────────

  Future<void> _createChannels() async {
    final ap = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (ap == null) return;

    await ap.createNotificationChannel(
      const AndroidNotificationChannel(
        _kRecallChannel,
        'Spaced Recall',
        description: 'PrepVanta spaced revision reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
    await ap.createNotificationChannel(
      const AndroidNotificationChannel(
        _kStarredChannel,
        'Starred Practice',
        description: 'Daily starred question practice',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await ap.createNotificationChannel(
      const AndroidNotificationChannel(
        _kGeneralChannel,
        'General',
        description: 'General PrepVanta notifications',
        importance: Importance.high,
        playSound: true,
      ),
    );
    await ap.createNotificationChannel(
      const AndroidNotificationChannel(
        _kAlarmChannel,
        'Math Alarm',
        description: 'Math wake-up alarm',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final ap = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await ap?.requestNotificationsPermission();
    await ap?.requestExactAlarmsPermission();
  }

  // ─────────────────────────────── FOREGROUND HANDLER ──────────────────────

  Future<void> _onForegroundResponse(NotificationResponse response) async {
    if (response.notificationResponseType ==
        NotificationResponseType.selectedNotificationAction) {
      if (response.input != null && response.input!.isNotEmpty) {
        await handleTypedAnswerAction(
            response.input!, response.id, response.payload);
      }
    } else if (response.notificationResponseType ==
        NotificationResponseType.notificationDismissed) {
      await handleNotificationDismissed(response.id, response.payload);
    } else {
      // selectedNotification — tap on body
      if (response.payload != null && response.payload!.isNotEmpty) {
        await handleNotificationPayload(response.payload!);
      }
    }
  }

  // ─────────────────────────────── BASIC SHOW / CANCEL ─────────────────────

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;
    if (_isAppInForeground) return; // suppress in foreground

    final prefs = await SharedPreferences.getInstance();
    if (!await _canSendNotification(prefs)) return;

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _kGeneralChannel,
          'General',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
    await _incrementDailyCount(prefs);
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await _plugin.cancelAll();
  }

  // ─────────────────────────────── STICKY RECALL ───────────────────────────

  Future<void> _showStickyRecallNotification({
    int? id,
    required String formula,
    required String correctAnswer,
    bool silent = false,
    String prefix = '',
  }) async {
    if (!_isInitialized) return;

    final payload = jsonEncode({
      'type': 'recall',
      'formula': formula,
      'correctAnswer': correctAnswer,
    });

    final targetId = id ?? getNotificationIdForPrompt(formula);

    final androidDetails = AndroidNotificationDetails(
      _kRecallChannel,
      'Spaced Recall',
      channelDescription: 'PrepVanta spaced revision reminders',
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      autoCancel: false,
      additionalFlags: Int32List.fromList([34]),
      category: AndroidNotificationCategory.reminder,
      dismissIsolate: NotificationDismissedIsolate.background,
      playSound: !silent,
      enableVibration: !silent,
      ticker: 'PrepVanta revision',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'SUBMIT_ANSWER',
          '✏️ Type Answer',
          showsUserInterface: false,
          cancelNotification: false,
          allowGeneratedReplies: false,
          inputs: <AndroidNotificationActionInput>[
            const AndroidNotificationActionInput(
              label: 'Type your answer…',
              allowFreeFormInput: true,
            ),
          ],
        ),
      ],
    );

    await _plugin.show(
      id: targetId,
      title: '$prefix📚 Revision: $formula = ?',
      body: 'Tap "✏️ Type Answer" below to solve here',
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // ─────────────────────────────── HANDLE DISMISSED ────────────────────────

  /// Called when notification is dismissed. Immediately re-posts right at present time.
  Future<void> handleNotificationDismissed(int? id, String? payload) async {
    if (payload == null || payload.isEmpty) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (data['type'] != 'recall') return;

    final formula = (data['formula'] as String?) ?? '';
    final correctAnswer = (data['correctAnswer'] as String?) ?? '';
    if (formula.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    if (_isSolved(prefs, formula)) return;

    // Immediately re-post at present time!
    final notifId = id ?? getNotificationIdForPrompt(formula);
    await _showStickyRecallNotification(
      id: notifId,
      formula: formula,
      correctAnswer: correctAnswer,
      silent: true,
    );
  }

  // ─────────────────────────────── HANDLE TYPED ANSWER ─────────────────────

  Future<void> handleTypedAnswerAction(
      String typedAnswer, int? id, String? payload) async {
    if (payload == null || payload.isEmpty) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final formula = (data['formula'] as String?) ?? '';
    final correctAnswer = (data['correctAnswer'] as String?) ?? '';
    if (formula.isEmpty) return;

    final targetId = id ?? getNotificationIdForPrompt(formula);

    if (_isAnswerCorrect(typedAnswer, correctAnswer)) {
      // ✅ Correct
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_kIsSolvedPrefix$formula', true);

      await _removePendingQueueEntry(formula);

      // CRITICAL FIX: Update the EXACT SAME targetId to stop the RemoteInput spinner!
      await _plugin.show(
        id: targetId,
        title: '🎉 Correct! $formula = $correctAnswer',
        body: 'Mistake resolved! Revision schedule updated.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _kRecallChannel,
            'Spaced Recall',
            importance: Importance.high,
            priority: Priority.high,
            ongoing: false,
            autoCancel: true,
            timeoutAfter: 3500,
          ),
        ),
      );

      onMistakeResolved?.call(formula, correctAnswer);

      // Advance to next stage
      final stage = prefs.getInt('$_kRepStagePrefix$formula') ?? 1;
      final originalStr = prefs.getString('$_kRecallOriginalPrefix$formula') ??
          DateTime.now().toIso8601String();
      final originalTime = DateTime.tryParse(originalStr) ?? DateTime.now();
      final nextStage = stage + 1;

      if (nextStage <= 8) {
        await prefs.setInt('$_kRepStagePrefix$formula', nextStage);
        await prefs.setBool('$_kIsSolvedPrefix$formula', false);
        final delayMin = _stageDelayMinutes(nextStage, originalTime);
        final dueAt = _applyQuietHours(
            DateTime.now().add(Duration(minutes: delayMin)));
        await prefs.setString(
            '$_kRecallDuePrefix$formula', dueAt.toIso8601String());
      } else {
        // All 8 stages done — mastered
        await prefs.setBool('$_kIsSolvedPrefix$formula', true);
        await _removePendingQueueEntry(formula);
        await notifyCalculationMastered(prompt: formula, answer: correctAnswer);
      }

      // Promote next question if queue has more items!
      final queue = prefs.getStringList(_kPendingQueue) ?? [];
      if (queue.isNotEmpty) {
        final nextParts = queue.first.split('|');
        final nextFormula = nextParts[0];
        final nextAns = nextParts.length > 1 ? nextParts[1] : '';
        await prefs.setString('currently_displayed_recall_formula', nextFormula);
        final nextDue = _applyQuietHours(DateTime.now().add(const Duration(minutes: 60)));
        await prefs.setString('$_kRecallDuePrefix$nextFormula', nextDue.toIso8601String());
        await _scheduleRecallAtTime(
          formula: nextFormula,
          correctAnswer: nextAns,
          dueAt: nextDue,
        );
      } else {
        await prefs.remove('currently_displayed_recall_formula');
      }
    } else {
      // ❌ Wrong — reshow with error on the EXACT SAME targetId to stop spinner and refresh prompt
      await _showStickyRecallNotification(
        id: targetId,
        formula: formula,
        correctAnswer: correctAnswer,
        silent: true,
        prefix: '❌ Wrong! Try again — ',
      );
    }
  }

  // ─────────────────────────────── HANDLE PAYLOAD (TAP) ────────────────────

  Future<void> handleNotificationPayload(String payload) async {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = (data['type'] as String?) ?? '';
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (type == 'recall') {
      Navigator.of(context).pushNamed(
        '/recall_solve',
        arguments: {
          'formula': data['formula'] ?? '',
          'correctAnswer': data['correctAnswer'] ?? '',
        },
      );
    }
  }

  // ─────────────────────────────── ENQUEUE SESSION MISTAKES ────────────────

  Future<void> enqueueSessionMistakesAndTrigger(
      List<MistakeModel> mistakes,
      {bool postImmediately = false}) async {
    if (mistakes.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final rawQueue = prefs.getStringList(_kPendingQueue) ?? [];
    final now = DateTime.now();

    // 1. Clean and deduplicate existing queue
    final List<String> queue = [];
    final Set<String> seen = {};
    for (final item in rawQueue) {
      final parts = item.split('|');
      if (parts.length < 2) continue;
      final f = cleanPrompt(parts[0]);
      if (f.isNotEmpty && !seen.contains(f) && !_isSolved(prefs, f)) {
        seen.add(f);
        queue.add('$f|${parts[1].trim()}');
      }
    }

    // 2. Add new unique mistakes
    for (final m in mistakes) {
      final formula = cleanPrompt(m.prompt);
      if (formula.isEmpty) continue;
      if (_isSolved(prefs, formula)) continue;

      if (!seen.contains(formula)) {
        seen.add(formula);
        queue.add('$formula|${m.correctAnswer.trim()}');
      }

      if (!prefs.containsKey('$_kRepStagePrefix$formula')) {
        await prefs.setInt('$_kRepStagePrefix$formula', 1);
        await prefs.setString(
            '$_kRecallOriginalPrefix$formula', now.toIso8601String());
      }
    }
    await prefs.setStringList(_kPendingQueue, queue);

    if (queue.isNotEmpty) {
      await prefs.setString('currently_displayed_recall_formula', queue.first.split('|')[0]);
    }

    // 3. Post / schedule every unique mistake together ("sb ko ak sath hi bhejo")
    for (final item in queue) {
      final parts = item.split('|');
      final formula = parts[0];
      final ans = parts.length > 1 ? parts[1] : '';
      final notifId = getNotificationIdForPrompt(formula);

      if (postImmediately) {
        await _showStickyRecallNotification(
          id: notifId,
          formula: formula,
          correctAnswer: ans,
        );
      } else {
        final dueAt =
            _applyQuietHours(now.add(const Duration(minutes: 60)));
        await prefs.setString(
            '$_kRecallDuePrefix$formula', dueAt.toIso8601String());
        await _scheduleRecallAtTime(
          id: notifId,
          formula: formula,
          correctAnswer: ans,
          dueAt: dueAt,
        );
      }
    }
  }

  // ─────────────────────────────── SCHEDULE CALCULATION MISTAKE ────────────

  Future<void> scheduleCalculationMistakeReminder({
    String? formula,
    String? prompt,
    required String correctAnswer,
    String? userAnswer,
    String? topicName,
    String? userName,
    bool postImmediately = false,
    int stage = 1,
    int delayMinutes = 60,
  }) async {
    final rawPrompt = formula ?? prompt ?? '';
    final cleaned = cleanPrompt(rawPrompt);
    if (cleaned.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    if (_isSolved(prefs, cleaned) &&
        (prefs.getInt('$_kRepStagePrefix$cleaned') ?? 1) >= 4) {
      return;
    }

    final now = DateTime.now();
    if (!prefs.containsKey('$_kRecallOriginalPrefix$cleaned')) {
      await prefs.setString(
          '$_kRecallOriginalPrefix$cleaned', now.toIso8601String());
    }
    await prefs.setInt('$_kRepStagePrefix$cleaned', stage);

    final dueAt = postImmediately
        ? now
        : applyQuietHoursGuard(now.add(Duration(minutes: delayMinutes)));
    await prefs.setString('$_kRecallDuePrefix$cleaned', dueAt.toIso8601String());

    final rawQueue = prefs.getStringList(_kPendingQueue) ?? [];
    final List<String> queue = [];
    final Set<String> seen = {};
    for (final item in rawQueue) {
      final parts = item.split('|');
      if (parts.length < 2) continue;
      final f = cleanPrompt(parts[0]);
      if (f.isNotEmpty && !seen.contains(f) && !_isSolved(prefs, f)) {
        seen.add(f);
        queue.add('$f|${parts[1].trim()}');
      }
    }

    final entry = '$cleaned|${correctAnswer.trim()}';
    if (!seen.contains(cleaned)) {
      seen.add(cleaned);
      queue.add(entry);
      await prefs.setStringList(_kPendingQueue, queue);
    }

    final currentActive = prefs.getString('currently_displayed_recall_formula');
    final bool isThisActive = currentActive == null || currentActive == cleaned;
    if (currentActive == null && queue.isNotEmpty) {
      await prefs.setString('currently_displayed_recall_formula', queue.first.split('|')[0]);
    }

    // Serial 1-by-1: ONLY post or schedule if this question is the active (first) in queue!
    if (isThisActive && queue.isNotEmpty && queue.first.split('|')[0] == cleaned) {
      if (postImmediately) {
        await _showStickyRecallNotification(
          id: _kActiveRecallNotificationId,
          formula: cleaned,
          correctAnswer: correctAnswer,
        );
      } else {
        await _scheduleRecallAtTime(
          formula: cleaned,
          correctAnswer: correctAnswer,
          dueAt: dueAt,
        );
      }
    }
  }

  // ─────────────────────────────── INTERNAL SCHEDULE HELPER ────────────────

  Future<void> _scheduleRecallAtTime({
    required String formula,
    required String correctAnswer,
    required DateTime dueAt,
    int? id,
  }) async {
    if (!_isInitialized) return;
    final targetId = id ?? getNotificationIdForPrompt(formula);
    final payload = jsonEncode({
      'type': 'recall',
      'formula': formula,
      'correctAnswer': correctAnswer,
    });

    try {
      await _plugin.zonedSchedule(
        id: targetId,
        title: '📚 Revision: $formula = ?',
        body: 'Tap "✏️ Type Answer" below to solve here',
        scheduledDate: _tzFrom(dueAt),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _kRecallChannel,
            'Spaced Recall',
            importance: Importance.max,
            priority: Priority.max,
            ongoing: true,
            autoCancel: false,
            additionalFlags: Int32List.fromList([34]),
            category: AndroidNotificationCategory.reminder,
            dismissIsolate: NotificationDismissedIsolate.background,
            actions: const <AndroidNotificationAction>[
              AndroidNotificationAction(
                'SUBMIT_ANSWER',
                '✏️ Type Answer',
                showsUserInterface: false,
                cancelNotification: false,
                allowGeneratedReplies: false,
                inputs: <AndroidNotificationActionInput>[
                  AndroidNotificationActionInput(
                    label: 'Type your answer…',
                    allowFreeFormInput: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[NotificationService] zonedSchedule error: $e');
    }
  }

  // ─────────────────────────────── RESCHEDULE ALL PENDING ──────────────────

  Future<void> rescheduleAllPendingMistakeAlarms() async {
    if (!_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();

    // 1. Cancel any active notification
    await cancelNotification(_kActiveRecallNotificationId);

    // 2. Read and deduplicate queue
    final rawQueue = prefs.getStringList(_kPendingQueue) ?? [];
    final List<String> queue = [];
    final Set<String> seen = {};
    for (final item in rawQueue) {
      final parts = item.split('|');
      if (parts.length < 2) continue;
      final f = cleanPrompt(parts[0]);
      if (f.isEmpty || seen.contains(f) || _isSolved(prefs, f)) continue;
      seen.add(f);
      queue.add('$f|${parts[1].trim()}');
    }
    await prefs.setStringList(_kPendingQueue, queue);

    if (queue.isEmpty) {
      await prefs.remove('currently_displayed_recall_formula');
      return;
    }

    // 3. Take ONLY the single active item (queue.first)
    final parts = queue.first.split('|');
    final formula = parts[0];
    final correctAnswer = parts[1];
    await prefs.setString('currently_displayed_recall_formula', formula);

    // Respect snooze
    final snoozeStr = prefs.getString('$_kSnoozeUntilPrefix$formula');
    if (snoozeStr != null) {
      final until = DateTime.tryParse(snoozeStr);
      if (until != null && DateTime.now().isBefore(until)) {
        await _scheduleRecallAtTime(
          formula: formula,
          correctAnswer: correctAnswer,
          dueAt: until,
        );
        return;
      }
    }

    final dueStr = prefs.getString('$_kRecallDuePrefix$formula');
    DateTime dueAt;
    if (dueStr != null) {
      dueAt = DateTime.tryParse(dueStr) ??
          DateTime.now().add(const Duration(hours: 1));
    } else {
      dueAt = DateTime.now().add(const Duration(hours: 1));
    }

    // If overdue by >10 min, trigger soon (only this ONE single question)
    if (dueAt.isBefore(DateTime.now().subtract(const Duration(minutes: 10)))) {
      dueAt = _applyQuietHours(DateTime.now().add(const Duration(minutes: 5)));
    }

    await _scheduleRecallAtTime(
      formula: formula,
      correctAnswer: correctAnswer,
      dueAt: dueAt,
    );
  }

  // ─────────────────────────────── FORCE POST ALL NOW ──────────────────────

  Future<int> forcePostAllPendingMistakesNow() async {
    if (!_isInitialized) return 0;
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_kPendingQueue) ?? [];
    if (queue.isEmpty) return 0;

    int posted = 0;
    for (final item in queue) {
      final parts = item.split('|');
      if (parts.length < 2) continue;
      final formula = parts[0];
      final correctAnswer = parts[1];
      if (_isSolved(prefs, formula)) continue;

      final notifId = getNotificationIdForPrompt(formula);
      await _showStickyRecallNotification(
        id: notifId,
        formula: formula,
        correctAnswer: correctAnswer,
      );
      posted++;
    }
    return posted;
  }

  // ─────────────────────────────── MASTERED ────────────────────────────────

  Future<void> notifyCalculationMastered({
    required String prompt,
    String? answer,
    String? correctAnswer,
    String? userName,
    String? nextPrompt,
    String? nextAnswer,
  }) async {
    if (!_isInitialized) return;
    final finalAnswer = answer ?? correctAnswer ?? '';
    await _plugin.show(
      id: _kMasteredId,
      title: '🎉 Mastered!',
      body: "$prompt = $finalAnswer  •  You've nailed this one!",
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _kGeneralChannel,
          'General',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ─────────────────────────────── STARRED TABLES ──────────────────────────

  Future<void> scheduleStarredTableNotification(
      int tableNum, {bool onlyIfNotScheduled = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_starred_table_number', tableNum);
    final formula = '$tableNum × 2';
    await prefs.setInt('$_kRepStagePrefix$formula', 1);
    final due = DateTime.now().add(const Duration(minutes: 60));
    await prefs.setString('$_kRecallDuePrefix$formula', due.toIso8601String());

    if (!_isInitialized) return;
    final starredTables = prefs.getStringList(_kStarredTables) ?? [];

    if (!starredTables.contains(tableNum.toString())) {
      starredTables.add(tableNum.toString());
      await prefs.setStringList(_kStarredTables, starredTables);
    }

    if (onlyIfNotScheduled) {
      final lastScheduled =
          prefs.getString('starred_daily_last_scheduled') ?? '';
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (lastScheduled == today) return;
    }

    final allStarred =
        starredTables.map((s) => int.tryParse(s) ?? 0).toList();
    if (allStarred.isEmpty) return;

    final offset = prefs.getInt(_kRotationOffset) ?? 0;
    final batch = <int>[];
    for (int i = 0; i < 5 && i < allStarred.length; i++) {
      batch.add(allStarred[(offset + i) % allStarred.length]);
    }
    await prefs.setInt(_kRotationOffset, (offset + 5) % allStarred.length);
    await prefs.setString('starred_daily_last_scheduled',
        DateTime.now().toIso8601String().substring(0, 10));

    var scheduleTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0);
    if (scheduleTime.isBefore(DateTime.now())) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }
    scheduleTime = _applyQuietHours(scheduleTime);

    try {
      await _plugin.zonedSchedule(
        id: _kStarredDailyId,
        title: '⭐ Daily Starred Practice',
        body: 'Practise tables: ${batch.join(', ')}  •  Tap to start',
        scheduledDate: _tzFrom(scheduleTime),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _kStarredChannel,
            'Starred Practice',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload:
            jsonEncode({'type': 'starred', 'tables': batch}),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[NotificationService] starred schedule error: $e');
    }
  }

  Future<void> cancelStarredTableNotification(int tableNum) async {
    if (!_isInitialized) return;
    if (tableNum == 0) {
      await _plugin.cancel(id: _kStarredDailyId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStarredTables);
      await prefs.remove(_kRotationOffset);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final starredTables = prefs.getStringList(_kStarredTables) ?? [];
    starredTables.remove(tableNum.toString());
    await prefs.setStringList(_kStarredTables, starredTables);
    if (starredTables.isEmpty) {
      await _plugin.cancel(id: _kStarredDailyId);
    }
  }

  // ─────────────────────────────── 3-DAY RECALL ────────────────────────────

  Future<void> schedule3DayTableRecallNotification(int tableNumber) async {
    if (!_isInitialized) return;
    final dueAt =
        _applyQuietHours(DateTime.now().add(const Duration(days: 3)));
    try {
      await _plugin.zonedSchedule(
        id: 8000 + tableNumber,
        title: '🔄 Table $tableNumber Recall',
        body: 'Time to revise Table $tableNumber!  •  Tap to practise',
        scheduledDate: _tzFrom(dueAt),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _kRecallChannel,
            'Spaced Recall',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(
            {'type': 'table_recall', 'tableNumber': tableNumber}),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[NotificationService] 3-day table recall error: $e');
    }
  }

  // ─────────────────────────────── STUDY PLAN ──────────────────────────────

  Future<void> scheduleStudyPlanReminder({
    required dynamic plan,
    String userName = 'Aspirant',
  }) async {
    if (!_isInitialized) return;
    await cancelStudyPlanReminder();

    String topicTitle;
    try {
      topicTitle = (plan.topicTitle as String?) ?? plan.toString();
    } catch (_) {
      topicTitle = plan.toString();
    }

    DateTime scheduleAt;
    try {
      final t = plan.targetTime as DateTime;
      scheduleAt = t.subtract(const Duration(minutes: 15));
      if (scheduleAt.isBefore(DateTime.now())) {
        scheduleAt = DateTime.now().add(const Duration(hours: 1));
      }
    } catch (_) {
      scheduleAt = DateTime.now().add(const Duration(hours: 1));
    }
    scheduleAt = _applyQuietHours(scheduleAt);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kActiveStudyPlan, jsonEncode({'topicTitle': topicTitle, 'userName': userName}));

    try {
      await _plugin.zonedSchedule(
        id: _kStudyPlanId,
        title: '📅 Study Plan — $userName',
        body: 'Time to study: $topicTitle',
        scheduledDate: _tzFrom(scheduleAt),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _kGeneralChannel,
            'General',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[NotificationService] study plan schedule error: $e');
    }
  }

  Future<void> cancelStudyPlanReminder() async {
    if (!_isInitialized) return;
    await _plugin.cancel(id: _kStudyPlanId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveStudyPlan);
  }

 
  /// Stub — compiles cleanly, returns 0.
  Future<int> scheduleTopicConceptReminders(TopicType topicType) async {
    return 0;
  }


  Future<void> scheduleMathWakeUpAlarm({
    required int hour,
    required int minute,
    String label = 'Math Alarm',
  }) async {
    if (!_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kMathAlarmHour, hour);
    await prefs.setInt(_kMathAlarmMinute, minute);

    final now = DateTime.now();
    var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id: _kMathAlarmId,
        title: '⏰ $label',
        body: 'Wake up and solve a quick maths problem!',
        scheduledDate: _tzFrom(alarmTime),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _kAlarmChannel,
            'Math Alarm',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
          ),
        ),
        payload: jsonEncode({'type': 'math_alarm', 'label': label}),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // daily repeat
      );
    } catch (e) {
      debugPrint('[NotificationService] math alarm schedule error: $e');
    }
  }

  Future<void> cancelMathWakeUpAlarm() async {
    if (!_isInitialized) return;
    await _plugin.cancel(id: _kMathAlarmId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kMathAlarmHour);
    await prefs.remove(_kMathAlarmMinute);
  }

  Future<void> triggerMathAlarmNotification(
      {String label = 'Math Wake-Up Alarm'}) async {
    if (!_isInitialized) return;
    await _plugin.show(
      id: _kMathAlarmId,
      title: '⏰ $label',
      body: 'Solve a maths problem to dismiss!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _kAlarmChannel,
          'Math Alarm',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
        ),
      ),
      payload: jsonEncode({'type': 'math_alarm', 'label': label}),
    );
  }


  Future<void> triggerAdminBroadcast({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) return;
    await _plugin.show(
      id: _kAdminBroadcastId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _kGeneralChannel,
          'General',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }


  Future<void> setDailyNotificationLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDailyLimit, limit);
  }

  /// Trigger an instant test notification using the user's real mistake from notebook/queue.
  /// Strictly NO hardcoded formula. Returns true if a real mistake was posted.
  Future<bool> triggerInstantTestNotification() async {
    if (!_isInitialized) return false;
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_kPendingQueue) ?? [];

    String formula = '';
    String correctAnswer = '';

    if (queue.isNotEmpty) {
      final parts = queue.first.split('|');
      formula = parts[0];
      if (parts.length > 1) correctAnswer = parts[1];
    } else {
      final mistJson = prefs.getStringList('mistakes_list') ?? [];
      if (mistJson.isNotEmpty) {
        try {
          final first = jsonDecode(mistJson.first);
          formula = cleanPrompt(first['prompt'] ?? '');
          correctAnswer = first['correctAnswer'] ?? '';
        } catch (_) {}
      }
    }

    if (formula.isNotEmpty && correctAnswer.isNotEmpty) {
      await _showStickyRecallNotification(
        id: _kInstantTestId,
        formula: formula,
        correctAnswer: correctAnswer,
      );
      return true;
    }
    return false;
  }


  Future<void> _removePendingQueueEntry(String formula) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_kPendingQueue) ?? [];
    final target = cleanPrompt(formula);
    queue.removeWhere((e) => cleanPrompt(e.split('|')[0]) == target || e == formula);
    await prefs.setStringList(_kPendingQueue, queue);

    if (queue.isNotEmpty) {
      final nextFormula = queue.first.split('|')[0];
      await prefs.setString('currently_displayed_recall_formula', nextFormula);
    } else {
      await prefs.remove('currently_displayed_recall_formula');
    }
  }
}
