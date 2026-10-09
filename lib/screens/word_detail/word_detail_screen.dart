import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/utils/pos_helper.dart';
import '../../core/utils/url_helper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_accents.dart';
import '../../theme/background_patterns.dart';
import '../../data/models/lexical_entry.dart';
import 'widgets/pronunciation_practice_widget.dart';

String _capitalize(String? input) {
  if (input == null) return '';
  final trimmed = input.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.length == 1) return trimmed.toUpperCase();
  return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
}

class WordDetailScreen extends ConsumerStatefulWidget {
  final LexicalEntry? entry;
  final String? initialWord;

  const WordDetailScreen({super.key, this.entry, this.initialWord});

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _noteController = TextEditingController();

  LexicalEntry? _fetchedEntry;
  bool _isLoadingWord = false;

  LexicalEntry? get _activeEntry => widget.entry ?? _fetchedEntry;

  bool _isPlaying = false;
  double _audioSpeed = 1.0;

  // Recall / Quiz Mode State
  final bool _isRecallMode = false;
  bool _isMeaningRevealed = false;

  // Datamuse Data
  List<String> _fetchedSynonyms = [];
  List<String> _fetchedAntonyms = [];
  List<String> _fetchedPairings = [];
  bool _isFetchingSynonyms = false;

  // Gemini AI State
  int _aiTab = 0;
  bool _isAiStreaming = false;
  StreamSubscription<String>? _aiStreamSubscription;
  String? _aiMnemonicResult;
  String? _aiNuanceResult;
  String? _aiExamplesResult;
  String? _aiCustomResult;
  String? _activeCustomPromptType;
  String? _aiErrorMsg;

  @override
  void initState() {
    super.initState();
    _logWordVisited();
    _loadExtraWordData();
  }

