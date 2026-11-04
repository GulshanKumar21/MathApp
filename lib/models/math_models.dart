import 'dart:convert';

enum TopicType {
  tables,
  squares,
  cubes,
  fractions,
  triples,
  hardMultiplier, // 🔥 Hard-On Pro 2-Digit × 2-Digit Multipliers (17 × 45+)
  addition,
  subtraction,
  division,
  productChauraha, // ✖️ Important Products & Multiplier Crossroads (108, 144, 180, Base 25)
  custom,
}

enum QuizTimerDifficulty {
  easy,   // Unlimited time (No per-question timer)
  medium, // 10s per question (Auto-skip on timeout)
  hard,   // 5s per question (Auto-skip on timeout)
}

class QuestionModel {
  final String id;
  final String topicId;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
  final int difficulty; // 1: Easy, 2: Medium, 3: Hard
  final String? examBadge;
  final String? diagramType;

  QuestionModel({
    required this.id,
    required this.topicId,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    this.explanation = '',
    this.difficulty = 1,
    this.examBadge,
    this.diagramType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'prompt': prompt,
      'correctAnswer': correctAnswer,
      'options': options,
      'explanation': explanation,
      'difficulty': difficulty,
      'examBadge': examBadge,
      'diagramType': diagramType,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      topicId: map['topicId'] ?? '',
      prompt: map['prompt'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      explanation: map['explanation'] ?? '',
      difficulty: map['difficulty'] ?? 1,
      examBadge: map['examBadge'],
      diagramType: map['diagramType'],
    );
  }

  String toJson() => json.encode(toMap());
  factory QuestionModel.fromJson(String source) => QuestionModel.fromMap(json.decode(source));
}

class TopicModel {
  final String id;
  final String title;
  final String subtitle;
  final TopicType type;
  final String iconName;
  final bool isPremium;
  final int totalItems;

  TopicModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.iconName,
    this.isPremium = false,
    this.totalItems = 50,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'iconName': iconName,
      'isPremium': isPremium,
      'totalItems': totalItems,
    };
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      type: TopicType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TopicType.tables,
      ),
      iconName: map['iconName'] ?? 'calculate',
      isPremium: map['isPremium'] ?? false,
      totalItems: map['totalItems'] ?? 50,
    );
  }
}

class MistakeModel {
  final String id;
  final String prompt;
  final String userAnswer;
  final String correctAnswer;
  final String topicId;
  final DateTime timestamp;
  final int repetitionStage; // 0=Immediate/Fresh, 1=1-Hr Recall, 2=Day 1, 3=Day 3, 4=Mastered
  final DateTime? snoozedUntil;
  final bool isResolved;
  final DateTime? resolvedAt;

  MistakeModel({
    required this.id,
    required this.prompt,
    required this.userAnswer,
    required this.correctAnswer,
    required this.topicId,
    required this.timestamp,
    this.repetitionStage = 0,
    this.snoozedUntil,
    this.isResolved = false,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt': prompt,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'topicId': topicId,
      'timestamp': timestamp.toIso8601String(),
      'repetitionStage': repetitionStage,
      if (snoozedUntil != null) 'snoozedUntil': snoozedUntil!.toIso8601String(),
      'isResolved': isResolved,
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    };
  }

