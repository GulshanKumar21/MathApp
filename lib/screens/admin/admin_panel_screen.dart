import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../services/backend_service.dart';
import '../../services/cloud_firestore_sync_service.dart';
import '../../services/notification_service.dart';
import '../auth/auth_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String _activeSection = 'all'; // 'all', 'mistakes', 'broadcasts', 'questions', 'pdfs', 'users'
  String _selectedMistakeFilter = 'all';
  String _selectedQuestionFilter = 'all';
  int _usersSubTab = 0; // 0 = Registered Users, 1 = Transactions

  final TextEditingController _studentSearchCtrl = TextEditingController();
  final TextEditingController _questionSearchCtrl = TextEditingController();
  final TextEditingController _userSearchCtrl = TextEditingController();
  final TextEditingController _pdfSearchCtrl = TextEditingController();

  final TextEditingController _pushTitleCtrl = TextEditingController(text: '⚡ Daily Speed Booster!');
  final TextEditingController _pushBodyCtrl = TextEditingController(
    text: 'Practice 5 minutes today to keep your streak alive and sharpen your calculations.',
  );
  String _targetAudience = 'All Students';

  @override
  void initState() {
    super.initState();
    // Auto-fetch all live data from Firebase Cloud Firestore upon opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().syncAllAdminDataFromCloud();
    });
  }

  @override
  void dispose() {
    _studentSearchCtrl.dispose();
    _questionSearchCtrl.dispose();
    _userSearchCtrl.dispose();
    _pdfSearchCtrl.dispose();
    _pushTitleCtrl.dispose();
    _pushBodyCtrl.dispose();
    super.dispose();
  }

  void _showExitOrSwitchModal(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Workspace Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text('Choose where you want to navigate:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove_red_eye_rounded, color: AppTheme.accent),
                ),
                title: const Text('Preview Student App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('View and test practice modules as an aspirant', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  state.setAdminStudentPreview(true);
                },
              ),
              const Divider(color: AppTheme.surfaceLight),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                ),
                title: const Text('Sign Out from Admin', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                subtitle: const Text('End admin session and return to Login screen', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmSignOut(context, state);
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.surfaceLight),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Stay in Admin Portal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Sign Out Admin?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out from the Admin Control Center?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    if (!state.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: AppTheme.surfaceElevated,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gpp_bad_rounded, size: 64, color: Colors.redAccent),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Unauthorized Admin Access',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'This workspace is strictly reserved for authenticated administrators. Please log in with admin credentials.',
                  style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Return to Safe Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitOrSwitchModal(context, state);
      },
      child: Scaffold(
        drawer: _buildAdminDrawer(context, state),
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.menu_rounded, color: AppTheme.gold, size: 20),
              ),
              tooltip: 'Open Menu (☰)',
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getActiveSectionTitle(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getActiveSectionSubtitle(),
                style: const TextStyle(fontSize: 10, color: Colors.white60),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            // Sync with Cloud
            IconButton(
              icon: state.isAdminSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                    )
                  : const Icon(Icons.sync_rounded, color: AppTheme.accent),
              tooltip: 'Sync Cloud Firestore Data',
              onPressed: () async {
                await state.syncAllAdminDataFromCloud();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.cloud_done_rounded, color: AppTheme.accent),
                          SizedBox(width: 8),
                          Text('Live Cloud data synchronized successfully!'),
                        ],
                      ),
                      backgroundColor: Color(0xFF065F46),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
            // Student Mode Preview button
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white70),
              tooltip: 'Preview Student View',
              onPressed: () {
                state.setAdminStudentPreview(true);
              },
            ),
            // Sign Out button
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: 'Sign Out Admin',
              onPressed: () => _confirmSignOut(context, state),
            ),
          ],
        ),
        body: Column(
          children: [
            if (state.isAdminSyncing)
              const LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
              ),
            Expanded(
              child: _buildMainView(state),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION TITLE & SUBTITLE HELPERS
  // ==========================================
  String _getActiveSectionTitle() {
    switch (_activeSection) {
      case 'users':
        return 'Students & Subscriptions';
      case 'mistakes':
        return 'Student Weak Areas';
      case 'broadcasts':
        return 'Send Notifications';
      case 'questions':
        return 'Questions Bank';
      case 'pdfs':
        return 'Study Notes & PDFs';
      case 'all':
      default:
        return 'Admin Dashboard';
    }
  }

  String _getActiveSectionSubtitle() {
    switch (_activeSection) {
      case 'users':
        return 'Tap ☰ menu • View users & grant PRO';
      case 'mistakes':
        return 'Tap ☰ menu • Mistakes analytics';
      case 'broadcasts':
        return 'Tap ☰ menu • Send notices & alerts';
      case 'questions':
        return 'Tap ☰ menu • Manage practice questions';
      case 'pdfs':
        return 'Tap ☰ menu • Upload & view study notes';
      case 'all':
      default:
        return 'Tap ☰ menu • Live Cloud connected';
    }
  }

  // ==========================================
  // MODERN ADMIN DRAWER (SIDE NAVIGATION)
  // ==========================================
  Widget _buildAdminDrawer(BuildContext context, AppStateProvider state) {
    final allAnalytics = state.studentMistakeAnalytics;
    final int totalMistakes = allAnalytics.fold(0, (sum, s) => sum + s.totalMistakes);

    final navItems = [
      {
        'id': 'all',
        'title': 'Dashboard Overview',
        'hindi': 'डैशबोर्ड (मुख्य पेज)',
        'icon': Icons.dashboard_rounded,
        'color': const Color(0xFF38BDF8),
        'badge': null,
      },
      {
        'id': 'users',
        'title': 'Students & Subscriptions',
        'hindi': 'विद्यार्थी और PRO पेमेंट्स',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF10B981),
        'badge': '${state.totalRegisteredUsers}',
      },
      {
        'id': 'mistakes',
        'title': 'Mistakes & Weak Areas',
        'hindi': 'छात्रों की गलतियाँ (Analytics)',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEF4444),
        'badge': totalMistakes > 0 ? '$totalMistakes' : null,
      },
      {
        'id': 'broadcasts',
        'title': 'Send Notifications',
        'hindi': 'पुश नोटिफिकेशन भेजें',
        'icon': Icons.campaign_rounded,
        'color': const Color(0xFFF59E0B),
        'badge': '${state.broadcasts.length}',
      },
      {
        'id': 'questions',
        'title': 'Questions Manager',
        'hindi': 'प्रश्न बैंक (Add / Edit MCQs)',
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFF8B5CF6),
        'badge': '${state.adminQuestions.length}',
      },
      {
        'id': 'pdfs',
        'title': 'Study Notes & PDFs',
        'hindi': 'स्टडी मटेरियल और नोट्स',
        'icon': Icons.picture_as_pdf_rounded,
        'color': const Color(0xFFEC4899),
        'badge': '${state.adminPdfMaterials.length}',
      },
    ];

    return Drawer(
      backgroundColor: const Color(0xFF0D1322),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Drawer Header (Clean Profile & Brand)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF131B2E),
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                        ),
                        child: const Icon(Icons.shield_rounded, color: AppTheme.gold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PrepVanta Admin',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.userEmail.isNotEmpty ? state.userEmail : 'Master Administrator',
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981), size: 13),
                        SizedBox(width: 6),
                        Text(
                          'Cloud Firestore Live Sync',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Text(
                      'CONTROL MODULES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 0.8),
                    ),
                  ),
                  ...navItems.map((item) {
                    final String id = item['id'] as String;
                    final bool isSelected = _activeSection == id;
                    final Color color = item['color'] as Color;
                    final IconData icon = item['icon'] as IconData;
                    final String title = item['title'] as String;
                    final String hindi = item['hindi'] as String;
                    final String? badge = item['badge'] as String?;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context); // Close Drawer
                            setState(() => _activeSection = id);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? color.withValues(alpha: 0.45) : Colors.transparent,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: isSelected ? color : color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isSelected ? Colors.white : color,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white70,
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        hindi,
                                        style: TextStyle(
                                          color: isSelected ? color : Colors.white38,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (badge != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: isSelected ? color : const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      badge,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF1E293B), indent: 8, endIndent: 8),
                  const SizedBox(height: 6),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Text(
                      'QUICK ACTIONS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 0.8),
                    ),
                  ),

                  // Preview Student Mode
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.remove_red_eye_rounded, color: AppTheme.accent, size: 18),
                    ),
                    title: const Text('Preview Student App', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    subtitle: const Text('विद्यार्थी व्यू टेस्ट करें', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    onTap: () {
                      Navigator.pop(context);
                      state.setAdminStudentPreview(true);
                    },
                  ),

                  // Sync Cloud Data
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sync_rounded, color: Color(0xFF10B981), size: 18),
                    ),
                    title: const Text('Sync All Data Now', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    subtitle: const Text('लाइव क्लाउड डेटा रिफ्रेश करें', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    onTap: () async {
                      Navigator.pop(context);
                      await state.syncAllAdminDataFromCloud();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Live Cloud data synchronized successfully!'),
                            backgroundColor: Color(0xFF065F46),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),

                  // Logout
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    ),
                    title: const Text('Sign Out Admin', style: TextStyle(color: Colors.redAccent, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    subtitle: const Text('एडमिन पैनल से बाहर निकलें', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmSignOut(context, state);
                    },
                  ),
                ],
              ),
            ),

            // 3. Drawer Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF090D16),
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PrepVanta Control Suite',
                    style: TextStyle(color: Colors.white38, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'v1.0.2+3',
                    style: TextStyle(color: AppTheme.gold, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP SECTION NAVIGATION CONTROLLER
  // ==========================================
  Widget _buildMainView(AppStateProvider state) {
    switch (_activeSection) {
      case 'mistakes':
        return _buildStudentMistakesTab(state);
      case 'broadcasts':
        return _buildPushNoticeTab(state);
      case 'questions':
        return _buildQuestionsTab(state);
      case 'pdfs':
        return _buildPdfMaterialsTab(state);
      case 'users':
        return _buildUsersAndPaymentsTab(state);
      case 'all':
      default:
        return _buildUnifiedDashboard(state);
    }
  }

  Widget _buildActiveSectionBanner(String sectionTitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Viewing $sectionTitle in deep focus mode.',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppTheme.gold,
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 14),
            label: const Text('All Dashboard', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () => setState(() => _activeSection = 'all'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: EXECUTIVE UNIFIED DASHBOARD
  // ==========================================
  Widget _buildUnifiedDashboard(AppStateProvider state) {
    return RefreshIndicator(
      onRefresh: () => state.syncAllAdminDataFromCloud(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Executive Master Command Hero Banner
          _buildCloudStatusCard(state),
          const SizedBox(height: 16),

          // 2. High-Impact Quick Action Hub (No confusing pills)
          _buildQuickActionHub(state),
          const SizedBox(height: 20),

          // 3. Platform Intelligence KPIs (6 Executive Cards Grid)
          _buildExecutiveKpis(state),
          const SizedBox(height: 22),

          // 4. Section Heading: Live Operations & Student Pulse
          Row(
            children: const [
              Icon(Icons.insights_rounded, size: 18, color: AppTheme.accent),
              SizedBox(width: 8),
              Text(
                'LIVE OPERATIONS & STUDENT PULSE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white70,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 5. Recent Student Weak Areas / Mistakes Snapshot
          _buildRecentMistakesSnapshot(state),
          const SizedBox(height: 14),

          // 6. Recent Revenue & Orders Snapshot
          _buildRecentTransactionsSnapshot(state),
          const SizedBox(height: 14),

          // 7. Content Bank & Study PDFs Snapshot
          _buildContentBankSnapshot(state),
          const SizedBox(height: 14),

          // 8. Latest Push Notification Studio Snapshot
          _buildLatestBroadcastSnapshot(state),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ==========================================
  // 1. EXECUTIVE MASTER COMMAND HERO CARD
  // ==========================================
  Widget _buildCloudStatusCard(AppStateProvider state) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Status Line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'CLOUD ENGINE ACTIVE',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10B981),
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 10.5, color: Colors.white54, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Headline & Admin Email
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.shield_rounded, color: AppTheme.gold, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PrepVanta Master Control',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.userEmail.isNotEmpty ? state.userEmail : 'Super Administrator (Full Cloud Access)',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),

          // Micro-Status Indicators Row & Sync Button
          Row(
            children: [
              _heroMicroChip(Icons.cloud_done_rounded, 'Firestore: Synced', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _heroMicroChip(Icons.lock_rounded, 'Role: Verified Admin', AppTheme.gold),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: state.isAdminSyncing
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sync_rounded, size: 14),
                label: Text(
                  state.isAdminSyncing ? 'Syncing...' : 'Sync Now',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                onPressed: state.isAdminSyncing ? null : () => state.syncAllAdminDataFromCloud(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMicroChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================
  // 2. HIGH-IMPACT QUICK ACTION HUB (4 CARDS + 2 AUX)
  // ==========================================
  Widget _buildQuickActionHub(AppStateProvider state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.bolt_rounded, size: 18, color: AppTheme.gold),
            SizedBox(width: 8),
            Text(
              'QUICK CONTROL ACTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2x2 Grid of Primary Actions
        Row(
          children: [
            Expanded(
              child: _actionGridCard(
                title: '+ Add Question',
                subtitle: 'New MCQ for SSC drills',
                icon: Icons.add_circle_outline_rounded,
                color: const Color(0xFF6366F1), // Indigo
                onTap: () => _showQuestionDialog(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionGridCard(
                title: '+ Upload PDF',
                subtitle: 'Formula book & notes',
                icon: Icons.picture_as_pdf_rounded,
                color: const Color(0xFFEC4899), // Pink
                onTap: () => _showAddPdfDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _actionGridCard(
                title: 'Send Notification',
                subtitle: 'Broadcast alert to all',
                icon: Icons.campaign_rounded,
                color: const Color(0xFFF59E0B), // Amber
                onTap: () => setState(() => _activeSection = 'broadcasts'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionGridCard(
                title: 'Students & PRO',
                subtitle: 'Grant lifetime PRO',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF10B981), // Emerald
                onTap: () => setState(() => _activeSection = 'users'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Auxiliary 2 Action Buttons (Bulk Upload & Preview)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Color(0xFF334155)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.flash_on_rounded, size: 15, color: AppTheme.gold),
                label: const Text('Bulk Questions Upload', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                onPressed: () => _showBulkQuestionDialog(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Color(0xFF334155)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.remove_red_eye_rounded, size: 15, color: AppTheme.accent),
                label: const Text('Preview Student App', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                onPressed: () => state.setAdminStudentPreview(true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          gradient: LinearGradient(
            colors: [
              AppTheme.surface,
              color.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. PLATFORM INTELLIGENCE KPIS (6 CARDS GRID)
  // ==========================================
  Widget _buildExecutiveKpis(AppStateProvider state) {
    final allAnalytics = state.studentMistakeAnalytics.where((s) {
      final email = s.studentEmail.toLowerCase();
      return !email.contains('admin') &&
          email != state.userEmail.toLowerCase() &&
          email != 'gulshankumar.dev01@gmail.com';
    }).toList();

    final int totalMistakes = allAnalytics.fold(0, (sum, s) => sum + s.totalMistakes);
    final int snoozedCount = allAnalytics.fold(
      0,
      (sum, s) => sum + s.mistakes.where((m) => m.snoozedUntil != null && DateTime.now().isBefore(m.snoozedUntil!)).length,
    );
    final int proCount = state.registeredUsers.where((u) => u['isPremium'] == true || u['isPro'] == true || (u['role']?.toString().toLowerCase() == 'pro')).length;
    final double totalRevenue = state.transactions.fold(0.0, (sum, tx) => sum + tx.amount);
    final double estimatedRevenue = totalRevenue > 0 ? totalRevenue : (proCount * 49.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.dashboard_customize_rounded, size: 18, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text(
              'PLATFORM EXECUTIVE INTELLIGENCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 1: Users & Revenue
        Row(
          children: [
            Expanded(
              child: _executiveKpiCard(
                title: 'Total Aspirants',
                value: '${state.totalRegisteredUsers}',
                subtext: '★ $proCount PRO Active',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF38BDF8), // Cyan
                onTap: () => setState(() => _activeSection = 'users'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _executiveKpiCard(
                title: 'Platform Revenue',
                value: '₹${estimatedRevenue.toInt()}',
                subtext: '• ₹49 Lifetime Orders',
                icon: Icons.currency_rupee_rounded,
                color: const Color(0xFF10B981), // Emerald
                onTap: () => setState(() => _activeSection = 'users'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Mistakes & Question Bank
        Row(
          children: [
            Expanded(
              child: _executiveKpiCard(
                title: 'Student Mistakes',
                value: '$totalMistakes',
                subtext: '• $snoozedCount Spaced Repetition',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFEF4444), // Red
                onTap: () => setState(() => _activeSection = 'mistakes'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _executiveKpiCard(
                title: 'Questions Bank',
                value: '${state.adminQuestions.length}',
                subtext: '• Geometry, Algebra & MCQs',
                icon: Icons.quiz_rounded,
                color: const Color(0xFF8B5CF6), // Purple
                onTap: () => setState(() => _activeSection = 'questions'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 3: Study PDFs & Broadcasts
        Row(
          children: [
            Expanded(
              child: _executiveKpiCard(
                title: 'Study PDFs & Notes',
                value: '${state.adminPdfMaterials.length}',
                subtext: '• Downloadable Books',
                icon: Icons.picture_as_pdf_rounded,
                color: const Color(0xFFEC4899), // Pink
                onTap: () => setState(() => _activeSection = 'pdfs'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _executiveKpiCard(
                title: 'Push Broadcasts',
                value: '${state.broadcasts.length}',
                subtext: '• 100% Student Reach',
                icon: Icons.campaign_rounded,
                color: const Color(0xFFF59E0B), // Amber
                onTap: () => setState(() => _activeSection = 'broadcasts'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _executiveKpiCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          gradient: LinearGradient(
            colors: [
              AppTheme.surface,
              color.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtext,
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color.withValues(alpha: 0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. RECENT STUDENT WEAK AREAS / MISTAKES SNAPSHOT
  // ==========================================
  Widget _buildRecentMistakesSnapshot(AppStateProvider state) {
    final list = state.studentMistakeAnalytics.where((s) {
      final email = s.studentEmail.toLowerCase();
      return !email.contains('admin') &&
          email != state.userEmail.toLowerCase() &&
          email != 'gulshankumar.dev01@gmail.com';
    }).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFEF4444)),
                  SizedBox(width: 8),
                  Text('Student Mistakes & Weak Areas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _activeSection = 'mistakes'),
                child: Row(
                  children: const [
                    Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFEF4444)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No student calculation mistakes logged yet. System is ready!', style: TextStyle(color: Colors.white54, fontSize: 11)),
            )
          else
            ...list.take(3).map((s) {
              final acc = s.accuracy > 1.0 ? s.accuracy : (s.accuracy * 100);
              final accColor = acc >= 75
                  ? const Color(0xFF10B981)
                  : acc >= 50
                      ? AppTheme.gold
                      : const Color(0xFFEF4444);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: accColor.withValues(alpha: 0.18),
                      child: Text(
                        s.studentName.isNotEmpty ? s.studentName[0].toUpperCase() : 'A',
                        style: TextStyle(color: accColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                          Text(s.studentEmail, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${s.totalMistakes} Errors', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                        Text('${acc.toStringAsFixed(0)}% Accuracy', style: TextStyle(fontSize: 9.5, color: accColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // 5. RECENT REVENUE & ORDERS SNAPSHOT
  // ==========================================
  Widget _buildRecentTransactionsSnapshot(AppStateProvider state) {
    final txs = state.transactions;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.currency_rupee_rounded, size: 18, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Text('Recent Orders & Subscriptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _activeSection = 'users'),
                child: Row(
                  children: const [
                    Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF10B981)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (txs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No verified transactions yet. Google Play In-App Purchase orders will appear here.', style: TextStyle(color: Colors.white54, fontSize: 11)),
            )
          else
            ...txs.take(3).map((t) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.userName.isNotEmpty ? t.userName : 'Aspirant', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                          Text(t.userEmail.isNotEmpty ? t.userEmail : t.orderId, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${t.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        const Text('VERIFIED PRO', style: TextStyle(fontSize: 9, color: AppTheme.gold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // 6. CONTENT BANK & STUDY PDFS SNAPSHOT
  // ==========================================
  Widget _buildContentBankSnapshot(AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_stories_rounded, size: 18, color: Color(0xFF8B5CF6)),
                  SizedBox(width: 8),
                  Text('Content Bank & Study Materials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _activeSection = 'questions'),
                child: Row(
                  children: const [
                    Text('Manage', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF8B5CF6)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${state.adminQuestions.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('Questions in Bank', style: TextStyle(fontSize: 10, color: Colors.white60)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${state.adminPdfMaterials.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('PDF Notes Live', style: TextStyle(fontSize: 10, color: Colors.white60)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 7. LATEST PUSH BROADCAST STUDIO SNAPSHOT
  // ==========================================
  Widget _buildLatestBroadcastSnapshot(AppStateProvider state) {
    final bc = state.broadcasts;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.campaign_rounded, size: 18, color: Colors.orangeAccent),
                  SizedBox(width: 8),
                  Text('Push Broadcast Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _activeSection = 'broadcasts'),
                child: Row(
                  children: const [
                    Text('Compose', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Colors.orangeAccent),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (bc.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No broadcast notices sent yet. Send motivational alerts to all aspirants!', style: TextStyle(color: Colors.white54, fontSize: 11)),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bc.first.targetAudience,
                          style: const TextStyle(fontSize: 9.5, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(DateFormat('dd MMM, hh:mm a').format(bc.first.sentAt), style: const TextStyle(fontSize: 9.5, color: Colors.white38)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(bc.first.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(bc.first.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Colors.white60)),
                ],
              ),
            ),
        ],
      ),
    );
  }
// ==========================================
  // TAB 1: QUESTIONS MANAGEMENT (SINGLE + BULK)
  // ==========================================
  Widget _buildQuestionsTab(AppStateProvider state) {
    final customQs = state.adminQuestions;
    final query = _questionSearchCtrl.text.trim().toLowerCase();

    final filtered = customQs.where((q) {
      if (query.isNotEmpty) {
        bool matchesPrompt = q.prompt.toLowerCase().contains(query);
        bool matchesAns = q.correctAnswer.toLowerCase().contains(query);
        if (!matchesPrompt && !matchesAns) return false;
      }
      if (_selectedQuestionFilter != 'all') {
        if (!q.topicId.toLowerCase().contains(_selectedQuestionFilter)) return false;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => state.syncAllAdminDataFromCloud(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_activeSection != 'all') _buildActiveSectionBanner('Questions Bank (MCQs)'),
          // Action Buttons: Single + Bulk Upload
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Add 1 Question', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () => _showQuestionDialog(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Bulk Upload (⚡)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () => _showBulkQuestionDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _questionSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search questions by prompt or answer...',
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
              suffixIcon: _questionSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                      onPressed: () {
                        _questionSearchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Topic Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuestionFilterChip('all', 'All (${customQs.length})'),
                const SizedBox(width: 8),
                _buildQuestionFilterChip('table', 'Tables 1–50'),
                const SizedBox(width: 8),
                _buildQuestionFilterChip('square', 'Squares & Cubes'),
                const SizedBox(width: 8),
                _buildQuestionFilterChip('fraction', 'Fractions & %'),
                const SizedBox(width: 8),
                _buildQuestionFilterChip('multiplier', 'Hard Multipliers'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Live Dynamic Questions (${filtered.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 12),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Column(
                children: [
                  const Icon(Icons.quiz_outlined, size: 48, color: Colors.white30),
                  const SizedBox(height: 12),
                  const Text('No custom questions found.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Add questions 1-by-1 or use Bulk Upload to publish dozens instantly.', style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add First Question'),
                    onPressed: () => _showQuestionDialog(context),
                  ),
                ],
              ),
            )
          else
            ...filtered.map((q) => _buildQuestionCard(context, state, q)),
        ],
      ),
    );
  }

  Widget _buildQuestionFilterChip(String filterId, String label) {
    bool isSelected = _selectedQuestionFilter == filterId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedQuestionFilter = filterId);
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, AppStateProvider state, QuestionModel q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  q.topicId.toUpperCase(),
                  style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                    onPressed: () => _showQuestionDialog(context, existing: q),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    onPressed: () => _confirmDeleteQuestion(context, state, q),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q.prompt,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Correct: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  q.correctAnswer,
                  style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          if (q.options.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: q.options.map((opt) {
                bool isCorrect = opt == q.correctAnswer;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCorrect ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.white10,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCorrect ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCorrect ? const Color(0xFF10B981) : Colors.white70,
                      fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (q.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '💡 Hint: ${q.explanation}',
              style: const TextStyle(fontSize: 11, color: Colors.white54, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: STUDY PDF MATERIALS (UPLOAD & MANAGE)
  // ==========================================
  Widget _buildPdfMaterialsTab(AppStateProvider state) {
    final pdfs = state.adminPdfMaterials;
    final query = _pdfSearchCtrl.text.trim().toLowerCase();

    final filteredPdfs = pdfs.where((p) {
      if (query.isNotEmpty) {
        String title = (p['title'] ?? '').toString().toLowerCase();
        String cat = (p['category'] ?? '').toString().toLowerCase();
        if (!title.contains(query) && !cat.contains(query)) return false;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => state.syncAllAdminDataFromCloud(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_activeSection != 'all') _buildActiveSectionBanner('Study Notes & PDFs'),
          // Upload PDF Banner & Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFDC2626).withValues(alpha: 0.2), AppTheme.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('PDF Study Materials Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      SizedBox(height: 2),
                      Text('Upload formula sheets, cheat notes & Vedic trick PDFs for students.', style: TextStyle(fontSize: 11, color: Colors.white60)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('Add PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _showAddPdfDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _pdfSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search PDF materials by title or category...',
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
              suffixIcon: _pdfSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                      onPressed: () {
                        _pdfSearchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Uploaded Study Materials (${filteredPdfs.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 12),

          if (filteredPdfs.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Column(
                children: [
                  const Icon(Icons.menu_book_rounded, size: 48, color: Colors.white30),
                  const SizedBox(height: 12),
                  const Text('No study PDF materials uploaded yet.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Upload formula books or cheat sheets to share with all aspirants.', style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Upload First PDF Document'),
                    onPressed: () => _showAddPdfDialog(context),
                  ),
                ],
              ),
            )
          else
            ...filteredPdfs.map((pdf) => _buildPdfCard(context, state, pdf)),
        ],
      ),
    );
  }

  Widget _buildPdfCard(BuildContext context, AppStateProvider state, Map<String, dynamic> pdf) {
    String id = pdf['id'] ?? '';
    String title = pdf['title'] ?? 'Formula Sheet';
    String category = pdf['category'] ?? 'General';
    String url = pdf['fileUrlOrData'] ?? '';
    int pageCount = pdf['pageCount'] is int ? pdf['pageCount'] : (int.tryParse(pdf['pageCount']?.toString() ?? '1') ?? 1);
    String desc = pdf['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(category, style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('$pageCount Pages', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDeletePdf(context, state, id, title),
              ),
            ],
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    side: const BorderSide(color: AppTheme.accent),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Copy PDF Link', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📋 PDF Link copied to clipboard!'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPdfDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final pagesCtrl = TextEditingController(text: '10');
    final descCtrl = TextEditingController();
    String category = 'Formula Sheet';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Upload Study PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'PDF Document Title',
                    hintText: 'e.g. Speed Math 1–50 Tables & Vedic Tricks',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: AppTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Study Category'),
                  items: const [
                    DropdownMenuItem(value: 'Formula Sheet', child: Text('Formula Sheet')),
                    DropdownMenuItem(value: 'Tables & Squares', child: Text('Tables & Squares')),
                    DropdownMenuItem(value: 'Vedic Tricks', child: Text('Vedic Tricks')),
                    DropdownMenuItem(value: 'Previous Year Mock', child: Text('Previous Year Mock')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => category = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'PDF URL or Google Drive Link',
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pagesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Page Count'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Short Description / Notes',
                    hintText: 'Full revision cheat sheet for aspirants',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              onPressed: () async {
                if (titleCtrl.text.trim().isNotEmpty && urlCtrl.text.trim().isNotEmpty) {
                  final state = context.read<AppStateProvider>();
                  await state.addAdminPdfMaterial(
                    title: titleCtrl.text.trim(),
                    category: category,
                    fileUrlOrData: urlCtrl.text.trim(),
                    pageCount: int.tryParse(pagesCtrl.text.trim()) ?? 1,
                    description: descCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ PDF Study Material published to Cloud Firestore!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                }
              },
              child: const Text('Publish PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAspirantDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String targetExam = 'SSC CGL';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDlgState) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: Color(0xFF10B981), size: 22),
              SizedBox(width: 8),
              Text('Add / Sync Aspirant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sync any user account by name/email directly to Cloud Users & Leaderboard:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Aspirant Full Name',
                    hintText: 'e.g. Rahul Kumar',
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Registered Email',
                    hintText: 'e.g. rahul@speedmath.com',
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: targetExam,
                  dropdownColor: AppTheme.surfaceElevated,
                  decoration: InputDecoration(
                    labelText: 'Target Exam',
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SSC CGL', child: Text('SSC CGL')),
                    DropdownMenuItem(value: 'BANK PO / CLERK', child: Text('BANK PO / CLERK')),
                    DropdownMenuItem(value: 'RAILWAY NTPC', child: Text('RAILWAY NTPC')),
                    DropdownMenuItem(value: 'CDS / AFCAT', child: Text('CDS / AFCAT')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => targetExam = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                if (name.isEmpty && email.isEmpty) return;

                final finalName = name.isNotEmpty ? name : email.split('@').first;
                final safeUid = 'usr_${(email.isNotEmpty ? email : finalName).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

                await CloudFirestoreSyncService().saveUserProfile(
                  uid: safeUid,
                  name: finalName,
                  email: email,
                  role: 'student',
                );

                await BackendService().syncUserProgressToLeaderboard(
                  userName: finalName,
                  score: 0,
                  accuracy: 0.0,
                  streak: 0,
                  userUid: safeUid,
                  targetExam: targetExam,
                  questionsSolved: 0,
                );

                if (ctx.mounted) Navigator.pop(ctx);
                if (!context.mounted) return;
                final state = context.read<AppStateProvider>();
                await state.syncAllAdminDataFromCloud();
                await state.fetchRealLeaderboard(forceRefresh: true);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ $finalName synced to Cloud Users & Leaderboard!'), backgroundColor: const Color(0xFF10B981)),
                );
              },
              child: const Text('Add to Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePdf(BuildContext context, AppStateProvider state, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete PDF Document?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "$title"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              state.deleteAdminPdfMaterial(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ PDF document deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: STUDENT MISTAKES & WEAKNESS ANALYTICS (100% REAL DATA)
  // ==========================================
  Widget _buildStudentMistakesTab(AppStateProvider state) {
    // Exclude Admin from student mistakes dossier!
    final allAnalytics = state.studentMistakeAnalytics.where((s) {
      final email = s.studentEmail.toLowerCase();
      final name = s.studentName.toLowerCase();
      return !email.contains('admin') &&
          email != state.userEmail.toLowerCase() &&
          email != 'gulshankumar.dev01@gmail.com' &&
          name != 'gulshan kumar' &&
          name != state.userName.toLowerCase();
    }).toList();
    final query = _studentSearchCtrl.text.trim().toLowerCase();

    var filtered = allAnalytics.where((s) {
      if (query.isNotEmpty) {
        bool matchesName = s.studentName.toLowerCase().contains(query);
        bool matchesEmail = s.studentEmail.toLowerCase().contains(query);
        if (!matchesName && !matchesEmail) return false;
      }

      if (_selectedMistakeFilter == 'needs_focus') {
        return s.accuracy < 70 || s.totalMistakes >= 4;
      } else if (_selectedMistakeFilter == 'snoozed') {
        return s.mistakes.any((m) => m.snoozedUntil != null && DateTime.now().isBefore(m.snoozedUntil!));
      } else if (_selectedMistakeFilter == 'tables') {
        return s.mistakes.any((m) => m.topicId.toLowerCase().contains('table'));
      } else if (_selectedMistakeFilter == 'squares') {
        return s.mistakes.any((m) => m.topicId.toLowerCase().contains('square'));
      }
      return true;
    }).toList();

    int totalMistakesCount = allAnalytics.fold(0, (sum, s) => sum + s.totalMistakes);
    int studentsNeedingFocus = allAnalytics.where((s) => s.accuracy < 70 || s.totalMistakes >= 4).length;

    return RefreshIndicator(
      onRefresh: () => state.syncAllAdminDataFromCloud(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_activeSection != 'all') _buildActiveSectionBanner('Student Mistakes & Weak Areas'),
          // Live Spaced Repetition Testing & Diagnostics Tool
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: AppTheme.accent, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Spaced Repetition Notification Live Diagnostics',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Schedule: 1st Alert 1 Hr after mistake ➔ 2nd Alert +3 Hrs later ➔ 3rd Alert +3 Hrs later. Tap below to immediately test multi-alert delivery on your phone right now.',
                  style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.3),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final prefs = await SharedPreferences.getInstance();
                      var queue = prefs.getStringList('pending_recall_queue') ?? [];
                      if (queue.isEmpty) {
                        await NotificationService().scheduleCalculationMistakeReminder(
                          prompt: '14 × 7',
                          correctAnswer: '98',
                          userAnswer: '95',
                        );
                        await NotificationService().scheduleCalculationMistakeReminder(
                          prompt: '16 × 3',
                          correctAnswer: '48',
                          userAnswer: '50',
                        );
                      }
                      final count = await NotificationService().forcePostAllPendingMistakesNow();
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '🎉 Sent $count Mistake Notifications to your phone! Each has 4 options: (A), (B), (C), (D) Snooze.',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF065F46),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text(
                      '⚡ Trigger All Pending Mistake Notifications Now',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // KPI Metric Summary (Strictly Real)
          Row(
            children: [
              Expanded(
                child: _summaryBox('Total Mistakes Logged', '$totalMistakesCount', Icons.error_outline_rounded, const Color(0xFFEF4444)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryBox('Needs Focus (<70%)', '$studentsNeedingFocus Students', Icons.priority_high_rounded, Colors.orangeAccent),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _studentSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search student by name or email...',
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
              suffixIcon: _studentSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                      onPressed: () {
                        _studentSearchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMistakeFilterChip('all', 'All Students (${allAnalytics.length})'),
                const SizedBox(width: 8),
                _buildMistakeFilterChip('needs_focus', 'Needs Attention (<70%)'),
                const SizedBox(width: 8),
                _buildMistakeFilterChip('snoozed', 'Snoozed ⏰'),
                const SizedBox(width: 8),
                _buildMistakeFilterChip('tables', 'Table Errors'),
                const SizedBox(width: 8),
                _buildMistakeFilterChip('squares', 'Square Errors'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildBroadcastMistakesToAllBanner(context, state),

          Text(
            'Real Student Mistake Dossier (${filtered.length} Active Aspirants)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(height: 12),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: Column(
                children: const [
                  Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF10B981)),
                  SizedBox(height: 12),
                  Text('No student mistakes recorded yet.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('As real students practice questions and quizzes, their mistakes and accuracy will appear here in real-time.', style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            )
          else
            ...filtered.map((s) => _buildStudentCard(context, state, s)),
        ],
      ),
    );
  }

  Widget _buildMistakeFilterChip(String filterId, String label) {
    bool isSelected = _selectedMistakeFilter == filterId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFEF4444),
      backgroundColor: AppTheme.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedMistakeFilter = filterId);
      },
    );
  }

  Widget _buildBroadcastMistakesToAllBanner(BuildContext context, AppStateProvider state) {
    final studentsWithMistakes = state.studentMistakeAnalytics.where((s) {
      final email = s.studentEmail.toLowerCase();
      return s.mistakes.isNotEmpty &&
          !email.contains('admin') &&
          email != state.userEmail.toLowerCase() &&
          email != 'gulshankumar.dev01@gmail.com';
    }).toList();
    final count = studentsWithMistakes.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            AppTheme.accent.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign_rounded, color: AppTheme.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1-Click Broadcast to ALL Students',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Sbhi students ke phone par unka apna unique wrong question jayega.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(
                'Sabhi Students Ko Unke Wrong Questions Ka Push Bhejo ($count Aspirants)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: count == 0
                  ? null
                  : () async {
                      final dispatched = await state.broadcastMistakeRemindersToAllStudents();
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                                SizedBox(width: 10),
                                Text('Broadcast Sent! 🎉', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: Text(
                              'Successfully sent personalized mistake recall challenges to all $dispatched students! Each student received their exact weak question.',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, AppStateProvider state, StudentMistakeAnalyticsModel s) {
    bool isWeak = s.accuracy < 70;
    Color statusColor = isWeak ? const Color(0xFFEF4444) : (s.accuracy < 85 ? Colors.orangeAccent : const Color(0xFF10B981));

    return Card(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Text(
            s.studentName.isNotEmpty ? s.studentName[0].toUpperCase() : 'A',
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                s.studentName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${s.accuracy.toStringAsFixed(1)}% Acc',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(s.studentEmail, style: const TextStyle(fontSize: 11, color: Colors.white54)),
            const SizedBox(height: 4),
            Text(
              '${s.totalMistakes} Mistakes  •  ${s.totalAttempted} Attempted  •  Active ${DateFormat('MMM d, h:mm a').format(s.lastActive.toLocal())}',
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Specific Mistake History:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                if (s.mistakes.isEmpty)
                  const Text('No recent mistakes recorded.', style: TextStyle(color: Colors.white38, fontSize: 12))
                else
                  ...s.mistakes.map((m) {
                    final bool isSnoozed = m.snoozedUntil != null && DateTime.now().isBefore(m.snoozedUntil!);
                    String stageLabel;
                    Color stageColor;
                    if (isSnoozed) {
                      stageLabel = '⏰ Snoozed (${DateFormat('MMM d, h a').format(m.snoozedUntil!.toLocal())})';
                      stageColor = Colors.amberAccent;
                    } else if (m.repetitionStage == 0) {
                      stageLabel = 'Stage 0: Fresh Error';
                      stageColor = const Color(0xFFEF4444);
                    } else if (m.repetitionStage == 1) {
                      stageLabel = 'Stage 1: 1-Hr Recall';
                      stageColor = Colors.orangeAccent;
                    } else if (m.repetitionStage == 2) {
                      stageLabel = 'Stage 2: +3-Hr Recall';
                      stageColor = Colors.amber;
                    } else if (m.repetitionStage == 3) {
                      stageLabel = 'Stage 3: +3-Hr Retention';
                      stageColor = Colors.lightBlueAccent;
                    } else {
                      stageLabel = 'Stage 4: Mastered';
                      stageColor = const Color(0xFF10B981);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: stageColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(m.prompt, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stageColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  stageLabel,
                                  style: TextStyle(color: stageColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Wrong: "${m.userAnswer}" ❌', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11.5, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Text('Correct: "${m.correctAnswer}" ✅', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.notifications_active_rounded, size: 14, color: Colors.white),
                              label: const Text('Is Question Ka Notification Bhejo (1-Click)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () async {
                                await state.sendTargetedMistakePushToStudent(
                                  studentUid: s.studentUid,
                                  studentName: s.studentName,
                                  studentEmail: s.studentEmail,
                                  prompt: m.prompt,
                                  userAnswer: m.userAnswer,
                                  correctAnswer: m.correctAnswer,
                                  topicName: m.topicId.toUpperCase(),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text('🚀 Notification for "${m.prompt}" dispatched to ${s.studentName}!'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF10B981),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text('Send Latest Mistake Push to ${s.studentName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      if (s.mistakes.isEmpty) return;
                      final latest = s.mistakes.first;
                      await state.sendTargetedMistakePushToStudent(
                        studentUid: s.studentUid,
                        studentName: s.studentName,
                        studentEmail: s.studentEmail,
                        prompt: latest.prompt,
                        userAnswer: latest.userAnswer,
                        correctAnswer: latest.correctAnswer,
                        topicName: latest.topicId.toUpperCase(),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Targeted focus push dispatched to ${s.studentName}!'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: REAL USERS & REVENUE (STRICTLY REAL DATA)
  // ==========================================
  Widget _buildUsersAndPaymentsTab(AppStateProvider state) {
    final users = state.registeredUsers;
    final txs = state.transactions;
    final query = _userSearchCtrl.text.trim().toLowerCase();

    final filteredUsers = users.where((u) {
      if (query.isNotEmpty) {
        String name = (u['name'] ?? '').toString().toLowerCase();
        String email = (u['email'] ?? '').toString().toLowerCase();
        if (!name.contains(query) && !email.contains(query)) return false;
      }
      return true;
    }).toList();

    final filteredTxs = txs.where((t) {
      if (query.isNotEmpty) {
        bool matchesName = t.userName.toLowerCase().contains(query);
        bool matchesId = t.orderId.toLowerCase().contains(query);
        bool matchesEmail = t.userEmail.toLowerCase().contains(query);
        bool matchesMethod = t.paymentMethod.toLowerCase().contains(query);
        if (!matchesName && !matchesId && !matchesEmail && !matchesMethod) return false;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => state.syncAllAdminDataFromCloud(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_activeSection != 'all') _buildActiveSectionBanner('Students & PRO Subscriptions'),
          // Real Platform Metrics
          Row(
            children: [
              Expanded(
                child: _summaryBox('Registered Aspirants', '${state.totalRegisteredUsers}', Icons.people_alt_rounded, AppTheme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryBox('Total Collected', '₹${state.totalRevenue.toInt()}', Icons.currency_rupee_rounded, AppTheme.gold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryBox('PRO Lifetime Members', '${txs.length}', Icons.verified_rounded, const Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryBox('Unlock Price', '₹49 One-Time', Icons.local_offer_rounded, Colors.orangeAccent),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Actions: Add/Sync Aspirant + Refresh
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                  label: const Text('Add / Sync Aspirant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  onPressed: () => _showAddAspirantDialog(context),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceElevated,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                label: const Text('Refresh', style: TextStyle(color: Colors.white70, fontSize: 13)),
                onPressed: () async {
                  await state.syncAllAdminDataFromCloud();
                  await state.fetchRealLeaderboard(forceRefresh: true);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _userSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search users or transactions by name, email, or order ID...',
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
              suffixIcon: _userSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                      onPressed: () {
                        _userSearchCtrl.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // Sub-Tab Switcher: Users vs Transactions
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _usersSubTab = 0),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _usersSubTab == 0 ? AppTheme.accent : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _usersSubTab == 0 ? AppTheme.accent : AppTheme.surfaceLight),
                    ),
                    child: Text(
                      'Registered Users (${filteredUsers.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _usersSubTab == 0 ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _usersSubTab = 1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _usersSubTab == 1 ? AppTheme.gold : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _usersSubTab == 1 ? AppTheme.gold : AppTheme.surfaceLight),
                    ),
                    child: Text(
                      'Transactions (${filteredTxs.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _usersSubTab == 1 ? Colors.black : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sub-Tab Content
          if (_usersSubTab == 0) ...[
            if (filteredUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.person_outline_rounded, size: 42, color: Colors.white30),
                    SizedBox(height: 12),
                    Text('No registered users found.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Real user profiles created via Firebase will appear here automatically.', style: TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center),
                  ],
                ),
              )
            else ...[
              // Group: System Administrators vs Student Aspirants
              ...(() {
                final adminList = filteredUsers.where((u) {
                  final r = (u['role'] ?? '').toString().toLowerCase();
                  final em = (u['email'] ?? '').toString().toLowerCase();
                  return r == 'admin' || em == state.userEmail.toLowerCase() || em == 'gulshankumar.dev01@gmail.com';
                }).toList();

                final studentList = filteredUsers.where((u) {
                  final r = (u['role'] ?? '').toString().toLowerCase();
                  final em = (u['email'] ?? '').toString().toLowerCase();
                  return r != 'admin' && em != state.userEmail.toLowerCase() && em != 'gulshankumar.dev01@gmail.com';
                }).toList();

                return [
                  if (adminList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.admin_panel_settings_rounded, size: 14, color: AppTheme.gold),
                          const SizedBox(width: 6),
                          Text(
                            'SYSTEM ADMINISTRATOR (${adminList.length})',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.gold, letterSpacing: 0.6),
                          ),
                        ],
                      ),
                    ),
                    ...adminList.map((u) => _buildUserCard(context, state, u)),
                    const SizedBox(height: 12),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'REGISTERED ASPIRANTS (${studentList.length})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 0.6),
                    ),
                  ),
                  if (studentList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.surfaceLight),
                      ),
                      child: const Text('No student aspirants registered yet.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    )
                  else
                    ...studentList.map((u) => _buildUserCard(context, state, u)),
                ];
              })(),
            ],
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredTxs.length} VERIFIED ORDERS',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 0.6),
                  ),
                  InkWell(
                    onTap: () async {
                      await state.syncAllAdminDataFromCloud();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          content: Row(
                            children: [
                              Icon(Icons.sync_rounded, color: AppTheme.accent, size: 18),
                              SizedBox(width: 8),
                              Text('Payments synced from Cloud Firestore!'),
                            ],
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sync_rounded, size: 13, color: AppTheme.gold),
                          SizedBox(width: 5),
                          Text('Sync Live', style: TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (filteredTxs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 42, color: Colors.white30),
                    const SizedBox(height: 12),
                    const Text('No payment transactions recorded yet.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('When students upgrade to Pro for ₹49, verified orders will be logged here in real-time.', style: TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.cloud_download_rounded, size: 18),
                      label: const Text('Fetch from Cloud Firestore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () => state.syncAllAdminDataFromCloud(),
                    ),
                  ],
                ),
              )
            else
              ...filteredTxs.map((t) => _buildTransactionCard(t)),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppStateProvider state, Map<String, dynamic> u) {
    String name = u['name'] ?? 'Aspirant';
    String email = u['email'] ?? '';
    String role = u['role'] ?? 'student';
    String uid = u['uid'] ?? '';
    bool isAdmin = role.toLowerCase() == 'admin';
    bool isPro = u['isPremium'] == true || u['isPro'] == true || (u['role']?.toString().toLowerCase() == 'pro');

    int score = (u['score'] is num) ? (u['score'] as num).toInt() : int.tryParse(u['score']?.toString() ?? '0') ?? 0;
    int questions = (u['questionsSolved'] is num) ? (u['questionsSolved'] as num).toInt() : int.tryParse(u['questionsSolved']?.toString() ?? '0') ?? 0;
    double rawAccuracy = (u['accuracy'] is num) ? (u['accuracy'] as num).toDouble() : double.tryParse(u['accuracy']?.toString() ?? '0.0') ?? 0.0;
    double accuracy = rawAccuracy > 1.0 ? rawAccuracy : (rawAccuracy * 100);
    int streak = (u['streak'] is num) ? (u['streak'] as num).toInt() : int.tryParse(u['streak']?.toString() ?? '0') ?? 0;
    String targetExam = u['targetExam']?.toString() ?? 'SSC CGL';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin
              ? AppTheme.gold.withValues(alpha: 0.5)
              : (isPro ? const Color(0xFF10B981).withValues(alpha: 0.4) : AppTheme.surfaceLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isAdmin
                    ? AppTheme.gold.withValues(alpha: 0.2)
                    : (isPro ? const Color(0xFF10B981).withValues(alpha: 0.15) : AppTheme.accent.withValues(alpha: 0.15)),
                child: Icon(
                  isAdmin
                      ? Icons.admin_panel_settings_rounded
                      : (isPro ? Icons.workspace_premium_rounded : Icons.person_rounded),
                  color: isAdmin ? AppTheme.gold : (isPro ? const Color(0xFF10B981) : AppTheme.accent),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? AppTheme.gold.withValues(alpha: 0.2)
                                : (isPro ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isAdmin ? 'ADMIN' : (isPro ? 'PRO LIFETIME' : 'STUDENT'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? AppTheme.gold : (isPro ? const Color(0xFF34D399) : Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isNotEmpty ? email : (uid.isNotEmpty ? 'UID: $uid' : 'No email provided'),
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  targetExam,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF818CF8), fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Score: $score',
                  style: const TextStyle(fontSize: 10, color: AppTheme.gold, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Solved: $questions',
                  style: const TextStyle(fontSize: 10, color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
              ),
              if (accuracy > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${accuracy.toStringAsFixed(0)}% acc',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF34D399), fontWeight: FontWeight.w600),
                  ),
                ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${streak}d streak',
                    style: const TextStyle(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          if (!isAdmin) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isPro ? Colors.redAccent : AppTheme.gold,
                    side: BorderSide(color: isPro ? Colors.redAccent.withValues(alpha: 0.5) : AppTheme.gold.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(
                    isPro ? Icons.remove_circle_outline_rounded : Icons.workspace_premium_rounded,
                    size: 14,
                  ),
                  label: Text(
                    isPro ? 'Revoke PRO' : 'Grant PRO Lifetime',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final targetId = uid.isNotEmpty ? uid : email;
                    if (targetId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot identify user without UID or Email')),
                      );
                      return;
                    }
                    final success = await state.toggleUserProStatus(targetId, !isPro);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                          content: Text(
                            success
                                ? (isPro ? 'Revoked PRO status for $name' : 'Granted PRO Lifetime to $name!')
                                : 'Failed to update user status in Cloud',
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

  Widget _buildTransactionCard(PaymentTransaction t) {
    final isUpi = t.paymentMethod.toLowerCase().contains('upi') || t.orderId.length == 12;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            t.userName.isNotEmpty ? t.userName : 'Verified Aspirant',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('PRO Lifetime', style: TextStyle(fontSize: 9.5, color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (t.userEmail.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded, size: 12, color: Colors.white54),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              t.userEmail,
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(t.date.toLocal()),
                      style: const TextStyle(fontSize: 10.5, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${t.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.gold)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUpi ? AppTheme.gold.withValues(alpha: 0.15) : AppTheme.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isUpi ? AppTheme.gold.withValues(alpha: 0.3) : AppTheme.primaryLight.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isUpi ? 'UPI Verified' : 'Google Play',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: isUpi ? AppTheme.gold : AppTheme.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.surfaceLight),
            ),
            child: Row(
              children: [
                Icon(isUpi ? Icons.receipt_long_rounded : Icons.confirmation_number_outlined, size: 13, color: Colors.white54),
                const SizedBox(width: 6),
                Text(
                  isUpi ? 'UTR Ref:' : 'Order ID:',
                  style: const TextStyle(fontSize: 10.5, color: Colors.white54, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.orderId,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: t.orderId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Row(
                          children: [
                            const Icon(Icons.copy_rounded, color: AppTheme.accent, size: 16),
                            const SizedBox(width: 8),
                            Text('Copied: ${t.orderId}'),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.copy_rounded, size: 13, color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 5: PUSH BROADCASTS
  // ==========================================
  Widget _buildPushNoticeTab(AppStateProvider state) {
    final broadcasts = state.broadcasts;

    return RefreshIndicator(
      onRefresh: () => state.syncAllAdminDataFromCloud(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_activeSection != 'all') _buildActiveSectionBanner('Send Notifications & Alerts'),
          Container(
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
                  children: const [
                    Icon(Icons.campaign_rounded, color: AppTheme.gold, size: 22),
                    SizedBox(width: 8),
                    Text('Compose Instant Notification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _pushTitleCtrl,
                  decoration: const InputDecoration(labelText: 'Notification Header / Title'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _pushBodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Message Body / Motivation Text'),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _targetAudience,
                  dropdownColor: AppTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Target Aspirant Cohort'),
                  items: const [
                    DropdownMenuItem(value: 'All Students', child: Text('All Registered Aspirants')),
                    DropdownMenuItem(value: 'Low Accuracy (<70%)', child: Text('Low Accuracy (<70%) Aspirants')),
                    DropdownMenuItem(value: 'Inactive (>24h)', child: Text('Inactive (>24 Hours)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _targetAudience = val);
                  },
                ),
                const SizedBox(height: 14),

                // Quick Templates
                Wrap(
                  spacing: 6,
                  children: [
                    _quickTemplateChip('⚡ Daily Booster', '⚡ Daily Speed Booster!', 'Practice 5 minutes today to keep your streak alive and sharpen your calculations.'),
                    _quickTemplateChip('🎯 Mistake Recall', '🧠 Mistake Auto-Recall Ready', 'Your failed table calculations from yesterday are waiting for smart revision.'),
                    _quickTemplateChip('🏆 Mock Test Live', '🔥 All-India Speed Mock Active', 'Compete on the leaderboard today and earn double XP.'),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Dispatch Push Broadcast to Students', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () async {
                      if (_pushTitleCtrl.text.trim().isNotEmpty && _pushBodyCtrl.text.trim().isNotEmpty) {
                        await state.sendAdminBroadcast(
                          title: _pushTitleCtrl.text.trim(),
                          body: _pushBodyCtrl.text.trim(),
                          target: _targetAudience,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🚀 Push broadcast dispatched and synced to Cloud Firestore!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Dispatched Broadcast History (${broadcasts.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(height: 10),

          if (broadcasts.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('No past broadcasts logged yet.', style: TextStyle(color: Colors.white38)),
            )
          else
            ...broadcasts.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.surfaceLight),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: AppTheme.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                                ),
                                Text(
                                  DateFormat('MMM d, h:mm a').format(b.sentAt.toLocal()),
                                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(b.body, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _quickTemplateChip(String label, String title, String body) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      backgroundColor: AppTheme.surfaceElevated,
      onPressed: () {
        setState(() {
          _pushTitleCtrl.text = title;
          _pushBodyCtrl.text = body;
        });
      },
    );
  }

  // ==========================================
  // BULK QUESTION UPLOAD MODAL
  // ==========================================
  void _showBulkQuestionDialog(BuildContext context) {
    final bulkTextCtrl = TextEditingController();
    List<QuestionModel> parsedQuestions = [];
    String parseStatus = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          void parseBulkInput() {
            final text = bulkTextCtrl.text.trim();
            if (text.isEmpty) {
              setModalState(() {
                parsedQuestions = [];
                parseStatus = 'Please enter or paste questions first.';
              });
              return;
            }

            List<QuestionModel> list = [];

            // 1. Try JSON parsing
            if (text.startsWith('[') && text.endsWith(']')) {
              try {
                List decoded = json.decode(text);
                for (var item in decoded) {
                  if (item is Map) {
                    list.add(QuestionModel(
                      id: item['id']?.toString() ?? const Uuid().v4(),
                      prompt: item['prompt']?.toString() ?? '',
                      correctAnswer: item['correctAnswer']?.toString() ?? '',
                      options: (item['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
                      topicId: item['topicId']?.toString() ?? 'tables',
                      explanation: item['explanation']?.toString() ?? '',
                    ));
                  }
                }
              } catch (_) {}
            }

            // 2. Delimited line-by-line format:
            // Prompt | Answer | Opt1, Opt2, Opt3, Opt4 | Topic | Explanation
            if (list.isEmpty) {
              final lines = text.split('\n');
              for (var rawLine in lines) {
                final line = rawLine.trim();
                if (line.isEmpty || line.startsWith('#') || line.startsWith('//')) continue;

                final parts = line.split('|').map((p) => p.trim()).toList();
                if (parts.length >= 2) {
                  String prompt = parts[0];
                  String ans = parts[1];
                  List<String> options = [];

                  if (parts.length >= 3 && parts[2].isNotEmpty) {
                    options = parts[2].split(',').map((o) => o.trim()).toList();
                  }

                  // Ensure correct answer is present in options
                  if (!options.contains(ans)) {
                    options.insert(0, ans);
                  }
                  // Auto-generate distractors if less than 4 options
                  int numericAns = int.tryParse(ans) ?? 10;
                  while (options.length < 4) {
                    int offset = (options.length == 1) ? 10 : (options.length == 2 ? -10 : 2);
                    String genOpt = '${numericAns + offset}';
                    if (!options.contains(genOpt)) {
                      options.add(genOpt);
                    } else {
                      options.add('${numericAns + options.length + 5}');
                    }
                  }

                  String topic = parts.length >= 4 && parts[3].isNotEmpty ? parts[3] : 'tables';
                  String explanation = parts.length >= 5 ? parts[4] : '';

                  list.add(QuestionModel(
                    id: const Uuid().v4(),
                    prompt: prompt,
                    correctAnswer: ans,
                    options: options..shuffle(),
                    topicId: topic,
                    explanation: explanation,
                  ));
                }
              }
            }

            setModalState(() {
              parsedQuestions = list;
              parseStatus = list.isNotEmpty
                  ? '✅ Successfully parsed ${list.length} question(s)!'
                  : '⚠️ No valid questions detected. Check format.';
            });
          }

          return AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Bulk Question Upload', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.88,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.surfaceLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Supported Line-by-Line Format:', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
                          SizedBox(height: 4),
                          Text('Prompt | Answer | Opt1, Opt2, Opt3, Opt4 | Topic | Hint', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          SizedBox(height: 2),
                          Text('Example: 19 × 7 = ? | 133 | 123, 133, 143, 153 | tables | 19*7=133', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          icon: const Icon(Icons.auto_awesome, size: 14, color: AppTheme.gold),
                          label: const Text('Load Sample Format', style: TextStyle(fontSize: 11, color: AppTheme.gold)),
                          onPressed: () {
                            bulkTextCtrl.text =
                                '17 × 8 = ? | 136 | 126, 136, 146, 156 | tables | 17 times 8 is 136\n'
                                '23² = ? | 529 | 519, 529, 539, 549 | squares | 23 squared is 529\n'
                                '1/16 in % = ? | 6.25% | 6.25%, 12.5%, 8.33%, 5.55% | fractions | 1/16 = 6.25%\n'
                                '48 × 25 = ? | 1200 | 1100, 1200, 1250, 1300 | multipliers | Divide by 4 and add 00';
                            parseBulkInput();
                          },
                        ),
                      ],
                    ),

                    TextField(
                      controller: bulkTextCtrl,
                      maxLines: 8,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Paste multiple questions here (one per line)...',
                        filled: true,
                        fillColor: AppTheme.surfaceElevated,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Validate & Parse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: parseBulkInput,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            parseStatus,
                            style: TextStyle(
                              fontSize: 11,
                              color: parseStatus.contains('✅') ? const Color(0xFF10B981) : Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (parsedQuestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Parsed Preview (${parsedQuestions.length} questions):', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.surfaceLight),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: parsedQuestions.length,
                          itemBuilder: (c, idx) {
                            final q = parsedQuestions[idx];
                            return ListTile(
                              dense: true,
                              title: Text('${idx + 1}. ${q.prompt}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              subtitle: Text('Ans: ${q.correctAnswer}  •  Topic: ${q.topicId}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                              trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                ),
                onPressed: parsedQuestions.isEmpty
                    ? null
                    : () async {
                        final state = context.read<AppStateProvider>();
                        int count = await state.addBulkAdminQuestions(parsedQuestions);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ $count questions uploaded and synced to Cloud Firestore!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                child: Text('Publish All (${parsedQuestions.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // SINGLE ADD / EDIT QUESTION DIALOG
  // ==========================================
  void _showQuestionDialog(BuildContext context, {QuestionModel? existing}) {
    final promptCtrl = TextEditingController(text: existing?.prompt ?? '');
    final ansCtrl = TextEditingController(text: existing?.correctAnswer ?? '');
    final explCtrl = TextEditingController(text: existing?.explanation ?? '');
    String topic = existing?.topicId ?? 'tables';

    List<String> distractors = existing != null
        ? existing.options.where((o) => o != existing.correctAnswer).toList()
        : [];
    final opt1Ctrl = TextEditingController(text: distractors.isNotEmpty ? distractors[0] : '');
    final opt2Ctrl = TextEditingController(text: distractors.length > 1 ? distractors[1] : '');
    final opt3Ctrl = TextEditingController(text: distractors.length > 2 ? distractors[2] : '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            existing == null ? 'Add Single Question' : 'Edit Question',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: topic,
                  dropdownColor: AppTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Topic Category'),
                  items: const [
                    DropdownMenuItem(value: 'tables', child: Text('Tables (1–50)')),
                    DropdownMenuItem(value: 'squares', child: Text('Squares & Cubes')),
                    DropdownMenuItem(value: 'fractions', child: Text('Fractions & %')),
                    DropdownMenuItem(value: 'multipliers', child: Text('Hard Multipliers (2-Digit)')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom Speed Drill')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => topic = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: promptCtrl,
                  decoration: const InputDecoration(labelText: 'Question Prompt (e.g. 29 × 8 = ?)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ansCtrl,
                  decoration: const InputDecoration(labelText: 'Correct Answer (e.g. 232)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: opt1Ctrl,
                  decoration: const InputDecoration(labelText: 'Distractor Option 1'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: opt2Ctrl,
                  decoration: const InputDecoration(labelText: 'Distractor Option 2'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: opt3Ctrl,
                  decoration: const InputDecoration(labelText: 'Distractor Option 3'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: explCtrl,
                  decoration: const InputDecoration(labelText: 'Explanation / Shortcut Hint (Optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              onPressed: () {
                if (promptCtrl.text.trim().isNotEmpty && ansCtrl.text.trim().isNotEmpty) {
                  final q = QuestionModel(
                    id: existing?.id ?? const Uuid().v4(),
                    topicId: topic,
                    prompt: promptCtrl.text.trim(),
                    correctAnswer: ansCtrl.text.trim(),
                    explanation: explCtrl.text.trim(),
                    options: [
                      ansCtrl.text.trim(),
                      opt1Ctrl.text.isNotEmpty ? opt1Ctrl.text.trim() : '${(int.tryParse(ansCtrl.text.trim()) ?? 10) + 10}',
                      opt2Ctrl.text.isNotEmpty ? opt2Ctrl.text.trim() : '${(int.tryParse(ansCtrl.text.trim()) ?? 10) - 10}',
                      opt3Ctrl.text.isNotEmpty ? opt3Ctrl.text.trim() : '${(int.tryParse(ansCtrl.text.trim()) ?? 10) + 2}',
                    ]..shuffle(),
                  );
                  if (existing == null) {
                    context.read<AppStateProvider>().addAdminQuestion(q);
                  } else {
                    context.read<AppStateProvider>().editAdminQuestion(q);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existing == null ? '✅ Question added and synced to Cloud!' : '✅ Question updated!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: Text(existing == null ? 'Save & Sync' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteQuestion(BuildContext context, AppStateProvider state, QuestionModel q) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Question?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${q.prompt}" from Cloud and local cache?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              state.deleteAdminQuestion(q.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ Question deleted from Cloud and device.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
