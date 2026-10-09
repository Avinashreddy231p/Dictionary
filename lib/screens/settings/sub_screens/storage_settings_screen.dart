import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../data/models/settings_state.dart';
import '../../../data/services/export_service.dart';
import '../../../data/services/file_import_service.dart';
import '../../../theme/app_colors.dart';

class StorageSettingsScreen extends ConsumerWidget {
  const StorageSettingsScreen({super.key});

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

  void _exportVocabulary(BuildContext context, WidgetRef ref) async {
    try {
      final words = await ref.read(databaseProvider).watchAllSavedWords().first;
      if (words.isEmpty) {
        if (context.mounted) {
          _showFeedback(context, 'No saved vocabulary words to export');
        }
        return;
      }

      final jsonString = ExportService.exportToFullJson(words);
      if (context.mounted) {
        await ExportService.exportAndShareFile(
          context: context,
          filename: 'Dictionary_Backup.json',
          content: jsonString,
          successMessage: 'Exported ${words.length} saved words to backup file',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, 'Export failed: $e');
      }
    }
  }

  void _showImportDialog(
      BuildContext context, WidgetRef ref, SettingsNotifier notifier) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Import Vocabulary Backup',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pick a backup file (.json / .csv) or paste text below:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '[{"word": "serene", "meaning": "calm"}, ...]\nor\nword;partOfSpeech;phonetic;meaning',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final fileResult = await FileImportService.pickAndReadBackupFile();
                      if (fileResult != null && fileResult.content.isNotEmpty) {
                        controller.text = fileResult.content;
                      }
                    },
                    icon: const Icon(CupertinoIcons.folder_badge_plus, size: 18),
                    label: const Text('Pick File'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null && data.text != null) {
                        controller.text = data.text!;
                      }
                    },
                    icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
                    label: const Text('Clipboard'),
                  ),
                ),
              ],
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
              final rawInput = controller.text.trim();
              if (rawInput.isEmpty) return;
              final db = ref.read(databaseProvider);

              int count = 0;
              if (rawInput.startsWith('[')) {
                count = await notifier.importVocabularyJson(rawInput, db);
              } else {
                count = await notifier.importVocabularyCsv(rawInput, db);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                _showFeedback(
                    context, 'Successfully imported $count vocabulary words!');
              }
            },
            child: const Text('Import Words'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(
      BuildContext context, WidgetRef ref, SettingsNotifier notifier) {
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
                _showFeedback(
                    context, 'Search history and cache cleared successfully');
              }
            },
            child: const Text('Clear Cache'),
          ),
        ],
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Storage & Data'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data & Backup Management',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(
                isDark: isDark,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                      subtitle:
                          const Text('12.4 MB downloaded • Offline lookup active'),
                      trailing: Switch.adaptive(
                        value: settings.offlineDatabaseEnabled,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          settingsNotifier.setOfflineDatabaseEnabled(val);
                          _showFeedback(
                            context,
                            val
                                ? 'Offline dictionary lookup active'
                                : 'Offline mode disabled',
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(CupertinoIcons.share,
                            color: primaryColor, size: 20),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(CupertinoIcons.doc_on_clipboard,
                            color: primaryColor, size: 20),
                      ),
                      title: const Text(
                        'Import Vocabulary Backup',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      subtitle:
                          const Text('Restore words from JSON text / Clipboard'),
                      onTap: () {
                        _showImportDialog(context, ref, settingsNotifier);
                      },
                    ),
                  ],
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
