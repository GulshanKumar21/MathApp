import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data/blackbook_vocabulary_bank.dart';
import '../models/english_models.dart';

/// Singleton service that loads, merges, deduplicates, and serves PrepVanta's
/// full A-to-Z English Vocabulary Dictionary from compressed bundled assets.

/// Topic-wise MCQ bundle generated from all extracted vocabulary datasets.
class VocabTopicQuizBundle {
  final String key;
  final String title;
  final String subtitle;
  final String categoryTag;
  final List<EnglishExerciseQuestion> questions;

  const VocabTopicQuizBundle({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.categoryTag,
    required this.questions,
  });
}

class VocabDictionaryService {
  static final VocabDictionaryService _instance = VocabDictionaryService._internal();
  factory VocabDictionaryService() => _instance;
  VocabDictionaryService._internal();

  bool _isLoaded = false;
  Future<void>? _loadingFuture;

  List<BlackbookOwsItem> _ows = [];
  List<BlackbookIdiomItem> _idioms = [];
  List<BlackbookSynAntItem> _synAnt = [];
  List<BlackbookHomonymPair> _homonyms = [];
  List<BlackbookSpellingItem> _spellings = [];
  List<BlackbookRootWordItem> _roots = [];
  List<VocabBoosterWordItem> _boosters = [];
  List<EnglishExerciseQuestion> _quiz = [];

  bool get isLoaded => _isLoaded;

  List<BlackbookOwsItem> get ows => _isLoaded ? _ows : _fallbackOws;
  List<BlackbookIdiomItem> get idioms => _isLoaded ? _idioms : _fallbackIdioms;
  List<BlackbookSynAntItem> get synAnt => _isLoaded ? _synAnt : _fallbackSynAnt;
  List<BlackbookHomonymPair> get homonyms => _isLoaded ? _homonyms : _fallbackHomonyms;
  List<BlackbookSpellingItem> get spellings => _isLoaded ? _spellings : _fallbackSpellings;
  List<BlackbookRootWordItem> get roots => _isLoaded ? _roots : BlackbookVocabularyBank.rootWords;
  List<VocabBoosterWordItem> get boosters => _boosters;
  List<EnglishExerciseQuestion> get quiz => _isLoaded ? _quiz : BlackbookVocabularyBank.blackbookPracticeQuestions;

  List<BlackbookOwsItem> get _fallbackOws {
    final list = List<BlackbookOwsItem>.from(BlackbookVocabularyBank.topOws);
    list.sort((a, b) => compareDictionary(a.word, b.word));
    return list;
  }

  List<BlackbookIdiomItem> get _fallbackIdioms {
    final list = List<BlackbookIdiomItem>.from(BlackbookVocabularyBank.topIdioms);
    list.sort((a, b) => compareDictionary(a.idiom, b.idiom));
    return list;
  }

  List<BlackbookSynAntItem> get _fallbackSynAnt {
    final list = List<BlackbookSynAntItem>.from(BlackbookVocabularyBank.topSynAnt);
    list.sort((a, b) => compareDictionary(a.word, b.word));
    return list;
  }

  List<BlackbookHomonymPair> get _fallbackHomonyms {
    final list = List<BlackbookHomonymPair>.from(BlackbookVocabularyBank.topHomonyms);
    list.sort((a, b) => compareDictionary(a.word1, b.word1));
    return list;
  }

  List<BlackbookSpellingItem> get _fallbackSpellings {
    final list = List<BlackbookSpellingItem>.from(BlackbookVocabularyBank.topSpellings);
    list.sort((a, b) => compareDictionary(a.correctWord, b.correctWord));
    return list;
  }

