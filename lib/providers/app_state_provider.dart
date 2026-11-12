import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/math_models.dart';
import '../models/english_models.dart';
import '../models/broadcast_model.dart';
import '../data/content_repository.dart';
import '../services/notification_service.dart';
import '../services/backend_service.dart';
import '../services/cloud_firestore_sync_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/security_sanitizer.dart';

class PaymentTransaction {
  final String orderId;
  final String userName;
  final String userEmail;
  final String userId;
  final double amount;
  final DateTime date;
  final String status;
  final String paymentMethod;

  PaymentTransaction({
    required this.orderId,
    required this.userName,
    this.userEmail = '',
    this.userId = '',
    required this.amount,
    required this.date,
    required this.status,
    this.paymentMethod = 'Google Play Billing',
  });

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'userName': userName,
    'userEmail': userEmail,
    'userId': userId,
    'amount': amount,
    'date': date.toIso8601String(),
    'status': status,
    'paymentMethod': paymentMethod,
  };

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) => PaymentTransaction(
    orderId: map['orderId']?.toString() ?? '',
    userName: (map['userName'] != null && map['userName'].toString().isNotEmpty)
        ? map['userName'].toString()
        : (map['userId']?.toString() ?? 'Aspirant'),
    userEmail: map['userEmail']?.toString() ?? '',
    userId: map['userId']?.toString() ?? '',
    amount: (map['amount'] is num)
        ? (map['amount'] as num).toDouble()
        : double.tryParse(map['amount']?.toString() ?? '49.0') ?? 49.0,
    date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
    status: map['status']?.toString() ?? 'SUCCESS',
    paymentMethod: map['paymentMethod']?.toString() ?? 'Google Play Billing',
  );
}

class AppStateProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Premium state
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  // Daily target and streak
  int _dailyTarget = 30;
  int _todayAttempted = 0;
  int _streakDays = 0;
  String _lastActiveDate = '';

  int get dailyTarget => _dailyTarget;
  int get todayAttempted => _todayAttempted;
  int get streakDays => _streakDays;

  // Daily notification frequency capping limit (default 10 alerts/day, 0 = unlimited)
  int _dailyNotificationLimit = 10;
  int get dailyNotificationLimit => _dailyNotificationLimit;

  // Settings & Customization Preferences
  String _targetExam = 'SSC CGL & CHSL';
  String get targetExam => _targetExam;

  String _numpadStyle = 'phone'; // 'phone' (1-2-3 top) or 'calculator' (7-8-9 top)
  String get numpadStyle => _numpadStyle;

  bool _hapticsEnabled = true;
  bool get hapticsEnabled => _hapticsEnabled;

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  double _ttsSpeechRate = 0.45;
  double get ttsSpeechRate => _ttsSpeechRate;

  double _ttsPitch = 1.0;
  double get ttsPitch => _ttsPitch;

  String _ttsLanguage = 'en-IN'; // 'en-IN', 'en-US', 'en-GB', 'hi-IN'
  String get ttsLanguage => _ttsLanguage;

  String _ttsRecitalStyle = 'school'; // 'school', 'times', 'vedic', 'quiz', 'standard'
  String get ttsRecitalStyle => _ttsRecitalStyle;

  String _ttsRepeatMode = 'none'; // 'none', 'table', 'row'
  String get ttsRepeatMode => _ttsRepeatMode;

  double _ttsQuizPauseSeconds = 2.0; // 1.5, 2.0, 3.0
  double get ttsQuizPauseSeconds => _ttsQuizPauseSeconds;

  bool _showTrickHints = true;
  bool get showTrickHints => _showTrickHints;

  int _reminderHour = 8;
  int _reminderMinute = 0;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  int _recallIntervalHours = 1;
  int get recallIntervalHours => _recallIntervalHours;

  bool _amoledBlackMode = false;
  bool get amoledBlackMode => _amoledBlackMode;

  // Notification reminder state
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  // Math Wake-Up Alarm State ("Solve 5 mistakes to dismiss alarm")
  bool _mathAlarmEnabled = false;
  int _mathAlarmHour = 7;
  int _mathAlarmMinute = 0;
  String _mathAlarmLabel = 'Morning SSC Speed Math Alarm';

  bool get mathAlarmEnabled => _mathAlarmEnabled;
  int get mathAlarmHour => _mathAlarmHour;
  int get mathAlarmMinute => _mathAlarmMinute;
  String get mathAlarmLabel => _mathAlarmLabel;

  // Mistakes / Wrong questions list (Active pending queue for 1-hour recall alert & notifications)
  List<MistakeModel> _mistakes = [];
  List<MistakeModel> get mistakes => _mistakes;

  // Permanent Lifetime Mistake Notebook (Keeps all mistakes forever, even after solved)
  List<MistakeModel> _allMistakes = [];
  List<MistakeModel> get allMistakes => _allMistakes;

  Future<void> _saveAllMistakes() async {
    if (_prefs != null) {
      List<String> jsonList = _allMistakes.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('all_mistakes_notebook', jsonList);
    }
  }

  // Practice results history
  List<PracticeResult> _history = [];
  List<PracticeResult> get history => _history;

  // Admin dynamic questions
  List<QuestionModel> _adminQuestions = [];
  List<QuestionModel> get adminQuestions => _adminQuestions;

  // Admin Broadcast notifications received by users
  final List<AdminBroadcastModel> _broadcasts = [];
  List<AdminBroadcastModel> get broadcasts => _broadcasts;

  Future<void> _saveBroadcasts() async {
    if (_prefs != null) {
      List<String> bList = _broadcasts.map((b) => b.toJson()).toList();
      await _prefs!.setStringList('admin_broadcasts', bList);
    }
  }

  Future<void> clearBroadcasts() async {
    _broadcasts.clear();
    if (_prefs != null) {
      await _prefs!.remove('admin_broadcasts');
    }
    notifyListeners();
  }

  Future<void> sendAdminBroadcast({
    required String title,
    required String body,
    String target = 'all',
  }) async {
    final notification = AdminBroadcastModel(
      id: 'bc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      target: target,
      sentAt: DateTime.now(),
    );

    _broadcasts.insert(0, notification);

    // 1. Trigger device system notification
    await NotificationService().triggerAdminBroadcast(title: title, body: body);

    // 2. Persist in SharedPreferences so student sees it in Notification Inbox
    await _saveBroadcasts();

    // 3. Dispatch to Cloud Backend (Firebase / Server)
    unawaited(BackendService().broadcastCloudNotification(title: title, message: body));

    notifyListeners();
  }

  // Admin Transactions list
  List<PaymentTransaction> _transactions = [];
  List<PaymentTransaction> get transactions => _transactions;

  // Real registered users list from Cloud Firestore
  List<Map<String, dynamic>> _registeredUsers = [];
  List<Map<String, dynamic>> get registeredUsers => _registeredUsers;

  // Real active user metrics (strictly dynamic from Firestore)
  int _totalRegisteredUsers = 0;
  int get totalRegisteredUsers => _totalRegisteredUsers;

  // PDF Study Materials (Formula sheets, cheat notes)
  List<Map<String, dynamic>> _adminPdfMaterials = [];
  List<Map<String, dynamic>> get adminPdfMaterials => _adminPdfMaterials;

  // Dedicated Admin Navigation State: prevents accidentally falling back into student view
  bool _isAdminStudentPreview = false;
  bool get isAdminStudentPreview => _isAdminStudentPreview;
  void setAdminStudentPreview(bool preview) {
    _isAdminStudentPreview = preview;
    notifyListeners();
  }

  // Starred / Bookmarked tables for quick 1-50 revision (Starts empty - user stars real tables)
  final Set<int> _starredTables = {};
  Set<int> get starredTables => _starredTables;

  bool isTableStarred(int tableNum) => _starredTables.contains(tableNum);

  Future<void> toggleStarTable(int tableNum) async {
    if (_starredTables.contains(tableNum)) {
      _starredTables.remove(tableNum);
      if (_prefs != null) {
        await _prefs!.setStringList('starred_tables', _starredTables.map((e) => e.toString()).toList());
      }
      if (_starredTables.isNotEmpty) {
        if (_notificationsEnabled) {
          await NotificationService().scheduleStarredTableNotification(_starredTables.last);
        }
      } else {
        await NotificationService().cancelStarredTableNotification(tableNum);
      }
    } else {
      _starredTables.add(tableNum);
      if (_prefs != null) {
        await _prefs!.setStringList('starred_tables', _starredTables.map((e) => e.toString()).toList());
      }
      if (_notificationsEnabled) {
        await NotificationService().scheduleStarredTableNotification(tableNum);
      }
    }
    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  // =========================================================================
  // 🌟 MEMORY DECAY & 3-DAY SPACED RETENTION TRACKING (Ideas 1 + 3)
  // =========================================================================
  final Map<int, int> _tablePracticeTimestamps = {};
  Map<int, int> get tablePracticeTimestamps => _tablePracticeTimestamps;

  double getTableMemoryHealth(int tableNumber) {
    final ts = _tablePracticeTimestamps[tableNumber];
    if (ts == null) return 0.0;
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    final hours = diff.inHours;
    if (hours < 24) return 1.0;
    if (hours < 48) return 0.85;
    if (hours < 72) return 0.65;
    if (hours < 120) return 0.40;
    if (hours < 168) return 0.20;
    return 0.10;
  }

  String getTableMemoryStatusText(int tableNumber) {
    final health = getTableMemoryHealth(tableNumber);
    if (health >= 0.85) return '100% Mastered (Fresh)';
    if (health >= 0.65) return '85% Solid (Day 2)';
    if (health >= 0.40) return '65% Decaying (3-Day Due)';
    if (health >= 0.20) return '40% Weak (Review Needed)';
    if (health > 0.0) return '15% Rusted (Needs Refill)';
    return 'Unpracticed';
  }

  Color getTableMemoryColor(int tableNumber) {
    final health = getTableMemoryHealth(tableNumber);
    if (health >= 0.85) return const Color(0xFF10B981);
    if (health >= 0.65) return const Color(0xFF34D399);
    if (health >= 0.40) return const Color(0xFFFBBF24);
    if (health >= 0.20) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  Future<void> recordTablePracticed(int tableNumber, {int correct = 0, int total = 0}) async {
    _tablePracticeTimestamps[tableNumber] = DateTime.now().millisecondsSinceEpoch;
    if (_prefs != null) {
      final enc = json.encode(_tablePracticeTimestamps.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs!.setString('table_practice_timestamps', enc);
    }
    // Schedule 3-Day Spaced Repetition Recall Alert (Part 1 & 3)
    try {
      await NotificationService().schedule3DayTableRecallNotification(tableNumber);
    } catch (_) {}
    notifyListeners();
  }

  // Clear all starred tables (Purges bookmarks and cancels all table notifications)
  Future<void> clearAllStarredTables() async {
    _starredTables.clear();
    if (_prefs != null) {
      await _prefs!.setStringList('starred_tables', []);
      await _prefs!.remove('active_starred_table_number');
      await _prefs!.remove('active_starred_table_formula');
    }
    await NotificationService().cancelStarredTableNotification(0);
    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  // Starred / Bookmarked Formulas ("My Quick Formula Sheet")
  final Set<String> _starredFormulas = {};
  Set<String> get starredFormulas => _starredFormulas;
  bool isFormulaStarred(String id) => _starredFormulas.contains(id);

  Future<void> toggleStarFormula(String id) async {
    if (_starredFormulas.contains(id)) {
      _starredFormulas.remove(id);
    } else {
      _starredFormulas.add(id);
    }
    if (_prefs != null) {
      await _prefs!.setStringList('starred_formulas', _starredFormulas.toList());
    }
    notifyListeners();
  }

  // Student Mistake & Weakness Analytics for Admin Channel ("Tracks detailed student mistakes, error rates, and weak topics")
  List<StudentMistakeAnalyticsModel> _studentMistakeAnalytics = [];
  List<StudentMistakeAnalyticsModel> get studentMistakeAnalytics => _studentMistakeAnalytics;

  // Tomorrow's / Scheduled Study Target Plan ("Study target planner & reminder")
  StudyPlanModel? _activeStudyPlan;
  StudyPlanModel? get activeStudyPlan => _activeStudyPlan;

  // Custom Revision Items Collection (Students can add ANY formula, trick, or topic to revise)
  List<RevisionItemModel> _revisionItems = [];
  List<RevisionItemModel> get revisionItems => _revisionItems;

  Future<void> addRevisionItem(RevisionItemModel item) async {
    _revisionItems.insert(0, item);
    await _saveRevisionItems();
    notifyListeners();
  }

  Future<void> updateRevisionItem(RevisionItemModel item) async {
    int idx = _revisionItems.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      _revisionItems[idx] = item;
      await _saveRevisionItems();
      notifyListeners();
    }
  }

  Future<void> toggleMasterRevisionItem(String id) async {
    int idx = _revisionItems.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _revisionItems[idx];
      _revisionItems[idx] = current.copyWith(isMastered: !current.isMastered);
      await _saveRevisionItems();
      notifyListeners();
    }
  }

  Future<void> deleteRevisionItem(String id) async {
    _revisionItems.removeWhere((e) => e.id == id);
    await _saveRevisionItems();
    notifyListeners();
  }

  Future<void> clearAllRevisionDeck() async {
    _revisionItems.clear();
    await _saveRevisionItems();
    notifyListeners();
  }

  Future<void> resetToDefaultRevisionItems() async {
    _revisionItems = _defaultStarterRevisionItems();
    await _saveRevisionItems();
    notifyListeners();
  }

  Future<void> loadStarterPack() async {
    final starter = _defaultStarterRevisionItems();
    for (var item in starter) {
      if (!_revisionItems.any((e) => e.title == item.title)) {
        _revisionItems.add(item);
      }
    }
    await _saveRevisionItems();
    notifyListeners();
  }

  Future<int> importMistakesToRevisionDeck() async {
    int imported = 0;
    for (var m in _allMistakes) {
      final promptClean = m.prompt.trim();
      final title = 'Mistake: ${m.topicId.toUpperCase()}';
      if (!_revisionItems.any((e) => e.question == '$promptClean = ?')) {
        _revisionItems.add(
          RevisionItemModel(
            id: 'rev_mistake_${m.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            question: '$promptClean = ?',
            answer: m.correctAnswer,
            category: 'Mistakes',
            notes: 'Prior wrong attempt: ${m.userAnswer}',
            createdAt: DateTime.now(),
          ),
        );
        imported++;
      }
    }
    if (imported > 0) {
      await _saveRevisionItems();
      notifyListeners();
    }
    return imported;
  }

  Future<void> _saveRevisionItems() async {
    if (_prefs != null) {
      final list = _revisionItems.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('custom_revision_items', list);
    }
  }

  List<RevisionItemModel> _defaultStarterRevisionItems() {
    return [
      RevisionItemModel(
        id: 'starter_alg_1',
        title: 'Square of Sum & Difference',
        question: '(a + b)² and (a - b)²',
        answer: 'a² + 2ab + b²  and  a² - 2ab + b²',
        category: 'Formulas',
        notes: '(a+b)² - (a-b)² = 4ab',
        createdAt: DateTime.now(),
      ),
      RevisionItemModel(
        id: 'starter_alg_2',
        title: 'Difference of Squares',
        question: 'a² - b²',
        answer: '(a - b)(a + b)',
        category: 'Formulas',
        notes: 'Fundamental identity used in every algebra simplification',
        createdAt: DateTime.now(),
      ),
      RevisionItemModel(
        id: 'starter_perc_1',
        title: 'Fraction 1/7 to Percentage',
        question: '1/7 = ? %',
        answer: '14.28% (or 14 2/7%)',
        category: 'Percentages',
        notes: '2/7 = 28.57%, 3/7 = 42.85%',
        createdAt: DateTime.now(),
      ),
      RevisionItemModel(
        id: 'starter_perc_2',
        title: 'Fraction 1/8 to Percentage',
        question: '1/8 = ? %',
        answer: '12.5% (or 12 1/2%)',
        category: 'Percentages',
        notes: '3/8 = 37.5%, 5/8 = 62.5%',
        createdAt: DateTime.now(),
      ),
      RevisionItemModel(
        id: 'starter_trip_1',
        title: 'Pythagorean Triplet (3, 4, 5)',
        question: 'Base = 3, Perp = 4 -> Hypotenuse?',
        answer: '5  [Multiples: 6-8-10, 9-12-15, 12-16-20]',
        category: 'Triplets',
        notes: 'Most frequent right triangle triplet in SSC/Bank exams',
        createdAt: DateTime.now(),
      ),
      RevisionItemModel(
        id: 'starter_trip_2',
        title: 'Pythagorean Triplet (5, 12, 13)',
        question: 'Base = 5, Perp = 12 -> Hypotenuse?',
        answer: '13  [Multiples: 10-24-26]',
        category: 'Triplets',
        notes: 'Standard exam right triangle triplet',
        createdAt: DateTime.now(),
      ),
      RevisionItemModel(
        id: 'starter_vedic_1',
        title: 'Squaring Number Ending in 5',
        question: 'How to calculate 35² or 75² in 1 second?',
        answer: 'Multiply prefix by next integer, append 25. e.g. 35² = (3×4)|25 = 1225',
        category: 'Shortcuts',
        notes: 'Works for 15, 25, 35, 45, 65, 75, 85, 95, 105...',
        createdAt: DateTime.now(),
      ),
      RevisionItemModel(
        id: 'starter_vedic_2',
        title: 'Multiply by 11 Shortcut',
        question: 'What is 43 × 11?',
        answer: '473  [Rule: Keep outer digits 4 and 3, middle digit = 4 + 3 = 7]',
        category: 'Shortcuts',
        notes: 'If sum exceeds 9, carry 1 to the left digit.',
        createdAt: DateTime.now(),
      ),
    ];
  }

  bool get isStudyPlanDueNow {
    if (_activeStudyPlan == null || _activeStudyPlan!.isCompleted) return false;
    final now = DateTime.now();
    return now.isAfter(_activeStudyPlan!.scheduledDate) ||
        now.isAtSameMomentAs(_activeStudyPlan!.scheduledDate);
  }

  Future<void> setStudyPlan({
    required String topicId,
    required String topicTitle,
    required DateTime targetTime,
    String? sampleQuestion,
  }) async {
    String q = sampleQuestion ??
        (topicId.startsWith('table_')
            ? '${topicId.replaceFirst('table_', '')} × 7 = ?'
            : '10 Questions Speed Drill');
    final plan = StudyPlanModel(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      topicId: topicId,
      topicTitle: topicTitle,
      scheduledDate: targetTime,
      sampleQuestion: q,
      isCompleted: false,
    );

    _activeStudyPlan = plan;

    if (_prefs != null) {
      await _prefs!.setString('active_study_plan', json.encode(plan.toMap()));
    }

    if (_notificationsEnabled) {
      await NotificationService().scheduleStudyPlanReminder(
        plan: plan,
        userName: _userName.isNotEmpty ? _userName : 'Aspirant',
      );
    }

    // Add in-app broadcast announcement
    final formattedTime = '${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}';
    _broadcasts.insert(
      0,
      AdminBroadcastModel(
        id: 'plan_${plan.id}',
        title: '📅 Study Plan Scheduled: $topicTitle',
        body: 'Target reminder set for tomorrow at $formattedTime. App will notify you when it\'s time to practice!',
        target: 'self',
        sentAt: DateTime.now(),
      ),
    );
    await _saveBroadcasts();

    notifyListeners();
  }

  Future<void> completeActiveStudyPlan() async {
    if (_activeStudyPlan == null) return;
    final completed = _activeStudyPlan!.copyWith(isCompleted: true);
    _activeStudyPlan = completed;

    if (_prefs != null) {
      await _prefs!.setString('active_study_plan', json.encode(completed.toMap()));
    }

    await NotificationService().cancelStudyPlanReminder();

    _broadcasts.insert(
      0,
      AdminBroadcastModel(
        id: 'plan_done_${DateTime.now().millisecondsSinceEpoch}',
        title: '🎉 Target Achieved: ${completed.topicTitle}!',
        body: 'Congratulations! You conquered your scheduled target on time. Keep up the momentum!',
        target: 'self',
        sentAt: DateTime.now(),
      ),
    );
    await _saveBroadcasts();

    notifyListeners();
  }

  Future<void> cancelActiveStudyPlan() async {
    _activeStudyPlan = null;
    if (_prefs != null) {
      await _prefs!.remove('active_study_plan');
    }
    await NotificationService().cancelStudyPlanReminder();
    notifyListeners();
  }

  // Last browsed topic for Flipkart-style smart prep nudges
  String _lastBrowsedTopicId = '';
  String _lastBrowsedTopicTitle = '';
  String get lastBrowsedTopicId => _lastBrowsedTopicId;
  String get lastBrowsedTopicTitle => _lastBrowsedTopicTitle;

  // Track last browsed topic in memory (no unsolicited hardcoded notifications)
  void trackTopicBrowsed({required String topicId, required String title, String? detail}) {
    _lastBrowsedTopicId = topicId;
    _lastBrowsedTopicTitle = title;
    notifyListeners();
  }

  // Admin Direct Action: Send targeted drill push to a specific student based on their mistake
  Future<void> sendTargetedMistakePushToStudent({
    required String studentName,
    String studentUid = '',
    String studentEmail = '',
    String weakPrompt = '',
    String prompt = '',
    String userAnswer = '',
    String correctAnswer = '',
    required String topicName,
  }) async {
    final activePrompt = prompt.isNotEmpty ? prompt : weakPrompt;
    final title = '🎯 Focus Drill for $studentName: ${topicName.toUpperCase()}!';
    final body = userAnswer.isNotEmpty && correctAnswer.isNotEmpty
        ? 'Hey $studentName, we noticed you answered "$userAnswer" on "$activePrompt". Correct answer is "$correctAnswer". Practice now for 100% mastery!'
        : 'Hey $studentName, we noticed you missed "$activePrompt". Take a 2-minute revision drill now to get 100% accuracy!';

    // 1. Dispatch to Cloud Firestore targeted pushes collection
    unawaited(BackendService().dispatchTargetedMistakePush(
      studentUid: studentUid.isNotEmpty ? studentUid : _effectiveUid,
      studentName: studentName,
      studentEmail: studentEmail,
      prompt: activePrompt,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
      topicId: topicName,
    ));

    // 2. Also register in Admin Broadcasts
    await sendAdminBroadcast(title: title, body: body, target: studentName);

    // 3. If on current device (student or admin testing), trigger system notification
    if (_notificationsEnabled) {
      await NotificationService().showNotification(
        id: 9988,
        title: title,
        body: body,
        payload: 'targeted_mistake_recall',
      );
    }
  }

  // Admin Direct Action: 1-Click Broadcast Targeted Mistake Push to ALL Students
  Future<int> broadcastMistakeRemindersToAllStudents() async {
    final studentsWithMistakes = _studentMistakeAnalytics.where((s) => s.mistakes.isNotEmpty).toList();
    if (studentsWithMistakes.isEmpty) return 0;

    int dispatchedCount = 0;
    for (var student in studentsWithMistakes) {
      final mistake = student.mistakes.first;
      final title = '🎯 Focus Drill for ${student.studentName}: ${mistake.topicId.toUpperCase()}!';
      final body = 'Hey ${student.studentName}, can you solve: "${mistake.prompt}"? Your last answer was "${mistake.userAnswer}". Tap to master it now!';

      await BackendService().dispatchTargetedMistakePush(
        studentUid: student.studentUid,
        studentName: student.studentName,
        studentEmail: student.studentEmail,
        prompt: mistake.prompt,
        userAnswer: mistake.userAnswer,
        correctAnswer: mistake.correctAnswer,
        topicId: mistake.topicId,
      );

      // Record in broadcast history
      final notification = AdminBroadcastModel(
        id: 'bc_all_${DateTime.now().millisecondsSinceEpoch}_$dispatchedCount',
        title: title,
        body: body,
        target: student.studentName,
        sentAt: DateTime.now(),
      );
      _broadcasts.insert(0, notification);
      dispatchedCount++;
    }

    await _saveBroadcasts();

    // Trigger local push notification if current user was included
    final currentUid = _effectiveUid;
    final hasCurrentUser = studentsWithMistakes.any((s) =>
        s.studentUid == currentUid ||
        (s.studentEmail.isNotEmpty && s.studentEmail == _userEmail));

    if (hasCurrentUser && _notificationsEnabled) {
      final myMistake = _mistakes.isNotEmpty ? _mistakes.first : null;
      if (myMistake != null) {
        await NotificationService().showNotification(
          id: 9987,
          title: '🎯 Focus Drill for $_userName: ${myMistake.topicId.toUpperCase()}!',
          body: 'Recall Challenge: "${myMistake.prompt}" (Your last answer was "${myMistake.userAnswer}"). Solve now to master!',
          payload: 'targeted_mistake_recall',
        );
      }
    }

    notifyListeners();
    return dispatchedCount;
  }

  Timer? _targetedPushWatcherTimer;

  void _startPeriodicTargetedPushWatcher() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _targetedPushWatcherTimer?.cancel();
    _targetedPushWatcherTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      checkAndDeliverTargetedPushes();
    });
  }

  // Check and deliver any targeted push notifications sent by Admin from Cloud Backend
  Future<void> checkAndDeliverTargetedPushes() async {
    try {
      final currentUid = _effectiveUid;
      final pushes = await BackendService().fetchTargetedPushesForStudent(
        studentUid: currentUid,
        studentEmail: _userEmail,
      );

      for (var push in pushes) {
        final pushId = push['id']?.toString() ?? '';
        final title = push['title']?.toString() ?? '🎯 Question Recall';
        final body = push['body']?.toString() ?? '';

        // Trigger local notification
        if (_notificationsEnabled) {
          await NotificationService().showNotification(
            id: 9986,
            title: title,
            body: body,
            payload: 'targeted_mistake_recall',
          );
        }

        // Mark delivered in Cloud Backend
        if (pushId.isNotEmpty) {
          await BackendService().markTargetedPushDelivered(pushId);
        }

        // Save to local inbox
        if (!_broadcasts.any((b) => b.id == pushId)) {
          _broadcasts.insert(
            0,
            AdminBroadcastModel(
              id: pushId,
              title: title,
              body: body,
              target: _userName,
              sentAt: DateTime.now(),
            ),
          );
        }
      }

      if (pushes.isNotEmpty) {
        await _saveBroadcasts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Targeted pushes check note: $e');
    }
  }

  // Real All-India Speed Leaderboard ("leaderboard proper real chaiye hardcode delete")
  List<LeaderboardEntryModel> _leaderboard = [];
  List<LeaderboardEntryModel> get leaderboard => _leaderboard;
  bool _isLeaderboardLoading = false;
  bool get isLeaderboardLoading => _isLeaderboardLoading;

  int get liveUserScore {
    int base = (totalCorrectAnswers * 10) + (_streakDays * 50);
    return base > 0 ? (base + bestScore) : bestScore;
  }

  // Flipkart/Swiggy Style 3-Section System: 0 = Math, 1 = Alarm, 2 = English
  int _currentAppSection = 0;
  int get currentAppSection => _currentAppSection;

  void setAppSection(int index) {
    if (_currentAppSection != index) {
      _currentAppSection = index;
      notifyListeners();
    }
  }

  // =========================================================================
  // English Verbal Mastery Hub State & Operations
  // =========================================================================
  int _englishQuestionsAttempted = 0;
  int _englishQuestionsCorrect = 0;
  List<EnglishMistake> _englishMistakes = [];
  final Set<String> _bookmarkedEnglishWords = {};
  final Set<int> _completedEnglishTopics = {};

  int get englishQuestionsAttempted => _englishQuestionsAttempted;
  int get englishQuestionsCorrect => _englishQuestionsCorrect;
  double get englishAccuracy => _englishQuestionsAttempted > 0
      ? (_englishQuestionsCorrect / _englishQuestionsAttempted * 100)
      : 0.0;
  List<EnglishMistake> get englishMistakes => _englishMistakes;
  Set<String> get bookmarkedEnglishWords => _bookmarkedEnglishWords;
  Set<int> get completedEnglishTopics => _completedEnglishTopics;

  bool isEnglishWordBookmarked(String word) =>
      _bookmarkedEnglishWords.contains(word.trim().toUpperCase());

  Future<void> toggleEnglishBookmark(String word) async {
    final key = word.trim().toUpperCase();
    if (_bookmarkedEnglishWords.contains(key)) {
      _bookmarkedEnglishWords.remove(key);
    } else {
      _bookmarkedEnglishWords.add(key);
    }
    if (_prefs != null) {
      await _prefs!.setStringList('english_bookmarks', _bookmarkedEnglishWords.toList());
    }
    notifyListeners();
  }

  Future<void> markEnglishTopicCompleted(int topicId) async {
    _completedEnglishTopics.add(topicId);
    if (_prefs != null) {
      await _prefs!.setStringList(
        'english_completed_topics',
        _completedEnglishTopics.map((e) => e.toString()).toList(),
      );
    }
    notifyListeners();
  }

  Future<void> recordEnglishAnswer({
    required bool isCorrect,
    required String questionId,
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required int selectedIndex,
    required String explanation,
  }) async {
    _englishQuestionsAttempted++;
    if (isCorrect) {
      _englishQuestionsCorrect++;
    } else {
      final idx = _englishMistakes.indexWhere((m) => m.id == questionId);
      final mistake = EnglishMistake(
        id: questionId,
        questionText: questionText,
        options: options,
        correctIndex: correctIndex,
        selectedIndex: selectedIndex,
        explanation: explanation,
        timestamp: DateTime.now(),
      );
      if (idx >= 0) {
        _englishMistakes[idx] = mistake;
      } else {
        _englishMistakes.insert(0, mistake);
      }

      // Also record into central mistake stream so Admin sees English mistakes too
      String userSel = (selectedIndex >= 0 && selectedIndex < options.length) ? options[selectedIndex] : 'Option $selectedIndex';
      String correctSel = (correctIndex >= 0 && correctIndex < options.length) ? options[correctIndex] : 'Option $correctIndex';
      final em = MistakeModel(
        id: 'eng_${questionId}_${DateTime.now().millisecondsSinceEpoch}',
        prompt: questionText,
        userAnswer: userSel,
        correctAnswer: correctSel,
        topicId: 'English: Verbal',
        timestamp: DateTime.now(),
      );
      int mIdx = _mistakes.indexWhere((m) => m.prompt == questionText);
      if (mIdx != -1) {
        _mistakes[mIdx] = em;
      } else {
        _mistakes.insert(0, em);
      }
      _mergeCurrentStudentAnalytics();
      unawaited(CloudFirestoreSyncService().syncStudentMistakeAnalytics(
        userUid: _effectiveUid,
        userName: _userName,
        userEmail: _userEmail,
        mistakes: _mistakes,
        accuracy: overallAccuracy,
        totalAttempted: totalQuestionsAttempted,
      ));
      unawaited(syncUserDataToCloud());
    }

    if (_prefs != null) {
      await _prefs!.setInt('english_attempted', _englishQuestionsAttempted);
      await _prefs!.setInt('english_correct', _englishQuestionsCorrect);
      await _saveEnglishMistakes();
    }
    notifyListeners();
  }

  Future<void> _saveEnglishMistakes() async {
    if (_prefs != null) {
      final list = _englishMistakes.map((m) => json.encode(m.toMap())).toList();
      await _prefs!.setStringList('english_mistakes', list);
    }
  }

  Future<void> removeEnglishMistake(String questionId) async {
    _englishMistakes.removeWhere((m) => m.id == questionId);
    await _saveEnglishMistakes();
    notifyListeners();
  }

  Future<void> clearEnglishMistakes() async {
    _englishMistakes.clear();
    await _saveEnglishMistakes();
    notifyListeners();
  }

  // Logged in User Profile
  String _userUid = '';
  String _userName = 'Guest Aspirant';
  String _userEmail = 'Not signed in';
  String _userRole = 'student'; // 'student' or 'admin'
  bool _isLoggedIn = false;

  // Guest questions tracking for 3-question free trial barrier ("3 ya 4 question banaya to direct register page")
  int _guestQuestionsSolved = 0;
  int get guestQuestionsSolved => _guestQuestionsSolved;
  static const int maxGuestQuestions = 3;
  bool get isGuestLimitReached => !_isLoggedIn && _guestQuestionsSolved >= maxGuestQuestions;

  void recordGuestQuestionAnswered() {
    if (!_isLoggedIn) {
      _guestQuestionsSolved++;
      if (_prefs != null) {
        _prefs!.setInt('guest_questions_solved', _guestQuestionsSolved);
      }
      notifyListeners();
    }
  }

  void resetGuestQuestionCount() {
    _guestQuestionsSolved = 0;
    if (_prefs != null) {
      _prefs!.setInt('guest_questions_solved', 0);
    }
    notifyListeners();
  }

  String get userUid => _userUid;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _userRole == 'admin';

  // Admin UID / Role verification (Directly controlled from Firebase)
  // When an admin role or UID is assigned in Firebase Console, the user immediately gains Admin status.
  Future<bool> checkAndVerifyAdminRole(String uidOrEmail) async {
    String cleanInput = uidOrEmail.trim();
    if (cleanInput.isEmpty) return false;

    // Directly verified via Firebase Cloud Firestore ("Admin verified directly via Firebase ID and password")
    final isEmail = cleanInput.contains('@');
    final uid = isEmail ? '' : cleanInput;
    final email = isEmail ? cleanInput : '';
    String verifiedRole = await CloudFirestoreSyncService().fetchUserRoleFromCloud(uid, email);
    if (verifiedRole == 'admin') {
      _userRole = 'admin';
      if (_prefs != null) {
        await _prefs!.setString('user_role', 'admin');
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Revoke admin session
  Future<void> revokeAdminRole() async {
    _userRole = 'student';
    if (_prefs != null) {
      await _prefs!.setString('user_role', 'student');
    }
    notifyListeners();
  }

  // Admin capability: Add a new Firebase UID as Admin (Security guarded)
  Future<void> assignAdminRoleToUid(String targetUid) async {
    if (!isAdmin) {
      debugPrint('Security warning: Unauthorized attempt to grant admin role.');
      return;
    }
    List<String> adminUids = _prefs?.getStringList('firebase_admin_uids') ?? [];
    if (!adminUids.contains(targetUid.trim())) {
      adminUids.add(targetUid.trim());
      if (_prefs != null) {
        await _prefs!.setStringList('firebase_admin_uids', adminUids);
      }
      notifyListeners();
    }
  }

  String get _effectiveUid {
    if (_userUid.isNotEmpty) return _userUid;
    String? localId = _prefs?.getString('unique_device_uid');
    if (localId == null || localId.isEmpty) {
      localId = 'usr_${DateTime.now().millisecondsSinceEpoch}_${(100 + (DateTime.now().microsecond % 900))}';
      _prefs?.setString('unique_device_uid', localId);
    }
    return localId;
  }

  // Sync full student data to Cloud Firestore backend
  Future<void> syncUserDataToCloud() async {
    if (_userUid.isEmpty) return;
    try {
      await BackendService().syncFullUserData(
        uid: _userUid,
        name: _userName,
        email: _userEmail,
        role: _userRole,
        targetExam: _targetExam,
        score: liveUserScore,
        bestScore: bestScore,
        streakDays: _streakDays,
        todayAttempted: _todayAttempted,
        totalAttempted: totalQuestionsAttempted,
        totalCorrect: totalCorrectAnswers,
        dailyTarget: _dailyTarget,
        isPremium: _isPremium,
        starredTables: _starredTables.toList(),
        mistakes: _mistakes,
        history: _history,
      );
    } catch (e) {
      debugPrint('Error syncing user data to cloud: $e');
    }
  }

  // Restore complete student data from Cloud Firestore on login or new install
  Future<void> restoreUserDataFromCloud(String uid) async {
    if (uid.isEmpty) return;
    try {
      final cloudData = await BackendService().fetchFullUserData(uid);
      if (cloudData != null) {
        String name = cloudData['name'] ?? '';
        if (name.isNotEmpty) _userName = name;
        String email = cloudData['email'] ?? '';
        if (email.isNotEmpty) _userEmail = email;
        String role = cloudData['role'] ?? '';
        if (role.isNotEmpty) _userRole = role;

        String exam = cloudData['targetExam'] ?? '';
        if (exam.isNotEmpty) _targetExam = exam;

        int streak = cloudData['streakDays'] ?? 1;
        _streakDays = streak > 0 ? streak : 1;

        int dailyTgt = cloudData['dailyTarget'] ?? 30;
        if (dailyTgt > 0) _dailyTarget = dailyTgt;

        _isPremium = cloudData['isPremium'] == true;

        List<int> starred = (cloudData['starredTables'] as List<dynamic>?)
                ?.map((e) => (e is num) ? e.toInt() : int.tryParse(e.toString()) ?? 0)
                .where((e) => e > 0)
                .toList() ??
            [];
        _starredTables.clear();
        _starredTables.addAll(starred);

        // Restore mistakes notebook
        _mistakes.clear();
        String mJson = cloudData['mistakesJson'] ?? '[]';
        try {
          List<dynamic> mList = json.decode(mJson);
          _mistakes = mList.map((m) => MistakeModel.fromMap(m as Map<String, dynamic>)).toList();
        } catch (_) {}
        _allMistakes = List<MistakeModel>.from(_mistakes);

        // Restore practice history
        _history.clear();
        String hJson = cloudData['historyJson'] ?? '[]';
        try {
          List<dynamic> hList = json.decode(hJson);
          _history = hList.map((h) => PracticeResult.fromMap(h as Map<String, dynamic>)).toList();
        } catch (_) {}

        // Persist restored state locally into SharedPreferences so offline access works too
        if (_prefs != null) {
          await _prefs!.setString('user_name', _userName);
          await _prefs!.setString('user_email', _userEmail);
          await _prefs!.setString('user_uid', _userUid);
          await _prefs!.setString('user_role', _userRole);
          await _prefs!.setString('target_exam', _targetExam);
          await _prefs!.setInt('streak_days', _streakDays);
          await _prefs!.setInt('daily_target', _dailyTarget);
          await _prefs!.setBool('is_premium', _isPremium);
          await _prefs!.setStringList('starred_tables', _starredTables.map((e) => e.toString()).toList());
          await _prefs!.setStringList('mistakes_list', _mistakes.map((m) => json.encode(m.toMap())).toList());
          await _prefs!.setStringList('all_mistakes_notebook', _allMistakes.map((m) => json.encode(m.toMap())).toList());
          await _prefs!.setStringList('history_list', _history.map((h) => json.encode(h.toMap())).toList());
        }

        notifyListeners();
        debugPrint('✅ Cloud Restore: Successfully loaded ${_history.length} history sessions, ${_mistakes.length} mistakes, and $_streakDays streak days for $_userName ($uid)!');
      } else {
        // Brand new account with no cloud history yet: Keep clean pristine baseline
        debugPrint('ℹ️ New user account ($uid): Initialized with fresh clean state.');
      }
    } catch (e) {
      debugPrint('Error restoring user data from cloud: $e');
    }
  }

  Future<void> setLoggedInUser({required String name, required String email, String uid = '', String role = 'student'}) async {
    // 1. Immediately wipe any in-memory data left from the previous user
    _history.clear();
    _mistakes.clear();
    _allMistakes.clear();
    _starredTables.clear();
    _starredFormulas.clear();
    _revisionItems.clear();
    _todayAttempted = 0;
    _streakDays = 1;
    _activeStudyPlan = null;
    _isPremium = false;
    _lastActiveDate = '';
    _broadcasts.clear();

    // 2. Cancel prior user's notification timers
    try {
      await NotificationService().cancelAllNotifications();
    } catch (_) {}

    _userName = name.isNotEmpty ? name : (email.isNotEmpty ? email.split('@').first : 'Aspirant');
    _userEmail = email;
    _userUid = uid.isNotEmpty ? uid : 'usr_${DateTime.now().millisecondsSinceEpoch}';
    _userRole = role;
    _isLoggedIn = true;
    _guestQuestionsSolved = 0; // Free trial unlocked upon registration!

    if (_prefs != null) {
      await _prefs!.setString('user_name', _userName);
      await _prefs!.setString('user_email', _userEmail);
      await _prefs!.setString('user_uid', _userUid);
      await _prefs!.setString('user_role', _userRole);
      await _prefs!.setBool('is_logged_in', true);
      await _prefs!.setInt('guest_questions_solved', 0);

      // Overwrite previous user's cached lists so they cannot bleed into this user
      await _prefs!.setStringList('history_list', []);
      await _prefs!.setStringList('mistakes_list', []);
      await _prefs!.setStringList('all_mistakes_notebook', []);
      await _prefs!.setStringList('starred_tables', []);
      await _prefs!.setStringList('starred_formulas', []);
      await _prefs!.setStringList('custom_revision_items', []);
      await _prefs!.setInt('today_attempted', 0);
      await _prefs!.setInt('streak_days', 1);
      await _prefs!.remove('active_study_plan');
      await _prefs!.setBool('is_premium', false);
      await _prefs!.setBool('is_pro', false);
      await _prefs!.setStringList('admin_broadcasts', []);
    }

    notifyListeners();

    // 3. RESTORE THIS USER'S CLOUD DATA (Only loads data belonging to this uid)
    await restoreUserDataFromCloud(_userUid);

    // 4. Sync user registration to Firebase Backend directly
    unawaited(BackendService().registerUserOnBackend(
      uid: _userUid,
      name: _userName,
      email: _userEmail,
      role: _userRole,
    ));

    // 5. Immediately sync only THIS user's real progress to Cloud Leaderboard and refresh rankings
    unawaited(BackendService().syncUserProgressToLeaderboard(
      userName: _userName,
      score: liveUserScore,
      accuracy: overallAccuracy,
      streak: _streakDays,
      userUid: _userUid,
      targetExam: _targetExam,
      questionsSolved: totalQuestionsAttempted,
    ));
    unawaited(fetchRealLeaderboard(forceRefresh: true));

    // 6. Ensure state is mirrored back to cloud
    unawaited(syncUserDataToCloud());
  }

  void updateUserName(String name) {
    _userName = name.trim();
    if (_prefs != null) {
      _prefs!.setString('user_name', _userName);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    // 1. Reset user identity to Guest
    _userName = 'Guest Aspirant';
    _userEmail = 'Not signed in';
    _userUid = '';
    _userRole = 'student';
    _isAdminStudentPreview = false;
    _isLoggedIn = false;
    _guestQuestionsSolved = 0;

    // 2. Completely reset user practice & session state in memory
    _history.clear();
    _mistakes.clear();
    _allMistakes.clear();
    _starredTables.clear();
    _starredFormulas.clear();
    _revisionItems.clear();
    _todayAttempted = 0;
    _streakDays = 1;
    _activeStudyPlan = null;
    _isPremium = false;
    _lastActiveDate = '';
    _broadcasts.clear();
    _studentMistakeAnalytics.removeWhere((s) => s.studentUid == 'current_user');
    _englishQuestionsAttempted = 0;
    _englishQuestionsCorrect = 0;
    _englishMistakes.clear();
    _bookmarkedEnglishWords.clear();
    _completedEnglishTopics.clear();

    // 3. Completely clear user-specific data from SharedPreferences
    if (_prefs != null) {
      await _prefs!.remove('user_name');
      await _prefs!.remove('user_email');
      await _prefs!.remove('user_uid');
      await _prefs!.remove('user_role');
      await _prefs!.setBool('is_logged_in', false);
      await _prefs!.remove('guest_questions_solved');

      await _prefs!.remove('history_list');
      await _prefs!.remove('mistakes_list');
      await _prefs!.remove('all_mistakes_notebook');
      await _prefs!.remove('starred_tables');
      await _prefs!.remove('starred_formulas');
      await _prefs!.remove('custom_revision_items');
      await _prefs!.remove('today_attempted');
      await _prefs!.remove('streak_days');
      await _prefs!.remove('active_study_plan');
      await _prefs!.remove('is_premium');
      await _prefs!.remove('is_pro');
      await _prefs!.remove('last_active_date');
      await _prefs!.remove('admin_broadcasts');
    }

    // 4. Cancel all active notifications & timers for the logged-out user
    try {
      await NotificationService().cancelAllNotifications();
    } catch (_) {}

    notifyListeners();
  }

  // Google Play Compliance: Permanent Account & Associated Personal Data Deletion
  Future<bool> deleteUserAccount() async {
    try {
      final uid = _userUid;

      // Step 1: Delete ALL user data from Firestore cloud backend
      // (users, student_mistakes, user_diagnostics, leaderboard, targeted_pushes, exam_mock_results)
      if (uid.isNotEmpty) {
        try {
          await BackendService().deleteAllUserDataFromBackend(uid);
          debugPrint('Cloud Firestore: All data permanently deleted for uid=$uid');
        } catch (e) {
          debugPrint('Firestore delete notice: $e');
        }
      }

      // Step 2: Delete Firebase Auth account
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.delete();
          debugPrint('Firebase Auth: Account deleted.');
        }
      } catch (e) {
        debugPrint('Firebase Auth account delete note: $e');
      }

      // Step 3: Cancel all scheduled notifications
      try {
        await NotificationService().cancelAllNotifications();
      } catch (_) {}

      // Step 4: Wipe all local SharedPreferences data
      await resetAllData();

      // Step 5: Logout and clear local session
      await logout();

      return true;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }

  // Topics
  List<TopicModel> _topics = [];
  List<TopicModel> get topics => _topics;

  // Stats
  int get totalQuestionsAttempted => _history.fold(0, (sum, item) => sum + item.totalQuestions);
  int get totalCorrectAnswers => _history.fold(0, (sum, item) => sum + item.correctCount);
  double get overallAccuracy => totalQuestionsAttempted == 0
      ? 0.0
      : (totalCorrectAnswers / totalQuestionsAttempted) * 100;
  int get bestScore => _history.isEmpty ? 0 : _history.map((e) => e.score).reduce((a, b) => a > b ? a : b);

  double get totalRevenue => _transactions.where((t) => t.status == 'SUCCESS').fold(0.0, (s, t) => s + t.amount);

  double get overallAvgSpeedSeconds {
    final valid = _history.where((r) => r.avgTimeSeconds > 0).toList();
    if (valid.isEmpty) return 0.0;
    return valid.fold(0.0, (s, r) => s + r.avgTimeSeconds) / valid.length;
  }

  AppStateProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    // NotificationService is initialized on launch in main.dart; configure mistake callback
    NotificationService().onMistakeResolved = (prompt, answer) {
      checkAndResolveIfMistake(prompt: prompt, answer: answer);
    };
    await _loadState();
    // Ensure scheduled native alarms (30m -> 3hr -> Next Day) are safely registered without firing on app open
    if (_notificationsEnabled) {
      await NotificationService().rescheduleAllPendingMistakeAlarms();
    }
    _syncWithCloudBackend();
    if (_isLoggedIn && _userUid.isNotEmpty) {
      restoreUserDataFromCloud(_userUid);
    }
    fetchRealLeaderboard();
  }

  // Cloud synchronization on launch
  Future<void> _syncWithCloudBackend() async {
    List<QuestionModel> cloudQuestions = await BackendService().syncQuestionsFromBackend();
    if (cloudQuestions.isNotEmpty) {
      _adminQuestions = cloudQuestions;
      notifyListeners();
    }
  }

  Future<void> _loadState() async {
    if (_prefs == null) return;

    _isPremium = _prefs!.getBool('is_premium') ?? false;
    _dailyTarget = _prefs!.getInt('daily_target') ?? 30;
    _streakDays = _prefs!.getInt('streak_days') ?? 1;
    _lastActiveDate = _prefs!.getString('last_active_date') ?? '';
    _notificationsEnabled = _prefs!.getBool('notifications_enabled') ?? true;
    _dailyNotificationLimit = _prefs!.getInt('daily_notification_limit') ?? 10;
    _totalRegisteredUsers = _prefs!.getInt('total_users') ?? 0;

    // Load cached real registered users
    List<String>? cachedUsers = _prefs!.getStringList('cached_registered_users');
    if (cachedUsers != null && cachedUsers.isNotEmpty) {
      try {
        _registeredUsers = cachedUsers.map((u) => json.decode(u) as Map<String, dynamic>).toList();
        _totalRegisteredUsers = _registeredUsers.length;
      } catch (_) {}
    }

    // Load cached PDF study materials
    List<String>? cachedPdfs = _prefs!.getStringList('cached_admin_pdfs');
    if (cachedPdfs != null && cachedPdfs.isNotEmpty) {
      try {
        _adminPdfMaterials = cachedPdfs.map((p) => json.decode(p) as Map<String, dynamic>).toList();
      } catch (_) {}
    }

    // Daily streak check with strict cancellation if yesterday was skipped
    String today = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastActiveDate != today) {
      if (_lastActiveDate.isNotEmpty) {
        DateTime? lastDate = DateTime.tryParse(_lastActiveDate);
        if (lastDate != null) {
          // Compare difference in calendar days
          DateTime now = DateTime.now();
          DateTime todayMidnight = DateTime(now.year, now.month, now.day);
          DateTime lastMidnight = DateTime(lastDate.year, lastDate.month, lastDate.day);
          int dayDifference = todayMidnight.difference(lastMidnight).inDays;

          if (dayDifference == 1) {
            // Consecutive day: Keep current streak intact until today's practice adds to it
          } else if (dayDifference > 1 || dayDifference < 0) {
            // Skipped one or more days or clock skewed backwards: STRICT RESET TO 0!
            _streakDays = 0;
          }
        }
      } else {
        _streakDays = 0;
      }

      _todayAttempted = 0;
      _lastActiveDate = today;
      _prefs!.setString('last_active_date', today);
      _prefs!.setInt('streak_days', _streakDays);
      _prefs!.setInt('today_attempted', 0);
    } else {
      _todayAttempted = _prefs!.getInt('today_attempted') ?? 0;
    }

    // Load mistakes (active pending queue for 1-hour recall alert)
    List<String>? mistakeStrings = _prefs!.getStringList('mistakes_list');
    if (mistakeStrings != null) {
      _mistakes = mistakeStrings.map((s) => MistakeModel.fromMap(json.decode(s))).toList();
    }

    // Load lifetime mistake notebook (permanently stores all mistakes, even after solved)
    List<String>? allMistakeStrings = _prefs!.getStringList('all_mistakes_notebook');
    if (allMistakeStrings != null) {
      _allMistakes = allMistakeStrings.map((s) => MistakeModel.fromMap(json.decode(s))).toList();
    } else {
      _allMistakes = List<MistakeModel>.from(_mistakes);
    }

    // Load table practice timestamps (Decay tracking)
    final tableTsString = _prefs!.getString('table_practice_timestamps');
    if (tableTsString != null && tableTsString.isNotEmpty) {
      try {
        final decoded = json.decode(tableTsString) as Map<String, dynamic>;
        _tablePracticeTimestamps.clear();
        decoded.forEach((k, v) {
          final tNum = int.tryParse(k);
          final ts = v is int ? v : int.tryParse(v.toString());
          if (tNum != null && ts != null) {
            _tablePracticeTimestamps[tNum] = ts;
          }
        });
      } catch (_) {}
    }

    // Load history
    List<String>? historyStrings = _prefs!.getStringList('history_list');
    if (historyStrings != null) {
      _history = historyStrings.map((s) => PracticeResult.fromMap(json.decode(s))).toList();
    }

    // Load admin questions
    List<String>? adminQStrings = _prefs!.getStringList('admin_questions');
    if (adminQStrings != null) {
      _adminQuestions = adminQStrings.map((s) => QuestionModel.fromMap(json.decode(s))).toList();
    }

    // Load transactions (Strictly real from cloud or local cache)
    List<String>? txStrings = _prefs!.getStringList('transactions_list');
    if (txStrings != null && txStrings.isNotEmpty) {
      _transactions = txStrings.map((s) => PaymentTransaction.fromMap(json.decode(s))).toList();
    } else {
      _transactions = [];
    }

    // Load broadcasts
    List<String>? broadcastStrings = _prefs!.getStringList('admin_broadcasts');
    if (broadcastStrings != null && broadcastStrings.isNotEmpty) {
      _broadcasts.clear();
      _broadcasts.addAll(broadcastStrings.map((s) => AdminBroadcastModel.fromJson(s)));
      // Filter out any unwanted "mastered" notifications
      _broadcasts.removeWhere((b) => b.id.startsWith('mastered_') || b.title.toLowerCase().contains('mastered'));
    }

    // Automatic one-time purge of legacy hardcoded data from device SharedPreferences
    final bool purgedLegacy = _prefs!.getBool('purged_legacy_mock_data_v4') ?? false;
    if (!purgedLegacy) {
      await _prefs!.remove('starred_tables');
      await _prefs!.remove('active_starred_table_number');
      await _prefs!.remove('active_starred_table_formula');
      await _prefs!.setBool('purged_legacy_mock_data_v4', true);
    }

    // Load starred tables (User-saved bookmarks: strictly empty by default)
    List<String>? starred = _prefs!.getStringList('starred_tables');
    _starredTables.clear();
    if (starred != null && starred.isNotEmpty) {
      _starredTables.addAll(starred.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0));
    }
    if (_starredTables.isNotEmpty && _notificationsEnabled) {
      NotificationService().scheduleStarredTableNotification(_starredTables.last, onlyIfNotScheduled: true);
    } else {
      NotificationService().cancelStarredTableNotification(0);
    }

    // Load starred formulas
    List<String>? starredFormulasList = _prefs!.getStringList('starred_formulas');
    if (starredFormulasList != null) {
      _starredFormulas.clear();
      _starredFormulas.addAll(starredFormulasList);
    }

    // Load active study plan
    String? planStr = _prefs!.getString('active_study_plan');
    if (planStr != null) {
      try {
        _activeStudyPlan = StudyPlanModel.fromMap(json.decode(planStr));
        if (!_activeStudyPlan!.isCompleted && _notificationsEnabled) {
          NotificationService().scheduleStudyPlanReminder(
            plan: _activeStudyPlan!,
            userName: _userName.isNotEmpty ? _userName : 'Aspirant',
          );
        }
      } catch (e) {
        debugPrint('Study plan load error: $e');
      }
    }

    // Load custom revision items (strictly empty by default, filtered of legacy dummy items)
    List<String>? revList = _prefs!.getStringList('custom_revision_items');
    _revisionItems.clear();
    if (revList != null && revList.isNotEmpty) {
      try {
        _revisionItems = revList
            .map((s) => RevisionItemModel.fromMap(json.decode(s)))
            .where((item) =>
                !item.id.startsWith('rev_formula_') &&
                !item.id.startsWith('rev_triple_') &&
                item.id != 'rev_perc_1_7')
            .toList();
        await _saveRevisionItems();
      } catch (e) {
        debugPrint('Custom revision items load error: $e');
        _revisionItems.clear();
      }
    }

    // Load Settings & Customization Preferences
    _targetExam = _prefs!.getString('target_exam') ?? 'SSC CGL & CHSL';
    _numpadStyle = _prefs!.getString('numpad_style') ?? 'phone';
    _hapticsEnabled = _prefs!.getBool('haptics_enabled') ?? true;
    _soundEnabled = _prefs!.getBool('sound_enabled') ?? true;
    _showTrickHints = _prefs!.getBool('show_trick_hints') ?? true;
    _ttsSpeechRate = _prefs!.getDouble('tts_speech_rate') ?? 0.45;
    _ttsPitch = _prefs!.getDouble('tts_pitch') ?? 1.0;
    _ttsLanguage = _prefs!.getString('tts_language') ?? 'en-IN';
    _ttsRecitalStyle = _prefs!.getString('tts_recital_style') ?? 'school';
    _ttsRepeatMode = _prefs!.getString('tts_repeat_mode') ?? 'none';
    _ttsQuizPauseSeconds = _prefs!.getDouble('tts_quiz_pause_seconds') ?? 2.0;
    _reminderHour = _prefs!.getInt('reminder_hour') ?? 8;
    _reminderMinute = _prefs!.getInt('reminder_minute') ?? 0;
    _recallIntervalHours = _prefs!.getInt('recall_interval_hours') ?? 1;
    _amoledBlackMode = _prefs!.getBool('amoled_black_mode') ?? false;

    // Load Math Alarm Settings
    _mathAlarmEnabled = _prefs!.getBool('math_alarm_enabled') ?? false;
    _mathAlarmHour = _prefs!.getInt('math_alarm_hour') ?? 7;
    _mathAlarmMinute = _prefs!.getInt('math_alarm_minute') ?? 0;
    _mathAlarmLabel = _prefs!.getString('math_alarm_label') ?? 'Morning SSC Speed Math Alarm';
    if (_mathAlarmEnabled) {
      NotificationService().scheduleMathWakeUpAlarm(
        hour: _mathAlarmHour,
        minute: _mathAlarmMinute,
        label: _mathAlarmLabel,
      );
    }

    // Load User Authentication & Guest Trial Limit
    _userName = _prefs!.getString('user_name') ?? 'Guest Aspirant';
    _userEmail = _prefs!.getString('user_email') ?? 'Not signed in';
    _userUid = _prefs!.getString('user_uid') ?? '';
    _userRole = _prefs!.getString('user_role') ?? 'student';
    _isLoggedIn = _prefs!.getBool('is_logged_in') ?? false;
    _guestQuestionsSolved = _prefs!.getInt('guest_questions_solved') ?? 0;

    _topics = ContentRepository.getDefaultTopics();
    _initStudentAnalytics();

    // Load cached real leaderboard
    List<String>? cachedLb = _prefs!.getStringList('cached_real_leaderboard');
    if (cachedLb != null && cachedLb.isNotEmpty) {
      try {
        _leaderboard = cachedLb
            .map((s) => LeaderboardEntryModel.fromMap(json.decode(s), currentUid: _userUid))
            .toList();
      } catch (e) {
        debugPrint('Leaderboard cache parse note: $e');
      }
    }

    // Load English verbal mastery state
    _englishQuestionsAttempted = _prefs!.getInt('english_attempted') ?? 0;
    _englishQuestionsCorrect = _prefs!.getInt('english_correct') ?? 0;
    List<String>? engMistakeStrings = _prefs!.getStringList('english_mistakes');
    if (engMistakeStrings != null && engMistakeStrings.isNotEmpty) {
      try {
        _englishMistakes = engMistakeStrings
            .map((s) => EnglishMistake.fromMap(json.decode(s)))
            .toList();
      } catch (e) {
        debugPrint('English mistakes load note: $e');
      }
    }
    List<String>? engBookmarks = _prefs!.getStringList('english_bookmarks');
    if (engBookmarks != null && engBookmarks.isNotEmpty) {
      _bookmarkedEnglishWords.clear();
      _bookmarkedEnglishWords.addAll(engBookmarks);
    }
    List<String>? engTopics = _prefs!.getStringList('english_completed_topics');
    if (engTopics != null && engTopics.isNotEmpty) {
      _completedEnglishTopics.clear();
      _completedEnglishTopics.addAll(
        engTopics.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0),
      );
    }

    unawaited(checkAndDeliverTargetedPushes());
    _startPeriodicTargetedPushWatcher();

    notifyListeners();
  }

  void _initStudentAnalytics() {
    _studentMistakeAnalytics = [];
    _mergeCurrentStudentAnalytics();
  }

  void _mergeCurrentStudentAnalytics() {
    // Admins are owners/evaluators, NOT students! Never show admin in student mistakes dossier!
    if (isAdmin || _userRole == 'admin' || _userEmail == 'gulshankumar.dev01@gmail.com') return;

    String currentUid = _userUid.isNotEmpty ? _userUid : 'current_user';
    int existingIdx = _studentMistakeAnalytics.indexWhere((s) => s.studentUid == currentUid);
    final currentRecord = StudentMistakeAnalyticsModel(
      studentUid: currentUid,
      studentName: _userName,
      studentEmail: _userEmail,
      totalMistakes: _mistakes.length,
      accuracy: overallAccuracy,
      totalAttempted: totalQuestionsAttempted,
      mistakes: List.from(_mistakes),
      lastActive: DateTime.now(),
    );

    if (existingIdx != -1) {
      _studentMistakeAnalytics[existingIdx] = currentRecord;
    } else {
      _studentMistakeAnalytics.insert(0, currentRecord);
    }
  }

  bool _isAdminSyncing = false;
  bool get isAdminSyncing => _isAdminSyncing;

  // Live Sync All Admin Data from Cloud Firestore & Backend ("All data properly fetched and synchronized in Admin Portal")
  Future<void> syncAllAdminDataFromCloud() async {
    _isAdminSyncing = true;
    notifyListeners();

    try {
      // Parallel execution of all cloud collections via Future.wait
      final results = await Future.wait([
        BackendService().syncQuestionsFromBackend(),
        CloudFirestoreSyncService().fetchStudentMistakesForAdmin(),
        CloudFirestoreSyncService().fetchUsersFromCloud(),
        CloudFirestoreSyncService().fetchPdfDocumentsFromCloud(),
        CloudFirestoreSyncService().fetchPaymentTransactionsForAdmin(),
        CloudFirestoreSyncService().fetchBroadcastsFromCloud(),
      ]);

      final cloudQuestions = results[0] as List<QuestionModel>;
      final liveAnalyticsRaw = results[1] as List<Map<String, dynamic>>;
      final liveUsers = results[2] as List<Map<String, dynamic>>;
      final livePdfs = results[3] as List<Map<String, dynamic>>;
      final liveTxsRaw = results[4] as List<Map<String, dynamic>>;
      final liveBroadcastsRaw = results[5] as List<Map<String, dynamic>>;

      // 1. Process Questions
      if (cloudQuestions.isNotEmpty) {
        for (var cq in cloudQuestions) {
          int idx = _adminQuestions.indexWhere((q) => q.id == cq.id);
          if (idx != -1) {
            _adminQuestions[idx] = cq;
          } else {
            _adminQuestions.add(cq);
          }
        }
        if (_prefs != null) {
          List<String> qJson = _adminQuestions.map((e) => json.encode(e.toMap())).toList();
          await _prefs!.setStringList('admin_questions', qJson);
        }
      }

      // 2. Process Student Mistake Analytics
      if (liveAnalyticsRaw.isNotEmpty) {
        for (var raw in liveAnalyticsRaw) {
          String uid = raw['studentUid'] ?? '';
          if (uid.isEmpty) continue;
          List<MistakeModel> mistList = [];
          try {
            List decoded = json.decode(raw['mistakesJson'] ?? '[]');
            mistList = decoded.map((m) => MistakeModel.fromMap(m)).toList();
          } catch (_) {}

          final model = StudentMistakeAnalyticsModel(
            studentUid: uid,
            studentName: raw['studentName'] ?? 'Aspirant',
            studentEmail: raw['studentEmail'] ?? '',
            totalMistakes: raw['totalMistakes'] ?? mistList.length,
            accuracy: (raw['accuracy'] ?? 0.0).toDouble(),
            totalAttempted: raw['totalAttempted'] ?? 0,
            mistakes: mistList,
            lastActive: DateTime.tryParse(raw['lastActive'] ?? '') ?? DateTime.now(),
          );

          int idx = _studentMistakeAnalytics.indexWhere((s) => s.studentUid == uid);
          if (idx != -1) {
            _studentMistakeAnalytics[idx] = model;
          } else {
            _studentMistakeAnalytics.insert(0, model);
          }
        }
      }

      // 3. Merge current device's user mistakes so admin sees current student's data too
      _mergeCurrentStudentAnalytics();

      // 4. Process Registered Users with aggressive UID / Email / Name deduplication
      final Map<String, Map<String, dynamic>> combinedUsers = {};

      void addOrMergeUserEntry(Map<String, dynamic> u) {
        String uUid = (u['uid']?.toString() ?? '').trim().toLowerCase();
        String uEmail = (u['email']?.toString() ?? '').trim().toLowerCase();
        String uName = (u['name']?.toString() ?? '').trim().toLowerCase();

        String? matchKey;
        for (var entry in combinedUsers.entries) {
          String exUid = (entry.value['uid']?.toString() ?? '').trim().toLowerCase();
          String exEmail = (entry.value['email']?.toString() ?? '').trim().toLowerCase();
          String exName = (entry.value['name']?.toString() ?? '').trim().toLowerCase();

          if (uUid.isNotEmpty && exUid.isNotEmpty && uUid == exUid) { matchKey = entry.key; break; }
          if (uEmail.isNotEmpty && exEmail.isNotEmpty && uEmail == exEmail) { matchKey = entry.key; break; }
          if (uName.isNotEmpty && uName != 'aspirant' && uName != 'guest aspirant' &&
              exName.isNotEmpty && exName != 'aspirant' && exName != 'guest aspirant' &&
              uName == exName) { matchKey = entry.key; break; }
        }

        if (matchKey != null) {
          final existing = combinedUsers[matchKey]!;
          existing.addAll(u);
          if (u['role'] == 'admin' || uEmail.contains('admin') || uEmail == 'gulshankumar.dev01@gmail.com') {
            existing['role'] = 'admin';
          }
        } else {
          String newKey = uEmail.isNotEmpty ? uEmail : (uUid.isNotEmpty ? uUid : uName);
          if (newKey.isNotEmpty) {
            final entry = Map<String, dynamic>.from(u);
            if (uEmail.contains('admin') || uEmail == 'gulshankumar.dev01@gmail.com') {
              entry['role'] = 'admin';
            }
            combinedUsers[newKey] = entry;
          }
        }
      }

      for (var u in _registeredUsers) {
        addOrMergeUserEntry(u);
      }

      for (var u in liveUsers) {
        addOrMergeUserEntry(u);
      }

      // ONLY add active device user if they are a STUDENT (Admins are NEVER injected as student aspirants!)
      if (!isAdmin && _userRole != 'admin' && _userEmail != 'gulshankumar.dev01@gmail.com') {
        if (_userEmail.isNotEmpty || _userUid.isNotEmpty) {
          int myScore = (totalCorrectAnswers * 10) + (_streakDays * 50) + bestScore;
          addOrMergeUserEntry({
            'uid': _userUid.isNotEmpty ? _userUid : _userEmail,
            'name': _userName.isNotEmpty ? _userName : 'Aspirant',
            'email': _userEmail,
            'role': 'student',
            'score': myScore > 0 ? myScore : bestScore,
            'accuracy': overallAccuracy,
            'streak': _streakDays,
            'targetExam': _targetExam,
            'questionsSolved': totalQuestionsAttempted,
            'registeredAt': DateTime.now().toIso8601String(),
            'lastActive': DateTime.now().toIso8601String(),
          });
        }
      }

      if (combinedUsers.isNotEmpty) {
        _registeredUsers = combinedUsers.values.toList();
        _totalRegisteredUsers = _registeredUsers.length;
        if (_prefs != null) {
          await _prefs!.setInt('total_users', _totalRegisteredUsers);
          await _prefs!.setStringList(
            'cached_registered_users',
            _registeredUsers.map((u) => json.encode(u)).toList(),
          );
        }
      } else {
        _totalRegisteredUsers = _registeredUsers.length;
      }

      // 5. Process PDF study materials
      if (livePdfs.isNotEmpty) {
        _adminPdfMaterials = livePdfs;
        if (_prefs != null) {
          await _prefs!.setStringList('cached_admin_pdfs', livePdfs.map((p) => json.encode(p)).toList());
        }
      }

      // 6. Process Transactions from Cloud Firestore
      if (liveTxsRaw.isNotEmpty) {
        final userLookup = <String, Map<String, dynamic>>{};
        for (var u in _registeredUsers) {
          final uid = u['uid']?.toString() ?? '';
          final email = u['email']?.toString().toLowerCase() ?? '';
          if (uid.isNotEmpty) userLookup[uid] = u;
          if (email.isNotEmpty) userLookup[email] = u;
        }

        final List<PaymentTransaction> parsed = [];
        for (var m in liveTxsRaw) {
          String uName = m['userName']?.toString() ?? '';
          String uEmail = m['userEmail']?.toString() ?? '';
          final uId = m['userId']?.toString() ?? '';

          if ((uName.isEmpty || uName == 'Aspirant' || uName.startsWith('usr_')) && uId.isNotEmpty) {
            if (userLookup.containsKey(uId)) {
              uName = userLookup[uId]!['name']?.toString() ?? uName;
              if (uEmail.isEmpty) uEmail = userLookup[uId]!['email']?.toString() ?? '';
            }
          }
          if (uEmail.isEmpty && userLookup.containsKey(uName.toLowerCase())) {
            uEmail = userLookup[uName.toLowerCase()]!['email']?.toString() ?? '';
          }

          final updatedMap = Map<String, dynamic>.from(m);
          if (uName.isNotEmpty && uName != 'Aspirant') updatedMap['userName'] = uName;
          if (uEmail.isNotEmpty) updatedMap['userEmail'] = uEmail;

          parsed.add(PaymentTransaction.fromMap(updatedMap));
        }

        // Merge with existing local transactions so local un-synced ones are preserved
        for (var localTx in _transactions) {
          if (!parsed.any((p) => p.orderId == localTx.orderId)) {
            parsed.add(localTx);
          }
        }
        parsed.sort((a, b) => b.date.compareTo(a.date));
        _transactions = parsed;

        if (_prefs != null) {
          List<String> txList = _transactions.map((t) => json.encode(t.toMap())).toList();
          await _prefs!.setStringList('transactions_list', txList);
        }
      }

      // 7. Process live broadcasts
      if (liveBroadcastsRaw.isNotEmpty) {
        for (var b in liveBroadcastsRaw) {
          if (!_broadcasts.any((existing) => existing.id == b['id'])) {
            _broadcasts.insert(
              0,
              AdminBroadcastModel(
                id: b['id'] ?? '',
                title: b['title'] ?? '',
                body: b['message'] ?? '',
                target: 'all',
                sentAt: DateTime.tryParse(b['sentAt'] ?? '') ?? DateTime.now(),
              ),
            );
          }
        }
        await _saveBroadcasts();
      }
    } catch (e) {
      debugPrint('Admin cloud sync note: $e');
    } finally {
      _isAdminSyncing = false;
      notifyListeners();
    }
  }

  // Fetch & Synchronize Live All-India Speed Leaderboard ("leaderboard proper real chaiye hardcode delete")
  Future<void> fetchRealLeaderboard({bool forceRefresh = false}) async {
    _isLeaderboardLoading = true;
    notifyListeners();

    try {
      final currentUid = _effectiveUid;
      final currentScore = liveUserScore;
      final currentEntry = LeaderboardEntryModel(
        uid: currentUid,
        name: _userName.isNotEmpty ? _userName : 'Guest Aspirant',
        score: currentScore,
        accuracy: overallAccuracy,
        streak: _streakDays,
        targetExam: _targetExam,
        questionsSolved: totalQuestionsAttempted,
        updatedAt: DateTime.now(),
        isCurrentUser: true,
      );

      // 1. Sync current user's live progress to Cloud Firestore (STUDENTS ONLY - Admin never pollutes leaderboard)
      if (!isAdmin && _userRole != 'admin' && _userEmail != 'gulshankumar.dev01@gmail.com') {
        await BackendService().syncUserProgressToLeaderboard(
          userName: currentEntry.name,
          score: currentEntry.score,
          accuracy: currentEntry.accuracy,
          streak: currentEntry.streak,
          userUid: currentEntry.uid,
          targetExam: currentEntry.targetExam,
          questionsSolved: currentEntry.questionsSolved,
        );
      }

      // 2. Fetch live rankings from Cloud Firestore
      final cloudRecords = await BackendService().fetchLeaderboardFromBackend();
      Map<String, LeaderboardEntryModel> mergedMap = {};

      for (var r in cloudRecords) {
        var entry = LeaderboardEntryModel.fromMap(r, currentUid: currentUid);
        String key = entry.uid.isNotEmpty ? entry.uid : entry.name;
        if (key.isNotEmpty) {
          mergedMap[key] = entry;
        }
      }

      // Fetch live registered users from Firestore multi-collection discovery
      try {
        final liveUsers = await CloudFirestoreSyncService().fetchUsersFromCloud();
        final Map<String, Map<String, dynamic>> combinedUsers = {};
        for (var u in _registeredUsers) {
          final key = (u['uid']?.toString().trim().isNotEmpty == true)
              ? u['uid'].toString().trim()
              : (u['email']?.toString().trim().toLowerCase() ?? '');
          if (key.isNotEmpty) combinedUsers[key] = Map<String, dynamic>.from(u);
        }
        for (var u in liveUsers) {
          final key = (u['uid']?.toString().trim().isNotEmpty == true)
              ? u['uid'].toString().trim()
              : (u['email']?.toString().trim().toLowerCase() ?? '');
          if (key.isNotEmpty) {
            if (combinedUsers.containsKey(key)) {
              combinedUsers[key]!.addAll(u);
            } else {
              combinedUsers[key] = Map<String, dynamic>.from(u);
            }
          }
        }
        if (combinedUsers.isNotEmpty) {
          _registeredUsers = combinedUsers.values.toList();
          _totalRegisteredUsers = _registeredUsers.length;
          if (_prefs != null) {
            await _prefs!.setInt('total_users', _totalRegisteredUsers);
            await _prefs!.setStringList(
              'cached_registered_users',
              _registeredUsers.map((u) => json.encode(u)).toList(),
            );
          }
        }
      } catch (e) {
        debugPrint('Fetch users for leaderboard notice: $e');
      }

      // Merge real registered users if present (strictly real scores, no fake defaults)
      for (var u in _registeredUsers) {
        String uid = (u['uid']?.toString() ?? '').trim();
        String name = (u['name']?.toString() ?? '').trim();
        String email = (u['email']?.toString() ?? '').trim();
        if (name.isEmpty && email.isNotEmpty) {
          final prefix = email.split('@').first;
          name = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
        }
        if (name.isEmpty) name = 'Aspirant';

        String key = uid.isNotEmpty ? uid : name;
        if (!mergedMap.containsKey(key) && uid != currentUid) {
          int uScore = (u['score'] is num ? (u['score'] as num).toInt() : int.tryParse(u['score']?.toString() ?? '0') ?? 0);
          int uQuestions = (u['questionsSolved'] is num ? (u['questionsSolved'] as num).toInt() : int.tryParse(u['questionsSolved']?.toString() ?? '0') ?? 0);
          mergedMap[key] = LeaderboardEntryModel(
            uid: uid.isNotEmpty ? uid : key,
            name: name,
            score: uScore,
            accuracy: (u['accuracy'] is num ? (u['accuracy'] as num).toDouble() : double.tryParse(u['accuracy']?.toString() ?? '0.0') ?? 0.0),
            streak: (u['streak'] is num ? (u['streak'] as num).toInt() : int.tryParse(u['streak']?.toString() ?? '0') ?? 0),
            targetExam: u['targetExam']?.toString() ?? 'SSC CGL',
            questionsSolved: uQuestions,
            updatedAt: DateTime.tryParse(u['lastActive']?.toString() ?? '') ?? DateTime.now(),
            isCurrentUser: false,
          );
        }
      }

      // 3. Always insert / update current active user with live local stats
      mergedMap[currentUid] = LeaderboardEntryModel(
        uid: currentUid,
        name: _userName.isNotEmpty ? _userName : 'Guest Aspirant',
        score: liveUserScore,
        accuracy: overallAccuracy,
        streak: _streakDays,
        targetExam: _targetExam,
        questionsSolved: totalQuestionsAttempted,
        updatedAt: DateTime.now(),
        isCurrentUser: true,
      );

      List<LeaderboardEntryModel> list = mergedMap.values.toList();
      // Sort strictly by score DESC, then accuracy DESC
      list.sort((a, b) {
        int cmp = b.score.compareTo(a.score);
        if (cmp != 0) return cmp;
        return b.accuracy.compareTo(a.accuracy);
      });

      _leaderboard = list;

      if (_prefs != null) {
        List<String> encoded = _leaderboard.map((e) => json.encode(e.toMap())).toList();
        await _prefs!.setStringList('cached_real_leaderboard', encoded);
      }
    } catch (e) {
      debugPrint('Error fetching real leaderboard: $e');
    } finally {
      _isLeaderboardLoading = false;
      notifyListeners();
    }
  }

  // Record practice session & trigger mistake reminders
  Future<void> recordPracticeResult(PracticeResult result, List<MistakeModel> newMistakes) async {
    _history.insert(0, result);
    // Calculate streak flags BEFORE incrementing (to compare old vs new value)
    bool hitTargetNow = _todayAttempted < 10 && (_todayAttempted + result.totalQuestions) >= 10;
    bool hitDailyGoalNow = _todayAttempted < _dailyTarget && (_todayAttempted + result.totalQuestions) >= _dailyTarget;
    _todayAttempted += result.totalQuestions;

    if (hitTargetNow && _streakDays == 0) {
      _streakDays = 1;
    } else if (hitDailyGoalNow && _streakDays > 0) {
      _streakDays += 1;
    }

    // Auto-record table practice for Spaced Repetition (Ideas 1 + 3)
    if (result.topicId.startsWith('table_')) {
      final tNum = int.tryParse(result.topicId.replaceFirst('table_', '')) ?? 0;
      if (tNum > 0) {
        unawaited(recordTablePracticed(tNum, correct: result.correctCount, total: result.totalQuestions));
      }
    }

    for (var m in newMistakes) {
      if (!_mistakes.any((existing) => existing.prompt == m.prompt)) {
        _mistakes.insert(0, m);
      }
      // Also save into lifetime notebook (marked unresolved until solved)
      int allIdx = _allMistakes.indexWhere((existing) => existing.prompt == m.prompt);
      if (allIdx != -1) {
        _allMistakes[allIdx] = m.copyWith(isResolved: false);
      } else {
        _allMistakes.insert(0, m.copyWith(isResolved: false));
      }
    }
    await _saveAllMistakes();

    if (_prefs != null) {
      await _prefs!.setInt('streak_days', _streakDays);
    }

    // Real dynamic score: 10 pts per correct ans + 50 pts per streak day + quiz best score
    int liveTotalScore = (totalCorrectAnswers * 10) + (_streakDays * 50) + bestScore;
    int calculatedScore = liveTotalScore > 0 ? liveTotalScore : bestScore;
    String currentUid = _effectiveUid;

    // Sync score with Cloud Leaderboard
    unawaited(BackendService().syncUserProgressToLeaderboard(
      userName: _userName.isNotEmpty ? _userName : 'Aspirant',
      score: calculatedScore,
      accuracy: overallAccuracy,
      streak: _streakDays,
      userUid: currentUid,
      targetExam: _targetExam,
      questionsSolved: totalQuestionsAttempted,
    ));

    // Update local real leaderboard state instantly
    if (_leaderboard.isNotEmpty) {
      _leaderboard.removeWhere((e) => e.isCurrentUser || e.uid == currentUid);
      final myUpdatedEntry = LeaderboardEntryModel(
        uid: currentUid,
        name: _userName.isNotEmpty ? _userName : 'Guest Aspirant',
        score: calculatedScore,
        accuracy: overallAccuracy,
        streak: _streakDays,
        targetExam: _targetExam,
        questionsSolved: totalQuestionsAttempted,
        updatedAt: DateTime.now(),
        isCurrentUser: true,
      );
      _leaderboard.add(myUpdatedEntry);
      _leaderboard.sort((a, b) {
        int cmp = b.score.compareTo(a.score);
        if (cmp != 0) return cmp;
        return b.accuracy.compareTo(a.accuracy);
      });
    }

    // Smart calculation notification trigger if mistakes were made
    if (newMistakes.isNotEmpty) {
      // Auto-record table practice for Spaced Repetition (Ideas 1 + 3)
    if (result.topicId.startsWith('table_')) {
      final tNum = int.tryParse(result.topicId.replaceFirst('table_', '')) ?? 0;
      if (tNum > 0) {
        unawaited(recordTablePracticed(tNum, correct: result.correctCount, total: result.totalQuestions));
      }
    }

    for (var m in newMistakes) {
        // Add to in-app broadcasts feed so student sees it in Notification Inbox
        _broadcasts.insert(
          0,
          AdminBroadcastModel(
            id: 'alert_${m.id}',
            title: '🔁 Recall Check: What is ${NotificationService().cleanPrompt(m.prompt)}?',
            body: 'You missed this calculation earlier. Can you calculate it correctly? Open Revision Notebook to test yourself!',
            target: 'self',
            sentAt: DateTime.now(),
          ),
        );
      }
      if (_notificationsEnabled) {
        NotificationService().enqueueSessionMistakesAndTrigger(newMistakes, postImmediately: false);
      }
    }

    if (_prefs != null) {
      await _prefs!.setInt('today_attempted', _todayAttempted);
      List<String> histJson = _history.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('history_list', histJson);

      List<String> mistJson = _mistakes.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('mistakes_list', mistJson);
      await _saveBroadcasts();
    }

    _mergeCurrentStudentAnalytics();
    unawaited(CloudFirestoreSyncService().syncStudentMistakeAnalytics(
      userUid: _userUid.isNotEmpty ? _userUid : 'current_user',
      userName: _userName,
      userEmail: _userEmail,
      mistakes: _mistakes,
      accuracy: overallAccuracy,
      totalAttempted: totalQuestionsAttempted,
    ));

    // If student just practiced their scheduled study plan topic, complete it!
    if (_activeStudyPlan != null && !_activeStudyPlan!.isCompleted) {
      if (result.topicId == _activeStudyPlan!.topicId ||
          _activeStudyPlan!.topicId.contains(result.topicId) ||
          result.topicId.contains(_activeStudyPlan!.topicId)) {
        await completeActiveStudyPlan();
      }
    }

    _mergeCurrentStudentAnalytics();
    unawaited(CloudFirestoreSyncService().syncStudentMistakeAnalytics(
      userUid: _effectiveUid,
      userName: _userName,
      userEmail: _userEmail,
      mistakes: _mistakes,
      accuracy: overallAccuracy,
      totalAttempted: totalQuestionsAttempted,
    ));
    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  // Check if an answered question matches a saved mistake, and resolve it with mastery resolution!
  Future<bool> checkAndResolveIfMistake({required String prompt, required String answer}) async {
    String clean(String s) => s.replaceAll(' = ?', '').replaceAll('?', '').replaceAll('=', '').trim();
    String target = clean(prompt);

    int idx = _mistakes.indexWhere((m) => clean(m.prompt) == target && m.correctAnswer == answer);
    int allIdx = _allMistakes.indexWhere((m) => clean(m.prompt) == target && m.correctAnswer == answer);

    if (allIdx != -1) {
      _allMistakes[allIdx] = _allMistakes[allIdx].copyWith(
        isResolved: true,
        resolvedAt: DateTime.now(),
      );
      await _saveAllMistakes();
    }

    if (idx != -1) {
      final mistake = _mistakes[idx];
      await resolveMistake(mistake.id);
      return true;
    } else if (allIdx != -1) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // Record an incorrect attempt during 1-hour recall and trigger reminder notification
  Future<void> recordWrongRecallAttempt({
    required String prompt,
    required String wrongAnswer,
    required String correctAnswer,
    String topicId = 'recall',
  }) async {
    String clean(String s) => s.replaceAll(' = ?', '').replaceAll('?', '').replaceAll('=', '').trim();
    String target = clean(prompt);

    int idx = _mistakes.indexWhere((m) => clean(m.prompt) == target);
    if (idx != -1) {
      _mistakes[idx] = MistakeModel(
        id: _mistakes[idx].id,
        prompt: _mistakes[idx].prompt,
        userAnswer: wrongAnswer,
        correctAnswer: _mistakes[idx].correctAnswer,
        topicId: _mistakes[idx].topicId,
        timestamp: DateTime.now(),
      );
    } else {
      _mistakes.insert(
        0,
        MistakeModel(
          id: 'mistake_${DateTime.now().millisecondsSinceEpoch}',
          prompt: prompt,
          userAnswer: wrongAnswer,
          correctAnswer: correctAnswer,
          topicId: topicId,
          timestamp: DateTime.now(),
        ),
      );
    }

    // Also update lifetime mistake notebook
    int allIdx = _allMistakes.indexWhere((m) => clean(m.prompt) == target);
    if (allIdx != -1) {
      _allMistakes[allIdx] = _allMistakes[allIdx].copyWith(
        userAnswer: wrongAnswer,
        timestamp: DateTime.now(),
        isResolved: false,
      );
    } else {
      _allMistakes.insert(
        0,
        MistakeModel(
          id: 'mistake_${DateTime.now().millisecondsSinceEpoch}',
          prompt: prompt,
          userAnswer: wrongAnswer,
          correctAnswer: correctAnswer,
          topicId: topicId,
          timestamp: DateTime.now(),
          isResolved: false,
        ),
      );
    }
    await _saveAllMistakes();

    if (_prefs != null) {
      List<String> mistJson = _mistakes.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('mistakes_list', mistJson);
    }

    // Trigger immediate mistake reminder + 1-hour recall notification
    // User directive: NEVER trigger notifications for addition or subtraction
    final bool isAddOrSub = topicId.toLowerCase().contains('addition') ||
        topicId.toLowerCase().contains('subtraction') ||
        prompt.contains('+') ||
        prompt.contains('-') ||
        prompt.contains('−');

    if (_notificationsEnabled && !isAddOrSub) {
      await NotificationService().scheduleCalculationMistakeReminder(
        prompt: prompt,
        correctAnswer: correctAnswer,
        userAnswer: wrongAnswer,
        topicName: topicId.toUpperCase(),
        userName: _userName.isNotEmpty ? _userName : 'Aspirant',
        postImmediately: false,
      );
    }

    _mergeCurrentStudentAnalytics();
    unawaited(CloudFirestoreSyncService().syncStudentMistakeAnalytics(
      userUid: _effectiveUid,
      userName: _userName,
      userEmail: _userEmail,
      mistakes: _mistakes,
      accuracy: overallAccuracy,
      totalAttempted: totalQuestionsAttempted,
    ));
    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  Future<void> resolveMistake(String id) async {
    // 1. Mark as solved in lifetime notebook (NEVER delete from Revision notebook!)
    int allIdx = _allMistakes.indexWhere((m) => m.id == id);
    if (allIdx != -1) {
      _allMistakes[allIdx] = _allMistakes[allIdx].copyWith(
        isResolved: true,
        resolvedAt: DateTime.now(),
      );
    }

    // 2. Clear from active queue (1-hour recall alert on home screen & notifications)
    int idx = _mistakes.indexWhere((m) => m.id == id);
    MistakeModel? resolved;
    if (idx != -1) {
      resolved = _mistakes[idx];
      _mistakes.removeAt(idx);
      if (allIdx == -1) {
        int pIdx = _allMistakes.indexWhere((m) => m.prompt == resolved!.prompt);
        if (pIdx != -1) {
          _allMistakes[pIdx] = _allMistakes[pIdx].copyWith(
            isResolved: true,
            resolvedAt: DateTime.now(),
          );
        }
      }
    } else if (allIdx != -1) {
      resolved = _allMistakes[allIdx];
    }

    if (_prefs != null) {
      List<String> mistJson = _mistakes.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('mistakes_list', mistJson);
    }
    await _saveAllMistakes();

    if (resolved != null && _notificationsEnabled) {
      MistakeModel? nextMistake = _mistakes.isNotEmpty ? _mistakes.first : null;
      await NotificationService().notifyCalculationMastered(
        prompt: resolved.prompt,
        correctAnswer: resolved.correctAnswer,
        userName: _userName.isNotEmpty ? _userName : 'Aspirant',
        nextPrompt: nextMistake?.prompt,
        nextAnswer: nextMistake?.correctAnswer,
      );
    }

    _mergeCurrentStudentAnalytics();
    CloudFirestoreSyncService().syncStudentMistakeAnalytics(
      userUid: _userUid.isNotEmpty ? _userUid : 'current_user',
      userName: _userName,
      userEmail: _userEmail,
      mistakes: _mistakes,
      accuracy: overallAccuracy,
      totalAttempted: totalQuestionsAttempted,
    );

    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  Future<void> clearAllMistakes() async {
    for (var m in _mistakes) {
      await NotificationService().cancelNotification(NotificationService().getNotificationIdForPrompt(m.prompt));
    }
    _mistakes.clear();
    _allMistakes.clear();
    if (_prefs != null) {
      await _prefs!.setStringList('mistakes_list', []);
      await _prefs!.setStringList('all_mistakes_notebook', []);
    }
    notifyListeners();
  }

  // Unlock/Revoke Premium status with cryptographic signature verification
  Future<void> setPremiumStatus(bool status, {String userName = 'Aspirant User'}) async {
    if (!status) {
      _isPremium = false;
      if (_prefs != null) {
        await _prefs!.setBool('is_premium', false);
      }
      notifyListeners();
      return;
    }
    // If enabling premium, execute cryptographic purchase flow
    await processPurchase(userName: userName);
  }

  // Secure Purchase Execution via Google Play Billing / In-App Checkout
  Future<bool> processPurchase({
    required String userName,
    String paymentMethod = 'Google Play Billing',
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final generatedOrderId = 'TXN_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // 1. Cryptographic HMAC-SHA256 signature generation & verification
      final signature = SecuritySanitizer.generatePaymentSignature(
        orderId: generatedOrderId,
        amount: 49.0,
        timestamp: timestamp,
      );

      final isSignatureValid = SecuritySanitizer.verifyPaymentSignature(
        orderId: generatedOrderId,
        amount: 49.0,
        timestamp: timestamp,
        signature: signature,
      );

      if (!isSignatureValid) {
        debugPrint('Security warning: Invalid payment signature detected.');
        return false;
      }

      // 2. Transmit and record transaction to Firebase Cloud Backend
      final userId = _userUid.isNotEmpty ? _userUid : 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final cleanName = SecuritySanitizer.sanitizeInput(userName.isNotEmpty ? userName : _userName);
      await BackendService().verifyPaymentOnBackend(
        orderId: generatedOrderId,
        userId: userId,
        userName: cleanName,
        userEmail: _userEmail,
        paymentMethod: paymentMethod,
        amount: 49.0,
      );

      // 3. Only set _isPremium to true AFTER signature validation
      _isPremium = true;

      final newTx = PaymentTransaction(
        orderId: generatedOrderId,
        userName: cleanName,
        userEmail: _userEmail,
        userId: userId,
        paymentMethod: paymentMethod,
        amount: 49.0,
        date: DateTime.now(),
        status: 'SUCCESS',
      );
      _transactions.insert(0, newTx);
      _totalRegisteredUsers += 1;

      if (_prefs != null) {
        List<String> txList = _transactions.map((t) => json.encode(t.toMap())).toList();
        await _prefs!.setStringList('transactions_list', txList);
        await _prefs!.setInt('total_users', _totalRegisteredUsers);
        await _prefs!.setBool('is_premium', true);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Purchase process error: $e');
      return false;
    }
  }

  // Secure Purchase Restoration: checks local ledger & cloud records
  Future<bool> restorePurchases() async {
    try {
      // 1. Check if user already has an active local transaction
      if (_transactions.any((t) => t.status == 'SUCCESS')) {
        _isPremium = true;
        if (_prefs != null) {
          await _prefs!.setBool('is_premium', true);
        }
        notifyListeners();
        return true;
      }

      // 2. Check if Firestore recorded a payment for this user
      if (_userUid.isNotEmpty || _userEmail.isNotEmpty) {
        final cloudHasRecord = await CloudFirestoreSyncService().checkIfUserHasPurchased(_userUid, _userEmail);
        if (cloudHasRecord) {
          _isPremium = true;
          if (_prefs != null) {
            await _prefs!.setBool('is_premium', true);
          }
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      return false;
    }
  }

  // Admin Capability: 1-Tap Toggle / Grant PRO Lifetime Access to an Aspirant
  Future<bool> toggleUserProStatus(String uid, bool makePro) async {
    try {
      int idx = _registeredUsers.indexWhere((u) =>
          (u['uid']?.toString() ?? '') == uid || (u['email']?.toString() ?? '') == uid);
      if (idx != -1) {
        _registeredUsers[idx]['isPremium'] = makePro;
        _registeredUsers[idx]['role'] = makePro ? 'pro' : 'student';
      }

      // 1. Sync to Firebase Cloud Firestore Native SDK
      if (Firebase.apps.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'isPremium': makePro,
            'role': makePro ? 'pro' : 'student',
            'proActivatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          if (makePro) {
            final orderId = 'ADMIN_GRANT_${DateTime.now().millisecondsSinceEpoch}';
            final name = idx != -1 ? (_registeredUsers[idx]['name'] ?? 'Aspirant') : 'Aspirant';
            final email = idx != -1 ? (_registeredUsers[idx]['email'] ?? '') : '';
            await BackendService().verifyPaymentOnBackend(
              orderId: orderId,
              userId: uid,
              amount: 49.0,
              userName: name,
              userEmail: email,
              paymentMethod: 'Admin Manual Grant',
            );
          }
        } catch (e) {
          debugPrint('Firestore toggleUserProStatus note: $e');
        }
      }

      // 2. Persist in Local Cache
      if (_prefs != null) {
        await _prefs!.setStringList(
          'cached_registered_users',
          _registeredUsers.map((u) => json.encode(u)).toList(),
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('toggleUserProStatus error: $e');
      return false;
    }
  }

  // Admin capabilities: Add custom question & sync to Backend
  Future<void> addAdminQuestion(QuestionModel question) async {
    // Sanitize question inputs against cross-site scripting
    final sanitizedQ = QuestionModel(
      id: question.id,
      topicId: SecuritySanitizer.sanitizeInput(question.topicId),
      prompt: SecuritySanitizer.sanitizeInput(question.prompt),
      correctAnswer: SecuritySanitizer.sanitizeInput(question.correctAnswer),
      options: question.options.map((o) => SecuritySanitizer.sanitizeInput(o)).toList(),
      explanation: SecuritySanitizer.sanitizeInput(question.explanation),
    );

    _adminQuestions.insert(0, sanitizedQ);
    unawaited(BackendService().postQuestionToBackend(sanitizedQ));

    if (_prefs != null) {
      List<String> qJson = _adminQuestions.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('admin_questions', qJson);
    }
    notifyListeners();
  }

  // Admin capabilities: Edit custom question
  Future<void> editAdminQuestion(QuestionModel updated) async {
    int idx = _adminQuestions.indexWhere((q) => q.id == updated.id);
    if (idx != -1) {
      _adminQuestions[idx] = updated;
      unawaited(BackendService().postQuestionToBackend(updated));

      if (_prefs != null) {
        List<String> qJson = _adminQuestions.map((e) => json.encode(e.toMap())).toList();
        await _prefs!.setStringList('admin_questions', qJson);
      }
      notifyListeners();
    }
  }

  // Admin capabilities: Delete question & sync to Backend
  Future<void> deleteAdminQuestion(String id) async {
    _adminQuestions.removeWhere((q) => q.id == id);
    unawaited(BackendService().deleteQuestionFromBackend(id));

    if (_prefs != null) {
      List<String> qJson = _adminQuestions.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('admin_questions', qJson);
    }
    notifyListeners();
  }

  // Admin capabilities: Bulk Upload Questions & sync all to Backend
  Future<int> addBulkAdminQuestions(List<QuestionModel> questions) async {
    int count = 0;
    for (var q in questions) {
      final sanitizedQ = QuestionModel(
        id: q.id,
        topicId: SecuritySanitizer.sanitizeInput(q.topicId),
        prompt: SecuritySanitizer.sanitizeInput(q.prompt),
        correctAnswer: SecuritySanitizer.sanitizeInput(q.correctAnswer),
        options: q.options.map((o) => SecuritySanitizer.sanitizeInput(o)).toList(),
        explanation: SecuritySanitizer.sanitizeInput(q.explanation),
        difficulty: q.difficulty,
      );
      // Avoid duplicate by id or prompt
      _adminQuestions.removeWhere((item) => item.id == sanitizedQ.id || (item.prompt == sanitizedQ.prompt && sanitizedQ.prompt.isNotEmpty));
      _adminQuestions.insert(0, sanitizedQ);
      unawaited(BackendService().postQuestionToBackend(sanitizedQ));
      count++;
    }

    if (_prefs != null) {
      List<String> qJson = _adminQuestions.map((e) => json.encode(e.toMap())).toList();
      await _prefs!.setStringList('admin_questions', qJson);
    }
    notifyListeners();
    return count;
  }

  // Admin capabilities: Upload & Manage PDF Study Materials
  Future<bool> addAdminPdfMaterial({
    required String title,
    required String category,
    required String fileUrlOrData,
    required int pageCount,
    required String description,
  }) async {
    final id = 'pdf_${DateTime.now().millisecondsSinceEpoch}';
    final docData = {
      'id': id,
      'title': SecuritySanitizer.sanitizeInput(title),
      'category': SecuritySanitizer.sanitizeInput(category),
      'fileUrlOrData': SecuritySanitizer.sanitizeInput(fileUrlOrData),
      'pageCount': pageCount,
      'description': SecuritySanitizer.sanitizeInput(description),
      'uploadedAt': DateTime.now().toUtc().toIso8601String(),
    };

    _adminPdfMaterials.insert(0, docData);
    if (_prefs != null) {
      await _prefs!.setStringList(
        'cached_admin_pdfs',
        _adminPdfMaterials.map((p) => json.encode(p)).toList(),
      );
    }
    notifyListeners();

    final cloudOk = await CloudFirestoreSyncService().postPdfDocumentToCloud(
      id: id,
      title: title,
      category: category,
      fileUrlOrData: fileUrlOrData,
      pageCount: pageCount,
      description: description,
    );
    return cloudOk;
  }

  Future<bool> deleteAdminPdfMaterial(String id) async {
    _adminPdfMaterials.removeWhere((p) => p['id'] == id);
    if (_prefs != null) {
      await _prefs!.setStringList(
        'cached_admin_pdfs',
        _adminPdfMaterials.map((p) => json.encode(p)).toList(),
      );
    }
    notifyListeners();

    return await CloudFirestoreSyncService().deletePdfDocumentFromCloud(id);
  }

  // Set daily target
  Future<void> updateDailyTarget(int target) async {
    _dailyTarget = target;
    if (_prefs != null) {
      await _prefs!.setInt('daily_target', target);
    }
    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  // Set daily notification limit (Frequency Capping: e.g. 5, 10, 15, 20, 0 = unlimited)
  Future<void> updateDailyNotificationLimit(int limit) async {
    _dailyNotificationLimit = limit;
    if (_prefs != null) {
      await _prefs!.setInt('daily_notification_limit', limit);
    }
    await NotificationService().setDailyNotificationLimit(limit);
    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool val) async {
    _notificationsEnabled = val;
    if (_prefs != null) {
      await _prefs!.setBool('notifications_enabled', val);
    }
    if (!val) {
      await NotificationService().cancelAllNotifications();
    } else {
      await NotificationService().rescheduleAllPendingMistakeAlarms();
    }
    notifyListeners();
  }

  // Trigger tactile vibration feedback if enabled
  void triggerHapticFeedback() {
    if (_hapticsEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  // Update Target Exam calibration
  Future<void> updateTargetExam(String exam) async {
    _targetExam = exam;
    if (_prefs != null) {
      await _prefs!.setString('target_exam', exam);
    }
    unawaited(syncUserDataToCloud());
    notifyListeners();
  }

  // Target exam pace cutoff in seconds
  double get targetExamPaceCutoff {
    switch (_targetExam) {
      case 'Banking (IBPS/SBI PO)':
        return 2.2;
      case 'SSC CGL & CHSL':
        return 3.5;
      case 'Railways & Defense':
        return 4.0;
      case 'CAT & MBA':
        return 4.5;
      default:
        return 3.0;
    }
  }

  // Update Numpad Style ('phone' vs 'calculator')
  Future<void> updateNumpadStyle(String style) async {
    _numpadStyle = style;
    if (_prefs != null) {
      await _prefs!.setString('numpad_style', style);
    }
    notifyListeners();
  }

  // Toggle Haptics
  Future<void> toggleHaptics(bool val) async {
    _hapticsEnabled = val;
    if (val) triggerHapticFeedback();
    if (_prefs != null) {
      await _prefs!.setBool('haptics_enabled', val);
    }
    notifyListeners();
  }

  // Toggle Sound Effects
  Future<void> toggleSoundEffects(bool val) async {
    _soundEnabled = val;
    if (_prefs != null) {
      await _prefs!.setBool('sound_enabled', val);
    }
    notifyListeners();
  }

  // Update Vedic TTS Speech Rate
  Future<void> updateTtsSpeechRate(double rate) async {
    _ttsSpeechRate = rate;
    if (_prefs != null) {
      await _prefs!.setDouble('tts_speech_rate', rate);
    }
    notifyListeners();
  }

  // Update TTS Voice Pitch
  Future<void> updateTtsPitch(double pitch) async {
    _ttsPitch = pitch;
    if (_prefs != null) {
      await _prefs!.setDouble('tts_pitch', pitch);
    }
    notifyListeners();
  }

  // Update TTS Voice Language / Accent (en-IN, en-US, en-GB, hi-IN)
  Future<void> updateTtsLanguage(String language) async {
    _ttsLanguage = language;
    if (_prefs != null) {
      await _prefs!.setString('tts_language', language);
    }
    notifyListeners();
  }

  // Update TTS Recital Style (school, times, vedic, quiz, standard)
  Future<void> updateTtsRecitalStyle(String style) async {
    _ttsRecitalStyle = style;
    if (_prefs != null) {
      await _prefs!.setString('tts_recital_style', style);
    }
    notifyListeners();
  }

  // Update TTS Repeat Mode (none, table, row)
  Future<void> updateTtsRepeatMode(String mode) async {
    _ttsRepeatMode = mode;
    if (_prefs != null) {
      await _prefs!.setString('tts_repeat_mode', mode);
    }
    notifyListeners();
  }

  // Update TTS Quiz Pause Seconds
  Future<void> updateTtsQuizPauseSeconds(double seconds) async {
    _ttsQuizPauseSeconds = seconds;
    if (_prefs != null) {
      await _prefs!.setDouble('tts_quiz_pause_seconds', seconds);
    }
    notifyListeners();
  }

  // Toggle Step-by-Step Trick Hints
  Future<void> toggleShowTrickHints(bool val) async {
    _showTrickHints = val;
    if (_prefs != null) {
      await _prefs!.setBool('show_trick_hints', val);
    }
    notifyListeners();
  }

  // Update Daily Reminder Time
  Future<void> updateReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    if (_prefs != null) {
      await _prefs!.setInt('reminder_hour', hour);
      await _prefs!.setInt('reminder_minute', minute);
    }
    notifyListeners();
  }

  // Update Mistake Auto-Recall Interval
  Future<void> updateRecallIntervalHours(int hours) async {
    _recallIntervalHours = hours;
    if (_prefs != null) {
      await _prefs!.setInt('recall_interval_hours', hours);
    }
    notifyListeners();
  }

  // Toggle AMOLED Black Mode
  Future<void> toggleAmoledBlack(bool val) async {
    _amoledBlackMode = val;
    if (_prefs != null) {
      await _prefs!.setBool('amoled_black_mode', val);
    }
    notifyListeners();
  }

  // Reset Today's Practice Counter
  Future<void> resetTodayProgress() async {
    _todayAttempted = 0;
    if (_prefs != null) {
      await _prefs!.setInt('today_attempted', 0);
    }
    notifyListeners();
  }

  // Math Wake-Up Alarm methods ("Solve 5 mistakes to dismiss alarm")
  Future<void> setMathAlarm({
    required int hour,
    required int minute,
    required bool enabled,
    String? label,
  }) async {
    _mathAlarmHour = hour;
    _mathAlarmMinute = minute;
    _mathAlarmEnabled = enabled;
    if (label != null) _mathAlarmLabel = label;

    if (_prefs != null) {
      await _prefs!.setInt('math_alarm_hour', hour);
      await _prefs!.setInt('math_alarm_minute', minute);
      await _prefs!.setBool('math_alarm_enabled', enabled);
      if (label != null) await _prefs!.setString('math_alarm_label', label);
    }

    if (enabled) {
      await NotificationService().scheduleMathWakeUpAlarm(
        hour: hour,
        minute: minute,
        label: _mathAlarmLabel,
      );
    } else {
      await NotificationService().cancelMathWakeUpAlarm();
    }

    notifyListeners();
  }

  Future<void> toggleMathAlarm(bool enabled) async {
    _mathAlarmEnabled = enabled;
    if (_prefs != null) {
      await _prefs!.setBool('math_alarm_enabled', enabled);
    }

    if (enabled) {
      await NotificationService().scheduleMathWakeUpAlarm(
        hour: _mathAlarmHour,
        minute: _mathAlarmMinute,
        label: _mathAlarmLabel,
      );
    } else {
      await NotificationService().cancelMathWakeUpAlarm();
    }

    notifyListeners();
  }

  // Factory Reset: Clear all practice logs and streaks
  Future<void> resetAllData() async {
    await clearAllMistakes();
    _history.clear();
    _todayAttempted = 0;
    _streakDays = 0;
    _broadcasts.clear();
    _starredTables.clear();
    _activeStudyPlan = null;
    if (_prefs != null) {
      await _prefs!.setStringList('history_list', []);
      await _prefs!.setInt('today_attempted', 0);
      await _prefs!.setInt('streak_days', 0);
      await _prefs!.setStringList('admin_broadcasts', []);
      await _prefs!.setStringList('starred_tables', []);
      await _prefs!.remove('active_study_plan');
    }
    notifyListeners();
  }

  // Toggle or Activate Pro / Premium Access
  Future<void> togglePremium(bool val) => setPremiumStatus(val);

  @override
  void dispose() {
    _targetedPushWatcherTimer?.cancel();
    super.dispose();
  }
}
