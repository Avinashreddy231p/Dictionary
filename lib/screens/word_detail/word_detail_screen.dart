import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import '../../data/models/lexical_entry.dart';

class WordDetailScreen extends ConsumerStatefulWidget {
  final LexicalEntry? entry;

  const WordDetailScreen({super.key, this.entry});

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _noteController = TextEditingController();

  bool _isPlaying = false;
  double _audioSpeed = 1.0;

  // Recall / Quiz Mode State
  bool _isRecallMode = false;
  bool _isMeaningRevealed = false;

  // Datamuse Data
  List<String> _fetchedSynonyms = [];
  List<String> _fetchedAntonyms = [];
  List<String> _fetchedPairings = [];
  bool _isFetchingSynonyms = false;

  @override
  void initState() {
    super.initState();
    _loadExtraWordData();
  }

  @override
  void didUpdateWidget(covariant WordDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != widget.entry) {
      _loadExtraWordData();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadExtraWordData() async {
    if (widget.entry == null) return;
    final word = widget.entry!.core.headword.toLowerCase();
    if (word.isEmpty) return;

    final existingSyns = widget.entry!.lexiLens.synonyms;
    final existingAnts = widget.entry!.lexiLens.antonyms;

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

  void _playAudio(String url) async {
    if (url.isEmpty || _isPlaying) return;
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.setSpeed(_audioSpeed);
      await _audioPlayer.play();
    } catch (e) {
      // Audio error handling
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
    if (widget.entry == null) return;

    try {
      final db = ref.read(databaseProvider);
      final entry = widget.entry!;
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
          meaning: entry.lexiLens.simpleMeaning,
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

  void _showShareSheet(BuildContext context) {
    if (widget.entry == null) return;
    final entry = widget.entry!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

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
              // Styled Card Preview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.core.headword.toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'LexiLens',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkSoftYellowText : AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${entry.core.phonetic} • ${entry.core.partOfSpeech}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkSoftYellowText.withOpacity(0.8) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${entry.lexiLens.simpleMeaning}"',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: '${entry.core.headword.toUpperCase()} (${entry.core.phonetic})\n'
                          '${entry.core.partOfSpeech}\n\n'
                          'Meaning: ${entry.lexiLens.simpleMeaning}\n\n'
                          'Learned with LexiLens ✨',
                    ));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Word card summary copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.doc_on_doc),
                  label: const Text('Copy Word Summary'),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  Color _getHeaderBlobColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkHeaderYellow : AppColors.headerYellow;
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

    final word = entry.core.headword;
    final phonetic = entry.core.phonetic;
    final pos = entry.core.partOfSpeech;

    final isSavedAsync = ref.watch(isWordSavedStreamProvider(word.toLowerCase()));
    final isSaved = isSavedAsync.value ?? false;

    // Watch saved word for notes
    final savedWordAsync = ref.watch(savedWordStreamProvider(word.toLowerCase()));
    final savedWord = savedWordAsync.value;

    final allExamples = entry.senses.expand((s) => s.examples).toList();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. ACCENT HEADER BLOB (Starts BELOW top app bar region, so app bar is 100% transparent on cream!)
          Positioned(
            top: topPadding + 62, // Positioned right below the top floating icons!
            left: 0,
            right: 0,
            height: 250,
            child: GestureDetector(
              onTap: () {
                _playAudio(entry.core.audioUrl);
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _getHeaderBlobColor(context),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(44),
                    bottomRight: Radius.circular(44),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getHeaderBlobColor(context).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
              ),
            ),
          ),

          // 2. SCROLLABLE CONTENT WITH FLOATING TOP BAR
          SafeArea(
            child: Column(
              children: [
                // Top App Bar Area (Sits on clean cream background, 100% transparent!)
                _buildTopBar(context, ref, isSaved),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Word Header Content (Sits directly inside the Yellow Header Blob below top bar!)
                        _buildHeaderContent(context, word, phonetic, pos),
                        const SizedBox(height: 36),

                        // Mastery Progress Card (if saved)
                        if (isSaved) _buildMasteryCard(context, ref, word),
                        if (isSaved) const SizedBox(height: 16),

                        // 1. Core Meaning & Context (HIGHLIGHTED WITH SIMPLICITY)
                        _buildSimpleMeaningCard(context, entry.lexiLens.simpleMeaning),
                        const SizedBox(height: 16),
                        _buildContextCard(context, word),
                        const SizedBox(height: 16),
                        if (allExamples.isNotEmpty) _buildExampleCard(context, allExamples),
                        if (allExamples.isNotEmpty) const SizedBox(height: 16),
                        if (entry.core.syllables.length > 1) _buildAnatomyCard(context),
                        if (entry.core.syllables.length > 1) const SizedBox(height: 24),

                        // Personal Reader Notes (if saved)
                        if (isSaved && savedWord != null) ...[
                          _buildPersonalNoteCard(context, savedWord),
                          const SizedBox(height: 16),
                        ],

                        // 2. Rich Dictionary Data
                        if (entry.senses.isNotEmpty)
                          _buildFullDefinitionsCard(context, entry.senses),
                        if (entry.senses.isNotEmpty) const SizedBox(height: 16),

                        if (_fetchedPairings.isNotEmpty) ...[
                          _buildPairingsCard(context),
                          const SizedBox(height: 16),
                        ],

                        if (entry.grammar.verbDivision.isNotEmpty ||
                            entry.grammar.usageNotes.isNotEmpty)
                          _buildUsageGrammarCard(context),
                        if (entry.grammar.verbDivision.isNotEmpty ||
                            entry.grammar.usageNotes.isNotEmpty)
                          const SizedBox(height: 16),

                        if (entry.grammar.inflections.isNotEmpty || entry.grammar.relatedForms.isNotEmpty)
                          _buildWordFamilyCard(context),
                        if (entry.grammar.inflections.isNotEmpty || entry.grammar.relatedForms.isNotEmpty)
                          const SizedBox(height: 16),

                        // Synonyms & Antonyms
                        _buildRelationshipsCard(context),
                        const SizedBox(height: 16),

                        if (entry.linguistic.etymology.isNotEmpty)
                          _buildEtymologyCard(context, entry.linguistic),
                        if (entry.linguistic.etymology.isNotEmpty)
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

  // TRANSPARENT TOP APP BAR WITH FLOATING CIRCULAR BUTTONS
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
              // Recall / Quiz Mode Toggle Button
              _buildFloatingIconButton(
                context,
                icon: _isRecallMode ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash,
                iconColor: _isRecallMode ? AppColors.primaryPurple : null,
                onPressed: () {
                  setState(() {
                    _isRecallMode = !_isRecallMode;
                    _isMeaningRevealed = false;
                  });
                  HapticFeedback.selectionClick();
                },
              ),
              const SizedBox(width: 10),
              _buildFloatingIconButton(
                context,
                icon: isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                iconColor: isSaved ? Colors.green : null,
                onPressed: () => _toggleSaveWord(context, ref),
              ),
              const SizedBox(width: 10),
              _buildFloatingIconButton(
                context,
                icon: CupertinoIcons.share,
                onPressed: () => _showShareSheet(context),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Minimalist App Bar Icon Button without white circular background
  Widget _buildFloatingIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed, Color? iconColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        icon,
        color: iconColor ?? (isDark ? Colors.white : AppColors.textPrimary),
        size: 24,
      ),
      onPressed: onPressed,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                word.toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      color: headerTextColor,
                      height: 1.0,
                    ),
              ),
            ),
            if (widget.entry!.core.homograph > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${widget.entry!.core.homograph}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: headerTextColor),
                ),
              )
            ]
          ],
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
                          fontWeight: FontWeight.w800,
                          color: headerTextColor,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(width: 8),
                  // Audio Speaker Button
                  GestureDetector(
                    onTap: () => _playAudio(widget.entry!.core.audioUrl),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black38 : Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: _isPlaying 
                          ? const SizedBox(
                              width: 18, 
                              height: 18, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPurple)
                            )
                          : Icon(CupertinoIcons.speaker_2_fill, size: 18, color: headerTextColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Slow-Motion Audio Speed Toggle (1.0x / 0.75x)
                  GestureDetector(
                    onTap: _toggleAudioSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _audioSpeed == 0.75 
                            ? AppColors.primaryPurple 
                            : (isDark ? Colors.black26 : Colors.white.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_audioSpeed}x',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _audioSpeed == 0.75 ? Colors.white : headerTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  // HIGHLIGHTED "SIMPLE MEANING" CARD WITH RECALL MODE / SIMPLICITY
  Widget _buildSimpleMeaningCard(BuildContext context, String meaning) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final formattedMeaning = meaning.isNotEmpty
        ? (meaning.replaceFirst(meaning[0], meaning[0].toUpperCase()) + (meaning.endsWith('.') ? '' : '.'))
        : 'Vocabulary term';

    // If Recall/Quiz Mode is active and meaning is hidden
    if (_isRecallMode && !_isMeaningRevealed) {
      return GestureDetector(
        onTap: () {
          setState(() => _isMeaningRevealed = true);
          HapticFeedback.lightImpact();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primaryPurple, width: 2.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.eye_slash_fill, size: 20, color: AppColors.primaryPurple),
                  const SizedBox(width: 8),
                  Text(
                    'RECALL MODE ACTIVE',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryPurple,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Can you recall the meaning?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Tap to Reveal Answer 👁️',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
        borderRadius: BorderRadius.circular(28),
        border: isDark 
            ? Border.all(color: AppColors.darkSoftYellowText.withOpacity(0.4), width: 1.5) 
            : Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.lightbulb_fill,
                  size: 16,
                  color: isDark ? AppColors.darkSoftYellowText : AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SIMPLE MEANING',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.darkSoftYellowText : AppColors.primaryPurple,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formattedMeaning,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1.4,
              color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
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

  // SCROLLABLE "WORD ANATOMY" TO PREVENT COMPROMISING MULTI-SYLLABLE WORDS
  Widget _buildAnatomyCard(BuildContext context) {
    if (widget.entry == null || widget.entry!.core.syllables.length < 2) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final syllables = widget.entry!.core.syllables;

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
            border: isDark ? Border.all(color: textColor.withOpacity(0.3), width: 1.5) : null,
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
              fillColor: isDark ? Colors.white10 : AppColors.background,
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
                            color: theme.primaryColor.withOpacity(0.1),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final grammar = widget.entry!.grammar;

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
    final isDark = theme.brightness == Brightness.dark;
    final grammar = widget.entry!.grammar;

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
                  return InkWell(
                    onTap: () => _navigateToWord(context, syn),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark ? Border.all(color: AppColors.darkSoftBlueText.withOpacity(0.3)) : null,
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
                  return InkWell(
                    onTap: () => _navigateToWord(context, ant),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSoftPink : AppColors.softPeach,
                        borderRadius: BorderRadius.circular(16),
                        border: isDark ? Border.all(color: AppColors.darkSoftPinkText.withOpacity(0.3)) : null,
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
                color: isDark ? Colors.white10 : AppColors.background,
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
