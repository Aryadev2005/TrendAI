// lib/presentation/screens/studio/studio_screen_placeholder.dart
// Placeholder for Studio screen — built on Day 7

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';

class StudioScreenPlaceholder extends StatelessWidget {
  const StudioScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎬', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 20),
                  Text(
                    'Studio',
                    style: GoogleFonts.dmSerifDisplay(
                      color: AppColors.textDark,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Script Builder · BGM Matcher · Editing Help\nComing on Day 7',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textMid,
                      fontSize: 14,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: BottomNav(currentIndex: 2),
          ),
        ],
      ),
    );
  }
}
