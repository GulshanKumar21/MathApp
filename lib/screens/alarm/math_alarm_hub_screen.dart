import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/swiggy_flipkart_section_bar.dart';
import 'math_alarm_ringing_screen.dart';

class MathAlarmHubScreen extends StatefulWidget {
  final bool isRootTab;
  const MathAlarmHubScreen({super.key, this.isRootTab = false});

  @override
  State<MathAlarmHubScreen> createState() => _MathAlarmHubScreenState();
}

class _MathAlarmHubScreenState extends State<MathAlarmHubScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isEnabled = state.mathAlarmEnabled;
    final int hour = state.mathAlarmHour;
    final int min = state.mathAlarmMinute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final String hourStr = displayHour.toString().padLeft(2, '0');
    final String minStr = min.toString().padLeft(2, '0');

    // Countdown calculation
    String countdownText = 'Alarm is currently off';
    String timeRemainingBadge = 'OFF';
    if (isEnabled) {
      final now = DateTime.now();
      DateTime target = DateTime(now.year, now.month, now.day, hour, min);
      if (target.isBefore(now)) target = target.add(const Duration(days: 1));
      final diff = target.difference(now);
      timeRemainingBadge = '${diff.inHours}h ${diff.inMinutes % 60}m';
      countdownText = 'Rings in $timeRemainingBadge (${DateFormat('EEEE').format(target)})';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isRootTab,
        backgroundColor: const Color(0xFF070B14),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Math Wake-Up Alarm',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
                Text(
                  'Anti-Snooze Protocol • Solve to Dismiss',
                  style: TextStyle(fontSize: 10.5, color: Colors.white54, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
        children: [
          // 0. Top 3 Tabs (Math | Alarm | English)
          if (widget.isRootTab) ...[
            const SwiggyFlipkartSectionBar(),
            const SizedBox(height: 12),
          ],

          // 1. SWIGGY-STYLE HERO ALARM CLOCK CARD
          _buildHeroAlarmCard(
            context,
            state,
            isEnabled: isEnabled,
            hourStr: hourStr,
            minStr: minStr,
            period: period,
            countdownText: countdownText,
            timeRemainingBadge: timeRemainingBadge,
          ),
          const SizedBox(height: 18),

          // 2. QUICK TIME PRESETS (SWIGGY FAST-ORDER STYLE PILLS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'QUICK MORNING TIMES',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Colors.white60,
                ),
              ),
              Text(
                '1-Tap Set',
                style: TextStyle(fontSize: 11, color: const Color(0xFFEF4444).withValues(alpha: 0.9), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _presetPill(context, state, hour: 5, min: 0, title: '5:00 AM', tag: 'EARLY BIRD'),
                _presetPill(context, state, hour: 6, min: 0, title: '6:00 AM', tag: 'RECOMMENDED'),
                _presetPill(context, state, hour: 6, min: 30, title: '6:30 AM', tag: 'EXAM DRILL'),
                _presetPill(context, state, hour: 7, min: 0, title: '7:00 AM', tag: 'STANDARD'),
                _presetPill(context, state, hour: 8, min: 0, title: '8:00 AM', tag: 'POWER WAKE'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. HOW THE ANTI-SNOOZE PROTOCOL WORKS (SWIGGY STEP-BY-STEP TRACKER)
          _buildAntiSnoozeStepsCard(),
          const SizedBox(height: 20),

          // 4. TEST ALARM ACTION BUTTONS (SWIGGY DUAL ACTION BUTTONS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'INSTANT SOUND & SNOOZE TEST',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Colors.white60,
                ),
              ),
              Text(
                'Safe Test',
                style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                  label: const Text(
                    'Ring Now',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MathAlarmRingingScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF0D9488), width: 1.3),
                    backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.timer_rounded, color: Color(0xFF2DD4BF), size: 19),
                  label: const Text(
                    'Ring in 10s',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await NotificationService().scheduleQuickTestAlarm(
                      seconds: 10,
                      label: 'Math Wake-Up Alarm',
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF0D9488),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        content: const Row(
                          children: [
                            Icon(Icons.alarm_on_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '⏰ Alarm scheduled for 10 seconds! Lock phone or wait to test siren.',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. DAILY PRACTICE REMINDERS & HOURLY CHALLENGES
          _buildDailyPracticeRemindersSection(context, state),
          const SizedBox(height: 20),

          // 6. SWIGGY FAQ / BACKGROUND ALARM HELPER
          _buildBackgroundPermissionGuide(),
        ],
      ),
    );
  }

  Widget _buildDailyPracticeRemindersSection(BuildContext context, AppStateProvider state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'DAILY STUDY REMINDERS & HOURLY ALERTS',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.white60,
              ),
            ),
            Text(
              'Spaced Recall',
              style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.surfaceLight),
          ),
          child: Column(
            children: [
              // 1. Daily Inactivity & Streak Reminder
              SwitchListTile(
                title: const Text('Daily Practice Reminder', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  state.notificationsEnabled
                      ? 'Scheduled at ${state.reminderHour.toString().padLeft(2, '0')}:${state.reminderMinute.toString().padLeft(2, '0')} ${state.reminderHour >= 12 ? 'PM' : 'AM'} (Tap clock to edit)'
                      : 'Off • Reminds you so your daily streak never breaks',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                value: state.notificationsEnabled,
                activeThumbColor: AppTheme.accent,
                onChanged: (v) {
                  state.toggleNotifications(v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(v ? '🔔 Practice reminder enabled' : '🔕 Reminder disabled')),
                  );
                },
                secondary: IconButton(
                  icon: const Icon(Icons.access_time_rounded, color: AppTheme.gold),
                  tooltip: 'Change Reminder Time',
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: state.reminderHour, minute: state.reminderMinute),
                    );
                    if (picked != null) {
                      state.updateReminderTime(picked.hour, picked.minute);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('⏰ Reminder set to ${picked.format(context)}')),
                        );
                      }
                    }
                  },
                ),
              ),
              const Divider(height: 1, color: AppTheme.surfaceLight),

              // 2. Mistake Spaced Repetition Interval
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mistake Recall Frequency',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        Text('Auto Spaced Repetition', style: TextStyle(fontSize: 10, color: AppTheme.accent)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [1, 2, 4].map((hours) {
                        bool isSelected = state.recallIntervalHours == hours;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => state.updateRecallIntervalHours(hours),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.accent.withValues(alpha: 0.2) : AppTheme.surfaceElevated,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.accent : AppTheme.surfaceLight,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  '$hours ${hours == 1 ? 'Hour' : 'Hours'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppTheme.accent : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.surfaceLight),

              // 3. 1-Hour Speed Math Challenge
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flash_on_rounded, color: AppTheme.gold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '1-Hour Speed Math Challenge',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                          Text(
                            'Hourly dynamic challenge alert with wrong questions priority',
                            style: TextStyle(fontSize: 10.5, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        NotificationService().triggerInstantHourlyChallenge(
                          userName: state.userName.isNotEmpty ? state.userName : 'Aspirant',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.notifications_active_rounded, color: AppTheme.gold),
                                SizedBox(width: 10),
                                Expanded(child: Text('🔔 1-Hour challenge notification triggered! Check your notification bar.')),
                              ],
                            ),
                            backgroundColor: Color(0xFF1E3A8A),
                          ),
                        );
                      },
                      child: const Text('Test Alert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroAlarmCard(
    BuildContext context,
    AppStateProvider state, {
    required bool isEnabled,
    required String hourStr,
    required String minStr,
    required String period,
    required String countdownText,
    required String timeRemainingBadge,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: isEnabled ? _pulseAnimation.value : 1.0,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? const [Color(0xFF2A0D15), Color(0xFF161E31), Color(0xFF0F1524)]
                : const [Color(0xFF131A2B), Color(0xFF0B101D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFEF4444).withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isEnabled
                  ? const Color(0xFFEF4444).withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.4),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Status Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: isEnabled ? const Color(0xFF10B981) : Colors.white38,
                        shape: BoxShape.circle,
                        boxShadow: isEnabled
                            ? [
                                const BoxShadow(
                                  color: Color(0xFF10B981),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEnabled ? 'ACTIVE • SNOOZE-PROOF' : 'ALARM DISABLED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isEnabled ? const Color(0xFF34D399) : Colors.white54,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isEnabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFFEF4444),
                  inactiveThumbColor: Colors.white60,
                  inactiveTrackColor: Colors.white12,
                  onChanged: (val) {
                    HapticFeedback.mediumImpact();
                    state.toggleMathAlarm(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Large Swiggy Clock Display
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _pickTime(context, state),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isEnabled
                        ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$hourStr:$minStr',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            height: 1.0,
                            color: isEnabled ? Colors.white : Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEnabled ? const Color(0xFFEF4444) : Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            period,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isEnabled ? const Color(0xFFFCA5A5) : Colors.white38,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          countdownText,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isEnabled ? const Color(0xFFFCA5A5) : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Change Alarm Time Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                label: const Text(
                  'Change Alarm Time',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                onPressed: () => _pickTime(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetPill(
    BuildContext context,
    AppStateProvider state, {
    required int hour,
    required int min,
    required String title,
    required String tag,
  }) {
    final bool isSelected = state.mathAlarmEnabled &&
        state.mathAlarmHour == hour &&
        state.mathAlarmMinute == min;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          state.setMathAlarm(hour: hour, minute: min, enabled: true);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF131929),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFEF4444) : Colors.white12,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tag,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white70 : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAntiSnoozeStepsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: Color(0xFFFBBF24), size: 20),
              SizedBox(width: 8),
              Text(
                'Anti-Snooze Protocol',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _stepRow(
            number: '1',
            title: 'Siren Rings Continuously',
            subtitle: 'Loud alarm rings at your exact time. Cannot be bypassed by volume down.',
            icon: Icons.volume_up_rounded,
          ),
          const Divider(height: 20, color: Colors.white10),
          _stepRow(
            number: '2',
            title: 'Tap to Pause Siren (35 Seconds)',
            subtitle: 'Siren mutes automatically so you can focus on calculating without panic.',
            icon: Icons.pause_circle_rounded,
          ),
          const Divider(height: 20, color: Colors.white10),
          _stepRow(
            number: '3',
            title: 'Solve 5 Math Questions to Turn Off',
            subtitle: 'Any wrong answer re-triggers the siren. Solve 5 to completely silence it!',
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }

  Widget _stepRow({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Icon(icon, color: const Color(0xFFEF4444), size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundPermissionGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 20),
              SizedBox(width: 8),
              Text(
                'What to do if alarm does not ring when app is closed?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'For the alarm to ring reliably on Android 13/14 even if the app is swiped away or the phone is locked, ensure these 2 settings are enabled:\n\n'
            '1. Settings > Apps > Math Speed Practice > Allow "Alarms & Reminders" permission.\n'
            '2. Battery > Set "Battery Optimization" / "Background restriction" to "Unrestricted" / "Don\'t optimize" (so the system does not kill background alarms).',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, AppStateProvider state) async {
    final initial = TimeOfDay(hour: state.mathAlarmHour, minute: state.mathAlarmMinute);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEF4444),
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      state.setMathAlarm(
        hour: picked.hour,
        minute: picked.minute,
        enabled: true,
      );
      if (!context.mounted) return;
      final dt = DateTime(2026, 1, 1, picked.hour, picked.minute);
      final formatted = DateFormat('hh:mm a').format(dt);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text('⏰ Alarm set for $formatted'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
