class EnglishWordTopic {
  final int id;
  final String word;
  final String partOfSpeech;
  final String rootWord;
  final List<String> synonyms;
  final List<String> antonyms;
  final Map<String, List<String>> idioms;
  final List<EnglishExerciseQuestion> exercises;

  const EnglishWordTopic({
    required this.id,
    required this.word,
    this.partOfSpeech = 'adjective',
    this.rootWord = '',
    required this.synonyms,
    required this.antonyms,
    this.idioms = const {},
    this.exercises = const [],
  });

  String get displayTitle => '$word ($partOfSpeech)';

  Map<String, dynamic> toMap() => {
    'id': id,
    'word': word,
    'partOfSpeech': partOfSpeech,
    'rootWord': rootWord,
    'synonyms': synonyms,
    'antonyms': antonyms,
  };
}

class EnglishExerciseQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex; // 0, 1, 2, 3
  final String type; // 'synonym', 'antonym', 'sentence', 'preposition'
  final String explanation;

  const EnglishExerciseQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.type = 'synonym',
    this.explanation = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'questionText': questionText,
    'options': options,
    'correctIndex': correctIndex,
    'type': type,
    'explanation': explanation,
  };

  factory EnglishExerciseQuestion.fromMap(Map<String, dynamic> map) => EnglishExerciseQuestion(
    id: map['id']?.toString() ?? '',
    questionText: map['questionText']?.toString() ?? '',
    options: (map['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
    correctIndex: int.tryParse(map['correctIndex']?.toString() ?? '0') ?? 0,
    type: map['type']?.toString() ?? 'synonym',
    explanation: map['explanation']?.toString() ?? '',
  );
}

class FixedPrepositionQuestion {
  final int number;
  final String sentence;
  final List<String> options;
  final int correctIndex;
  final String rule;

  const FixedPrepositionQuestion({
    required this.number,
    required this.sentence,
    required this.options,
    required this.correctIndex,
    this.rule = '',
  });

  String get correctOptionText => options.isNotEmpty && correctIndex < options.length
      ? options[correctIndex]
      : '';
}

class IdiomThematicGroup {
  final String theme;
  final String category; // 'Focus & Alertness', 'Rash & Reckless', etc.
  final List<IdiomItem> idioms;

  const IdiomThematicGroup({
    required this.theme,
    this.category = 'General',
    required this.idioms,
  });

  String get displayTheme => theme;
}

class IdiomItem {
  final String idiom;
  final String meaning;
  final String example;

  const IdiomItem({
    required this.idiom,
    required this.meaning,
    this.example = '',
  });
}

class EnglishMistake {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int selectedIndex;
  final String explanation;
  final DateTime timestamp;

  EnglishMistake({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.explanation,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'questionText': questionText,
    'options': options,
    'correctIndex': correctIndex,
    'selectedIndex': selectedIndex,
    'explanation': explanation,
    'timestamp': timestamp.toIso8601String(),
  };

  factory EnglishMistake.fromMap(Map<String, dynamic> map) => EnglishMistake(
    id: map['id']?.toString() ?? '',
    questionText: map['questionText']?.toString() ?? '',
    options: (map['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
    correctIndex: int.tryParse(map['correctIndex']?.toString() ?? '0') ?? 0,
    selectedIndex: int.tryParse(map['selectedIndex']?.toString() ?? '0') ?? 0,
    explanation: map['explanation']?.toString() ?? '',
    timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
  );
}
