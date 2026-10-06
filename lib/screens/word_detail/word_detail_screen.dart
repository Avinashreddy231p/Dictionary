import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../data/models/dictionary_entry.dart';

class WordDetailScreen extends ConsumerStatefulWidget {
  final DictionaryEntry? entry;

  const WordDetailScreen({super.key, this.entry});

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio(String url) async {
    if (url.isEmpty || _isPlaying) return;
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      // Audio playback failed
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  void _toggleSaveWord(BuildContext context, WidgetRef ref) async {
    if (widget.entry == null) return;

    try {
      final db = ref.read(databaseProvider);
      final word = widget.entry!.word.toLowerCase();
      final saved = await db.getSavedWordByWord(word);

      if (saved != null) {
        if (!mounted) return;
        _showCollectionsSheet(context, ref, saved);
      } else {
        final simpleMeaning = widget.entry!.meanings.isNotEmpty
            ? widget.entry!.meanings.first.split(';').first
            : 'Vocabulary word';
        final example = widget.entry!.examples.isNotEmpty ? widget.entry!.examples.first : null;

        await db.saveWord(
          word: widget.entry!.word,
          phonetic: widget.entry!.phonetic,
          partOfSpeech: widget.entry!.partOfSpeech,
          meaning: simpleMeaning,
          example: example,
          syllables: widget.entry!.syllables.join('*'),
          cefr: 'B2',
        );

        final newSaved = await db.getSavedWordByWord(word);
        if (newSaved != null && mounted) {
          _showCollectionsSheet(context, ref, newSaved);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "${widget.entry!.word}" to your vocabulary!'),
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

  void _showCollectionsSheet(BuildContext context, WidgetRef ref, SavedWord savedWord) {
    final db = ref.read(databaseProvider);

    showModalBottomSheet(
      context: context,
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
                      Text(
                        'Collections for "${savedWord.word}"',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.textDisabled),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select which collections to include this word in:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  userColsAsync.when(
                    data: (cols) {
                      final assignedIds = wordColIdsAsync.value ?? [];

                      if (cols.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('No custom collections yet.', style: Theme.of(context).textTheme.bodyMedium),
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
    if (widget.entry == null) {
      return const Scaffold(
        body: Center(child: Text('Word not found.')),
      );
    }

    final entry = widget.entry!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final word = entry.word;
    final phonetic = entry.phonetic.isNotEmpty ? entry.phonetic : '';
    final pos = entry.partOfSpeech;
    final meanings = entry.meanings;

    final isSavedAsync = ref.watch(isWordSavedStreamProvider(word.toLowerCase()));
    final isSaved = isSavedAsync.value ?? false;

    final simpleMeaning = meanings.isNotEmpty
        ? meanings.first.split(';').first
        : 'Not wanting to do something.';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Header blob
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkHeaderYellow : AppColors.headerYellow,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                border: isDark
                    ? Border.all(color: AppColors.darkHeaderYellowText.withOpacity(0.3), width: 1.5)
                    : null,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, ref, isSaved),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeaderContent(context, word, phonetic, pos),
                        const SizedBox(height: 24),

                        // Mastery Progress Card (if saved)
                        if (isSaved) _buildMasteryCard(context, ref, word),
                        if (isSaved) const SizedBox(height: 16),

                        // 1. Core Meaning & Context
                        _buildSimpleMeaningCard(context, simpleMeaning),
                        const SizedBox(height: 16),
                        _buildContextCard(context, word),
                        const SizedBox(height: 16),
                        _buildExampleCard(context, entry!.examples),
                        const SizedBox(height: 16),
                        _buildAnatomyCard(context),
                        const SizedBox(height: 24),

                        // 2. Rich Dictionary Data
                        if (meanings.isNotEmpty)
                          _buildFullDefinitionsCard(context, meanings),
                        if (meanings.isNotEmpty) const SizedBox(height: 16),

                        if (entry!.grammaticalInfo.isNotEmpty ||
                            entry!.registers.isNotEmpty ||
                            entry!.domains.isNotEmpty)
                          _buildUsageGrammarCard(context),
                        if (entry!.grammaticalInfo.isNotEmpty ||
                            entry!.registers.isNotEmpty ||
                            entry!.domains.isNotEmpty)
                          const SizedBox(height: 16),

                        if (entry!.inflections.isNotEmpty)
                          _buildWordFamilyCard(context),
                        if (entry!.inflections.isNotEmpty)
                          const SizedBox(height: 16),

                        if (entry!.synonyms.isNotEmpty ||
                            entry!.antonyms.isNotEmpty)
                          _buildRelationshipsCard(context),
                        if (entry!.synonyms.isNotEmpty ||
                            entry!.antonyms.isNotEmpty)
                          const SizedBox(height: 16),

                        if (entry!.etymology.isNotEmpty)
                          _buildEtymologyCard(context, entry!.etymology),
                        if (entry!.etymology.isNotEmpty)
                          const SizedBox(height: 24),

                        // 3. Bottom Action
                        _buildSavedButton(context, ref, isSaved),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, bool isSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFloatingIconButton(
            context,
            icon: CupertinoIcons.back,
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
          Row(
            children: [
              _buildFloatingIconButton(
                context,
                icon: isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                iconColor: isSaved ? Colors.green : null,
                onPressed: () => _toggleSaveWord(context, ref),
              ),
              const SizedBox(width: 12),
              _buildFloatingIconButton(
                context,
                icon: CupertinoIcons.ellipsis_vertical,
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
    );
  }

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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white : AppColors.textPrimary),
          size: 22,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHeaderContent(
      BuildContext context, String word, String phonetic, String pos) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerTextColor =
        isDark ? AppColors.darkHeaderYellowText : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word.toUpperCase(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                color: headerTextColor,
                height: 1.0,
              ),
        ),
        if (phonetic.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    phonetic,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: headerTextColor,
                          fontSize: 20,
                        ),
                  ),
                  const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _playAudio(widget.entry!.audioUrl),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black38 : Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: _isPlaying 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPurple)
                          )
                        : Icon(CupertinoIcons.speaker_2_fill, size: 20, color: headerTextColor),
                  ),
                ),
              ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBadgeTeal : AppColors.badgeTeal,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark
                      ? Border.all(color: AppColors.darkBadgeTealText, width: 1.5)
                      : null,
                ),
                child: Text(
                  'B2',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkBadgeTealText
                            : AppColors.textPrimary,
                      ),
                ),
              )
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          pos,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: headerTextColor.withOpacity(0.85),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
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
        final icons = [CupertinoIcons.book, CupertinoIcons.arrow_2_circlepath, CupertinoIcons.star_fill];

        final stateIndex = savedWord.reviewState.clamp(0, 2);
        final bgColor = isDark ? darkColors[stateIndex] : colors[stateIndex];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: Colors.white24) : Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icons[stateIndex], color: isDark ? Colors.white : AppColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Progress',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      states[stateIndex],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white24 : Colors.white,
                  foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  side: isDark ? null : const BorderSide(color: AppColors.border),
                ),
                onPressed: () async {
                  final db = ref.read(databaseProvider);
                  await db.updateReviewState(savedWord.id, (stateIndex + 1) % 3);
                },
                child: const Text('Update'),
              )
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSimpleMeaningCard(BuildContext context, String meaning) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSoftYellow : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isDark
                      ? AppColors.darkSoftYellowText.withOpacity(0.4)
                      : AppColors.border),
            ),
            child: Icon(CupertinoIcons.lightbulb,
                size: 20,
                color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simple meaning',
                  style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  meaning.replaceFirst(meaning[0], meaning[0].toUpperCase()) +
                      (meaning.endsWith('.') ? '' : '.'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              Text(
                'In context',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exampleText = examples.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSoftPink : AppColors.examplePink,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkSoftPinkText.withOpacity(0.3), width: 1.5)
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
            '"${exampleText.replaceFirst(exampleText[0], exampleText[0].toUpperCase())}"',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkSoftPinkText.withOpacity(0.9)
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnatomyCard(BuildContext context) {
    if (widget.entry == null || widget.entry!.syllables.length < 2) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final syllables = widget.entry!.syllables;

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
            padding: const EdgeInsets.only(top: 16),
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: anatomyWidgets,
          ),
        ],
      ),
    );
  }

  Widget _buildAnatomyBubble(
      BuildContext context, String root, Color color, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? Border.all(color: textColor.withOpacity(0.3), width: 1.5) : null,
            ),
            child: Text(
              root,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDefinitionsCard(
      BuildContext context, List<String> meanings) {
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
            meanings.length > 1 ? 'All Definitions' : 'Definition',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          ...meanings.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (meanings.length > 1)
                    Text(
                      '${e.key + 1}. ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                    ),
                  Expanded(
                    child: Text(
                      e.value
                          .replaceFirst(e.value[0], e.value[0].toUpperCase()),
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUsageGrammarCard(BuildContext context) {
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
              ...widget.entry!.grammaticalInfo.map((info) => _buildMinimalTag(
                  context, info,
                  bg: isDark ? AppColors.darkSoftGreen : AppColors.softGreen,
                  textColor: isDark
                      ? AppColors.darkSoftGreenText
                      : AppColors.textPrimary)),
              ...widget.entry!.registers.map((r) => _buildMinimalTag(context, r,
                  bg: isDark ? AppColors.darkSoftPink : AppColors.softPeach,
                  textColor: isDark
                      ? AppColors.darkSoftPinkText
                      : AppColors.textPrimary)),
              ...widget.entry!.domains.map((d) => _buildMinimalTag(context, d,
                  bg: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
                  textColor: isDark
                      ? AppColors.darkSoftBlueText
                      : AppColors.textPrimary)),
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
        border: isDark ? Border.all(color: textColor.withOpacity(0.3)) : null,
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
    final theme = Theme.of(context);

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
            'Word Family',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            [widget.entry!.word, ...widget.entry!.inflections].join('  ·  '),
            style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
          ),
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
          if (widget.entry!.synonyms.isNotEmpty) ...[
            Text('Synonyms',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              widget.entry!.synonyms.join('  ·  '),
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.entry!.antonyms.isNotEmpty) ...[
            Text('Antonyms',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              widget.entry!.antonyms.join('  ·  '),
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEtymologyCard(BuildContext context, String etymology) {
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
              Icon(CupertinoIcons.time,
                  size: 20,
                  color: isDark ? Colors.white : AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'Etymology / History',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            etymology,
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedButton(BuildContext context, WidgetRef ref, bool isSaved) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isSaved ? theme.primaryColor : AppColors.buttonBlack).withOpacity(0.3),
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
    );
  }
}
