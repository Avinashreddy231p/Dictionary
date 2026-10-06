import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/settings_provider.dart';
import '../../data/models/settings_state.dart';
import '../../theme/app_accents.dart';
import '../../theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
                    _buildProfileCard(context, primaryColor, isDark),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      icon: CupertinoIcons.paintbrush_fill,
                      title: 'Appearance & Accent Color',
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
                    _buildAboutCard(context, settingsNotifier, primaryColor, isDark),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Customize your LexiLens experience',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
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

  Widget _buildProfileCard(BuildContext context, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232338) : AppColors.softYellow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF3B3B54) : AppColors.headerYellow,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'LL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LexiLens Learner',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.badgeTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '14 Day Streak',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.orangeAccent : Colors.deepOrange,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Icon(CupertinoIcons.book_fill, color: primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '128 Words Saved',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
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
                    onTap: () => settingsNotifier.setThemeMode(ThemeMode.system),
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
                    onTap: () => settingsNotifier.setThemeMode(ThemeMode.light),
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
                    onTap: () => settingsNotifier.setThemeMode(ThemeMode.dark),
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
                  onTap: () => settingsNotifier.setAccentColor(accent.primary),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Text Scaling',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
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
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
                    onTap: () => settingsNotifier.setPreferredAccent('US'),
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
                    onTap: () => settingsNotifier.setPreferredAccent('UK'),
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
                  onChanged: (val) => settingsNotifier.setAutoPlayAudio(val),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('${speed}x'),
                      selected: isSelected,
                      selectedColor: isDark ? primaryColor : AppColors.softYellow,
                      backgroundColor: isDark ? const Color(0xFF27273C) : AppColors.background,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.textPrimary)
                            : (isDark ? Colors.white70 : AppColors.textSecondary),
                      ),
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
                      onSelected: (_) => settingsNotifier.setAudioSpeed(speed),
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
        padding: const EdgeInsets.all(14),
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
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningCard(
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
              'Daily Vocabulary Target',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [5, 10, 15, 20].map((goal) {
                final isSelected = settings.dailyGoal == goal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => settingsNotifier.setDailyGoal(goal),
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
                                : (isDark ? const Color(0xFF383852) : AppColors.border),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$goal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              'words/day',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white70
                                    : AppColors.textSecondary,
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
                  onChanged: (val) => settingsNotifier.setDailyReminders(val),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.clock_fill,
                              color: AppColors.textPrimary, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Reminder Time: ${settings.reminderTime}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
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
                        'Alert when your streak is about to reset',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: settings.streakProtection,
                  activeColor: primaryColor,
                  onChanged: (val) => settingsNotifier.setStreakProtection(val),
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
            subtitle: const Text('12.4 MB downloaded • Offline lookup active'),
            trailing: Switch.adaptive(
              value: settings.offlineDatabaseEnabled,
              activeColor: primaryColor,
              onChanged: (val) => settingsNotifier.setOfflineDatabaseEnabled(val),
            ),
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
              _showClearCacheDialog(context, settingsNotifier);
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
            subtitle: const Text('Backup saved words as JSON'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exported 128 saved words to LexiLens_Backup.json'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for supporting LexiLens! ⭐⭐⭐⭐⭐'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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

  void _showClearCacheDialog(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Clear History & Cache?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'This will delete cached search results and temporary audio files. Saved collections will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await notifier.clearCacheAndHistory();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache and search history cleared successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to default values'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
