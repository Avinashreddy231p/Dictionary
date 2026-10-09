import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/settings_state.dart';
import '../../../theme/app_accents.dart';
import '../../../theme/app_colors.dart';

class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends ConsumerState<AppearanceSettingsScreen> {
  String _selectedAccentCategory = 'All';
  String _pantoneSearchQuery = '';
  late TextEditingController _hexController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _hexController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getFontScaleLabel(double scale) {
    if (scale <= 0.95) return 'Small (90%)';
    if (scale <= 1.05) return 'Normal (100%)';
    if (scale <= 1.2) return 'Large (115%)';
    return 'Extra Large (130%)';
  }

  void _applyHexColor(String hexText, SettingsNotifier notifier) {
    String clean = hexText.replaceAll('#', '').trim();
    if (clean.length == 6) {
      clean = 'FF$clean';
    }
    final val = int.tryParse(clean, radix: 16);
    if (val != null) {
      final color = Color(val);
      notifier.setAccentColor(color);
      _showFeedback(context, 'Custom color applied: #${color.value.toRadixString(16).substring(2).toUpperCase()}');
      Navigator.pop(context);
    } else {
      _showFeedback(context, 'Invalid Hex Color code. Use e.g. #3B82F6');
    }
  }

  void _showHexColorDialog(BuildContext context, Color currentColor, SettingsNotifier notifier) {
    _hexController.text = '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}';
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.color_filter, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('Custom Hex Color', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter any 6-character hex code (e.g. #0077EE, #FF5722, #10B981):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _hexController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.tag),
                hintText: 'FF5722',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _applyHexColor(_hexController.text, notifier),
            child: const Text('Apply Color'),
          ),
        ],
      ),
    );
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case 'Purples':
        return [const Color(0xFF6344FF), const Color(0xFFC026D3)];
      case 'Blues':
        return [const Color(0xFF2563EB), const Color(0xFF0D9488)];
      case 'Greens':
        return [const Color(0xFF059669), const Color(0xFF88B04B)];
      case 'Yellows':
        return [const Color(0xFFD97706), const Color(0xFFE0BB10)];
      case 'Oranges':
        return [const Color(0xFFEA580C), const Color(0xFFFF7854)];
      case 'Pinks & Reds':
        return [const Color(0xFFE11D48), const Color(0xFFBB2649)];
      case 'Earth & Neutrals':
        return [const Color(0xFF9B6B56), const Color(0xFF1E293B)];
      case 'All':
      default:
        return [
          const Color(0xFF6344FF),
          const Color(0xFF2563EB),
          const Color(0xFF059669),
          const Color(0xFFEA580C),
          const Color(0xFFE11D48),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    const categories = [
      'All',
      'Purples',
      'Blues',
      'Greens',
      'Yellows',
      'Oranges',
      'Pinks & Reds',
      'Earth & Neutrals',
    ];

    final categoryFiltered = _selectedAccentCategory == 'All'
        ? AppAccent.presets
        : AppAccent.presets
            .where((a) => a.category == _selectedAccentCategory)
            .toList();

    final filteredPresets = _pantoneSearchQuery.isEmpty
        ? categoryFiltered
        : categoryFiltered
            .where((a) =>
                a.name.toLowerCase().contains(_pantoneSearchQuery.toLowerCase()) ||
                a.code.toLowerCase().contains(_pantoneSearchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Appearance & Theme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Appearance',
            onPressed: () {
              settingsNotifier.resetToDefaults();
              _showFeedback(context, 'Appearance settings restored to defaults');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Theme Mode ---
              Text(
                'Theme Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how LexiLens looks on your device',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildOptionTile(
                          context,
                          label: 'System',
                          icon: CupertinoIcons.device_phone_portrait,
                          isSelected: settings.themeMode == ThemeMode.system,
                          onTap: () {
                            settingsNotifier.setThemeMode(ThemeMode.system);
                            _showFeedback(context, 'Theme set to System Default');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionTile(
                          context,
                          label: 'Light',
                          icon: CupertinoIcons.sun_max,
                          isSelected: settings.themeMode == ThemeMode.light,
                          onTap: () {
                            settingsNotifier.setThemeMode(ThemeMode.light);
                            _showFeedback(context, 'Theme set to Light Mode');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionTile(
                          context,
                          label: 'Dark',
                          icon: CupertinoIcons.moon,
                          isSelected: settings.themeMode == ThemeMode.dark,
                          onTap: () {
                            settingsNotifier.setThemeMode(ThemeMode.dark);
                            _showFeedback(context, 'Theme set to Dark Mode');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. Display Canvas Variants & Contrast Profiles ---
              Text(
                'Display Variants & Contrast',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Specialized reading modes and high-contrast OLED profiles',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Display Canvas Variant',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select canvas background tint and display profiles',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildVariantTile(
                            context,
                            id: 'standard',
                            label: 'Standard',
                            previewBg: isDark ? const Color(0xFF11111B) : const Color(0xFFFFF9EE),
                            previewCard: isDark ? const Color(0xFF1B1B2A) : Colors.white,
                            isSelected: settings.themeVariant == 'standard',
                            onTap: () {
                              settingsNotifier.setThemeVariant('standard');
                              _showFeedback(context, 'Set theme variant to Standard');
                            },
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                          _buildVariantTile(
                            context,
                            id: 'oled',
                            label: 'OLED Black',
                            previewBg: const Color(0xFF000000),
                            previewCard: const Color(0xFF0E0E14),
                            isSelected: settings.themeVariant == 'oled',
                            onTap: () {
                              settingsNotifier.setThemeVariant('oled');
                              _showFeedback(context, 'Set theme variant to Pure OLED Black');
                            },
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                          _buildVariantTile(
                            context,
                            id: 'sepia',
                            label: 'Sepia Warmth',
                            previewBg: isDark ? const Color(0xFF261D15) : const Color(0xFFFBF0D9),
                            previewCard: isDark ? const Color(0xFF33271D) : const Color(0xFFFFF7E6),
                            isSelected: settings.themeVariant == 'sepia',
                            onTap: () {
                              settingsNotifier.setThemeVariant('sepia');
                              _showFeedback(context, 'Set theme variant to Sepia Warmth');
                            },
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                          _buildVariantTile(
                            context,
                            id: 'nordic',
                            label: 'Nordic Slate',
                            previewBg: isDark ? const Color(0xFF141C24) : const Color(0xFFF0F4F8),
                            previewCard: isDark ? const Color(0xFF1E2834) : Colors.white,
                            isSelected: settings.themeVariant == 'nordic',
                            onTap: () {
                              settingsNotifier.setThemeVariant('nordic');
                              _showFeedback(context, 'Set theme variant to Nordic Slate');
                            },
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                          _buildVariantTile(
                            context,
                            id: 'matcha',
                            label: 'Matcha Sage',
                            previewBg: isDark ? const Color(0xFF152018) : const Color(0xFFF2F7F2),
                            previewCard: isDark ? const Color(0xFF1F2E23) : Colors.white,
                            isSelected: settings.themeVariant == 'matcha',
                            onTap: () {
                              settingsNotifier.setThemeVariant('matcha');
                              _showFeedback(context, 'Set theme variant to Botanical Matcha');
                            },
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                          _buildVariantTile(
                            context,
                            id: 'rose',
                            label: 'Velvet Rose',
                            previewBg: isDark ? const Color(0xFF23161B) : const Color(0xFFFAF2F4),
                            previewCard: isDark ? const Color(0xFF301E25) : Colors.white,
                            isSelected: settings.themeVariant == 'rose',
                            onTap: () {
                              settingsNotifier.setThemeVariant('rose');
                              _showFeedback(context, 'Set theme variant to Velvet Rose');
                            },
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                          _buildVariantTile(
                            context,
                            id: 'synth',
                            label: 'Cyber Synth',
                            previewBg: isDark ? const Color(0xFF151022) : const Color(0xFFF7F2FA),
                            previewCard: isDark ? const Color(0xFF201832) : Colors.white,
                            isSelected: settings.themeVariant == 'synth',
                            onTap: () {
                              settingsNotifier.setThemeVariant('synth');
                              _showFeedback(context, 'Set theme variant to Cyber Synth');
                            },
                            primaryColor: primaryColor,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. Custom Color Wheel & Official Pantone Presets ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accent Color & Pantone Presets',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '63 Curated Pantone Colors + Custom Hex Picker',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _showHexColorDialog(context, settings.accentColor, settingsNotifier),
                    icon: const Icon(Icons.colorize, size: 16),
                    label: const Text('Custom Hex', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick Search Bar for Pantone Palette
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C2C) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _pantoneSearchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search 63 Pantone colors... e.g. "Peach", "Magenta", "Gold"',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                    suffixIcon: _pantoneSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _pantoneSearchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Creative Glowing Category Swatch Filter Bar
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedAccentCategory == category;
                    final count = category == 'All'
                        ? AppAccent.presets.length
                        : AppAccent.presets.where((a) => a.category == category).length;

                    return _buildCreativeCategoryPill(
                      category: category,
                      count: count,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedAccentCategory = category;
                        });
                      },
                      primaryColor: primaryColor,
                      isDark: isDark,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // 4-Row Horizontal Scrolling Accent Presets Grid
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: filteredPresets.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(CupertinoIcons.color_filter,
                                    size: 32,
                                    color: isDark ? Colors.white38 : Colors.black38),
                                const SizedBox(height: 8),
                                Text(
                                  'No Pantone color found for "$_pantoneSearchQuery"',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  for (int i = 0; i < filteredPresets.length; i += 4)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _buildAccentTile(
                                        context: context,
                                        accent: filteredPresets[i],
                                        isDark: isDark,
                                        settings: settings,
                                        settingsNotifier: settingsNotifier,
                                      ),
                                    ),
                                ],
                              ),
                              if (filteredPresets.length > 1) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    for (int i = 1; i < filteredPresets.length; i += 4)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: _buildAccentTile(
                                          context: context,
                                          accent: filteredPresets[i],
                                          isDark: isDark,
                                          settings: settings,
                                          settingsNotifier: settingsNotifier,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              if (filteredPresets.length > 2) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    for (int i = 2; i < filteredPresets.length; i += 4)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: _buildAccentTile(
                                          context: context,
                                          accent: filteredPresets[i],
                                          isDark: isDark,
                                          settings: settings,
                                          settingsNotifier: settingsNotifier,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              if (filteredPresets.length > 3) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    for (int i = 3; i < filteredPresets.length; i += 4)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: _buildAccentTile(
                                          context: context,
                                          accent: filteredPresets[i],
                                          isDark: isDark,
                                          settings: settings,
                                          settingsNotifier: settingsNotifier,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 4. Typography & Font Scaling ---
              Text(
                'Typography & Font Family',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select your preferred typeface and text scale multiplier',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Font Scale',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _getFontScaleLabel(settings.fontScale),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primaryColor,
                          thumbColor: primaryColor,
                          overlayColor: primaryColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: settings.fontScale,
                          min: 0.9,
                          max: 1.3,
                          divisions: 4,
                          onChanged: (val) {
                            settingsNotifier.setFontScale(val);
                          },
                        ),
                      ),
                      const Divider(height: 28),
                      const Text(
                        'Font Family',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFontOption(
                              context,
                              family: 'SF Pro',
                              label: 'SF Pro',
                              subLabel: 'Apple System UI',
                              isSelected: settings.appFontFamily == 'SF Pro',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('SF Pro');
                                _showFeedback(context, 'Font set to SF Pro');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFontOption(
                              context,
                              family: 'Inter',
                              label: 'Inter',
                              subLabel: 'Clean Modern',
                              isSelected: settings.appFontFamily == 'Inter',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Inter');
                                _showFeedback(context, 'Font set to Inter');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFontOption(
                              context,
                              family: 'Roboto',
                              label: 'Roboto',
                              subLabel: 'Material Standard',
                              isSelected: settings.appFontFamily == 'Roboto',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Roboto');
                                _showFeedback(context, 'Font set to Roboto');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFontOption(
                              context,
                              family: 'Figtree',
                              label: 'Figtree',
                              subLabel: 'Geometric Sans',
                              isSelected: settings.appFontFamily == 'Figtree',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Figtree');
                                _showFeedback(
                                    context, 'Font set to Figtree Geometric');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFontOption(
                              context,
                              family: 'Nunito',
                              label: 'Nunito',
                              subLabel: 'Rounded Friendly',
                              isSelected: settings.appFontFamily == 'Nunito',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Nunito');
                                _showFeedback(context, 'Font set to Nunito');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFontOption(
                              context,
                              family: 'Lora',
                              label: 'Lora',
                              subLabel: 'Classic Serif',
                              isSelected: settings.appFontFamily == 'Lora',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Lora');
                                _showFeedback(context, 'Font set to Lora Serif');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 5. Component Styling & Shapes ---
              Text(
                'Component Styling & Shapes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize card corner rounding, borders, search shapes, and density',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Radius Style
                      const Text(
                        'Card Corner Rounding',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Sharp',
                              isSelected: settings.cardRadiusStyle == 'sharp',
                              onTap: () {
                                settingsNotifier.setCardRadiusStyle('sharp');
                                _showFeedback(context, 'Card radius set to Sharp');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Rounded',
                              isSelected: settings.cardRadiusStyle == 'rounded',
                              onTap: () {
                                settingsNotifier.setCardRadiusStyle('rounded');
                                _showFeedback(context, 'Card radius set to Rounded');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Pill Soft',
                              isSelected: settings.cardRadiusStyle == 'pill',
                              onTap: () {
                                settingsNotifier.setCardRadiusStyle('pill');
                                _showFeedback(context, 'Card radius set to Pill Soft');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Border Width Style
                      const Text(
                        'Border Thickness',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Thin (1px)',
                              isSelected: settings.borderWidthStyle == 'thin',
                              onTap: () {
                                settingsNotifier.setBorderWidthStyle('thin');
                                _showFeedback(context, 'Border thickness set to Thin');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Standard (1.5px)',
                              isSelected: settings.borderWidthStyle == 'standard',
                              onTap: () {
                                settingsNotifier.setBorderWidthStyle('standard');
                                _showFeedback(context, 'Border thickness set to Standard');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Bold (2px)',
                              isSelected: settings.borderWidthStyle == 'bold',
                              onTap: () {
                                settingsNotifier.setBorderWidthStyle('bold');
                                _showFeedback(context, 'Border thickness set to Bold');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Card Shadow Style
                      const Text(
                        'Card Shadow Elevation',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Flat (None)',
                              isSelected: settings.cardShadowStyle == 'none',
                              onTap: () {
                                settingsNotifier.setCardShadowStyle('none');
                                _showFeedback(context, 'Card shadow set to Flat');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Soft Ambient',
                              isSelected: settings.cardShadowStyle == 'soft',
                              onTap: () {
                                settingsNotifier.setCardShadowStyle('soft');
                                _showFeedback(context, 'Card shadow set to Soft');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Deep Elevation',
                              isSelected: settings.cardShadowStyle == 'deep',
                              onTap: () {
                                settingsNotifier.setCardShadowStyle('deep');
                                _showFeedback(context, 'Card shadow set to Deep');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Search Bar Shape
                      const Text(
                        'Search Bar Geometry',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Full Pill',
                              isSelected: settings.searchBarShape == 'pill',
                              onTap: () {
                                settingsNotifier.setSearchBarShape('pill');
                                _showFeedback(context, 'Search bar shape set to Full Pill');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Rounded Box',
                              isSelected: settings.searchBarShape == 'roundedBox',
                              onTap: () {
                                settingsNotifier.setSearchBarShape('roundedBox');
                                _showFeedback(context, 'Search bar shape set to Rounded Box');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Definition Layout Density
                      const Text(
                        'Definition Density',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Spacious Comfort',
                              isSelected: settings.definitionDensity == 'spacious',
                              onTap: () {
                                settingsNotifier.setDefinitionDensity('spacious');
                                _showFeedback(context, 'Definition density set to Spacious');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Compact Dense',
                              isSelected: settings.definitionDensity == 'compact',
                              onTap: () {
                                settingsNotifier.setDefinitionDensity('compact');
                                _showFeedback(context, 'Definition density set to Compact');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 6. Motion & Navigation Effects ---
              Text(
                'Motion & Page Transitions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Configure screen navigation animations and motion effects',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Smooth UI Animations',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'Enable fluid page transitions and interactive micro-animations',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: settings.enableAnimations,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          settingsNotifier.setEnableAnimations(val);
                          _showFeedback(
                            context,
                            val ? 'Smooth animations enabled' : 'Reduced motion enabled',
                          );
                        },
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Page Navigation Transition',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Standard Native',
                              isSelected: settings.pageTransitionStyle == 'standard',
                              onTap: () {
                                settingsNotifier.setPageTransitionStyle('standard');
                                _showFeedback(context, 'Transition set to Standard');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Zoom In',
                              isSelected: settings.pageTransitionStyle == 'zoom',
                              onTap: () {
                                settingsNotifier.setPageTransitionStyle('zoom');
                                _showFeedback(context, 'Transition set to Zoom In');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChipTile(
                              label: 'Smooth Fade',
                              isSelected: settings.pageTransitionStyle == 'fade',
                              onTap: () {
                                settingsNotifier.setPageTransitionStyle('fade');
                                _showFeedback(context, 'Transition set to Smooth Fade');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 7. Canvas Background & Texture Patterns ---
              Text(
                'Canvas Background & Effects',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Overlay ambient gradient blobs or subtle texture patterns',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Floating Ambient Gradient Blobs',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'Render glowing background aura shapes',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: settings.showBgBlobs,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          settingsNotifier.setShowBgBlobs(val);
                          _showFeedback(
                            context,
                            val ? 'Ambient Blobs enabled' : 'Ambient Blobs disabled',
                          );
                        },
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Background Texture Pattern',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextureOption(
                              context,
                              label: 'Plain Solid',
                              icon: CupertinoIcons.square,
                              isSelected: settings.bgTexture == 'none',
                              onTap: () {
                                settingsNotifier.setBgTexture('none');
                                _showFeedback(context, 'Set background to Plain Solid');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextureOption(
                              context,
                              label: 'Blueprint Grid',
                              icon: CupertinoIcons.grid,
                              isSelected: settings.bgTexture == 'grid',
                              onTap: () {
                                settingsNotifier.setBgTexture('grid');
                                _showFeedback(context, 'Set background to Blueprint Grid');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextureOption(
                              context,
                              label: 'Subtle Dots',
                              icon: CupertinoIcons.circle_grid_hex,
                              isSelected: settings.bgTexture == 'dots',
                              onTap: () {
                                settingsNotifier.setBgTexture('dots');
                                _showFeedback(context, 'Set background to Subtle Dots');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextureOption(
                              context,
                              label: 'Cross Hatch',
                              icon: CupertinoIcons.divide,
                              isSelected: settings.bgTexture == 'crosshatch',
                              onTap: () {
                                settingsNotifier.setBgTexture('crosshatch');
                                _showFeedback(context, 'Set background to Cross Hatch');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      if (settings.bgTexture != 'none') ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Texture Opacity',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              '${(settings.bgTextureOpacity * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: primaryColor,
                            thumbColor: primaryColor,
                            overlayColor: primaryColor.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: settings.bgTextureOpacity,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            onChanged: (val) {
                              settingsNotifier.setBgTextureOpacity(val);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreativeCategoryPill({
    required String category,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    final gradientColors = _getCategoryGradient(category);
    final activeGlowColor = gradientColors.first;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF252538) : Colors.white)
              : (isDark
                  ? const Color(0xFF1C1C2C)
                  : primaryColor.withOpacity(0.06)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? activeGlowColor
                : (isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeGlowColor.withOpacity(0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeGlowColor.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected
                    ? (isDark ? Colors.white : activeGlowColor)
                    : (isDark ? Colors.white70 : AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeGlowColor.withOpacity(0.18)
                    : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? activeGlowColor
                      : (isDark ? Colors.white54 : AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContainer({
    required BuildContext context,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B2B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildVariantTile(
    BuildContext context, {
    required String id,
    required String label,
    required Color previewBg,
    required Color previewCard,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.15)
              : (isDark ? const Color(0xFF28283D) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? Colors.white12 : AppColors.border),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: previewBg,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: previewCard,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF28283D) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF36364E) : AppColors.border),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChipTile({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF28283D) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF36364E) : AppColors.border),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : AppColors.textPrimary),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFontOption(
    BuildContext context, {
    required String family,
    required String label,
    required String subLabel,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.12)
              : (isDark ? const Color(0xFF28283D) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? Colors.white12 : AppColors.border),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.text_fields,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      fontFamily: family,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextureOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF28283D) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF36364E) : AppColors.border),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
              size: 18,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentTile({
    required BuildContext context,
    required AppAccent accent,
    required bool isDark,
    required SettingsState settings,
    required SettingsNotifier settingsNotifier,
  }) {
    final isSelected = settings.accentColor.value == accent.primary.value;
    return InkWell(
      onTap: () {
        settingsNotifier.setAccentColor(accent.primary);
        _showFeedback(
            context, 'Accent color set to ${accent.name} (${accent.code})');
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 155,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accent.primary : accent.adaptiveSoft(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accent.primary
                : (isDark
                    ? accent.darkSoftText.withOpacity(0.3)
                    : AppColors.border),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.primary.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : accent.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 10,
                          color: accent.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    accent.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                accent.code,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white.withOpacity(0.85)
                      : (isDark ? Colors.white54 : AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
