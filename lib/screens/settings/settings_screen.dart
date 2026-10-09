import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/n8n_config.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_accents.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  int _calculateStreak(List<SavedWord> words) {
    if (words.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Set<DateTime> activeDates = {};

    for (final w in words) {
      activeDates.add(DateTime(w.dateAdded.year, w.dateAdded.month, w.dateAdded.day));
    }

    int streak = 0;
    DateTime checkDate = today;
    if (!activeDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (activeDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final activeAccentName = AppAccent.fromColor(settings.accentColor).name;

    final aiStatus = settings.geminiAiEnabled
        ? (settings.geminiApiKey.isNotEmpty ? 'Active' : 'Key Needed')
        : 'Off';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, primaryColor, isDark),
                    const SizedBox(height: 20),
                    _buildStatsHeroCard(context, ref, primaryColor, isDark, settings.dailyGoal),
                    const SizedBox(height: 24),

                    // SECTION 1: PERSONALIZATION
                    _buildSectionHeader(context, 'PERSONALIZATION', isDark),
                    const SizedBox(height: 8),
                    _buildGroupedCardContainer(
                      context: context,
                      isDark: isDark,
                      items: [
                        _buildSectionItem(
                          context,
                          icon: CupertinoIcons.paintbrush,
                          title: 'Appearance & Theme',
                          subtitle: '7 theme variants, accent colors & typography',
                          badgeText: activeAccentName,
                          onTap: () => context.push('/settings/appearance'),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                        _buildSectionItem(
                          context,
                          icon: CupertinoIcons.speaker_2,
                          title: 'Audio & Pronunciation',
                          subtitle: 'US/UK pronunciation & playback speed',
                          badgeText: '${settings.preferredAccent} • ${settings.audioSpeed}x',
                          onTap: () => context.push('/settings/audio'),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SECTION 2: GOALS & SYSTEM
                    _buildSectionHeader(context, 'GOALS & SYSTEM', isDark),
                    const SizedBox(height: 8),
                    _buildGroupedCardContainer(
                      context: context,
                      isDark: isDark,
                      items: [
                        _buildSectionItem(
                          context,
                          icon: CupertinoIcons.flame,
                          title: 'Learning & Goals',
                          subtitle: 'Daily target, notifications & streak protection',
                          badgeText: '${settings.dailyGoal} words/day',
                          onTap: () => context.push('/settings/goals'),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                        _buildSectionItem(
                          context,
                          icon: CupertinoIcons.sparkles,
                          title: 'Gemini AI Engine',
                          subtitle: 'Smart meanings, etymology & assistant',
                          badgeText: aiStatus,
                          trailing: Switch.adaptive(
                            value: settings.geminiAiEnabled,
                            activeColor: primaryColor,
                            onChanged: (val) {
                              settingsNotifier.setGeminiAiEnabled(val);
                            },
                          ),
                          onTap: () => context.push('/settings/gemini'),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                        _buildSectionItem(
                          context,
                          icon: CupertinoIcons.tray_full,
                          title: 'Storage & Offline DB',
                          subtitle: 'Offline dictionary, cache & JSON backup',
                          badgeText: settings.offlineDatabaseEnabled ? '12.4 MB Offline' : 'Online Only',
                          trailing: Switch.adaptive(
                            value: settings.offlineDatabaseEnabled,
                            activeColor: primaryColor,
                            onChanged: (val) {
                              settingsNotifier.setOfflineDatabaseEnabled(val);
                            },
                          ),
                          onTap: () => context.push('/settings/storage'),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                        _buildSectionItem(
                          context,
                          icon: CupertinoIcons.arrow_2_squarepath,
                          title: 'n8n Workflow Automation',
                          subtitle: 'Environment: ${N8nConfig.environment}',
                          badgeText: N8nConfig.environment.toUpperCase(),
                          onTap: () => context.push('/settings/storage'),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SECTION 3: INFORMATION & ABOUT
                    _buildSectionHeader(context, 'INFORMATION & ABOUT', isDark),
                    const SizedBox(height: 8),
                    _buildGroupedCardContainer(
                      context: context,
                      isDark: isDark,
                      items: [
                        _buildSectionItem(
                          context,
                          icon: CupertinoIcons.info_circle,
                          title: 'About, Terms & Privacy',
                          subtitle: 'Version info, open source licenses & reset',
                          badgeText: 'v2.3.1',
                          onTap: () => context.push('/settings/about'),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),
                    _buildFooter(context, primaryColor, isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.4,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          'Customize your Dictionary preferences',
          style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 13,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatsHeroCard(
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
        ? '0%'
        : '${((masteredCount / savedWordsCount) * 100).round()}%';

    final savedWordsList = savedWordsAsync.asData?.value ?? [];
    final streakDays = _calculateStreak(savedWordsList);
    final goalProgressRatio = dailyGoal > 0 ? (todaySavedCount / dailyGoal).clamp(0.0, 1.0) : 0.0;

    final tileBg = isDark ? AppColors.darkTileBg : const Color(0xFFF7F7F9);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/stats'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: AppTheme.borderWidth(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chart_bar_square,
                    color: primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning Overview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Today\'s Goal: $todaySavedCount / $dailyGoal words',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Analytics',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(CupertinoIcons.chevron_right, size: 11, color: primaryColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goalProgressRatio,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white12 : AppColors.border.withOpacity(0.6),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Streak',
                    value: '$streakDays Days 🔥',
                    icon: CupertinoIcons.flame,
                    iconColor: primaryColor,
                    bgColor: tileBg,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Saved',
                    value: '$savedWordsCount Words',
                    icon: CupertinoIcons.book,
                    iconColor: primaryColor,
                    bgColor: tileBg,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Accuracy',
                    value: masteryRate,
                    icon: CupertinoIcons.star,
                    iconColor: primaryColor,
                    bgColor: tileBg,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedCardContainer({
    required BuildContext context,
    required bool isDark,
    required List<Widget> items,
  }) {
    final radius = AppTheme.cardRadius(context);
    final strokeWidth = AppTheme.borderWidth(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: strokeWidth,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 52,
                endIndent: 16,
                color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.6),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Widget? trailing,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF0F0F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trailing != null)
              trailing
            else
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: isDark ? Colors.white38 : AppColors.textSecondary.withOpacity(0.7),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color primaryColor, bool isDark) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.sparkles, color: primaryColor, size: 15),
              const SizedBox(width: 6),
              Text(
                'Dictionary',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Version 2.3.1 • Created by PARKER (Batch H1)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
