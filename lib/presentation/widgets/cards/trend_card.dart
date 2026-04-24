import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/trend_model.dart';

class TrendCard extends StatelessWidget {
  final TrendModel trend;
  final VoidCallback? onTap;

  const TrendCard({super.key, required this.trend, this.onTap});

  @override
  Widget build(BuildContext context) {
    final badgeColor = Helpers.getBadgeColor(trend.badge);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(trend.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: AppDimensions.fontMD, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: badgeColor.withOpacity(0.4)),
                  ),
                  child: Text(trend.badge, style: TextStyle(color: badgeColor, fontSize: AppDimensions.fontXS, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${trend.platform} · ${trend.stat}', style: const TextStyle(color: AppColors.textMuted, fontSize: AppDimensions.fontSM)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(trend.aiTip, style: const TextStyle(color: AppColors.primary, fontSize: AppDimensions.fontXS)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}