  /// Strict lexicographical comparator (A -> AA -> AB -> ... -> Z),
  /// stripping non-alphabetic leading characters for true dictionary ordering.
  static int compareDictionary(String a, String b) {
    final na = normalizeForSort(a);
    final nb = normalizeForSort(b);
    final cmp = na.compareTo(nb);
    if (cmp != 0) return cmp;
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  static String normalizeForSort(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'^[^a-z]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String startingLetter(String s) {
    final norm = normalizeForSort(s);
    if (norm.isEmpty) return '#';
    final ch = norm[0].toUpperCase();
    if (ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90) return ch;
    return '#';
  }

  Future<void> ensureLoaded() {
    if (_isLoaded) return Future.value();
    _loadingFuture ??= _loadAllAssets();
    return _loadingFuture!;
  }

  Future<List<dynamic>> _loadGzipJson(String assetPath) async {
    try {
      final bd = await rootBundle.load(assetPath);
      final compressed = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
      final decompressed = gzip.decode(compressed);
      final jsonStr = utf8.decode(decompressed);
      final decoded = json.decode(jsonStr);
      if (decoded is List) return decoded;
    } catch (e) {
      debugPrint('VocabDictionaryService asset load note ($assetPath): $e');
    }
    return const [];
  }

  Future<void> _loadAllAssets() async {
    try {
      final results = await Future.wait([
        _loadGzipJson('assets/data/vocab_ows.json.gz'),
        _loadGzipJson('assets/data/vocab_idioms.json.gz'),
        _loadGzipJson('assets/data/vocab_syn_ant.json.gz'),
        _loadGzipJson('assets/data/vocab_homonyms.json.gz'),
        _loadGzipJson('assets/data/vocab_spellings.json.gz'),
        _loadGzipJson('assets/data/vocab_roots.json.gz'),
        _loadGzipJson('assets/data/vocab_boosters.json.gz'),
        _loadGzipJson('assets/data/vocab_quiz.json.gz'),
      ]);

      // 1. OWS: merge built-in curated + extracted JSON, deduplicated by normalized word
      final owsMap = <String, BlackbookOwsItem>{};
      for (final item in BlackbookVocabularyBank.topOws) {
        owsMap[normalizeForSort(item.word)] = item;
      }
      int owsIdx = 1000;
      for (final raw in results[0]) {
        if (raw is! Map) continue;
        final item = BlackbookOwsItem.fromJson(Map<String, dynamic>.from(raw), owsIdx++);
        final key = normalizeForSort(item.word);
        if (key.length < 2) continue;
        owsMap.putIfAbsent(key, () => item);
      }
      _ows = owsMap.values.toList()..sort((a, b) => compareDictionary(a.word, b.word));

      // 2. Idioms & Proverbs: merge built-in + extracted
      final idiomMap = <String, BlackbookIdiomItem>{};
      for (final item in BlackbookVocabularyBank.topIdioms) {
        idiomMap[normalizeForSort(item.idiom)] = item;
      }
      int idmIdx = 1000;
      for (final raw in results[1]) {
        if (raw is! Map) continue;
        final item = BlackbookIdiomItem.fromJson(Map<String, dynamic>.from(raw), idmIdx++);
        final key = normalizeForSort(item.idiom);
        if (key.length < 3) continue;
        idiomMap.putIfAbsent(key, () => item);
      }
      _idioms = idiomMap.values.toList()..sort((a, b) => compareDictionary(a.idiom, b.idiom));

      // 3. Syn & Ant: merge built-in + extracted
      final synMap = <String, BlackbookSynAntItem>{};
      for (final item in BlackbookVocabularyBank.topSynAnt) {
        synMap[normalizeForSort(item.word)] = item;
      }
      int synIdx = 1000;
      for (final raw in results[2]) {
        if (raw is! Map) continue;
        final item = BlackbookSynAntItem.fromJson(Map<String, dynamic>.from(raw), synIdx++);
        final key = normalizeForSort(item.word);
        if (key.length < 2) continue;
        synMap.putIfAbsent(key, () => item);
      }
      _synAnt = synMap.values.toList()..sort((a, b) => compareDictionary(a.word, b.word));

      // 4. Homonyms
      final homoMap = <String, BlackbookHomonymPair>{};
      for (final item in BlackbookVocabularyBank.topHomonyms) {
        homoMap[normalizeForSort(item.word1)] = item;
      }
      int homIdx = 1000;
      for (final raw in results[3]) {
        if (raw is! Map) continue;
        final item = BlackbookHomonymPair.fromJson(Map<String, dynamic>.from(raw), homIdx++);
        final key = normalizeForSort(item.word1);
        if (key.length < 2) continue;
        homoMap.putIfAbsent(key, () => item);
      }
      _homonyms = homoMap.values.toList()..sort((a, b) => compareDictionary(a.word1, b.word1));

      // 5. Spellings
      final spellMap = <String, BlackbookSpellingItem>{};
      for (final item in BlackbookVocabularyBank.topSpellings) {
        spellMap[normalizeForSort(item.correctWord)] = item;
      }
      int splIdx = 1000;
      for (final raw in results[4]) {
        if (raw is! Map) continue;
        final item = BlackbookSpellingItem.fromJson(Map<String, dynamic>.from(raw), splIdx++);
        final key = normalizeForSort(item.correctWord);
        if (key.length < 3) continue;
        spellMap.putIfAbsent(key, () => item);
      }
      _spellings = spellMap.values.toList()..sort((a, b) => compareDictionary(a.correctWord, b.correctWord));

      // 6. Root Words
      final rootMap = <String, BlackbookRootWordItem>{};
      for (final item in BlackbookVocabularyBank.rootWords) {
        rootMap[normalizeForSort(item.root)] = item;
      }
      for (final raw in results[5]) {
        if (raw is! Map) continue;
        final item = BlackbookRootWordItem.fromJson(Map<String, dynamic>.from(raw));
        final key = normalizeForSort(item.root);
        if (key.isEmpty) continue;
        rootMap.putIfAbsent(key, () => item);
      }
      _roots = rootMap.values.toList()..sort((a, b) => compareDictionary(a.root, b.root));

      // 7. Vocab Boosters (Phrasal Verbs, Fixed Prepositions, Editorial Vocab, Foreign Words)
      final bstMap = <String, VocabBoosterWordItem>{};
      int bstIdx = 1;
      for (final raw in results[6]) {
        if (raw is! Map) continue;
        final item = VocabBoosterWordItem.fromJson(Map<String, dynamic>.from(raw), bstIdx++);
        final key = '${item.section}:${normalizeForSort(item.word)}';
        if (normalizeForSort(item.word).length < 2) continue;
        bstMap.putIfAbsent(key, () => item);
      }
      _boosters = bstMap.values.toList()..sort((a, b) => compareDictionary(a.word, b.word));

      // 8. Practice Quiz
      final quizList = List<EnglishExerciseQuestion>.from(BlackbookVocabularyBank.blackbookPracticeQuestions);
      final seenQ = quizList.map((q) => q.questionText.trim().toLowerCase()).toSet();
      for (final raw in results[7]) {
        if (raw is! Map) continue;
        final q = EnglishExerciseQuestion.fromMap(Map<String, dynamic>.from(raw));
        if (q.questionText.trim().isEmpty || q.options.length < 2) continue;
        if (seenQ.add(q.questionText.trim().toLowerCase())) {
          quizList.add(q);
        }
      }
      _quiz = quizList;
      _isLoaded = true;
      clearTopicCache();
    } catch (e) {
      debugPrint('VocabDictionaryService load fallback note: $e');
      _ows = _fallbackOws;
      _idioms = _fallbackIdioms;
      _synAnt = _fallbackSynAnt;
      _homonyms = _fallbackHomonyms;
      _spellings = _fallbackSpellings;
      _roots = List<BlackbookRootWordItem>.from(BlackbookVocabularyBank.rootWords)
        ..sort((a, b) => compareDictionary(a.root, b.root));
      _quiz = List<EnglishExerciseQuestion>.from(BlackbookVocabularyBank.blackbookPracticeQuestions);
      _isLoaded = true;
    }
  }

  /// Dictionary-style prefix ranking: headwords starting with [query] appear first,
  /// sorted A->Z, followed by contains matches in headword or meanings.
  static List<T> filterAndRankDictionary<T>({
    required List<T> items,
    required String query,
    required String letterFilter,
    required bool sortByFrequency,
    required String Function(T) getHeadword,
    required int Function(T) getRepetition,
    required bool Function(T, String) matchesSecondary,
  }) {
    Iterable<T> filtered = items;

    if (letterFilter != 'ALL') {
      filtered = filtered.where((item) => startingLetter(getHeadword(item)) == letterFilter);
    }

    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      final list = filtered.toList();
      if (sortByFrequency) {
        list.sort((a, b) {
          final cmp = getRepetition(b).compareTo(getRepetition(a));
          return cmp != 0 ? cmp : compareDictionary(getHeadword(a), getHeadword(b));
        });
      } else {
        list.sort((a, b) => compareDictionary(getHeadword(a), getHeadword(b)));
      }
      return list;
    }

    final prefixMatches = <T>[];
    final wordContainsMatches = <T>[];
    final secondaryMatches = <T>[];

    for (final item in filtered) {
      final hw = normalizeForSort(getHeadword(item));
      if (hw.startsWith(q)) {
        prefixMatches.add(item);
      } else if (hw.contains(q)) {
        wordContainsMatches.add(item);
      } else if (matchesSecondary(item, q)) {
        secondaryMatches.add(item);
      }
    }

    if (!sortByFrequency) {
      prefixMatches.sort((a, b) => compareDictionary(getHeadword(a), getHeadword(b)));
      wordContainsMatches.sort((a, b) => compareDictionary(getHeadword(a), getHeadword(b)));
      secondaryMatches.sort((a, b) => compareDictionary(getHeadword(a), getHeadword(b)));
    } else {
      prefixMatches.sort((a, b) => getRepetition(b).compareTo(getRepetition(a)));
      wordContainsMatches.sort((a, b) => getRepetition(b).compareTo(getRepetition(a)));
      secondaryMatches.sort((a, b) => getRepetition(b).compareTo(getRepetition(a)));
    }

    return [...prefixMatches, ...wordContainsMatches, ...secondaryMatches];
  }

