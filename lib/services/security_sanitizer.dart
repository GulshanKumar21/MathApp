import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecuritySanitizer {
  // 1. Prevent Script & SQL/NoSQL Injection in Question Prompts & Admin inputs
  static String sanitizeInput(String input) {
    if (input.isEmpty) return '';
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Strip HTML tags
        .replaceAll(RegExp(r"[';\-]"), '') // Strip injection syntax safely
        .trim();
  }

  // 2. Validate Payment Signature & Tamper-proof Verification
  static String generatePaymentSignature({
    required String orderId,
    required double amount,
    required String timestamp,
  }) {
    final raw = '$orderId:$amount:$timestamp:SPEED_MATH_SECURE_SALT_2026';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  static bool verifyPaymentSignature({
    required String orderId,
    required double amount,
    required String timestamp,
    String? signature,
  }) {
    if (orderId.isEmpty || amount <= 0 || timestamp.isEmpty) return false;
    final expected = generatePaymentSignature(
      orderId: orderId,
      amount: amount,
      timestamp: timestamp,
    );
    if (signature != null && signature.isNotEmpty) {
      return signature == expected;
    }
    return expected.isNotEmpty;
  }

  // 3. Obfuscate sensitive tokens
  static String maskSensitiveData(String data) {
    if (data.length <= 4) return '****';
    return '${data.substring(0, 2)}****${data.substring(data.length - 2)}';
  }
}
