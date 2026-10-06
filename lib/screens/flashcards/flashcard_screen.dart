import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _currentIndex = 0;
  bool _isFront = true;
  int _masteredCount = 0;
  int _reviewCount = 0;

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
    super.dispose();
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

  void _onSwipe(bool mastered, List<SavedWord> words) async {
    if (words.isEmpty || _currentIndex >= words.length) return;

    final currentWord = words[_currentIndex];
    final db = ref.read(databaseProvider);

    if (mastered) {
      await db.updateReviewState(currentWord.id, 2); // Mastered
      setState(() => _masteredCount++);
    } else {
      await db.updateReviewState(currentWord.id, 1); // Review Needed
      setState(() => _reviewCount++);
    }

    if (!_isFront) {
      _flipController.reverse();
      _isFront = true;
    }

    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                        size: 64, color: theme.primaryColor.withOpacity(0.5)),
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
                        backgroundColor: theme.primaryColor,
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
                          icon: const Icon(CupertinoIcons.bolt_fill),
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
                        color: theme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${((_currentIndex / savedWords.length) * 100).toInt()}% Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: theme.primaryColor,
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
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
                const SizedBox(height: 32),

                // 3D Flip Card Container
                Expanded(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final angle = _flipAnimation.value * pi;
                        final isFrontVisible = angle < pi / 2;

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          alignment: Alignment.center,
                          child: isFrontVisible
                              ? _buildCardFront(context, currentWord, isDark)
                              : Transform(
                                  transform: Matrix4.identity()..rotateY(pi),
                                  alignment: Alignment.center,
                                  child: _buildCardBack(context, currentWord, isDark),
                                ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.15),
                          foregroundColor: Colors.redAccent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => _onSwipe(false, savedWords),
                        icon: const Icon(CupertinoIcons.xmark_circle_fill),
                        label: const Text(
                          'Needs Review',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.15),
                          foregroundColor: Colors.green,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => _onSwipe(true, savedWords),
                        icon: const Icon(CupertinoIcons.checkmark_circle_fill),
                        label: const Text(
                          'Mastered',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (e, __) => Center(child: Text('Error loading flashcards: $e')),
      ),
    );
  }

  Widget _buildCardFront(BuildContext context, SavedWord word, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 2),
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
              color: theme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.partOfSpeech?.toUpperCase() ?? 'VOCABULARY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: theme.primaryColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            word.word,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (word.phonetic != null && word.phonetic!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.phonetic!,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.hand_draw, size: 18, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Tap card to reveal definition',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, SavedWord word, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232338) : const Color(0xFFF3EDFF),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(isDark ? 0.3 : 0.12),
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
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            word.meaning ?? 'No definition available.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          if (word.example != null && word.example!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'EXAMPLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: theme.primaryColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${word.example}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
