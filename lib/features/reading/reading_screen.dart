import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../data/services/file_import_service.dart';
import '../../theme/app_colors.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  String _documentTitle = 'The Great Gatsby - Chapter 3';
  String _readingText =
      'There was music from my neighbor\'s house through the summer nights. In his blue gardens men and girls came and went like moths among the whisperings and the champagne and the stars. At high tide in the afternoon I watched his guests diving from the tower of his raft, or sunburned on the hot sand of his beach while his two motor-boats slit the waters of the Sound, drawing aquaplanes over cataracts of foam. On week-ends his Rolls-Royce became an omnibus, bearing parties to and from the city between eight o\'clock on Friday morning and midnight on Monday. And on Mondays eight servants, including an extra gardener, toiled all day with mops and scrubbing-brushes and hammers and garden-shears, repairing the ravages of the night before.';

  double _fontSize = 17.0;
  bool _useSerif = true;
  String _selectedWord = '';

  final samplePassages = <String, String>{
    'The Great Gatsby':
        'There was music from my neighbor\'s house through the summer nights. In his blue gardens men and girls came and went like moths among the whisperings and the champagne and the stars.',
    'Pride and Prejudice':
        'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife. However little known the feelings or views of such a man may be on his first entering a neighbourhood.',
    'Scientific Excerpt':
        'Neural networks are computing systems inspired by the biological neural networks that constitute animal brains. An ANN is based on a collection of connected units or nodes called artificial neurons.',
  };

  void _importDocumentFromFile() async {
    final result = await FileImportService.pickAndReadDocumentFile();
    if (result != null && result.content.isNotEmpty) {
      setState(() {
        _documentTitle = result.fileName;
        _readingText = result.content;
      });
      _showFeedback('Successfully imported "${result.fileName}"');
    }
  }

  void _showPasteTextDialog() {
    final titleController = TextEditingController(text: 'Imported Reading Passage');
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Paste Text / Article', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Document Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Paste article, book chapter, or excerpt text here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data != null && data.text != null) {
                  textController.text = data.text!;
                }
              },
              icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
              label: const Text('Paste from Clipboard'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _documentTitle = titleController.text.trim().isEmpty ? 'Pasted Passage' : titleController.text.trim();
                  _readingText = text;
                });
                Navigator.pop(ctx);
                _showFeedback('Document text loaded into reader');
              }
            },
            child: const Text('Load into Reader'),
          ),
        ],
      ),
    );
  }

  void _showWordLookupSheet(String word, String contextSentence) async {
    final cleanWord = word.replaceAll(RegExp(r'[^\w-]'), '').trim();
    if (cleanWord.length < 2) return;

    setState(() {
      _selectedWord = cleanWord;
    });

    final repo = ref.read(dictionaryRepositoryProvider);
    final result = await repo.searchWord(cleanWord);

    if (!mounted) return;

    final entry = result.entries.isNotEmpty ? result.entries.first : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final primaryColor = theme.primaryColor;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleanWord.toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: primaryColor,
                          ),
                        ),
                        if (entry != null && entry.core.phonetic.isNotEmpty)
                          Text(
                            entry.core.phonetic,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                Text(
                  'Definition:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry != null
                      ? entry.dictionaryLayer.simpleMeaning
                      : 'Definition lookup active for "$cleanWord"',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),

                if (contextSentence.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Captured Context Sentence:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '"$contextSentence"',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white.withValues(alpha: 0.87) : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          await db.saveWord(
                            word: cleanWord,
                            phonetic: entry?.core.phonetic,
                            partOfSpeech: entry?.core.partOfSpeech ?? 'word',
                            meaning: entry?.dictionaryLayer.simpleMeaning ?? 'Saved from reading',
                            contextSentence: contextSentence,
                            source: _documentTitle,
                          );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            _showFeedback('Saved "$cleanWord" to vocabulary!');
                          }
                        },
                        icon: const Icon(CupertinoIcons.bookmark_fill, size: 18),
                        label: const Text('Save Word & Context', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/word/$cleanWord', extra: entry);
                      },
                      child: const Text('Full View'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Widget> _buildInteractiveTextWidgets(bool isDark, Color primaryColor) {
    final sentences = _readingText.split(RegExp(r'(?<=[.!?])\s+'));
    final List<Widget> widgets = [];

    for (final sentence in sentences) {
      final words = sentence.split(RegExp(r'\s+'));
      for (final wordStr in words) {
        final cleanWord = wordStr.replaceAll(RegExp(r'[^\w-]'), '').toLowerCase();
        final isSelected = _selectedWord.isNotEmpty && cleanWord == _selectedWord;

        widgets.add(
          GestureDetector(
            onTap: () => _showWordLookupSheet(wordStr, sentence),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withValues(alpha: 0.25) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$wordStr ',
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 1.6,
                  fontFamily: _useSerif ? 'Georgia' : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF2C2C3E)),
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(_documentTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.folder_badge_plus),
            tooltip: 'Import Book File',
            onPressed: _importDocumentFromFile,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.doc_on_clipboard),
            tooltip: 'Paste Text',
            onPressed: _showPasteTextDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Reader Control Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: isDark ? const Color(0xFF191926) : const Color(0xFFF5F5FA),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.minus, size: 16),
                        onPressed: () {
                          if (_fontSize > 13) setState(() => _fontSize -= 1);
                        },
                      ),
                      Text(
                        '${_fontSize.toInt()} pt',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.plus, size: 16),
                        onPressed: () {
                          if (_fontSize < 28) setState(() => _fontSize += 1);
                        },
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Serif', style: TextStyle(fontSize: 11)),
                        selected: _useSerif,
                        onSelected: (val) => setState(() => _useSerif = true),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Sans', style: TextStyle(fontSize: 11)),
                        selected: !_useSerif,
                        onSelected: (val) => setState(() => _useSerif = false),
                      ),
                    ],
                  ),

                  PopupMenuButton<String>(
                    icon: const Icon(CupertinoIcons.book, size: 20),
                    tooltip: 'Sample Passages',
                    onSelected: (key) {
                      if (samplePassages.containsKey(key)) {
                        setState(() {
                          _documentTitle = key;
                          _readingText = samplePassages[key]!;
                        });
                      }
                    },
                    itemBuilder: (context) => samplePassages.keys
                        .map((title) => PopupMenuItem(
                              value: title,
                              child: Text(title, style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Interactive Text Reader Surface
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  children: _buildInteractiveTextWidgets(isDark, primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
