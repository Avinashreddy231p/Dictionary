import 'package:flutter/material.dart';

class AppAccent {
  final String name;
  final Color primary;
  final Color soft;
  final Color darkSoft;
  final Color darkSoftText;
  final String category;

  const AppAccent({
    required this.name,
    required this.primary,
    required this.soft,
    required this.darkSoft,
    required this.darkSoftText,
    this.category = 'All',
  });

  String get code => '#${primary.value.toRadixString(16).substring(2).toUpperCase()}';

  Color adaptiveSoft(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSoft : soft;
  }

  Color adaptiveSoftText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSoftText : primary;
  }

  static const List<AppAccent> presets = [
    // --- Purples & Violets ---
    AppAccent(
      name: 'Royal Purple',
      primary: Color(0xFF6344FF),
      soft: Color(0xFFE3DFFF),
      darkSoft: Color(0xFF382C48),
      darkSoftText: Color(0xFFCBB7E2),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Berry Violet',
      primary: Color(0xFFC026D3),
      soft: Color(0xFFFAE8FF),
      darkSoft: Color(0xFF3F2148),
      darkSoftText: Color(0xFFE5B5EE),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Very Peri',
      primary: Color(0xFF6667AB),
      soft: Color(0xFFEBEBFF),
      darkSoft: Color(0xFF282845),
      darkSoftText: Color(0xFFB5B6E6),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Ultra Violet',
      primary: Color(0xFF5F4B8B),
      soft: Color(0xFFEBE5F7),
      darkSoft: Color(0xFF261D3A),
      darkSoftText: Color(0xFFB4A5D6),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Radiant Orchid',
      primary: Color(0xFFB565A7),
      soft: Color(0xFFF9E8F6),
      darkSoft: Color(0xFF3D2138),
      darkSoftText: Color(0xFFE2A8D8),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Amethyst Purple',
      primary: Color(0xFF9966CC),
      soft: Color(0xFFF4EDFC),
      darkSoft: Color(0xFF2F1F3F),
      darkSoftText: Color(0xFFCAA8EC),
      category: 'Purples',
    ),
    AppAccent(
      name: 'French Lilac',
      primary: Color(0xFF86608E),
      soft: Color(0xFFF2ECF5),
      darkSoft: Color(0xFF2C1D2F),
      darkSoftText: Color(0xFFC3A2CC),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Lilac Bloom',
      primary: Color(0xFFA29BFE),
      soft: Color(0xFFF2F0FF),
      darkSoft: Color(0xFF302D52),
      darkSoftText: Color(0xFFCDC8FF),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Periwinkle',
      primary: Color(0xFF8E82FE),
      soft: Color(0xFFEFEEFF),
      darkSoft: Color(0xFF2C2852),
      darkSoftText: Color(0xFFC0B8FF),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Blue Iris',
      primary: Color(0xFF5A5B9F),
      soft: Color(0xFFEBEBF7),
      darkSoft: Color(0xFF222340),
      darkSoftText: Color(0xFFA8A9DC),
      category: 'Purples',
    ),
    AppAccent(
      name: 'Plum Noir',
      primary: Color(0xFF6B2D5C),
      soft: Color(0xFFF5E6F2),
      darkSoft: Color(0xFF2E1227),
      darkSoftText: Color(0xFFD493C4),
      category: 'Purples',
    ),

    // --- Blues & Cyans ---
    AppAccent(
      name: 'Ocean Blue',
      primary: Color(0xFF2563EB),
      soft: Color(0xFFD6E6FF),
      darkSoft: Color(0xFF28384A),
      darkSoftText: Color(0xFFA5C4E8),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Classic Blue',
      primary: Color(0xFF0F4C81),
      soft: Color(0xFFDCEBFA),
      darkSoft: Color(0xFF162B40),
      darkSoftText: Color(0xFF7CB1E0),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Midnight Sapphire',
      primary: Color(0xFF1D3557),
      soft: Color(0xFFE6EEF8),
      darkSoft: Color(0xFF131F33),
      darkSoftText: Color(0xFF84A6D6),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Royal Azure',
      primary: Color(0xFF0077EE),
      soft: Color(0xFFE3F0FF),
      darkSoft: Color(0xFF0C2B4E),
      darkSoftText: Color(0xFF73B4FF),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Cerulean Blue',
      primary: Color(0xFF6B92C2),
      soft: Color(0xFFEBF1F8),
      darkSoft: Color(0xFF1E2E42),
      darkSoftText: Color(0xFFB0C9E8),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Serenity Blue',
      primary: Color(0xFF7094C4),
      soft: Color(0xFFEBF1F9),
      darkSoft: Color(0xFF1E2E45),
      darkSoftText: Color(0xFFB3CCEC),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Nordic Blue',
      primary: Color(0xFF457B9D),
      soft: Color(0xFFEBF3F7),
      darkSoft: Color(0xFF1B2D38),
      darkSoftText: Color(0xFF8EBDDA),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Teal Cyan',
      primary: Color(0xFF0D9488),
      soft: Color(0xFFCCFBF1),
      darkSoft: Color(0xFF1C3835),
      darkSoftText: Color(0xFF8FE0D6),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Turquoise Sea',
      primary: Color(0xFF45B5AA),
      soft: Color(0xFFE6F7F5),
      darkSoft: Color(0xFF143B37),
      darkSoftText: Color(0xFF98E2DA),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Blue Turquoise',
      primary: Color(0xFF399E9B),
      soft: Color(0xFFE3F5F4),
      darkSoft: Color(0xFF113635),
      darkSoftText: Color(0xFF85D6D3),
      category: 'Blues',
    ),
    AppAccent(
      name: 'Aqua Sky',
      primary: Color(0xFF52A8A8),
      soft: Color(0xFFE8F7F7),
      darkSoft: Color(0xFF133636),
      darkSoftText: Color(0xFF94DBDB),
      category: 'Blues',
    ),

    // --- Greens & Botanical Tones ---
    AppAccent(
      name: 'Emerald Green',
      primary: Color(0xFF059669),
      soft: Color(0xFFD1FAE5),
      darkSoft: Color(0xFF2B4332),
      darkSoftText: Color(0xFF9FD4AC),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Emerald Elegance',
      primary: Color(0xFF009B77),
      soft: Color(0xFFE0F7F2),
      darkSoft: Color(0xFF123B31),
      darkSoftText: Color(0xFF7FDCC5),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Greenery',
      primary: Color(0xFF88B04B),
      soft: Color(0xFFF0F7E6),
      darkSoft: Color(0xFF283812),
      darkSoftText: Color(0xFFC3E092),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Meadow Green',
      primary: Color(0xFF389693),
      soft: Color(0xFFE3F5F4),
      darkSoft: Color(0xFF113332),
      darkSoftText: Color(0xFF80CFCC),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Peacock Green',
      primary: Color(0xFF2A9D8F),
      soft: Color(0xFFE3F5F3),
      darkSoft: Color(0xFF133631),
      darkSoftText: Color(0xFF7CD4C9),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Forest Pine',
      primary: Color(0xFF2D6A4F),
      soft: Color(0xFFE3F2EB),
      darkSoft: Color(0xFF132B20),
      darkSoftText: Color(0xFF7CB89C),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Sage Leaf',
      primary: Color(0xFF84A98C),
      soft: Color(0xFFEFF5F0),
      darkSoft: Color(0xFF263629),
      darkSoftText: Color(0xFFBBE0C3),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Olive Branch',
      primary: Color(0xFF708238),
      soft: Color(0xFFF0F5E1),
      darkSoft: Color(0xFF242B12),
      darkSoftText: Color(0xFFB2C47D),
      category: 'Greens',
    ),
    AppAccent(
      name: 'Celadon Mint',
      primary: Color(0xFF5DB37A),
      soft: Color(0xFFEBF7EF),
      darkSoft: Color(0xFF1B3B26),
      darkSoftText: Color(0xFFA1E0B7),
      category: 'Greens',
    ),

    // --- Yellows & Golds ---
    AppAccent(
      name: 'Amber Gold',
      primary: Color(0xFFD97706),
      soft: Color(0xFFFEF3C7),
      darkSoft: Color(0xFF422B14),
      darkSoftText: Color(0xFFFCD34D),
      category: 'Yellows',
    ),
    AppAccent(
      name: 'Mimosa Gold',
      primary: Color(0xFFE2A829),
      soft: Color(0xFFFCF5E3),
      darkSoft: Color(0xFF3F2E0A),
      darkSoftText: Color(0xFFF2D183),
      category: 'Yellows',
    ),
    AppAccent(
      name: 'Illuminating Gold',
      primary: Color(0xFFE0BB10),
      soft: Color(0xFFFCF9E3),
      darkSoft: Color(0xFF3F3504),
      darkSoftText: Color(0xFFF2DA63),
      category: 'Yellows',
    ),
    AppAccent(
      name: 'Golden Wheat',
      primary: Color(0xFFD4943A),
      soft: Color(0xFFFAF2E6),
      darkSoft: Color(0xFF3D2A10),
      darkSoftText: Color(0xFFF5C582),
      category: 'Yellows',
    ),
    AppAccent(
      name: 'Saffron Yellow',
      primary: Color(0xFFF4A261),
      soft: Color(0xFFFEF4EC),
      darkSoft: Color(0xFF452B17),
      darkSoftText: Color(0xFFFBC8A0),
      category: 'Yellows',
    ),
    AppAccent(
      name: 'Mustard Spice',
      primary: Color(0xFFD4A373),
      soft: Color(0xFFFAF3EC),
      darkSoft: Color(0xFF3D2D1E),
      darkSoftText: Color(0xFFF5CEAA),
      category: 'Yellows',
    ),

    // --- Oranges & Terracottas ---
    AppAccent(
      name: 'Sunset Orange',
      primary: Color(0xFFEA580C),
      soft: Color(0xFFFFEDD5),
      darkSoft: Color(0xFF452B1E),
      darkSoftText: Color(0xFFEBC1A8),
      category: 'Oranges',
    ),
    AppAccent(
      name: 'Peach Fuzz',
      primary: Color(0xFFFF7854),
      soft: Color(0xFFFFECE5),
      darkSoft: Color(0xFF42261E),
      darkSoftText: Color(0xFFFFB39E),
      category: 'Oranges',
    ),
    AppAccent(
      name: 'Tangerine Tango',
      primary: Color(0xFFDD4124),
      soft: Color(0xFFFCEBE8),
      darkSoft: Color(0xFF451710),
      darkSoftText: Color(0xFFFA9C8A),
      category: 'Oranges',
    ),
    AppAccent(
      name: 'Tigerlily',
      primary: Color(0xFFE2583E),
      soft: Color(0xFFFCECE8),
      darkSoft: Color(0xFF451B13),
      darkSoftText: Color(0xFFFAAA9C),
      category: 'Oranges',
    ),
    AppAccent(
      name: 'Sunset Coral',
      primary: Color(0xFFF2683A),
      soft: Color(0xFFFDEEE8),
      darkSoft: Color(0xFF451A0E),
      darkSoftText: Color(0xFFFBA285),
      category: 'Oranges',
    ),
    AppAccent(
      name: 'Canyon Clay',
      primary: Color(0xFFCE725B),
      soft: Color(0xFFFCEEEA),
      darkSoft: Color(0xFF42211A),
      darkSoftText: Color(0xFFF2A796),
      category: 'Oranges',
    ),
    AppAccent(
      name: 'Blush Rose',
      primary: Color(0xFFE07A5F),
      soft: Color(0xFFFCEEEA),
      darkSoft: Color(0xFF45241C),
      darkSoftText: Color(0xFFF7B4A3),
      category: 'Oranges',
    ),
    AppAccent(
      name: 'Burnt Ochre',
      primary: Color(0xFFBB4E2D),
      soft: Color(0xFFFCEBE6),
      darkSoft: Color(0xFF3F190D),
      darkSoftText: Color(0xFFEFA28C),
      category: 'Oranges',
    ),

    // --- Pinks, Magentas & Reds ---
    AppAccent(
      name: 'Coral Pink',
      primary: Color(0xFFE11D48),
      soft: Color(0xFFFFE4E6),
      darkSoft: Color(0xFF3D1E26),
      darkSoftText: Color(0xFFF5B7C4),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Living Coral',
      primary: Color(0xFFFF6F61),
      soft: Color(0xFFFFEBE8),
      darkSoft: Color(0xFF45221F),
      darkSoftText: Color(0xFFFFB5AD),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Viva Magenta',
      primary: Color(0xFFBB2649),
      soft: Color(0xFFFFE5EC),
      darkSoft: Color(0xFF3F1922),
      darkSoftText: Color(0xFFF29DB2),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Honeysuckle',
      primary: Color(0xFFD65076),
      soft: Color(0xFFFCECF1),
      darkSoft: Color(0xFF421825),
      darkSoftText: Color(0xFFF2A0B8),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Fuchsia Rose',
      primary: Color(0xFFC74375),
      soft: Color(0xFFFCECF2),
      darkSoft: Color(0xFF3F1525),
      darkSoftText: Color(0xFFEC8EB1),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Raspberry Sorbet',
      primary: Color(0xFFD2386C),
      soft: Color(0xFFFCE8EF),
      darkSoft: Color(0xFF421021),
      darkSoftText: Color(0xFFF08CB0),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Rose Quartz',
      primary: Color(0xFFE2929B),
      soft: Color(0xFFFCEDEE),
      darkSoft: Color(0xFF3D2125),
      darkSoftText: Color(0xFFF5BFC5),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Dusty Rose',
      primary: Color(0xFFC49076),
      soft: Color(0xFFF7EFEA),
      darkSoft: Color(0xFF3B2B22),
      darkSoftText: Color(0xFFE5BCA8),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'True Red',
      primary: Color(0xFFBF1932),
      soft: Color(0xFFFDE8EA),
      darkSoft: Color(0xFF3F0810),
      darkSoftText: Color(0xFFF27E8F),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Chili Pepper',
      primary: Color(0xFF9B1B30),
      soft: Color(0xFFF9E6E9),
      darkSoft: Color(0xFF3D0A13),
      darkSoftText: Color(0xFFE58091),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Lava Red',
      primary: Color(0xFFE63946),
      soft: Color(0xFFFFEBEC),
      darkSoft: Color(0xFF45191C),
      darkSoftText: Color(0xFFFF9EA6),
      category: 'Pinks & Reds',
    ),
    AppAccent(
      name: 'Marsala',
      primary: Color(0xFF955251),
      soft: Color(0xFFF7EBEB),
      darkSoft: Color(0xFF3B1E1E),
      darkSoftText: Color(0xFFD3A4A3),
      category: 'Pinks & Reds',
    ),

    // --- Earth & Neutrals ---
    AppAccent(
      name: 'Mocha Mousse',
      primary: Color(0xFF9B6B56),
      soft: Color(0xFFF5ECE8),
      darkSoft: Color(0xFF38251C),
      darkSoftText: Color(0xFFD6B5A6),
      category: 'Earth & Neutrals',
    ),
    AppAccent(
      name: 'Sandstorm',
      primary: Color(0xFFC2A68C),
      soft: Color(0xFFF7F3EE),
      darkSoft: Color(0xFF3B3128),
      darkSoftText: Color(0xFFDEC3AA),
      category: 'Earth & Neutrals',
    ),
    AppAccent(
      name: 'Sand Dollar',
      primary: Color(0xFFB89B82),
      soft: Color(0xFFF7F3EF),
      darkSoft: Color(0xFF3B2F25),
      darkSoftText: Color(0xFFDECDBE),
      category: 'Earth & Neutrals',
    ),
    AppAccent(
      name: 'Sand Dollar Beige',
      primary: Color(0xFFA88F78),
      soft: Color(0xFFF7F2ED),
      darkSoft: Color(0xFF382E25),
      darkSoftText: Color(0xFFD6C0AC),
      category: 'Earth & Neutrals',
    ),
    AppAccent(
      name: 'Ultimate Gray',
      primary: Color(0xFF787A7C),
      soft: Color(0xFFEFEFF0),
      darkSoft: Color(0xFF2B2C2D),
      darkSoftText: Color(0xFFBFC1C3),
      category: 'Earth & Neutrals',
    ),
    AppAccent(
      name: 'Midnight Ink',
      primary: Color(0xFF1E293B),
      soft: Color(0xFFE2E8F0),
      darkSoft: Color(0xFF282828),
      darkSoftText: Color(0xFFD0D0D0),
      category: 'Earth & Neutrals',
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
      category: 'Custom',
    );
  }
}
