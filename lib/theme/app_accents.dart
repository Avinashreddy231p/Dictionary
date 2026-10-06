import 'package:flutter/material.dart';

class AppAccent {
  final String name;
  final Color primary;
  final Color soft;

  const AppAccent({
    required this.name,
    required this.primary,
    required this.soft,
  });

  static const List<AppAccent> presets = [
    AppAccent(
      name: 'Royal Purple',
      primary: Color(0xFF6344FF),
      soft: Color(0xFFE3DFFF),
    ),
    AppAccent(
      name: 'Ocean Blue',
      primary: Color(0xFF2563EB),
      soft: Color(0xFFD6E6FF),
    ),
    AppAccent(
      name: 'Emerald Green',
      primary: Color(0xFF059669),
      soft: Color(0xFFD1FAE5),
    ),
    AppAccent(
      name: 'Sunset Orange',
      primary: Color(0xFFEA580C),
      soft: Color(0xFFFFEDD5),
    ),
    AppAccent(
      name: 'Coral Pink',
      primary: Color(0xFFE11D48),
      soft: Color(0xFFFFE4E6),
    ),
    AppAccent(
      name: 'Berry Violet',
      primary: Color(0xFFC026D3),
      soft: Color(0xFFFAE8FF),
    ),
    AppAccent(
      name: 'Teal Cyan',
      primary: Color(0xFF0D9488),
      soft: Color(0xFFCCFBF1),
    ),
    AppAccent(
      name: 'Midnight Ink',
      primary: Color(0xFF1E293B),
      soft: Color(0xFFE2E8F0),
    ),
  ];

  static AppAccent fromColor(Color primaryColor) {
    return presets.firstWhere(
      (a) => a.primary.value == primaryColor.value,
      orElse: () => presets.first,
    );
  }
}
