import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/providers.dart';
import '../../core/utils/pos_helper.dart';
import '../../theme/app_colors.dart';
import '../../data/models/lexical_entry.dart';
import '../collections/collection_detail_screen.dart';

const Set<String> _stopWords = {
  'a', 'about', 'above', 'after', 'again', 'against', 'all', 'am', 'an', 'and', 'any', 'are', 'aren\'t', 'as', 'at',
  'be', 'because', 'been', 'before', 'being', 'below', 'between', 'both', 'but', 'by', 'can\'t', 'cannot', 'could',
  'couldn\'t', 'did', 'didn\'t', 'do', 'does', 'doesn\'t', 'doing', 'don\'t', 'down', 'during', 'each', 'few', 'for',
  'from', 'further', 'had', 'hadn\'t', 'has', 'hasn\'t', 'have', 'haven\'t', 'having', 'he', 'he\'d', 'he\'ll', 'he\'s',
  'her', 'here', 'here\'s', 'hers', 'herself', 'him', 'himself', 'his', 'how', 'how\'s', 'i', 'i\'d', 'i\'ll', 'i\'m',
  'i\'ve', 'if', 'in', 'into', 'is', 'isn\'t', 'it', 'it\'s', 'its', 'itself', 'let\'s', 'me', 'more', 'most', 'mustn\'t',
  'my', 'myself', 'no', 'nor', 'not', 'of', 'off', 'on', 'once', 'only', 'or', 'other', 'ought', 'our', 'ours', 'ourselves',
  'out', 'over', 'own', 'same', 'shan\'t', 'she', 'she\'d', 'she\'ll', 'she\'s', 'should', 'shouldn\'t', 'so', 'some', 'such',
  'than', 'that', 'that\'s', 'the', 'their', 'theirs', 'them', 'themselves', 'then', 'there', 'there\'s', 'these', 'they',
  'they\'d', 'they\'ll', 'they\'re', 'they\'ve', 'this', 'those', 'through', 'to', 'too', 'under', 'until', 'up', 'very',
  'was', 'wasn\'t', 'we', 'we\'d', 'we\'ll', 'we\'re', 'we\'ve', 'were', 'weren\'t', 'what', 'what\'s', 'whatever', 'when',
  'when\'s', 'where', 'where\'s', 'which', 'while', 'who', 'who\'s', 'whom', 'why', 'why\'s', 'with', 'won\'t', 'would',
  'wouldn\'t', 'you', 'you\'d', 'you\'ll', 'you\'re', 'you\'ve', 'your', 'yours', 'yourself', 'yourselves'
};

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _showAddWordDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final exampleController = TextEditingController();
    final phoneticController = TextEditingController();

    String selectedPos = 'noun';
    final posOptions = ['noun', 'verb', 'adjective', 'adverb', 'preposition', 'conjunction', 'interjection', 'pronoun'];

    Timer? debounceTimer;
    LexicalEntry? livePreviewEntry;
    bool isSearchingPreview = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final rawInput = wordController.text.trim().toLowerCase();
            final isExactMatch = livePreviewEntry != null &&
                rawInput == livePreviewEntry!.core.headword.toLowerCase();

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                              child: Icon(CupertinoIcons.add_circled_solid, color: primaryColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Add Custom Word',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () {
                            debounceTimer?.cancel();
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: wordController,
                      autofocus: true,
                      onChanged: (val) {
                        final clean = val.trim().toLowerCase();
                        if (clean.isEmpty) {
                          setDialogState(() {
                            livePreviewEntry = null;
                            isSearchingPreview = false;
                          });
                          return;
                        }

                        debounceTimer?.cancel();
                        debounceTimer = Timer(const Duration(milliseconds: 300), () async {
                          setDialogState(() => isSearchingPreview = true);
                          final db = ref.read(databaseProvider);
                          var entry = await db.getOfflineWord(clean);

                          if (entry == null) {
                            try {
                              final repo = ref.read(wordRepositoryProvider);
                              final results = await repo.searchWord(clean);
                              if (results.isNotEmpty) {
                                entry = results.first;
                              }
                            } catch (_) {}
                          }

                          if (ctx.mounted) {
                            setDialogState(() {
                              livePreviewEntry = entry;
                              isSearchingPreview = false;
                            });
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Word',
                        hintText: 'e.g., ubiquitous, resilient',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        suffixIcon: isSearchingPreview
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                    ),

                    // Live Auto-Definition Preview Card
                    if (livePreviewEntry != null) ...[
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F1F32) : const Color(0xFFF3EDFF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isExactMatch ? Colors.green : primaryColor.withOpacity(0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isExactMatch ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.sparkles,
                                      size: 14,
                                      color: isExactMatch ? Colors.green : primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isExactMatch
                                          ? 'Exact Dictionary Match'
                                          : 'Similar Word: "${livePreviewEntry!.core.headword}"',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isExactMatch ? Colors.green : primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final def = livePreviewEntry!.senses.isNotEmpty
                                        ? livePreviewEntry!.senses.first.definition
                                        : 'Offline definition';
                                    meaningController.text = def;
                                    phoneticController.text = livePreviewEntry!.core.phonetic;
                                    selectedPos = formatPartOfSpeech(livePreviewEntry!.core.partOfSpeech);

                                    if (livePreviewEntry!.senses.isNotEmpty &&
                                        livePreviewEntry!.senses.first.examples.isNotEmpty) {
                                      exampleController.text = livePreviewEntry!.senses.first.examples.first;
                                    }
                                    setDialogState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Auto-Fill ✨',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${livePreviewEntry!.core.headword} • ${formatPartOfSpeech(livePreviewEntry!.core.partOfSpeech)} ${livePreviewEntry!.core.phonetic}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              livePreviewEntry!.senses.isNotEmpty
                                  ? livePreviewEntry!.senses.first.definition
                                  : 'Dictionary definition available',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Part of Speech Selector Chips
                    Text(
                      'Part of Speech',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: posOptions.map((pos) {
                          final isSelected = selectedPos == pos;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(
                                pos,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: primaryColor,
                              backgroundColor: isDark ? const Color(0xFF222234) : const Color(0xFFF3EDFF),
                              onSelected: (_) {
                                setDialogState(() => selectedPos = pos);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: meaningController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Definition',
                        hintText: 'Present, appearing, or found everywhere...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneticController,
                      decoration: InputDecoration(
                        labelText: 'IPA Phonetic Pronunciation (Optional)',
                        hintText: 'e.g., /yū-ˈbi-kwə-təs/',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: exampleController,
                      decoration: InputDecoration(
                        labelText: 'Example Sentence (Optional)',
                        hintText: 'e.g., Smart phones are ubiquitous in modern life.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                          final word = wordController.text.trim();
                          if (word.isNotEmpty) {
                            debounceTimer?.cancel();
                            Navigator.pop(ctx);
                            final db = ref.read(databaseProvider);

                            final def = meaningController.text.trim().isNotEmpty
                                ? meaningController.text.trim()
                                : (livePreviewEntry?.senses.isNotEmpty == true
                                    ? livePreviewEntry!.senses.first.definition
                                    : 'Custom saved word');

                            final ex = exampleController.text.trim().isNotEmpty
                                ? exampleController.text.trim()
                                : (livePreviewEntry?.senses.isNotEmpty == true && livePreviewEntry!.senses.first.examples.isNotEmpty
                                    ? livePreviewEntry!.senses.first.examples.first
                                    : null);

                            final ph = phoneticController.text.trim().isNotEmpty
                                ? phoneticController.text.trim()
                                : livePreviewEntry?.core.phonetic;

                            await db.saveWord(
                              word: word,
                              phonetic: ph,
                              partOfSpeech: selectedPos,
                              meaning: def,
                              example: ex,
                              source: 'Manual Add',
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Saved "$word" as $selectedPos to My Vocabulary!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                        label: const Text(
                          'Save Word',
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
      },
    );
  }

  void _showPasteTextDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final textController = TextEditingController();
    final titleController = TextEditingController(text: 'Pasted Excerpt');

    bool isAnalyzing = false;
    List<Map<String, String>> extractedCandidateWords = [];
    Set<String> selectedWords = {};
    final AudioPlayer audioPlayer = AudioPlayer();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final rawText = textController.text.trim();
            final wordCount = rawText.isEmpty
                ? 0
                : rawText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
            final readTimeMin = (wordCount / 180).ceil().clamp(1, 60);

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.doc_plaintext, color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Smart Reader & Vocab Extractor',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () {
                            audioPlayer.dispose();
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Collection Title Field
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Collection Name',
                        hintText: 'e.g., Science Article, Reading Excerpt',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header Row with Auto-Paste & TTS Reader Actions
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Article / Excerpt Text',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rawText.isNotEmpty) ...[
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(CupertinoIcons.speaker_2_fill, size: 18, color: primaryColor),
                            tooltip: 'Listen Excerpt',
                            onPressed: () async {
                              try {
                                final ttsUrl = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(rawText.substring(0, min(200, rawText.length)))}&tl=en';
                                await audioPlayer.setVolume(1.0);
                                await audioPlayer.setUrl(ttsUrl);
                                await audioPlayer.play();
                              } catch (_) {}
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          ),
                          onPressed: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data != null && data.text != null && data.text!.isNotEmpty) {
                              textController.text = data.text!;
                              setSheetState(() {});
                            }
                          },
                          icon: const Icon(CupertinoIcons.doc_on_clipboard_fill, size: 14),
                          label: const Text('Clipboard Auto-Paste', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: textController,
                      maxLines: 4,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Paste an article paragraph or excerpt here...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Text Metrics Stats Dashboard
                    if (rawText.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF3EDFF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: primaryColor.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('WORDS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryColor)),
                                const SizedBox(height: 4),
                                Text('$wordCount', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                              ],
                            ),
                            Container(width: 1, height: 24, color: primaryColor.withOpacity(0.2)),
                            Column(
                              children: [
                                Text('EST. READ TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryColor)),
                                const SizedBox(height: 4),
                                Text('~$readTimeMin min', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                              ],
                            ),
                            Container(width: 1, height: 24, color: primaryColor.withOpacity(0.2)),
                            Column(
                              children: [
                                Text('SOPHISTICATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryColor)),
                                const SizedBox(height: 4),
                                const Text('Academic C1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Candidate Words Pre-Save Checklist
                    if (extractedCandidateWords.isNotEmpty) ...[
                      Text(
                        'Select Words to Add (${selectedWords.length} Selected)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: SingleChildScrollView(
                          child: Column(
                            children: extractedCandidateWords.map((item) {
                              final word = item['word']!;
                              final meaning = item['meaning']!;
                              final isSelected = selectedWords.contains(word);

                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                title: Row(
                                  children: [
                                    Text(
                                      word.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: isSelected ? primaryColor : (isDark ? Colors.white : AppColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'C1 Academic',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  meaning,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textSecondary),
                                ),
                                onChanged: (val) {
                                  setSheetState(() {
                                    if (val == true) {
                                      selectedWords.add(word);
                                    } else {
                                      selectedWords.remove(word);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action Button (Analyze OR Save)
                    if (extractedCandidateWords.isEmpty) ...[
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
                          onPressed: rawText.isEmpty || isAnalyzing
                              ? null
                              : () async {
                                  setSheetState(() => isAnalyzing = true);
                                  final db = ref.read(databaseProvider);

                                  final candidates = rawText
                                      .replaceAll(RegExp(r'[^\w\s]'), '')
                                      .split(RegExp(r'\s+'))
                                      .where((w) => w.length > 3 && !_stopWords.contains(w.toLowerCase()))
                                      .map((w) => w.toLowerCase())
                                      .toSet()
                                      .take(10);

                                  List<Map<String, String>> resolved = [];
                                  for (var w in candidates) {
                                    final entry = await db.getOfflineWord(w);
                                    final meaning = entry?.senses.isNotEmpty == true
                                        ? entry!.senses.first.definition
                                        : 'Extracted term from reading excerpt';
                                    resolved.add({'word': w, 'meaning': meaning});
                                  }

                                  setSheetState(() {
                                    extractedCandidateWords = resolved;
                                    selectedWords = resolved.map((e) => e['word']!).toSet();
                                    isAnalyzing = false;
                                  });
                                },
                          icon: isAnalyzing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(CupertinoIcons.sparkles, size: 18),
                          label: Text(
                            isAnalyzing ? 'Analyzing Text...' : 'Analyze & Extract Vocabulary',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 2,
                          ),
                          onPressed: selectedWords.isEmpty
                              ? null
                              : () async {
                                  final title = titleController.text.trim().isNotEmpty
                                      ? titleController.text.trim()
                                      : 'Pasted Excerpt';

                                  audioPlayer.dispose();
                                  Navigator.pop(ctx);

                                  final db = ref.read(databaseProvider);
                                  final colId = await db.createCollection(
                                    title: title,
                                    description: rawText.length > 80 ? '${rawText.substring(0, 80)}...' : rawText,
                                    colorHex: '0xFF8B5CF6',
                                  );

                                  for (var item in extractedCandidateWords) {
                                    final w = item['word']!;
                                    if (selectedWords.contains(w)) {
                                      final savedId = await db.saveWord(
                                        word: w,
                                        meaning: item['meaning']!,
                                        contextSentence: rawText,
                                        source: title,
                                      );
                                      await db.addWordToCollection(colId, savedId);
                                    }
                                  }

                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CollectionDetailScreen(
                                          collectionId: colId,
                                          title: title,
                                          description: rawText,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                          label: Text(
                            'Save Collection (${selectedWords.length} Words)',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
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
              _buildIndexingProgressSection(context),
              const SizedBox(height: 20),
              _buildWordOfTheDay(context),
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dictionary',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Understand every word.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildIndexingProgressSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final indexingState = ref.watch(indexingProgressProvider);
    final countAsync = ref.watch(offlineWordsCountStreamProvider);
    final dbCount = countAsync.value ?? 0;
    final currentCount = indexingState.count > dbCount
        ? indexingState.count
        : (dbCount > 0 ? dbCount : indexingState.count);

    final isDone = currentCount >= 100000 || (indexingState.progress >= 0.99 && !indexingState.isIndexing);

    // Hide section from HomeScreen when indexing is complete or not actively running
    if (isDone || (!indexingState.isIndexing && currentCount > 10000)) {
      return const SizedBox.shrink();
    }

    final progressVal = (indexingState.progress > 0 ? indexingState.progress : (currentCount / 100000.0)).clamp(0.02, 1.0);
    final percentText = '${(progressVal * 100).toInt()}%';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF3EDFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
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
                  color: theme.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indexing Offline Dictionary (14.5 MB)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Preparing pre-indexed Offline Dictionary Database...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percentText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Indexed: $currentCount / ~100,000 words',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              Text(
                'Active in background',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordOfTheDay(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final wotdAsync = ref.watch(wordOfTheDayProvider);

    return wotdAsync.when(
      data: (entry) {
        if (entry == null) return const SizedBox.shrink();

        final headword = entry.core.headword;
        final pos = entry.core.partOfSpeech;
        final phonetic = entry.core.phonetic;
        final meaning = entry.senses.isNotEmpty ? entry.senses.first.definition : entry.dictionaryLayer.simpleMeaning;
        final example = entry.senses.isNotEmpty && entry.senses.first.examples.isNotEmpty
            ? entry.senses.first.examples.first
            : entry.dictionaryLayer.contextualMeaning;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF231E3D), const Color(0xFF1B192E)]
                  : [const Color(0xFFEFE8FF), const Color(0xFFE3D8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              context.push('/word/$headword', extra: entry);
            },
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.calendar_today, size: 16, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'WORD OF THE DAY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pos,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    headword,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (phonetic.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      phonetic,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (example.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"$example"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
              'Flashcards',
              CupertinoIcons.rectangle_stack_fill,
              isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
              isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
              onTap: () => context.push('/flashcards'),
            ),
            _buildActionCard(
              context,
              'Quiz Mode',
              CupertinoIcons.bolt_fill,
              isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
              isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
              onTap: () => context.push('/quiz'),
            ),
            _buildActionCard(
              context,
              'Paste Text',
              CupertinoIcons.doc_on_clipboard,
              isDark ? AppColors.darkSoftGreen : AppColors.softGreen,
              isDark ? AppColors.darkSoftGreenText : AppColors.textPrimary,
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
                    dictionaryLayer: DictionaryLayer(
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
