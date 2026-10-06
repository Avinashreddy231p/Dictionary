import 'package:flutter/material.dart';

class AppColors {
  // Core backgrounds
  static const Color background = Color(0xFFFFF9EE);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1B1B26); // Dark indigo/black
  static const Color textSecondary = Color(0xFF6C6C7D); // Muted grey/indigo
  static const Color textDisabled = Color(0xFFA1A1AF);

  // Primary Accent
  static const Color primaryPurple = Color(0xFF6344FF); // Buttons, active tabs

  // Pastel Accents (Cards, Chips, Highlights)
  static const Color softYellow = Color(0xFFFFEEA9);
  static const Color softPurple = Color(0xFFE3DFFF);
  static const Color softGreen = Color(0xFFD8F3D1);
  // New specific colors from the exact mockup
  static const Color headerYellow = Color(0xFFFFCC33);
  static const Color badgeTeal = Color(0xFF13C1B6);
  static const Color anatomyGreen = Color(0xFFCEF0B5);
  static const Color anatomyBlue = Color(0xFFBBD3FF);
  static const Color anatomyPurple = Color(0xFFDFCCFF);
  static const Color examplePink = Color(0xFFFAEOE5); // Muted pink
  static const Color illustrationPurple = Color(0xFFC7B8FF);
  static const Color buttonBlack = Color(0xFF1E1E1E);
  
  // Custom Gradients (e.g. for "Continue Reading" or smart cards)
  static const LinearGradient continueReadingGradient = LinearGradient(
    colors: [Color(0xFFD4BFFF), Color(0xFF8C71FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient homeHeroGradient = LinearGradient(
    colors: [Color(0xFFFFF9EE), Color(0xFFFFF0D4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Borders & Dividers
  static const Color border = Color(0xFFE8E4DA);
}