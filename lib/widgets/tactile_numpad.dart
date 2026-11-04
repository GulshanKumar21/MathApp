import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Modern Tactile 3D Numpad for Speed Math drills and direct CAT / Bank exam calculation.
class TactileNumpad extends StatelessWidget {
  final ValueChanged<String> onDigitPress;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  final bool isCalculatorLayout;
  final VoidCallback? onToggleLayout;
  final bool showHelperRow;
  final bool isSubmitEnabled;
  final Color? submitColor;

  const TactileNumpad({
    super.key,
    required this.onDigitPress,
    required this.onBackspace,
    required this.onClear,
    required this.onSubmit,
    this.isCalculatorLayout = false,
    this.onToggleLayout,
    this.showHelperRow = true,
    this.isSubmitEnabled = true,
    this.submitColor,
  });

  @override
  Widget build(BuildContext context) {
    final row1 = isCalculatorLayout ? ['7', '8', '9'] : ['1', '2', '3'];
    final row3 = isCalculatorLayout ? ['1', '2', '3'] : ['7', '8', '9'];

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHelperRow) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onToggleLayout != null)
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onToggleLayout!();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCalculatorLayout ? Icons.calculate_outlined : Icons.dialpad_rounded,
                              size: 14,
                              color: AppTheme.cyan,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isCalculatorLayout ? '🧮 7-8-9 Calc' : '📱 1-2-3 Phone',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onClear();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear_all_rounded, size: 14, color: AppTheme.error),
                          SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _buildKeyRow(row1),
          const SizedBox(height: 10),
          _buildKeyRow(['4', '5', '6']),
          const SizedBox(height: 10),
          _buildKeyRow(row3),
          const SizedBox(height: 10),
          // Bottom Row: Backspace, 0, Submit
          Row(
            children: [
              Expanded(
                child: _buildTactileKey(
                  child: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 22),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onBackspace();
                  },
                  backgroundColor: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTactileKey(
                  child: const Text(
                    '0',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDigitPress('0');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTactileKey(
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
                  onTap: isSubmitEnabled
                      ? () {
                          HapticFeedback.heavyImpact();
                          onSubmit();
                        }
                      : null,
                  gradient: isSubmitEnabled
                      ? LinearGradient(
                          colors: [
                            submitColor ?? const Color(0xFF10B981),
                            (submitColor ?? const Color(0xFF10B981)).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  backgroundColor: isSubmitEnabled ? null : AppTheme.surfaceLight,
                  borderColor: isSubmitEnabled
                      ? (submitColor ?? AppTheme.accent).withValues(alpha: 0.6)
                      : Colors.white12,
                  hasGlow: isSubmitEnabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> digits) {
    return Row(
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _buildTactileKey(
              child: Text(
                digits[i],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              onTap: () {
                HapticFeedback.selectionClick();
                onDigitPress(digits[i]);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTactileKey({
    required Widget child,
    VoidCallback? onTap,
    Color? backgroundColor,
    Gradient? gradient,
    Color? borderColor,
    bool hasGlow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primaryLight.withValues(alpha: 0.25),
        highlightColor: Colors.white10,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    backgroundColor ?? const Color(0xFF1E293B),
                    backgroundColor != null
                        ? backgroundColor.withValues(alpha: 0.85)
                        : const Color(0xFF121B2A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? const Color(0xFF334155),
              width: 1.2,
            ),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: (submitColor ?? AppTheme.accent).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
