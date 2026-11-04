import 'package:flutter_tts/flutter_tts.dart';

class VoiceReciterHelper {
  static const Map<int, String> _indianMultipliers = {
    1: 'one za',
    2: 'two za',
    3: 'three za',
    4: 'four za',
    5: 'five za',
    6: 'six za',
    7: 'seven za',
    8: 'eight za',
    9: 'nine za',
    10: 'ten za',
    11: 'eleven za',
    12: 'twelve za',
    13: 'thirteen za',
    14: 'fourteen za',
    15: 'fifteen za',
    16: 'sixteen za',
    17: 'seventeen za',
    18: 'eighteen za',
    19: 'nineteen za',
    20: 'twenty za',
  };

  static String getIndianMultiplierWord(int mult) {
    return _indianMultipliers[mult] ?? '$mult za';
  }

  static const List<Map<String, dynamic>> availableStyles = [
    {
      'id': 'school',
      'title': 'School Chanting ("za")',
      'subtitle': '17 two za 34 • Traditional Indian school rhythm',
      'icon': 'school_rounded',
      'badge': 'RECOMMENDED',
    },
    {
      'id': 'times',
      'title': 'Times Style',
      'subtitle': '17 times 2 is 34 • Clear international rhythm',
      'icon': 'close_rounded',
      'badge': 'POPULAR',
    },
    {
      'id': 'vedic',
      'title': 'Vedic Fast Drill',
      'subtitle': '17 into 2, 34 • Rapid-fire high speed calculation',
      'icon': 'bolt_rounded',
      'badge': 'SPEED',
    },
    {
      'id': 'quiz',
      'title': 'Self-Quiz Recall Drill',
      'subtitle': '17 times 2 is... [pause 2s] ... 34! • Active brain recall',
      'icon': 'psychology_rounded',
      'badge': 'MEMORIZE',
    },
    {
      'id': 'standard',
      'title': 'Formal Math',
      'subtitle': '17 multiplied by 2 is 34 • Formal textbook format',
      'icon': 'menu_book_rounded',
      'badge': 'FORMAL',
    },
  ];
  static const List<Map<String, dynamic>> recitalStyles = availableStyles;

  static const List<Map<String, String>> availableLanguages = [
    {'code': 'en-IN', 'name': 'Indian English', 'flag': '🇮🇳'},
    {'code': 'en-US', 'name': 'US English', 'flag': '🇺🇸'},
    {'code': 'en-GB', 'name': 'UK English', 'flag': '🇬🇧'},
    {'code': 'hi-IN', 'name': 'Hindi Voice', 'flag': '🇮🇳'},
  ];

  static const List<Map<String, dynamic>> speedPresets = [
    {'label': '0.35x Slow', 'val': 0.35},
    {'label': '0.45x Normal', 'val': 0.45},
    {'label': '0.55x Fast', 'val': 0.55},
    {'label': '0.65x Blitz', 'val': 0.65},
  ];

  static const List<Map<String, dynamic>> pitchPresets = [
    {'label': 'Deep (0.8x)', 'val': 0.8},
    {'label': 'Natural (1.0x)', 'val': 1.0},
    {'label': 'Clear/High (1.2x)', 'val': 1.2},
  ];

  static const List<Map<String, dynamic>> repeatModes = [
    {'id': 'none', 'label': 'No Loop', 'icon': 'arrow_forward_rounded'},
    {'id': 'table', 'label': 'Loop Table', 'icon': 'repeat_rounded'},
    {'id': 'row', 'label': 'Repeat Row', 'icon': 'repeat_one_rounded'},
  ];

  /// Generate speech text for multiplication tables
  static String getTableSpeechText({
    required int table,
    required int mult,
    required String style,
    bool isQuestionOnly = false,
  }) {
    int ans = table * mult;
    switch (style) {
      case 'school':
        if (isQuestionOnly) return '$table ${getIndianMultiplierWord(mult)}';
        return '$table ${getIndianMultiplierWord(mult)} $ans';
      case 'times':
        if (isQuestionOnly) return '$table times $mult is';
        return '$table times $mult is $ans';
      case 'vedic':
        if (isQuestionOnly) return '$table into $mult';
        return '$table into $mult, $ans';
      case 'quiz':
        if (isQuestionOnly) return '$table times $mult is';
        return '$ans';
      case 'standard':
      default:
        if (isQuestionOnly) return '$table multiplied by $mult is';
        return '$table multiplied by $mult is $ans';
    }
  }

