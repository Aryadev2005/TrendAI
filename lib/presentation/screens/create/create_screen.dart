import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../presentation/controllers/content_controller.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});
  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  String selectedPlatform = 'Instagram';
  final platforms = ['Instagram', 'YouTube', 'TikTok', 'Twitter/X'];

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentProvider);
    final content = contentState.generatedContent;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create Content', style: TextStyle(fontSize: AppDimensions.fontXXL, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('AI generates your full content plan', style: TextStyle(color: Colors.white38, fontSize: AppDimensions.fontSM)),
                  const SizedBox(height: 24),
                  const Text('SELECT PLATFORM', style: TextStyle(color: Colors.white38, fontSize: AppDimensions.fontXS, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: platforms.map((p) {
                      final sel = selectedPlatform == p;
                      return GestureDetector(
                        onTap: () => setState(() => selectedPlatform = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: sel ? AppColors.primary : Colors.white12),
                          ),
                          child: Text(p, style: TextStyle(color: sel ? AppColors.primary : Colors.white38, fontSize: AppDimensions.fontSM)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  contentState.isLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)))
                      : content == null
                          ? AppButton(
                              label: 'Generate AI Content',
                              onTap: () => ref.read(contentProvider.notifier).generateContent(
                                trendTitle: 'Quiet Luxury',
  platform: selectedPlatform,
),
                            )
                          : _contentResult(content),
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(currentIndex: 3)),
        ],
      ),
    );
  }

  Widget _contentResult(content) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _resultCard('HOOK', content.hook, Icons.flash_on),
      const SizedBox(height: 12),
      _resultCard('CAPTION', content.caption, Icons.text_fields),
      const SizedBox(height: 12),
      _resultCard('HASHTAGS', content.hashtags.join('  '), Icons.tag),
      const SizedBox(height: 12),
      _resultCard('BEST TIME TO POST', content.bestTimeToPost, Icons.access_time),
      const SizedBox(height: 24),
      AppButton(label: 'Publish to $selectedPlatform', onTap: () {}),
      const SizedBox(height: 12),
      AppButton(label: 'Generate Again', isOutlined: true, onTap: () => ref.read(contentProvider.notifier).clearContent()),
    ],
  );

  Widget _resultCard(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(AppDimensions.paddingMD),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: AppDimensions.fontXS, letterSpacing: 1)),
        ]),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: AppDimensions.fontSM, height: 1.5)),
      ],
    ),
  );
}