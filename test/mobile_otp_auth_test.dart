import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class IndianPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length > 10) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

String sanitizeIndianPhoneNumber(String rawInput) {
  String phone = rawInput.replaceAll(RegExp(r'\D'), '');
  if (phone.startsWith('91') && phone.length > 10) {
    phone = phone.substring(2);
  } else if (phone.startsWith('0') && phone.length > 10) {
    phone = phone.substring(1);
  }
  if (phone.length > 10) {
    phone = phone.substring(0, 10);
  }
  return phone;
}

void main() {
  group('Mobile OTP & Indian Phone Formatter Tests', () {
    final formatter = IndianPhoneNumberFormatter();

    test('Pasting number with +91 country code strips prefix and extracts 10 digits', () {
      const input = '+91 98765 43210';
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: input),
      );
      expect(result.text, equals('9876543210'));
      expect(sanitizeIndianPhoneNumber(input), equals('9876543210'));
    });

    test('Pasting number with 91 prefix without plus extracts 10 digits', () {
      const input = '919876543210';
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: input),
      );
      expect(result.text, equals('9876543210'));
      expect(sanitizeIndianPhoneNumber(input), equals('9876543210'));
    });

    test('Pasting number with leading 0 (STD/trunk prefix) strips 0 and keeps 10 digits', () {
      const input = '09876543210';
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: input),
      );
      expect(result.text, equals('9876543210'));
      expect(sanitizeIndianPhoneNumber(input), equals('9876543210'));
    });

    test('Entering 10 digits directly preserves exact number', () {
      const input = '9876543210';
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: input),
      );
      expect(result.text, equals('9876543210'));
      expect(sanitizeIndianPhoneNumber(input), equals('9876543210'));
    });

    test('Input with dashes and spaces is cleaned up', () {
      const input = '9876-543-210';
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: input),
      );
      expect(result.text, equals('9876543210'));
      expect(sanitizeIndianPhoneNumber(input), equals('9876543210'));
    });

    test('Regex validates strictly 10 digits', () {
      final phoneRegex = RegExp(r'^\d{10}$');
      expect(phoneRegex.hasMatch('9876543210'), isTrue);
      expect(phoneRegex.hasMatch('987654321'), isFalse);
      expect(phoneRegex.hasMatch('98765432100'), isFalse);
      expect(phoneRegex.hasMatch('987654321a'), isFalse);
    });
  });
}
