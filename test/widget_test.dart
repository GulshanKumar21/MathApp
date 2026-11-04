import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/main.dart';
import 'package:math_speed_practice/services/notification_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    NotificationService().cancelAllTimers();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpeedMathApp());
    expect(find.byType(SpeedMathApp), findsOneWidget);
    NotificationService().cancelAllTimers();
  });
}
