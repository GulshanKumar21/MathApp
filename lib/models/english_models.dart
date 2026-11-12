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


// =========================================================================
// PREPVANTA ENGLISH VOCABULARY DICTIONARY MODELS
// =========================================================================

class BlackbookOwsItem {
  final int id;
  final String phrase;
  final String word;
  final String partOfSpeech;
  final String hindiMeaning;
  final int repetitionCount;
  final String category;
  final bool isSpellingTrap;
  final bool isSynAnt;

  const BlackbookOwsItem({
    required this.id,
    required this.phrase,
    required this.word,
    this.partOfSpeech = 'N.',
    required this.hindiMeaning,
    required this.repetitionCount,
    this.category = 'General',
    this.isSpellingTrap = false,
    this.isSynAnt = false,
  });

  factory BlackbookOwsItem.fromJson(Map<String, dynamic> j, int fallbackId) {
    return BlackbookOwsItem(
      id: (j['id'] as num?)?.toInt() ?? fallbackId,
      phrase: (j['phrase'] ?? '').toString(),
      word: (j['word'] ?? '').toString(),
      partOfSpeech: (j['pos'] ?? 'N.').toString(),
      hindiMeaning: (j['hindi'] ?? '').toString(),
      repetitionCount: (j['rep'] as num?)?.toInt() ?? 1,
      category: (j['cat'] ?? 'SSC OWS').toString(),
      isSpellingTrap: j['spell'] == true,
      isSynAnt: j['synant'] == true,
    );
  }
}

class BlackbookIdiomItem {
  final int id;
  final String idiom;
  final String englishMeaning;
  final String hindiMeaning;
  final int repetitionCount;
  final String category;
  final String example;

  const BlackbookIdiomItem({
    required this.id,
    required this.idiom,
    required this.englishMeaning,
    required this.hindiMeaning,
    required this.repetitionCount,
    this.category = 'General',
    this.example = '',
  });

  factory BlackbookIdiomItem.fromJson(Map<String, dynamic> j, int fallbackId) {
    return BlackbookIdiomItem(
      id: (j['id'] as num?)?.toInt() ?? fallbackId,
      idiom: (j['idiom'] ?? '').toString(),
      englishMeaning: (j['eng'] ?? '').toString(),
      hindiMeaning: (j['hindi'] ?? '').toString(),
      repetitionCount: (j['rep'] as num?)?.toInt() ?? 1,
      category: (j['cat'] ?? 'Idioms').toString(),
      example: (j['ex'] ?? '').toString(),
    );
  }
}

class BlackbookSynAntItem {
  final int id;
  final String word;
  final String partOfSpeech;
  final String definition;
  final String hindiMeaning;
  final int repetitionCount;
  final List<String> synonyms;
  final List<String> antonyms;

  const BlackbookSynAntItem({
    required this.id,
    required this.word,
    this.partOfSpeech = 'Adj.',
    this.definition = '',
    required this.hindiMeaning,
    required this.repetitionCount,
    required this.synonyms,
    required this.antonyms,
  });

