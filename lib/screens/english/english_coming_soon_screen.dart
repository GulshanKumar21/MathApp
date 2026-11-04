import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/swiggy_flipkart_section_bar.dart';

class EnglishComingSoonScreen extends StatefulWidget {
  const EnglishComingSoonScreen({super.key});

  @override
  State<EnglishComingSoonScreen> createState() => _EnglishComingSoonScreenState();
}

class _EnglishComingSoonScreenState extends State<EnglishComingSoonScreen> with SingleTickerProviderStateMixin {
  bool _notifyEnabled = true;
  int _activeSampleCard = 0;
  late AnimationController _badgeGlowController;
  late Animation<double> _badgeGlow;

  final List<Map<String, dynamic>> _quickPreviews = [
    {
      'title': 'Vocab of The Day',
      'word': 'Ephemeral (adj.)',
      'meaning': 'Lasting for a very short time.',
      'mnemonic': 'Think "sounds like perfume" — fragrance lasts short!',
      'tag': 'SSC / BANK CORE',
      'color': Color(0xFF38BDF8),
    },
    {
      'title': '10s Golden Rule',
      'word': 'Rule #42: Neither / Nor',
      'meaning': 'Verb always agrees with the closest subject.',
      'mnemonic': 'Neither the teacher nor the students were present.',
      'tag': '120 GRAMMAR RULES',
      'color': Color(0xFFA78BFA),
    },
    {
      'title': 'Idiom of The Day',
      'word': 'Burn the midnight oil',
      'meaning': 'To work or study late into the night.',
      'mnemonic': 'Used heavily in SSC CGL Tier 1 & Tier 2 comprehension.',
      'tag': 'HIGH-FREQUENCY IDIOM',
      'color': Color(0xFFFBBF24),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _badgeGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _badgeGlow = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _badgeGlowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _badgeGlowController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notifyEnabled = prefs.getBool('notify_english_launch') ?? true;
      });
    }
  }

  Future<void> _toggleNotification(bool val) async {
    HapticFeedback.lightImpact();
    setState(() => _notifyEnabled = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notify_english_launch', val);
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: val ? const Color(0xFF059669) : const Color(0xFF334155),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              val ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                val
                    ? 'Launch alert enabled! You will be notified the moment English launches.'
                    : 'Launch alert disabled for English section.',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF070B14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'English Verbal Hub',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                ),
                Text(
                  'Vocab, Grammar & Comprehension Sprint',
                  style: TextStyle(fontSize: 10.5, color: Colors.white54, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 0. Flipkart / Swiggy 3-Department Category Bar (Math | Alarm | English)
            const SwiggyFlipkartSectionBar(),
            const SizedBox(height: 12),

            // 1. HERO COMING SOON BANNER (SWIGGY SPECIAL TEASER)
            _buildHeroComingSoonBanner(),
            const SizedBox(height: 16),

            // 2. INTERACTIVE LIVE SAMPLE VOCAB PREVIEW CAROUSEL
            _buildInteractivePreviewTabs(),
            const SizedBox(height: 16),

            // 3. 1-TAP NOTIFY ME PREFERENCE SWITCH CARD
            _buildNotifyMeCard(),
            const SizedBox(height: 20),

            // 4. CURATED MODULE PREVIEWS (SWIGGY STYLE RESTAURANT DISH CARDS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'PLANNED HIGH-YIELD TRACKS',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Colors.white60,
                  ),
                ),
                Text(
                  '5 Tracks In Build',
                  style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildModulePreviewCard(
              icon: Icons.menu_book_rounded,
              iconColor: const Color(0xFF38BDF8),
              title: 'Daily Editorial Vocab & Root Words',
              description: '10 The Hindu exam-level words daily with mnemonics, contextual definitions, antonyms & synonyms.',
              badge: '10 Words/Day',
            ),
            const SizedBox(height: 10),

            _buildModulePreviewCard(
              icon: Icons.spellcheck_rounded,
              iconColor: const Color(0xFFA78BFA),
              title: '10-Second Grammar Error Spotter',
              description: '120 Golden Rules of Grammar with rapid question drills: Subject-Verb, Prepositions & Modifiers.',
              badge: '120 Rules',
            ),
            const SizedBox(height: 10),

            _buildModulePreviewCard(
              icon: Icons.speed_rounded,
              iconColor: const Color(0xFFFBBF24),
              title: 'Reading Speed Booster (WPM)',
              description: 'Interactive speed-reading exercises to take your comprehension speed from 140 WPM to 350 WPM.',
              badge: 'Speed Drills',
            ),
            const SizedBox(height: 10),

            _buildModulePreviewCard(
              icon: Icons.auto_awesome_rounded,
              iconColor: const Color(0xFFF472B6),
              title: '500 High-Yield Idioms & Phrases',
              description: 'Most frequently repeated SSC & Banking idioms tested through rapid flashcard flip cards.',
              badge: '500 Flashcards',
            ),
            const SizedBox(height: 10),

            _buildModulePreviewCard(
              icon: Icons.format_list_numbered_rounded,
              iconColor: const Color(0xFF34D399),
              title: 'Cloze Test & Para Jumbles Sprint',
              description: 'Exam-pattern context filling and sentence rearrangement with time countdown pressure.',
              badge: 'Exam Pattern',
            ),
            const SizedBox(height: 22),

            // 5. ACTION BUTTONS: GO TO MATH OR ALARM
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.flash_on_rounded, color: AppTheme.gold, size: 18),
                    label: const Text(
                      'Speed Math Drills',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                    ),
                    onPressed: () => state.setAppSection(0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.3),
                      backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.14),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.alarm_on_rounded, color: Color(0xFFEF4444), size: 19),
                    label: const Text(
                      'Math Alarm',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                    ),
                    onPressed: () => state.setAppSection(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. HERO COMING SOON BANNER ---
  Widget _buildHeroComingSoonBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B), // Deep emerald
            Color(0xFF0F3931),
            Color(0xFF0A1828),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedBuilder(
                animation: _badgeGlow,
                builder: (context, child) => Transform.scale(
                  scale: _badgeGlow.value,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: Colors.black, size: 13),
                      SizedBox(width: 5),
                      Text(
                        'COMING SOON',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'V1 Beta in Build',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'English Verbal Mastery',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Targeted speed drills for SSC CGL, Banking (PO/Clerk), CDS & Defense Aspirants.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Development Progress Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF071B17),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Development Progress',
                      style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '80% Complete',
                      style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.80,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. INTERACTIVE SAMPLE VOCAB PREVIEW CAROUSEL ---
  Widget _buildInteractivePreviewTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'LIVE CURRICULUM SAMPLE',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.white60,
              ),
            ),
            Text(
              'Tap to Preview',
              style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_quickPreviews.length, (idx) {
            final p = _quickPreviews[idx];
            final bool isSel = _activeSampleCard == idx;
            final Color col = p['color'] as Color;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: idx < 2 ? 6.0 : 0.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _activeSampleCard = idx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? col.withValues(alpha: 0.22) : const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? col : Colors.white12,
                        width: isSel ? 1.4 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        p['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                          color: isSel ? Colors.white : Colors.white60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _buildSampleCardContent(_quickPreviews[_activeSampleCard]),
        ),
      ],
    );
  }

  Widget _buildSampleCardContent(Map<String, dynamic> data) {
    final Color color = data['color'] as Color;
    return Container(
      key: ValueKey<String>(data['word'] as String),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['word'] as String,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data['tag'] as String,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data['meaning'] as String,
            style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.3),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B101D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFFFBBF24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['mnemonic'] as String,
                    style: const TextStyle(fontSize: 11, color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. 1-TAP NOTIFY ME PREFERENCE SWITCH CARD ---
  Widget _buildNotifyMeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notify Me on Launch',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                SizedBox(height: 2),
                Text(
                  'Receive a one-time push alert when English goes live',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _notifyEnabled,
            activeTrackColor: const Color(0xFF10B981),
            activeThumbColor: Colors.white,
            inactiveTrackColor: Colors.white12,
            inactiveThumbColor: Colors.white54,
            onChanged: _toggleNotification,
          ),
        ],
      ),
    );
  }

  Widget _buildModulePreviewCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9.5),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
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
      ),
    );
  }
}
