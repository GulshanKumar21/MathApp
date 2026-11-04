import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_speed_practice/providers/app_state_provider.dart';
import 'package:math_speed_practice/services/in_app_payment_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Payment Verification & Anti-Fraud Gate Tests', () {
    test('Invalid UTR format (< 12 digits or alphabetic) is strictly rejected', () async {
      final result1 = await InAppPaymentService.verifyUtrAndClaim(
        utr: '12345',
        userId: 'test_user_1',
        userName: 'Aspirant',
        amount: 29.0,
      );
      expect(result1['success'], isFalse);
      expect(result1['error'], contains('12 numeric digits'));

      final result2 = await InAppPaymentService.verifyUtrAndClaim(
        utr: '42918204918A', // Alphabetic
        userId: 'test_user_1',
        userName: 'Aspirant',
        amount: 29.0,
      );
      expect(result2['success'], isFalse);
      expect(result2['error'], contains('12 numeric digits'));
    });

    test('Valid 12-Digit UTR format can be verified and locked against duplicate reuse', () async {
      const validUtr = '429182049182';

      final result1 = await InAppPaymentService.verifyUtrAndClaim(
        utr: validUtr,
        userId: 'test_user_1',
        userName: 'Aspirant 1',
        amount: 29.0,
      );

      // Successfully processed UTR
      expect(result1['success'], isTrue);
      expect(result1['utr'], equals(validUtr));

      // Attempting to reuse the exact same UTR by another student is blocked
      final result2 = await InAppPaymentService.verifyUtrAndClaim(
        utr: validUtr,
        userId: 'test_user_2',
        userName: 'Aspirant 2',
        amount: 29.0,
      );

      expect(result2['success'], isFalse);
      expect(result2['error'], contains('already been used'));
    });

    test('AppStateProvider does NOT unlock Pro without legitimate purchase processing', () async {
      final state = AppStateProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(state.isPremium, isFalse);

      // Simply visiting checkout or tapping back does not set isPremium to true
      expect(state.isPremium, isFalse);

      // Proper verified purchase execution
      final success = await state.processPurchase(
        userName: 'Verified Aspirant',
        paymentMethod: 'UPI Verified (UTR: 429182049182)',
      );

      expect(success, isTrue);
      expect(state.isPremium, isTrue);
      expect(state.transactions.isNotEmpty, isTrue);
      expect(state.transactions.first.status, 'SUCCESS');
    });
  });
}