  final Map<String, List<EnglishExerciseQuestion>> _topicQuestionCache = {};

  /// Clears cached generated topic questions (called after reload).
  void clearTopicCache() => _topicQuestionCache.clear();

  /// Returns all available topic-wise MCQ bundles covering 100% of extracted items.
  List<VocabTopicQuizBundle> getTopicWiseQuizBundles() {
    final sscOws = getQuestionsForTopic('ssc_ows');
    final otherOws = getQuestionsForTopic('other_ows');
    final synonyms = getQuestionsForTopic('synonyms');
    final antonyms = getQuestionsForTopic('antonyms');
    final spelling = getQuestionsForTopic('spelling');
    final sscIdioms = getQuestionsForTopic('ssc_idioms');
    final proverbs = getQuestionsForTopic('proverbs_idioms');
    final phrasal = getQuestionsForTopic('phrasal_preps');
    final homonyms = getQuestionsForTopic('homonyms');
    final editorial = getQuestionsForTopic('editorial_foreign');

    return [
      VocabTopicQuizBundle(
        key: 'ssc_ows',
        title: 'SSC One Word Substitution',
        subtitle: '${sscOws.length} repeated exam OWS MCQs with Hindi meanings',
        categoryTag: 'OWS',
        questions: sscOws,
      ),
      VocabTopicQuizBundle(
        key: 'other_ows',
        title: 'Other Exams OWS',
        subtitle: '${otherOws.length} Banking, CDS & State exam OWS MCQs',
        categoryTag: 'OWS',
        questions: otherOws,
      ),
      VocabTopicQuizBundle(
        key: 'synonyms',
        title: 'Synonyms Mastery',
        subtitle: '${synonyms.length} high-frequency Synonym MCQs',
        categoryTag: 'SYNONYMS',
        questions: synonyms,
      ),
      VocabTopicQuizBundle(
        key: 'antonyms',
        title: 'Antonyms Mastery',
        subtitle: '${antonyms.length} high-frequency Antonym MCQs',
        categoryTag: 'ANTONYMS',
        questions: antonyms,
      ),
      VocabTopicQuizBundle(
        key: 'spelling',
        title: 'Spelling Test & Traps',
        subtitle: '${spelling.length} commonly misspelt word MCQs',
        categoryTag: 'SPELLING',
        questions: spelling,
      ),
      VocabTopicQuizBundle(
        key: 'ssc_idioms',
        title: 'SSC Idioms & Phrases',
        subtitle: '${sscIdioms.length} high-frequency SSC Idiom MCQs',
        categoryTag: 'IDIOMS',
        questions: sscIdioms,
      ),
      VocabTopicQuizBundle(
        key: 'proverbs_idioms',
        title: 'Proverbs & Exam Idioms',
        subtitle: '${proverbs.length} Proverbs & extra Idiom MCQs',
        categoryTag: 'PROVERBS',
        questions: proverbs,
      ),
      VocabTopicQuizBundle(
        key: 'phrasal_preps',
        title: 'Phrasal Verbs & Fixed Prepositions',
        subtitle: '${phrasal.length} Phrasal Verb & Preposition MCQs',
        categoryTag: 'BOOSTERS',
        questions: phrasal,
      ),
      VocabTopicQuizBundle(
        key: 'homonyms',
        title: 'Homonyms & Confusing Words',
        subtitle: '${homonyms.length} look-alike & sound-alike word MCQs',
        categoryTag: 'HOMONYMS',
        questions: homonyms,
      ),
      VocabTopicQuizBundle(
        key: 'editorial_foreign',
        title: 'Editorial & Foreign Vocab',
        subtitle: '${editorial.length} advanced Editorial & Foreign word MCQs',
        categoryTag: 'EDITORIAL',
        questions: editorial,
      ),
    ].where((b) => b.questions.isNotEmpty).toList();
  }

