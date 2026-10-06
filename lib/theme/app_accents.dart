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
      darkSoft: Color(0xFF2E2345),
      darkSoftText: Color(0xFFE4D7FA),
    ),
    AppAccent(
      name: 'Ocean Blue',
      primary: Color(0xFF2563EB),
      soft: Color(0xFFD6E6FF),
      darkSoft: Color(0xFF1C2740),
      darkSoftText: Color(0xFFCFE2FE),
    ),
    AppAccent(
      name: 'Emerald Green',
      primary: Color(0xFF059669),
      soft: Color(0xFFD1FAE5),
      darkSoft: Color(0xFF1B2E24),
      darkSoftText: Color(0xFFC8F2D5),
    ),
    AppAccent(
      name: 'Sunset Orange',
      primary: Color(0xFFEA580C),
      soft: Color(0xFFFFEDD5),
      darkSoft: Color(0xFF382315),
      darkSoftText: Color(0xFFFDE1C8),
    ),
    AppAccent(
      name: 'Coral Pink',
      primary: Color(0xFFE11D48),
      soft: Color(0xFFFFE4E6),
      darkSoft: Color(0xFF341C2A),
      darkSoftText: Color(0xFFF9C8D4),
    ),
    AppAccent(
      name: 'Berry Violet',
      primary: Color(0xFFC026D3),
      soft: Color(0xFFFAE8FF),
      darkSoft: Color(0xFF341B3B),
      darkSoftText: Color(0xFFF5D2FC),
    ),
    AppAccent(
      name: 'Teal Cyan',
      primary: Color(0xFF0D9488),
      soft: Color(0xFFCCFBF1),
      darkSoft: Color(0xFF172E2D),
      darkSoftText: Color(0xFFB8EBE6),
    ),
    AppAccent(
      name: 'Midnight Ink',
      primary: Color(0xFF1E293B),
      soft: Color(0xFFE2E8F0),
      darkSoft: Color(0xFF222638),
      darkSoftText: Color(0xFFD8DCFC),
    ),
  ];

  static AppAccent fromColor(Color primaryColor) {
    return presets.firstWhere(
      (a) => a.primary.value == primaryColor.value,
      orElse: () => presets.first,
    );
  }
}
