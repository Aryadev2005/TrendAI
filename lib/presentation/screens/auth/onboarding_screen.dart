import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? selectedFollowers;
  String? selectedPlatform;
  final List<String> selectedNiches = [];

  final followers = ['1K–10K', '10K–50K', '50K–100K', '100K–500K', '500K+'];
  final platforms = ['Instagram', 'YouTube', 'TikTok', 'Twitter/X'];
  final niches = ['🔥 Fashion', '🍕 Food', '✈️ Travel', '💪 Fitness', '💄 Beauty', '📱 Tech', '💰 Finance', '🎮 Gaming', '🎵 Music', '😂 Comedy', '📚 Education', '🏠 Lifestyle'];

  bool get _canContinue => selectedFollowers != null && selectedPlatform != null && selectedNiches.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Positioned(top: -100, right: -60, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.purple.withOpacity(0.1)))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _progressBar(),
                  const SizedBox(height: 32),
                  const Text('Build your\nTrend Profile', style: TextStyle(fontSize: AppDimensions.fontXXL, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                  const SizedBox(height: 8),
                  const Text('Personalise your AI trend feed in 60 seconds', style: TextStyle(color: Colors.white38, fontSize: AppDimensions.fontSM)),
                  const SizedBox(height: 36),
                  _label('FOLLOWER COUNT'),
                  const SizedBox(height: 12),
                  _chips(followers, (f) => selectedFollowers == f, (f) => setState(() => selectedFollowers = f)),
                  const SizedBox(height: 28),
                  _label('PRIMARY PLATFORM'),
                  const SizedBox(height: 12),
                  _chips(platforms, (p) => selectedPlatform == p, (p) => setState(() => selectedPlatform = p)),
                  const SizedBox(height: 28),
                  _label('YOUR CONTENT NICHE'),
                  const SizedBox(height: 4),
                  const Text('Pick all that apply', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 12),
                  _chips(niches, (n) => selectedNiches.contains(n), (n) => setState(() => selectedNiches.contains(n) ? selectedNiches.remove(n) : selectedNiches.add(n))),
                  const SizedBox(height: 40),
                  AppButton(
                    label: 'Continue →',
                    isEnabled: _canContinue,
                    onTap: () {
                      ref.read(authProvider.notifier).updateProfile(
                        followerRange: selectedFollowers,
                        primaryPlatform: selectedPlatform,
                        niches: selectedNiches,
                      );
                      context.go(AppRoutes.dashboard);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar() => Row(children: [
    Expanded(child: Container(height: 3, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
    const SizedBox(width: 6),
    Expanded(child: Container(height: 3, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
  ]);

  Widget _label(String text) => Text(text, style: const TextStyle(color: Colors.white38, fontSize: AppDimensions.fontXS, letterSpacing: 1.5, fontWeight: FontWeight.w600));

  Widget _chips(List<String> items, bool Function(String) isSelected, void Function(String) onTap) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: items.map((item) {
        final sel = isSelected(item);
        return GestureDetector(
          onTap: () => onTap(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: sel ? AppColors.primary : Colors.white12),
            ),
            child: Text(item, style: TextStyle(color: sel ? AppColors.primary : Colors.white38, fontSize: AppDimensions.fontSM, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }
}