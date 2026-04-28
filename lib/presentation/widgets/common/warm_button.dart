import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class WarmButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isOutlined;
  final IconData? icon;

  const WarmButton({
    super.key,
    required this.label,
    this.onTap,
    this.isEnabled = true,
    this.isOutlined = false,
    this.icon,
  });

  @override
  State<WarmButton> createState() => _WarmButtonState();
}

class _WarmButtonState extends State<WarmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (widget.isEnabled) widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          decoration: BoxDecoration(
            color: widget.isOutlined
                ? Colors.transparent
                : widget.isEnabled
                    ? AppColors.primary
                    : AppColors.accentLight,
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
            border: widget.isOutlined
                ? Border.all(color: AppColors.border, width: 1.5)
                : null,
            boxShadow: widget.isEnabled && !widget.isOutlined
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: widget.isOutlined
                        ? AppColors.textMid
                        : Colors.white,
                    size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  fontSize: AppDimensions.fontMD,
                  fontWeight: FontWeight.w600,
                  color: widget.isOutlined
                      ? AppColors.textMid
                      : Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}