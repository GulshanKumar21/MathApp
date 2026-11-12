import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/math_models.dart';

class CloudFirestoreSyncService {
  static final CloudFirestoreSyncService _instance = CloudFirestoreSyncService._internal();
  factory CloudFirestoreSyncService() => _instance;
  CloudFirestoreSyncService._internal();

  // Primary Firebase Firestore REST API configuration
  // Auto-connects to speedmath-practice Firebase project
  final String _projectId = 'speedmath-practice';
  String get _firestoreBaseUrl => 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {}
    return headers;
  }

  // 1. Sync Exam Mock Test Result to Firebase Cloud
  Future<bool> syncExamMockResult({
    required String userUid,
    required String examTitle,
    required int score,
    required double accuracy,
    required double timeTakenSeconds,
  }) async {
    try {
      final docData = {
        'fields': {
          'userUid': {'stringValue': userUid},
          'examTitle': {'stringValue': examTitle},
          'score': {'integerValue': score.toString()},
          'accuracy': {'doubleValue': accuracy},
          'timeTakenSeconds': {'doubleValue': timeTakenSeconds},
          'timestamp': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final response = await http.post(
        Uri.parse('$_firestoreBaseUrl/exam_mock_results'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Cloud sync notice: Exam mock saved in local cache ($e)');
      return false;
    }
  }

  // 2. Sync 1v1 Multiplayer Duel Match to Firebase Cloud
  Future<bool> recordDuelMatch({
    required String player1Name,
    required int player1Score,
    required String player2Name,
    required int player2Score,
    required String winner,
  }) async {
    try {
      final docData = {
        'fields': {
          'player1': {'stringValue': player1Name},
          'player1Score': {'integerValue': player1Score.toString()},
          'player2': {'stringValue': player2Name},
          'player2Score': {'integerValue': player2Score.toString()},
          'winner': {'stringValue': winner},
          'timestamp': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final response = await http.post(
        Uri.parse('$_firestoreBaseUrl/duel_matches'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Cloud sync notice: Duel match recorded locally ($e)');
      return false;
    }
  }

  // 3. Sync Weakness Heatmap Matrix (Real AI diagnostic cloud sync)
  Future<bool> syncWeaknessProfile({
    required String userUid,
    required List<int> weakTables,
    required List<int> weakSquares,
  }) async {
    try {
      final docData = {
        'fields': {
          'userUid': {'stringValue': userUid},
          'weakTables': {
            'arrayValue': {
              'values': weakTables.map((t) => {'integerValue': t.toString()}).toList()
            }
          },
          'weakSquares': {
            'arrayValue': {
              'values': weakSquares.map((s) => {'integerValue': s.toString()}).toList()
            }
          },
          'lastDiagnosed': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/user_diagnostics/$userUid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Cloud diagnostic notice: Saved to local profile ($e)');
      return false;
    }
  }

  // 4. Sync Student Mistake Log to Cloud Firestore for Admin Portal
  Future<bool> syncStudentMistakeAnalytics({
    required String userUid,
    required String userName,
    required String userEmail,
    required List<MistakeModel> mistakes,
    required double accuracy,
    required int totalAttempted,
  }) async {
    if (userUid.isEmpty) return false;

    // Strategy 1: Firebase Firestore Native SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('student_mistakes').doc(userUid).set({
          'studentUid': userUid,
          'studentName': userName,
          'studentEmail': userEmail,
          'totalMistakes': mistakes.length,
          'accuracy': accuracy,
          'totalAttempted': totalAttempted,
          'mistakesJson': json.encode(mistakes.map((m) => m.toMap()).toList()),
          'lastActive': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Cloud Sync: Student mistake analytics uploaded to Firestore SDK for $userName ($userUid)');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK student mistakes sync note: $e');
      }
    }

    // Strategy 2: Firebase REST API Fallback
    try {
      final docData = {
        'fields': {
          'studentUid': {'stringValue': userUid},
          'studentName': {'stringValue': userName},
          'studentEmail': {'stringValue': userEmail},
          'totalMistakes': {'integerValue': mistakes.length.toString()},
          'accuracy': {'doubleValue': accuracy},
          'totalAttempted': {'integerValue': totalAttempted.toString()},
          'mistakesJson': {
            'stringValue': json.encode(mistakes.map((m) => m.toMap()).toList())
          },
          'lastActive': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/student_mistakes/$userUid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Student mistake cloud sync notice: Recorded locally ($e)');
      return false;
    }
  }

  // 5. Fetch Live Student Mistake Analytics for Admin Channel (Aggregating student_mistakes & users)
  Future<List<Map<String, dynamic>>> fetchStudentMistakesForAdmin() async {
    final Map<String, Map<String, dynamic>> resultsMap = {};

    // Strategy 1: Firebase Firestore Native SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('student_mistakes')
            .get();

        for (var doc in snap.docs) {
          final data = doc.data();
          String lastActiveStr = (data['lastActive'] is Timestamp)
              ? (data['lastActive'] as Timestamp).toDate().toIso8601String()
              : data['lastActive']?.toString() ?? DateTime.now().toIso8601String();

          final key = data['studentUid']?.toString() ?? doc.id;
          resultsMap[key] = {
            'studentUid': key,
            'studentName': data['studentName']?.toString() ?? 'Aspirant',
            'studentEmail': data['studentEmail']?.toString() ?? '',
            'totalMistakes': (data['totalMistakes'] is num) ? (data['totalMistakes'] as num).toInt() : 0,
            'accuracy': (data['accuracy'] is num) ? (data['accuracy'] as num).toDouble() : 0.0,
            'totalAttempted': (data['totalAttempted'] is num) ? (data['totalAttempted'] as num).toInt() : 0,
            'mistakesJson': data['mistakesJson']?.toString() ?? '[]',
            'lastActive': lastActiveStr,
          };
        }

        // Also enrich with users collection (where mistakes are synced via syncFullUserDataToCloud)
        final userSnap = await FirebaseFirestore.instance.collection('users').get();
        for (var uDoc in userSnap.docs) {
          final uData = uDoc.data();
          final uid = uData['uid']?.toString() ?? uDoc.id;
          final mJson = uData['mistakesJson']?.toString() ?? '';
          if (mJson.isNotEmpty && mJson != '[]') {
            if (!resultsMap.containsKey(uid)) {
              int totalAtt = (uData['totalAttempted'] is num) ? (uData['totalAttempted'] as num).toInt() : 0;
              int totalCorr = (uData['totalCorrect'] is num) ? (uData['totalCorrect'] as num).toInt() : 0;
              double acc = totalAtt > 0 ? (totalCorr / totalAtt * 100) : 0.0;
              int mistCount = 0;
              try {
                mistCount = (json.decode(mJson) as List).length;
              } catch (_) {}

              resultsMap[uid] = {
                'studentUid': uid,
                'studentName': uData['name']?.toString() ?? 'Aspirant',
                'studentEmail': uData['email']?.toString() ?? '',
                'totalMistakes': mistCount,
                'accuracy': acc,
                'totalAttempted': totalAtt,
                'mistakesJson': mJson,
                'lastActive': uData['lastActive']?.toString() ?? DateTime.now().toIso8601String(),
              };
            } else if (resultsMap[uid]!['totalMistakes'] == 0 && mJson != '[]') {
              resultsMap[uid]!['mistakesJson'] = mJson;
              try {
                resultsMap[uid]!['totalMistakes'] = (json.decode(mJson) as List).length;
              } catch (_) {}
            }
          }
        }

        if (resultsMap.isNotEmpty) return resultsMap.values.toList();
      } catch (e) {
        debugPrint('Firestore SDK fetch student mistakes note: $e');
      }
    }

    // Strategy 2: Firebase REST API Fallback
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/student_mistakes'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          for (var doc in data['documents']) {
            var fields = doc['fields'] ?? {};
            final uid = fields['studentUid']?['stringValue'] ?? '';
            if (uid.isEmpty) continue;
            resultsMap[uid] = {
              'studentUid': uid,
              'studentName': fields['studentName']?['stringValue'] ?? 'Aspirant',
              'studentEmail': fields['studentEmail']?['stringValue'] ?? '',
              'totalMistakes': int.tryParse(fields['totalMistakes']?['integerValue'] ?? '0') ?? 0,
              'accuracy': (fields['accuracy']?['doubleValue'] ?? 0.0).toDouble(),
              'totalAttempted': int.tryParse(fields['totalAttempted']?['integerValue'] ?? '0') ?? 0,
              'mistakesJson': fields['mistakesJson']?['stringValue'] ?? '[]',
              'lastActive': fields['lastActive']?['timestampValue'] ?? DateTime.now().toIso8601String(),
            };
          }
        }
      }

      // Also check users collection via REST
      try {
        final uRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/users?pageSize=300'),
          headers: headers,
        ).timeout(const Duration(seconds: 4));
        if (uRes.statusCode == 200) {
          final uData = json.decode(uRes.body);
          if (uData['documents'] != null) {
            for (var doc in uData['documents']) {
              var fields = doc['fields'] ?? {};
              final uid = fields['uid']?['stringValue'] ?? '';
              final mJson = fields['mistakesJson']?['stringValue'] ?? '';
              if (uid.isNotEmpty && mJson.isNotEmpty && mJson != '[]') {
                if (!resultsMap.containsKey(uid)) {
                  int totalAtt = int.tryParse(fields['totalAttempted']?['integerValue'] ?? '0') ?? 0;
                  int totalCorr = int.tryParse(fields['totalCorrect']?['integerValue'] ?? '0') ?? 0;
                  double acc = totalAtt > 0 ? (totalCorr / totalAtt * 100) : 0.0;
                  int mistCount = 0;
                  try {
                    mistCount = (json.decode(mJson) as List).length;
                  } catch (_) {}

                  resultsMap[uid] = {
                    'studentUid': uid,
                    'studentName': fields['name']?['stringValue'] ?? 'Aspirant',
                    'studentEmail': fields['email']?['stringValue'] ?? '',
                    'totalMistakes': mistCount,
                    'accuracy': acc,
                    'totalAttempted': totalAtt,
                    'mistakesJson': mJson,
                    'lastActive': fields['lastActive']?['timestampValue'] ?? DateTime.now().toIso8601String(),
                  };
                }
              }
            }
          }
        }
      } catch (_) {}

      return resultsMap.values.toList();
    } catch (e) {
      debugPrint('Admin mistake fetch notice: Operating with local analytics data ($e)');
    }
    return resultsMap.values.toList();
  }

  // 6. Save User Profile to Cloud Firestore
  Future<bool> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    String phone = '',
    String role = 'student',
    bool isNewUser = false,
  }) async {
    if (uid.isEmpty) return false;

    // Strategy 1: Firestore Native SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        final payload = <String, dynamic>{
          'uid': uid,
          'name': name,
          'email': email,
          'role': role,
          'lastActive': FieldValue.serverTimestamp(),
        };
        if (phone.isNotEmpty) {
          payload['phone'] = phone;
        }
        if (isNewUser) {
          payload['registeredAt'] = FieldValue.serverTimestamp();
        }
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          payload,
          SetOptions(merge: true),
        );
        return true;
      } catch (e) {
        debugPrint('Firestore SDK save user note: $e');
      }
    }

    // Strategy 2: REST API (uses updateMask so existing progress fields are NEVER overwritten)
    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final fields = <String, dynamic>{
        'uid': {'stringValue': uid},
        'name': {'stringValue': name},
        'email': {'stringValue': email},
        'role': {'stringValue': role},
        'lastActive': {'timestampValue': nowIso},
      };
      final maskParams = <String>[
        'updateMask.fieldPaths=uid',
        'updateMask.fieldPaths=name',
        'updateMask.fieldPaths=email',
        'updateMask.fieldPaths=role',
        'updateMask.fieldPaths=lastActive',
      ];
      if (phone.isNotEmpty) {
        fields['phone'] = {'stringValue': phone};
        maskParams.add('updateMask.fieldPaths=phone');
      }
      if (isNewUser) {
        fields['registeredAt'] = {'timestampValue': nowIso};
        maskParams.add('updateMask.fieldPaths=registeredAt');
      }

      final docData = {'fields': fields};
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/users/$uid?${maskParams.join('&')}'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 12));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Save user profile cloud notice: $e');
      return false;
    }
  }

  // 6-Full. Sync complete user study progress, history, and mistakes to Cloud Backend
  Future<bool> syncFullUserDataToCloud({
    required String uid,
    required String name,
    required String email,
    required String role,
    required String targetExam,
    required int score,
    required int bestScore,
    required int streakDays,
    required int todayAttempted,
    required int totalAttempted,
    required int totalCorrect,
    required int dailyTarget,
    required bool isPremium,
    required List<int> starredTables,
    required List<MistakeModel> mistakes,
    required List<PracticeResult> history,
  }) async {
    if (uid.isEmpty) return false;

    final String mistakesJson = json.encode(mistakes.map((m) => m.toMap()).toList());
    final String historyJson = json.encode(history.map((h) => h.toMap()).toList());

    // 1. Try native Firestore SDK if initialized
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'name': name,
          'email': email,
          'role': role,
          'targetExam': targetExam,
          'score': score,
          'bestScore': bestScore,
          'streakDays': streakDays,
          'todayAttempted': todayAttempted,
          'totalAttempted': totalAttempted,
          'totalCorrect': totalCorrect,
          'dailyTarget': dailyTarget,
          'isPremium': isPremium,
          'starredTables': starredTables,
          'mistakesJson': mistakesJson,
          'historyJson': historyJson,
          'lastActive': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('Cloud Sync: Full user progress saved for $name ($uid)');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK full user sync note: $e');
      }
    }

    // 2. Fallback to Firebase REST API
    try {
      final docData = {
        'fields': {
          'uid': {'stringValue': uid},
          'name': {'stringValue': name},
          'email': {'stringValue': email},
          'role': {'stringValue': role},
          'targetExam': {'stringValue': targetExam},
          'score': {'integerValue': score.toString()},
          'bestScore': {'integerValue': bestScore.toString()},
          'streakDays': {'integerValue': streakDays.toString()},
          'todayAttempted': {'integerValue': todayAttempted.toString()},
          'totalAttempted': {'integerValue': totalAttempted.toString()},
          'totalCorrect': {'integerValue': totalCorrect.toString()},
          'dailyTarget': {'integerValue': dailyTarget.toString()},
          'isPremium': {'booleanValue': isPremium},
          'starredTables': {
            'arrayValue': {
              'values': starredTables.map((t) => {'integerValue': t.toString()}).toList()
            }
          },
          'mistakesJson': {'stringValue': mistakesJson},
          'historyJson': {'stringValue': historyJson},
          'lastActive': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/users/$uid'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 12));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Cloud full user sync error: $e');
      return false;
    }
  }

  // 6-Restore. Fetch full user study progress, history, and mistakes from Cloud Backend
  Future<Map<String, dynamic>?> fetchFullUserDataFromCloud(String uid) async {
    if (uid.isEmpty) return null;

    // Strategy 1: Firebase Cloud Firestore native SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          return {
            'uid': data['uid']?.toString() ?? uid,
            'name': data['name']?.toString() ?? '',
            'email': data['email']?.toString() ?? '',
            'role': data['role']?.toString() ?? 'student',
            'targetExam': data['targetExam']?.toString() ?? 'SSC CGL',
            'score': (data['score'] is num) ? (data['score'] as num).toInt() : int.tryParse(data['score']?.toString() ?? '0') ?? 0,
            'bestScore': (data['bestScore'] is num) ? (data['bestScore'] as num).toInt() : int.tryParse(data['bestScore']?.toString() ?? '0') ?? 0,
            'streakDays': (data['streakDays'] is num) ? (data['streakDays'] as num).toInt() : int.tryParse(data['streakDays']?.toString() ?? '1') ?? 1,
            'todayAttempted': (data['todayAttempted'] is num) ? (data['todayAttempted'] as num).toInt() : int.tryParse(data['todayAttempted']?.toString() ?? '0') ?? 0,
            'totalAttempted': (data['totalAttempted'] is num) ? (data['totalAttempted'] as num).toInt() : int.tryParse(data['totalAttempted']?.toString() ?? '0') ?? 0,
            'totalCorrect': (data['totalCorrect'] is num) ? (data['totalCorrect'] as num).toInt() : int.tryParse(data['totalCorrect']?.toString() ?? '0') ?? 0,
            'dailyTarget': (data['dailyTarget'] is num) ? (data['dailyTarget'] as num).toInt() : int.tryParse(data['dailyTarget']?.toString() ?? '30') ?? 30,
            'isPremium': data['isPremium'] == true,
            'starredTables': (data['starredTables'] is List)
                ? (data['starredTables'] as List).map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e > 0).toList()
                : <int>[],
            'mistakesJson': data['mistakesJson']?.toString() ?? '[]',
            'historyJson': data['historyJson']?.toString() ?? '[]',
          };
        }
      } catch (e) {
        debugPrint('Firestore SDK fetch user note: $e');
      }
    }

    // Strategy 2: Firebase REST API Fallback
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/users/$uid'),
        headers: headers,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fields = data['fields'] ?? {};
        return {
          'uid': fields['uid']?['stringValue'] ?? uid,
          'name': fields['name']?['stringValue'] ?? '',
          'email': fields['email']?['stringValue'] ?? '',
          'role': fields['role']?['stringValue'] ?? 'student',
          'targetExam': fields['targetExam']?['stringValue'] ?? 'SSC CGL',
          'score': int.tryParse(fields['score']?['integerValue']?.toString() ?? '0') ?? 0,
          'bestScore': int.tryParse(fields['bestScore']?['integerValue']?.toString() ?? '0') ?? 0,
          'streakDays': int.tryParse(fields['streakDays']?['integerValue']?.toString() ?? '1') ?? 1,
          'todayAttempted': int.tryParse(fields['todayAttempted']?['integerValue']?.toString() ?? '0') ?? 0,
          'totalAttempted': int.tryParse(fields['totalAttempted']?['integerValue']?.toString() ?? '0') ?? 0,
          'totalCorrect': int.tryParse(fields['totalCorrect']?['integerValue']?.toString() ?? '0') ?? 0,
          'dailyTarget': int.tryParse(fields['dailyTarget']?['integerValue']?.toString() ?? '30') ?? 30,
          'isPremium': fields['isPremium']?['booleanValue'] == true,
          'starredTables': (fields['starredTables']?['arrayValue']?['values'] as List?)
                  ?.map((v) => int.tryParse(v['integerValue']?.toString() ?? '0') ?? 0)
                  .where((n) => n > 0)
                  .toList() ??
              <int>[],
          'mistakesJson': fields['mistakesJson']?['stringValue'] ?? '[]',
          'historyJson': fields['historyJson']?['stringValue'] ?? '[]',
        };
      }
    } catch (e) {
      debugPrint('Cloud fetch user error: $e');
    }
    return null;
  }

  // 6a. Fetch Real Registered Users from Cloud Firestore (Aggregating users, leaderboard, mistakes & admins)
  Future<List<Map<String, dynamic>>> fetchUsersFromCloud() async {
    final Map<String, Map<String, dynamic>> userMap = {};

    void mergeUser({
      required String uid,
      required String name,
      required String email,
      String phone = '',
      String role = 'student',
      int score = 0,
      double accuracy = 0.0,
      int streak = 0,
      String targetExam = 'SSC CGL',
      int questionsSolved = 0,
      String? registeredAt,
      String? lastActive,
    }) {
      String cleanUid = uid.trim();
      String cleanEmail = email.trim().toLowerCase();
      String cleanName = name.trim();

      if (cleanName.isEmpty && cleanEmail.isNotEmpty) {
        final prefix = cleanEmail.split('@').first;
        cleanName = prefix.isNotEmpty
            ? '${prefix[0].toUpperCase()}${prefix.substring(1)}'
            : 'Aspirant';
      }
      if (cleanName.isEmpty) cleanName = 'Aspirant';

      // Aggressive multi-field deduplication (matches by UID, Email, OR matching Name)
      String? matchedKey;
      for (var entry in userMap.entries) {
        final existingUid = (entry.value['uid']?.toString() ?? '').trim().toLowerCase();
        final existingEmail = (entry.value['email']?.toString() ?? '').trim().toLowerCase();
        final existingName = (entry.value['name']?.toString() ?? '').trim().toLowerCase();

        final cUid = cleanUid.toLowerCase();
        final cEmail = cleanEmail.toLowerCase();
        final cName = cleanName.toLowerCase();

        // 1. Exact UID match
        if (cUid.isNotEmpty && existingUid.isNotEmpty && cUid == existingUid) {
          matchedKey = entry.key;
          break;
        }
        // 2. Exact Email match (case-insensitive)
        if (cEmail.isNotEmpty && existingEmail.isNotEmpty && cEmail == existingEmail) {
          matchedKey = entry.key;
          break;
        }
        // 3. Exact Name match (as long as it's not generic 'Aspirant')
        if (cName.isNotEmpty && cName != 'aspirant' && cName != 'guest aspirant' &&
            existingName.isNotEmpty && existingName != 'aspirant' && existingName != 'guest aspirant' &&
            cName == existingName) {
          matchedKey = entry.key;
          break;
        }
      }

      final key = matchedKey ??
          (cleanEmail.isNotEmpty
              ? cleanEmail
              : (cleanUid.isNotEmpty ? cleanUid : cleanName.toLowerCase()));
      if (key.isEmpty) return;

      if (!userMap.containsKey(key)) {
        userMap[key] = {
          'uid': cleanUid.isNotEmpty ? cleanUid : key,
          'name': cleanName,
          'email': cleanEmail,
          'phone': phone,
          'role': (role.toLowerCase() == 'admin' || cleanEmail == 'gulshankumar.dev01@gmail.com') ? 'admin' : role,
          'score': score,
          'accuracy': accuracy,
          'streak': streak,
          'targetExam': targetExam.isNotEmpty ? targetExam : 'SSC CGL',
          'questionsSolved': questionsSolved,
          'registeredAt': registeredAt ?? DateTime.now().toIso8601String(),
          'lastActive': lastActive ?? DateTime.now().toIso8601String(),
        };
      } else {
        final existing = userMap[key]!;
        if (cleanUid.isNotEmpty && (existing['uid'] == null || existing['uid'].toString().isEmpty)) {
          existing['uid'] = cleanUid;
        }
        if (cleanName != 'Aspirant' && (existing['name'] == 'Aspirant' || existing['name'] == null || existing['name'].toString().isEmpty)) {
          existing['name'] = cleanName;
        }
        if (cleanEmail.isNotEmpty && (existing['email'] == null || existing['email'].toString().isEmpty)) {
          existing['email'] = cleanEmail;
        }
        if (phone.isNotEmpty && (existing['phone'] == null || existing['phone'].toString().isEmpty)) {
          existing['phone'] = phone;
        }
        if (role.toLowerCase() == 'admin' || cleanEmail == 'gulshankumar.dev01@gmail.com' || existing['role']?.toString().toLowerCase() == 'admin') {
          existing['role'] = 'admin';
        }
        if (score > (existing['score'] as int? ?? 0)) {
          existing['score'] = score;
        }
        if (questionsSolved > (existing['questionsSolved'] as int? ?? 0)) {
          existing['questionsSolved'] = questionsSolved;
        }
        if (accuracy > 0.0 && ((existing['accuracy'] as double? ?? 0.0) == 0.0 || questionsSolved >= (existing['questionsSolved'] as int? ?? 0))) {
          existing['accuracy'] = accuracy;
        }
        if (streak > (existing['streak'] as int? ?? 0)) {
          existing['streak'] = streak;
        }
        if (targetExam.isNotEmpty && targetExam != 'SSC CGL') {
          existing['targetExam'] = targetExam;
        }
        if (lastActive != null) {
          existing['lastActive'] = lastActive;
        }
      }
    }

    // 1. Native Firebase Cloud Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        // A. Primary 'users' collection
        try {
          final snap = await FirebaseFirestore.instance.collection('users').get();
          for (var doc in snap.docs) {
            final data = doc.data();
            final uid = (data['uid']?.toString() ?? doc.id).trim();
            final name = (data['name']?.toString() ??
                    data['userName']?.toString() ??
                    data['displayName']?.toString() ??
                    '')
                .trim();
            final email = (data['email']?.toString() ?? '').trim();
            final phone = data['phone']?.toString() ?? '';
            final role = data['role']?.toString() ?? 'student';
            final score = (data['score'] is num)
                ? (data['score'] as num).toInt()
                : int.tryParse(data['score']?.toString() ?? '0') ?? 0;
            final accuracy = (data['accuracy'] is num)
                ? (data['accuracy'] as num).toDouble()
                : double.tryParse(data['accuracy']?.toString() ?? '0.0') ?? 0.0;
            final streak = (data['streak'] is num)
                ? (data['streak'] as num).toInt()
                : int.tryParse(data['streak']?.toString() ?? '0') ?? 0;
            final targetExam = data['targetExam']?.toString() ?? 'SSC CGL';
            final questionsSolved = (data['questionsSolved'] is num)
                ? (data['questionsSolved'] as num).toInt()
                : int.tryParse(data['questionsSolved']?.toString() ?? '0') ?? 0;
            final registeredAt = (data['registeredAt'] is Timestamp)
                ? (data['registeredAt'] as Timestamp).toDate().toIso8601String()
                : data['registeredAt']?.toString();
            final lastActive = (data['lastActive'] is Timestamp)
                ? (data['lastActive'] as Timestamp).toDate().toIso8601String()
                : data['lastActive']?.toString();

            mergeUser(
              uid: uid,
              name: name,
              email: email,
              phone: phone,
              role: role,
              score: score,
              accuracy: accuracy,
              streak: streak,
              targetExam: targetExam,
              questionsSolved: questionsSolved,
              registeredAt: registeredAt,
              lastActive: lastActive,
            );
          }
        } catch (e) {
          debugPrint('Firestore SDK users collection fetch: $e');
        }

        // B. 'leaderboard' collection
        try {
          final lbSnap = await FirebaseFirestore.instance.collection('leaderboard').get();
          for (var doc in lbSnap.docs) {
            final data = doc.data();
            final uid = (data['uid']?.toString() ?? doc.id).trim();
            final name = (data['userName']?.toString() ??
                    data['name']?.toString() ??
                    data['displayName']?.toString() ??
                    '')
                .trim();
            final email = (data['email']?.toString() ?? '').trim();
            final score = (data['score'] is num)
                ? (data['score'] as num).toInt()
                : int.tryParse(data['score']?.toString() ?? '0') ?? 0;
            final accuracy = (data['accuracy'] is num)
                ? (data['accuracy'] as num).toDouble()
                : double.tryParse(data['accuracy']?.toString() ?? '0.0') ?? 0.0;
            final streak = (data['streak'] is num)
                ? (data['streak'] as num).toInt()
                : int.tryParse(data['streak']?.toString() ?? '0') ?? 0;
            final targetExam = data['targetExam']?.toString() ?? 'SSC CGL';
            final questionsSolved = (data['questionsSolved'] is num)
                ? (data['questionsSolved'] as num).toInt()
                : int.tryParse(data['questionsSolved']?.toString() ?? '0') ?? 0;
            final updatedAt = (data['updatedAt'] is Timestamp)
                ? (data['updatedAt'] as Timestamp).toDate().toIso8601String()
                : data['updatedAt']?.toString();

            mergeUser(
              uid: uid,
              name: name,
              email: email,
              score: score,
              accuracy: accuracy,
              streak: streak,
              targetExam: targetExam,
              questionsSolved: questionsSolved,
              lastActive: updatedAt,
            );
          }
        } catch (e) {
          debugPrint('Firestore SDK leaderboard collection fetch: $e');
        }

        // C. 'student_mistakes' collection
        try {
          final mistakesSnap = await FirebaseFirestore.instance.collection('student_mistakes').get();
          for (var doc in mistakesSnap.docs) {
            final data = doc.data();
            final uid = (data['studentUid']?.toString() ?? doc.id).trim();
            final name = (data['studentName']?.toString() ?? '').trim();
            final email = (data['studentEmail']?.toString() ?? '').trim();
            final totalAttempted = int.tryParse(data['totalAttempted']?.toString() ?? '0') ?? 0;
            final accuracy = (data['accuracy'] is num)
                ? (data['accuracy'] as num).toDouble()
                : double.tryParse(data['accuracy']?.toString() ?? '0.0') ?? 0.0;
            final lastActive = (data['lastActive'] is Timestamp)
                ? (data['lastActive'] as Timestamp).toDate().toIso8601String()
                : data['lastActive']?.toString();

            mergeUser(
              uid: uid,
              name: name,
              email: email,
              score: totalAttempted * 10,
              accuracy: accuracy,
              questionsSolved: totalAttempted,
              lastActive: lastActive,
            );
          }
        } catch (e) {
          debugPrint('Firestore SDK student_mistakes collection fetch: $e');
        }

        // D. 'admins' collection
        try {
          final adminSnap = await FirebaseFirestore.instance.collection('admins').get();
          for (var doc in adminSnap.docs) {
            final data = doc.data();
            final uid = (data['uid']?.toString() ?? doc.id).trim();
            final name = (data['name']?.toString() ?? data['displayName']?.toString() ?? '').trim();
            final email = (data['email']?.toString() ?? (doc.id.contains('@') ? doc.id : '')).trim();

            mergeUser(
              uid: uid,
              name: name,
              email: email,
              role: 'admin',
            );
          }
        } catch (e) {
          debugPrint('Firestore SDK admins collection fetch: $e');
        }

        // E. Current authenticated Firebase user (if any)
        try {
          final currentAuth = FirebaseAuth.instance.currentUser;
          if (currentAuth != null) {
            final uid = currentAuth.uid.trim();
            final email = (currentAuth.email ?? '').trim();
            final name = (currentAuth.displayName ?? '').trim();
            final phone = (currentAuth.phoneNumber ?? '').trim();
            if (uid.isNotEmpty || email.isNotEmpty) {
              mergeUser(
                uid: uid,
                name: name,
                email: email,
                phone: phone,
              );
            }
          }
        } catch (_) {}



        if (userMap.isNotEmpty) {
          return userMap.values.toList();
        }
      } catch (e) {
        debugPrint('Firestore SDK fetch users note: $e');
      }
    }

    // 2. Firebase REST API Fallback (Aggregates users, leaderboard, student_mistakes, admins)
    try {
      final headers = await _getAuthHeaders();

      // A. Query /users
      try {
        final response = await http.get(
          Uri.parse('$_firestoreBaseUrl/users?pageSize=300'),
          headers: headers,
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['documents'] != null) {
            for (var doc in data['documents']) {
              final docPath = doc['name']?.toString() ?? '';
              final docId = docPath.split('/').last;
              var fields = doc['fields'] ?? {};

              String uid = (fields['uid']?['stringValue']?.toString() ?? docId).trim();
              String name = (fields['name']?['stringValue']?.toString() ??
                      fields['userName']?['stringValue']?.toString() ??
                      fields['displayName']?['stringValue']?.toString() ??
                      '')
                  .trim();
              final email = (fields['email']?['stringValue']?.toString() ?? '').trim();

              mergeUser(
                uid: uid,
                name: name,
                email: email,
                phone: fields['phone']?['stringValue'] ?? '',
                role: fields['role']?['stringValue'] ?? 'student',
                score: int.tryParse(fields['score']?['integerValue']?.toString() ?? '0') ?? 0,
                accuracy: (fields['accuracy']?['doubleValue'] is num)
                    ? (fields['accuracy']!['doubleValue'] as num).toDouble()
                    : 0.0,
                streak: int.tryParse(fields['streak']?['integerValue']?.toString() ?? '0') ?? 0,
                targetExam: fields['targetExam']?['stringValue'] ?? 'SSC CGL',
                questionsSolved: int.tryParse(fields['questionsSolved']?['integerValue']?.toString() ?? '0') ?? 0,
                registeredAt: fields['registeredAt']?['timestampValue'],
                lastActive: fields['lastActive']?['timestampValue'],
              );
            }
          }
        }
      } catch (e) {
        debugPrint('REST API users fetch notice: $e');
      }

      // B. Query /leaderboard
      try {
        final lbRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/leaderboard?pageSize=300'),
          headers: headers,
        ).timeout(const Duration(seconds: 10));

        if (lbRes.statusCode == 200) {
          final data = json.decode(lbRes.body);
          if (data['documents'] != null) {
            for (var doc in data['documents']) {
              final docPath = doc['name']?.toString() ?? '';
              final docId = docPath.split('/').last;
              var fields = doc['fields'] ?? {};

              String uid = (fields['uid']?['stringValue']?.toString() ?? docId).trim();
              String name = (fields['userName']?['stringValue']?.toString() ??
                      fields['name']?['stringValue']?.toString() ??
                      fields['displayName']?['stringValue']?.toString() ??
                      '')
                  .trim();
              final email = (fields['email']?['stringValue']?.toString() ?? '').trim();

              mergeUser(
                uid: uid,
                name: name,
                email: email,
                score: int.tryParse(fields['score']?['integerValue']?.toString() ?? '0') ?? 0,
                accuracy: (fields['accuracy']?['doubleValue'] is num)
                    ? (fields['accuracy']!['doubleValue'] as num).toDouble()
                    : 0.0,
                streak: int.tryParse(fields['streak']?['integerValue']?.toString() ?? '0') ?? 0,
                targetExam: fields['targetExam']?['stringValue'] ?? 'SSC CGL',
                questionsSolved: int.tryParse(fields['questionsSolved']?['integerValue']?.toString() ?? '0') ?? 0,
                lastActive: fields['updatedAt']?['timestampValue'],
              );
            }
          }
        }
      } catch (e) {
        debugPrint('REST API leaderboard fetch notice: $e');
      }

      // C. Query /student_mistakes
      try {
        final mistRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/student_mistakes?pageSize=300'),
          headers: headers,
        ).timeout(const Duration(seconds: 10));

        if (mistRes.statusCode == 200) {
          final data = json.decode(mistRes.body);
          if (data['documents'] != null) {
            for (var doc in data['documents']) {
              final docPath = doc['name']?.toString() ?? '';
              final docId = docPath.split('/').last;
              var fields = doc['fields'] ?? {};

              String uid = (fields['studentUid']?['stringValue']?.toString() ?? docId).trim();
              String name = (fields['studentName']?['stringValue']?.toString() ?? '').trim();
              final email = (fields['studentEmail']?['stringValue']?.toString() ?? '').trim();
              int totalAttempted = int.tryParse(fields['totalAttempted']?['integerValue']?.toString() ?? '0') ?? 0;

              mergeUser(
                uid: uid,
                name: name,
                email: email,
                score: totalAttempted * 10,
                accuracy: (fields['accuracy']?['doubleValue'] is num)
                    ? (fields['accuracy']!['doubleValue'] as num).toDouble()
                    : 0.0,
                questionsSolved: totalAttempted,
                lastActive: fields['lastActive']?['timestampValue'],
              );
            }
          }
        }
      } catch (e) {
        debugPrint('REST API student_mistakes fetch notice: $e');
      }

      // D. Query /admins
      try {
        final adminRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/admins?pageSize=300'),
          headers: headers,
        ).timeout(const Duration(seconds: 10));

        if (adminRes.statusCode == 200) {
          final data = json.decode(adminRes.body);
          if (data['documents'] != null) {
            for (var doc in data['documents']) {
              final docPath = doc['name']?.toString() ?? '';
              final docId = docPath.split('/').last;
              var fields = doc['fields'] ?? {};

              String uid = (fields['uid']?['stringValue']?.toString() ?? docId).trim();
              String name = (fields['name']?['stringValue']?.toString() ?? fields['displayName']?['stringValue']?.toString() ?? '').trim();
              final email = (fields['email']?['stringValue']?.toString() ?? (docId.contains('@') ? docId : '')).trim();

              mergeUser(
                uid: uid,
                name: name,
                email: email,
                role: 'admin',
              );
            }
          }
        }
      } catch (e) {
        debugPrint('REST API admins fetch notice: $e');
      }

      if (userMap.isNotEmpty) {
        return userMap.values.toList();
      }
    } catch (e) {
      debugPrint('Fetch users cloud notice: $e');
    }
    return userMap.values.toList();
  }

  // 6c. Upload Study PDF Note / Cheat Sheet Document metadata to Cloud Firestore
  Future<bool> postPdfDocumentToCloud({
    required String id,
    required String title,
    required String category,
    required String fileUrlOrData,
    required int pageCount,
    required String description,
  }) async {
    // Strategy 1: Native Firebase Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('admin_pdf_materials').doc(id).set({
          'id': id,
          'title': title,
          'category': category,
          'fileUrlOrData': fileUrlOrData,
          'pageCount': pageCount,
          'description': description,
          'uploadedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Firestore SDK: Posted PDF $id successfully');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK post PDF notice: $e');
      }
    }

    // Strategy 2: Authenticated REST API Fallback
    try {
      final docData = {
        'fields': {
          'id': {'stringValue': id},
          'title': {'stringValue': title},
          'category': {'stringValue': category},
          'fileUrlOrData': {'stringValue': fileUrlOrData},
          'pageCount': {'integerValue': pageCount.toString()},
          'description': {'stringValue': description},
          'uploadedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/admin_pdf_materials/$id'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Post PDF document cloud notice: $e');
      return false;
    }
  }

  // 6d. Fetch PDF Documents from Cloud Firestore
  Future<List<Map<String, dynamic>>> fetchPdfDocumentsFromCloud() async {
    try {
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/admin_pdf_materials'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          List<Map<String, dynamic>> results = [];
          for (var doc in data['documents']) {
            var fields = doc['fields'] ?? {};
            results.add({
              'id': fields['id']?['stringValue'] ?? '',
              'title': fields['title']?['stringValue'] ?? 'Formula Sheet',
              'category': fields['category']?['stringValue'] ?? 'Tables',
              'fileUrlOrData': fields['fileUrlOrData']?['stringValue'] ?? '',
              'pageCount': int.tryParse(fields['pageCount']?['integerValue'] ?? '1') ?? 1,
              'description': fields['description']?['stringValue'] ?? '',
              'uploadedAt': fields['uploadedAt']?['timestampValue'] ?? DateTime.now().toIso8601String(),
            });
          }
          return results;
        }
      }
    } catch (e) {
      debugPrint('Fetch PDF documents cloud notice: $e');
    }
    return [];
  }

  // 6e. Delete PDF Document from Cloud Firestore
  Future<bool> deletePdfDocumentFromCloud(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_firestoreBaseUrl/admin_pdf_materials/$id'),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete PDF cloud notice: $e');
      return false;
    }
  }

  // 6b. Fetch User Role directly from Firebase Cloud Firestore ("admin direct firebase se hi bna kr id password denge")
  Future<String> fetchUserRoleFromCloud(String uid, String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // 0. Require real authenticated Firebase user for privileged owner check
    // Never grant admin blindly from unverified email patterns like 'admin_*'.
    try {
      final currentAuthUser = FirebaseAuth.instance.currentUser;
      final authedEmail = currentAuthUser?.email?.trim().toLowerCase() ?? '';
      if (currentAuthUser != null &&
          authedEmail == 'gulshankumar.dev01@gmail.com' &&
          (cleanEmail.isEmpty || cleanEmail == authedEmail)) {
        return 'admin';
      }
    } catch (_) {}

    // 1. Native Firestore SDK check
    if (Firebase.apps.isNotEmpty) {
      try {
        if (uid.isNotEmpty) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (userDoc.exists) {
            final data = userDoc.data() ?? {};
            final role = data['role']?.toString().toLowerCase().trim();
            if (role == 'admin') return 'admin';
          }
          final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(uid).get();
          if (adminDoc.exists) return 'admin';
        }

        if (cleanEmail.isNotEmpty) {
          final adminEmailDoc = await FirebaseFirestore.instance.collection('admins').doc(cleanEmail).get();
          if (adminEmailDoc.exists) return 'admin';

          final query = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: cleanEmail)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            final role = query.docs.first.data()['role']?.toString().toLowerCase().trim();
            if (role == 'admin') return 'admin';
          }
        }
      } catch (e) {
        debugPrint('Firestore SDK user role check notice: $e');
      }
    }

    // 2. Firebase REST API Fallback with Auth Headers
    try {
      final headers = await _getAuthHeaders();

      // Check user profile in Firestore by UID: users/$uid
      if (uid.isNotEmpty) {
        final response = await http.get(
          Uri.parse('$_firestoreBaseUrl/users/$uid'),
          headers: headers,
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final fields = data['fields'] ?? {};
          final role = fields['role']?['stringValue'];
          if (role != null && role.trim().toLowerCase() == 'admin') {
            return 'admin';
          }
        }
      }

      // Check if user document is stored with safe email key
      if (cleanEmail.isNotEmpty) {
        String safeEmail = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
        final emailDocRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/users/$safeEmail'),
          headers: headers,
        ).timeout(const Duration(seconds: 4));
        if (emailDocRes.statusCode == 200) {
          final data = json.decode(emailDocRes.body);
          final fields = data['fields'] ?? {};
          final role = fields['role']?['stringValue'];
          if (role != null && role.trim().toLowerCase() == 'admin') {
            return 'admin';
          }
        }

        // Check 'admins' collection
        final adminEmailRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/admins/$safeEmail'),
          headers: headers,
        ).timeout(const Duration(seconds: 4));
        if (adminEmailRes.statusCode == 200) return 'admin';
      }

      // Check if UID exists in 'admins' collection
      if (uid.isNotEmpty) {
        final adminUidRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/admins/$uid'),
          headers: headers,
        ).timeout(const Duration(seconds: 4));
        if (adminUidRes.statusCode == 200) return 'admin';
      }
    } catch (e) {
      debugPrint('Cloud user role fetch note: $e');
    }
    return 'student';
  }

  // 7. Fetch Questions from Cloud Firestore
  Future<List<QuestionModel>> fetchQuestionsFromCloud() async {
    // Strategy 1: Native Firebase Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance.collection('admin_questions').get();
        if (snap.docs.isNotEmpty) {
          final questions = snap.docs.map((doc) {
            final data = doc.data();
            return QuestionModel(
              id: data['id']?.toString() ?? doc.id,
              topicId: data['topicId']?.toString() ?? 'daily_admin',
              prompt: data['prompt']?.toString() ?? '',
              correctAnswer: data['correctAnswer']?.toString() ?? '',
              options: (data['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
              explanation: data['explanation']?.toString() ?? '',
              difficulty: (data['difficulty'] is num)
                  ? (data['difficulty'] as num).toInt()
                  : int.tryParse(data['difficulty']?.toString() ?? '1') ?? 1,
            );
          }).toList();
          debugPrint('Firestore SDK: Fetched ${questions.length} admin questions');
          return questions;
        }
      } catch (e) {
        debugPrint('Firestore SDK fetch admin questions notice: $e');
      }
    }

    // Strategy 2: Authenticated REST API Fallback
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/admin_questions'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          List<QuestionModel> questions = [];
          for (var doc in data['documents']) {
            var fields = doc['fields'] ?? {};
            String name = doc['name'] ?? '';
            String id = name.split('/').last;
            questions.add(QuestionModel(
              id: id,
              topicId: fields['topicId']?['stringValue'] ?? 'daily_admin',
              prompt: fields['prompt']?['stringValue'] ?? '',
              correctAnswer: fields['correctAnswer']?['stringValue'] ?? '',
              options: (fields['options']?['arrayValue']?['values'] as List?)
                      ?.map((v) => v['stringValue']?.toString() ?? '')
                      .toList() ??
                  [],
              explanation: fields['explanation']?['stringValue'] ?? '',
              difficulty: int.tryParse(fields['difficulty']?['integerValue']?.toString() ?? '1') ?? 1,
            ));
          }
          return questions;
        }
      }
    } catch (e) {
      debugPrint('Cloud questions fetch notice: $e');
    }
    return [];
  }

  // 8. Publish Question to Cloud Firestore
  Future<bool> postQuestionToCloud(QuestionModel question) async {
    // Strategy 1: Native Firebase Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('admin_questions').doc(question.id).set({
          'id': question.id,
          'topicId': question.topicId,
          'prompt': question.prompt,
          'correctAnswer': question.correctAnswer,
          'difficulty': question.difficulty,
          'options': question.options,
          'explanation': question.explanation,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Firestore SDK: Posted question ${question.id} successfully');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK post question notice: $e');
      }
    }

    // Strategy 2: Authenticated REST API Fallback
    try {
      final docData = {
        'fields': {
          'id': {'stringValue': question.id},
          'topicId': {'stringValue': question.topicId},
          'prompt': {'stringValue': question.prompt},
          'correctAnswer': {'stringValue': question.correctAnswer},
          'difficulty': {'integerValue': question.difficulty.toString()},
          'options': {
            'arrayValue': {
              'values': question.options.map((o) => {'stringValue': o}).toList(),
            }
          },
          'explanation': {'stringValue': question.explanation},
          'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/admin_questions/${question.id}'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Cloud post question notice: $e');
      return false;
    }
  }

  // 9. Delete Question from Cloud Firestore
  Future<bool> deleteQuestionFromCloud(String questionId) async {
    // Strategy 1: Native Firebase Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('admin_questions').doc(questionId).delete();
        debugPrint('Firestore SDK: Deleted question $questionId');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK delete question notice: $e');
      }
    }

    // Strategy 2: Authenticated REST API Fallback
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_firestoreBaseUrl/admin_questions/$questionId'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Cloud delete question notice: $e');
      return false;
    }
  }

  // 10. Record Payment to Cloud Firestore
  Future<bool> recordPayment({
    required String orderId,
    required String userId,
    required double amount,
    String userName = '',
    String userEmail = '',
    String paymentMethod = 'Google Play Billing',
  }) async {
    // 1. Try Firebase Native Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('payment_transactions').doc(orderId).set({
          'orderId': orderId,
          'userId': userId,
          'userName': userName.isNotEmpty ? userName : 'Aspirant',
          'userEmail': userEmail,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'currency': 'INR',
          'status': 'SUCCESS',
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (userId.isNotEmpty) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(userId).set({
              'isPremium': true,
              'proActivatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (_) {}
        }
        debugPrint('Firestore SDK: Successfully recorded payment $orderId in cloud!');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK record payment notice: $e');
      }
    }

    // 2. REST API Fallback
    try {
      final docData = {
        'fields': {
          'orderId': {'stringValue': orderId},
          'userId': {'stringValue': userId},
          'userName': {'stringValue': userName.isNotEmpty ? userName : 'Aspirant'},
          'userEmail': {'stringValue': userEmail},
          'paymentMethod': {'stringValue': paymentMethod},
          'amount': {'doubleValue': amount},
          'currency': {'stringValue': 'INR'},
          'status': {'stringValue': 'SUCCESS'},
          'timestamp': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/payment_transactions/$orderId'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 4));

      if (userId.isNotEmpty) {
        try {
          final userPatchData = {
            'fields': {
              'isPremium': {'booleanValue': true},
            }
          };
          await http.patch(
            Uri.parse('$_firestoreBaseUrl/users/$userId?updateMask.fieldPaths=isPremium'),
            headers: headers,
            body: json.encode(userPatchData),
          ).timeout(const Duration(seconds: 4));
        } catch (_) {}
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Payment sync notice: $e');
      return false;
    }
  }

  // Cache of verified UTRs to prevent immediate duplicate attempts
  static final Set<String> _locallyVerifiedUtrs = {};

  // 10B. Check if a 12-Digit UPI UTR has already been claimed / used
  Future<bool> checkIsUtrAlreadyUsed(String utr) async {
    final cleanUtr = utr.trim().replaceAll(RegExp(r'\s+'), '');
    if (cleanUtr.length != 12) return false;

    // Check fast cache first
    if (_locallyVerifiedUtrs.contains(cleanUtr)) return true;

    // 1. Try Firebase native SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('verified_utrs').doc(cleanUtr).get();
        if (doc.exists) {
          _locallyVerifiedUtrs.add(cleanUtr);
          return true;
        }
      } catch (e) {
        debugPrint('Firestore SDK check UTR notice: $e');
      }
    }

    // 2. REST API fallback
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/verified_utrs/$cleanUtr'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _locallyVerifiedUtrs.add(cleanUtr);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // 10C. Record Verified 12-Digit UPI UTR in Cloud Firestore
  Future<bool> recordVerifiedPaymentUtr({
    required String utr,
    required String userId,
    required String userName,
    required double amount,
  }) async {
    final cleanUtr = utr.trim().replaceAll(RegExp(r'\s+'), '');
    if (cleanUtr.length != 12) return false;

    // Lock in local cache immediately
    _locallyVerifiedUtrs.add(cleanUtr);

    // 1. Try Firebase native SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('verified_utrs').doc(cleanUtr).set({
          'utr': cleanUtr,
          'userId': userId,
          'userName': userName,
          'amount': amount,
          'currency': 'INR',
          'status': 'VERIFIED',
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Firestore SDK: Verified and locked UTR $cleanUtr in cloud!');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK record UTR notice: $e');
      }
    }

    // 2. REST API fallback
    try {
      final docData = {
        'fields': {
          'utr': {'stringValue': cleanUtr},
          'userId': {'stringValue': userId},
          'userName': {'stringValue': userName},
          'amount': {'doubleValue': amount},
          'currency': {'stringValue': 'INR'},
          'status': {'stringValue': 'VERIFIED'},
          'timestamp': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/verified_utrs/$cleanUtr'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      // In local testing/offline environment with mock binding, local cache persistence validates claim
      return _locallyVerifiedUtrs.contains(cleanUtr);
    } catch (e) {
      debugPrint('Cloud UTR sync notice: $e');
      return true; // Local verification fallback
    }
  }

  // 11. Sync Leaderboard Entry to Cloud Firestore
  Future<bool> syncLeaderboardEntry({
    required String userName,
    required int score,
    required double accuracy,
    required int streak,
    String userUid = '',
    String targetExam = 'SSC CGL',
    int questionsSolved = 0,
  }) async {
    String safeId = (userUid.isNotEmpty ? userUid : userName)
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (safeId.isEmpty) safeId = 'student_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Try Firebase Cloud Firestore native SDK if initialized
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('leaderboard').doc(safeId).set({
          'uid': userUid,
          'userName': userName,
          'score': score,
          'accuracy': accuracy,
          'streak': streak,
          'targetExam': targetExam,
          'questionsSolved': questionsSolved,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Leaderboard: Synced $userName ($safeId) to Cloud Firestore SDK');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK leaderboard sync fallback to REST: $e');
      }
    }

    // 2. Fallback to Firebase REST API
    try {
      final docData = {
        'fields': {
          'uid': {'stringValue': userUid},
          'userName': {'stringValue': userName},
          'score': {'integerValue': score.toString()},
          'accuracy': {'doubleValue': accuracy},
          'streak': {'integerValue': streak.toString()},
          'targetExam': {'stringValue': targetExam},
          'questionsSolved': {'integerValue': questionsSolved.toString()},
          'updatedAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/leaderboard/$safeId'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 12));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Leaderboard cloud sync notice: $e');
      return false;
    }
  }

  // 11b. Fetch Live All-India Leaderboard strictly from Cloud Backend
  Future<List<Map<String, dynamic>>> fetchLeaderboardFromCloud() async {
    List<Map<String, dynamic>> results = [];

    // Strategy 1: Firebase Cloud Firestore native SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        QuerySnapshot<Map<String, dynamic>> lbSnap;
        try {
          lbSnap = await FirebaseFirestore.instance
              .collection('leaderboard')
              .orderBy('score', descending: true)
              .get();
        } catch (_) {
          lbSnap = await FirebaseFirestore.instance
              .collection('leaderboard')
              .get();
        }

        for (var doc in lbSnap.docs) {
          final data = doc.data();
          String uid = (data['uid']?.toString() ?? doc.id).trim();
          String name = (data['userName']?.toString() ??
              data['name']?.toString() ??
              data['displayName']?.toString() ??
              '').trim();
          final email = (data['email']?.toString() ?? '').trim();
          if (name.isEmpty && email.isNotEmpty) {
            final prefix = email.split('@').first;
            name = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
          }
          if (name.isEmpty) name = 'Aspirant';

          int score = (data['score'] is num)
              ? (data['score'] as num).toInt()
              : int.tryParse(data['score']?.toString() ?? '0') ?? 0;
          double accuracy = (data['accuracy'] is num)
              ? (data['accuracy'] as num).toDouble()
              : double.tryParse(data['accuracy']?.toString() ?? '0.0') ?? 0.0;
          int streak = (data['streak'] is num)
              ? (data['streak'] as num).toInt()
              : int.tryParse(data['streak']?.toString() ?? '0') ?? 0;
          String targetExam = data['targetExam']?.toString() ?? 'SSC CGL';
          int questionsSolved = (data['questionsSolved'] is num)
              ? (data['questionsSolved'] as num).toInt()
              : int.tryParse(data['questionsSolved']?.toString() ?? '0') ?? 0;
          String updatedAt = (data['updatedAt'] is Timestamp)
              ? (data['updatedAt'] as Timestamp).toDate().toIso8601String()
              : data['updatedAt']?.toString() ?? DateTime.now().toIso8601String();

          if (!results.any((r) => r['uid'] == uid || (email.isNotEmpty && r['email'] == email))) {
            results.add({
              'uid': uid.isNotEmpty ? uid : doc.id,
              'userName': name,
              'email': email,
              'score': score,
              'accuracy': accuracy,
              'streak': streak,
              'targetExam': targetExam,
              'questionsSolved': questionsSolved,
              'updatedAt': updatedAt,
            });
          }
        }

        // Also fetch from 'users' collection to include all registered students who have real score or baseline
        try {
          final usersSnap = await FirebaseFirestore.instance.collection('users').get();
          for (var doc in usersSnap.docs) {
            final data = doc.data();
            String uid = (data['uid']?.toString() ?? doc.id).trim();
            String name = (data['name']?.toString() ??
                data['userName']?.toString() ??
                data['displayName']?.toString() ??
                '').trim();
            final email = (data['email']?.toString() ?? '').trim();
            if (name.isEmpty && email.isNotEmpty) {
              final prefix = email.split('@').first;
              name = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
            }
            if (name.isEmpty) name = 'Aspirant';

            int userScore = (data['score'] is num)
                ? (data['score'] as num).toInt()
                : int.tryParse(data['score']?.toString() ?? '0') ?? 0;
            int userQuestions = (data['questionsSolved'] is num)
                ? (data['questionsSolved'] as num).toInt()
                : int.tryParse(data['questionsSolved']?.toString() ?? '0') ?? 0;

            if (!results.any((r) => r['uid'] == uid || (email.isNotEmpty && r['email'] == email))) {
              results.add({
                'uid': uid.isNotEmpty ? uid : doc.id,
                'userName': name,
                'email': email,
                'score': userScore,
                'accuracy': (data['accuracy'] is num)
                    ? (data['accuracy'] as num).toDouble()
                    : double.tryParse(data['accuracy']?.toString() ?? '0.0') ?? 0.0,
                'streak': (data['streak'] is num)
                    ? (data['streak'] as num).toInt()
                    : int.tryParse(data['streak']?.toString() ?? '0') ?? 0,
                'targetExam': data['targetExam']?.toString() ?? 'SSC CGL',
                'questionsSolved': userQuestions,
                'updatedAt': (data['lastActive'] is Timestamp)
                    ? (data['lastActive'] as Timestamp).toDate().toIso8601String()
                    : data['lastActive']?.toString() ?? DateTime.now().toIso8601String(),
              });
            }
          }
        } catch (_) {}



        // Also fetch from 'student_mistakes' collection in case any active student has quiz activity
        try {
          final mistakesSnap = await FirebaseFirestore.instance.collection('student_mistakes').get();
          for (var doc in mistakesSnap.docs) {
            final data = doc.data();
            String uid = (data['studentUid']?.toString() ?? doc.id).trim();
            String name = (data['studentName']?.toString() ?? '').trim();
            final email = (data['studentEmail']?.toString() ?? '').trim();
            if (name.isEmpty && email.isNotEmpty) {
              final prefix = email.split('@').first;
              name = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
            }
            if (name.isEmpty) name = 'Aspirant';

            int totalAttempted = int.tryParse(data['totalAttempted']?.toString() ?? '0') ?? 0;
            double acc = (data['accuracy'] is num) ? (data['accuracy'] as num).toDouble() : 0.0;

            if (!results.any((r) => r['uid'] == uid || (email.isNotEmpty && r['email'] == email))) {
              results.add({
                'uid': uid.isNotEmpty ? uid : doc.id,
                'userName': name,
                'email': email,
                'score': totalAttempted * 10,
                'accuracy': acc,
                'streak': 1,
                'targetExam': 'SSC CGL',
                'questionsSolved': totalAttempted,
                'updatedAt': (data['lastActive'] is Timestamp)
                    ? (data['lastActive'] as Timestamp).toDate().toIso8601String()
                    : data['lastActive']?.toString() ?? DateTime.now().toIso8601String(),
              });
            }
          }
        } catch (_) {}



        if (results.isNotEmpty) {
          debugPrint('Loaded ${results.length} real contestants via Firestore SDK.');
          return results;
        }
      } catch (e) {
        debugPrint('Firestore SDK leaderboard query note: $e');
      }
    }

    // Strategy 2: Firebase REST API Fallback
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/leaderboard?pageSize=300'),
        headers: headers,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          for (var doc in data['documents']) {
            final docPath = doc['name']?.toString() ?? '';
            final docId = docPath.split('/').last;
            var fields = doc['fields'] ?? {};
            String uid = (fields['uid']?['stringValue']?.toString() ?? docId).trim();
            String name = (fields['userName']?['stringValue']?.toString() ??
                fields['name']?['stringValue']?.toString() ??
                fields['displayName']?['stringValue']?.toString() ??
                '').trim();
            final email = (fields['email']?['stringValue']?.toString() ?? '').trim();
            if (name.isEmpty && email.isNotEmpty) {
              final prefix = email.split('@').first;
              name = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
            }
            if (name.isEmpty) name = 'Aspirant';

            int score = int.tryParse(fields['score']?['integerValue']?.toString() ??
                fields['score']?['stringValue']?.toString() ??
                '0') ??
                (fields['score']?['doubleValue'] is num ? (fields['score']!['doubleValue'] as num).toInt() : 0);

            double accuracy = (fields['accuracy']?['doubleValue'] is num)
                ? (fields['accuracy']!['doubleValue'] as num).toDouble()
                : double.tryParse(fields['accuracy']?['stringValue']?.toString() ?? '0.0') ?? 0.0;

            int streak = int.tryParse(fields['streak']?['integerValue']?.toString() ??
                fields['streak']?['stringValue']?.toString() ??
                '0') ?? 0;

            String targetExam = fields['targetExam']?['stringValue'] ?? 'SSC CGL';
            int questionsSolved = int.tryParse(fields['questionsSolved']?['integerValue']?.toString() ??
                fields['questionsSolved']?['stringValue']?.toString() ??
                '0') ?? 0;

            String updatedAt = fields['updatedAt']?['timestampValue'] ?? DateTime.now().toIso8601String();

            if (!results.any((r) => r['uid'] == uid || (email.isNotEmpty && r['email'] == email))) {
              results.add({
                'uid': uid.isNotEmpty ? uid : docId,
                'userName': name,
                'email': email,
                'score': score,
                'accuracy': accuracy,
                'streak': streak,
                'targetExam': targetExam,
                'questionsSolved': questionsSolved,
                'updatedAt': updatedAt,
              });
            }
          }
        }
      }

      // Also fetch users collection strictly with real data
      try {
        final usersRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/users?pageSize=300'),
          headers: headers,
        ).timeout(const Duration(seconds: 12));
        if (usersRes.statusCode == 200) {
          final uData = json.decode(usersRes.body);
          if (uData['documents'] != null) {
            for (var doc in uData['documents']) {
              final docPath = doc['name']?.toString() ?? '';
              final docId = docPath.split('/').last;
              var fields = doc['fields'] ?? {};
              String uid = (fields['uid']?['stringValue']?.toString() ?? docId).trim();
              String name = (fields['name']?['stringValue']?.toString() ??
                  fields['userName']?['stringValue']?.toString() ??
                  fields['displayName']?['stringValue']?.toString() ??
                  '').trim();
              final email = (fields['email']?['stringValue']?.toString() ?? '').trim();
              if (name.isEmpty && email.isNotEmpty) {
                final prefix = email.split('@').first;
                name = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
              }
              if (name.isEmpty) name = 'Aspirant';

              int userScore = int.tryParse(fields['score']?['integerValue']?.toString() ?? '0') ?? 0;
              int userQuestions = int.tryParse(fields['questionsSolved']?['integerValue']?.toString() ?? '0') ?? 0;

              if (!results.any((r) => r['uid'] == uid || (email.isNotEmpty && r['email'] == email))) {
                results.add({
                  'uid': uid.isNotEmpty ? uid : docId,
                  'userName': name,
                  'email': email,
                  'score': userScore,
                  'accuracy': (fields['accuracy']?['doubleValue'] is num ? (fields['accuracy']!['doubleValue'] as num).toDouble() : 0.0),
                  'streak': int.tryParse(fields['streak']?['integerValue']?.toString() ?? '0') ?? 0,
                  'targetExam': fields['targetExam']?['stringValue'] ?? 'SSC CGL',
                  'questionsSolved': userQuestions,
                  'updatedAt': fields['lastActive']?['timestampValue'] ?? DateTime.now().toIso8601String(),
                });
              }
            }
          }
        }
      } catch (_) {}

      // Also fetch student_mistakes collection in REST fallback
      try {
        final mistRes = await http.get(
          Uri.parse('$_firestoreBaseUrl/student_mistakes?pageSize=300'),
          headers: headers,
        ).timeout(const Duration(seconds: 10));
        if (mistRes.statusCode == 200) {
          final mData = json.decode(mistRes.body);
          if (mData['documents'] != null) {
            for (var doc in mData['documents']) {
              final docPath = doc['name']?.toString() ?? '';
              final docId = docPath.split('/').last;
              var fields = doc['fields'] ?? {};
              String uid = (fields['studentUid']?['stringValue']?.toString() ?? docId).trim();
              String name = (fields['studentName']?['stringValue']?.toString() ?? '').trim();
              final email = (fields['studentEmail']?['stringValue']?.toString() ?? '').trim();
              if (name.isEmpty && email.isNotEmpty) {
                final prefix = email.split('@').first;
                name = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
              }
              if (name.isEmpty) name = 'Aspirant';

              int totalAttempted = int.tryParse(fields['totalAttempted']?['integerValue']?.toString() ?? '0') ?? 0;
              double acc = (fields['accuracy']?['doubleValue'] is num) ? (fields['accuracy']!['doubleValue'] as num).toDouble() : 0.0;

              if (!results.any((r) => r['uid'] == uid || (email.isNotEmpty && r['email'] == email))) {
                results.add({
                  'uid': uid.isNotEmpty ? uid : docId,
                  'userName': name,
                  'email': email,
                  'score': totalAttempted * 10,
                  'accuracy': acc,
                  'streak': 1,
                  'targetExam': 'SSC CGL',
                  'questionsSolved': totalAttempted,
                  'updatedAt': fields['lastActive']?['timestampValue'] ?? DateTime.now().toIso8601String(),
                });
              }
            }
          }
        }
      } catch (_) {}

      return results;
    } catch (e) {
      debugPrint('Cloud leaderboard fetch note: $e');
    }
    return results;
  }

  // 12. Save Broadcast to Cloud Firestore
  Future<bool> saveBroadcastToCloud({
    required String title,
    required String message,
  }) async {
    String id = 'bc_${DateTime.now().millisecondsSinceEpoch}';

    // Strategy 1: Native Firebase Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('broadcasts').doc(id).set({
          'id': id,
          'title': title,
          'message': message,
          'sentAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Firestore SDK: Saved broadcast $id');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK save broadcast notice: $e');
      }
    }

    // Strategy 2: Authenticated REST API Fallback
    try {
      final docData = {
        'fields': {
          'id': {'stringValue': id},
          'title': {'stringValue': title},
          'message': {'stringValue': message},
          'sentAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      };

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$_firestoreBaseUrl/broadcasts/$id'),
        headers: headers,
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Broadcast cloud notice: $e');
      return false;
    }
  }

  // 13. Fetch Payment Transactions from Cloud Firestore (Multi-Collection Aggregation)
  Future<List<Map<String, dynamic>>> fetchPaymentTransactionsForAdmin() async {
    final Map<String, Map<String, dynamic>> txMap = {};

    void mergeTx({
      required String orderId,
      required String userId,
      String userName = '',
      String userEmail = '',
      String paymentMethod = 'Google Play Billing',
      double amount = 49.0,
      String status = 'SUCCESS',
      DateTime? date,
    }) {
      final cleanOrderId = orderId.trim();
      final cleanUserId = userId.trim();
      String cleanName = userName.trim();
      final cleanEmail = userEmail.trim();
      final dt = date ?? DateTime.now();

      if (cleanName.isEmpty && cleanEmail.isNotEmpty) {
        final prefix = cleanEmail.split('@').first;
        cleanName = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Aspirant';
      }
      if (cleanName.isEmpty) {
        cleanName = cleanUserId.isNotEmpty ? (cleanUserId.startsWith('usr_') ? 'Aspirant' : cleanUserId) : 'Aspirant';
      }

      // Key by Order ID, UTR, or User ID
      String key = cleanOrderId;
      if (key.isEmpty) {
        key = cleanUserId.isNotEmpty ? 'TX_$cleanUserId' : 'TX_${txMap.length + 1}';
      }

      if (!txMap.containsKey(key)) {
        txMap[key] = {
          'orderId': cleanOrderId.isNotEmpty ? cleanOrderId : key,
          'userId': cleanUserId,
          'userName': cleanName,
          'userEmail': cleanEmail,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'date': dt.toIso8601String(),
          'status': status,
        };
      } else {
        final existing = txMap[key]!;
        if ((existing['userName'] == 'Aspirant' || existing['userName'] == null || existing['userName'].toString().isEmpty) && cleanName != 'Aspirant') {
          existing['userName'] = cleanName;
        }
        if ((existing['userEmail'] == null || existing['userEmail'].toString().isEmpty) && cleanEmail.isNotEmpty) {
          existing['userEmail'] = cleanEmail;
        }
        if ((existing['userId'] == null || existing['userId'].toString().isEmpty) && cleanUserId.isNotEmpty) {
          existing['userId'] = cleanUserId;
        }
        if (existing['paymentMethod'] == 'Google Play Billing' && paymentMethod != 'Google Play Billing') {
          existing['paymentMethod'] = paymentMethod;
        }
      }
    }

    // 1. Fetch from 'payment_transactions' (Native SDK)
    if (Firebase.apps.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance.collection('payment_transactions').get();
        for (var doc in snap.docs) {
          final data = doc.data();
          DateTime dt = DateTime.now();
          if (data['timestamp'] is Timestamp) {
            dt = (data['timestamp'] as Timestamp).toDate();
          } else if (data['timestamp'] != null) {
            dt = DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now();
          }
          final uName = data['userName']?.toString() ?? '';
          mergeTx(
            orderId: data['orderId']?.toString() ?? doc.id,
            userId: data['userId']?.toString() ?? '',
            userName: uName.isNotEmpty ? uName : (data['userId']?.toString() ?? ''),
            userEmail: data['userEmail']?.toString() ?? '',
            paymentMethod: data['paymentMethod']?.toString() ?? 'Google Play Billing',
            amount: (data['amount'] is num) ? (data['amount'] as num).toDouble() : 49.0,
            status: data['status']?.toString() ?? 'SUCCESS',
            date: dt,
          );
        }
      } catch (e) {
        debugPrint('Firestore SDK fetch payment_transactions: $e');
      }

      // 1B. Fetch from 'verified_utrs' (Native SDK)
      try {
        final snap = await FirebaseFirestore.instance.collection('verified_utrs').get();
        for (var doc in snap.docs) {
          final data = doc.data();
          DateTime dt = DateTime.now();
          if (data['timestamp'] is Timestamp) {
            dt = (data['timestamp'] as Timestamp).toDate();
          } else if (data['timestamp'] != null) {
            dt = DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now();
          }
          final utr = data['utr']?.toString() ?? doc.id;
          mergeTx(
            orderId: utr,
            userId: data['userId']?.toString() ?? '',
            userName: data['userName']?.toString() ?? '',
            userEmail: data['userEmail']?.toString() ?? '',
            paymentMethod: 'UPI (UTR: $utr)',
            amount: (data['amount'] is num) ? (data['amount'] as num).toDouble() : 49.0,
            status: 'VERIFIED',
            date: dt,
          );
        }
      } catch (e) {
        debugPrint('Firestore SDK fetch verified_utrs: $e');
      }
    }

    // 2. REST API Fallback for 'payment_transactions'
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/payment_transactions'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          for (var doc in data['documents']) {
            var fields = doc['fields'] ?? {};
            String name = doc['name'] ?? '';
            String docId = name.split('/').last;
            DateTime dt = DateTime.now();
            if (fields['timestamp']?['timestampValue'] != null) {
              dt = DateTime.tryParse(fields['timestamp']['timestampValue'].toString()) ?? DateTime.now();
            }
            final uName = fields['userName']?['stringValue'] ?? '';
            mergeTx(
              orderId: fields['orderId']?['stringValue'] ?? docId,
              userId: fields['userId']?['stringValue'] ?? '',
              userName: uName.isNotEmpty ? uName : (fields['userId']?['stringValue'] ?? ''),
              userEmail: fields['userEmail']?['stringValue'] ?? '',
              paymentMethod: fields['paymentMethod']?['stringValue'] ?? 'Google Play Billing',
              amount: (fields['amount']?['doubleValue'] ?? 49.0).toDouble(),
              status: fields['status']?['stringValue'] ?? 'SUCCESS',
              date: dt,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('REST fetch payment_transactions: $e');
    }

    // 2B. REST API Fallback for 'verified_utrs'
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/verified_utrs'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          for (var doc in data['documents']) {
            var fields = doc['fields'] ?? {};
            String name = doc['name'] ?? '';
            String utr = fields['utr']?['stringValue'] ?? name.split('/').last;
            DateTime dt = DateTime.now();
            if (fields['timestamp']?['timestampValue'] != null) {
              dt = DateTime.tryParse(fields['timestamp']['timestampValue'].toString()) ?? DateTime.now();
            }
            mergeTx(
              orderId: utr,
              userId: fields['userId']?['stringValue'] ?? '',
              userName: fields['userName']?['stringValue'] ?? '',
              userEmail: fields['userEmail']?['stringValue'] ?? '',
              paymentMethod: 'UPI (UTR: $utr)',
              amount: (fields['amount']?['doubleValue'] ?? 49.0).toDouble(),
              status: 'VERIFIED',
              date: dt,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('REST fetch verified_utrs: $e');
    }

    // 3. Fallback discovery from registered users collection: any user marked isPremium (fast query)
    try {
      if (Firebase.apps.isNotEmpty) {
        final proSnap = await FirebaseFirestore.instance.collection('users').where('isPremium', isEqualTo: true).get();
        for (var doc in proSnap.docs) {
          final u = doc.data();
          final uid = (u['uid']?.toString() ?? doc.id).trim();
          final name = (u['name']?.toString() ?? '').trim();
          final email = (u['email']?.toString() ?? '').trim();
          final hasTxAlready = txMap.values.any((t) =>
              (uid.isNotEmpty && t['userId'] == uid) ||
              (email.isNotEmpty && t['userEmail']?.toString().toLowerCase() == email.toLowerCase()));
          if (!hasTxAlready) {
            mergeTx(
              orderId: 'PRO_${uid.length > 8 ? uid.substring(0, 8) : (uid.isNotEmpty ? uid : "VIP")}',
              userId: uid,
              userName: name.isNotEmpty ? name : 'PRO Aspirant',
              userEmail: email,
              paymentMethod: 'PRO Lifetime License',
              amount: 49.0,
              status: 'SUCCESS',
              date: (u['registeredAt'] is Timestamp)
                  ? (u['registeredAt'] as Timestamp).toDate()
                  : DateTime.now(),
            );
          }
        }
      }
    } catch (_) {}
    try {
      final List<Map<String, dynamic>> users = []; // bypassed redundant recursive query
      for (var u in users) {
        final isPrem = u['isPremium'] == true || u['role']?.toString().toLowerCase() == 'pro';
        if (isPrem) {
          final uid = u['uid']?.toString() ?? '';
          final name = u['name']?.toString() ?? '';
          final email = u['email']?.toString() ?? '';
          final hasTxAlready = txMap.values.any((t) =>
              (uid.isNotEmpty && t['userId'] == uid) ||
              (email.isNotEmpty && t['userEmail']?.toString().toLowerCase() == email.toLowerCase()));
          if (!hasTxAlready) {
            mergeTx(
              orderId: 'PRO_${uid.length > 8 ? uid.substring(0, 8) : (uid.isNotEmpty ? uid : "VIP")}',
              userId: uid,
              userName: name.isNotEmpty ? name : 'PRO Aspirant',
              userEmail: email,
              paymentMethod: 'PRO Lifetime License',
              amount: 49.0,
              status: 'SUCCESS',
              date: DateTime.tryParse(u['registeredAt']?.toString() ?? '') ?? DateTime.now(),
            );
          }
        }
      }
    } catch (_) {}

    final list = txMap.values.toList();
    list.sort((a, b) {
      final da = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime.now();
      final db = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime.now();
      return db.compareTo(da);
    });
    return list;
  }

  // 14. Fetch Broadcasts from Cloud Firestore
  Future<List<Map<String, dynamic>>> fetchBroadcastsFromCloud() async {
    // Strategy 1: Native Firebase Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance.collection('broadcasts').get();
        if (snap.docs.isNotEmpty) {
          final results = snap.docs.map((doc) {
            final data = doc.data();
            final sentAtStr = (data['sentAt'] is Timestamp)
                ? (data['sentAt'] as Timestamp).toDate().toIso8601String()
                : data['sentAt']?.toString() ?? DateTime.now().toIso8601String();
            return {
              'id': data['id']?.toString() ?? doc.id,
              'title': data['title']?.toString() ?? '',
              'message': data['message']?.toString() ?? '',
              'sentAt': sentAtStr,
            };
          }).toList();
          debugPrint('Firestore SDK: Fetched ${results.length} broadcasts');
          return results;
        }
      } catch (e) {
        debugPrint('Firestore SDK fetch broadcasts notice: $e');
      }
    }

    // Strategy 2: Authenticated REST API Fallback
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/broadcasts'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          List<Map<String, dynamic>> results = [];
          for (var doc in data['documents']) {
            var fields = doc['fields'] ?? {};
            results.add({
              'id': fields['id']?['stringValue'] ?? '',
              'title': fields['title']?['stringValue'] ?? '',
              'message': fields['message']?['stringValue'] ?? '',
              'sentAt': fields['sentAt']?['timestampValue'] ?? DateTime.now().toIso8601String(),
            });
          }
          return results;
        }
      }
    } catch (e) {
      debugPrint('Fetch broadcasts notice: $e');
    }
    return [];
  }

  // 15. Check if user has an existing purchase on Cloud Firestore
  Future<bool> checkIfUserHasPurchased(String uid, String email) async {
    try {
      final txList = await fetchPaymentTransactionsForAdmin();
      final cleanUid = uid.trim();
      final cleanEmail = email.trim().toLowerCase();
      final hasTx = txList.any((tx) {
        final txUserId = (tx['userId'] ?? '').toString().trim();
        final txEmail = (tx['userEmail'] ?? '').toString().trim().toLowerCase();
        final txUserName = (tx['userName'] ?? '').toString().trim().toLowerCase();
        return (cleanUid.isNotEmpty && txUserId == cleanUid) ||
            (cleanEmail.isNotEmpty && (txUserId.toLowerCase() == cleanEmail || txEmail == cleanEmail || txUserName == cleanEmail));
      });
      return hasTx;
    } catch (e) {
      debugPrint('Check user purchase notice: $e');
      return false;
    }
  }

  // 16. Dispatch Targeted Question Recall Push to a Specific Student
  Future<bool> dispatchTargetedMistakePush({
    required String studentUid,
    required String studentName,
    required String studentEmail,
    required String prompt,
    required String userAnswer,
    required String correctAnswer,
    required String topicId,
    String? customNote,
  }) async {
    final String pushId = 'push_${DateTime.now().millisecondsSinceEpoch}_${(100 + (DateTime.now().microsecond % 900))}';
    final String title = '🎯 Focus Drill for $studentName: ${topicId.toUpperCase()}!';
    final String body = 'Can you solve this now? "$prompt"\n(Your last answer: "$userAnswer" ❌, Correct: "$correctAnswer" ✅)\nTap to master it in 30 seconds!';

    // Strategy 1: Firebase SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('targeted_pushes').doc(pushId).set({
          'id': pushId,
          'studentUid': studentUid,
          'studentName': studentName,
          'studentEmail': studentEmail,
          'title': title,
          'body': body,
          'prompt': prompt,
          'userAnswer': userAnswer,
          'correctAnswer': correctAnswer,
          'topicId': topicId,
          'isDelivered': false,
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': DateTime.now().toIso8601String(),
        });
        await FirebaseFirestore.instance.collection('broadcasts').doc(pushId).set({
          'id': pushId,
          'title': title,
          'message': body,
          'target': studentUid.isNotEmpty ? studentUid : studentName,
          'targetEmail': studentEmail,
          'sentAt': FieldValue.serverTimestamp(),
        });
        debugPrint('Cloud Sync: Targeted mistake push dispatched for $studentName ($studentUid)');
        return true;
      } catch (e) {
        debugPrint('Firestore SDK targeted push note: $e');
      }
    }

    // Strategy 2: Firebase REST API Fallback
    try {
      final docData = {
        'fields': {
          'id': {'stringValue': pushId},
          'studentUid': {'stringValue': studentUid},
          'studentName': {'stringValue': studentName},
          'studentEmail': {'stringValue': studentEmail},
          'title': {'stringValue': title},
          'body': {'stringValue': body},
          'prompt': {'stringValue': prompt},
          'userAnswer': {'stringValue': userAnswer},
          'correctAnswer': {'stringValue': correctAnswer},
          'topicId': {'stringValue': topicId},
          'isDelivered': {'booleanValue': false},
          'timestamp': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
        }
      };

      await http.patch(
        Uri.parse('$_firestoreBaseUrl/targeted_pushes/$pushId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(docData),
      ).timeout(const Duration(seconds: 4));

      await http.patch(
        Uri.parse('$_firestoreBaseUrl/broadcasts/$pushId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fields': {
            'id': {'stringValue': pushId},
            'title': {'stringValue': title},
            'message': {'stringValue': body},
            'target': {'stringValue': studentUid.isNotEmpty ? studentUid : studentName},
            'targetEmail': {'stringValue': studentEmail},
            'sentAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          }
        }),
      ).timeout(const Duration(seconds: 4));

      return true;
    } catch (e) {
      debugPrint('Targeted push REST note: $e');
      return false;
    }
  }

  // 17. Fetch Pending Targeted Pushes for a Student
  Future<List<Map<String, dynamic>>> fetchTargetedPushesForStudent({
    required String studentUid,
    required String studentEmail,
  }) async {
    List<Map<String, dynamic>> results = [];
    if (studentUid.isEmpty && studentEmail.isEmpty) return results;

    // Strategy 1: Firebase SDK
    if (Firebase.apps.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('targeted_pushes')
            .where('isDelivered', isEqualTo: false)
            .get();

        for (var doc in snap.docs) {
          final data = doc.data();
          final targetUid = data['studentUid']?.toString() ?? '';
          final targetEmail = data['studentEmail']?.toString().toLowerCase() ?? '';

          if ((studentUid.isNotEmpty && targetUid == studentUid) ||
              (studentEmail.isNotEmpty && targetEmail == studentEmail.toLowerCase()) ||
              targetUid == 'all') {
            results.add({
              'id': data['id']?.toString() ?? doc.id,
              'title': data['title']?.toString() ?? '',
              'body': data['body']?.toString() ?? '',
              'prompt': data['prompt']?.toString() ?? '',
              'userAnswer': data['userAnswer']?.toString() ?? '',
              'correctAnswer': data['correctAnswer']?.toString() ?? '',
              'topicId': data['topicId']?.toString() ?? '',
            });
          }
        }
        if (results.isNotEmpty) return results;
      } catch (e) {
        debugPrint('Firestore fetch targeted pushes note: $e');
      }
    }

    // Strategy 2: Firebase REST API Fallback
    try {
      final response = await http.get(
        Uri.parse('$_firestoreBaseUrl/targeted_pushes'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['documents'] != null) {
          for (var doc in data['documents']) {
            var fields = doc['fields'] ?? {};
            bool isDelivered = fields['isDelivered']?['booleanValue'] ?? false;
            if (isDelivered) continue;

            String targetUid = fields['studentUid']?['stringValue'] ?? '';
            String targetEmail = (fields['studentEmail']?['stringValue'] ?? '').toLowerCase();

            if ((studentUid.isNotEmpty && targetUid == studentUid) ||
                (studentEmail.isNotEmpty && targetEmail == studentEmail.toLowerCase()) ||
                targetUid == 'all') {
              results.add({
                'id': fields['id']?['stringValue'] ?? '',
                'title': fields['title']?['stringValue'] ?? '',
                'body': fields['body']?['stringValue'] ?? '',
                'prompt': fields['prompt']?['stringValue'] ?? '',
                'userAnswer': fields['userAnswer']?['stringValue'] ?? '',
                'correctAnswer': fields['correctAnswer']?['stringValue'] ?? '',
                'topicId': fields['topicId']?['stringValue'] ?? '',
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Targeted pushes REST note: $e');
    }
    return results;
  }

  // 18. Mark Targeted Push Delivered
  Future<void> markTargetedPushDelivered(String pushId) async {
    if (pushId.isEmpty) return;
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('targeted_pushes')
            .doc(pushId)
            .update({'isDelivered': true});
        return;
      } catch (_) {}
    }
    try {
      await http.patch(
        Uri.parse('$_firestoreBaseUrl/targeted_pushes/$pushId?updateMask.fieldPaths=isDelivered'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fields': {
            'isDelivered': {'booleanValue': true}
          }
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  // Permanently delete all Firestore data for a user across all collections
  // Required by Google Play Policy: "Users must be able to request complete account and data deletion"
  Future<bool> deleteAllUserDataFromCloud(String uid) async {
    if (uid.isEmpty) return false;

    bool success = true;

    // Collections to purge user data from
    final collectionsToDelete = [
      'users',
      'student_mistakes',
      'user_diagnostics',
      'leaderboard',
    ];

    // Strategy 1: Native Firestore SDK
    if (Firebase.apps.isNotEmpty) {
      for (final collection in collectionsToDelete) {
        try {
          await FirebaseFirestore.instance.collection(collection).doc(uid).delete();
          debugPrint('Firestore: Deleted $collection/$uid');
        } catch (e) {
          debugPrint('Firestore delete $collection/$uid note: $e');
        }
      }

      // Also delete any targeted pushes sent to this user
      try {
        final pushSnap = await FirebaseFirestore.instance
            .collection('targeted_pushes')
            .where('studentUid', isEqualTo: uid)
            .get();
        for (final doc in pushSnap.docs) {
          await doc.reference.delete();
        }
        debugPrint('Firestore: Deleted ${pushSnap.docs.length} targeted pushes for $uid');
      } catch (e) {
        debugPrint('Firestore delete targeted_pushes note: $e');
      }

      // Delete exam mock results
      try {
        final mockSnap = await FirebaseFirestore.instance
            .collection('exam_mock_results')
            .where('userUid', isEqualTo: uid)
            .get();
        for (final doc in mockSnap.docs) {
          await doc.reference.delete();
        }
        debugPrint('Firestore: Deleted ${mockSnap.docs.length} exam mock results for $uid');
      } catch (e) {
        debugPrint('Firestore delete exam_mock_results note: $e');
      }

      return success;
    }

    // Strategy 2: REST API Fallback
    try {
      final headers = await _getAuthHeaders();
      for (final collection in collectionsToDelete) {
        try {
          final res = await http.delete(
            Uri.parse('$_firestoreBaseUrl/$collection/$uid'),
            headers: headers,
          ).timeout(const Duration(seconds: 6));
          if (res.statusCode != 200 && res.statusCode != 204 && res.statusCode != 404) {
            success = false;
          }
          debugPrint('REST: Deleted $collection/$uid → ${res.statusCode}');
        } catch (e) {
          debugPrint('REST delete $collection/$uid note: $e');
        }
      }
    } catch (e) {
      debugPrint('deleteAllUserDataFromCloud REST error: $e');
      success = false;
    }

    return success;
  }
}

