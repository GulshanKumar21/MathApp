import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/models/math_models.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Custom Revision Deck - Starter pack loading, adding, editing, mastering, and deleting items', () async {
    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    // 1. Check revision deck starts 100% clean and empty (no hardcoded mock data)
    expect(provider.revisionItems.isEmpty, isTrue);
    const initialCount = 0;

    // 2. Add custom revision item
    final customItem = RevisionItemModel(
      id: 'custom_ci_trick_1',
      title: 'Compound Interest 3-Year Ratio',
      question: '3-Year CI:SI Difference Ratio',
      answer: '3R + 1 / R³',
      category: 'Shortcuts',
      notes: 'Standard shortcut for SSC CGL Tier 2',
      createdAt: DateTime.now(),
    );

    await provider.addRevisionItem(customItem);
    expect(provider.revisionItems.length, initialCount + 1);
    expect(provider.revisionItems.first.title, 'Compound Interest 3-Year Ratio');

    // 3. Toggle mastered status
    expect(provider.revisionItems.first.isMastered, isFalse);
    await provider.toggleMasterRevisionItem('custom_ci_trick_1');
    expect(provider.revisionItems.first.isMastered, isTrue);

    // 4. Update item
    final updated = provider.revisionItems.first.copyWith(
      title: 'CI 3-Year Master Formula',
      answer: '3a + 3b + c',
    );
    await provider.updateRevisionItem(updated);
    expect(provider.revisionItems.first.title, 'CI 3-Year Master Formula');
    expect(provider.revisionItems.first.answer, '3a + 3b + c');

    // 5. Delete item
    await provider.deleteRevisionItem('custom_ci_trick_1');
    expect(provider.revisionItems.length, initialCount);
    expect(provider.revisionItems.any((e) => e.id == 'custom_ci_trick_1'), isFalse);
  });
}
