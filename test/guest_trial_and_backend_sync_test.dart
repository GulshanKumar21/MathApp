import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Guest 3-question free trial limit and mandatory registration barrier test', () async {
    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 50));

    // Initially guest is not logged in and has solved 0 questions
    expect(provider.isLoggedIn, isFalse);
    expect(provider.guestQuestionsSolved, equals(0));
    expect(provider.isGuestLimitReached, isFalse);

    // Question 1
    provider.recordGuestQuestionAnswered();
    expect(provider.guestQuestionsSolved, equals(1));
    expect(provider.isGuestLimitReached, isFalse);

    // Question 2
    provider.recordGuestQuestionAnswered();
    expect(provider.guestQuestionsSolved, equals(2));
    expect(provider.isGuestLimitReached, isFalse);

    // Question 3
    provider.recordGuestQuestionAnswered();
    expect(provider.guestQuestionsSolved, equals(3));
    expect(provider.isGuestLimitReached, isTrue);

    // Reset guest questions
    provider.resetGuestQuestionCount();
    expect(provider.guestQuestionsSolved, equals(0));
    expect(provider.isGuestLimitReached, isFalse);
  });
}
