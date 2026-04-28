import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String change;
  final bool isPositive;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: AppDimensions.fontLG, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: AppDimensions.fontXS)),
            const SizedBox(height: 6),
            Text(change, style: TextStyle(
              color: isPositive ? AppColors.primary : AppColors.orange,
              fontSize: AppDimensions.fontXS,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}