  /// Generates & caches all exam MCQs for a given topic key cleanly.
  List<EnglishExerciseQuestion> getQuestionsForTopic(String topicKey) {
    final cacheKey = '${_isLoaded ? "L" : "F"}_$topicKey';
    final cached = _topicQuestionCache[cacheKey];
    if (cached != null) return cached;

    late final List<EnglishExerciseQuestion> built;
    switch (topicKey) {
      case 'ssc_ows':
        built = _buildOwsQuestions(
          ows.where((e) => !e.category.toLowerCase().contains('other')).toList(),
          includeCuratedQuiz: true,
        );
        break;
      case 'other_ows':
        built = _buildOwsQuestions(
          ows.where((e) => e.category.toLowerCase().contains('other')).toList(),
        );
        break;
      case 'ssc_idioms':
        built = _buildIdiomQuestions(
          idioms.where((e) => e.category.toLowerCase().contains('ssc')).toList(),
          includeCuratedQuiz: true,
        );
        break;
      case 'proverbs_idioms':
        built = _buildIdiomQuestions(
          idioms.where((e) => !e.category.toLowerCase().contains('ssc')).toList(),
        );
        break;
      case 'spelling':
        built = _buildSpellingQuestions(spellings, includeCuratedQuiz: true);
        break;
      case 'synonyms':
        built = _buildSynAntQuestions(synAnt, isSynonym: true);
        break;
      case 'antonyms':
        built = _buildSynAntQuestions(synAnt, isSynonym: false);
        break;
      case 'phrasal_preps':
        built = _buildBoosterQuestions(
          boosters.where((b) => b.section == 'Phrasal Verbs' || b.section == 'Fixed Prepositions').toList(),
        );
        break;
      case 'editorial_foreign':
        built = _buildBoosterQuestions(
          boosters.where((b) => b.section != 'Phrasal Verbs' && b.section != 'Fixed Prepositions').toList(),
        );
        break;
      case 'homonyms':
        built = _buildHomonymQuestions(homonyms);
        break;
      case 'all':
      default:
        built = [
          ...getQuestionsForTopic('ssc_ows'),
          ...getQuestionsForTopic('other_ows'),
          ...getQuestionsForTopic('ssc_idioms'),
          ...getQuestionsForTopic('proverbs_idioms'),
          ...getQuestionsForTopic('spelling'),
          ...getQuestionsForTopic('synonyms'),
          ...getQuestionsForTopic('antonyms'),
          ...getQuestionsForTopic('phrasal_preps'),
          ...getQuestionsForTopic('homonyms'),
          ...getQuestionsForTopic('editorial_foreign'),
        ];
        break;
    }

    _topicQuestionCache[cacheKey] = built;
    return built;
  }