  /// Generate speech text for square numbers
  static String getSquareSpeechText({
    required int number,
    required String style,
    bool isQuestionOnly = false,
  }) {
    int ans = number * number;
    switch (style) {
      case 'vedic':
        if (isQuestionOnly) return '$number square';
        return '$number square, $ans';
      case 'quiz':
        if (isQuestionOnly) return 'Square of $number is';
        return '$ans';
      case 'school':
      case 'times':
      case 'standard':
      default:
        if (isQuestionOnly) return 'Square of $number is';
        return 'Square of $number is $ans';
    }
  }

  /// Generate speech text for cube numbers
  static String getCubeSpeechText({
    required int number,
    required String style,
    bool isQuestionOnly = false,
  }) {
    int ans = number * number * number;
    switch (style) {
      case 'vedic':
        if (isQuestionOnly) return '$number cube';
        return '$number cube, $ans';
      case 'quiz':
        if (isQuestionOnly) return 'Cube of $number is';
        return '$ans';
      case 'school':
      case 'times':
      case 'standard':
      default:
        if (isQuestionOnly) return 'Cube of $number is';
        return 'Cube of $number is $ans';
    }
  }

  /// Generate speech text for fraction to percentage conversions
  static String getFractionSpeechText({
    required String fraction,
    required String percentage,
    required String decimal,
    required String style,
    bool isQuestionOnly = false,
  }) {
    String cleanFraction = fraction.replaceAll('/', ' by ');
    switch (style) {
      case 'vedic':
        if (isQuestionOnly) return '$cleanFraction percent';
        return '$cleanFraction, $percentage';
      case 'quiz':
        if (isQuestionOnly) return 'What is $cleanFraction in percent?';
        return percentage;
      case 'school':
      case 'times':
      case 'standard':
      default:
        if (isQuestionOnly) return '$cleanFraction in percentage is';
        return '$cleanFraction is $percentage, decimal $decimal';
    }
  }

  /// Generate speech text for Pythagorean Triples
  static String getTripleSpeechText({
    required int a,
    required int b,
    required int c,
    required String style,
    bool isQuestionOnly = false,
  }) {
    switch (style) {
      case 'vedic':
        if (isQuestionOnly) return 'Triple $a, $b';
        return '$a, $b, hypotenuse $c';
      case 'quiz':
        if (isQuestionOnly) return 'Base $a, perpendicular $b, what is hypotenuse?';
        return '$c';
      case 'school':
      case 'times':
      case 'standard':
      default:
        if (isQuestionOnly) return 'For triangle sides $a and $b';
        return 'Pythagorean triple: $a, $b, hypotenuse $c';
    }
  }

  /// Generate natural speech text for generic quiz prompts
  static String getQuestionSpeechText({
    required String prompt,
    String style = 'standard',
  }) {
    String text = prompt;
    // Replace symbols with spoken words
    text = text.replaceAll('×', style == 'vedic' ? 'into' : (style == 'school' ? 'za' : 'times'));
    text = text.replaceAll('*', ' times ');
    text = text.replaceAll('÷', ' divided by ');
    text = text.replaceAll('/', ' divided by ');
    text = text.replaceAll('+', ' plus ');
    text = text.replaceAll('-', ' minus ');
    text = text.replaceAll('²', ' squared');
    text = text.replaceAll('³', ' cubed');
    text = text.replaceAll('=', '');
    text = text.replaceAll('?', '');
    text = text.trim();
    if (style == 'quiz') {
      return 'Calculate: $text';
    }
    return text;
  }

  /// Apply speech settings to a FlutterTts instance
  static Future<void> applyTtsSettings({
    required FlutterTts tts,
    required double rate,
    required double pitch,
    required String language,
  }) async {
    try {
      await tts.setLanguage(language);
      await tts.setSpeechRate(rate);
      await tts.setPitch(pitch);
    } catch (_) {
      // Fallback to default en-US if locale not installed on system
      try {
        await tts.setLanguage('en-US');
        await tts.setSpeechRate(rate);
        await tts.setPitch(pitch);
      } catch (_) {}
    }
  }

  /// Preview / Test voice speech
  static Future<void> playTestVoice({
    required FlutterTts tts,
    required double rate,
    required double pitch,
    required String language,
    required String style,
  }) async {
    await applyTtsSettings(tts: tts, rate: rate, pitch: pitch, language: language);
    String sample = getTableSpeechText(table: 17, mult: 6, style: style);
    await tts.stop();
    await tts.speak('Testing voice: $sample');
  }
}
