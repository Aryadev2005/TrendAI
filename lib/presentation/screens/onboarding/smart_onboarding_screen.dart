// lib/presentation/screens/onboarding/smart_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/controllers/onboarding_controller.dart';
import '../../../routes/app_routes.dart';

class SmartOnboardingScreen extends ConsumerStatefulWidget {
  const SmartOnboardingScreen({super.key});

  @override
  ConsumerState<SmartOnboardingScreen> createState() =>
      _SmartOnboardingScreenState();
}

class _SmartOnboardingScreenState extends ConsumerState<SmartOnboardingScreen>
    with TickerProviderStateMixin {
  late TextEditingController _handleCtrl;
  late AnimationController _scanAnimCtrl;

  @override
  void initState() {
    super.initState();
    _handleCtrl = TextEditingController();
    _scanAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _handleCtrl.dispose();
    _scanAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: switch (onboardingState.step) {
        OnboardingStep.platformSelect => _buildPlatformSelect(context),
        OnboardingStep.handleInput => _buildHandleInput(context),
        OnboardingStep.scraping => _buildScraping(context),
        OnboardingStep.analysis => _buildAnalysis(context),
        OnboardingStep.nicheConfirm => _buildNicheConfirm(context),
        OnboardingStep.done => _buildDone(context),
      },
    );
  }

  // ===== STEP 1: Platform Select =====
  Widget _buildPlatformSelect(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);
    const platforms = ['instagram', 'youtube', 'twitter', 'tiktok'];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Where do you create?',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 36,
                color: AppColors.textDark,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Connect your social handle to unlock personalized insights powered by ARIA.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ...platforms.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _platformCard(p, notifier),
            )),
          ],
        ),
      ),
    );
  }

  Widget _platformCard(String platform, OnboardingNotifier notifier) {
    final platformNames = {
      'instagram': '📸 Instagram',
      'youtube': '▶️ YouTube',
      'twitter': '𝕏 X (Twitter)',
      'tiktok': '🎵 TikTok',
    };

    return GestureDetector(
      onTap: () => notifier.selectPlatform(platform),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        child: Row(
          children: [
            Text(
              platformNames[platform]!,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 2: Handle Input =====
  Widget _buildHandleInput(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () =>
                  notifier.selectPlatform(''), // Reset to platform select
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textDark, size: 18),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "What's your handle?",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 36,
                color: AppColors.textDark,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your ${onboardingState.selectedPlatform} username (with or without @)',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _handleCtrl,
              onChanged: (val) => notifier.setHandle(val),
              decoration: InputDecoration(
                hintText: '@yourhandle',
                hintStyle: GoogleFonts.dmSans(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppColors.textMid, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.bgCard,
              ),
              style: GoogleFonts.dmSans(
                color: AppColors.textDark,
                fontSize: 14,
              ),
            ),
            if (onboardingState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Text(
                  onboardingState.error!,
                  style: GoogleFonts.dmSans(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onboardingState.isLoading
                    ? null
                    : () => ref
                        .read(onboardingProvider.notifier)
                        .connectAndAnalyse(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                ),
                child: onboardingState.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.bgPrimary,
                          ),
                        ),
                      )
                    : Text(
                        'Scan Profile',
                        style: GoogleFonts.dmSans(
                          color: AppColors.bgPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 3: Scraping/Scanning Animation =====
  Widget _buildScraping(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScannerAnimation(),
            const SizedBox(height: 32),
            Text(
              'Scanning your profile...',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ARIA is analyzing your content and\naudience to find your unique niche.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerAnimation() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
          // Animated pulse rings
          AnimatedBuilder(
            animation: _scanAnimCtrl,
            builder: (_, __) {
              _scanAnimCtrl.repeat();
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 120 + (20 * _scanAnimCtrl.value),
                    width: 120 + (20 * _scanAnimCtrl.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 1 - _scanAnimCtrl.value),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.bgPrimary,
                      size: 40,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ===== STEP 4: Analysis Display =====
  Widget _buildAnalysis(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final profile = onboardingState.profile;

    if (profile == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      profile.archetypeEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are ${profile.archetypeLabel}',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${profile.archetypeConfidence}%',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Profile Stats
            _statsRow('Followers', profile.followerRange ?? 'N/A',
                '👥'),
            const SizedBox(height: 12),
            _statsRow('Health Score', '${profile.healthScore}/100',
                '💪'),
            const SizedBox(height: 12),
            _statsRow('Growth Stage', profile.growthStage, '📈'),
            const SizedBox(height: 28),
            // Niches
            Text(
              'Your Niches',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textMid,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.detectedNiches
                  .map((n) => _nicheBadge(n))
                  .toList(),
            ),
            const SizedBox(height: 28),
            // Content Insights
            Text(
              'Content Insights',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textMid,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _insightRow('Best Format', profile.contentInsights.bestFormat),
            _insightRow(
                'Best Time', profile.contentInsights.bestTime),
            _insightRow('Posting Frequency',
                profile.contentInsights.postingFrequency),
            _insightRow(
                'Audience Age', profile.contentInsights.audienceAge),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref
                    .read(onboardingProvider.notifier)
                    .proceedToNicheConfirm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                ),
                child: Text(
                  'Confirm & Continue',
                  style: GoogleFonts.dmSans(
                    color: AppColors.bgPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    ref.read(onboardingProvider.notifier).retry(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                ),
                child: Text(
                  'Try Different Handle',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textMid,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nicheBadge(String niche) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        niche,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textMid,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== STEP 5: Niche Confirmation =====
  Widget _buildNicheConfirm(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Confirm Your Niches',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 32,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select at least one niche to customize your ARIA experience.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ...onboardingState.profile!.detectedNiches.map((niche) {
              final isSelected =
                  onboardingState.confirmedNiches.contains(niche);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => notifier.toggleNiche(niche),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.bgCard,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLG),
                    ),
                    child: Row(
                      children: [
                        Text(niche,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            )),
                        const Spacer(),
                        isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 20)
                            : Icon(Icons.circle_outlined,
                                color: AppColors.textMid.withValues(alpha: 0.3),
                                size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onboardingState.isLoading
                    ? null
                    : () => notifier.finaliseAndComplete(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                ),
                child: onboardingState.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.bgPrimary,
                          ),
                        ),
                      )
                    : Text(
                        'Complete Setup',
                        style: GoogleFonts.dmSans(
                          color: AppColors.bgPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 6: Done =====
  Widget _buildDone(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'You\'re all set! 🎉',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 28,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your profile is ready. Let's explore\nyour personalized creator dashboard.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.discover),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                ),
                child: Text(
                  'Go to Discover',
                  style: GoogleFonts.dmSans(
                    color: AppColors.bgPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
