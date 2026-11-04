import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/math_models.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import 'learn_mode_screen.dart';
import 'practice_quiz_screen.dart';
import 'arithmetic_digit_selection_screen.dart';
import '../revision/table_revision_hub_screen.dart';
import '../revision/powers_revision_hub_screen.dart';
import '../revision/product_chauraha_hub_screen.dart';
import '../auth/auth_screen.dart';
import '../../widgets/payment_checkout_sheet.dart';

class CalculationModulesHubScreen extends StatefulWidget {
  const CalculationModulesHubScreen({super.key});

  @override
  State<CalculationModulesHubScreen> createState() => _CalculationModulesHubScreenState();
}

class _CalculationModulesHubScreenState extends State<CalculationModulesHubScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Add & Subtract',
    'Tables (1–30)',
    'Squares & Cubes',
    'Hard Multipliers',
    'Fractions',
    'Division',
    'Pythagorean Triples',
    'Product Chauraha',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isPro = state.isPremium;
    final topics = state.topics;

    final filteredTopics = _filterTopics(topics);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📐 Calculation Modules'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            child: ActionChip(
              avatar: Icon(
                isPro ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                size: 16,
                color: isPro ? Colors.white : AppTheme.gold,
              ),
              backgroundColor: isPro ? const Color(0xFF10B981) : const Color(0xFFF59E0B).withValues(alpha: 0.2),
              side: BorderSide(
                color: isPro ? const Color(0xFF059669) : AppTheme.gold,
                width: 1.2,
              ),
              label: Text(
                isPro ? 'PRO ACTIVE' : 'UPGRADE PRO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isPro ? Colors.white : AppTheme.gold,
                ),
              ),
              onPressed: () => _showProUpgradeModal(context, state),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // 1. Pro Membership Plan Status Banner
          _buildProPlanBanner(context, state, isPro),
          const SizedBox(height: 18),

          // 2. Category Filter Pills
          _buildCategoryFilterRow(),
          const SizedBox(height: 16),

          // 3. Module Count Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Modules (${filteredTopics.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                  letterSpacing: 0.2,
                ),
              ),
              if (!isPro)
                GestureDetector(
                  onTap: () => _showProUpgradeModal(context, state),
                  child: const Text(
                    'Unlock All with Pro ⚡',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Clean Calculation Module Cards
          ...filteredTopics.map((topic) => _buildModuleCard(context, topic, isPro, state)),
        ],
      ),
    );
  }

  List<TopicModel> _filterTopics(List<TopicModel> allTopics) {
    if (_selectedCategory == 'All') return allTopics;
    if (_selectedCategory == 'Add & Subtract') {
      return allTopics.where((t) => t.type == TopicType.addition || t.type == TopicType.subtraction).toList();
    }
    if (_selectedCategory == 'Tables (1–30)') {
      return allTopics.where((t) => t.type == TopicType.tables).toList();
    }
    if (_selectedCategory == 'Squares & Cubes') {
      return allTopics.where((t) => t.type == TopicType.squares || t.type == TopicType.cubes).toList();
    }
    if (_selectedCategory == 'Pythagorean Triples') {
      return allTopics.where((t) => t.type == TopicType.triples).toList();
    }
    if (_selectedCategory == 'Fractions') {
      return allTopics.where((t) => t.type == TopicType.fractions).toList();
    }
    if (_selectedCategory == 'Division') {
      return allTopics.where((t) => t.type == TopicType.division).toList();
    }
    if (_selectedCategory == 'Hard Multipliers') {
      return allTopics.where((t) => t.type == TopicType.hardMultiplier).toList();
    }
    if (_selectedCategory == 'Product Chauraha') {
      return allTopics.where((t) => t.type == TopicType.productChauraha).toList();
    }
    return allTopics;
  }

  Widget _buildCategoryFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryLight,
              backgroundColor: AppTheme.surfaceElevated,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight,
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedCategory = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // 1. Pro Membership Plan Banner
  Widget _buildProPlanBanner(BuildContext context, AppStateProvider state, bool isPro) {
    if (isPro) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF065F46), Color(0xFF047857)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.gold, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '👑 Pro Calculation Plan Active',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'All 8 Calculation Modules, 1–50 Tables & Hard Multipliers are 100% unlocked.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 16,
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
                child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.gold, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Speed Math Pro Calculation Vault',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PAID PLAN',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Unlock all advanced modules, 1–50 tables, 2-digit hard multipliers, Vedic decomposition tricks, and offline cheat sheets.',
            style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 18, color: Colors.black),
              label: const Text(
                'Unlock Pro Access (Special ₹49 / Lifetime)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
              onPressed: () => _showProUpgradeModal(context, state),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Module Card
  Widget _buildModuleCard(BuildContext context, TopicModel topic, bool isPro, AppStateProvider state) {
    final bool isLocked = !isPro && topic.type == TopicType.hardMultiplier;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLocked ? AppTheme.gold.withValues(alpha: 0.3) : AppTheme.surfaceLight,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTopicColor(topic.type).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getTopicIcon(topic.type),
                    color: _getTopicColor(topic.type),
                    size: 26,
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
                              topic.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.gold, width: 0.8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_rounded, size: 10, color: AppTheme.gold),
                                  SizedBox(width: 3),
                                  Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: AppTheme.gold,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        topic.subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.surfaceLight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Learn & Tricks Button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.surfaceLight),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.accent),
                    label: const Text('Learn & Tricks', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      if (topic.type == TopicType.productChauraha) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductChaurahaHubScreen(startInDrillMode: false)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LearnModeScreen(topic: topic)),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Rapid Drill Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLocked ? AppTheme.surfaceElevated : AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(
                      isLocked ? Icons.lock_open_rounded : Icons.flash_on_rounded,
                      size: 16,
                      color: isLocked ? AppTheme.gold : AppTheme.gold,
                    ),
                    label: Text(
                      isLocked ? 'Unlock Drill' : 'Start Drill',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (state.isGuestLimitReached) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthScreen(
                              initialIsLogin: false,
                              isMandatory: true,
                            ),
                          ),
                        );
                        return;
                      }
                      if (isLocked) {
                        _showProUpgradeModal(context, state);
                      } else if (topic.type == TopicType.tables) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TableRevisionHubScreen(initialTable: 2),
                          ),
                        );
                      } else if (topic.type == TopicType.squares) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PowersRevisionHubScreen(isCubes: false),
                          ),
                        );
                      } else if (topic.type == TopicType.cubes) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PowersRevisionHubScreen(isCubes: true),
                          ),
                        );
                      } else if (topic.type == TopicType.productChauraha) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductChaurahaHubScreen(startInDrillMode: true),
                          ),
                        );
                      } else if (topic.type == TopicType.addition ||
                          topic.type == TopicType.subtraction ||
                          topic.type == TopicType.hardMultiplier ||
                          topic.type == TopicType.division) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArithmeticDigitSelectionScreen(type: topic.type),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeQuizScreen(
                              topic: topic,
                              isTimed: true,
                              questionCount: 15,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                if (topic.type == TopicType.tables) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.table_chart_rounded, color: AppTheme.accent, size: 20),
                    tooltip: '1–50 Table Hub',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TableRevisionHubScreen()),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTopicColor(TopicType type) {
    switch (type) {
      case TopicType.addition:
        return const Color(0xFF10B981);
      case TopicType.subtraction:
        return const Color(0xFFF97316);
      case TopicType.division:
        return const Color(0xFF14B8A6);
      case TopicType.tables:
        return const Color(0xFF6366F1);
      case TopicType.squares:
        return const Color(0xFFFBBF24);
      case TopicType.cubes:
        return const Color(0xFF8B5CF6);
      case TopicType.fractions:
        return const Color(0xFFEC4899);
      case TopicType.triples:
        return const Color(0xFF8B5CF6);
      case TopicType.hardMultiplier:
        return const Color(0xFFEF4444);
      case TopicType.productChauraha:
        return const Color(0xFFF59E0B);
      case TopicType.custom:
        return const Color(0xFF06B6D4);
    }
  }

  IconData _getTopicIcon(TopicType type) {
    switch (type) {
      case TopicType.addition:
        return Icons.add_rounded;
      case TopicType.subtraction:
        return Icons.remove_rounded;
      case TopicType.division:
        return Icons.safety_divider_rounded;
      case TopicType.tables:
        return Icons.grid_view_rounded;
      case TopicType.squares:
        return Icons.crop_square_rounded;
      case TopicType.cubes:
        return Icons.view_in_ar_rounded;
      case TopicType.fractions:
        return Icons.percent_rounded;
      case TopicType.triples:
        return Icons.change_history_rounded;
      case TopicType.hardMultiplier:
        return Icons.bolt_rounded;
      case TopicType.productChauraha:
        return Icons.alt_route_rounded;
      case TopicType.custom:
        return Icons.calculate_rounded;
    }
  }

  void _showProUpgradeModal(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.gold, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👑 Speed Math Pro Lifetime',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Comprehensive Calculation Mastery Access',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _proFeatureBullet('⚡ Unlimited Hard-On Pro Multipliers (17×45+)', 'Vedic 2-digit shortcuts without pen & paper'),
            _proFeatureBullet('📚 Complete 1–50 Tables Hub', 'High-speed audio reciter & targeted drills'),
            _proFeatureBullet('📐 All Squares, Cubes, Roots & Triples', 'Instant calculation formula cards & cheatsheets'),
            _proFeatureBullet('🚫 100% Ad-Free & Offline PDF Sheets', 'Printable Vedic cheat sheets & spaced repetition'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  PaymentCheckoutSheet.show(context);
                },
                child: Text(
                  state.isPremium ? 'PRO Membership Active • Manage' : 'Unlock Lifetime PRO for ₹49',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _proFeatureBullet(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
