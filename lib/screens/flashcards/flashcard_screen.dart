import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/utils/pos_helper.dart';
import '../../theme/app_colors.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _currentIndex = 0;
  bool _isFront = true;
  bool _isPlayingAudio = false;
  int _masteredCount = 0;
  int _reviewCount = 0;

  // Pan Gesture Swiping Offsets
  double _dragDx = 0.0;
  double _dragDy = 0.0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playWordAudio(String word) async {
    setState(() => _isPlayingAudio = true);
    try {
      final ttsUrl = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(word)}&tl=en';
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setUrl(ttsUrl);
      await _audioPlayer.play();
    } catch (_) {}
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _onSwipeLeft(List<SavedWord> words) async {
    if (words.isEmpty || _currentIndex >= words.length) return;
    HapticFeedback.mediumImpact();

    final currentWord = words[_currentIndex];
    final db = ref.read(databaseProvider);

    await db.updateReviewState(currentWord.id, 1); // Need Review
    setState(() => _reviewCount++);

    _resetCardStateAndAdvance();
  }

  void _onSwipeRight(List<SavedWord> words) async {
    if (words.isEmpty || _currentIndex >= words.length) return;
    HapticFeedback.heavyImpact();

    final currentWord = words[_currentIndex];
    final db = ref.read(databaseProvider);

    await db.updateReviewState(currentWord.id, 2); // Mastered
    setState(() => _masteredCount++);

    _resetCardStateAndAdvance();
  }

  void _onSwipeDown(List<SavedWord> words) {
    if (words.isEmpty || _currentIndex >= words.length) return;
    HapticFeedback.mediumImpact();

    final currentWord = words[_currentIndex];
    _showAddToCollectionBottomSheet(context, currentWord);

    setState(() {
      _dragDx = 0;
      _dragDy = 0;
    });
  }

  void _onSwipeUp(List<SavedWord> words) {
    if (words.isEmpty || _currentIndex >= words.length) return;
    HapticFeedback.lightImpact();
    _resetCardStateAndAdvance();
  }

  void _resetCardStateAndAdvance() {
    if (!_isFront) {
      _flipController.reverse();
      _isFront = true;
    }
    setState(() {
      _dragDx = 0;
      _dragDy = 0;
      _currentIndex++;
    });
  }

  void _showAddToCollectionBottomSheet(BuildContext context, SavedWord word) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final collectionsAsync = ref.watch(userCollectionsStreamProvider);

    final Set<int> addedCollectionIds = {};

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
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Add "${word.word}" to Collections',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.50,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: collectionsAsync.when(
                          data: (collections) {
                            if (collections.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    const Text('No collections created yet.'),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        context.push('/collections');
                                      },
                                      icon: const Icon(CupertinoIcons.add),
                                      label: const Text('Create New Collection'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: collections.map((col) {
                                final isAdded = addedCollectionIds.contains(col.id);

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isAdded ? Colors.green.withOpacity(0.15) : primaryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isAdded ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.folder_fill,
                                      color: isAdded ? Colors.green : primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    col.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: isAdded ? Colors.green.shade700 : (isDark ? Colors.white : AppColors.textPrimary),
                                    ),
                                  ),
                                  subtitle: Text(
                                    col.description ?? 'Vocabulary collection',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                                    ),
                                  ),
                                  trailing: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isAdded ? Colors.green : primaryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isAdded ? CupertinoIcons.checkmark_alt : CupertinoIcons.add,
                                          size: 14,
                                          color: isAdded ? Colors.white : primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isAdded ? 'Added' : 'Add',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isAdded ? Colors.white : primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    final db = ref.read(databaseProvider);
                                    await db.addWordToCollection(col.id, word.id);
                                    HapticFeedback.selectionClick();
                                    setSheetState(() {
                                      addedCollectionIds.add(col.id);
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Text('Error loading collections'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          addedCollectionIds.isNotEmpty
                              ? 'Done (${addedCollectionIds.length} Added)'
                              : 'Done',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final savedWordsAsync = ref.watch(savedWordsStreamProvider);

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
        title: const Text('Spaced Repetition Flashcards'),
      ),
      body: savedWordsAsync.when(
        data: (savedWords) {
          if (savedWords.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.rectangle_stack_badge_minus,
                        size: 64, color: primaryColor.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No saved words for flashcards yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save words from dictionary search or collections to start learning with flashcards!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      onPressed: () => context.go('/home/search'),
                      icon: const Icon(CupertinoIcons.search, size: 18),
                      label: const Text('Search & Save Words'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_currentIndex >= savedWords.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.checkmark_seal_fill,
                        size: 72, color: Colors.green.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Session Complete! 🎉',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mastered: $_masteredCount words  •  Needs Review: $_reviewCount words',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentIndex = 0;
                              _masteredCount = 0;
                              _reviewCount = 0;
                            });
                          },
                          icon: const Icon(CupertinoIcons.refresh),
                          label: const Text('Restart Deck'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () => context.go('/quiz'),
                          icon: const Icon(CupertinoIcons.question_circle_fill),
                          label: const Text('Take Quiz'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          final currentWord = savedWords[_currentIndex];

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card ${_currentIndex + 1} of ${savedWords.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${((_currentIndex / savedWords.length) * 100).toInt()}% Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / savedWords.length,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                const SizedBox(height: 24),

                // 3D Flip Card Container with Pan Gesture Swiping
                Expanded(
                  child: GestureDetector(
                    onTap: _flipCard,
                    onPanUpdate: (details) {
                      setState(() {
                        _dragDx += details.delta.dx;
                        _dragDy += details.delta.dy;
                      });
                    },
                    onPanEnd: (details) {
                      if (_dragDx < -90) {
                        _onSwipeLeft(savedWords);
                      } else if (_dragDx > 90) {
                        _onSwipeRight(savedWords);
                      } else if (_dragDy > 90 && _dragDx.abs() < 50) {
                        _onSwipeDown(savedWords);
                      } else if (_dragDy < -90 && _dragDx.abs() < 50) {
                        _onSwipeUp(savedWords);
                      } else {
                        setState(() {
                          _dragDx = 0;
                          _dragDy = 0;
                        });
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final angle = _flipAnimation.value * pi;
                        final isFrontVisible = angle < pi / 2;

                        return Transform.translate(
                          offset: Offset(_dragDx * 0.6, _dragDy * 0.6),
                          child: Transform.rotate(
                            angle: _dragDx * 0.001,
                            child: Stack(
                              children: [
                                Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(angle),
                                  alignment: Alignment.center,
                                  child: isFrontVisible
                                      ? _buildCardFront(context, currentWord, isDark, primaryColor)
                                      : Transform(
                                          transform: Matrix4.identity()..rotateY(pi),
                                          alignment: Alignment.center,
                                          child: _buildCardBack(context, currentWord, isDark, primaryColor),
                                        ),
                                ),

                                // Visual Drag Overlay Badges
                                if (_dragDx < -40)
                                  Positioned(
                                    top: 30,
                                    right: 30,
                                    child: _buildSwipeBadge('NEED REVIEW', Colors.redAccent),
                                  ),
                                if (_dragDx > 40)
                                  Positioned(
                                    top: 30,
                                    left: 30,
                                    child: _buildSwipeBadge('MASTERED', Colors.green),
                                  ),
                                if (_dragDy > 40 && _dragDx.abs() < 40)
                                  Positioned(
                                    top: 30,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: _buildSwipeBadge('ADD TO COLLECTION', primaryColor),
                                    ),
                                  ),
                                if (_dragDy < -40 && _dragDx.abs() < 40)
                                  Positioned(
                                    bottom: 30,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: _buildSwipeBadge('SKIP CARD', Colors.grey.shade700),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Action Buttons (Left: Review, Bottom: Collection, Right: Mastered)
                Row(
                  children: [
                    // Left: Needs Review
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.15),
                          foregroundColor: Colors.redAccent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () => _onSwipeLeft(savedWords),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Review',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bottom/Middle: Collection
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.15),
                          foregroundColor: primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () => _onSwipeDown(savedWords),
                        icon: const Icon(CupertinoIcons.folder_badge_plus, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Collection',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Right: Mastered
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.15),
                          foregroundColor: Colors.green,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () => _onSwipeRight(savedWords),
                        icon: const Icon(CupertinoIcons.checkmark_circle_fill, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Mastered',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: primaryColor)),
        error: (e, __) => Center(child: Text('Error loading flashcards: $e')),
      ),
    );
  }

  Widget _buildSwipeBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCardFront(BuildContext context, SavedWord word, bool isDark, Color primaryColor) {
    final theme = Theme.of(context);

    // Compute Syllable Spelling Breakdown e.g. re · luc · tant
    final wordText = word.word;
    final List<String> syllables = wordText.length > 4
        ? [
            wordText.substring(0, (wordText.length / 3).floor()),
            wordText.substring((wordText.length / 3).floor(), (2 * wordText.length / 3).floor()),
            wordText.substring((2 * wordText.length / 3).floor())
          ]
        : [wordText];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: primaryColor.withOpacity(0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              formatPartOfSpeech(word.partOfSpeech).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            word.word.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Phonetic & Native Listen Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (word.phonetic != null && word.phonetic!.isNotEmpty)
                Text(
                  word.phonetic!,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _playWordAudio(word.word),
                icon: _isPlayingAudio
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(CupertinoIcons.speaker_2_fill, size: 20, color: primaryColor),
                tooltip: 'Listen Pronunciation',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Syllables Spelling Breakdown Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2B2B40) : const Color(0xFFF3EDFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Text(
                  'SPELLING & SYLLABLES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: syllables.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        s.toLowerCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.arrow_2_squarepath, size: 14, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  'Tap card to flip & reveal meaning',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, SavedWord word, bool isDark, Color primaryColor) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232338) : const Color(0xFFF3EDFF),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isDark ? 0.3 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DEFINITION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            word.meaning ?? 'No definition available.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          if (word.example != null && word.example!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'EXAMPLE SENTENCE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: primaryColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"${word.example}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Deep Study Link Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              context.push('/word/${Uri.encodeComponent(word.word)}');
            },
            icon: const Icon(CupertinoIcons.book_fill, size: 16),
            label: const Text(
              'Study in Word Detail',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