  List<String> _deterministicOptions(String correct, List<String> pool, int seed) {
    final Set<String> opts = {correct};
    final int n = pool.length;
    if (n > 0) {
      int step = (seed % 7) + 1;
      for (int k = 0; k < 20 && opts.length < 4; k++) {
        final cand = pool[(seed + k * step) % n].trim();
        if (cand.isNotEmpty && cand.toLowerCase() != correct.toLowerCase()) {
          opts.add(cand);
        }
      }
    }
    int pad = 1;
    while (opts.length < 4) {
      opts.add('$correct ($pad)');
      pad++;
    }
    final list = opts.take(4).toList();
    // Deterministic permutation by seed
    final rot = seed % 4;
    return [...list.skip(rot), ...list.take(rot)];
  }

  List<EnglishExerciseQuestion> _buildOwsQuestions(
    List<BlackbookOwsItem> source, {
    bool includeCuratedQuiz = false,
  }) {
    final List<EnglishExerciseQuestion> out = [];
    final seen = <String>{};
    if (includeCuratedQuiz) {
      for (final q in quiz.where((x) => x.type.toUpperCase() == 'OWS')) {
        if (seen.add(q.questionText.trim().toLowerCase())) out.add(q);
      }
    }
    final pool = ows.map((e) => e.word).where((w) => w.isNotEmpty).toList();
    for (int i = 0; i < source.length; i++) {
      final item = source[i];
      if (item.phrase.trim().isEmpty || item.word.trim().isEmpty) continue;
      final prompt = 'One word for: "${item.phrase.trim()}"';
      if (!seen.add(prompt.toLowerCase())) continue;
      final options = _deterministicOptions(item.word.trim(), pool, item.id + i);
      final correctIdx = options.indexOf(item.word.trim());
      out.add(EnglishExerciseQuestion(
        id: 'ows_gen_${item.id}',
        questionText: prompt,
        options: options,
        correctIndex: correctIdx < 0 ? 0 : correctIdx,
        type: 'OWS',
        explanation: '${item.word} (${item.partOfSpeech}) — ${item.hindiMeaning.isNotEmpty ? item.hindiMeaning : item.phrase}',
      ));
    }
    return out;
  }

