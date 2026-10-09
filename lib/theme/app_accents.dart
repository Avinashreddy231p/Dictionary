import 'package:flutter/material.dart';

class AppAccent {
  final String name;
  final Color primary;
  final Color soft;
  final Color darkSoft;
  final Color darkSoftText;

  const AppAccent({
    required this.name,
    required this.primary,
    required this.soft,
    required this.darkSoft,
    required this.darkSoftText,
  });

  String get code => '#${primary.value.toRadixString(16).substring(2).toUpperCase()}';

  Color adaptiveSoft(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSoft : soft;
  }

  Color adaptiveSoftText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSoftText : primary;
  }

  static const List<AppAccent> presets = [
    AppAccent(
      name: 'Royal Purple',
      primary: Color(0xFF6344FF),
      soft: Color(0xFFE3DFFF),
      darkSoft: Color(0xFF382C48),
      darkSoftText: Color(0xFFCBB7E2),
    ),
    AppAccent(
      name: 'Ocean Blue',
      primary: Color(0xFF2563EB),
      soft: Color(0xFFD6E6FF),
      darkSoft: Color(0xFF28384A),
      darkSoftText: Color(0xFFA5C4E8),
    ),
    AppAccent(
      name: 'Emerald Green',
      primary: Color(0xFF059669),
      soft: Color(0xFFD1FAE5),
      darkSoft: Color(0xFF2B4332),
      darkSoftText: Color(0xFF9FD4AC),
    ),
    AppAccent(
      name: 'Sunset Orange',
      primary: Color(0xFFEA580C),
      soft: Color(0xFFFFEDD5),
      darkSoft: Color(0xFF452B1E),
      darkSoftText: Color(0xFFEBC1A8),
    ),
    AppAccent(
      name: 'Coral Pink',
      primary: Color(0xFFE11D48),
      soft: Color(0xFFFFE4E6),
      darkSoft: Color(0xFF3D1E26),
      darkSoftText: Color(0xFFF5B7C4),
    ),
    AppAccent(
      name: 'Berry Violet',
      primary: Color(0xFFC026D3),
      soft: Color(0xFFFAE8FF),
      darkSoft: Color(0xFF3F2148),
      darkSoftText: Color(0xFFE5B5EE),
    ),
    AppAccent(
      name: 'Teal Cyan',
      primary: Color(0xFF0D9488),
      soft: Color(0xFFCCFBF1),
      darkSoft: Color(0xFF1C3835),
      darkSoftText: Color(0xFF8FE0D6),
    ),
    AppAccent(
      name: 'Midnight Ink',
      primary: Color(0xFF1E293B),
      soft: Color(0xFFE2E8F0),
      darkSoft: Color(0xFF282828),
      darkSoftText: Color(0xFFD0D0D0),
    ),
  ];

  static AppAccent fromColor(Color primaryColor) {
    for (final preset in presets) {
      if (preset.primary.value == primaryColor.value) {
        return preset;
      }
    }
    final hsl = HSLColor.fromColor(primaryColor);
    final soft = hsl.withLightness(0.92).withSaturation(0.75).toColor();
    final darkSoft = hsl.withLightness(0.20).withSaturation(0.35).toColor();
    final darkSoftText = hsl.withLightness(0.80).withSaturation(0.50).toColor();
    return AppAccent(
      name: 'Custom Accent',
      primary: primaryColor,
      soft: soft,
      darkSoft: darkSoft,
      darkSoftText: darkSoftText,
    );
  }
}
