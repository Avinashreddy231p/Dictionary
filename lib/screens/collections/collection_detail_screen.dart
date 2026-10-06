import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../data/models/lexical_entry.dart';

class CollectionDetailScreen extends ConsumerStatefulWidget {
  final int? collectionId;
  final String title;
  final String? description;
  final String? smartType; // 'recent', 'review', 'favorites', 'book'

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

  void _showAddWordDialog(BuildContext context, int collectionId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Word to Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a word to save and add to this collection:'),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. serendipity',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final query = textController.text.trim();
              if (query.isNotEmpty) {
                Navigator.pop(ctx);
                final db = ref.read(databaseProvider);
                final repo = ref.read(wordRepositoryProvider);
                
                // Fetch dictionary entry if available
                final results = await repo.searchWord(query);
                final entry = results.isNotEmpty ? results.first : null;
                
                final savedId = await db.saveWord(
                  word: query,
                  phonetic: entry?.core.phonetic,
                  partOfSpeech: entry?.core.partOfSpeech,
                  meaning: entry?.lexiLens.simpleMeaning ?? 'Saved custom word',
                  example: entry?.senses.isNotEmpty == true && entry!.senses.first.examples.isNotEmpty ? entry.senses.first.examples.first : null,
                  source: widget.title,
                );
                await db.addWordToCollection(collectionId, savedId);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(BuildContext context, int collectionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Collection?'),
        content: Text('Are you sure you want to delete "${widget.title}"? The words will remain in your general vocabulary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(databaseProvider).deleteCollection(collectionId);
              if (context.mounted && context.canPop()) {
                context.pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
          if (!isSmart && widget.collectionId != null) ...[
            IconButton(
              icon: const Icon(CupertinoIcons.plus_circle),
              onPressed: () => _showAddWordDialog(context, widget.collectionId!),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
              onPressed: () => _confirmDeleteCollection(context, widget.collectionId!),
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
                                onPressed: () => _showAddWordDialog(context, widget.collectionId!),
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
          lexiLens: LexiLensLayer(
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
