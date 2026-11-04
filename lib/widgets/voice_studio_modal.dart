import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/voice_reciter_helper.dart';
import '../theme/app_theme.dart';

class VoiceStudioModal extends StatefulWidget {
  final VoidCallback? onSettingsChanged;

  const VoiceStudioModal({super.key, this.onSettingsChanged});

  static Future<void> show(BuildContext context, {VoidCallback? onSettingsChanged}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceStudioModal(onSettingsChanged: onSettingsChanged),
    );
  }

  @override
  State<VoiceStudioModal> createState() => _VoiceStudioModalState();
}

class _VoiceStudioModalState extends State<VoiceStudioModal> {
  final FlutterTts _previewTts = FlutterTts();
  bool _isPlayingPreview = false;

  late double _speed;
  late double _pitch;
  late String _language;
  late String _style;
  late String _repeatMode;
  late double _quizPause;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppStateProvider>();
    _speed = state.ttsSpeechRate;
    _pitch = state.ttsPitch;
    _language = state.ttsLanguage;
    _style = state.ttsRecitalStyle;
    _repeatMode = state.ttsRepeatMode;
    _quizPause = state.ttsQuizPauseSeconds;
  }

  @override
  void dispose() {
    _previewTts.stop();
    super.dispose();
  }

  Future<void> _playLiveTest() async {
    setState(() => _isPlayingPreview = true);
    await VoiceReciterHelper.playTestVoice(
      tts: _previewTts,
      rate: _speed,
      pitch: _pitch,
      language: _language,
      style: _style,
    );
    if (mounted) {
      setState(() => _isPlayingPreview = false);
    }
  }

  void _applyAndSave() {
    final state = context.read<AppStateProvider>();
    state.updateTtsSpeechRate(_speed);
    state.updateTtsPitch(_pitch);
    state.updateTtsLanguage(_language);
    state.updateTtsRecitalStyle(_style);
    state.updateTtsRepeatMode(_repeatMode);
    state.updateTtsQuizPauseSeconds(_quizPause);

    widget.onSettingsChanged?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF131826),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.graphic_eq_rounded, color: AppTheme.accent, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice & Audio Studio',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Customize chanting style, accent, speed & pause',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Scrollable Settings Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Recital Style
                  _sectionHeader('Recital Style & Chanting Format', Icons.record_voice_over_rounded),
                  const SizedBox(height: 8),
                  ...VoiceReciterHelper.availableStyles.map((item) {
                    final isPicked = _style == item['id'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() => _style = item['id']);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isPicked
                                ? AppTheme.accent.withValues(alpha: 0.16)
                                : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isPicked ? AppTheme.accent : AppTheme.surfaceLight,
                              width: isPicked ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPicked ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                color: isPicked ? AppTheme.accent : Colors.white38,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item['title'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isPicked ? FontWeight.bold : FontWeight.w600,
                                            color: isPicked ? Colors.white : Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (item['badge'] != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isPicked
                                                  ? AppTheme.accent.withValues(alpha: 0.25)
                                                  : Colors.white10,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item['badge'],
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: isPicked ? AppTheme.accent : Colors.white54,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item['subtitle'],
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isPicked ? Colors.white70 : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),

                  // 2. Language / Accent
                  _sectionHeader('Voice Accent & Language', Icons.language_rounded),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: VoiceReciterHelper.availableLanguages.map((lang) {
                      final isPicked = _language == lang['code'];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(lang['flag']!, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              lang['name']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isPicked ? FontWeight.bold : FontWeight.w500,
                                color: isPicked ? Colors.white : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        selected: isPicked,
                        selectedColor: AppTheme.accent,
                        backgroundColor: AppTheme.surfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isPicked ? AppTheme.accent : AppTheme.surfaceLight,
                          ),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _language = lang['code']!);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 3. Speed & Tempo
                  _sectionHeader('Recital Speed: ${_speed.toStringAsFixed(2)}x', Icons.speed_rounded),
                  const SizedBox(height: 4),
                  Slider(
                    value: _speed,
                    min: 0.28,
                    max: 0.72,
                    divisions: 11,
                    activeColor: AppTheme.accent,
                    inactiveColor: AppTheme.surfaceLight,
                    onChanged: (val) => setState(() => _speed = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: VoiceReciterHelper.speedPresets.map((preset) {
                      final double pVal = preset['val'];
                      final bool isSelected = (_speed - pVal).abs() < 0.04;
                      return GestureDetector(
                        onTap: () => setState(() => _speed = pVal),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accent.withValues(alpha: 0.2) : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppTheme.accent : AppTheme.surfaceLight,
                            ),
                          ),
                          child: Text(
                            preset['label'],
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white60,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 4. Voice Pitch
                  _sectionHeader('Voice Pitch: ${_pitch.toStringAsFixed(1)}x', Icons.tune_rounded),
                  const SizedBox(height: 4),
                  Slider(
                    value: _pitch,
                    min: 0.7,
                    max: 1.3,
                    divisions: 6,
                    activeColor: AppTheme.cyan,
                    inactiveColor: AppTheme.surfaceLight,
                    onChanged: (val) => setState(() => _pitch = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: VoiceReciterHelper.pitchPresets.map((preset) {
                      final double pVal = preset['val'];
                      final bool isSelected = (_pitch - pVal).abs() < 0.08;
                      return GestureDetector(
                        onTap: () => setState(() => _pitch = pVal),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.cyan.withValues(alpha: 0.2) : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppTheme.cyan : AppTheme.surfaceLight,
                            ),
                          ),
                          child: Text(
                            preset['label'],
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white60,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 5. Loop / Repeat Mode
                  _sectionHeader('Loop & Repeat Mode', Icons.repeat_rounded),
                  const SizedBox(height: 8),
                  Row(
                    children: VoiceReciterHelper.repeatModes.map((mode) {
                      final isPicked = _repeatMode == mode['id'];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () => setState(() => _repeatMode = mode['id']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: isPicked ? const Color(0xFFA855F7).withValues(alpha: 0.2) : AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isPicked ? const Color(0xFFA855F7) : AppTheme.surfaceLight,
                                  width: isPicked ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    mode['id'] == 'row'
                                        ? Icons.repeat_one_rounded
                                        : (mode['id'] == 'table' ? Icons.repeat_rounded : Icons.arrow_forward_rounded),
                                    size: 16,
                                    color: isPicked ? const Color(0xFFA855F7) : Colors.white60,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    mode['label'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isPicked ? FontWeight.bold : FontWeight.normal,
                                      color: isPicked ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // 6. Quiz Thinking Pause (if Quiz mode is active)
                  if (_style == 'quiz') ...[
                    const SizedBox(height: 18),
                    _sectionHeader('Recall Pause Duration (Before Answer)', Icons.hourglass_bottom_rounded),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _pauseOptionChip(1.5, '1.5s (Fast Recall)'),
                        const SizedBox(width: 8),
                        _pauseOptionChip(2.0, '2.0s (Balanced)'),
                        const SizedBox(width: 8),
                        _pauseOptionChip(3.0, '3.0s (Relaxed)'),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Deck
          Row(
            children: [
              // Test Voice Button
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(
                    _isPlayingPreview ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                    color: AppTheme.accent,
                    size: 18,
                  ),
                  label: Text(
                    _isPlayingPreview ? 'Speaking...' : 'Test Voice',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 13),
                  ),
                  onPressed: _isPlayingPreview ? null : _playLiveTest,
                ),
              ),
              const SizedBox(width: 10),
              // Apply Settings Button
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Apply Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  ),
                  onPressed: _applyAndSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.accent),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _pauseOptionChip(double val, String label) {
    final isPicked = (_quizPause - val).abs() < 0.1;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _quizPause = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPicked ? AppTheme.gold.withValues(alpha: 0.18) : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPicked ? AppTheme.gold : AppTheme.surfaceLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isPicked ? FontWeight.bold : FontWeight.normal,
              color: isPicked ? AppTheme.gold : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
