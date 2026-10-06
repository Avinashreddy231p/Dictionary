import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../data/models/dictionary_entry.dart';

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
  String _searchQuery = '';

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
                  phonetic: entry?.phonetic,
                  partOfSpeech: entry?.partOfSpeech,
                  meaning: entry?.meanings.isNotEmpty == true ? entry!.meanings.first : 'Saved custom word',
                  example: entry?.examples.isNotEmpty == true ? entry!.examples.first : null,
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
      backgroundColor: AppColors.background,
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
        child: Column(
          children: [
            // Header Info Box
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.5),
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      wordsAsync.when(
                        data: (words) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.softPurple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${words.length} words',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$known known • $learning learning • $review review',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
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
                                      child: Container(color: AppColors.softGreen),
                                    ),
                                    Expanded(
                                      flex: learning > 0 ? learning : 0,
                                      child: Container(color: AppColors.softYellow),
                                    ),
                                    Expanded(
                                      flex: review > 0 ? review : 0,
                                      child: Container(color: AppColors.softPeach),
                                    ),
                                  ] else
                                    Expanded(
                                      child: Container(color: AppColors.border),
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

            // Search Bar inside Collection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Filter words in this collection...',
                  prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Word List
            Expanded(
              child: wordsAsync.when(
                data: (words) {
                  final filtered = _searchQuery.isEmpty
                      ? words
                      : words.where((w) => w.word.toLowerCase().contains(_searchQuery)).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.book, size: 56, color: AppColors.textDisabled),
                            const SizedBox(height: 16),
                            Text(
                              words.isEmpty ? 'No words in this collection yet.' : 'No matching words found.',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (!isSmart && widget.collectionId != null && words.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textPrimary,
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
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildWordCard(context, item);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(BuildContext context, SavedWord item) {
    final db = ref.read(databaseProvider);
    final reviewText = item.reviewState == 2 ? 'Known' : (item.reviewState == 1 ? 'Review' : 'Learning');
    final reviewColor = item.reviewState == 2
        ? AppColors.softGreen
        : (item.reviewState == 1 ? AppColors.softPeach : AppColors.softYellow);

    return InkWell(
      onTap: () {
        // Construct entry for word detail view
        final entry = DictionaryEntry(
          word: item.word,
          partOfSpeech: item.partOfSpeech ?? 'word',
          phonetic: item.phonetic ?? '',
          syllables: item.syllables?.split('*') ?? [item.word],
          meanings: [item.meaning ?? 'No definition provided'],
          examples: item.example != null ? [item.example!] : [],
          synonyms: [],
          antonyms: [],
          inflections: [],
          grammaticalInfo: [],
          registers: [],
          domains: [],
          etymology: '',
        );
        context.push('/home/search/detail', extra: entry);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
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
                      Text(
                        item.word,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (item.phonetic != null && item.phonetic!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.phonetic!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: reviewColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reviewText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            if (item.contextSentence != null && item.contextSentence!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '“${item.contextSentence}”',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
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
