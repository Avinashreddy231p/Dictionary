import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

class QuizQuestion {
  final String word;
  final String correctMeaning;
  final List<String> options;

  QuizQuestion({
    required this.word,
    required this.correctMeaning,
    required this.options,
  });
}

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _questionIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _isInit = false;

  void _generateQuiz(List<SavedWord> savedWords) {
    if (savedWords.length < 2) return;

    final random = Random();
    final List<QuizQuestion> generated = [];

    final shuffledWords = List<SavedWord>.from(savedWords)..shuffle(random);
    final count = min(10, shuffledWords.length);

    for (int i = 0; i < count; i++) {
      final target = shuffledWords[i];
      final targetMeaning = target.meaning ?? 'Vocabulary word';

      final Set<String> optionsSet = {targetMeaning};

      while (optionsSet.length < min(4, savedWords.length)) {
        final randWord = savedWords[random.nextInt(savedWords.length)];
        final randMeaning = randWord.meaning ?? 'Option definition';
        optionsSet.add(randMeaning);
      }

      final optionsList = optionsSet.toList()..shuffle(random);

      generated.add(QuizQuestion(
        word: target.word,
        correctMeaning: targetMeaning,
        options: optionsList,
      ));
    }

    setState(() {
      _questions = generated;
      _isInit = true;
    });
  }

  void _answerQuestion(String option) {
    if (_answered) return;

    final current = _questions[_questionIndex];
    final isCorrect = option == current.correctMeaning;

    setState(() {
      _selectedOption = option;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      setState(() {
        _questionIndex++; // Triggers summary
      });
    }
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
        title: const Text('Vocabulary Quiz'),
      ),
      body: savedWordsAsync.when(
        data: (savedWords) {
          if (savedWords.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.bolt_badge_a_fill,
                        size: 64, color: theme.primaryColor.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Need at least 2 saved words for quiz',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save a few more words to unlock multiple choice quizzes!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

          if (!_isInit) {
            _generateQuiz(savedWords);
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }

          // Quiz Summary Screen
          if (_questionIndex >= _questions.length) {
            final percentage = ((_score / _questions.length) * 100).toInt();

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        percentage >= 70 ? CupertinoIcons.sparkles : CupertinoIcons.flag_fill,
                        size: 64,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      percentage >= 70 ? 'Great Job! 🎯' : 'Keep Practicing! 💪',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You scored $_score / ${_questions.length} ($percentage%)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _questionIndex = 0;
                              _score = 0;
                              _selectedOption = null;
                              _answered = false;
                              _generateQuiz(savedWords);
                            });
                          },
                          icon: const Icon(CupertinoIcons.refresh),
                          label: const Text('Play Again'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () => context.go('/flashcards'),
                          icon: const Icon(CupertinoIcons.rectangle_stack_fill),
                          label: const Text('Flashcards'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          final current = _questions[_questionIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_questionIndex + 1} of ${_questions.length}',
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
                        'Score: $_score',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
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
                    value: (_questionIndex + 1) / _questions.length,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
                const SizedBox(height: 32),

                // Question Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'WHAT IS THE MEANING OF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        current.word.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Options List
                Column(
                  children: current.options.map((option) {
                    final isSelected = _selectedOption == option;
                    final isCorrect = option == current.correctMeaning;

                    Color cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
                    Color borderCol = isDark ? const Color(0xFF2C2C3F) : AppColors.border;

                    if (_answered) {
                      if (isCorrect) {
                        cardBg = Colors.green.withOpacity(0.15);
                        borderCol = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        cardBg = Colors.redAccent.withOpacity(0.15);
                        borderCol = Colors.redAccent;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _answerQuestion(option),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderCol, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_answered)
                                Icon(
                                  isCorrect
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : (isSelected ? CupertinoIcons.xmark_circle_fill : null),
                                  color: isCorrect ? Colors.green : Colors.redAccent,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (_answered) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _nextQuestion,
                      icon: const Icon(CupertinoIcons.arrow_right),
                      label: Text(
                        _questionIndex < _questions.length - 1 ? 'Next Question' : 'View Results',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (e, __) => Center(child: Text('Error loading quiz: $e')),
      ),
    );
  }
}
