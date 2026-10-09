import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/settings_state.dart';
import '../../../theme/app_colors.dart';

class GoalsSettingsScreen extends ConsumerWidget {
  const GoalsSettingsScreen({super.key});

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Learning & Goals'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Vocabulary Goal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(
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
                              'Target Words per Day',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: InkWell(
                                onTap: () {
                                  settingsNotifier.setDailyGoal(g);
                                  _showFeedback(context,
                                      'Daily goal updated to $g words/day');
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark
                                            ? const Color(0xFF27273C)
                                            : AppColors.background),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : (isDark
                                              ? const Color(0xFF383852)
                                              : AppColors.border),
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
                                                : (isDark
                                                    ? Colors.white
                                                    : AppColors.textPrimary),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Notifications & Reminders',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Word of the Day Notification',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
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
                              initialTime:
                                  const TimeOfDay(hour: 20, minute: 0),
                            );
                            if (timeOfDay != null) {
                              final formatted = timeOfDay.format(context);
                              settingsNotifier.setReminderTime(formatted);
                              if (context.mounted) {
                                _showFeedback(context,
                                    'Study reminder set for $formatted every day');
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF27273C)
                                  : AppColors.softYellow.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF383852)
                                    : AppColors.headerYellow,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
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
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
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
}