  List<EnglishExerciseQuestion> _buildIdiomQuestions(
    List<BlackbookIdiomItem> source, {
    bool includeCuratedQuiz = false,
  }) {
    final List<EnglishExerciseQuestion> out = [];
    final seen = <String>{};
    if (includeCuratedQuiz) {
      for (final q in quiz.where((x) => x.type.toUpperCase().contains('IDIOM'))) {
        if (seen.add(q.questionText.trim().toLowerCase())) out.add(q);
      }
    }
    final pool = idioms.map((e) => e.englishMeaning).where((m) => m.isNotEmpty).toList();
    for (int i = 0; i < source.length; i++) {
      final item = source[i];
      if (item.idiom.trim().isEmpty || item.englishMeaning.trim().isEmpty) continue;
      final prompt = 'Meaning of idiom: "${item.idiom.trim()}"';
      if (!seen.add(prompt.toLowerCase())) continue;
      final options = _deterministicOptions(item.englishMeaning.trim(), pool, item.id + i);
      final correctIdx = options.indexOf(item.englishMeaning.trim());
      out.add(EnglishExerciseQuestion(
        id: 'idm_gen_${item.id}',
        questionText: prompt,
        options: options,
        correctIndex: correctIdx < 0 ? 0 : correctIdx,
        type: 'Idiom',
        explanation: '${item.idiom}: ${item.englishMeaning}${item.hindiMeaning.isNotEmpty ? " (${item.hindiMeaning})" : ""}',
      ));
    }
    return out;
  }

