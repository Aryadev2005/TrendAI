// lib/presentation/screens/dashboard/dashboard_screen.dart
// ARIA Dashboard — Home screen with 3-phase cards + ARIA daily brief
// Redesigned: DISCOVER / STUDIO / LAUNCH phase cards replace old trend feed

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/aria_session_controller.dart';
import '../../../routes/app_routes.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState  = ref.watch(authProvider);
    final session    = ref.watch(ariaSessionProvider);
    final userName   = authState.user?.name.split(' ').first ?? 'Creator';
    final hour       = DateTime.now().hour;
    final greeting   = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background blob
          Positioned(
            top: -60, right: -50,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(userName, greeting),
                  const SizedBox(height: 24),
                  _ariaBrief(session),
                  const SizedBox(height: 28),
                  _sectionLabel('YOUR WORKFLOW TODAY'),
                  const SizedBox(height: 14),
                  _phaseCard(
                    context: context,
                    phase: 'DISCOVER',
                    emoji: '🔍',
                    title: 'What to make',
                    subtitle: 'Niche trends, viral angles,\ncompetitor moves — 48hrs early',
                    badge: 'HOT',
                    badgeColor: AppColors.hot,
                    route: AppRoutes.discover,
                    gradientColors: [const Color(0xFFFFEDE0), const Color(0xFFFAF7F2)],
                    isActive: true,
                  ),
                  const SizedBox(height: 12),
                  _phaseCard(
                    context: context,
                    phase: 'STUDIO',
                    emoji: '🎬',
                    title: 'How to make it',
                    subtitle: 'Script builder, BGM matcher,\nediting help — without losing your voice',
                    badge: session.hasIdea ? 'READY' : 'START DISCOVER',
                    badgeColor: session.hasIdea ? AppColors.rising : AppColors.textMid,
                    route: AppRoutes.studio,
                    gradientColors: [const Color(0xFFE8F5ED), const Color(0xFFFAF7F2)],
                    isActive: session.hasIdea,
                  ),
                  const SizedBox(height: 12),
                  _phaseCard(
                    context: context,
                    phase: 'LAUNCH',
                    emoji: '🚀',
                    title: 'Drop it right',
                    subtitle: 'Timing intelligence, posting package,\nbrand deal alerts',
                    badge: session.hasScript ? 'READY' : 'FINISH STUDIO',
                    badgeColor: session.hasScript ? AppColors.primary : AppColors.textMid,
                    route: AppRoutes.launch,
                    gradientColors: [const Color(0xFFEDE8FF), const Color(0xFFFAF7F2)],
                    isActive: session.hasScript,
                  ),
                  const SizedBox(height: 28),
                  _sectionLabel('ARIA TOOLS'),
                  const SizedBox(height: 14),
                  _videoDnaCard(context),
                  const SizedBox(height: 24),
                  _sectionLabel('ARIA STATS'),
                  const SizedBox(height: 14),
                  _statsRow(),
                  const SizedBox(height: 24),
                  _quickTip(),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: BottomNav(currentIndex: 0),
          ),
        ],
      ),
    );
  }

  Widget _topBar(String name, String greeting) => Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting 👋',
            style: GoogleFonts.dmSans(
              color: AppColors.textMid,
              fontSize: AppDimensions.fontSM,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Hi, $name!',
            style: GoogleFonts.dmSerifDisplay(
              color: AppColors.textDark,
              fontSize: AppDimensions.fontXL,
            ),
          ),
        ],
      ),
      const Spacer(),
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
      ),
    ],
  );

  Widget _ariaBrief(AriaSession session) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.textDark,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ARIA DAILY BRIEF',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
        ]),
        const SizedBox(height: 12),
        Text(
          session.hasIdea
              ? '"${session.idea}" is locked. Head to Studio to build it out.'
              : '"Go viral. Before it\'s a trend." — Start with Discover to find your next winning idea.',
          style: GoogleFonts.dmSans(
            color: AppColors.textPrimary,
            fontSize: AppDimensions.fontMD,
            height: 1.5,
          ),
        ),
        if (session.hasIdea) ...[
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.check_circle, color: AppColors.rising, size: 14),
            const SizedBox(width: 6),
            Text(
              'Idea locked → niche: ${session.niche ?? 'general'} · ${session.platform ?? 'Instagram'}',
              style: GoogleFonts.dmSans(
                color: AppColors.textMuted,
                fontSize: AppDimensions.fontXS,
              ),
            ),
          ]),
        ],
      ],
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.dmSans(
      color: AppColors.textMid,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    ),
  );

  Widget _phaseCard({
    required BuildContext context,
    required String phase,
    required String emoji,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required String route,
    required List<Color> gradientColors,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedOpacity(
        opacity: isActive || phase == 'DISCOVER' ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        phase,
                        style: GoogleFonts.dmSans(
                          color: AppColors.textMid,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.dmSans(
                            color: badgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.dmSerifDisplay(
                        color: AppColors.textDark,
                        fontSize: AppDimensions.fontLG,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        color: AppColors.textMid,
                        fontSize: AppDimensions.fontXS,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsRow() => Row(
    children: [
      _statChip('48h', 'Trend lead'),
      const SizedBox(width: 10),
      _statChip('₹499', 'Pro/month'),
      const SizedBox(width: 10),
      _statChip('12', 'Creator tools'),
    ],
  );

  Widget _statChip(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              color: AppColors.primary,
              fontSize: AppDimensions.fontLG,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: AppColors.textMid,
              fontSize: AppDimensions.fontXS,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _quickTip() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        const Text('💡', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Friday 7:30 PM IST is your best posting window this week.',
            style: GoogleFonts.dmSans(
              color: AppColors.textDark,
              fontSize: AppDimensions.fontSM,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _videoDnaCard(BuildContext context) => GestureDetector(
    onTap: () => context.push(AppRoutes.videoDna),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video DNA',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textDark,
                    fontSize: AppDimensions.fontMD,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analyse any YouTube video',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textMid,
                    fontSize: AppDimensions.fontXS,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.textLight,
            size: 18,
          ),
        ],
      ),
    ),
  );
}
