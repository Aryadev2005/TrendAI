// lib/presentation/widgets/pro_gate.dart
// ARIA — Reusable Pro gate widget
// Wrap any feature widget with ProGate to show paywall if not Pro
//
// Usage:
//   ProGate(child: RateCardScreen())
//   ProGate.button(context: context, label: 'Generate Rate Card', onProTap: () { ... })

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

// ── Wrap a full screen ────────────────────────────────────────────────────

class ProGate extends ConsumerWidget {
  final Widget child;
  final String? featureName;

  const ProGate({
    super.key,
    required this.child,
    this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(authProvider).user?.isPro ?? false;
    if (isPro) return child;
    return _ProLockedScreen(featureName: featureName);
  }

  // ── Factory: wrap a button ──────────────────────────────────────────────

  static Widget button({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required VoidCallback onProTap,
    IconData? icon,
    String? featureName,
  }) {
    final isPro = ref.watch(authProvider).user?.isPro ?? false;

    return GestureDetector(
      onTap: isPro
          ? onProTap
          : () => _navigateToPaywall(context, featureName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPro
              ? const Color.fromARGB(255, 59, 188, 226)
              : const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: isPro ? 1 : 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                isPro ? icon : Icons.lock_outline,
                color: isPro ? Colors.white : const Color.fromARGB(255, 59, 188, 226),
                size: 16,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isPro ? Colors.white : const Color.fromARGB(255, 59, 188, 226),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isPro) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 59, 188, 226),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void _navigateToPaywall(BuildContext context, String? featureName) {
    context.push(AppRoutes.paywall);
  }
}

// ── Locked screen shown when not Pro ─────────────────────────────────────

class _ProLockedScreen extends StatelessWidget {
  final String? featureName;

  const _ProLockedScreen({this.featureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 59, 188, 226).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color.fromARGB(255, 59, 188, 226),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                featureName != null
                    ? '$featureName is a Pro feature'
                    : 'Pro Feature',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Upgrade to ARIA Pro to unlock this and all other features.',
                style: TextStyle(
                  color: AppColors.textMid,
                  fontSize: 15,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.paywall),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 59, 188, 226),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Go back',
                  style: TextStyle(color: AppColors.textMid),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pro badge chip (use in profile, dashboard, etc.) ─────────────────────

class ProBadge extends StatelessWidget {
  final bool compact;

  const ProBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 59, 188, 226),
            Color.fromARGB(255, 41, 167, 206),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: Colors.white, size: compact ? 10 : 12),
          SizedBox(width: compact ? 2 : 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
