import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/providers/settings_provider.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => getLight(AppColors.primaryPurple);
  static ThemeData get darkTheme => getDark(AppColors.primaryPurple);

  static TextTheme _getTextTheme(String fontFamily, TextTheme base) {
    switch (fontFamily) {
      case 'SF Pro':
      case 'SF Pro Display':
      case 'SF Pro Rounded':
        return base.apply(fontFamily: fontFamily);
      case 'Inter':
        return GoogleFonts.interTextTheme(base);
      case 'Figtree':
        return GoogleFonts.figtreeTextTheme(base);
      case 'Lora':
        return GoogleFonts.loraTextTheme(base);
      case 'Fira Code':
        return GoogleFonts.firaCodeTextTheme(base);
      case 'Nunito':
      default:
        return GoogleFonts.nunitoTextTheme(base);
    }
  }

  static double _getCardRadius(String radiusStyle) {
    switch (radiusStyle) {
      case 'sharp':
        return 12.0;
      case 'pill':
        return 32.0;
      case 'rounded':
      default:
        return 24.0;
    }
  }

  static double cardRadius(BuildContext context) {
    try {
      final settings = ProviderScope.containerOf(context).read(settingsProvider);
      return _getCardRadius(settings.cardRadiusStyle);
    } catch (_) {
      return 24.0;
    }
  }

  static double borderWidth(BuildContext context) {
    try {
      final settings = ProviderScope.containerOf(context).read(settingsProvider);
      switch (settings.borderWidthStyle) {
        case 'thin':
          return 1.0;
        case 'bold':
          return 2.5;
        case 'standard':
        default:
          return 1.5;
      }
    } catch (_) {
      return 1.5;
    }
  }

  static double searchBarRadius(BuildContext context) {
    try {
      final settings = ProviderScope.containerOf(context).read(settingsProvider);
      return settings.searchBarShape == 'roundedBox' ? 16.0 : 50.0;
    } catch (_) {
      return 50.0;
    }
  }

  static ThemeData getLight(
    Color accentColor, {
    String variant = 'standard',
    String fontFamily = 'Nunito',
    String radiusStyle = 'rounded',
    String borderWidthStyle = 'standard',
    String searchBarShape = 'pill',
  }) {
    final rawBaseText = _getTextTheme(fontFamily, ThemeData.light().textTheme);
    final cardRadiusVal = _getCardRadius(radiusStyle);
    final strokeWidth = borderWidthStyle == 'thin' ? 1.0 : (borderWidthStyle == 'bold' ? 2.5 : 1.5);
    final searchRadius = searchBarShape == 'roundedBox' ? 16.0 : 50.0;

    Color bg = AppColors.background; // #FFF9EE
    Color cardColor = AppColors.white; // #FFFFFF
    Color textCol = AppColors.textPrimary; // #1B1B26

    if (variant == 'sepia') {
      bg = const Color(0xFFFBF0D9); // Warm parchment paper
      cardColor = const Color(0xFFFFF7E6);
      textCol = const Color(0xFF2D2217);
    } else if (variant == 'oled') {
      bg = const Color(0xFFF5F5F7); // Crisp white-grey
      cardColor = AppColors.white;
      textCol = const Color(0xFF111118);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      primaryColor: accentColor,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        onPrimary: AppColors.white,
        secondary: AppColors.softYellow,
        onSecondary: textCol,
        surface: cardColor,
        onSurface: textCol,
        background: bg,
        onBackground: textCol,
        outline: AppColors.border,
      ),
      textTheme: rawBaseText.copyWith(
        displayLarge: rawBaseText.displayLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w900,
        ),
        displayMedium: rawBaseText.displayMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: rawBaseText.headlineLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: rawBaseText.headlineMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: rawBaseText.titleLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: rawBaseText.titleMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: rawBaseText.bodyLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: rawBaseText.bodyMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: rawBaseText.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: rawBaseText.labelLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textCol),
        titleTextStyle: rawBaseText.titleLarge?.copyWith(
          color: textCol,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadiusVal),
          side: BorderSide(color: AppColors.border, width: strokeWidth),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: rawBaseText.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        hintStyle: rawBaseText.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide(color: AppColors.border, width: strokeWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide(color: AppColors.border, width: strokeWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide(color: accentColor, width: strokeWidth + 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: strokeWidth,
        space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softPurple,
        disabledColor: AppColors.border,
        selectedColor: accentColor,
        secondarySelectedColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: rawBaseText.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: textCol,
        ),
        secondaryLabelStyle: rawBaseText.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border, width: strokeWidth),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bg,
        modalBackgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadiusVal + 8)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadiusVal + 4),
          side: BorderSide(color: AppColors.border, width: strokeWidth),
        ),
      ),
    );
  }

  static ThemeData getDark(
    Color accentColor, {
    String variant = 'standard',
    String fontFamily = 'Nunito',
    String radiusStyle = 'rounded',
    String borderWidthStyle = 'standard',
    String searchBarShape = 'pill',
  }) {
    final rawBaseText = _getTextTheme(fontFamily, ThemeData.dark().textTheme);
    final cardRadiusVal = _getCardRadius(radiusStyle);
    final strokeWidth = borderWidthStyle == 'thin' ? 1.0 : (borderWidthStyle == 'bold' ? 2.5 : 1.5);
    final searchRadius = searchBarShape == 'roundedBox' ? 16.0 : 50.0;

    Color bg = AppColors.darkBackground; // #11111B
    Color surfaceColor = AppColors.darkSurface; // #1B1B2A
    Color textCol = AppColors.textPrimaryDark;

    if (variant == 'sepia') {
      bg = const Color(0xFF261D15); // Warm dark espresso paper
      surfaceColor = const Color(0xFF33271D);
      textCol = const Color(0xFFF7E8D3);
    } else if (variant == 'oled') {
      bg = const Color(0xFF000000); // PURE OLED PITCH BLACK!
      surfaceColor = const Color(0xFF0E0E14);
      textCol = const Color(0xFFFFFFFF);
    } else if (variant == 'nordic') {
      bg = const Color(0xFF141C24); // Deep Nordic Abyssal Slate
      surfaceColor = const Color(0xFF1E2834);
      textCol = const Color(0xFFE2E8F0);
    } else if (variant == 'matcha') {
      bg = const Color(0xFF152018); // Deep Forest Tea Sage
      surfaceColor = const Color(0xFF1F2E23);
      textCol = const Color(0xFFE2EFE5);
    } else if (variant == 'rose') {
      bg = const Color(0xFF23161B); // Midnight Velvet Rose Plum
      surfaceColor = const Color(0xFF301E25);
      textCol = const Color(0xFFF8E6EB);
    } else if (variant == 'synth') {
      bg = const Color(0xFF151022); // Deep Synthwave Cyber Violet
      surfaceColor = const Color(0xFF201832);
      textCol = const Color(0xFFEFE8FC);
    } else if (variant == 'accentTint' || variant == 'dynamic' || variant == 'accent') {
      final hsl = HSLColor.fromColor(accentColor);
      bg = hsl.withLightness(0.08).withSaturation(0.20).toColor();
      surfaceColor = hsl.withLightness(0.14).withSaturation(0.22).toColor();
      textCol = AppColors.textPrimaryDark;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: accentColor,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        onPrimary: AppColors.white,
        secondary: AppColors.darkSoftYellowText,
        onSecondary: bg,
        surface: surfaceColor,
        onSurface: textCol,
        background: bg,
        onBackground: textCol,
        outline: AppColors.darkBorder,
      ),
      textTheme: rawBaseText.copyWith(
        displayLarge: rawBaseText.displayLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w900,
        ),
        displayMedium: rawBaseText.displayMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: rawBaseText.headlineLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: rawBaseText.headlineMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: rawBaseText.titleLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: rawBaseText.titleMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: rawBaseText.bodyLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: rawBaseText.bodyMedium?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: rawBaseText.bodySmall?.copyWith(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: rawBaseText.labelLarge?.copyWith(
          color: textCol,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textCol),
        titleTextStyle: rawBaseText.titleLarge?.copyWith(
          color: textCol,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadiusVal),
          side: BorderSide(color: AppColors.darkBorder, width: strokeWidth),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: rawBaseText.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        hintStyle: rawBaseText.bodyMedium?.copyWith(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide(color: AppColors.darkBorder, width: strokeWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide(color: AppColors.darkBorder, width: strokeWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchRadius),
          borderSide: BorderSide(color: accentColor, width: strokeWidth + 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder,
        thickness: strokeWidth,
        space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSoftPurple,
        disabledColor: AppColors.darkBorder,
        selectedColor: accentColor,
        secondarySelectedColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: rawBaseText.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.darkSoftPurpleText,
        ),
        secondaryLabelStyle: rawBaseText.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.darkBorder, width: strokeWidth),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        modalBackgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadiusVal + 8)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadiusVal + 4),
          side: BorderSide(color: AppColors.darkBorder, width: strokeWidth),
        ),
      ),
    );
  }
}
