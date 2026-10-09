import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../theme/app_accents.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Appearance & Theme'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildThemeOption(
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          label: 'Light',
                          icon: CupertinoIcons.sun_max_fill,
                          isSelected: settings.themeMode == ThemeMode.light,
                          onTap: () {
                            settingsNotifier.setThemeMode(ThemeMode.light);
                            _showFeedback(context, 'Light Theme activated');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          label: 'Dark',
                          icon: CupertinoIcons.moon_fill,
                          isSelected: settings.themeMode == ThemeMode.dark,
                          onTap: () {
                            settingsNotifier.setThemeMode(ThemeMode.dark);
                            _showFeedback(context, 'Dark Theme activated');
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
              Text(
                'Theme Variant & Aesthetics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize background tone and surface aesthetics',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 16) / 3;
                      final accentHsl = HSLColor.fromColor(settings.accentColor);
                      final accentLightTint = accentHsl.withLightness(0.97).withSaturation(0.28).toColor();
                      final accentDarkTint = accentHsl.withLightness(0.08).withSaturation(0.20).toColor();

                      final variants = [
                        (id: 'standard', name: 'Standard', sub: 'Playful Warm', lightCol: const Color(0xFFFFF9EE), darkCol: const Color(0xFF141414)),
                        (id: 'accentTint', name: 'Accent Sync', sub: 'Subtle Tint', lightCol: accentLightTint, darkCol: accentDarkTint),
                        (id: 'sepia', name: 'Warm Sepia', sub: 'Book Reader', lightCol: const Color(0xFFFBF0D9), darkCol: const Color(0xFF261D15)),
                        (id: 'oled', name: 'OLED Black', sub: 'Pitch Dark', lightCol: const Color(0xFFF5F5F7), darkCol: const Color(0xFF000000)),
                        (id: 'nordic', name: 'Nordic Frost', sub: 'Cool Slate', lightCol: const Color(0xFFF0F4F8), darkCol: const Color(0xFF141C24)),
                        (id: 'matcha', name: 'Matcha Sage', sub: 'Zen Botanical', lightCol: const Color(0xFFF2F7F2), darkCol: const Color(0xFF152018)),
                        (id: 'rose', name: 'Rose Velvet', sub: 'Soft Blush', lightCol: const Color(0xFFFAF2F4), darkCol: const Color(0xFF23161B)),
                        (id: 'synth', name: 'Midnight', sub: 'Cyber Purple', lightCol: const Color(0xFFF7F2FA), darkCol: const Color(0xFF151022)),
                      ];

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: variants.map((v) {
                          final isSelected = settings.themeVariant == v.id;
                          final tone = isDark ? v.darkCol : v.lightCol;

                          return SizedBox(
                            width: itemWidth,
                            child: _buildVariantOption(
                              context,
                              label: v.name,
                              subtitle: v.sub,
                              isSelected: isSelected,
                              tonePreview: tone,
                              onTap: () {
                                settingsNotifier.setThemeVariant(v.id);
                                _showFeedback(context, 'Set to ${v.name} Theme');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Definition Layout Density',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose layout spacing and list density for dictionary definitions',
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
                        child: _buildVariantOption(
                          context,
                          label: 'Spacious Cards',
                          subtitle: 'Generous Spacing',
                          isSelected: settings.definitionDensity == 'spacious',
                          onTap: () {
                            settingsNotifier.setDefinitionDensity('spacious');
                            _showFeedback(context, 'Set definitions to Spacious Cards');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildVariantOption(
                          context,
                          label: 'Compact List',
                          subtitle: 'Fast Skimming',
                          isSelected: settings.definitionDensity == 'compact',
                          onTap: () {
                            settingsNotifier.setDefinitionDensity('compact');
                            _showFeedback(context, 'Set definitions to Compact List');
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
              Text(
                'Card Corner Radius Style',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize corner roundness across cards and containers',
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
                        child: _buildVariantOption(
                          context,
                          label: 'Sharp',
                          subtitle: '12px Radius',
                          isSelected: settings.cardRadiusStyle == 'sharp',
                          onTap: () {
                            settingsNotifier.setCardRadiusStyle('sharp');
                            _showFeedback(context, 'Set card corners to Sharp Modern');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVariantOption(
                          context,
                          label: 'Rounded',
                          subtitle: '24px Radius',
                          isSelected: settings.cardRadiusStyle == 'rounded',
                          onTap: () {
                            settingsNotifier.setCardRadiusStyle('rounded');
                            _showFeedback(context, 'Set card corners to Playful Rounded');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVariantOption(
                          context,
                          label: 'Pill',
                          subtitle: '32px Radius',
                          isSelected: settings.cardRadiusStyle == 'pill',
                          onTap: () {
                            settingsNotifier.setCardRadiusStyle('pill');
                            _showFeedback(context, 'Set card corners to Pill Smooth');
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
              Text(
                'Card Border Thickness',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize card border stroke thickness',
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
                        child: _buildVariantOption(
                          context,
                          label: 'Thin',
                          subtitle: '1.0px Stroke',
                          isSelected: settings.borderWidthStyle == 'thin',
                          onTap: () {
                            settingsNotifier.setBorderWidthStyle('thin');
                            _showFeedback(context, 'Set card borders to Thin Delicate');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVariantOption(
                          context,
                          label: 'Standard',
                          subtitle: '1.5px Stroke',
                          isSelected: settings.borderWidthStyle == 'standard',
                          onTap: () {
                            settingsNotifier.setBorderWidthStyle('standard');
                            _showFeedback(context, 'Set card borders to Standard Playful');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVariantOption(
                          context,
                          label: 'Bold Retro',
                          subtitle: '2.5px Stroke',
                          isSelected: settings.borderWidthStyle == 'bold',
                          onTap: () {
                            settingsNotifier.setBorderWidthStyle('bold');
                            _showFeedback(context, 'Set card borders to Bold Retro');
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
              Text(
                'Search Bar Shape',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize search input field corner style',
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
                        child: _buildVariantOption(
                          context,
                          label: 'Full Pill',
                          subtitle: '50px Rounded',
                          isSelected: settings.searchBarShape == 'pill',
                          onTap: () {
                            settingsNotifier.setSearchBarShape('pill');
                            _showFeedback(context, 'Set search bar to Full Pill');
                          },
                          primaryColor: primaryColor,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildVariantOption(
                          context,
                          label: 'Rounded Box',
                          subtitle: '16px Rectangle',
                          isSelected: settings.searchBarShape == 'roundedBox',
                          onTap: () {
                            settingsNotifier.setSearchBarShape('roundedBox');
                            _showFeedback(context, 'Set search bar to Rounded Box');
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
              Text(
                'Typography Font Family',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose typography family across headings, definitions & notes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'SF Pro',
                              subtitle: 'Apple System Sans',
                              isSelected: settings.appFontFamily == 'SF Pro',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('SF Pro');
                                _showFeedback(context, 'Font set to San Francisco Pro');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'SF Pro Display',
                              subtitle: 'Headline Display',
                              isSelected: settings.appFontFamily == 'SF Pro Display',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('SF Pro Display');
                                _showFeedback(context, 'Font set to SF Pro Display');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'SF Pro Rounded',
                              subtitle: 'Apple Soft Rounded',
                              isSelected: settings.appFontFamily == 'SF Pro Rounded',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('SF Pro Rounded');
                                _showFeedback(context, 'Font set to SF Pro Rounded');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'Nunito',
                              subtitle: 'Playful Rounded',
                              isSelected: settings.appFontFamily == 'Nunito',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Nunito');
                                _showFeedback(context, 'Font set to Nunito Playful');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'Inter',
                              subtitle: 'Swiss Sans',
                              isSelected: settings.appFontFamily == 'Inter',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Inter');
                                _showFeedback(context, 'Font set to Inter Sans');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'Lora',
                              subtitle: 'Editorial Serif',
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'Fira Code',
                              subtitle: 'Monospace',
                              isSelected: settings.appFontFamily == 'Fira Code',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Fira Code');
                                _showFeedback(context, 'Font set to Fira Monospace');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildVariantOption(
                              context,
                              label: 'Figtree',
                              subtitle: 'Geometric Sans',
                              isSelected: settings.appFontFamily == 'Figtree',
                              onTap: () {
                                settingsNotifier.setAppFontFamily('Figtree');
                                _showFeedback(context, 'Font set to Figtree Geometric');
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
              Text(
                'Official Pantone Palette Presets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Curated Pantone Color of the Year & Iconic Palette Colors',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppAccent.presets.map((accent) {
                      final isSelected =
                          settings.accentColor.value == accent.primary.value;
                      return InkWell(
                        onTap: () {
                          settingsNotifier.setAccentColor(accent.primary);
                          _showFeedback(context, 'Accent color set to ${accent.name} (${accent.code})');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent.primary
                                : accent.adaptiveSoft(context),
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
                                mainAxisSize: MainAxisSize.min,
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
                                  Text(
                                    accent.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white
                                              : AppColors.textPrimary),
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
                                        : (isDark
                                            ? Colors.white54
                                            : AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Background Texture Pattern',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Overlay subtle geometric grid or dot pattern on the canvas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
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
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildTextureOption(
                              context,
                              label: 'Dot Grid',
                              icon: CupertinoIcons.circle_grid_3x3_fill,
                              isSelected: settings.bgTexture == 'dots',
                              onTap: () {
                                settingsNotifier.setBgTexture('dots');
                                _showFeedback(context, 'Set background to Dot Grid');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildTextureOption(
                              context,
                              label: 'Line Grid',
                              icon: CupertinoIcons.grid,
                              isSelected: settings.bgTexture == 'grid',
                              onTap: () {
                                settingsNotifier.setBgTexture('grid');
                                _showFeedback(context, 'Set background to Line Grid');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildTextureOption(
                              context,
                              label: 'Crosshatch',
                              icon: CupertinoIcons.line_horizontal_3_decrease,
                              isSelected: settings.bgTexture == 'crosshatch',
                              onTap: () {
                                settingsNotifier.setBgTexture('crosshatch');
                                _showFeedback(context, 'Set background to Crosshatch');
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      if (settings.bgTexture != 'none') ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pattern Opacity',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Adjust visibility intensity of the background pattern',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${(settings.bgTextureOpacity * 100).round()}%',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Slider.adaptive(
                          value: settings.bgTextureOpacity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            settingsNotifier.setBgTextureOpacity(val);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Interactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haptic Feedback',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tactile vibration on tap actions',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: settings.hapticFeedbackEnabled,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          settingsNotifier.setHapticFeedback(val);
                          if (val) HapticFeedback.selectionClick();
                          _showFeedback(
                              context,
                              val
                                  ? 'Haptic feedback enabled'
                                  : 'Haptic feedback disabled');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Typography & Scaling',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
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
                          Expanded(
                            child: Text(
                              'Text Scaling',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _getFontScaleLabel(settings.fontScale),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: isDark
                              ? const Color(0xFF32324A)
                              : primaryColor.withOpacity(0.15),
                          thumbColor: primaryColor,
                          overlayColor: primaryColor.withOpacity(0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: settings.fontScale,
                          min: 0.9,
                          max: 1.3,
                          divisions: 4,
                          onChanged: (value) =>
                              settingsNotifier.setFontScale(value),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF26263A)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF383852)
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.text_format,
                                color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Preview: Dictionary App helps you master words effortlessly.',
                                style: TextStyle(
                                  fontSize: 14 * settings.fontScale,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child, required bool isDark, BuildContext? context}) {
    final radius = context != null ? AppTheme.cardRadius(context) : 24.0;
    final strokeWidth = context != null ? AppTheme.borderWidth(context) : 1.5;

    final cardBgColor = isDark
        ? (context != null ? Theme.of(context).colorScheme.surface : AppColors.darkSurface)
        : Colors.white;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.border;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor,
          width: strokeWidth,
        ),
      ),
      child: child,
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF27273C) : AppColors.background),
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

  Widget _buildVariantOption(
    BuildContext context, {
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
    Color? tonePreview,
  }) {
    final unselectedBg = isDark
        ? (tonePreview?.withOpacity(0.3) ?? const Color(0xFF27273C))
        : (tonePreview ?? AppColors.background);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : unselectedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF36364E) : AppColors.border),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            if (tonePreview != null) ...[
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : tonePreview,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white70 : (isDark ? Colors.white24 : Colors.black12),
                    width: 1,
                  ),
                ),
              ),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white70
                      : (isDark ? Colors.white54 : AppColors.textSecondary),
                ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF27273C) : AppColors.background),
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
}
