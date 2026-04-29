// lib/presentation/screens/discover/discover_screen.dart
// ARIA Discover — "What to make"
// Niche chips | ARIA Top Pick | Opportunity feed | Competitor moves | Festival boosts

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/radar_model.dart';
import '../../../presentation/controllers/discover_controller.dart';
import '../../../presentation/controllers/aria_session_controller.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../routes/app_routes.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});
  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _niches = ['All', 'Fashion', 'Finance', 'Food', 'Travel', 'Comedy', 'Fitness', 'Tech'];
  final _badges = ['ALL', 'HOT', 'RISING', 'NEW'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(discoverProvider.notifier).fetchIntelligence());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  _nicheChips(state),
                  _badgeFilter(state),
                  if (state.isLoading)
                    _loadingView()
                  else if (state.error != null)
                    _errorView(state.error!)
                  else
                    _content(state),
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(currentIndex: 1)),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover',
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.textDark,
                fontSize: AppDimensions.fontXL,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Find trending ideas before they explode',
              style: GoogleFonts.dmSans(
                color: AppColors.textMid,
                fontSize: AppDimensions.fontSM,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => ref.read(discoverProvider.notifier).retry(),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    ),
  );

  // ─── Niche chips ─────────────────────────────────────────────────────────
  Widget _nicheChips(DiscoverState state) => SizedBox(
    height: 44,
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      scrollDirection: Axis.horizontal,
      itemCount: _niches.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final selected = _niches[i] == state.selectedNiche;
        return GestureDetector(
          onTap: () => ref.read(discoverProvider.notifier).selectNiche(_niches[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              _niches[i],
              style: GoogleFonts.dmSans(
                color: selected ? Colors.white : AppColors.textMid,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    ),
  );

  // ─── Badge filter ────────────────────────────────────────────────────────
  Widget _badgeFilter(DiscoverState state) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(
      children: _badges.map((b) {
        final selected = b == state.selectedBadge;
        return Expanded(
          child: GestureDetector(
            onTap: () => ref.read(discoverProvider.notifier).selectBadge(b),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                b,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: selected ? AppColors.primary : AppColors.textMid,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  // ─── Main content ─────────────────────────────────────────────────────────
  Widget _content(DiscoverState state) {
    final intel = state.intelligence;
    if (intel == null) return _emptyView();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        if (intel.festivalBoosts.isNotEmpty) ...[
          _sectionLabel('🎉 FESTIVAL BOOSTS', '${intel.festivalBoosts.length}'),
          const SizedBox(height: 8),
          ...(intel.festivalBoosts.take(2).map((f) => Column(
            children: [_festivalBanner(f), const SizedBox(height: 12)],
          ))),
        ],
        _sectionLabel('✨ ARIA TOP PICK', 'Your best shot'),
        const SizedBox(height: 8),
        _ariaTopPickCard(intel.ariaTopPick),
        const SizedBox(height: 20),
        _sectionLabel('🚀 OPPORTUNITIES', '${state.filteredOpportunities.length}'),
        const SizedBox(height: 8),
        ...(state.filteredOpportunities.map((opp) => Column(
          children: [_opportunityCard(opp), const SizedBox(height: 12)],
        ))),
        const SizedBox(height: 20),
        if (intel.competitorMoves.isNotEmpty) ...[
          _sectionLabel('👀 WHAT COMPETITORS ARE DOING', '${intel.competitorMoves.length}'),
          const SizedBox(height: 8),
          ...(intel.competitorMoves.map((m) => _competitorCard(m))),
        ],
      ],
    );
  }

  // ─── Festival Banner ──────────────────────────────────────────────────────
  Widget _festivalBanner(FestivalBoost f) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              f.name,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${f.daysUntil} days away • ${f.windowDays}d window',
              style: GoogleFonts.dmSans(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (f.isUrgent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.hot,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'URGENT',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    ),
  );

  // ─── ARIA Top Pick ────────────────────────────────────────────────────────
  Widget _ariaTopPickCard(AriaTopPick pick) => Container(
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
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'TOP PICK',
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${pick.peakWindowHours}h window',
            style: GoogleFonts.dmSans(
              color: AppColors.textMid,
              fontSize: 11,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Text(
          pick.title,
          style: GoogleFonts.dmSerifDisplay(
            color: AppColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pick.reason,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pick.urgency == 'high' ? AppColors.hot
                    : pick.urgency == 'medium' ? AppColors.rising
                    : AppColors.newBadge,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pick.urgency.toUpperCase(),
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ref.read(ariaSessionProvider.notifier).setIdea(pick.title);
                context.go(AppRoutes.studio);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Create now',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ─── Opportunity Card ─────────────────────────────────────────────────────
  Widget _opportunityCard(RadarOpportunity opp) {
    final badgeColor = opp.badge == 'HOT' ? AppColors.hot
        : opp.badge == 'RISING' ? AppColors.rising
        : AppColors.newBadge;

    return GestureDetector(
      onTap: () => _showOpportunityDetail(opp),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    opp.title,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    opp.badge,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              opp.description,
              style: GoogleFonts.dmSans(
                color: AppColors.textMid,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _scoreColor(opp.opportunityScore).withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Text(
                          '${opp.opportunityScore}',
                          style: GoogleFonts.dmSans(
                            color: _scoreColor(opp.opportunityScore),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Score',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textMid,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  opp.estimatedViews,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textMid,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Competitor card ──────────────────────────────────────────────────────
  Widget _competitorCard(CompetitorMove move) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          move.description,
          style: GoogleFonts.dmSans(
            color: AppColors.textLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _detailRow('Engagement', move.engagement),
            ),
            Expanded(
              child: _detailRow('Gap', move.gap),
            ),
          ],
        ),
      ],
    ),
  );

  // ─── Section label ────────────────────────────────────────────────────────
  Widget _sectionLabel(String title, String sub) => Row(
    children: [
      Text(title, style: GoogleFonts.dmSans(
        color: AppColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.w700, letterSpacing: 1.5)),
      const SizedBox(width: 8),
      Text(sub, style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 11)),
    ],
  );

  // ─── Opportunity Detail Bottom Sheet ──────────────────────────────────────
  void _showOpportunityDetail(RadarOpportunity opp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                opp.title,
                style: GoogleFonts.dmSerifDisplay(
                  color: AppColors.textDark,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Angle', opp.angle),
              _detailRow('Hook', opp.hookSuggestion),
              _detailRow('Niche Source', opp.nicheSource),
              _detailRow('Peak Window', '${opp.peakWindowHours}h'),
              _detailRow('Est. Views', opp.estimatedViews),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    ref.read(ariaSessionProvider.notifier).setIdea(
                      opp.title,
                      trendContext: {
                        'angle': opp.angle,
                        'hook': opp.hookSuggestion,
                        'niche': opp.nicheSource,
                      },
                    );
                    Navigator.pop(context);
                    context.go(AppRoutes.studio);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Start Creating',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              color: AppColors.textLight,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Color _scoreColor(int score) => score >= 80 ? AppColors.rising
      : score >= 60 ? AppColors.primary
      : AppColors.textMid;

  Widget _loadingView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Scanning for trends...',
          style: GoogleFonts.dmSans(color: AppColors.textMid),
        ),
      ],
    ),
  );

  Widget _errorView(String error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Could not load opportunities',
            style: GoogleFonts.dmSans(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.dmSans(
              color: AppColors.textMid,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => ref.read(discoverProvider.notifier).retry(),
            child: Text(
              'Retry',
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyView() => Center(
    child: Text('No opportunities found. Try refreshing.',
      style: GoogleFonts.dmSans(color: AppColors.textMid)),
  );
}
