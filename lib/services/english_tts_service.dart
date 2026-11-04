import 'package:flutter_tts/flutter_tts.dart';

class EnglishTtsService {
  static final EnglishTtsService _instance = EnglishTtsService._internal();
  factory EnglishTtsService() => _instance;
  EnglishTtsService._internal();

  FlutterTts? _tts;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    try {
      _tts = FlutterTts();
      await _tts?.setLanguage('en-US');
      await _tts?.setSpeechRate(0.42);
      await _tts?.setPitch(1.0);
      _initialized = true;
    } catch (_) {}
  }

  Future<void> speakWord(String text) async {
    try {
      await _init();
      await _tts?.stop();
      await _tts?.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
