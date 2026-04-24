import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Helpers {
  static String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  static Color getBadgeColor(String badge) {
    switch (badge.toUpperCase()) {
      case 'HOT': return AppColors.orange;
      case 'RISING': return AppColors.primary;
      case 'NEW': return AppColors.purple;
      default: return AppColors.primary;
    }
  }

  static void showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}