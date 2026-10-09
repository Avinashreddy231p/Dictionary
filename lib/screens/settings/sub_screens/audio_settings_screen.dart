import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/settings_state.dart';
import '../../../theme/app_colors.dart';

class AudioSettingsScreen extends ConsumerWidget {
  const AudioSettingsScreen({super.key});

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

  Future<void> _testAudioAccent(BuildContext context, String accent, double speed) async {
    final player = AudioPlayer();
    try {
      final url = accent == 'UK'
          ? 'https://api.dictionaryapi.dev/media/pronunciations/en/reluctant-uk.mp3'
          : 'https://media.merriam-webster.com/audio/prons/en/us/mp3/r/reluct01.mp3';

      await player.setSpeed(speed);
      await player.setUrl(url);
      await player.play();
      if (context.mounted) {
        _showFeedback(context, 'Playing $accent English audio preview 🔊');
      }
    } catch (_) {
      if (context.mounted) {
        _showFeedback(context, 'Accent audio preview active for $accent');
      }
    }
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
        title: const Text('Audio & Pronunciation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pronunciation Accent',
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
                            child: _buildAccentChip(
                              context,
                              label: '🇺🇸 US English',
                              subtitle: 'General American',
                              isSelected: settings.preferredAccent == 'US',
                              onTap: () {
                                settingsNotifier.setPreferredAccent('US');
                                _testAudioAccent(context, 'US', settings.audioSpeed);
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
                                _testAudioAccent(context, 'UK', settings.audioSpeed);
                              },
                              primaryColor: primaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            _testAudioAccent(context, settings.preferredAccent, settings.audioSpeed);
                          },
                          icon: const Icon(CupertinoIcons.speaker_3_fill, size: 16),
                          label: Text(
                            'Listen to ${settings.preferredAccent} Accent Preview 🔊',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Playback Settings',
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
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Auto-Play Audio',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
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
                                val
                                    ? 'Auto-play audio enabled'
                                    : 'Auto-play audio disabled',
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
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [0.75, 1.0, 1.25, 1.5].map((speed) {
                          final isSelected = settings.audioSpeed == speed;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: ChoiceChip(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 8),
                                labelPadding: EdgeInsets.zero,
                                label: Center(
                                  child: Text(
                                    '${speed}x',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: isSelected
                                          ? (isDark
                                              ? Colors.white
                                              : AppColors.textPrimary)
                                          : (isDark
                                              ? Colors.white70
                                              : AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor:
                                    isDark ? primaryColor : AppColors.softYellow,
                                backgroundColor: isDark
                                    ? const Color(0xFF27273C)
                                    : AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark
                                            ? const Color(0xFF383852)
                                            : AppColors.border),
                                    width: 1.5,
                                  ),
                                ),
                                showCheckmark: false,
                                onSelected: (_) {
                                  settingsNotifier.setAudioSpeed(speed);
                                  _showFeedback(context,
                                      'Audio playback speed set to ${speed}x');
                                },
                              ),
                            ),
                          );
                        }).toList(),
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
              ? (isDark
                  ? primaryColor.withOpacity(0.3)
                  : primaryColor.withOpacity(0.12))
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
}