  List<EnglishExerciseQuestion> _buildSpellingQuestions(
    List<BlackbookSpellingItem> source, {
    bool includeCuratedQuiz = false,
  }) {
    final List<EnglishExerciseQuestion> out = [];
    final seen = <String>{};
    if (includeCuratedQuiz) {
      for (final q in quiz.where((x) => x.type.toUpperCase().contains('SPELL'))) {
        if (seen.add(q.questionText.trim().toLowerCase())) out.add(q);
      }
    }
    for (int i = 0; i < source.length; i++) {
      final item = source[i];
      final correct = item.correctWord.trim();
      if (correct.length < 3) continue;
      final prompt = 'Select the correctly spelt word (${item.hindiMeaning.isNotEmpty ? item.hindiMeaning : "Vocabulary"})';
      if (!seen.add('${prompt}_$correct'.toLowerCase())) continue;
      final wrongs = item.wrongOptions.where((w) => w.trim().isNotEmpty && w.trim().toLowerCase() != correct.toLowerCase()).toList();
      final traps = wrongs.length >= 3 ? wrongs.take(3).toList() : _generateSpellingTraps(correct, wrongs);
      final opts = _deterministicOptions(correct, traps, item.id + i);
      final correctIdx = opts.indexOf(correct);
      out.add(EnglishExerciseQuestion(
        id: 'spl_gen_${item.id}',
        questionText: prompt,
        options: opts,
        correctIndex: correctIdx < 0 ? 0 : correctIdx,
        type: 'Spelling',
        explanation: 'Correct spelling: $correct${item.hindiMeaning.isNotEmpty ? " (${item.hindiMeaning})" : ""}${item.trickyPart.isNotEmpty ? " • Trap: ${item.trickyPart}" : ""}',
      ));
    }
    return out;
  }

  List<String> _generateSpellingTraps(String word, List<String> seedWrongs) {
    final Set<String> traps = {...seedWrongs};
    final lower = word.toLowerCase();
    // Trap 1: swap common vowels
    final rules = [
      ['ei', 'ie'], ['ie', 'ei'], ['a', 'e'], ['e', 'i'], ['i', 'e'], ['o', 'u'], ['c', 's'], ['s', 'c'],
    ];
    for (final r in rules) {
      if (traps.length >= 3) break;
      if (lower.contains(r[0])) {
        final mutated = word.replaceFirst(RegExp(r[0], caseSensitive: false), r[1]);
        if (mutated.toLowerCase() != lower) traps.add(mutated);
      }
    }
    // Trap 2: duplicate or drop double letter
    for (int i = 1; i < word.length - 1 && traps.length < 3; i++) {
      if (word[i] == word[i - 1]) {
        traps.add(word.substring(0, i) + word.substring(i + 1));
      } else if (RegExp(r'[bcdfghjklmnpqrstvwxyz]', caseSensitive: false).hasMatch(word[i])) {
        traps.add(word.substring(0, i + 1) + word[i] + word.substring(i + 1));
      }
    }
    if (traps.length < 3 && word.length > 3) {
      traps.add('${word.substring(0, word.length - 1)}e${word[word.length - 1]}');
    }
    while (traps.length < 3) {
      traps.add('${word}s');
      if (traps.length < 3) traps.add('${word}e');
      if (traps.length < 3) traps.add('in$word');
    }
    return traps.take(3).toList();
  }