  factory MistakeModel.fromMap(Map<String, dynamic> map) {
    return MistakeModel(
      id: map['id'] ?? '',
      prompt: map['prompt'] ?? '',
      userAnswer: map['userAnswer'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      topicId: map['topicId'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      repetitionStage: (map['repetitionStage'] is num) ? (map['repetitionStage'] as num).toInt() : 0,
      snoozedUntil: map['snoozedUntil'] != null ? DateTime.tryParse(map['snoozedUntil'].toString()) : null,
      isResolved: map['isResolved'] == true,
      resolvedAt: map['resolvedAt'] != null ? DateTime.tryParse(map['resolvedAt'].toString()) : null,
    );
  }

  MistakeModel copyWith({
    String? id,
    String? prompt,
    String? userAnswer,
    String? correctAnswer,
    String? topicId,
    DateTime? timestamp,
    int? repetitionStage,
    DateTime? snoozedUntil,
    bool? isResolved,
    DateTime? resolvedAt,
  }) {
    return MistakeModel(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      topicId: topicId ?? this.topicId,
      timestamp: timestamp ?? this.timestamp,
      repetitionStage: repetitionStage ?? this.repetitionStage,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

class PracticeResult {
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final double avgTimeSeconds;
  final int score;
  final String topicId;
  final DateTime date;

  PracticeResult({
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.avgTimeSeconds,
    required this.score,
    required this.topicId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'accuracy': accuracy,
      'avgTimeSeconds': avgTimeSeconds,
      'score': score,
      'topicId': topicId,
      'date': date.toIso8601String(),
    };
  }

  factory PracticeResult.fromMap(Map<String, dynamic> map) {
    return PracticeResult(
      totalQuestions: map['totalQuestions'] ?? 0,
      correctCount: map['correctCount'] ?? 0,
      wrongCount: map['wrongCount'] ?? 0,
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      avgTimeSeconds: (map['avgTimeSeconds'] ?? 0).toDouble(),
      score: map['score'] ?? 0,
      topicId: map['topicId'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class StudentMistakeAnalyticsModel {
  final String studentUid;
  final String studentName;
  final String studentEmail;
  final int totalMistakes;
  final double accuracy;
  final int totalAttempted;
  final List<MistakeModel> mistakes;
  final DateTime lastActive;

  StudentMistakeAnalyticsModel({
    required this.studentUid,
    required this.studentName,
    required this.studentEmail,
    required this.totalMistakes,
    required this.accuracy,
    required this.totalAttempted,
    required this.mistakes,
    required this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentUid': studentUid,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'totalMistakes': totalMistakes,
      'accuracy': accuracy,
      'totalAttempted': totalAttempted,
      'mistakes': mistakes.map((m) => m.toMap()).toList(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory StudentMistakeAnalyticsModel.fromMap(Map<String, dynamic> map) {
    var rawList = map['mistakes'] as List? ?? [];
    List<MistakeModel> list = rawList.map((item) {
      if (item is Map<String, dynamic>) return MistakeModel.fromMap(item);
      return MistakeModel.fromMap(Map<String, dynamic>.from(item));
    }).toList();

    return StudentMistakeAnalyticsModel(
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? 'Aspirant',
      studentEmail: map['studentEmail'] ?? '',
      totalMistakes: map['totalMistakes'] ?? list.length,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      totalAttempted: map['totalAttempted'] ?? 0,
      mistakes: list,
      lastActive: DateTime.tryParse(map['lastActive'] ?? '') ?? DateTime.now(),
    );
  }
}

class StudyPlanModel {
  final String id;
  final String topicId; // e.g. 'table_17', 'squares', 'cubes', 'fractions'
  final String topicTitle; // e.g. 'Table of 17'
  final DateTime scheduledDate; // Target reminder time tomorrow
  final String sampleQuestion; // e.g. '17 × 7'
  final bool isCompleted;

  StudyPlanModel({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.scheduledDate,
    required this.sampleQuestion,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'topicId': topicId,
        'topicTitle': topicTitle,
        'scheduledDate': scheduledDate.toIso8601String(),
        'sampleQuestion': sampleQuestion,
        'isCompleted': isCompleted,
      };

  factory StudyPlanModel.fromMap(Map<String, dynamic> map) => StudyPlanModel(
        id: map['id'] ?? '',
        topicId: map['topicId'] ?? 'table_17',
        topicTitle: map['topicTitle'] ?? 'Table of 17',
        scheduledDate: DateTime.tryParse(map['scheduledDate'] ?? '') ?? DateTime.now().add(const Duration(days: 1)),
        sampleQuestion: map['sampleQuestion'] ?? '17 × 7',
        isCompleted: map['isCompleted'] ?? false,
      );

  StudyPlanModel copyWith({
    String? id,
    String? topicId,
    String? topicTitle,
    DateTime? scheduledDate,
    String? sampleQuestion,
    bool? isCompleted,
  }) =>
      StudyPlanModel(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        topicTitle: topicTitle ?? this.topicTitle,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        sampleQuestion: sampleQuestion ?? this.sampleQuestion,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

class LeaderboardEntryModel {
  final String uid;
  final String name;
  final int score;
  final double accuracy;
  final int streak;
  final String targetExam;
  final int questionsSolved;
  final DateTime updatedAt;
  final bool isCurrentUser;

  LeaderboardEntryModel({
    required this.uid,
    required this.name,
    required this.score,
    required this.accuracy,
    this.streak = 0,
    this.targetExam = 'SSC CGL',
    this.questionsSolved = 0,
    required this.updatedAt,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'score': score,
        'accuracy': accuracy,
        'streak': streak,
        'targetExam': targetExam,
        'questionsSolved': questionsSolved,
        'updatedAt': updatedAt.toIso8601String(),
        'isCurrentUser': isCurrentUser,
      };

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map, {String currentUid = ''}) {
    String entryUid = map['uid'] ?? map['studentUid'] ?? '';
    bool isMe = map['isCurrentUser'] == true || (currentUid.isNotEmpty && entryUid == currentUid);
    return LeaderboardEntryModel(
      uid: entryUid,
      name: map['name'] ?? map['userName'] ?? map['studentName'] ?? 'Aspirant',
      score: map['score'] is int
          ? map['score']
          : int.tryParse(map['score']?.toString() ?? '0') ?? 0,
      accuracy: (map['accuracy'] is num)
          ? (map['accuracy'] as num).toDouble()
          : double.tryParse(map['accuracy']?.toString() ?? '0.0') ?? 0.0,
      streak: map['streak'] is int
          ? map['streak']
          : int.tryParse(map['streak']?.toString() ?? '0') ?? 0,
      targetExam: map['targetExam'] ?? map['exam'] ?? 'SSC CGL',
      questionsSolved: map['questionsSolved'] is int
          ? map['questionsSolved']
          : int.tryParse(map['questionsSolved']?.toString() ?? '0') ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      isCurrentUser: isMe,
    );
  }

  LeaderboardEntryModel copyWith({
    String? uid,
    String? name,
    int? score,
    double? accuracy,
    int? streak,
    String? targetExam,
    int? questionsSolved,
    DateTime? updatedAt,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntryModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      score: score ?? this.score,
      accuracy: accuracy ?? this.accuracy,
      streak: streak ?? this.streak,
      targetExam: targetExam ?? this.targetExam,
      questionsSolved: questionsSolved ?? this.questionsSolved,
      updatedAt: updatedAt ?? this.updatedAt,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class RevisionItemModel {
  final String id;
  final String title;
  final String question; // Front / prompt / formula
  final String answer; // Back / result / value
  final String category; // e.g. "Formulas", "Percentages", "Triplets", "Shortcuts", "Custom"
  final String notes; // Extra trick or note
  final bool isMastered;
  final DateTime createdAt;

  RevisionItemModel({
    required this.id,
    required this.title,
    required this.question,
    required this.answer,
    this.category = 'Custom',
    this.notes = '',
    this.isMastered = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'question': question,
    'answer': answer,
    'category': category,
    'notes': notes,
    'isMastered': isMastered,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RevisionItemModel.fromMap(Map<String, dynamic> map) {
    return RevisionItemModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: map['category'] ?? 'Custom',
      notes: map['notes'] ?? '',
      isMastered: map['isMastered'] == true,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory RevisionItemModel.fromJson(String source) => RevisionItemModel.fromMap(json.decode(source));

  RevisionItemModel copyWith({
    String? id,
    String? title,
    String? question,
    String? answer,
    String? category,
    String? notes,
    bool? isMastered,
    DateTime? createdAt,
  }) {
    return RevisionItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isMastered: isMastered ?? this.isMastered,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


