// lib/presentation/screens/video_dna/video_dna_screen.dart
// ARIA Video DNA — Paste any YouTube / Shorts link, get ARIA's full analysis.
// Route: /video-dna  (add to AppRoutes + GoRouter)
// Nav: accessible from Profile screen "Analyse a Video" menu item
//      OR from dashboard "ARIA Tools" card
//
// Design: matches bgPrimary #F5F0E8 warm cream system, DM Serif Display + DM Sans

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/controllers/video_dna_controller.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';

class VideoDnaScreen extends ConsumerStatefulWidget {
  const VideoDnaScreen({super.key});
  @override
  ConsumerState<VideoDnaScreen> createState() => _VideoDnaScreenState();
}

class _VideoDnaScreenState extends ConsumerState<VideoDnaScreen>
    with TickerProviderStateMixin {
  final _urlController = TextEditingController();
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoDnaProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildUrlInput(state),
                  const SizedBox(height: 16),
                  _buildAnalyseButton(state),
                  const SizedBox(height: 32),

                  // States
                  if (state.isLoading) _buildLoadingState(),
                  if (state.error != null && !state.isLoading)
                    _buildErrorState(state.error!),
                  if (state.result != null && !state.isLoading)
                    _buildResults(state.result!),

                  // Empty state — show when no analysis yet
                  if (state.result == null && !state.isLoading && state.error == null)
                    _buildEmptyState(),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: BottomNav(currentIndex: -1), // -1 = no active tab
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textDark, size: 18),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video DNA',
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.textDark,
                fontSize: AppDimensions.fontXL,
                height: 1.1,
              ),
            ),
            Text(
              'Deep-analyse any YouTube video with ARIA',
              style: GoogleFonts.dmSans(
                color: AppColors.textMid,
                fontSize: AppDimensions.fontXS,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 12),
              const SizedBox(width: 3),
              Text(
                'PRO',
                style: GoogleFonts.dmSans(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── URL Input ─────────────────────────────────────────────────────────────
  Widget _buildUrlInput(VideoDnaState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PASTE YOUR LINK',
        style: GoogleFonts.dmSans(
          color: AppColors.textMid,
          fontSize: AppDimensions.fontXS,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: _urlController.text.isNotEmpty
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.link_rounded, color: AppColors.textLight, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _urlController,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _triggerAnalysis(state),
                style: GoogleFonts.dmSans(
                  color: AppColors.textDark,
                  fontSize: AppDimensions.fontSM,
                ),
                decoration: InputDecoration(
                  hintText: 'youtube.com/watch?v=... or youtu.be/...',
                  hintStyle: GoogleFonts.dmSans(
                    color: AppColors.textLight,
                    fontSize: AppDimensions.fontSM,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            if (_urlController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _urlController.clear();
                  setState(() {});
                  ref.read(videoDnaProvider.notifier).clear();
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.textLight, size: 18),
                ),
              )
            else
              GestureDetector(
                onTap: _pasteFromClipboard,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Text(
                    'Paste',
                    style: GoogleFonts.dmSans(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // Platform chips
      Row(
        children: [
          _platformChip(Icons.play_circle_fill_rounded, 'YouTube', Colors.red),
          const SizedBox(width: 8),
          _platformChip(Icons.play_arrow_rounded, 'Shorts', Colors.red),
          const Spacer(),
          Text(
            'Instagram coming soon',
            style: GoogleFonts.dmSans(
              color: AppColors.textLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _platformChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.dmSans(
          color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  // ── Analyse Button ────────────────────────────────────────────────────────
  Widget _buildAnalyseButton(VideoDnaState state) => GestureDetector(
    onTap: state.isLoading ? null : () => _triggerAnalysis(state),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: _urlController.text.trim().isNotEmpty && !state.isLoading
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        boxShadow: _urlController.text.trim().isNotEmpty && !state.isLoading
            ? [BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )]
            : [],
      ),
      child: Center(
        child: state.isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.biotech_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Analyse with ARIA',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: AppDimensions.fontMD,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );

  // ── Loading State ─────────────────────────────────────────────────────────
  Widget _buildLoadingState() => Column(
    children: [
      const SizedBox(height: 40),
      Center(
        child: ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.biotech_rounded,
                color: AppColors.primary, size: 32),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'ARIA is reading the DNA...',
        style: GoogleFonts.dmSerifDisplay(
          color: AppColors.textDark,
          fontSize: AppDimensions.fontLG,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        'Pulling stats, analysing hook, benchmarking performance',
        style: GoogleFonts.dmSans(
          color: AppColors.textMid,
          fontSize: AppDimensions.fontSM,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      ..._loadingSteps(),
    ],
  );

  List<Widget> _loadingSteps() {
    final steps = [
      'Fetching video metadata from YouTube',
      'Benchmarking against your niche',
      'Analysing hook strength',
      'Generating ARIA recommendations',
    ];
    return steps.asMap().entries.map((e) => _loadingStep(e.key, e.value)).toList();
  }

  Widget _loadingStep(int index, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: Center(
            child: Text('${index + 1}',
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
            style: GoogleFonts.dmSans(
              color: AppColors.textMid, fontSize: AppDimensions.fontSM)),
        ),
      ],
    ),
  );

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Column(
    children: [
      const SizedBox(height: 32),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: const Icon(Icons.analytics_outlined,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'What Video DNA shows you',
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.textDark, fontSize: AppDimensions.fontLG),
            ),
            const SizedBox(height: 16),
            ..._emptyFeatures(),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _exampleCard(),
    ],
  );

  List<Widget> _emptyFeatures() {
    final features = [
      ('📊', 'Performance score vs your niche average'),
      ('🎣', 'Hook strength — first 3 seconds rated'),
      ('📈', 'Views / likes / comments benchmarked'),
      ('🏷️', 'Title SEO vs trending search terms'),
      ('🎵', 'Audio strategy analysis'),
      ('🚀', 'ARIA\'s "make this better" action plan'),
    ];
    return features.map((f) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(f.$1, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(f.$2,
              style: GoogleFonts.dmSans(
                color: AppColors.textMid, fontSize: AppDimensions.fontSM)),
          ),
        ],
      ),
    )).toList();
  }

  Widget _exampleCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        const Icon(Icons.lightbulb_outline_rounded,
            color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Try pasting a competitor\'s video to see what\'s working in your niche',
            style: GoogleFonts.dmSans(
              color: AppColors.primaryDark,
              fontSize: AppDimensions.fontSM,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildErrorState(String error) => Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.error.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      border: Border.all(color: AppColors.error.withOpacity(0.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Could not analyse this video',
                style: GoogleFonts.dmSans(
                  color: AppColors.error,
                  fontSize: AppDimensions.fontSM,
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(error,
                style: GoogleFonts.dmSans(
                  color: AppColors.textMid,
                  fontSize: AppDimensions.fontXS)),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Results ───────────────────────────────────────────────────────────────
  Widget _buildResults(VideoDnaResult result) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _videoPreviewCard(result),
      const SizedBox(height: 20),
      _overallScoreCard(result),
      const SizedBox(height: 16),
      _metricsRow(result),
      const SizedBox(height: 16),
      _hookAnalysisCard(result),
      const SizedBox(height: 16),
      _titleSeoCard(result),
      const SizedBox(height: 16),
      _performanceBenchmarkCard(result),
      const SizedBox(height: 16),
      _ariaRecommendationCard(result),
      const SizedBox(height: 16),
      _nextVideoCard(result),
    ],
  );

  // ── Video Preview Card ────────────────────────────────────────────────────
  Widget _videoPreviewCard(VideoDnaResult r) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          child: r.thumbnailUrl != null
              ? Image.network(r.thumbnailUrl!,
                  width: 90, height: 60, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _thumbFallback())
              : _thumbFallback(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.videoTitle,
                style: GoogleFonts.dmSans(
                  color: AppColors.textDark,
                  fontSize: AppDimensions.fontSM,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    color: AppColors.textLight, size: 11),
                const SizedBox(width: 4),
                Text(r.publishedAt,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textLight, fontSize: 10)),
                const SizedBox(width: 10),
                Icon(Icons.timer_outlined,
                    color: AppColors.textLight, size: 11),
                const SizedBox(width: 4),
                Text(r.duration,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textLight, fontSize: 10)),
              ]),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _thumbFallback() => Container(
    width: 90, height: 60,
    decoration: BoxDecoration(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
    ),
    child: const Icon(Icons.play_circle_outline_rounded,
        color: AppColors.textLight, size: 28),
  );

  // ── Overall Score ─────────────────────────────────────────────────────────
  Widget _overallScoreCard(VideoDnaResult r) {
    final scoreColor = r.overallScore >= 75 ? AppColors.rising
        : r.overallScore >= 50 ? AppColors.primary
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        children: [
          // Score ring
          SizedBox(
            width: 72, height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: r.overallScore / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
                Text('${r.overallScore}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.white, fontSize: 22)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall DNA Score',
                  style: GoogleFonts.dmSans(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(r.scoreVerdict,
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.white, fontSize: 18)),
                const SizedBox(height: 6),
                Text(r.scoreSummary,
                  style: GoogleFonts.dmSans(
                    color: Colors.white54,
                    fontSize: AppDimensions.fontXS,
                    height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Metrics Row ───────────────────────────────────────────────────────────
  Widget _metricsRow(VideoDnaResult r) => Row(
    children: [
      Expanded(child: _metricTile('Views', r.viewCount, Icons.visibility_outlined)),
      const SizedBox(width: 10),
      Expanded(child: _metricTile('Likes', r.likeCount, Icons.thumb_up_outlined)),
      const SizedBox(width: 10),
      Expanded(child: _metricTile('Comments', r.commentCount, Icons.comment_outlined)),
    ],
  );

  Widget _metricTile(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(height: 8),
        Text(value,
          style: GoogleFonts.dmSerifDisplay(
            color: AppColors.textDark, fontSize: AppDimensions.fontLG)),
        Text(label,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 10,
            fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ],
    ),
  );

  // ── Hook Analysis ─────────────────────────────────────────────────────────
  Widget _hookAnalysisCard(VideoDnaResult r) => _sectionCard(
    icon: Icons.flash_on_rounded,
    label: 'HOOK STRENGTH',
    score: r.hookScore,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _scoreBar(r.hookScore),
        const SizedBox(height: 12),
        Text(r.hookAnalysis,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid,
            fontSize: AppDimensions.fontSM, height: 1.5)),
        if (r.improvedHook != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rising.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(color: AppColors.rising.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ARIA\'S STRONGER HOOK',
                  style: GoogleFonts.dmSans(
                    color: AppColors.rising,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text('"${r.improvedHook!}"',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textDark,
                    fontSize: AppDimensions.fontSM,
                    fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ],
    ),
  );

  // ── Title SEO Card ────────────────────────────────────────────────────────
  Widget _titleSeoCard(VideoDnaResult r) => _sectionCard(
    icon: Icons.search_rounded,
    label: 'TITLE SEO',
    score: r.titleScore,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _scoreBar(r.titleScore),
        const SizedBox(height: 12),
        Text(r.titleAnalysis,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid,
            fontSize: AppDimensions.fontSM, height: 1.5)),
        if (r.betterTitle != null) ...[
          const SizedBox(height: 10),
          _suggestionPill('Better title: ${r.betterTitle!}'),
        ],
      ],
    ),
  );

  // ── Performance Benchmark Card ────────────────────────────────────────────
  Widget _performanceBenchmarkCard(VideoDnaResult r) => _sectionCard(
    icon: Icons.bar_chart_rounded,
    label: 'NICHE BENCHMARK',
    score: r.benchmarkScore,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _scoreBar(r.benchmarkScore),
        const SizedBox(height: 12),
        Text(r.benchmarkAnalysis,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid,
            fontSize: AppDimensions.fontSM, height: 1.5)),
        if (r.benchmarkStats.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...r.benchmarkStats.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.6)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(s,
                style: GoogleFonts.dmSans(
                  color: AppColors.textMid,
                  fontSize: AppDimensions.fontXS))),
            ]),
          )),
        ],
      ],
    ),
  );

  // ── ARIA Recommendation Card ──────────────────────────────────────────────
  Widget _ariaRecommendationCard(VideoDnaResult r) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      border: Border.all(color: AppColors.primary.withOpacity(0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text('ARIA SAYS',
              style: GoogleFonts.dmSans(
                color: Colors.white, fontSize: 10,
                fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
        ]),
        const SizedBox(height: 14),
        Text(r.ariaInsight,
          style: GoogleFonts.dmSans(
            color: AppColors.textDark,
            fontSize: AppDimensions.fontMD,
            fontWeight: FontWeight.w600, height: 1.5)),
        if (r.actionItems.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...r.actionItems.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                      style: GoogleFonts.dmSans(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textMid,
                    fontSize: AppDimensions.fontSM,
                    height: 1.4))),
              ],
            ),
          )),
        ],
      ],
    ),
  );

  // ── Next Video Card ───────────────────────────────────────────────────────
  Widget _nextVideoCard(VideoDnaResult r) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.textDark,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR NEXT VIDEO',
          style: GoogleFonts.dmSans(
            color: Colors.white38, fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Text(r.nextVideoSuggestion,
          style: GoogleFonts.dmSerifDisplay(
            color: Colors.white, fontSize: AppDimensions.fontLG, height: 1.3)),
        const SizedBox(height: 8),
        Text(r.nextVideoReason,
          style: GoogleFonts.dmSans(
            color: Colors.white54,
            fontSize: AppDimensions.fontSM, height: 1.5)),
      ],
    ),
  );

  // ── Shared section card ───────────────────────────────────────────────────
  Widget _sectionCard({
    required IconData icon,
    required String label,
    required int score,
    required Widget child,
  }) {
    final scoreColor = score >= 75 ? AppColors.rising
        : score >= 50 ? AppColors.primary
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Text(label,
              style: GoogleFonts.dmSans(
                color: AppColors.textMid, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 1)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text('$score / 100',
                style: GoogleFonts.dmSans(
                  color: scoreColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _scoreBar(int score) {
    final scoreColor = score >= 75 ? AppColors.rising
        : score >= 50 ? AppColors.primary
        : AppColors.error;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: LinearProgressIndicator(
        value: score / 100,
        minHeight: 6,
        backgroundColor: AppColors.bgSurface,
        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
      ),
    );
  }

  Widget _suggestionPill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(text,
      style: GoogleFonts.dmSans(
        color: AppColors.textMid, fontSize: AppDimensions.fontXS)),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
      setState(() {});
    }
  }

  void _triggerAnalysis(VideoDnaState state) {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    ref.read(videoDnaProvider.notifier).analyseVideo(url);
  }
}