  List<EnglishExerciseQuestion> _buildSynAntQuestions(
    List<BlackbookSynAntItem> source, {
    required bool isSynonym,
  }) {
    final List<EnglishExerciseQuestion> out = [];
    final wordPool = source.map((e) => e.word).where((w) => w.isNotEmpty).toList();
    for (int i = 0; i < source.length; i++) {
      final item = source[i];
      final targetList = isSynonym ? item.synonyms : item.antonyms;
      if (targetList.isEmpty || item.word.trim().isEmpty) continue;
      final ans = targetList.first.trim();
      if (ans.isEmpty || ans.toLowerCase() == item.word.trim().toLowerCase()) continue;
      final label = isSynonym ? 'SYNONYM' : 'ANTONYM';
      final opts = _deterministicOptions(ans, wordPool, item.id + i + (isSynonym ? 11 : 97));
      final correctIdx = opts.indexOf(ans);
      out.add(EnglishExerciseQuestion(
        id: '${isSynonym ? "syn" : "ant"}_gen_${item.id}',
        questionText: 'Choose the $label of: ${item.word} (${item.partOfSpeech})',
        options: opts,
        correctIndex: correctIdx < 0 ? 0 : correctIdx,
        type: isSynonym ? 'Synonym' : 'Antonym',
        explanation: '${item.word}: ${item.definition.isNotEmpty ? item.definition : item.hindiMeaning} • $label: $ans',
      ));
    }
    return out;
  }

  List<EnglishExerciseQuestion> _buildBoosterQuestions(List<VocabBoosterWordItem> source) {
    final List<EnglishExerciseQuestion> out = [];
    final pool = boosters.map((b) => b.englishMeaning).where((m) => m.isNotEmpty).toList();
    for (int i = 0; i < source.length; i++) {
      final item = source[i];
      if (item.word.trim().isEmpty || item.englishMeaning.trim().isEmpty) continue;
      final ans = item.englishMeaning.trim();
      final opts = _deterministicOptions(ans, pool, item.id + i + 31);
      final correctIdx = opts.indexOf(ans);
      out.add(EnglishExerciseQuestion(
        id: 'bst_gen_${item.id}_$i',
        questionText: 'Meaning of ${item.section}: "${item.word}"',
        options: opts,
        correctIndex: correctIdx < 0 ? 0 : correctIdx,
        type: item.section,
        explanation: '${item.word}: $ans${item.hindiMeaning.isNotEmpty ? " (${item.hindiMeaning})" : ""}',
      ));
    }
    return out;
  }

  List<EnglishExerciseQuestion> _buildHomonymQuestions(List<BlackbookHomonymPair> source) {
    final List<EnglishExerciseQuestion> out = [];
    final pool = source.map((h) => h.word1).where((w) => w.isNotEmpty).toList();
    for (int i = 0; i < source.length; i++) {
      final h = source[i];
      if (h.word1.trim().isEmpty || h.meaning1.trim().isEmpty) continue;
      final ans = h.word1.trim();
      final distractors = [h.word2.trim(), ...pool];
      final opts = _deterministicOptions(ans, distractors, h.id + i + 53);
      final correctIdx = opts.indexOf(ans);
      out.add(EnglishExerciseQuestion(
        id: 'hom_gen_${h.id}',
        questionText: 'Choose word meaning: "${h.meaning1}" (often confused with "${h.word2}")',
        options: opts,
        correctIndex: correctIdx < 0 ? 0 : correctIdx,
        type: 'Homonyms',
        explanation: '${h.word1} (${h.pos1}): ${h.meaning1} | ${h.word2} (${h.pos2}): ${h.meaning2}',
      ));
    }
    return out;
  }

}
