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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, primaryColor, isDark),
                    const SizedBox(height: 20),
                    _buildStatsCard(context, ref, primaryColor, isDark, settings.dailyGoal),
                    const SizedBox(height: 28),
                    Text(
                      'Personalization & Intelligence',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationCard(
                      context,
                      icon: CupertinoIcons.sparkles,
                      iconBgColor: primaryColor.withOpacity(0.15),
                      iconColor: primaryColor,
                      title: 'AI Assistant & Gemini Engine',
                      subtitle: 'API key, AI models, language & features',
                      badgeText: aiStatus,
                      route: '/settings/gemini',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationCard(
                      context,
                      icon: CupertinoIcons.paintbrush_fill,
                      iconBgColor: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
                      iconColor: isDark ? AppColors.darkSoftYellowText : Colors.orange.shade800,
                      title: 'Appearance & Theme',
                      subtitle: 'Pantone accents, fonts, shapes & textures',
                      badgeText: activeAccentName,
                      route: '/settings/appearance',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationCard(
                      context,
                      icon: CupertinoIcons.speaker_2_fill,
                      iconBgColor: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
                      iconColor: primaryColor,
                      title: 'Audio & Pronunciation',
                      subtitle: 'US/UK accent, audio speed & preview tests',
                      badgeText: '${settings.preferredAccent} • ${settings.audioSpeed}x',
                      route: '/settings/audio',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'System & Data Management',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationCard(
                      context,
                      icon: CupertinoIcons.flame_fill,
                      iconBgColor: isDark ? AppColors.darkSoftGreen : AppColors.softGreen,
                      iconColor: Colors.green,
                      title: 'Learning & Goals',
                      subtitle: 'Daily targets, reminders & streak protection',
                      badgeText: '${settings.dailyGoal} words/day',
                      route: '/settings/goals',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationCard(
                      context,
                      icon: CupertinoIcons.arrow_2_squarepath,
                      iconBgColor: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
                      iconColor: primaryColor,
                      title: 'n8n Workflow Automation',
                      subtitle: 'Environment: ${N8nConfig.environment}',
                      badgeText: N8nConfig.environment.toUpperCase(),
                      route: '/settings/storage',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationCard(
                      context,
                      icon: CupertinoIcons.tray_full_fill,
                      iconBgColor: isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
                      iconColor: primaryColor,
                      title: 'Storage & Data Management',
                      subtitle: 'Offline database, cache & backup JSON',
                      badgeText: settings.offlineDatabaseEnabled ? '12.4 MB Offline' : 'Online Only',
                      route: '/settings/storage',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationCard(
                      context,
                      icon: CupertinoIcons.info_circle_fill,
                      title: 'About & Support',
                      subtitle: 'App version, privacy policy & reset defaults',
                      badgeText: 'v1.0.0',
                      route: '/settings/about',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 36),
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

  Widget _buildHeader(BuildContext context, Color primaryColor, bool isDark) {
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
                'Customize your Dictionary experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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

    final savedWordsList = savedWordsAsync.asData?.value ?? [];
    final streakDays = _calculateStreak(savedWordsList);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/stats'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: AppTheme.borderWidth(context),
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
                    value: '$streakDays Days 🔥',
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

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    Color? iconBgColor,
    Color? iconColor,
    required String title,
    required String subtitle,
    String? badgeText,
    required String route,
    required bool isDark,
    required Color primaryColor,
  }) {
    final cardRadius = AppTheme.cardRadius(context);
    final strokeWidth = AppTheme.borderWidth(context);

    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(cardRadius),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
            width: strokeWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor ?? primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
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
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
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
                          fontSize: 12,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ],
        ),
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
            'Powered by Merriam-Webster & Riverpod State Engine',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
