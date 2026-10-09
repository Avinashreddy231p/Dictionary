import 'package:flutter/material.dart';

class AppColors {
  // Core backgrounds (Light - Warm Cream & Soft White)
  static const Color background = Color(0xFFFFF9EE);
  static const Color white = Color(0xFFFFFFFF);

  // Core backgrounds (Dark - Premium Matte Charcoal & Dark Surfaces, as in Reference UI)
  static const Color darkBackground = Color(0xFF141414);
  static const Color darkSurface = Color(0xFF222222);
  static const Color darkBorder = Color(0xFF2E2E2E);
  static const Color darkTileBg = Color(0xFF181818);

  // Text Colors (Light)
  static const Color textPrimary = Color(0xFF1B1B26); // Dark indigo/black
  static const Color textSecondary = Color(0xFF6C6C7D); // Muted grey/indigo
  static const Color textDisabled = Color(0xFFA1A1AF);

  // Text Colors (Dark - Off-white & Muted Grey)
  static const Color textPrimaryDark = Color(0xFFEDEDED);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);
  static const Color textDisabledDark = Color(0xFF666666);

  // Primary Accent
  static const Color primaryPurple = Color(0xFF6344FF); // Buttons, active tabs

  // Pastel Accents (Light)
  static const Color softYellow = Color(0xFFFFEEA9);
  static const Color softPurple = Color(0xFFE3DFFF);
  static const Color softGreen = Color(0xFFD8F3D1);
  static const Color softPeach = Color(0xFFFFDFD1);
  static const Color softBlue = Color(0xFFD6E6FF);
  static const Color headerYellow = Color(0xFFFFCC33);
  static const Color badgeTeal = Color(0xFF13C1B6);
  static const Color anatomyGreen = Color(0xFFCEF0B5);
  static const Color anatomyBlue = Color(0xFFBBD3FF);
  static const Color anatomyPurple = Color(0xFFDFCCFF);
  static const Color examplePink = Color(0xFFFDE3E8);
  static const Color illustrationPurple = Color(0xFFC7B8FF);
  static const Color buttonBlack = Color(0xFF1E1E1E);

  // Deep Muted Dark Container Colors (Matching Reference Screenshot Exactly)
  static const Color darkHeaderYellow = Color(0xFF222222); // Outer header card surface
  static const Color darkHeaderYellowText = Color(0xFFFFE8B6); // Warm cream meaning text
  static const Color darkSoftYellow = Color(0xFF382D1B);
  static const Color darkSoftYellowText = Color(0xFFFFE8B6); // Warm cream
  static const Color darkSoftPurple = Color(0xFF382C48); // Deep muted violet
  static const Color darkSoftPurpleText = Color(0xFFCBB7E2); // Soft lilac
  static const Color darkSoftGreen = Color(0xFF2B4332); // Deep muted sage
  static const Color darkSoftGreenText = Color(0xFF9FD4AC); // Soft mint
  static const Color darkSoftBlue = Color(0xFF28384A); // Deep muted dusty blue
  static const Color darkSoftBlueText = Color(0xFFA5C4E8); // Soft blue
  static const Color darkSoftPink = Color(0xFF3D1E26); // Deep warm burgundy/maroon
  static const Color darkSoftPinkText = Color(0xFFF5B7C4); // Soft rose pink
  static const Color darkBadgeTeal = Color(0xFF1C3835);
  static const Color darkBadgeTealText = Color(0xFF8FE0D6);

  // Gradients (Light)
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

  // Gradients (Dark)
  static const LinearGradient continueReadingGradientDark = LinearGradient(
    colors: [Color(0xFF4D226A), Color(0xFF2C133F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient homeHeroGradientDark = LinearGradient(
    colors: [Color(0xFF1D1D1D), Color(0xFF272727)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Borders & Dividers
  static const Color border = Color(0xFFE8E4DA);

  // Helper methods for adaptive context brightness
  static Color cardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : white;
  }

  static Color cardBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : border;
  }

  static Color tileBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTileBg
        : background;
  }

  static Color adaptiveSoftYellow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftYellow
        : softYellow;
  }

  static Color adaptiveSoftYellowText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftYellowText
        : textPrimary;
  }

  static Color adaptiveSoftPurple(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftPurple
        : softPurple;
  }

  static Color adaptiveSoftPurpleText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftPurpleText
        : textPrimary;
  }

  static Color adaptiveSoftGreen(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftGreen
        : softGreen;
  }

  static Color adaptiveSoftGreenText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftGreenText
        : textPrimary;
  }

  static Color adaptiveSoftBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftBlue
        : softBlue;
  }

  static Color adaptiveSoftBlueText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftBlueText
        : textPrimary;
  }

  static Color adaptiveSoftPink(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftPink
        : softPeach;
  }

  static Color adaptiveSoftPinkText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSoftPinkText
        : textPrimary;
  }

  static Color adaptiveHeaderYellow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkHeaderYellow
        : headerYellow;
  }
}