  factory BlackbookSynAntItem.fromJson(Map<String, dynamic> j, int fallbackId) {
    return BlackbookSynAntItem(
      id: (j['id'] as num?)?.toInt() ?? fallbackId,
      word: (j['word'] ?? '').toString(),
      partOfSpeech: (j['pos'] ?? 'Adj.').toString(),
      definition: (j['def'] ?? '').toString(),
      hindiMeaning: (j['hindi'] ?? '').toString(),
      repetitionCount: (j['rep'] as num?)?.toInt() ?? 1,
      synonyms: (j['syn'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      antonyms: (j['ant'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class BlackbookHomonymPair {
  final int id;
  final String word1;
  final String pos1;
  final String meaning1;
  final String hindi1;
  final String word2;
  final String pos2;
  final String meaning2;
  final String hindi2;
  final String? word3;
  final String? pos3;
  final String? meaning3;
  final String? hindi3;
  final int repetitionCount;

  const BlackbookHomonymPair({
    required this.id,
    required this.word1,
    required this.pos1,
    required this.meaning1,
    required this.hindi1,
    required this.word2,
    required this.pos2,
    required this.meaning2,
    required this.hindi2,
    this.word3,
    this.pos3,
    this.meaning3,
    this.hindi3,
    this.repetitionCount = 2,
  });

  factory BlackbookHomonymPair.fromJson(Map<String, dynamic> j, int fallbackId) {
    return BlackbookHomonymPair(
      id: (j['id'] as num?)?.toInt() ?? fallbackId,
      word1: (j['w1'] ?? '').toString(),
      pos1: (j['p1'] ?? 'N.').toString(),
      meaning1: (j['m1'] ?? '').toString(),
      hindi1: (j['h1'] ?? '').toString(),
      word2: (j['w2'] ?? '').toString(),
      pos2: (j['p2'] ?? 'N.').toString(),
      meaning2: (j['m2'] ?? '').toString(),
      hindi2: (j['h2'] ?? '').toString(),
      word3: j['w3']?.toString(),
      pos3: j['p3']?.toString(),
      meaning3: j['m3']?.toString(),
      hindi3: j['h3']?.toString(),
      repetitionCount: (j['rep'] as num?)?.toInt() ?? 2,
    );
  }
}

class BlackbookSpellingItem {
  final int id;
  final String correctWord;
  final String hindiMeaning;
  final int repetitionCount;
  final List<String> wrongOptions;
  final String trickyPart;

  const BlackbookSpellingItem({
    required this.id,
    required this.correctWord,
    required this.hindiMeaning,
    required this.repetitionCount,
    required this.wrongOptions,
    this.trickyPart = '',
  });

  factory BlackbookSpellingItem.fromJson(Map<String, dynamic> j, int fallbackId) {
    return BlackbookSpellingItem(
      id: (j['id'] as num?)?.toInt() ?? fallbackId,
      correctWord: (j['word'] ?? '').toString(),
      hindiMeaning: (j['hindi'] ?? '').toString(),
      repetitionCount: (j['rep'] as num?)?.toInt() ?? 1,
      wrongOptions: (j['wrong'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      trickyPart: (j['tricky'] ?? '').toString(),
    );
  }
}

class BlackbookRootWordItem {
  final String root;
  final String meaning;
  final String origin;
  final List<Map<String, String>> derivatives;

  const BlackbookRootWordItem({
    required this.root,
    required this.meaning,
    this.origin = 'Greek/Latin',
    required this.derivatives,
  });

  factory BlackbookRootWordItem.fromJson(Map<String, dynamic> j) {
    final rawDer = (j['der'] as List?) ?? const [];
    return BlackbookRootWordItem(
      root: (j['root'] ?? '').toString(),
      meaning: (j['meaning'] ?? '').toString(),
      origin: (j['origin'] ?? 'Greek/Latin').toString(),
      derivatives: rawDer
          .map((e) => Map<String, String>.from(
                (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
              ))
          .toList(),
    );
  }
}

class VocabBoosterWordItem {
  final int id;
  final String word;
  final String partOfSpeech;
  final String englishMeaning;
  final String hindiMeaning;
  final List<String> synonyms;
  final String section; // 'Phrasal Verbs', 'Fixed Prepositions', 'Editorial Vocab', 'Foreign Words'
  final String origin;
  final int repetitionCount;

  const VocabBoosterWordItem({
    required this.id,
    required this.word,
    this.partOfSpeech = '',
    required this.englishMeaning,
    this.hindiMeaning = '',
    this.synonyms = const [],
    required this.section,
    this.origin = '',
    this.repetitionCount = 1,
  });

  factory VocabBoosterWordItem.fromJson(Map<String, dynamic> j, int fallbackId) {
    return VocabBoosterWordItem(
      id: (j['id'] as num?)?.toInt() ?? fallbackId,
      word: (j['word'] ?? '').toString(),
      partOfSpeech: (j['pos'] ?? '').toString(),
      englishMeaning: (j['eng'] ?? '').toString(),
      hindiMeaning: (j['hindi'] ?? '').toString(),
      synonyms: (j['syn'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      section: (j['sec'] ?? 'Editorial').toString(),
      origin: (j['origin'] ?? '').toString(),
      repetitionCount: (j['rep'] as num?)?.toInt() ?? 1,
    );
  }
}
