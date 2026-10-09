import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers.dart';
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

  void _showBackupSelectionSheet(BuildContext context, WidgetRef ref, SettingsNotifier notifier) {
    bool includeSettings = true;
    bool includeVocabulary = true;
    bool includeCollections = true;
    bool includeHistory = true;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF181826) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Create App Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Select the modules you want to include in this backup file:'),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232338) : const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Theme, UI options, AI Keys'),
                            value: includeSettings,
                            activeColor: primaryColor,
                            onChanged: (val) => setSheetState(() => includeSettings = val!),
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            title: const Text('Vocabulary', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Saved words, definitions, notes, XP'),
                            value: includeVocabulary,
                            activeColor: primaryColor,
                            onChanged: (val) => setSheetState(() => includeVocabulary = val!),
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            title: const Text('Collections', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Custom folders and word links'),
                            value: includeCollections,
                            activeColor: primaryColor,
                            onChanged: (val) => setSheetState(() => includeCollections = val!),
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            title: const Text('Search History', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Recent dictionary searches'),
                            value: includeHistory,
                            activeColor: primaryColor,
                            onChanged: (val) => setSheetState(() => includeHistory = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx); // close selection sheet
                          _executeFullBackup(
                            context, 
                            ref, 
                            notifier,
                            BackupConfig(
                              includeSettings: includeSettings,
                              includeVocabulary: includeVocabulary,
                              includeCollections: includeCollections,
                              includeHistory: includeHistory,
                            ),
                          );
                        },
                        icon: const Icon(CupertinoIcons.cloud_upload_fill),
                        label: const Text('Generate Backup File', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
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

  void _executeFullBackup(BuildContext context, WidgetRef ref, SettingsNotifier notifier, BackupConfig config) {
    _showProgressSheet(
      context: context, 
      title: 'Creating Backup...', 
      onExecute: (updateProgress) async {
        final db = ref.read(databaseProvider);
        final jsonStr = await notifier.exportCustomBackup(
          config: config, 
          db: db,
          onProgress: updateProgress,
        );
        
        if (context.mounted) {
          updateProgress(1.0, 'Saving File...');
          await ExportService.exportAndShareFile(
            context: context,
            filename: 'Dictionary_FullAppBackup.json',
            content: jsonStr,
            successMessage: 'Backup generated successfully!',
          );
        }
      },
    );
  }

  void _showRestoreSelectionSheet(BuildContext context, WidgetRef ref, SettingsNotifier notifier, Map<String, dynamic> payload, String payloadStr) {
    final hasSettings = payload.containsKey('preferences');
    final hasWords = payload.containsKey('savedWords');
    final hasCollections = payload.containsKey('collections');
    final hasHistory = payload.containsKey('recentSearches');

    bool restoreSettings = hasSettings;
    RestoreStrategy wordStrategy = hasWords ? RestoreStrategy.mergeSkip : RestoreStrategy.mergeSkip;
    RestoreStrategy collectionStrategy = hasCollections ? RestoreStrategy.mergeSkip : RestoreStrategy.mergeSkip;
    RestoreStrategy historyStrategy = hasHistory ? RestoreStrategy.mergeSkip : RestoreStrategy.mergeSkip;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF181826) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Restore App Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Select what to restore and how to handle conflicts:'),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232338) : const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          if (hasSettings) ...[
                            CheckboxListTile(
                              title: const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: const Text('Restore theme, AI Keys, etc.'),
                              value: restoreSettings,
                              activeColor: primaryColor,
                              onChanged: (val) => setSheetState(() => restoreSettings = val!),
                            ),
                            const Divider(height: 1),
                          ],
                          
                          if (hasWords) ...[
                            _buildStrategyTile(
                              context: context,
                              title: 'Vocabulary',
                              subtitle: 'Saved words and stats',
                              currentStrategy: wordStrategy,
                              onStrategyChanged: (val) => setSheetState(() => wordStrategy = val),
                            ),
                            const Divider(height: 1),
                          ],
                          
                          if (hasCollections) ...[
                            _buildStrategyTile(
                              context: context,
                              title: 'Collections',
                              subtitle: 'Custom folders',
                              currentStrategy: collectionStrategy,
                              onStrategyChanged: (val) => setSheetState(() => collectionStrategy = val),
                            ),
                            const Divider(height: 1),
                          ],
                          
                          if (hasHistory) ...[
                            _buildStrategyTile(
                              context: context,
                              title: 'Search History',
                              subtitle: 'Recent dictionary searches',
                              currentStrategy: historyStrategy,
                              onStrategyChanged: (val) => setSheetState(() => historyStrategy = val),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _executeFullRestore(
                            context, 
                            ref, 
                            notifier, 
                            payloadStr,
                            RestoreConfig(
                              restoreSettings: restoreSettings,
                              wordStrategy: wordStrategy,
                              collectionStrategy: collectionStrategy,
                              historyStrategy: historyStrategy,
                            ),
                          );
                        },
                        icon: const Icon(CupertinoIcons.exclamationmark_triangle_fill),
                        label: const Text('Start Restore', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
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

  Widget _buildStrategyTile({
    required BuildContext context, 
    required String title, 
    required String subtitle, 
    required RestoreStrategy currentStrategy,
    required ValueChanged<RestoreStrategy> onStrategyChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RestoreStrategy>(
                  value: currentStrategy,
                  isExpanded: true,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                  items: const [
                    DropdownMenuItem(value: RestoreStrategy.mergeSkip, child: Text('Merge (Skip)')),
                    DropdownMenuItem(value: RestoreStrategy.mergeUpdate, child: Text('Merge (Update)')),
                    DropdownMenuItem(value: RestoreStrategy.replaceAll, child: Text('Replace All')),
                  ],
                  onChanged: (val) {
                     if (val != null) onStrategyChanged(val);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _executeFullRestore(BuildContext context, WidgetRef ref, SettingsNotifier notifier, String jsonStr, RestoreConfig config) {
    _showProgressSheet(
      context: context, 
      title: 'Restoring Backup...', 
      onExecute: (updateProgress) async {
        final db = ref.read(databaseProvider);
        final success = await notifier.restoreCustomBackup(
          jsonStr: jsonStr, 
          config: config, 
          db: db,
          onProgress: updateProgress,
        );
        
        if (context.mounted) {
          _showFeedback(context, success ? 'Restore completed successfully!' : 'Restore failed.');
        }
      },
    );
  }

  void _showProgressSheet({
    required BuildContext context,
    required String title,
    required Future<void> Function(void Function(double progress, String status) updateProgress) onExecute,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    double currentProgress = 0.05;
    String currentStatus = 'Initializing...';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF181826) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (currentProgress == 0.05) {
                await onExecute((progress, status) {
                  if (ctx.mounted) {
                    setSheetState(() {
                      currentProgress = progress;
                      currentStatus = status;
                    });
                  }
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            });

            final pct = (currentProgress * 100).toInt().clamp(0, 100);

            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: currentProgress,
                      minHeight: 10,
                      backgroundColor: isDark ? Colors.white12 : AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('$pct% • $currentStatus', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref, SettingsNotifier notifier) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Import Vocabulary Backup', style: TextStyle(fontWeight: FontWeight.w800)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                        
                        // Auto-detect Full App Backup
                        if (fileResult.content.trim().startsWith('{') && fileResult.content.contains('"version"')) {
                           if (ctx.mounted) {
                              Navigator.pop(ctx); // Close standard import dialog
                              try {
                                final payload = jsonDecode(fileResult.content) as Map<String, dynamic>;
                                _showRestoreSelectionSheet(context, ref, notifier, payload, fileResult.content);
                              } catch (_) {
                                _showFeedback(context, 'Invalid Backup File format.');
                              }
                           }
                           return;
                        }
                      }
                    },
                    icon: const Icon(CupertinoIcons.folder_badge_plus, size: 18),
                    label: const Text('Pick File'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data != null && data.text != null) controller.text = data.text!;
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
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(CupertinoIcons.cloud_upload_fill,
                            color: primaryColor, size: 20),
                      ),
                      title: const Text(
                        'Create Full App Backup',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      subtitle: const Text('Export settings, collections & vocabulary'),
                      onTap: () {
                        _showBackupSelectionSheet(context, ref, settingsNotifier);
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
                        child: Icon(CupertinoIcons.arrow_down_doc_fill,
                            color: primaryColor, size: 20),
                      ),
                      title: const Text(
                        'Restore App Backup',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      subtitle:
                          const Text('Restore from a backup JSON/CSV file'),
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
