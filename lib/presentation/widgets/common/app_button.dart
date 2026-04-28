import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isEnabled = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: isOutlined
              ? Colors.transparent
              : isEnabled
                  ? AppColors.primary
                  : Colors.white12,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusMD),
          border: isOutlined
              ? Border.all(color: AppColors.border)
              : null,
          boxShadow: isEnabled && !isOutlined
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isOutlined
                  ? AppColors.textSecondary
                  : Colors.white,
              fontSize: AppDimensions.fontMD,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}