  @override
  void didUpdateWidget(covariant WordDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != widget.entry || oldWidget.initialWord != widget.initialWord) {
      _logWordVisited();
      _loadExtraWordData();
    }
  }

  void _logWordVisited() {
    final word = widget.entry?.core.headword ?? widget.initialWord;
    if (word != null && word.trim().isNotEmpty) {
      ref.read(databaseProvider).addRecentSearch(word.trim().toLowerCase());
    }
  }

  @override
  void dispose() {
    _aiStreamSubscription?.cancel();
    _audioPlayer.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadExtraWordData() async {
    if (widget.entry == null && widget.initialWord != null && widget.initialWord!.isNotEmpty) {
      setState(() => _isLoadingWord = true);
      try {
        final repo = ref.read(wordRepositoryProvider);
        final results = await repo.searchWord(widget.initialWord!);
        if (results.isNotEmpty) {
          setState(() {
            _fetchedEntry = results.first;
          });
        }
      } catch (_) {}
      if (mounted) setState(() => _isLoadingWord = false);
    }

    final active = _activeEntry;
    if (active == null) return;
    final word = active.core.headword.toLowerCase();
    if (word.isEmpty) return;

    final existingSyns = active.dictionaryLayer.synonyms;
    final existingAnts = active.dictionaryLayer.antonyms;

    if (existingSyns.isNotEmpty || existingAnts.isNotEmpty) {
      setState(() {
        _fetchedSynonyms = existingSyns;
        _fetchedAntonyms = existingAnts;
      });
    }

    setState(() => _isFetchingSynonyms = true);

    try {
      // 1. Datamuse Synonyms
      if (_fetchedSynonyms.isEmpty) {
        final synRes = await http.get(Uri.parse('https://api.datamuse.com/words?rel_syn=$word'));
        if (synRes.statusCode == 200) {
          final data = json.decode(synRes.body) as List;
          _fetchedSynonyms = data.take(8).map((e) => e['word'].toString()).toList();
        }
      }

      // 2. Datamuse Antonyms
      if (_fetchedAntonyms.isEmpty) {
        final antRes = await http.get(Uri.parse('https://api.datamuse.com/words?rel_ant=$word'));
        if (antRes.statusCode == 200) {
          final data = json.decode(antRes.body) as List;
          _fetchedAntonyms = data.take(5).map((e) => e['word'].toString()).toList();
        }
      }

      // 3. Datamuse Collocations / Word Pairings
      final pairRes = await http.get(Uri.parse('https://api.datamuse.com/words?rel_jja=$word'));
      List<String> pairs = [];
      if (pairRes.statusCode == 200) {
        final data = json.decode(pairRes.body) as List;
        pairs.addAll(data.take(4).map((e) => '$word ${e['word']}'));
      }
      if (pairs.length < 3) {
        final pairRes2 = await http.get(Uri.parse('https://api.datamuse.com/words?rel_jjb=$word'));
        if (pairRes2.statusCode == 200) {
          final data = json.decode(pairRes2.body) as List;
          pairs.addAll(data.take(4).map((e) => '${e['word']} $word'));
        }
      }

      if (mounted) {
        setState(() {
          _fetchedPairings = pairs.toSet().toList();
          _isFetchingSynonyms = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingSynonyms = false);
    }
  }

  void _playAudio(String url, {LexicalEntry? entry}) async {
    if (_isPlaying) return;

    final settings = ref.read(settingsProvider);
    String targetUrl = url;

    if (entry != null) {
      final accent = settings.preferredAccent;
      final primaryUrl = accent == 'UK' ? entry.core.ukAudioUrl : entry.core.audioUrl;
      final fallbackUrl = accent == 'UK' ? entry.core.audioUrl : entry.core.ukAudioUrl;
      targetUrl = primaryUrl.isNotEmpty ? primaryUrl : fallbackUrl;
    }

    if (targetUrl.isEmpty) return;

    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.setSpeed(settings.audioSpeed);
      await _audioPlayer.setUrl(targetUrl);
      await _audioPlayer.play();
    } catch (_) {
      if (entry != null) {
        final fallback = settings.preferredAccent == 'UK' ? entry.core.audioUrl : entry.core.ukAudioUrl;
        if (fallback.isNotEmpty && fallback != targetUrl) {
          try {
            await _audioPlayer.setUrl(fallback);
            await _audioPlayer.play();
          } catch (_) {}
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  void _toggleAudioSpeed() {
    setState(() {
      _audioSpeed = (_audioSpeed == 1.0) ? 0.75 : 1.0;
    });
    HapticFeedback.selectionClick();
  }

  void _navigateToWord(BuildContext context, String targetWord) async {
    final cleanWord = targetWord.trim().toLowerCase();
    if (cleanWord.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPurple),
      ),
    );

    try {
      final repo = ref.read(wordRepositoryProvider);
      final results = await repo.searchWord(cleanWord);

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        if (results.isNotEmpty) {
          context.push('/home/search/detail', extra: results.first);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No dictionary entry found for "$cleanWord"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading "$cleanWord": $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleSaveWord(BuildContext context, WidgetRef ref) async {
    final entry = _activeEntry;
    if (entry == null) return;

    try {
      final db = ref.read(databaseProvider);
      final word = entry.core.headword.toLowerCase();
      final saved = await db.getSavedWordByWord(word);

      if (saved != null) {
        if (!mounted) return;
        _showCollectionsSheet(context, ref, saved);
      } else {
        final example = entry.senses.isNotEmpty && entry.senses.first.examples.isNotEmpty
            ? entry.senses.first.examples.first
            : null;

        await db.saveWord(
          word: entry.core.headword,
          phonetic: entry.core.phonetic,
          partOfSpeech: entry.core.partOfSpeech,
          meaning: entry.dictionaryLayer.simpleMeaning,
          example: example,
          syllables: entry.core.syllables.join('*'),
          cefr: 'B2',
        );

        final newSaved = await db.getSavedWordByWord(word);
        if (newSaved != null && mounted) {
          _showCollectionsSheet(context, ref, newSaved);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "${entry.core.headword}" to your vocabulary!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save word: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatShareCaption(LexicalEntry entry) {
    final phonetic = entry.core.phonetic.isNotEmpty ? ' (${entry.core.phonetic})' : '';
    final pos = entry.core.partOfSpeech.isNotEmpty ? '\n${entry.core.partOfSpeech}' : '';
    return '${entry.core.headword.toUpperCase()}$phonetic$pos\n\nMeaning: ${entry.dictionaryLayer.simpleMeaning}';
  }

  Future<void> _shareCardImage(
    BuildContext context,
    GlobalKey cardBoundaryKey,
    LexicalEntry entry,
  ) async {
    final shareCaption = _formatShareCaption(entry);

    try {
      final boundary = cardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        await SharePlus.instance.share(shareCaption, subject: 'Word Card: ${entry.core.headword}');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${entry.core.headword.toLowerCase()}_card.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        [XFile(filePath)],
        text: shareCaption,
        subject: 'Word Card: ${entry.core.headword}',
      );
    } catch (e) {
      debugPrint('Error sharing card image: $e');
      await SharePlus.instance.share(shareCaption, subject: 'Word Card: ${entry.core.headword}');
    }
  }

  void _showShareSheet(BuildContext context) {
    final entry = _activeEntry;
    if (entry == null) return;
    final cardBoundaryKey = GlobalKey();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        final settings = ref.watch(settingsProvider);
        final accent = AppAccent.fromColor(settings.accentColor);
        final cardBgColor = accent.adaptiveSoft(context);
        final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        final subTextColor = isDark ? accent.darkSoftText : AppColors.textPrimary;
        final brandColor = isDark ? accent.darkSoftText : accent.primary;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share Word Card',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textDisabled),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Styled Card Preview wrapped in RepaintBoundary for high-res PNG image capture
              RepaintBoundary(
                key: cardBoundaryKey,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? accent.primary.withValues(alpha: 0.3) : accent.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.25) : accent.primary.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.core.headword.toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Dictionary',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: brandColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.core.phonetic} • ${formatPartOfSpeech(entry.core.partOfSpeech)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '"${entry.dictionaryLayer.simpleMeaning}"',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: theme.primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _formatShareCaption(entry)));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Word card summary copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(CupertinoIcons.doc_on_doc, color: theme.primaryColor, size: 18),
                      label: Text('Copy', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _shareCardImage(context, cardBoundaryKey, entry);
                      },
                      icon: const Icon(CupertinoIcons.share, size: 18),
                      label: const Text('Share Card', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateNewCollectionDialog(BuildContext context, WidgetRef ref, AppDatabase db, SavedWord savedWord) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final tagsController = TextEditingController();

    String selectedColor = '0xFFFFF0B3'; // Default soft yellow
    String selectedIcon = 'book';

    final iconOptions = [
      {'name': 'book', 'icon': CupertinoIcons.book_fill},
      {'name': 'bookmark', 'icon': CupertinoIcons.bookmark_fill},
      {'name': 'star', 'icon': CupertinoIcons.star_fill},
      {'name': 'flame', 'icon': CupertinoIcons.flame_fill},
      {'name': 'lightbulb', 'icon': CupertinoIcons.lightbulb_fill},
      {'name': 'heart', 'icon': CupertinoIcons.heart_fill},
      {'name': 'folder', 'icon': CupertinoIcons.folder_fill},
    ];

    final colorOptions = [
      '0xFFFFF0B3', // Soft Yellow
      '0xFFD1FAE5', // Soft Green
      '0xFFFFEDD5', // Soft Orange
      '0xFFD6E6FF', // Soft Blue
      '0xFFFFF0F5', // Soft Cream/Pink
      '0xFFFFE4E6', // Soft Coral
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF181826) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final keyboardHeight = MediaQuery.of(ctx).viewInsets.bottom;
            final previewColor = Color(int.parse(selectedColor));
            final previewIconData = iconOptions.firstWhere(
              (opt) => opt['name'] == selectedIcon,
              orElse: () => iconOptions.first,
            )['icon'] as IconData;

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: keyboardHeight + 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create New Collection',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(CupertinoIcons.xmark_circle_fill, color: isDark ? Colors.white54 : AppColors.textDisabled),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Live Card Preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: previewColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(previewIconData, color: AppColors.textPrimary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleController.text.trim().isNotEmpty
                                      ? titleController.text.trim()
                                      : 'Collection Title',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  descController.text.trim().isNotEmpty
                                      ? descController.text.trim()
                                      : 'Description preview',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Collection Name Field
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      onChanged: (_) => setBottomSheetState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Collection Name',
                        hintText: 'e.g. Science Terminology',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    TextField(
                      controller: descController,
                      onChanged: (_) => setBottomSheetState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'e.g. Terms from biology chapter 4',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags Field
                    TextField(
                      controller: tagsController,
                      onChanged: (_) => setBottomSheetState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Tags (comma separated)',
                        hintText: 'e.g. Exam, IELTS, Classic',
                        prefixIcon: const Icon(CupertinoIcons.tag_fill, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Icon Selector
                    Text('Choose Icon:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: iconOptions.map((opt) {
                          final name = opt['name'] as String;
                          final icon = opt['icon'] as IconData;
                          final isSelected = selectedIcon == name;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setBottomSheetState(() {
                                  selectedIcon = name;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 44,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.primaryColor : theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? theme.primaryColor : AppColors.cardBorder(context),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 20,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Color Selector
                    Text('Accent Color:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: colorOptions.map((cHex) {
                        final isSelected = selectedColor == cHex;
                        final color = Color(int.parse(cHex));
                        return GestureDetector(
                          onTap: () {
                            setBottomSheetState(() {
                              selectedColor = cHex;
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: AppColors.textPrimary, width: 3)
                                  : Border.all(color: AppColors.border, width: 1),
                            ),
                            child: isSelected
                                ? const Icon(CupertinoIcons.check_mark, size: 16, color: AppColors.textPrimary)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isNotEmpty) {
                            Navigator.pop(ctx);
                            final tags = tagsController.text.trim();

                            final newColId = await db.createCollection(
                              title: title,
                              description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                              colorHex: selectedColor,
                              iconName: selectedIcon,
                              tags: tags.isNotEmpty ? tags : null,
                            );

                            await db.addWordToCollection(newColId, savedWord.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Created "$title" & added "${savedWord.word}"!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Create & Add',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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

  void _showCollectionsSheet(BuildContext context, WidgetRef ref, SavedWord savedWord) {
    final db = ref.read(databaseProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF181826) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final userColsAsync = ref.watch(userCollectionsStreamProvider);
            final wordColIdsAsync = ref.watch(collectionIdsForWordStreamProvider(savedWord.id));

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Collections for "${savedWord.word}"',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textDisabled),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select collections for this word:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          _showCreateNewCollectionDialog(context, ref, db, savedWord);
                        },
                        icon: const Icon(CupertinoIcons.add, size: 14),
                        label: const Text('New Collection', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  userColsAsync.when(
                    data: (cols) {
                      final assignedIds = wordColIdsAsync.value ?? [];

                      if (cols.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No custom collections created yet.', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () {
                                  _showCreateNewCollectionDialog(context, ref, db, savedWord);
                                },
                                icon: const Icon(CupertinoIcons.add, size: 16),
                                label: const Text('Create First Collection'),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: cols.map((col) {
                          final isAssigned = assignedIds.contains(col.id);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(col.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            value: isAssigned,
                            activeColor: AppColors.textPrimary,
                            onChanged: (val) async {
                              if (val == true) {
                                await db.addWordToCollection(col.id, savedWord.id);
                              } else {
                                await db.removeWordFromCollection(col.id, savedWord.id);
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error loading collections: $e'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await db.removeSavedWord(savedWord.word);
                          },
                          icon: const Icon(CupertinoIcons.trash, size: 18),
                          label: const Text('Remove Word'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = _activeEntry;
    if (entry == null) {
      if (_isLoadingWord) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Word Detail')),
        body: const Center(child: Text('Word not found.')),
      );
    }
    final theme = Theme.of(context);

    final word = entry.core.headword;
    final isSavedAsync = ref.watch(isWordSavedStreamProvider(word.toLowerCase()));
    final isSaved = isSavedAsync.value ?? false;
    final settings = ref.watch(settingsProvider);

    // Watch saved word for notes
    final savedWordAsync = ref.watch(savedWordStreamProvider(word.toLowerCase()));
    final savedWord = savedWordAsync.value;

    final allExamples = entry.senses.expand((s) => s.examples).toList();

    int cardIndex = 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BackgroundTextureWidget(
        texture: settings.bgTexture,
        opacity: settings.bgTextureOpacity,
        child: SafeArea(
          child: Column(
            children: [
              // 1. FLOATING APP BAR
              _buildTopBar(context, ref, isSaved, entry),

              // 2. SCROLLABLE CONTENT WITH STAGGERED FLUID ENTRANCE ANIMATIONS
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 8),

                    // HEADER CARD WITH NESTED SIMPLE MEANING HERO CARD
                    _FluidAnimatedCard(
                      index: cardIndex++,
                      child: _SafeCard(builder: () => _buildHeaderAndSimpleMeaning(context, entry)),
                    ),
                    const SizedBox(height: 20),

                    // Mastery Progress Card (if saved)
                    if (isSaved) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildMasteryCard(context, ref, word)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Context Card
                    _FluidAnimatedCard(
                      index: cardIndex++,
                      child: _SafeCard(builder: () => _buildContextCard(context, word)),
                    ),
                    const SizedBox(height: 16),

                    if (allExamples.isNotEmpty) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildExampleCard(context, allExamples)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (entry.core.syllables.length > 1) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildAnatomyCard(context)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Pronunciation Practice & Voice Comparator
                    _FluidAnimatedCard(
                      index: cardIndex++,
                      child: _SafeCard(
                        builder: () => PronunciationPracticeWidget(
                          headword: word,
                          phonetic: entry.core.phonetic,
                          audioUrl: entry.core.audioUrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Personal Reader Notes (if saved)
                    if (isSaved && savedWord != null) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildPersonalNoteCard(context, savedWord)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Gemini AI Assistant Card
                    _FluidAnimatedCard(
                      index: cardIndex++,
                      child: _SafeCard(builder: () => _buildGeminiAiCard(context, ref, entry)),
                    ),
                    const SizedBox(height: 16),

                    // Rich Dictionary Data
                    if (entry.senses.isNotEmpty) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildFullDefinitionsCard(context, entry.senses)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_fetchedPairings.isNotEmpty) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildPairingsCard(context)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (entry.grammar.verbDivision.isNotEmpty ||
                        entry.grammar.usageNotes.isNotEmpty) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildUsageGrammarCard(context)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (entry.grammar.inflections.isNotEmpty || entry.grammar.relatedForms.isNotEmpty) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildWordFamilyCard(context)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Synonyms & Antonyms
                    _FluidAnimatedCard(
                      index: cardIndex++,
                      child: _SafeCard(builder: () => _buildRelationshipsCard(context)),
                    ),
                    const SizedBox(height: 16),

                    if (entry.linguistic.etymology.isNotEmpty) ...[
                      _FluidAnimatedCard(
                        index: cardIndex++,
                        child: _SafeCard(builder: () => _buildEtymologyCard(context, entry.linguistic)),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Bottom Action
                    _FluidAnimatedCard(
                      index: cardIndex++,
                      child: _SafeCard(builder: () => _buildSavedButton(context, ref, isSaved)),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // FLOATING APP BAR
  Widget _buildTopBar(BuildContext context, WidgetRef ref, bool isSaved, LexicalEntry entry) {
    final theme = Theme.of(context);
    final word = entry.core.headword;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BouncyTouch(
            onTap: () {
              if (context.canPop()) context.pop();
            },
            child: _buildFloatingIconButton(
              context,
              icon: CupertinoIcons.arrow_left,
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
          Row(
            children: [
              _BouncyTouch(
                onTap: () => launchGoogleDefinition(word),
                child: _buildFloatingIconButton(
                  context,
                  icon: CupertinoIcons.globe,
                  iconColor: theme.primaryColor,
                  onPressed: () => launchGoogleDefinition(word),
                ),
              ),
              const SizedBox(width: 10),
              _BouncyTouch(
                onTap: () => _toggleSaveWord(context, ref),
                child: _buildFloatingIconButton(
                  context,
                  icon: isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                  iconColor: isSaved ? Colors.green : null,
                  onPressed: () => _toggleSaveWord(context, ref),
                ),
              ),
              const SizedBox(width: 10),
              _BouncyTouch(
                onTap: () => _showShareSheet(context),
                child: _buildFloatingIconButton(
                  context,
                  icon: CupertinoIcons.ellipsis_vertical,
                  onPressed: () => _showShareSheet(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // FLOATING CIRCULAR PILL BUTTON
  Widget _buildFloatingIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed, Color? iconColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white : AppColors.textPrimary),
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }

  // ACCENT HEADER CARD WITH NESTED SIMPLE MEANING HERO CARD
  Widget _buildHeaderAndSimpleMeaning(BuildContext context, LexicalEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final word = entry.core.headword;
    final phonetic = entry.core.phonetic;
    final pos = formatPartOfSpeech(entry.core.partOfSpeech);
    final simpleMeaning = entry.dictionaryLayer.simpleMeaning;

    final settings = ref.watch(settingsProvider);
    final accent = AppAccent.fromColor(settings.accentColor);

    final blobColor = accent.adaptiveSoft(context);
    final headerTextColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextColor = isDark ? accent.darkSoftText : AppColors.textPrimary;

    final capMeaning = _capitalize(simpleMeaning);
    final formattedMeaning = capMeaning.isNotEmpty
        ? (capMeaning + (capMeaning.endsWith('.') ? '' : '.'))
        : 'Vocabulary term';

    return GestureDetector(
      onTap: () {
        _playAudio(entry.core.audioUrl, entry: entry);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: blobColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark 
                ? accent.primary.withValues(alpha: 0.3) 
                : accent.primary.withValues(alpha: 0.2), 
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.25) 
                  : accent.primary.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            // Word Title
            Text(
              word.toUpperCase(),
              softWrap: true,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: word.length > 14 ? 26 : (word.length > 10 ? 30 : 36),
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: headerTextColor,
                height: 1.1,
              ),
            ),
            if (phonetic.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        phonetic,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: subTextColor,
                          fontSize: 18,
                        ),
                      ),
                      // Audio Speaker Button
                      _BouncyTouch(
                        onTap: () => _playAudio(entry.core.audioUrl, entry: entry),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isPlaying 
                                ? accent.primary 
                                : (isDark ? AppColors.darkTileBg : Colors.white.withValues(alpha: 0.75)),
                            shape: BoxShape.circle,
                            boxShadow: _isPlaying
                                ? [
                                    BoxShadow(
                                      color: accent.primary.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: _isPlaying
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(
                                  CupertinoIcons.speaker_2_fill, 
                                  size: 16, 
                                  color: _isPlaying ? Colors.white : subTextColor
                                ),
                        ),
                      ),
                      // Audio Speed Pill
                      _BouncyTouch(
                        onTap: _toggleAudioSpeed,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _audioSpeed == 0.75
                                ? accent.primary
                                : (isDark ? AppColors.darkTileBg : Colors.white.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_audioSpeed}x',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _audioSpeed == 0.75 ? Colors.white : subTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // B2 Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkTileBg : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : accent.primary.withValues(alpha: 0.25), 
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'B2',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? accent.darkSoftText : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (pos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                pos,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: subTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // SIMPLE MEANING HERO CARD
            _buildOverlappingSimpleMeaningCard(context, formattedMeaning),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => launchGoogleDefinition(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTileBg : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : accent.primary.withValues(alpha: 0.25), 
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.globe, size: 14, color: subTextColor),
                    const SizedBox(width: 6),
                    Text(
                      'Google Definition',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(CupertinoIcons.arrow_up_right, size: 12, color: subTextColor.withValues(alpha: 0.7)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SIMPLE MEANING HERO CARD WITH FLUID RECALL REVEAL ANIMATION
  Widget _buildOverlappingSimpleMeaningCard(BuildContext context, String meaning) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final accent = AppAccent.fromColor(settings.accentColor);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInQuad,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: (_isRecallMode && !_isMeaningRevealed)
          ? _BouncyTouch(
              key: const ValueKey('recall_active'),
              onTap: () {
                setState(() => _isMeaningRevealed = true);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTileBg : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.primary, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.eye_slash_fill, size: 20, color: accent.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECALL MODE ACTIVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: accent.primary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to reveal answer 👁️',
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container(
              key: const ValueKey('meaning_revealed'),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTileBg : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: isDark
                    ? Border.all(color: AppColors.darkBorder, width: 1.5)
                    : Border.all(color: accent.primary.withValues(alpha: 0.2), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circle with Lightbulb
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? accent.primary.withValues(alpha: 0.25) 
                          : accent.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.lightbulb,
                      size: 20,
                      color: isDark ? accent.darkSoftText : accent.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Simple meaning',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? accent.darkSoftText.withValues(alpha: 0.85) : const Color(0xFF555566),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meaning,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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

  Widget _buildMasteryCard(BuildContext context, WidgetRef ref, String word) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final savedWordAsync = ref.watch(savedWordStreamProvider(word.toLowerCase()));

    return savedWordAsync.when(
      data: (savedWord) {
        if (savedWord == null) return const SizedBox.shrink();

        final states = ['Learning', 'Reviewing', 'Mastered'];
        final colors = [AppColors.softPeach, AppColors.softBlue, AppColors.softGreen];
        final darkColors = [AppColors.darkSoftPink, AppColors.darkSoftBlue, AppColors.darkSoftGreen];
        final darkTextColors = [AppColors.darkSoftPinkText, AppColors.darkSoftBlueText, AppColors.darkSoftGreenText];
        final icons = [CupertinoIcons.book, CupertinoIcons.arrow_2_circlepath, CupertinoIcons.star_fill];

        final stateIndex = savedWord.reviewState.clamp(0, 2);
        final bgColor = isDark ? darkColors[stateIndex] : colors[stateIndex];
        final textColor = isDark ? darkTextColors[stateIndex] : AppColors.textPrimary;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5) : Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icons[stateIndex], color: textColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Progress',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? textColor.withValues(alpha: 0.8) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      states[stateIndex],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              _BouncyTouch(
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  await db.updateReviewState(savedWord.id, (stateIndex + 1) % 3);
                },
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkTileBg : Colors.white,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    side: BorderSide(color: isDark ? textColor.withValues(alpha: 0.4) : AppColors.border),
                  ),
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    await db.updateReviewState(savedWord.id, (stateIndex + 1) % 3);
                  },
                  child: const Text('Update'),
                ),
              )
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildContextCard(BuildContext context, String word) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'In context',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  size: 16,
                  color: isDark ? Colors.white54 : AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
              children: [
                const TextSpan(text: 'He was '),
                TextSpan(
                  text: word.toLowerCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: theme.primaryColor,
                  ),
                ),
                const TextSpan(
                    text:
                        ' to enter the room, even though he knew it was important.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(BuildContext context, List<String> examples) {
    if (examples.isEmpty) return const SizedBox.shrink();
    final exampleText = examples.first.trim();
    if (exampleText.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final capExample = _capitalize(exampleText);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSoftPink : AppColors.examplePink,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkSoftPinkText.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Example',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkSoftPinkText
                      : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '"$capExample"',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkSoftPinkText.withValues(alpha: 0.9)
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  // SCROLLABLE "WORD ANATOMY" TO PREVENT COMPROMISING MULTI-SYLLABLE WORDS
  Widget _buildAnatomyCard(BuildContext context) {
    final entry = _activeEntry;
    if (entry == null || entry.core.syllables.length < 2) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final syllables = entry.core.syllables;

    final colors = isDark
        ? [AppColors.darkSoftGreen, AppColors.darkSoftBlue, AppColors.darkSoftPurple]
        : [AppColors.anatomyGreen, AppColors.anatomyBlue, AppColors.anatomyPurple];

    final textColors = isDark
        ? [
            AppColors.darkSoftGreenText,
            AppColors.darkSoftBlueText,
            AppColors.darkSoftPurpleText
          ]
        : [AppColors.textPrimary, AppColors.textPrimary, AppColors.textPrimary];

    List<Widget> anatomyWidgets = [];
    for (int i = 0; i < syllables.length; i++) {
      anatomyWidgets.add(
        _buildAnatomyBubble(
          context,
          syllables[i],
          colors[i % colors.length],
          textColors[i % textColors.length],
        ),
      );

      if (i < syllables.length - 1) {
        anatomyWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('+',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white70 : AppColors.textPrimary)),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word anatomy',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: anatomyWidgets,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnatomyBubble(
      BuildContext context, String root, Color color, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: isDark ? Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5) : null,
          ),
          child: Text(
            root,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
          ),
        ),
      ],
    );
  }

  // PERSONAL READER NOTE CARD
  Widget _buildPersonalNoteCard(BuildContext context, SavedWord savedWord) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_noteController.text.isEmpty && savedWord.personalNote != null) {
      _noteController.text = savedWord.personalNote!;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.pencil_ellipsis_rectangle, size: 20, color: AppColors.primaryPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Personal Note',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: Colors.green, size: 24),
                onPressed: () async {
                  final db = ref.read(databaseProvider);
                  await db.updatePersonalNote(savedWord.id, _noteController.text.trim());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Personal note saved!'), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add a personal memory or reading context...',
              filled: true,
              fillColor: isDark ? AppColors.darkTileBg : AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  // COMMON PAIRINGS / COLLOCATIONS CARD
  Widget _buildPairingsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Common Pairings',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fetchedPairings.map((pair) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pair,
                  style: TextStyle(
                    color: isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDefinitionsCard(
      BuildContext context, List<Sense> senses) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senses.length > 1 ? 'All Definitions' : 'Definition',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          ...senses.map((sense) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sense.senseNumber.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sense.senseNumber,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          sense.definition,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (sense.labels.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: sense.labels.map((lbl) => _buildMinimalTag(
                        context, 
                        lbl, 
                        bg: isDark ? AppColors.darkSoftPink : AppColors.softPeach, 
                        textColor: isDark ? AppColors.darkSoftPinkText : AppColors.textPrimary
                      )).toList(),
                    ),
                  ],
                  if (sense.examples.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ...sense.examples.map((ex) => Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        '"$ex"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    )),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUsageGrammarCard(BuildContext context) {
    final entry = _activeEntry;
    if (entry == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final grammar = entry.grammar;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage & Grammar',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (grammar.verbDivision.isNotEmpty)
                _buildMinimalTag(
                  context, grammar.verbDivision,
                  bg: isDark ? AppColors.darkSoftGreen : AppColors.softGreen,
                  textColor: isDark ? AppColors.darkSoftGreenText : AppColors.textPrimary
                ),
              ...grammar.usageNotes.map((note) => _buildMinimalTag(
                  context, note,
                  bg: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
                  textColor: isDark ? AppColors.darkSoftBlueText : AppColors.textPrimary
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTag(BuildContext context, String text,
      {required Color bg, required Color textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: textColor.withValues(alpha: 0.3)) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildWordFamilyCard(BuildContext context) {
    final entry = _activeEntry;
    if (entry == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final grammar = entry.grammar;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word Family & Related Forms',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (grammar.inflections.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Inflections: ${grammar.inflections.join('  ·  ')}',
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
            ),
          ],
          if (grammar.relatedForms.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Derived: ${grammar.relatedForms.join('  ·  ')}',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelationshipsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.sparkles, size: 18, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              Text('Synonyms & Antonyms',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          if (_isFetchingSynonyms)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPurple)
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Fetching related terms...',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, 
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else if (_fetchedSynonyms.isEmpty && _fetchedAntonyms.isEmpty)
            Text(
              'No synonyms or antonyms available for this word.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            )
          else ...[
            if (_fetchedSynonyms.isNotEmpty) ...[
              Text(
                'Synonyms',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _fetchedSynonyms.map((syn) {
                  return _BouncyTouch(
                    onTap: () => _navigateToWord(context, syn),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark ? Border.all(color: AppColors.darkSoftBlueText.withValues(alpha: 0.3)) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            syn,
                            style: TextStyle(
                              color: isDark ? AppColors.darkSoftBlueText : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.arrow_up_right,
                            size: 12,
                            color: isDark ? AppColors.darkSoftBlueText : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_fetchedAntonyms.isNotEmpty) const SizedBox(height: 16),
            ],
            if (_fetchedAntonyms.isNotEmpty) ...[
              Text(
                'Antonyms',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _fetchedAntonyms.map((ant) {
                  return _BouncyTouch(
                    onTap: () => _navigateToWord(context, ant),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSoftPink : AppColors.softPeach,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark ? Border.all(color: AppColors.darkSoftPinkText.withValues(alpha: 0.3)) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ant,
                            style: TextStyle(
                              color: isDark ? AppColors.darkSoftPinkText : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.arrow_up_right,
                            size: 12,
                            color: isDark ? AppColors.darkSoftPinkText : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEtymologyCard(BuildContext context, LinguisticData linguistic) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Extract root language names from the etymology string dynamically
    final languageRegex = RegExp(
      r'\b(Latin|Late Latin|Medieval Latin|Vulgar Latin|Greek|Anglo-French|Old French|French|Middle English|Old English|Germanic|Old Norse|Dutch|Arabic|Sanskrit|Italian|Spanish|Proto-Indo-European)\b',
      caseSensitive: false,
    );
    final matches = languageRegex.allMatches(linguistic.etymology);
    final languages = matches.map((m) => m.group(0)!).toSet().toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.time,
                        size: 20,
                        color: AppColors.primaryPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Etymology & Lineage',
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (linguistic.firstKnownUse.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.calendar,
                          size: 12,
                          color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Text(
                        linguistic.firstKnownUse,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          // Visual Historical Lineage Flow
          if (languages.isNotEmpty) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (int i = 0; i < languages.length; i++) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSoftPurple : AppColors.anatomyPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        languages[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (i < languages.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(CupertinoIcons.arrow_right, size: 14, color: AppColors.textDisabled),
                      ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(CupertinoIcons.arrow_right, size: 14, color: AppColors.textDisabled),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Modern English',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (linguistic.etymology.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTileBg : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                linguistic.etymology,
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _stopAiStream() {
    _aiStreamSubscription?.cancel();
    _aiStreamSubscription = null;
    if (mounted) {
      setState(() {
        _isAiStreaming = false;
      });
    }
  }

  void _startAiStream({
    required BuildContext context,
    required WidgetRef ref,
    required Stream<String> Function(String apiKey, String? model) streamBuilder,
    required void Function(String chunk, bool isFirst) onChunk,
  }) {
    final settings = ref.read(settingsProvider);
    final apiKey = settings.geminiApiKey;
    if (apiKey.isEmpty) {
      _showApiKeyPrompt(context);
      return;
    }

    _stopAiStream();

    setState(() {
      _isAiStreaming = true;
      _aiErrorMsg = null;
    });

    bool isFirst = true;

    try {
      final stream = streamBuilder(apiKey, settings.geminiModel);
      _aiStreamSubscription = stream.listen(
        (chunk) {
          if (mounted) {
            setState(() {
              onChunk(chunk, isFirst);
              isFirst = false;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              _aiErrorMsg = e.toString().replaceAll('Exception: ', '');
              _isAiStreaming = false;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isAiStreaming = false;
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiErrorMsg = e.toString().replaceAll('Exception: ', '');
          _isAiStreaming = false;
        });
      }
    }
  }

  void _triggerMnemonicStream(BuildContext context, WidgetRef ref, LexicalEntry entry) {
    _startAiStream(
      context: context,
      ref: ref,
      streamBuilder: (apiKey, model) => ref.read(geminiServiceProvider).streamMnemonic(
        entry.core.headword,
        entry.dictionaryLayer.simpleMeaning,
        apiKey: apiKey,
        model: model,
      ),
      onChunk: (chunk, isFirst) {
        if (isFirst) {
          _aiMnemonicResult = chunk;
        } else {
          _aiMnemonicResult = (_aiMnemonicResult ?? '') + chunk;
        }
      },
    );
  }

  void _triggerNuanceStream(BuildContext context, WidgetRef ref, LexicalEntry entry) {
    _startAiStream(
      context: context,
      ref: ref,
      streamBuilder: (apiKey, model) => ref.read(geminiServiceProvider).streamExplainNuance(
        entry.core.headword,
        entry.core.partOfSpeech,
        entry.dictionaryLayer.simpleMeaning,
        apiKey: apiKey,
        model: model,
      ),
      onChunk: (chunk, isFirst) {
        if (isFirst) {
          _aiNuanceResult = chunk;
        } else {
          _aiNuanceResult = (_aiNuanceResult ?? '') + chunk;
        }
      },
    );
  }

  void _triggerExamplesStream(BuildContext context, WidgetRef ref, LexicalEntry entry) {
    _startAiStream(
      context: context,
      ref: ref,
      streamBuilder: (apiKey, model) => ref.read(geminiServiceProvider).streamContextExamples(
        entry.core.headword,
        entry.core.partOfSpeech,
        apiKey: apiKey,
        model: model,
      ),
      onChunk: (chunk, isFirst) {
        if (isFirst) {
          _aiExamplesResult = chunk;
        } else {
          _aiExamplesResult = (_aiExamplesResult ?? '') + chunk;
        }
      },
    );
  }

  void _triggerCustomStream(BuildContext context, WidgetRef ref, LexicalEntry entry, String promptType) {
    _activeCustomPromptType = promptType;
    _startAiStream(
      context: context,
      ref: ref,
      streamBuilder: (apiKey, model) => ref.read(geminiServiceProvider).streamCustomPrompt(
        entry.core.headword,
        promptType,
        apiKey: apiKey,
        model: model,
      ),
      onChunk: (chunk, isFirst) {
        if (isFirst) {
          _aiCustomResult = chunk;
        } else {
          _aiCustomResult = (_aiCustomResult ?? '') + chunk;
        }
      },
    );
  }

  Widget _buildStreamingResultCard({
    required BuildContext context,
    required String? text,
    required Color bgColor,
    required Color textColor,
    required Color primaryColor,
    required bool isStreaming,
    required VoidCallback onStop,
    required VoidCallback onRegenerate,
  }) {
    final cleanText = (text ?? '').trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: cleanText,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              children: [
                if (isStreaming)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 8,
                      height: 14,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isStreaming) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: onStop,
                  icon: const Icon(CupertinoIcons.stop_fill, size: 12),
                  label: const Text('Stop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ] else if (cleanText.isNotEmpty) ...[
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(CupertinoIcons.doc_on_doc, size: 16),
                  tooltip: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: cleanText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(CupertinoIcons.refresh, size: 16),
                  tooltip: 'Regenerate',
                  onPressed: onRegenerate,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptChip(
    BuildContext context, {
    required String label,
    required String type,
    required LexicalEntry entry,
    required WidgetRef ref,
    required Color primaryColor,
    required bool isDark,
  }) {
    final isSelected = _activeCustomPromptType == type;
    return ActionChip(
      avatar: isSelected && _isAiStreaming
          ? SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
            )
          : null,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      backgroundColor: isSelected
          ? primaryColor.withValues(alpha: 0.15)
          : (isDark ? AppColors.darkTileBg : AppColors.softPurple.withValues(alpha: 0.3)),
      side: BorderSide(
        color: isSelected ? primaryColor : (isDark ? AppColors.darkBorder : AppColors.border),
      ),
      onPressed: _isAiStreaming ? null : () => _triggerCustomStream(context, ref, entry, type),
    );
  }

  Widget _buildGeminiAiCard(BuildContext context, WidgetRef ref, LexicalEntry entry) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    if (!settings.geminiAiEnabled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF3EDFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.sparkles, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Mnemonics & Deep Insights', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('Unlock AI Mnemonics, Shades of Meaning & Examples in Settings.', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textSecondary)),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/settings'),
              child: const Text('Unlock'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? primaryColor.withValues(alpha: 0.4) : primaryColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
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
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.sparkles, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gemini AI Assistant',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _isAiStreaming ? 'Live Streaming AI Response...' : 'Interactive Real-Time Insights',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isAiStreaming ? primaryColor : (isDark ? Colors.white54 : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isAiStreaming) ...[
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                    ],
                    const Text(
                      'Realtime AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAiTabPill(context, label: '💡 Mnemonic', index: 0, activeIndex: _aiTab, onSelect: (i) => setState(() => _aiTab = i), primaryColor: primaryColor, isDark: isDark),
                const SizedBox(width: 6),
                _buildAiTabPill(context, label: '⚖️ Nuance', index: 1, activeIndex: _aiTab, onSelect: (i) => setState(() => _aiTab = i), primaryColor: primaryColor, isDark: isDark),
                const SizedBox(width: 6),
                _buildAiTabPill(context, label: '💬 Sentences', index: 2, activeIndex: _aiTab, onSelect: (i) => setState(() => _aiTab = i), primaryColor: primaryColor, isDark: isDark),
                const SizedBox(width: 6),
                _buildAiTabPill(context, label: '⚡ Quick AI', index: 3, activeIndex: _aiTab, onSelect: (i) => setState(() => _aiTab = i), primaryColor: primaryColor, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_aiTab == 0) ...[
            if (_aiMnemonicResult != null)
              _buildStreamingResultCard(
                context: context,
                text: _aiMnemonicResult,
                bgColor: isDark ? AppColors.darkSoftYellow : AppColors.softYellow.withValues(alpha: 0.6),
                textColor: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
                primaryColor: primaryColor,
                isStreaming: _isAiStreaming,
                onStop: _stopAiStream,
                onRegenerate: () => _triggerMnemonicStream(context, ref, entry),
              )
            else ...[
              Text(
                'Generate a clever visual memory trick to remember "${entry.core.headword}" forever.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isAiStreaming ? null : () => _triggerMnemonicStream(context, ref, entry),
                  icon: _isAiStreaming
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(CupertinoIcons.sparkles, size: 16),
                  label: Text(
                    _isAiStreaming ? 'Streaming Mnemonic...' : 'Generate AI Mnemonic',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ] else if (_aiTab == 1) ...[
            if (_aiNuanceResult != null)
              _buildStreamingResultCard(
                context: context,
                text: _aiNuanceResult,
                bgColor: isDark ? AppColors.darkSoftPurple : AppColors.softPurple.withValues(alpha: 0.6),
                textColor: isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
                primaryColor: primaryColor,
                isStreaming: _isAiStreaming,
                onStop: _stopAiStream,
                onRegenerate: () => _triggerNuanceStream(context, ref, entry),
              )
            else ...[
              Text(
                'Explain the precise emotional tone and nuance of "${entry.core.headword}" compared to synonyms.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isAiStreaming ? null : () => _triggerNuanceStream(context, ref, entry),
                  icon: _isAiStreaming
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(CupertinoIcons.sparkles, size: 16),
                  label: Text(
                    _isAiStreaming ? 'Streaming Nuance...' : 'Explain Nuance with Gemini',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ] else if (_aiTab == 2) ...[
            if (_aiExamplesResult != null)
              _buildStreamingResultCard(
                context: context,
                text: _aiExamplesResult,
                bgColor: isDark ? AppColors.darkSoftBlue : AppColors.softBlue.withValues(alpha: 0.6),
                textColor: isDark ? AppColors.darkSoftBlueText : AppColors.textPrimary,
                primaryColor: primaryColor,
                isStreaming: _isAiStreaming,
                onStop: _stopAiStream,
                onRegenerate: () => _triggerExamplesStream(context, ref, entry),
              )
            else ...[
              Text(
                'Generate casual conversation and workplace examples for "${entry.core.headword}".',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isAiStreaming ? null : () => _triggerExamplesStream(context, ref, entry),
                  icon: _isAiStreaming
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(CupertinoIcons.sparkles, size: 16),
                  label: Text(
                    _isAiStreaming ? 'Streaming Sentences...' : 'Generate AI Sentences',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ] else ...[
            Text(
              'Tap an interactive prompt to stream real-time insights for "${entry.core.headword}":',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickPromptChip(context, label: '👶 Explain Simply', type: 'simple', entry: entry, ref: ref, primaryColor: primaryColor, isDark: isDark),
                _buildQuickPromptChip(context, label: '📖 Micro-Story', type: 'story', entry: entry, ref: ref, primaryColor: primaryColor, isDark: isDark),
                _buildQuickPromptChip(context, label: '🔤 Synonyms & Tone', type: 'synonyms', entry: entry, ref: ref, primaryColor: primaryColor, isDark: isDark),
                _buildQuickPromptChip(context, label: '🏛️ Etymology', type: 'etymology', entry: entry, ref: ref, primaryColor: primaryColor, isDark: isDark),
              ],
            ),
            if (_aiCustomResult != null) ...[
              const SizedBox(height: 14),
              _buildStreamingResultCard(
                context: context,
                text: _aiCustomResult,
                bgColor: isDark ? AppColors.darkSoftGreen : AppColors.softGreen.withValues(alpha: 0.6),
                textColor: isDark ? AppColors.darkSoftGreenText : AppColors.textPrimary,
                primaryColor: primaryColor,
                isStreaming: _isAiStreaming,
                onStop: _stopAiStream,
                onRegenerate: () {
                  if (_activeCustomPromptType != null) {
                    _triggerCustomStream(context, ref, entry, _activeCustomPromptType!);
                  }
                },
              ),
            ],
          ],
          if (_aiErrorMsg != null) ...[
            const SizedBox(height: 10),
            Text(
              _aiErrorMsg!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiTabPill(
    BuildContext context, {
    required String label,
    required int index,
    required int activeIndex,
    required Function(int) onSelect,
    required Color primaryColor,
    required bool isDark,
  }) {
    final isSelected = index == activeIndex;
    return InkWell(
      onTap: () => onSelect(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? AppColors.darkTileBg : AppColors.softPurple.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  void _showApiKeyPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Gemini API Key Required', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Please enter your free Gemini API Key in Settings to unlock AI Mnemonics, Nuance Explanations, and Practice Sentences.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/settings');
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedButton(BuildContext context, WidgetRef ref, bool isSaved) {
    final theme = Theme.of(context);

    return _BouncyTouch(
      onTap: () => _toggleSaveWord(context, ref),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (isSaved ? theme.primaryColor : AppColors.buttonBlack).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSaved ? theme.primaryColor : AppColors.buttonBlack,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          onPressed: () => _toggleSaveWord(context, ref),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isSaved ? 'Saved to My Vocabulary' : 'Save to My Vocabulary',
                style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSaved ? const Color(0xFF86D568) : Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSaved ? CupertinoIcons.check_mark : CupertinoIcons.add,
                  color: Colors.white,
                  size: 12,
                  weight: 800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FLUID STAGGERED ENTRANCE ANIMATED WIDGET
class _FluidAnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;

  const _FluidAnimatedCard({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 30).clamp(0, 300)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _SafeCard extends StatelessWidget {
  final Widget Function() builder;

  const _SafeCard({required this.builder});

  @override
  Widget build(BuildContext context) {
    try {
      return builder();
    } catch (e, stack) {
      debugPrint('Error building WordDetail card: $e\n$stack');
      return const SizedBox.shrink();
    }
  }
}

// SPRING BOUNCY TOUCH MICRO-INTERACTION WIDGET
class _BouncyTouch extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyTouch({super.key, required this.child, required this.onTap});

  @override
  State<_BouncyTouch> createState() => _BouncyTouchState();
}

class _BouncyTouchState extends State<_BouncyTouch> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        child: widget.child,
      ),
    );
  }
}
