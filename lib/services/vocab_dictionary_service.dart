import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data/blackbook_vocabulary_bank.dart';
import '../models/english_models.dart';

/// Singleton service that loads, merges, deduplicates, and serves PrepVanta's
/// full A-to-Z English Vocabulary Dictionary from compressed bundled assets.
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
}
