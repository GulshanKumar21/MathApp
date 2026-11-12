import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../alarm/math_alarm_hub_screen.dart';
import '../admin/admin_panel_screen.dart';
import '../auth/auth_screen.dart';
import '../../widgets/voice_studio_modal.dart';
import '../../widgets/payment_checkout_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
        actions: [
          if (state.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.gold),
              tooltip: 'Admin Control Center',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen())),
            ),
          if (state.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              tooltip: 'Logout',
              onPressed: () async {
                await state.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, color: AppTheme.accent, size: 20),
                          SizedBox(width: 10),
                          Text('Logged out successfully.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
        children: [
          // 1. 👤 User Identity & Account Card
          _buildUserAccountCard(context, state),
          const SizedBox(height: 20),

          // 2. 🎯 Target Exam
          _buildSectionTitle('Target Exam', Icons.school_rounded),
          const SizedBox(height: 8),
          _buildTargetExamCard(context, state),
          const SizedBox(height: 20),

          // 3. 🎯 Daily Practice Goal
          _buildSectionTitle('Daily Practice Target', Icons.flag_rounded),
          const SizedBox(height: 8),
          _buildDailyGoalCard(context, state),
          const SizedBox(height: 20),

          // 4. ⏰ Alarm & Study Reminders
          _buildSectionTitle('Alarms & Reminders', Icons.alarm_rounded),
          const SizedBox(height: 8),
          _buildAlarmNavigationCard(context, state),
          const SizedBox(height: 20),

          // 5. 🎙️ Voice Coach Settings
          _buildSectionTitle('Voice Coach', Icons.record_voice_over_rounded),
          const SizedBox(height: 8),
          _buildVoiceCoachCard(context, state),
          const SizedBox(height: 20),

          // 6. 🌓 Display & Appearance
          _buildSectionTitle('Appearance', Icons.palette_rounded),
          const SizedBox(height: 8),
          _buildAppearanceCard(context, state),
          const SizedBox(height: 20),

          // 7. 🛡️ Data & Privacy
          _buildSectionTitle('Data & Privacy', Icons.storage_rounded),
          const SizedBox(height: 8),
          _buildDataManagementCard(context, state),
          const SizedBox(height: 20),

          // 8. 👑 Admin Control Center (Guarded: Only visible to authenticated Admin)
          if (state.isAdmin) ...[
            _buildAdminConsoleCard(context, state),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  // --- SECTION WIDGETS ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppTheme.primaryLight),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
            color: Colors.white70,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }

  // 1. User Account Card
  Widget _buildUserAccountCard(BuildContext context, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF10B981)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage('assets/images/prepvanta_icon_1024.png'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            state.userName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white54),
                          tooltip: 'Edit Name',
                          onPressed: () => _showEditNameDialog(context, state),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.userEmail,
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    if (state.isLoggedIn && state.userUid.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: state.userUid));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 2),
                              content: Row(
                                children: [
                                  Icon(Icons.copy_rounded, color: AppTheme.accent, size: 16),
                                  SizedBox(width: 8),
                                  Text('User ID copied to clipboard!'),
                                ],
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'UID: ${state.userUid.length > 12 ? "${state.userUid.substring(0, 10)}..." : state.userUid}',
                                style: const TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'monospace'),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy_rounded, size: 11, color: Colors.white38),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: state.isAdmin
                            ? AppTheme.gold.withValues(alpha: 0.25)
                            : (state.isPremium
                                ? AppTheme.gold.withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: state.isAdmin
                              ? AppTheme.gold
                              : (state.isPremium
                                  ? AppTheme.gold.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.15)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : (state.isPremium ? Icons.verified_rounded : Icons.person_outline_rounded),
                            size: 13,
                            color: (state.isAdmin || state.isPremium) ? AppTheme.gold : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.isAdmin
                                ? '👑 MASTER ADMIN'
                                : (state.isPremium ? 'PRO Lifetime Member' : 'Free Tier Aspirant'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: (state.isAdmin || state.isPremium) ? AppTheme.gold : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          // User Quick Stat Badges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _userStatPill('Streak', '${state.streakDays} Days', Icons.local_fire_department_rounded, AppTheme.gold),
                Container(width: 1, height: 22, color: AppTheme.surfaceLight),
                _userStatPill('Solved', '${state.totalQuestionsAttempted} Qs', Icons.check_circle_rounded, AppTheme.accent),
                Container(width: 1, height: 22, color: AppTheme.surfaceLight),
                _userStatPill('Accuracy', '${state.overallAccuracy.toStringAsFixed(1)}%', Icons.analytics_rounded, AppTheme.cyan),
              ],
            ),
          ),

          if (!state.isLoggedIn) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Sign In / Register Account', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              },
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (state.isAdmin) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                      label: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        state.setAdminStudentPreview(false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (!state.isPremium) ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      onPressed: () => _showUpgradeSheet(context),
                      child: const Text('Upgrade PRO ₹49', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: AppTheme.surfaceLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                  label: const Text('Sign Out', style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    await state.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, color: AppTheme.accent, size: 18),
                              SizedBox(width: 10),
                              Text('Logged out successfully.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _userStatPill(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.white54)),
          ],
        ),
      ],
    );
  }

  // 2. Target Exam Card
  Widget _buildTargetExamCard(BuildContext context, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded, color: AppTheme.primaryLight, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.targetExam,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  Text(
                    'Target Pace: ≤ ${state.targetExamPaceCutoff}s / question',
                    style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceElevated,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _showTargetExamPicker(context, state),
            child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 4. Alarm & Reminders Navigation Card
  Widget _buildAlarmNavigationCard(BuildContext context, AppStateProvider state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.alarm_on_rounded, color: Color(0xFFEF4444), size: 20),
            ),
            title: const Text(
              'Math Wake-Up Alarm',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MathAlarmHubScreen()));
            },
          ),
          const Divider(height: 1, color: AppTheme.surfaceLight),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppTheme.gold, size: 20),
            ),
            title: const Text(
              'Daily Notification Limit',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              state.dailyNotificationLimit == 0
                  ? 'Unlimited question alerts per day (No cap)'
                  : '${state.dailyNotificationLimit} question alerts max per day (Prevents fatigue)',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                state.dailyNotificationLimit == 0 ? 'Unlimited' : '${state.dailyNotificationLimit} / Day',
                style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
            onTap: () => _showNotificationLimitPicker(context, state),
          ),
        ],
      ),
    );
  }

  // 5. Voice Coach Studio Card
  Widget _buildVoiceCoachCard(BuildContext context, AppStateProvider state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.record_voice_over_rounded, color: AppTheme.primaryLight, size: 20),
        ),
        title: const Text('Voice Coach Studio', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Speed: ${state.ttsSpeechRate.toStringAsFixed(2)}x • ${state.ttsLanguage} • ${state.ttsRecitalStyle}',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
        onTap: () => VoiceStudioModal.show(context),
      ),
    );
  }

  // 6. Daily Goal Card
  Widget _buildDailyGoalCard(BuildContext context, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Question Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(
                '${state.dailyTarget} Questions / Day',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent),
              ),
            ],
          ),
          Slider(
            value: state.dailyTarget.toDouble(),
            min: 10,
            max: 100,
            divisions: 9,
            activeColor: AppTheme.accent,
            inactiveColor: AppTheme.surfaceLight,
            onChanged: (val) {
              state.updateDailyTarget(val.toInt());
            },
          ),
        ],
      ),
    );
  }

  // 6. Appearance Card
  Widget _buildAppearanceCard(BuildContext context, AppStateProvider state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: SwitchListTile(
        title: const Text('AMOLED Ultra Black Mode', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: const Text('Pure black theme for AMOLED displays', style: TextStyle(color: Colors.white54, fontSize: 11)),
        value: state.amoledBlackMode,
        activeThumbColor: AppTheme.accent,
        onChanged: (val) {
          state.toggleAmoledBlack(val);
        },
      ),
    );
  }

  // 7. Data & Privacy Management Card
  Widget _buildDataManagementCard(BuildContext context, AppStateProvider state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          // Reset Today's Count
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restart_alt_rounded, color: AppTheme.gold, size: 20),
            ),
            title: const Text('Restart Today\'s Sprint Counter', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('${state.todayAttempted} / ${state.dailyTarget} Qs completed', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Text('${state.todayAttempted} Qs', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            onTap: () => _showResetTodayDialog(context, state),
          ),
          const Divider(height: 1, color: AppTheme.surfaceLight),

          // Clear Mistakes
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cleaning_services_rounded, color: Color(0xFFEF4444), size: 20),
            ),
            title: const Text('Clear Saved Mistakes History', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('${state.mistakes.length} mistakes saved in revision notebook', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: state.mistakes.isNotEmpty ? const Color(0xFFEF4444).withValues(alpha: 0.15) : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: state.mistakes.isNotEmpty ? const Color(0xFFEF4444).withValues(alpha: 0.3) : AppTheme.surfaceLight),
              ),
              child: Text('${state.mistakes.length} saved', style: TextStyle(color: state.mistakes.isNotEmpty ? const Color(0xFFEF4444) : Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            onTap: () => _showClearMistakesDialog(context, state),
          ),
          const Divider(height: 1, color: AppTheme.surfaceLight),

          // Factory Reset All Progress
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFDC2626), size: 20),
            ),
            title: const Text('Factory Reset All Progress', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Reset history, streak, and target counter to zero', style: TextStyle(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
            onTap: () => _showResetAllDataDialog(context, state),
          ),
          const Divider(height: 1, color: AppTheme.surfaceLight),

          // Restore Purchases (Cryptographically verified)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restore_rounded, color: AppTheme.gold, size: 20),
            ),
            title: const Text('Restore Purchases', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Restore PRO Lifetime access across devices', style: TextStyle(color: Colors.white54, fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: const Text('Verify', style: TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            onTap: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Dialog(
                  backgroundColor: AppTheme.surfaceElevated,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.gold),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Verifying Play Store purchase & cloud license...',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              final restored = await state.restorePurchases();
              if (context.mounted) Navigator.pop(context); // close loader
              if (context.mounted) {
                if (restored) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF065F46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
                      ),
                      content: const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PRO Membership Verified & Restored! 🎉',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'All 6 premium modules unlocked for this account.',
                                  style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                      ),
                      content: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No Previous ₹49 Purchase Found',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'No active PRO license found for this Google ID. Tap "Unlock PRO" to activate.',
                                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      action: SnackBarAction(
                        label: 'Unlock PRO',
                        textColor: AppTheme.gold,
                        onPressed: () => _showUpgradeSheet(context),
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(height: 1, color: AppTheme.surfaceLight),

          // Privacy Policy & Terms (Google Play Requirement)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.privacy_tip_outlined, color: AppTheme.cyan, size: 20),
            ),
            title: const Text('Privacy Policy & Data Safety', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Review offline storage, data retention, and terms', style: TextStyle(color: Colors.white54, fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
            onTap: () => _showPrivacyPolicyModal(context),
          ),

          if (state.isLoggedIn) ...[
            const Divider(height: 1, color: AppTheme.surfaceLight),

            // Delete Account & Personal Data (Google Play Requirement)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.no_accounts_rounded, color: Color(0xFFEF4444), size: 20),
              ),
              title: const Text('Delete Account & Personal Data', style: TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text('Permanently erase account, mistakes, and cloud profile', style: TextStyle(color: Colors.white54, fontSize: 11)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: const Text('Permanent', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              onTap: () => _showDeleteAccountDialog(context, state),
            ),
          ],
        ],
      ),
    );
  }

  // --- DIALOGS & BOTTOM SHEETS ---

  void _showTargetExamPicker(BuildContext context, AppStateProvider state) {
    final exams = [
      {'name': 'SSC CGL & CHSL', 'pace': '≤ 3.5s/Q', 'icon': Icons.school_rounded, 'desc': 'Tables to 25, Squares to 50, Cubes to 30'},
      {'name': 'Banking (IBPS/SBI PO)', 'pace': '≤ 2.2s/Q', 'icon': Icons.account_balance_rounded, 'desc': 'Rapid Simplification, % Fractions, Decimals'},
      {'name': 'CAT & MBA', 'pace': '≤ 4.5s/Q', 'icon': Icons.trending_up_rounded, 'desc': 'Multiplication tricks, Approximation hacks'},
      {'name': 'Railways & Defense', 'pace': '≤ 4.0s/Q', 'icon': Icons.train_rounded, 'desc': 'Core speed math, Fast additions & tables'},
      {'name': 'Speed Math Master', 'pace': '≤ 2.0s/Q', 'icon': Icons.psychology_rounded, 'desc': 'Lightning-fast Vedic math & flash memory'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Your Target Exam',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Speedometer dials and question generators calibrate to your selection.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              ...exams.map((item) {
                String examName = item['name'] as String;
                bool isSelected = state.targetExam == examName;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryLight.withValues(alpha: 0.15) : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(item['icon'] as IconData, color: isSelected ? AppTheme.accent : Colors.white70),
                    title: Text(
                      examName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white70, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${item['pace']} • ${item['desc']}',
                      style: TextStyle(fontSize: 11, color: isSelected ? AppTheme.accent : Colors.white38),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.accent) : null,
                    onTap: () {
                      state.updateTargetExam(examName);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.school_rounded, color: AppTheme.accent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Target set to $examName! Benchmarks calibrated.', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationLimitPicker(BuildContext context, AppStateProvider state) {
    final limits = [
      {'limit': 5, 'name': '5 Alerts / Day', 'desc': 'Light practice • Ideal for casual learners', 'icon': Icons.spa_rounded},
      {'limit': 10, 'name': '10 Alerts / Day (Recommended)', 'desc': 'Balanced retention • Industry standard pacing', 'icon': Icons.star_rounded},
      {'limit': 15, 'name': '15 Alerts / Day', 'desc': 'Moderate pace • Regular mistake correction', 'icon': Icons.fitness_center_rounded},
      {'limit': 20, 'name': '20 Alerts / Day', 'desc': 'Intensive drill • For high-pressure exam aspirants', 'icon': Icons.bolt_rounded},
      {'limit': 0, 'name': 'Unlimited Alerts', 'desc': 'No daily cap • Receive every question recall instantly', 'icon': Icons.all_inclusive_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Notification Frequency Capping',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Limits how many question recalls you receive per day to prevent fatigue.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              ...limits.map((item) {
                int limitVal = item['limit'] as int;
                String limitName = item['name'] as String;
                bool isSelected = state.dailyNotificationLimit == limitVal;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.gold.withValues(alpha: 0.15) : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppTheme.gold : AppTheme.surfaceLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(item['icon'] as IconData, color: isSelected ? AppTheme.gold : Colors.white70),
                    title: Text(
                      limitName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white70, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      item['desc'] as String,
                      style: TextStyle(fontSize: 11, color: isSelected ? AppTheme.gold : Colors.white38),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.gold) : null,
                    onTap: () {
                      state.updateDailyNotificationLimit(limitVal);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded, color: AppTheme.gold, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Daily notification limit set to $limitName!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, AppStateProvider state) {
    final ctrl = TextEditingController(text: state.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceLight, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: AppTheme.primaryLight, size: 20),
            SizedBox(width: 8),
            Text('Edit Aspirant Name', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Your Name',
            hintText: 'e.g. Rahul Sharma',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryLight),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.surfaceLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryLight, width: 1.5)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                state.updateUserName(ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showResetTodayDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceLight, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppTheme.gold, size: 22),
            SizedBox(width: 8),
            Text('Restart Today\'s Sprint?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will reset your solved count for today back to 0 so you can start a fresh daily target sprint. Your overall streak and history will remain safe.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              state.resetTodayProgress();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.restart_alt_rounded, color: AppTheme.gold, size: 20),
                      SizedBox(width: 10),
                      Text('Today\'s sprint counter reset to 0!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Reset Today', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClearMistakesDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceLight, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.cleaning_services_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text('Clear Saved Mistakes?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will clear all missed calculations from your Revision Notebook and cancel pending recall notifications. You can start with a fresh slate.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              state.clearAllMistakes();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.cleaning_services_rounded, color: AppTheme.accent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Mistake history cleared & pending alarms cancelled!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showResetAllDataDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text('Factory Reset All Data?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will permanently reset your quiz history, streak count, today\'s solved counter, and clear all saved mistakes so you can begin completely fresh.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              state.resetAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('All progress and history have been reset to fresh start!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Reset Everything', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 14),
              const Text(
                'Unlock PrepVanta PRO',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                '₹49 One-Time Payment • Lifetime Access to All Pro Functions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Pro Features List
              _buildProFeatureRow(
                icon: Icons.electric_bolt_rounded,
                color: Colors.amberAccent,
                title: '⚡ Hard-On Pro Multipliers (17×45+)',
                desc: 'Master 2-Digit × 2-Digit cross calculations with Vedic trick explanations.',
              ),
              _buildProFeatureRow(
                icon: Icons.timer_rounded,
                color: Colors.blueAccent,
                title: '🎯 Strict 2.5s Rapid Exam Mocks',
                desc: 'Uncapped access to SSC CGL, Bank PO, Railways & CAT 2.5s speed drills.',
              ),
              _buildProFeatureRow(
                icon: Icons.percent_rounded,
                color: Colors.greenAccent,
                title: '📈 Fraction & Pythagorean Triples',
                desc: 'Instant recall modules for 1/2-1/25 conversions and exam-vital triples.',
              ),
              _buildProFeatureRow(
                icon: Icons.headphones_rounded,
                color: Colors.cyanAccent,
                title: '🎧 Voice & Audio Recital Studio',
                desc: 'Hands-free audio coaching with variable speed, accents and chanting formats inside each module.',
              ),
              _buildProFeatureRow(
                icon: Icons.picture_as_pdf_rounded,
                color: Colors.deepOrangeAccent,
                title: '🖨️ Unlimited PDF Cheat Sheet Export',
                desc: 'Print-ready high resolution summary tables & revision notebooks.',
              ),
              _buildProFeatureRow(
                icon: Icons.insights_rounded,
                color: Colors.purpleAccent,
                title: '📊 Deep AI Heatmap & Diagnostics',
                desc: 'Precision analytics identifying your exact calculation bottlenecks.',
              ),

              const SizedBox(height: 22),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  PaymentCheckoutSheet.show(context);
                },
                child: const Text(
                  'Unlock All PRO Functions for ₹49',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🛡️ Master Admin Console Card
  Widget _buildAdminConsoleCard(BuildContext context, AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.gold, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Control Portal',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Cloud Firestore live database & student metrics',
                      style: TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MASTER ACCESS',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Access real-time student mistake dossiers, manage dynamic question bank, monitor revenue ledger, and broadcast instant push notices.',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.dashboard_rounded, size: 18),
              label: const Text('Open Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 📜 Google Play Compliance: In-App Privacy Policy
  void _showPrivacyPolicyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.privacy_tip_rounded, color: AppTheme.cyan, size: 24),
                SizedBox(width: 10),
                Text(
                  'Privacy Policy & Data Safety',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'PrepVanta • Compliant with Google Play Developer Policies',
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('https://sites.google.com/view/prepvanta/home');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.open_in_browser_rounded, color: AppTheme.cyan, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live Policy: sites.google.com/view/prepvanta/home',
                        style: TextStyle(color: AppTheme.cyan, fontSize: 11.5, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_outward_rounded, color: AppTheme.cyan, size: 16),
                  ],
                ),
              ),
            ),
            const Divider(height: 20, color: AppTheme.surfaceLight),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _policySection(
                      '1. Overview',
                      'PrepVanta ("we", "app") is designed to help students improve mental arithmetic and calculation speed for competitive examinations (SSC, Banking, Railways, CAT). We respect your privacy and process personal data transparently in accordance with Google Play Developer Policies and global data safety standards.',
                    ),
                    _policySection(
                      '2. Information We Collect',
                      '• Account Credentials: When you sign up, we collect your name and email address solely for authentication.\n• Calculation & Performance Telemetry: Your quiz scores, response latency, accuracy %, and saved mistake lists are stored locally on your device and synced with encrypted Firebase Cloud Firestore.\n• Payment Information: In-app purchases for the ₹49 Lifetime PRO license are processed securely via Google Play Billing. We never receive or store your credit/debit card numbers or bank passwords.',
                    ),
                    _policySection(
                      '3. Android System Permissions & Purpose',
                      '• INTERNET & ACCESS_NETWORK_STATE: Sync study progress with Firebase Cloud Firestore.\n• POST_NOTIFICATIONS: Interactive spaced-repetition calculation challenges and mistake recall reminders.\n• SCHEDULE_EXACT_ALARM: Schedule scientific 1-hour and 3-hour spaced recall reminders.\n• VIBRATE: Haptic feedback during speed drills.\n• RECEIVE_BOOT_COMPLETED: Restore reminders after phone reboot.\n• BILLING: Google Play In-App Purchase for PrepVanta PRO.',
                    ),
                    _policySection(
                      '4. Third-Party Services Used',
                      'We use Google Play Services, Google Play In-App Billing, and Google Firebase (Authentication & Cloud Firestore). All third-party services comply with strict Google privacy and security standards.',
                    ),
                    _policySection(
                      '5. How We Use Data',
                      '• To compute your AI Heatmap diagnostics and weakness recommendations.\n• To maintain your streak and leaderboard rankings.\n• To schedule exact math alarm wakeups and spaced-repetition calculation drills.\n• We do NOT sell, lease, or monetize your personal data to any third-party advertisers.',
                    ),
                    _policySection(
                      '6. Security & Cryptographic Protection',
                      'All communications between the app and cloud servers are encrypted via HTTPS/TLS. In-app purchase verification employs SHA-256 HMAC cryptographic signatures to prevent tampering.',
                    ),
                    _policySection(
                      '7. Children’s Privacy (COPPA Compliance)',
                      'PrepVanta is intended for students and competitive exam aspirants. We do not knowingly collect personal identifiable information from children under 13 years of age.',
                    ),
                    _policySection(
                      '8. Account & Data Deletion',
                      'Under Google Play User Data policies, you hold full rights to permanently delete your account and all associated performance dossiers at any time directly through the "Delete Account & Personal Data" setting in this app.',
                    ),
                    _policySection(
                      '9. Official Policy Link & Support',
                      'Official Hosted Privacy Policy: https://sites.google.com/view/prepvanta/home\n\nIf you have questions regarding this Privacy Policy or wish to request data erasure, contact developer Gulshan Kumar at: gulshankumar.dev01@gmail.com',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.cyan,
                      side: const BorderSide(color: AppTheme.cyan),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse('https://sites.google.com/view/prepvanta/home');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.language_rounded, size: 18),
                    label: const Text('Open Web Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('I Understand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _policySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.gold)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }

  // 🛡️ Google Play Compliance: Permanent Account Deletion Dialog
  void _showDeleteAccountDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Text('Delete Account?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will permanently delete your account, authentication credentials, calculation history, and saved mistake dossiers from both this device and Google Firebase Cloud servers.\n\nThis action cannot be undone.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final deleted = await state.deleteUserAccount();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF7F1D1D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    content: Row(
                      children: [
                        const Icon(Icons.no_accounts_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            deleted
                                ? 'Your account and personal data have been permanently deleted.'
                                : 'Account deletion completed locally.',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
