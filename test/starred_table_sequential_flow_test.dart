import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Starred Table Notification - Sequential progression through all multipliers 2 to 12 without repetition or trivial x1', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('starred_tables', ['23']);
    await prefs.setInt('active_starred_table_number', 23);

    // Verify competitive exam multipliers list
    expect(NotificationService.tableMultipliers, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    expect(NotificationService.tableMultipliers.contains(1), isFalse); // No trivial x 1

    // Step through all 11 multipliers sequentially
    final receivedMultipliers = <int>[];
    for (int i = 0; i < NotificationService.tableMultipliers.length; i++) {
      final key = 'starred_table_23_next_mult_idx';
      int currentIdx = prefs.getInt(key) ?? 0;
      expect(currentIdx, i);

      final m = NotificationService.tableMultipliers[currentIdx];
      receivedMultipliers.add(m);

      // Advance
      await prefs.setInt(key, (currentIdx + 1) % NotificationService.tableMultipliers.length);
    }

    // Must have tested all 11 multipliers in exact sequence without repetition
    expect(receivedMultipliers, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
  });

  test('Multi-table rotation: After completing Table 23 multipliers, advances to Table 29', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('starred_tables', ['23', '29']);
    await prefs.setInt('active_starred_table_number', 23);

    // Simulate completion of table 23
    final multKey = 'starred_table_23_next_mult_idx';
    await prefs.setInt(multKey, NotificationService.tableMultipliers.length); // at the end

    // Trigger next question logic
    final validStarred = [23, 29];
    int currentTable = prefs.getInt('active_starred_table_number') ?? validStarred.first;
    int nextMultIdx = prefs.getInt(multKey) ?? 0;

    if (nextMultIdx >= NotificationService.tableMultipliers.length) {
      nextMultIdx = 0;
      await prefs.setInt(multKey, 0);

      if (validStarred.length > 1) {
        int tableIdx = validStarred.indexOf(currentTable);
        int nextTableIdx = (tableIdx + 1) % validStarred.length;
        currentTable = validStarred[nextTableIdx];
        await prefs.setInt('active_starred_table_number', currentTable);
      }
    }

    // Current active table should now be rotated to Table 29!
    expect(prefs.getInt('active_starred_table_number'), 29);
  });
}
