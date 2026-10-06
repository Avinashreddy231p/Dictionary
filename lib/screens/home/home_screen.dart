import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../data/models/lexical_entry.dart';
import '../collections/collection_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _showAddWordDialog(BuildContext context) {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Custom Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Word',
                hintText: 'e.g. ubiquitous',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: meaningController,
              decoration: InputDecoration(
                labelText: 'Definition',
                hintText: 'e.g. Present, appearing, or found everywhere',
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
              final word = wordController.text.trim();
              if (word.isNotEmpty) {
                Navigator.pop(ctx);
                final db = ref.read(databaseProvider);
                final repo = ref.read(wordRepositoryProvider);
                final results = await repo.searchWord(word);
                final entry = results.isNotEmpty ? results.first : null;

                await db.saveWord(
                  word: word,
                  phonetic: entry?.core.phonetic,
                  partOfSpeech: entry?.core.partOfSpeech ?? 'word',
                  meaning: meaningController.text.trim().isNotEmpty
                      ? meaningController.text.trim()
                      : (entry?.lexiLens.simpleMeaning ?? 'Custom word'),
                  example: (entry?.senses.isNotEmpty == true && entry!.senses.first.examples.isNotEmpty)
                      ? entry.senses.first.examples.first
                      : null,
                  source: 'Manual Add',
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasteTextDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Paste Text to Extract Words'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste an article or snippet to save key vocabulary:'),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Paste text here...',
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
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                final db = ref.read(databaseProvider);
                final colId = await db.createCollection(
                  title: 'Pasted Excerpt',
                  description: text.length > 50 ? '${text.substring(0, 50)}...' : text,
                  colorHex: '0xFFD4E3FF',
                );

                // Extract potential unique words
                final words = text
                    .replaceAll(RegExp(r'[^\w\s]'), '')
                    .split(RegExp(r'\s+'))
                    .where((w) => w.length > 4)
                    .toSet()
                    .take(5);

                for (var w in words) {
                  final savedId = await db.saveWord(
                    word: w,
                    meaning: 'Extracted from pasted excerpt',
                    contextSentence: text,
                    source: 'Pasted Excerpt',
                  );
                  await db.addWordToCollection(colId, savedId);
                }

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollectionDetailScreen(
                        collectionId: colId,
                        title: 'Pasted Excerpt',
                        description: text,
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Create Collection'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildSearchSection(context),
              const SizedBox(height: 28),
              _buildTodayVocabulary(context),
              const SizedBox(height: 24),
              _buildContinueReading(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.sparkles,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LexiLens',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Understand every word.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            context.go('/settings');
          },
          icon: const Icon(CupertinoIcons.settings),
          style: IconButton.styleFrom(
            backgroundColor: theme.cardTheme.color,
            side: BorderSide(color: AppColors.cardBorder(context), width: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionCard(
              context,
              'Scan Text',
              CupertinoIcons.camera,
              isDark ? AppColors.darkSoftGreen : AppColors.softGreen,
              isDark ? AppColors.darkSoftGreenText : AppColors.textPrimary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera text scanner ready.')),
                );
              },
            ),
            _buildActionCard(
              context,
              'Import Book',
              CupertinoIcons.doc,
              isDark ? AppColors.darkSoftPink : AppColors.softPeach,
              isDark ? AppColors.darkSoftPinkText : AppColors.textPrimary,
              onTap: () {
                _showAddWordDialog(context);
              },
            ),
            _buildActionCard(
              context,
              'Paste Text',
              CupertinoIcons.doc_on_clipboard,
              isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
              isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
              onTap: () {
                _showPasteTextDialog(context);
              },
            ),
            _buildActionCard(
              context,
              'Add Word',
              CupertinoIcons.add,
              isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
              isDark ? AppColors.darkSoftBlueText : AppColors.textPrimary,
              onTap: () {
                _showAddWordDialog(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bg,
    Color textColor, {
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? Border.all(color: textColor.withOpacity(0.3), width: 1.5) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recentSearchesAsync = ref.watch(recentSearchesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            context.go('/home/search');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.search,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search a word, phrase, or sentence...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_right,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        recentSearchesAsync.when(
          data: (queries) {
            final list = queries.isNotEmpty
                ? queries
                : ['reluctant', 'peculiar', 'ambiguous', 'serene'];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8, left: 4),
                    child: Text(
                      'Recent:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: isDark ? Colors.white38 : AppColors.textDisabled,
                      ),
                    ),
                  ),
                  ...list.map((word) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () async {
                          final repo = ref.read(wordRepositoryProvider);
                          final results = await repo.searchWord(word);
                          if (results.isNotEmpty && context.mounted) {
                            context.push('/home/search/detail', extra: results.first);
                          } else if (context.mounted) {
                            context.go('/home/search');
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface.withOpacity(0.8)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.cardBorder(context),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                size: 11,
                                color: isDark ? Colors.white54 : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                word,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTodayVocabulary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final savedWordsAsync = ref.watch(savedWordsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.sparkles,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Vocabulary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.go('/collections'),
              child: Text(
                'See all',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        savedWordsAsync.when(
          data: (words) {
            final todayWord = words.isNotEmpty ? words.first : null;
            final wordTitle = todayWord?.word ?? 'serene';
            final phonetic = todayWord?.phonetic ?? '/səˈriːn/';
            final pos = todayWord?.partOfSpeech ?? 'adjective';
            final cefr = todayWord?.cefr ?? 'B1';
            final meaning = todayWord?.meaning ??
                'Calm, peaceful, and untroubled; tranquil.';
            final example = todayWord?.example ??
                'The serene landscape brought a deep sense of peace.';

            return InkWell(
              onTap: () async {
                final repo = ref.read(wordRepositoryProvider);
                final results = await repo.searchWord(wordTitle);
                if (results.isNotEmpty && context.mounted) {
                  context.push('/home/search/detail', extra: results.first);
                } else if (todayWord != null && context.mounted) {
                  final fallbackEntry = LexicalEntry(
                    core: CoreData(
                      headword: todayWord.word,
                      homograph: 0,
                      partOfSpeech: todayWord.partOfSpeech ?? 'word',
                      phonetic: todayWord.phonetic ?? '',
                      audioUrl: '',
                      syllables: todayWord.syllables?.split('*') ?? [todayWord.word],
                    ),
                    senses: [
                      Sense(
                        senseNumber: '1',
                        definition: todayWord.meaning ?? 'Vocabulary word',
                        examples: todayWord.example != null ? [todayWord.example!] : [],
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
                      simpleMeaning: todayWord.meaning ?? 'Vocabulary word',
                      contextualMeaning: todayWord.contextSentence ?? '',
                      synonyms: [],
                      antonyms: [],
                    ),
                  );
                  context.push('/home/search/detail', extra: fallbackEntry);
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 12,
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pos.toUpperCase(),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                cefr,
                                style: TextStyle(
                                  color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 18,
                          color: isDark ? Colors.white38 : AppColors.textDisabled,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Text(
                          wordTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        if (phonetic.isNotEmpty)
                          Text(
                            phonetic,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white54 : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meaning,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: isDark ? Colors.white.withOpacity(0.87) : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (example.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBackground.withOpacity(0.6)
                              : AppColors.background.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white12 : AppColors.border.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.quote_bubble,
                              size: 14,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"$example"',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildContinueReading(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userColsAsync = ref.watch(userCollectionsStreamProvider);

    return userColsAsync.when(
      data: (cols) {
        final activeCol = cols.isNotEmpty ? cols.first : null;
        final title = activeCol?.title ?? 'The Great Gatsby';
        final desc = activeCol?.description ?? 'Chapter 3 • Vocabulary reading';

        return InkWell(
          onTap: () {
            if (activeCol != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CollectionDetailScreen(
                    collectionId: activeCol.id,
                    title: activeCol.title,
                    description: activeCol.description,
                  ),
                ),
              );
            } else {
              context.go('/collections');
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.book_fill,
                    color: isDark ? AppColors.darkSoftPurpleText : theme.primaryColor,
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
                          Text(
                            'CONTINUE READING',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white38 : AppColors.textDisabled,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '68%',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        desc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.play_fill,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
