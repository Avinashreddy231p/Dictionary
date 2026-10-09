import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../data/models/lexical_entry.dart';
import '../../data/services/export_service.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  final int? collectionId;
  final String title;
  final String? description;
  final String? smartType; // 'recent', 'review', 'favorites', 'book', 'mastered', 'notes'

  const CollectionDetailScreen({
    super.key,
    this.collectionId,
    required this.title,
    this.description,
    this.smartType,
  });

  @override
  ConsumerState<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends ConsumerState<CollectionDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddWordBottomSheet(BuildContext context, int collectionId) {
    final textController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setBottomSheetState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white30 : Colors.grey[300],
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
                        'Add Word',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: isDark ? Colors.white54 : AppColors.textDisabled,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Save a word directly to "${widget.title}"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Text Input Field
                  TextField(
                    controller: textController,
                    autofocus: true,
                    onChanged: (_) => setBottomSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: 'e.g. serendipity, ephemeral...',
                      prefixIcon: Icon(CupertinoIcons.search, color: isDark ? Colors.white60 : AppColors.textSecondary),
                      filled: true,
                      fillColor: theme.cardTheme.color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.cardBorder(context), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.cardBorder(context), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: theme.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                      onPressed: isLoading
                          ? null
                          : () async {
                              final query = textController.text.trim();
                              if (query.isNotEmpty) {
                                setBottomSheetState(() {
                                  isLoading = true;
                                });

                                final db = ref.read(databaseProvider);
                                final repo = ref.read(wordRepositoryProvider);

                                // Fetch dictionary entry if available
                                final results = await repo.searchWord(query);
                                final entry = results.isNotEmpty ? results.first : null;

                                final savedId = await db.saveWord(
                                  word: query,
                                  phonetic: entry?.core.phonetic,
                                  partOfSpeech: entry?.core.partOfSpeech,
                                  meaning: entry?.dictionaryLayer.simpleMeaning ?? 'Saved custom word',
                                  example: entry?.senses.isNotEmpty == true && entry!.senses.first.examples.isNotEmpty
                                      ? entry.senses.first.examples.first
                                      : null,
                                  source: widget.title,
                                );
                                await db.addWordToCollection(collectionId, savedId);

                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                }
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Add to Collection',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteCollectionBottomSheet(BuildContext context, int collectionId) {
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
      builder: (ctx) => Container(
        color: isDark ? const Color(0xFF181826) : Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Collection?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Are you sure you want to delete "${widget.title}"? Words will remain in your general vocabulary.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: AppColors.cardBorder(context)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await ref.read(databaseProvider).deleteCollection(collectionId);
                        if (context.mounted && context.canPop()) {
                          context.pop();
                        }
                      },
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExportCollectionBottomSheet(BuildContext context, List<SavedWord> words) {
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Export Collection Vocabulary',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Choose a format to export ${words.length} vocabulary words:',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Option 1: Visual Poster Card Image Summary
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(CupertinoIcons.photo_fill_on_rectangle_fill, color: Colors.orange, size: 20),
                    ),
                    title: const Text('Visual Poster Card Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Beautiful, shareable poster card with vocabulary list'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showSharePosterCardModal(context, words, widget.title);
                    },
                  ),
                  const Divider(height: 1),

                  // Option 2: Anki CSV Deck Format
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(CupertinoIcons.rectangle_stack_fill, color: Colors.purple, size: 20),
                    ),
                    title: const Text('Anki Flashcard Deck CSV (.csv)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Export & share as .csv file for Anki app'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final csv = ExportService.exportToAnkiCsv(words);
                      await ExportService.exportAndShareFile(
                        context: context,
                        filename: '${widget.title}_Anki.csv',
                        content: csv,
                        successMessage: 'Exported Anki Deck file (.csv)',
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // Option 3: Printable PDF Document Format
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(CupertinoIcons.doc_richtext, color: Colors.redAccent, size: 20),
                    ),
                    title: const Text('Printable PDF Study Document (.pdf)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Export & share as a real binary .pdf document file'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final pdfBytes = await ExportService.generatePdfDocument(words, widget.title);
                      if (context.mounted) {
                        await ExportService.exportAndShareBytes(
                          context: context,
                          filename: '${widget.title}_StudySheet.pdf',
                          bytes: pdfBytes,
                          successMessage: 'Exported PDF Study Document (.pdf)',
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),

                  // Option 4: Formatted Study Sheet
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(CupertinoIcons.doc_text_fill, color: Colors.green, size: 20),
                    ),
                    title: const Text('Formatted Study Sheet Text (.txt)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Export & share as .txt text file'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final sheet = ExportService.exportToFormattedStudySheet(words, widget.title);
                      await ExportService.exportAndShareFile(
                        context: context,
                        filename: '${widget.title}_Notes.txt',
                        content: sheet,
                        successMessage: 'Exported Study Sheet file (.txt)',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSharePosterCardModal(BuildContext context, List<SavedWord> words, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF181826) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.photo_fill_on_rectangle_fill, color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('Visual Poster Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Poster Card Preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF232338) : const Color(0xFFF3EDFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primaryColor.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: primaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${words.length} Words',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      ...words.take(5).map((w) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                    children: [
                                      TextSpan(text: '${w.word}: ', style: const TextStyle(fontWeight: FontWeight.w900)),
                                      TextSpan(text: w.meaning ?? 'Vocabulary word'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      if (words.length > 5) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+ ${words.length - 5} more words in collection...',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: primaryColor),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final summary = ExportService.exportToFormattedStudySheet(words, title);
                      await ExportService.exportAndShareFile(
                        context: context,
                        filename: '${title}_PosterCard.txt',
                        content: summary,
                        successMessage: 'Exported Visual Poster Summary file',
                      );
                    },
                    icon: const Icon(CupertinoIcons.doc_on_doc, size: 18),
                    label: const Text(
                      'Copy Visual Poster Summary',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmart = widget.smartType != null;
    
    // Select stream based on smartType vs user collection
    AsyncValue<List<SavedWord>> wordsAsync;
    if (widget.smartType == 'recent') {
      wordsAsync = ref.watch(recentSavedWordsProvider);
    } else if (widget.smartType == 'review') {
      wordsAsync = ref.watch(needsReviewStreamProvider);
    } else if (widget.smartType == 'favorites') {
      wordsAsync = ref.watch(favoritesStreamProvider);
    } else if (widget.smartType == 'book') {
      wordsAsync = ref.watch(wordsWithSourceStreamProvider);
    } else if (widget.smartType == 'mastered') {
      wordsAsync = ref.watch(masteredWordsStreamProvider);
    } else if (widget.smartType == 'notes') {
      wordsAsync = ref.watch(wordsWithNotesStreamProvider);
    } else if (widget.collectionId != null) {
      wordsAsync = ref.watch(collectionWordsStreamProvider(widget.collectionId!));
    } else {
      wordsAsync = ref.watch(savedWordsStreamProvider);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/collections');
            }
          },
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.share),
            tooltip: 'Export Collection',
            onPressed: () => _showExportCollectionBottomSheet(context, wordsAsync.value ?? []),
          ),
          if (!isSmart && widget.collectionId != null) ...[
            IconButton(
              icon: const Icon(CupertinoIcons.plus_circle),
              onPressed: () => _showAddWordBottomSheet(context, widget.collectionId!),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
              onPressed: () => _confirmDeleteCollectionBottomSheet(context, widget.collectionId!),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Stats Card Header (scrolls out of view)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
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
                              widget.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          wordsAsync.when(
                            data: (words) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${words.length} words',
                                style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      if (widget.description != null && widget.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Progress Breakdown
                      wordsAsync.when(
                        data: (words) {
                          final known = words.where((w) => w.reviewState == 2).length;
                          final review = words.where((w) => w.reviewState == 1).length;
                          final learning = words.where((w) => w.reviewState == 0).length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$known known • $learning learning • $review review',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  height: 8,
                                  child: Row(
                                    children: [
                                      if (words.isNotEmpty) ...[
                                        Expanded(
                                          flex: known > 0 ? known : (words.isEmpty ? 1 : 0),
                                          child: Container(color: isDark ? AppColors.darkSoftGreen : AppColors.softGreen),
                                        ),
                                        Expanded(
                                          flex: learning > 0 ? learning : 0,
                                          child: Container(color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow),
                                        ),
                                        Expanded(
                                          flex: review > 0 ? review : 0,
                                          child: Container(color: isDark ? AppColors.darkSoftPink : AppColors.softPeach),
                                        ),
                                      ] else
                                        Expanded(
                                          child: Container(color: AppColors.cardBorder(context)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Search Bar Header (pins below AppBar on scroll)
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedSearchBarDelegate(
                height: 64.0,
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Filter words in this collection...',
                      prefixIcon: Icon(CupertinoIcons.search, color: isDark ? Colors.white60 : AppColors.textSecondary),
                      filled: true,
                      fillColor: theme.cardTheme.color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.cardBorder(context), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColors.cardBorder(context), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: theme.primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Word List Slivers
            wordsAsync.when(
              data: (words) {
                final filtered = _searchQuery.isEmpty
                    ? words
                    : words.where((w) => w.word.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.book, size: 56, color: isDark ? Colors.white38 : AppColors.textDisabled),
                            const SizedBox(height: 16),
                            Text(
                              words.isEmpty ? 'No words in this collection yet.' : 'No matching words found.',
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (!isSmart && widget.collectionId != null && words.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => _showAddWordBottomSheet(context, widget.collectionId!),
                                icon: const Icon(CupertinoIcons.add),
                                label: const Text('Add your first word'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildWordCard(context, item),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(BuildContext context, SavedWord item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final db = ref.read(databaseProvider);

    final reviewText = item.reviewState == 2 ? 'Known' : (item.reviewState == 1 ? 'Review' : 'Learning');
    final reviewColor = item.reviewState == 2
        ? (isDark ? AppColors.darkSoftGreen : AppColors.softGreen)
        : (item.reviewState == 1
            ? (isDark ? AppColors.darkSoftPink : AppColors.softPeach)
            : (isDark ? AppColors.darkSoftYellow : AppColors.softYellow));
    final reviewTextColor = item.reviewState == 2
        ? (isDark ? AppColors.darkSoftGreenText : AppColors.textPrimary)
        : (item.reviewState == 1
            ? (isDark ? AppColors.darkSoftPinkText : AppColors.textPrimary)
            : (isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary));

    return InkWell(
      onTap: () {
        final entry = LexicalEntry(
          core: CoreData(
            headword: item.word,
            homograph: 0,
            partOfSpeech: item.partOfSpeech ?? 'word',
            phonetic: item.phonetic ?? '',
            audioUrl: '',
            syllables: item.syllables?.split('*') ?? [item.word],
          ),
          senses: [
            Sense(
              senseNumber: '1',
              definition: item.meaning ?? 'No definition provided',
              examples: item.example != null ? [item.example!] : [],
              labels: [],
            )
          ],
          grammar: GrammarData(
            verbDivision: '',
            usageNotes: [],
            inflections: [],
            relatedForms: [],
          ),
          linguistic: LinguisticData(
            etymology: '',
            firstKnownUse: '',
          ),
          dictionaryLayer: DictionaryLayer(
            simpleMeaning: item.meaning ?? 'No definition provided',
            contextualMeaning: item.contextSentence ?? '',
            synonyms: [],
            antonyms: [],
          ),
        );
        context.push('/home/search/detail', extra: entry);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
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
                      Flexible(
                        child: Text(
                          item.word,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (item.phonetic != null && item.phonetic!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.phonetic!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: reviewColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reviewText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: reviewTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        item.isFavorite ? CupertinoIcons.star_fill : CupertinoIcons.star,
                        color: item.isFavorite ? Colors.amber : AppColors.textDisabled,
                        size: 20,
                      ),
                      onPressed: () => db.toggleFavorite(item.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (item.meaning != null && item.meaning!.isNotEmpty) ...[
              Text(
                item.meaning!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            if (item.contextSentence != null && item.contextSentence!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '“${item.contextSentence}”',
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinnedSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _PinnedSearchBarDelegate({required this.child, this.height = 64.0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _PinnedSearchBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
