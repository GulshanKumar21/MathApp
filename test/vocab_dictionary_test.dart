import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/services/vocab_dictionary_service.dart';
import 'package:math_speed_practice/models/english_models.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/screens/english/english_hub_screen.dart';

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

    // Verify all topic-wise MCQ bundles cover all extracted datasets cleanly
    final bundles = svc.getTopicWiseQuizBundles();
    expect(bundles.length, greaterThanOrEqualTo(9));
    final totalTopicQs = bundles.fold<int>(0, (acc, b) => acc + b.questions.length);
    expect(totalTopicQs, greaterThan(5000));
    for (final b in bundles) {
      expect(b.questions.isNotEmpty, isTrue);
      final q = b.questions.first;
      expect(q.options.length, equals(4));
      expect(q.correctIndex >= 0 && q.correctIndex < 4, isTrue);
    }
  });

  testWidgets('EnglishHubScreen renders cleanly without overflow or duplicate promo banner', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: EnglishHubScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Topic MCQs & Word Vaults & A-Z Dictionary cleanly separated
    expect(find.textContaining('Topic MCQs'), findsOneWidget);
    expect(find.textContaining('Word Vaults'), findsOneWidget);
    expect(find.textContaining('A–Z Dictionary'), findsOneWidget);
    expect(find.text('Open A–Z'), findsNothing);

    // Switch to Word Vaults and scroll to NOVICE (#4) — verifying zero RenderFlex overflow
    await tester.tap(find.textContaining('Word Vaults'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('NOVICE'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('NOVICE'), findsOneWidget);
  });
}
