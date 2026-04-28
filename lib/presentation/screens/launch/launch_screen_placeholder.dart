// lib/presentation/screens/launch/launch_screen_placeholder.dart
// Placeholder for Launch screen — built on Day 9

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';

class LaunchScreenPlaceholder extends StatelessWidget {
  const LaunchScreenPlaceholder({super.key});

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
                  const Text('🚀', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 20),
                  Text(
                    'Launch',
                    style: GoogleFonts.dmSerifDisplay(
                      color: AppColors.textDark,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Timing Intelligence · Posting Package · Brand Alerts\nComing on Day 9',
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
            child: BottomNav(currentIndex: 3),
          ),
        ],
      ),
    );
  }
}
