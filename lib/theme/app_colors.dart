import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color seed = Color(0xFFE65100);

  // Surface
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);

  // Input
  static const Color inputFillLight = Color(0xFFF5F5F5);
  static const Color inputBorderLight = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color bodyMediumLight = Color(0xFF757575);
  static const Color inputBorderDark = Color(0xFF424242);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1565C0);

  // Alert severity backgrounds
  static const Color alertInfo = Color(0xFFE8F5E9);
  static const Color alertWarning = Color(0xFFFFF8E1);
  static const Color alertHigh = Color(0xFFFFF3E0);
  static const Color alertCritical = Color(0xFFFFEBEE);

  // Alert severity border/icon colors
  static const Color alertInfoBorder = Color(0xFF4CAF50);
  static const Color alertWarningBorder = Color(0xFFFFB300);
  static const Color alertHighBorder = Color(0xFFFF6D00);
  static const Color alertCriticalBorder = Color(0xFFE53935);

  // Shadows
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x4D000000);

  // Category icons mapping
  static final Map<String, IconData> categoriaIcon = {
    'oleo': Icons.local_shipping,
    'filtro': Icons.filter_alt,
    'pastilha': Icons.disc_full,
    'lona': Icons.radio_button_checked,
    'relacao': Icons.link,
    'pneu': Icons.tire_repair,
    'cabos': Icons.cable,
    'velas': Icons.flare,
    'bateria': Icons.battery_full,
  };
}

