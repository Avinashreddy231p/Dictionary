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
  static const Color softPeach = Color(0xFFFFDFD1);
  static const Color softBlue = Color(0xFFD6E6FF);
  
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