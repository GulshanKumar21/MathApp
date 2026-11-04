import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../services/in_app_payment_service.dart';

/// 100% Google Play Store Compliant In-App Purchase Checkout Sheet
/// Follows Google Play Developer Payments Policy (In-App Billing API).
/// Google Play automatically allows customers in India and worldwide to pay
/// via Google Pay (UPI), PhonePe, Paytm, RuPay/Debit/Credit Cards, NetBanking,
/// and Google Play Balance directly through the native Google Play bottom sheet.
class PaymentCheckoutSheet extends StatefulWidget {
  const PaymentCheckoutSheet({super.key});

  static Future<bool?> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaymentCheckoutSheet(),
    );

    if (context.mounted && result != null) {
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.verified_rounded, color: Colors.black),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🎉 PrepVanta PRO Activated for ₹49 Lifetime!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.gold,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
    return result;
  }

  @override
  State<PaymentCheckoutSheet> createState() => _PaymentCheckoutSheetState();
}

class _PaymentCheckoutSheetState extends State<PaymentCheckoutSheet> {
  bool _isProcessing = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        InAppPaymentService().initialize(context.read<AppStateProvider>());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final iapService = InAppPaymentService();

    // Dynamically retrieve formatted price from Google Play if loaded, else fallback to ₹49
    String displayPrice = '₹49.00';
    if (iapService.products.isNotEmpty) {
      final proProduct = iapService.products.firstWhere(
        (p) => p.id == InAppPaymentService.proProductId,
        orElse: () => iapService.products.first,
      );
      displayPrice = proProduct.price;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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

            // Header Banner
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.gold, Colors.amberAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 26),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PrepVanta PRO Upgrade',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        'Official Google Play In-App Purchase',
                        style: TextStyle(fontSize: 11.5, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    displayPrice.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.gold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // If user already owns PRO
            if (state.isPremium) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'You are a PrepVanta PRO Member!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Lifetime License is active on this device. All Vedic modules, timers, and mocks are fully unlocked.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Back to Practice 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // What you unlock pills
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Included in Lifetime PRO License:',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.accent),
                        ),
                        Text(
                          'One-Time Payment',
                          style: TextStyle(fontSize: 10.5, color: Colors.white54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _proCheckRow('⚡ Unlimited 2D×2D & 3D Multipliers (17×45+ with Vedic tricks)'),
                    _proCheckRow('🎯 Strict 2.5s Timed Exam Mocks (SSC CGL, Bank PO, RRB, CAT)'),
                    _proCheckRow('📚 Full 1-50 Tables, Powers & Pythagorean Triples'),
                    _proCheckRow('🎧 Variable-Speed Voice Recital Studio (Hands-free study)'),
                    _proCheckRow('🖨️ Printable High-Res PDF Revision Cheatsheets'),
                    _proCheckRow('🛡️ 100% Ad-Free & Offline Supported'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Official Google Play Billing Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF13192B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shop_two_rounded, color: Colors.greenAccent, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Google Play In-App Billing',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Play Store Official • 1-Tap Secure Checkout',
                                style: TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            'OFFICIAL',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 9.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: AppTheme.gold, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Supports: Google Pay, PhonePe, Paytm (UPI), RuPay/Cards, Net Banking & Play Balance.',
                              style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Security Guarantee
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: Colors.white54),
                  SizedBox(width: 6),
                  Text(
                    'Protected by Google Play Buyer Security • Instant Activation',
                    style: TextStyle(fontSize: 10.5, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Pay / Buy Button
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
                  onPressed: _isProcessing ? null : () => _executeGooglePlayPurchase(state),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Connecting to Google Play...',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                            ),
                          ],
                        )
                      : Text(
                          'Buy with Google Play ($displayPrice)',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.3),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Restore Purchases Row (Mandatory for Google Play & App Store policies)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _isRestoring ? null : () => _restorePurchases(state),
                    icon: _isRestoring
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.8, color: AppTheme.gold),
                          )
                        : const Icon(Icons.restore_rounded, size: 16, color: Colors.white70),
                    label: Text(
                      _isRestoring ? 'Checking Play Store...' : 'Already purchased? Restore Purchase',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('https://sites.google.com/view/prepvanta/home');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.security_rounded, size: 13, color: Colors.white38),
                  label: const Text(
                    'Privacy Policy & Terms (prepvanta)',
                    style: TextStyle(color: Colors.white38, fontSize: 11, decoration: TextDecoration.underline),
                  ),
                ),
              ),

              // Developer Testing Shortcut (Debug builds only; completely hidden in Play Store release)
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                Center(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                      side: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final success = await state.processPurchase(
                        userName: state.userName,
                        paymentMethod: 'Dev Test Sandbox Unlock',
                      );
                      if (mounted && success) {
                        nav.pop(true);
                      }
                    },
                    icon: const Icon(Icons.bug_report_rounded, size: 14),
                    label: const Text(
                      'Dev Sandbox: Simulate Pro Unlock',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Execute Google Play In-App Purchase Flow
  Future<void> _executeGooglePlayPurchase(AppStateProvider state) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isProcessing = true);

    try {
      final iap = InAppPaymentService();
      final isAvailable = await iap.checkAvailability();

      if (!isAvailable) {
        if (mounted) setState(() => _isProcessing = false);
        messenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Google Play Billing requires an Android device with Google Play Store installed and logged in.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF1E293B),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      final initiated = await iap.buyProProduct();
      if (mounted) setState(() => _isProcessing = false);

      if (initiated) {
        messenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Google Play checkout opened. Pro will activate automatically once Google confirms payment.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF065F46),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Could not connect to Google Play product. Ensure "speedmath_pro_lifetime_49" is active in Play Console.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      debugPrint('Google Play purchase trigger error: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  // Restore previous purchases (Required by Google Play and App Store review policies)
  Future<void> _restorePurchases(AppStateProvider state) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isRestoring = true);

    try {
      // 1. Check local/cloud ledger first
      final localRestored = await state.restorePurchases();
      if (localRestored) {
        if (mounted) setState(() => _isRestoring = false);
        nav.pop(true);
        return;
      }

      // 2. Query Google Play Billing for restored purchases
      await InAppPaymentService().restorePurchases();
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) setState(() => _isRestoring = false);

      if (state.isPremium) {
        nav.pop(true);
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No active Google Play purchase found for this account. Tap "Buy with Google Play" to unlock.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF1E293B),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isRestoring = false);
      debugPrint('Restore purchases error: $e');
    }
  }

  Widget _proCheckRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
