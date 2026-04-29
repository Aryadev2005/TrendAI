// lib/presentation/screens/subscription/paywall_screen.dart
// ARIA — Pro Paywall Screen
// Route: /paywall

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/subscription_controller.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with TickerProviderStateMixin {
  bool _isAnnual = true; // Default to annual (better value)
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(subscriptionProvider);

    // Navigate away if already pro
    ref.listen(subscriptionProvider, (_, next) {
      if (next.isPro && next.successMessage != null) {
        _showSuccess(next.successMessage!);
        ref.read(subscriptionProvider.notifier).clearSuccess();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && context.mounted) context.pop();
        });
      }
      if (next.error != null && next.error!.isNotEmpty) {
        _showError(next.error!);
        ref.read(subscriptionProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildHeroSection(),
                      const SizedBox(height: 32),
                      _buildFeatureList(),
                      const SizedBox(height: 32),
                      _buildPricingToggle(),
                      const SizedBox(height: 20),
                      _buildPricingCard(sub),
                      const SizedBox(height: 24),
                      _buildCTAButton(sub),
                      const SizedBox(height: 16),
                      _buildRestoreButton(sub),
                      const SizedBox(height: 24),
                      _buildLegalText(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: AppColors.textMid, size: 22),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '⭐ LIMITED OFFER',
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return Column(
      children: [
        // ARIA logo mark
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome,
              color: Color.fromARGB(255, 59, 188, 226),
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Go Pro with ARIA',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'India\'s smartest creator tool.\nGrow faster, earn more.',
          style: TextStyle(
            color: AppColors.textMid,
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Feature list ─────────────────────────────────────────────────────────

  Widget _buildFeatureList() {
    final features = [
      ('Unlimited trend lookups + Viral Radar', Icons.trending_up),
      ('ARIA Brain — unlimited AI chat', Icons.auto_awesome),
      ('Script generator + BGM suggestions', Icons.movie_creation_outlined),
      ('Content calendar — all months', Icons.calendar_month_outlined),
      ('Rate card generator', Icons.price_change_outlined),
      ('48hr performance follow-up', Icons.notifications_active_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: features.map((f) => _featureRow(f.$1, f.$2)).toList(),
      ),
    );
  }

  Widget _featureRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color.fromARGB(255, 59, 188, 226), size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.check_circle, color: Color.fromARGB(255, 59, 188, 226), size: 18),
        ],
      ),
    );
  }

  // ── Pricing toggle ───────────────────────────────────────────────────────

  Widget _buildPricingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          _togglePill('Monthly', !_isAnnual, () => setState(() => _isAnnual = false)),
          _togglePill('Yearly  🔥', _isAnnual, () => setState(() => _isAnnual = true)),
        ],
      ),
    );
  }

  Widget _togglePill(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 59, 188, 226)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMid,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Pricing card ─────────────────────────────────────────────────────────

  Widget _buildPricingCard(SubscriptionState sub) {
    if (_isAnnual) {
      return _annualCard(sub.annualPrice);
    } else {
      return _monthlyCard(sub.monthlyPrice);
    }
  }

  Widget _monthlyCard(String price) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Plan',
                style: TextStyle(
                  color: AppColors.textMid,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Best for trying',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color.fromARGB(255, 59, 188, 226),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '/month',
                style: TextStyle(
                  color: AppColors.textMid,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _annualCard(String price) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 59, 188, 226),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Annual Plan',
                    style: TextStyle(
                      color: AppColors.textMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Most popular ⭐',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SAVE 50%',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.1),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Billed once yearly',
                style: TextStyle(
                  color: AppColors.textMid,
                  fontSize: 12,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Color.fromARGB(255, 59, 188, 226),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CTA button ───────────────────────────────────────────────────────────

  Widget _buildCTAButton(SubscriptionState sub) {
    final label = _isAnnual
        ? 'Start Pro — ₹5,000/year'
        : 'Start Pro — ₹499/month';

    final isLoading = sub.isPurchasing;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (_isAnnual) {
                  ref.read(subscriptionProvider.notifier).purchaseAnnual();
                } else {
                  ref.read(subscriptionProvider.notifier).purchaseMonthly();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 59, 188, 226),
          disabledBackgroundColor: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ── Restore button ───────────────────────────────────────────────────────

  Widget _buildRestoreButton(SubscriptionState sub) {
    return TextButton(
      onPressed: sub.isRestoring
          ? null
          : () => ref.read(subscriptionProvider.notifier).restorePurchases(),
      child: sub.isRestoring
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textMid),
              ),
            )
          : const Text(
              'Restore Purchase',
              style: TextStyle(
                color: AppColors.textMid,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }

  // ── Legal ────────────────────────────────────────────────────────────────

  Widget _buildLegalText() {
    return const Text(
      'Subscriptions auto-renew unless cancelled 24 hours before renewal. Manage in App Store / Play Store settings.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textMid,
        fontSize: 10,
        height: 1.5,
      ),
    );
  }

  // ── Snackbars ────────────────────────────────────────────────────────────

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6BAF7A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted || message.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
