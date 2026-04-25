import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds ──────────────────────────────
  static const bgPrimary   = Color(0xFFF5F0E8);  // warm cream
  static const bgSurface   = Color(0xFFEDE8DC);  // soft beige
  static const bgCard      = Color(0xFFFAF7F2);  // light warm white
  static const bgCardDeep  = Color(0xFFF0EAE0);  // deeper card
  static const bgDark      = Color(0xFF1C110A);  // warm near-black

  // ── Brand ────────────────────────────────────
  static const primary     = Color(0xFFE8722A);  // rich orange
  static const primaryDark = Color(0xFFC45A1A);  // deep orange
  static const primaryGlow = Color(0xFFF0A060);  // light orange
  static const accent      = Color(0xFFD4956A);  // warm tan
  static const accentLight = Color(0xFFEDD5B8);  // pale peach

  // ── Text ─────────────────────────────────────
  static const textDark      = Color(0xFF2C1810);  // warm black
  static const textMid       = Color(0xFF8B6B55);  // warm brown
  static const textLight     = Color(0xFFB8A090);  // muted warm
  static const textOnPrimary = Colors.white;

  // ── Text aliases (dark-surface screens) ──────
  static const textPrimary   = Color(0xFFF5EDE5);  // near-white on dark bg
  static const textSecondary = Color(0xFF8B6B55);  // same as textMid
  static const textMuted     = Color(0xFF9E8070);  // dim warm on dark bg

  // ── Borders & Shadows ────────────────────────
  static const border      = Color(0xFFE0D5C5);
  static const borderLight = Color(0xFFEDE5D8);
  static const shadow      = Color(0x18C45A1A);  // warm orange shadow
  static const shadowDeep  = Color(0x30C45A1A);

  // ── Status ───────────────────────────────────
  static const hot         = Color(0xFFE8722A);
  static const rising      = Color(0xFF6BAF7A);
  static const newBadge    = Color(0xFF7B6FA8);
  static const success     = Color(0xFF6BAF7A);
  static const error       = Color(0xFFD05050);

  // ── Aliases for badge helpers ─────────────────
  static const orange      = Color(0xFFE8722A);  // same as primary / hot
  static const purple      = Color(0xFF7B6FA8);  // same as newBadge
}