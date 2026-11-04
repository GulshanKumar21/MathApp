import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

/// MNC-Grade Animated Segmented Section Bar (Like Swiggy, Flipkart, Cred)
/// Features a continuous sliding indicator pill, spring physics, and haptic feedback
class SwiggyFlipkartSectionBar extends StatelessWidget {
  const SwiggyFlipkartSectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final int currentSection = state.currentAppSection;
    final bool isAlarmActive = state.mathAlarmEnabled;
    final String alarmTimeStr =
        '${state.mathAlarmHour % 12 == 0 ? 12 : state.mathAlarmHour % 12}:${state.mathAlarmMinute.toString().padLeft(2, '0')} ${state.mathAlarmHour >= 12 ? 'PM' : 'AM'}';

    // Alignment of sliding indicator: -1.0 (Left), 0.0 (Center), 1.0 (Right)
    final Alignment pillAlignment = currentSection == 0
        ? const Alignment(-1.0, 0.0)
        : (currentSection == 1 ? const Alignment(0.0, 0.0) : const Alignment(1.0, 0.0));

    final List<Color> activeGradient = currentSection == 0
        ? const [Color(0xFF4338CA), Color(0xFF3730A3)] // Deep Cobalt
        : (currentSection == 1
            ? const [Color(0xFFBE123C), Color(0xFF9F1239)] // Deep Rose
            : const [Color(0xFF047857), Color(0xFF065F46)]); // Forest Emerald

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Slate 900 base
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1F2937),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. Smooth Gliding Active Pill (Refined Segmented Control)
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: pillAlignment,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: activeGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Interactive Clickable Tab Items
          Row(
            children: [
              // Tab 0: Speed Math
              Expanded(
                child: _TabItem(
                  isSelected: currentSection == 0,
                  icon: Icons.bolt_rounded,
                  title: 'Speed Math',
                  subtitle: 'Practice Hub',
                  onTap: () {
                    if (currentSection != 0) {
                      HapticFeedback.selectionClick();
                      state.setAppSection(0);
                    }
                  },
                ),
              ),

              // Tab 1: Math Alarm
              Expanded(
                child: _TabItem(
                  isSelected: currentSection == 1,
                  icon: Icons.alarm_rounded,
                  title: 'Math Alarm',
                  subtitle: isAlarmActive ? alarmTimeStr : 'Alarm Off',
                  isDotActive: isAlarmActive,
                  onTap: () {
                    if (currentSection != 1) {
                      HapticFeedback.selectionClick();
                      state.setAppSection(1);
                    }
                  },
                ),
              ),

              // Tab 2: English Verbal
              Expanded(
                child: _TabItem(
                  isSelected: currentSection == 2,
                  icon: Icons.auto_stories_rounded,
                  title: 'English',
                  subtitle: 'Verbal Hub',
                  badgeText: 'LIVE',
                  onTap: () {
                    if (currentSection != 2) {
                      HapticFeedback.selectionClick();
                      state.setAppSection(2);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool isDotActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.isDotActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected ? Colors.white : Colors.white60;
    final Color titleColor = isSelected ? Colors.white : Colors.white70;
    final Color subColor = isSelected ? Colors.white.withValues(alpha: 0.85) : Colors.white38;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with scale spring
                AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  scale: isSelected ? 1.08 : 0.95,
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 7),

                // Text info
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: titleColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (isDotActive) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 5.5,
                            height: 5.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        if (badgeText != null) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: isSelected ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText!,
                              style: const TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
