import 'package:flutter_test/flutter_test.dart';
import 'package:math_speed_practice/services/vocab_dictionary_service.dart';
import 'package:math_speed_practice/models/english_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Dictionary sorting puts A, AA, AB in strict lexicographical order', () {
    final words = ['Abacus', 'Zebra', 'Aardvark', 'Abandon', 'Aaron', 'Aback'];
    words.sort(VocabDictionaryService.compareDictionary);
    expect(words, ['Aardvark', 'Aaron', 'Aback', 'Abacus', 'Abandon', 'Zebra']);
  });

  test('Prefix search ranks words starting with query before substring matches', () {
    final items = [
      const BlackbookOwsItem(id: 1, phrase: 'A person with ability', word: 'Capable', hindiMeaning: '', repetitionCount: 5),
      const BlackbookOwsItem(id: 2, phrase: 'Slaughterhouse', word: 'Abattoir', hindiMeaning: '', repetitionCount: 2),
      const BlackbookOwsItem(id: 3, phrase: 'Give up throne', word: 'Abdicate', hindiMeaning: '', repetitionCount: 8),
      const BlackbookOwsItem(id: 4, phrase: 'Shorten form', word: 'Aardvark', hindiMeaning: '', repetitionCount: 1),
    ];

    final filtered = VocabDictionaryService.filterAndRankDictionary<BlackbookOwsItem>(
      items: items,
      query: 'ab',
      letterFilter: 'ALL',
      sortByFrequency: false,
      getHeadword: (e) => e.word,
      getRepetition: (e) => e.repetitionCount,
      matchesSecondary: (e, q) => e.phrase.toLowerCase().contains(q),
    );

    expect(filtered.map((e) => e.word).toList(), ['Abattoir', 'Abdicate', 'Capable']);
  });

  test('VocabDictionaryService loads compressed assets and strips book branding', () async {
    final svc = VocabDictionaryService();
    await svc.ensureLoaded();

    expect(svc.ows.length, greaterThan(500));
    expect(svc.idioms.length, greaterThan(500));
    expect(svc.synAnt.length, greaterThan(1000));
    expect(svc.spellings.length, greaterThan(1000));
    expect(svc.boosters.length, greaterThan(300));
    expect(svc.quiz.length, greaterThan(50));

    // Verify A-Z ordering on OWS
    for (int i = 1; i < 50 && i < svc.ows.length; i++) {
      expect(
        VocabDictionaryService.compareDictionary(svc.ows[i - 1].word, svc.ows[i].word) <= 0,
        isTrue,
        reason: '${svc.ows[i - 1].word} should come before ${svc.ows[i].word}',
      );
    }

    // Verify no book name leaks in loaded entries
    for (final item in svc.ows.take(200)) {
      expect(item.word.toLowerCase().contains('blackbook'), isFalse);
      expect(item.phrase.toLowerCase().contains('blackbook'), isFalse);
    }
  });
}
