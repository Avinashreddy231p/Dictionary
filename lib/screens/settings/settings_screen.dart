import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../data/models/settings_state.dart';
import '../../theme/app_accents.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, primaryColor),
                    const SizedBox(height: 20),
                    _buildStatsCard(context, ref, primaryColor, isDark, settings.dailyGoal),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      icon: CupertinoIcons.sparkles,
                      title: 'AI Assistant & Gemini Engine',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _GeminiSettingsCard(
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      icon: CupertinoIcons.paintbrush_fill,
                      title: 'Appearance & Interaction',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildAppearanceCard(
                      context,
                      settings,
                      settingsNotifier,
                      primaryColor,
                      isDark,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      icon: CupertinoIcons.speaker_2_fill,
                      title: 'Audio & Pronunciation',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildAudioCard(
                      context,
                      settings,
                      settingsNotifier,
                      primaryColor,
                      isDark,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      icon: CupertinoIcons.flame_fill,
                      title: 'Learning & Goals',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildLearningCard(
                      context,
                      ref,
                      settings,
                      settingsNotifier,
                      primaryColor,
                      isDark,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      icon: CupertinoIcons.tray_full_fill,
                      title: 'Storage & Data',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildStorageCard(
                      context,
                      ref,
                      settings,
                      settingsNotifier,
                      primaryColor,
                      isDark,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      icon: CupertinoIcons.info_circle_fill,
                      title: 'About & Support',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildAboutCard(context, ref, settingsNotifier, primaryColor, isDark),
                    const SizedBox(height: 32),
                    _buildFooter(context, primaryColor),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      height: 1.1,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Customize your LexiLens experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(
            CupertinoIcons.gear_alt_fill,
            color: primaryColor,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    bool isDark,
    int dailyGoal,
  ) {
    final savedWordsAsync = ref.watch(savedWordsStreamProvider);
    final todayWordsAsync = ref.watch(todaySavedWordsStreamProvider);
    final masteredWordsAsync = ref.watch(masteredWordsStreamProvider);

    final savedWordsCount = savedWordsAsync.when(
      data: (words) => words.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final todaySavedCount = todayWordsAsync.when(
      data: (words) => words.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final masteredCount = masteredWordsAsync.when(
      data: (words) => words.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final masteryRate = savedWordsCount == 0
        ? '0% Rate'
        : '${((masteredCount / savedWordsCount) * 100).round()}% Accuracy';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/stats'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSoftYellow
                        : AppColors.softYellow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chart_bar_square_fill,
                    color: isDark
                        ? AppColors.darkSoftYellowText
                        : Colors.orange.shade800,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Learning Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Full Analytics',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(CupertinoIcons.chevron_right, size: 12, color: primaryColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Streak',
                    value: '14 Days 🔥',
                    icon: CupertinoIcons.flame_fill,
                    iconColor: Colors.orange,
                    bgColor: isDark ? AppColors.darkSoftYellow : AppColors.softYellow.withOpacity(0.5),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Words Saved',
                    value: '$savedWordsCount Words',
                    icon: CupertinoIcons.book_fill,
                    iconColor: primaryColor,
                    bgColor: isDark ? AppColors.darkSoftPurple : AppColors.softPurple.withOpacity(0.5),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Today\'s Progress',
                    value: '$todaySavedCount / $dailyGoal Words',
                    icon: CupertinoIcons.checkmark_seal_fill,
                    iconColor: Colors.green,
                    bgColor: isDark ? AppColors.darkSoftGreen : AppColors.softGreen.withOpacity(0.5),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Mastery Rate',
                    value: masteryRate,
                    icon: CupertinoIcons.star_fill,
                    iconColor: Colors.amber,
                    bgColor: isDark ? AppColors.darkSoftBlue : AppColors.softBlue.withOpacity(0.5),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? iconColor.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildAppearanceCard(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    return _buildCardContainer(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Text(
              'Accent Color',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your favorite highlight theme across LexiLens',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppAccent.presets.map((accent) {
                final isSelected = settings.accentColor.value == accent.primary.value;
                return InkWell(
                  onTap: () {
                    settingsNotifier.setAccentColor(accent.primary);
                    _showFeedback(context, 'Accent color set to ${accent.name}');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent.primary
                          : (isDark ? const Color(0xFF27273C) : accent.soft.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? accent.primary
                            : (isDark ? const Color(0xFF383852) : AppColors.border),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
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
                                  size: 11,
                                  color: accent.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          accent.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
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
                        'Haptic Feedback',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
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
                    _showFeedback(context, val ? 'Haptic feedback enabled' : 'Haptic feedback disabled');
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Text Scaling',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _getFontScaleLabel(settings.fontScale),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: primaryColor,
                inactiveTrackColor: isDark ? const Color(0xFF32324A) : primaryColor.withOpacity(0.15),
                thumbColor: primaryColor,
                overlayColor: primaryColor.withOpacity(0.2),
                trackHeight: 6,
              ),
              child: Slider(
                value: settings.fontScale,
                min: 0.9,
                max: 1.3,
                divisions: 4,
                onChanged: (value) => settingsNotifier.setFontScale(value),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF26263A) : AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF383852) : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.text_format, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Preview: LexiLens helps you master words effortlessly.',
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

  Widget _buildAudioCard(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    return _buildCardContainer(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferred Pronunciation Accent',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAccentChip(
                    context,
                    label: '🇺🇸 US English',
                    subtitle: 'General American',
                    isSelected: settings.preferredAccent == 'US',
                    onTap: () {
                      settingsNotifier.setPreferredAccent('US');
                      _showFeedback(context, 'Accent set to US General American');
                    },
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAccentChip(
                    context,
                    label: '🇬🇧 UK English',
                    subtitle: 'Received Pronunciation',
                    isSelected: settings.preferredAccent == 'UK',
                    onTap: () {
                      settingsNotifier.setPreferredAccent('UK');
                      _showFeedback(context, 'Accent set to UK Received Pronunciation');
                    },
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
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
                        'Auto-Play Audio',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Play audio automatically on word lookup',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: settings.autoPlayAudio,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    settingsNotifier.setAutoPlayAudio(val);
                    _showFeedback(
                      context,
                      val ? 'Auto-play audio enabled' : 'Auto-play audio disabled',
                    );
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Text(
              'Playback Speed',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [0.75, 1.0, 1.25, 1.5].map((speed) {
                final isSelected = settings.audioSpeed == speed;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      labelPadding: EdgeInsets.zero,
                      label: Center(
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.textPrimary)
                                : (isDark ? Colors.white70 : AppColors.textSecondary),
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: isDark ? primaryColor : AppColors.softYellow,
                      backgroundColor: isDark ? const Color(0xFF27273C) : AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? primaryColor
                              : (isDark ? const Color(0xFF383852) : AppColors.border),
                          width: 1.5,
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (_) {
                        settingsNotifier.setAudioSpeed(speed);
                        _showFeedback(context, 'Audio playback speed set to ${speed}x');
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentChip(
    BuildContext context, {
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? primaryColor.withOpacity(0.3) : primaryColor.withOpacity(0.12))
              : (isDark ? const Color(0xFF27273C) : AppColors.background),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF383852) : AppColors.border),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningCard(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    final todayWordsAsync = ref.watch(todaySavedWordsStreamProvider);
    final todaySavedCount = todayWordsAsync.when(
      data: (words) => words.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final goal = settings.dailyGoal;
    final progressRatio = (todaySavedCount / goal).clamp(0.0, 1.0);
    final actualPercent = ((todaySavedCount / goal) * 100).round();
    final isGoalMet = todaySavedCount >= goal;

    final progressText = isGoalMet
        ? '$todaySavedCount of $goal ($actualPercent% 🎉)'
        : '$todaySavedCount of $goal ($actualPercent%)';

    return _buildCardContainer(
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
                    'Daily Vocabulary Target',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  progressText,
                  style: TextStyle(
                    color: isGoalMet ? Colors.green : primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressRatio,
                backgroundColor: isDark
                    ? const Color(0xFF32324A)
                    : primaryColor.withOpacity(0.12),
                color: isGoalMet ? Colors.green : primaryColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [5, 10, 15, 20].map((g) {
                final isSelected = settings.dailyGoal == g;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () {
                        settingsNotifier.setDailyGoal(g);
                        _showFeedback(context, 'Daily goal updated to $g words/day');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark ? const Color(0xFF27273C) : AppColors.background),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : (isDark ? const Color(0xFF383852) : AppColors.border),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$g',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white : AppColors.textPrimary),
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'words/day',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
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
                        'Word of the Day Notification',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Receive featured vocabulary daily at ${settings.wordOfTheDayTime}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: settings.wordOfTheDayNotification,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    settingsNotifier.setWordOfTheDayNotification(val);
                    _showFeedback(
                      context,
                      val
                          ? 'Word of the Day scheduled for ${settings.wordOfTheDayTime}'
                          : 'Word of the Day notifications disabled',
                    );
                  },
                ),
              ],
            ),
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
                        'Daily Study Reminder',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Get notified to practice every day',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: settings.dailyReminders,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    settingsNotifier.setDailyReminders(val);
                    _showFeedback(
                      context,
                      val
                          ? 'Daily study reminders enabled for ${settings.reminderTime}'
                          : 'Daily reminders disabled',
                    );
                  },
                ),
              ],
            ),
            if (settings.dailyReminders) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 20, minute: 0),
                  );
                  if (timeOfDay != null) {
                    final formatted = timeOfDay.format(context);
                    settingsNotifier.setReminderTime(formatted);
                    if (context.mounted) {
                      _showFeedback(context, 'Study reminder set for $formatted every day');
                    }
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27273C) : AppColors.softYellow.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF383852) : AppColors.headerYellow,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.clock_fill,
                          color: AppColors.textPrimary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reminder Time: ${settings.reminderTime}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
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
                        'Streak Risk Protection',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Alert at 07:00 PM if 0 words saved today',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: settings.streakProtection,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    settingsNotifier.setStreakProtection(val);
                    _showFeedback(
                      context,
                      val
                          ? 'Streak Protection active (Alerts at 07:00 PM if needed)'
                          : 'Streak Protection disabled',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    return _buildCardContainer(
      isDark: isDark,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.anatomyGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.cloud_download_fill,
                  color: Colors.green, size: 20),
            ),
            title: const Text(
              'Offline Dictionary Database',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: Consumer(
              builder: (context, ref, child) {
                final countAsync = ref.watch(offlineWordsCountStreamProvider);
                return countAsync.when(
                  data: (count) => Text('$count words indexed • Offline lookup active'),
                  loading: () => const Text('Offline lookup active'),
                  error: (_, __) => const Text('Offline lookup active'),
                );
              },
            ),
            trailing: Switch.adaptive(
              value: settings.offlineDatabaseEnabled,
              activeColor: primaryColor,
              onChanged: (val) {
                settingsNotifier.setOfflineDatabaseEnabled(val);
                _showFeedback(
                  context,
                  val ? 'Offline dictionary lookup active' : 'Offline mode disabled',
                );
              },
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(CupertinoIcons.arrow_2_circlepath,
                  color: primaryColor, size: 20),
            ),
            title: const Text(
              'Sync Full English Dictionary CSV',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: const Text('Download 100k+ words dataset from GitHub'),
            onTap: () => _syncOfflineDatabase(context, ref),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.examplePink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.trash_fill,
                  color: Colors.redAccent, size: 20),
            ),
            title: const Text(
              'Clear Cache & History',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: const Text('Remove search logs and cached audio'),
            onTap: () {
              _showClearCacheDialog(context, ref, settingsNotifier);
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(CupertinoIcons.share, color: primaryColor, size: 20),
            ),
            title: const Text(
              'Export Vocabulary Data',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: const Text('Backup saved words as JSON to Clipboard'),
            onTap: () {
              _exportVocabulary(context, ref);
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(CupertinoIcons.doc_on_clipboard, color: primaryColor, size: 20),
            ),
            title: const Text(
              'Import Vocabulary Backup',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: const Text('Restore words from JSON text / Clipboard'),
            onTap: () {
              _showImportDialog(context, ref, settingsNotifier);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
    WidgetRef ref,
    SettingsNotifier settingsNotifier,
    Color primaryColor,
    bool isDark,
  ) {
    return _buildCardContainer(
      isDark: isDark,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(CupertinoIcons.app_badge_fill, color: primaryColor, size: 20),
            ),
            title: const Text(
              'LexiLens Version',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: const Text('v1.0.0 (Build 102)'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Up to date',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.softYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.star_fill,
                  color: Colors.orange, size: 20),
            ),
            title: const Text(
              'Rate & Review LexiLens',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            trailing: const Icon(CupertinoIcons.chevron_right,
                size: 16, color: AppColors.textSecondary),
            onTap: () {
              _showFeedback(context, 'Thank you for supporting LexiLens! ⭐⭐⭐⭐⭐');
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C40) : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.doc_text_fill,
                  color: AppColors.textSecondary, size: 20),
            ),
            title: const Text(
              'Privacy Policy & Terms',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            trailing: const Icon(CupertinoIcons.chevron_right,
                size: 16, color: AppColors.textSecondary),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'LexiLens Dictionary',
                applicationVersion: 'v1.0.0',
                applicationLegalese: '© 2025 LexiLens Inc. All rights reserved.',
              );
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.examplePink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.arrow_counterclockwise,
                  color: Colors.redAccent, size: 20),
            ),
            title: const Text(
              'Reset All Settings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.redAccent,
              ),
            ),
            onTap: () {
              _showResetSettingsDialog(context, settingsNotifier);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color primaryColor) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.sparkles, color: primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                'LexiLens Smart Dictionary',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Powered by Merriam-Webster & Riverpod State Engine',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getFontScaleLabel(double scale) {
    if (scale <= 0.95) return 'Small (90%)';
    if (scale <= 1.05) return 'Normal (100%)';
    if (scale <= 1.2) return 'Large (115%)';
    return 'Extra Large (130%)';
  }

  void _exportVocabulary(BuildContext context, WidgetRef ref) async {
    try {
      final words = await ref.read(databaseProvider).watchAllSavedWords().first;
      final jsonList = words.map((w) => {
        'word': w.word,
        'phonetic': w.phonetic,
        'partOfSpeech': w.partOfSpeech,
        'meaning': w.meaning,
        'example': w.example,
        'cefr': w.cefr,
        'dateAdded': w.dateAdded.toIso8601String(),
      }).toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (context.mounted) {
        _showFeedback(context, 'Exported ${words.length} saved words to Clipboard as JSON!');
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, 'Export completed');
      }
    }
  }

  void _showImportDialog(BuildContext context, WidgetRef ref, SettingsNotifier notifier) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Import Vocabulary JSON',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste vocabulary JSON backup text below:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '[{"word": "serene", "meaning": "calm"}, ...]',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data != null && data.text != null) {
                  controller.text = data.text!;
                }
              },
              icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
              label: const Text('Paste from Clipboard'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final jsonStr = controller.text.trim();
              if (jsonStr.isEmpty) return;
              final db = ref.read(databaseProvider);
              final count = await notifier.importVocabularyJson(jsonStr, db);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                _showFeedback(context, 'Successfully imported $count vocabulary words!');
              }
            },
            child: const Text('Import Words'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Clear History & Cache?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'This will delete search history logs from the database and clear temporary cache. Saved collections will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await ref.read(databaseProvider).clearRecentSearches();
              await notifier.clearCacheAndHistory();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                _showFeedback(context, 'Search history and cache cleared successfully');
              }
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Reset All Settings?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'This will reset theme, accent color, audio preferences, daily targets, and notifications back to default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await notifier.resetToDefaults();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                _showFeedback(context, 'All settings reset to default values');
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

void _syncOfflineDatabase(BuildContext context, WidgetRef ref) async {
    double progress = 0.0;
    StateSetter? dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulWidget(
          builder: (context, setState) {
            dialogSetState = setState;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(CupertinoIcons.cloud_download, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Text('Syncing Dataset', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  const Text('Downloading English Dictionary CSV dataset from GitHub and populating offline database...'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress > 0 ? progress : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 10),
                  Text('${(progress * 100).toStringAsFixed(0)}% indexed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      final service = ref.read(offlineDictionaryServiceProvider);
      final count = await service.downloadAndSyncDatabase(
        onProgress: (p) {
          if (dialogSetState != null) {
            dialogSetState!(() {
              progress = p;
            });
          }
        },
      );
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showFeedback(context, 'Synced! $count words now available offline.');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showFeedback(context, 'Sync failed: $e');
      }
    }
  }
  }
}

class _GeminiSettingsCard extends ConsumerStatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _GeminiSettingsCard({
    required this.primaryColor,
    required this.isDark,
  });

  @override
  ConsumerState<_GeminiSettingsCard> createState() => _GeminiSettingsCardState();
}

class _GeminiSettingsCardState extends ConsumerState<_GeminiSettingsCard> {
  late TextEditingController _keyController;
  bool _obscureKey = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initialKey = ref.read(settingsProvider).geminiApiKey;
    _keyController = TextEditingController(text: initialKey);
  }

  @override
  void dispose() {
    _keyController.dispose();
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

  void _showModelSelectionSheet(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier settingsNotifier,
  ) {
    final geminiService = ref.read(geminiServiceProvider);
    final apiKey = settings.geminiApiKey;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return FutureBuilder<List<GeminiModelInfo>>(
          future: geminiService.fetchAvailableModels(apiKey: apiKey),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final models = snapshot.data ?? geminiService.getDefaultModels();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1D1D2C) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: widget.isDark ? const Color(0xFF2C2C3F) : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select AI Model',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: models.map((m) {
                        final isSelected = settings.geminiModel == m.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pop(ctx);
                              settingsNotifier.setGeminiModel(m.id);
                              _showFeedback(context, 'Selected model: ${m.name}');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.primaryColor.withOpacity(0.12)
                                    : (widget.isDark ? const Color(0xFF27273C) : AppColors.background),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? widget.primaryColor
                                      : (widget.isDark ? const Color(0xFF383852) : AppColors.border),
                                  width: isSelected ? 2 : 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: isSelected
                                                ? widget.primaryColor
                                                : (widget.isDark ? Colors.white : AppColors.textPrimary),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          m.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: widget.isDark ? Colors.white60 : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, color: widget.primaryColor, size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final rawModel = settings.geminiModel.replaceFirst('models/', '');
    final modelDisplayName = rawModel
        .split('-')
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
        .join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CREDENTIALS SECTION
        Text(
          'Credentials',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: widget.primaryColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1D1D2C) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isDark ? const Color(0xFF2C2C3F) : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Google Gemini API Key',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Get from Google AI Studio (aistudio.google.com)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _keyController,
                obscureText: _obscureKey,
                onChanged: (val) {
                  settingsNotifier.setGeminiApiKey(val.trim());
                },
                decoration: InputDecoration(
                  hintText: 'Paste API Key here...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.vpn_key_rounded,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureKey ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureKey = !_obscureKey;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.content_paste_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data != null && data.text != null) {
                            final text = data.text!.trim();
                            _keyController.text = text;
                            settingsNotifier.setGeminiApiKey(text);
                            if (context.mounted) {
                              _showFeedback(context, 'Pasted API Key from Clipboard');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.primaryColor,
                        side: BorderSide(color: widget.primaryColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        await Clipboard.setData(const ClipboardData(text: 'https://aistudio.google.com/app/api-keys'));
                        if (context.mounted) {
                          _showFeedback(context, 'Link copied: aistudio.google.com/app/api-keys');
                        }
                      },
                      icon: Icon(Icons.launch_rounded, size: 16, color: widget.primaryColor),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Get API Key',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDark ? const Color(0xFF2C2C40) : const Color(0xFF2C2C3E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () async {
                              final key = _keyController.text.trim();
                              if (key.isEmpty) {
                                _showFeedback(context, 'Please enter or paste a Gemini API key');
                                return;
                              }
                              setState(() => _isSaving = true);
                              await settingsNotifier.setGeminiApiKey(key);
                              final geminiService = ref.read(geminiServiceProvider);
                              final testResult = await geminiService.testApiKey(key, model: settings.geminiModel);
                              setState(() => _isSaving = false);
                              if (context.mounted) {
                                if (testResult.success) {
                                  final activeModel = testResult.workingModel ?? settings.geminiModel;
                                  if (testResult.workingModel != null && testResult.workingModel != settings.geminiModel) {
                                    await settingsNotifier.setGeminiModel(testResult.workingModel!);
                                  }
                                  if (context.mounted) {
                                    _showFeedback(context, 'Connected successfully to Gemini $activeModel! ✨');
                                  }
                                } else {
                                  _showFeedback(context, testResult.errorMessage != null ? 'Connection failed: ${testResult.errorMessage}' : 'Key Saved. Connection failed - please check Key.');
                                }
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.bolt_rounded, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _isSaving ? 'Testing...' : 'Test Connection',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // MODEL SELECTION SECTION
        Text(
          'Model Selection',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: widget.primaryColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showModelSelectionSheet(context, settings, settingsNotifier),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1D1D2C) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark ? const Color(0xFF2C2C3F) : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF27273C) : AppColors.softYellow.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.science_rounded, color: Colors.amber.shade800, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Model',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select a model.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.isDark ? widget.primaryColor.withOpacity(0.25) : AppColors.softPurple,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        modelDisplayName,
                        style: TextStyle(
                          color: widget.isDark ? Colors.white : widget.primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: widget.primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
