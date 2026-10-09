import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import 'legal_terms_screen.dart';

class AboutSettingsScreen extends ConsumerWidget {
  const AboutSettingsScreen({super.key});

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

  void _showResetSettingsDialog(
      BuildContext context, SettingsNotifier notifier) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: const Text(
          'About App',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner / Header
              _buildAppHeroBanner(context, primaryColor, isDark),
              const SizedBox(height: 24),

              // SECTION 1: APPLICATION DETAILS
              _buildSectionHeader(context, 'APPLICATION DETAILS', isDark),
              const SizedBox(height: 8),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Column(
                  children: [
                    // Creator
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveSoftPurple(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                      title: const Text(
                        'Creator',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        'PARKER',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'PARKER',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.border.withOpacity(0.6),
                    ),

                    // Version
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveSoftBlue(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          CupertinoIcons.app_badge_fill,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                      title: const Text(
                        'Version',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        '2.3.1',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveSoftGreen(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.checkmark_seal_fill,
                              color: Colors.green,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'v2.3.1',
                              style: TextStyle(
                                color: isDark ? AppColors.darkSoftGreenText : Colors.green.shade800,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.border.withOpacity(0.6),
                    ),

                    // Batch No
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveSoftYellow(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          CupertinoIcons.number_square_fill,
                          color: Colors.orange,
                          size: 22,
                        ),
                      ),
                      title: const Text(
                        'Batch Number',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        'H1',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Batch H1',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 2: SUPPORT & LEGAL
              _buildSectionHeader(context, 'SUPPORT & LEGAL', isDark),
              const SizedBox(height: 8),
              _buildCardContainer(
                context: context,
                isDark: isDark,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveSoftYellow(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          CupertinoIcons.star_fill,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Rate & Review Dictionary',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      trailing: const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () {
                        _showFeedback(
                          context,
                          'Thank you for supporting Dictionary! ⭐⭐⭐⭐⭐',
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.border.withOpacity(0.6),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C40)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_text_fill,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Privacy Policy & Terms',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      trailing: const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const LegalTermsScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 20,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.border.withOpacity(0.6),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.adaptiveSoftPink(context),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_counterclockwise,
                          color: Colors.redAccent,
                          size: 20,
                        ),
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
              ),

              const SizedBox(height: 36),

              // Footer
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.sparkles,
                          color: primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dictionary',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created by PARKER • Batch H1',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Version 2.3.1',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark.withOpacity(0.7)
                            : AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeroBanner(
      BuildContext context, Color primaryColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppTheme.borderWidth(context),
        ),
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF332A1C) : const Color(0xFFFAF0E4),
            ),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD97706),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.book_fill,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dictionary App',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart Vocabulary & AI Assistant',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildBadgeChip(
                context,
                label: 'v2.3.1',
                color: primaryColor,
                isDark: isDark,
              ),
              _buildBadgeChip(
                context,
                label: 'Batch H1',
                color: Colors.orange,
                isDark: isDark,
              ),
              _buildBadgeChip(
                context,
                label: 'PARKER',
                color: Colors.teal,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(BuildContext context,
      {required String label, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
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

  Widget _buildCardContainer(
      {required BuildContext context,
      required Widget child,
      required bool isDark}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: AppTheme.borderWidth(context),
        ),
      ),
      child: child,
    );
  }
}
