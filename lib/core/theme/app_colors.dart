import 'package:flutter/material.dart';

class AppColors {
  // Base Theme Colors
  static const Color background = Color(0xFF0A0A0A); // Deep dark background
  static const Color surface = Color(0xFF121212); // Slightly lighter surface
  static const Color card =
      Color(0xFF1C1C1E); // Card with slightly visible contrast

  // Text Colors
  static const Color textPrimary = Color(0xFFEFEFEF); // Soft white
  static const Color textSecondary = Color(0xFFAAAAAA); // Light gray
  static const Color textHint = Color(0xFF666666); // Muted gray for hint text

  // Primary (Inspired by Poli Purple)
  static const Color primary = Color(0xFF9B5DE5);
  static const Color primaryDark = Color(0xFF6F3CC9);
  static const Color primaryLight = Color(0xFFCBA2F3);

  // Secondary (Inspired by Park Green)
  static const Color secondary = Color(0xFF00F5D4);
  static const Color secondaryDark = Color(0xFF00C9A7);
  static const Color secondaryLight = Color(0xFF8BF9E6);

  // Accent (Inspired by Orange Sunshine or Neo Pacha)
  static const Color accent = Color(0xFFFFA500); // Modern orange
  static const Color accentDark = Color(0xFFCC8400);
  static const Color accentLight = Color(0xFFFFC266);

  // Status Colors (From Semantic colors in screenshot)
  static const Color success = Color(0xFF00C853); // Deep vibrant green
  static const Color error = Color(0xFFFF5252); // Bright coral red
  static const Color warning = Color(0xFFFFAB00); // Orange-yellow
  static const Color info = Color(0xFF448AFF); // Sharp blue

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFF2C2C2E); // Dark gray button bg
  static const Color buttonDisabled = Color(0xFF3A3A3C);

  // Input Fields
  static const Color inputBackground = Color(0xFF1E1E1E); // Darker background
  static const Color inputBorder = Color(0xFF3C3C3C); // Low contrast border
  static const Color inputFocusedBorder = primary;

  // Shadows
  static const Color shadow = Color(0x33000000); // Soft shadow in dark mode

  // Transaction Colors
  static const Color credit = Color(0xFF00E676); // Green
  static const Color debit = Color(0xFFFF3D00); // Orange-Red
  static const Color neutral = Color(0xFFB0BEC5); // Cool gray
}
