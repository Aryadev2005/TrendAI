import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textMuted),
          prefixIcon:
              Icon(icon, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}