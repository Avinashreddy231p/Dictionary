import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';

enum QuizQuestionType { meaning, context, synonym }

class QuizQuestion {
  final String word;
  final QuizQuestionType type;
  final String questionText;
  final String correctOption;
  final List<String> options;
  final String? contextSentence;

  QuizQuestion({
    required this.word,
    required this.type,
    required this.questionText,
    required this.correctOption,
    required this.options,
    this.contextSentence,
  });
}

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  List<QuizQuestion> _missedQuestions = [];
  int _questionIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _isInit = false;

  // Celebration Animation Controller
  late AnimationController _celebrationController;

  // Timer per question
  Timer? _timer;
  int _secondsRemaining = 15;
  static const int _maxSeconds = 15;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebrationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _maxSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining == 0) {
          _timer?.cancel();
          if (!_answered) {
            _answerQuestion('');
          }
        }
      }
    });
  }

  void _generateQuiz(List<SavedWord> savedWords, AppDatabase db) async {
    final random = Random();
    final List<QuizQuestion> generated = [];

    List<Map<String, String>> vocabPool = [];

    // 1. Gather saved words first
    for (final s in savedWords) {
      if (s.meaning != null && s.meaning!.isNotEmpty) {
        vocabPool.add({'word': s.word, 'meaning': s.meaning!});
      }
    }

    // 2. Supplement from offline SQLite dictionary
    if (vocabPool.length < 10) {
      try {
        final offlineWords = await (db.select(db.words)..limit(50)).get();
        for (final w in offlineWords) {
          if (w.simpleMeaning != null && w.simpleMeaning!.isNotEmpty) {
            vocabPool.add({'word': w.word, 'meaning': w.simpleMeaning!});
          }
        }
      } catch (_) {}
    }

    if (vocabPool.length < 4) {
      vocabPool = [
        {'word': 'reluctant', 'meaning': 'Unwilling and hesitant; disinclined.'},
        {'word': 'resilient', 'meaning': 'Able to withstand or recover quickly from difficult conditions.'},
        {'word': 'ephemeral', 'meaning': 'Lasting for a very short time.'},
        {'word': 'serene', 'meaning': 'Calm, peaceful, and untroubled; tranquil.'},
        {'word': 'eloquent', 'meaning': 'Fluent or persuasive in speaking or writing.'},
      ];
    }

    vocabPool.shuffle(random);
    final count = min(10, vocabPool.length);

    for (int i = 0; i < count; i++) {
      final target = vocabPool[i];
      final word = target['word']!;
      final meaning = target['meaning']!;

      final Set<String> distractorSet = {meaning};

      while (distractorSet.length < min(4, vocabPool.length)) {
        final rand = vocabPool[random.nextInt(vocabPool.length)];
        distractorSet.add(rand['meaning']!);
      }

      final optionsList = distractorSet.toList()..shuffle(random);

      generated.add(QuizQuestion(
        word: word,
        type: QuizQuestionType.meaning,
        questionText: 'WHAT IS THE DEFINITION OF',
        correctOption: meaning,
        options: optionsList,
      ));
    }

    if (mounted) {
      setState(() {
        _questions = generated;
        _missedQuestions = [];
        _isInit = true;
      });
      _startTimer();
    }
  }

  void _answerQuestion(String option) {
    if (_answered) return;

    _timer?.cancel();
    final current = _questions[_questionIndex];
    final isCorrect = option == current.correctOption;

    if (isCorrect) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
      _missedQuestions.add(current);
    }

    setState(() {
      _selectedOption = option;
      _answered = true;
      if (isCorrect) {
        _score += 10 + (_streak * 2);
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
      } else {
        _streak = 0;
      }
    });
  }

  void _nextQuestion() {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
        _answered = false;
      });
      _startTimer();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _questionIndex++; // Triggers summary
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final savedWordsAsync = ref.watch(savedWordsStreamProvider);
    final db = ref.watch(databaseProvider);

    final optionLabels = ['A', 'B', 'C', 'D'];

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
          if (!_isInit) {
            _generateQuiz(savedWords, db);
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          // Intriguing Gamified Quiz Summary Screen
          if (_questionIndex >= _questions.length) {
            final totalPossible = _questions.length * 10;
            final accuracy = ((_score / totalPossible) * 100).toInt().clamp(0, 100);
            final stars = (accuracy / 20).ceil().clamp(1, 5);

            Color rankColor = primaryColor;
            String rankTitle = 'VOCABULARY MASTER';
            String rankSubtitle = 'Legendary Performance!';

            if (accuracy >= 90) {
              rankColor = const Color(0xFFFFB800); // Gold
              rankTitle = 'LEGENDARY MASTERY 🏆';
              rankSubtitle = 'Flawless execution & vocabulary precision!';
            } else if (accuracy >= 70) {
              rankColor = const Color(0xFF10B981); // Emerald Green
              rankTitle = 'HIGH ACHIEVER 🌟';
              rankSubtitle = 'Great job! Outstanding vocabulary recall.';
            } else {
              rankColor = const Color(0xFF8B5CF6); // Purple
              rankTitle = 'LEARNING PRO 🎯';
              rankSubtitle = 'Solid effort! Practice makes perfect.';
            }

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Celebration Trophy Badge
                    AnimatedBuilder(
                      animation: _celebrationController,
                      builder: (context, child) {
                        final scale = 1.0 + (_celebrationController.value * 0.08);
                        return Transform.scale(
                          scale: scale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: rankColor.withOpacity(0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: rankColor.withOpacity(0.35),
                                      blurRadius: 32,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: rankColor,
                                ),
                                child: Icon(
                                  accuracy >= 80 ? Icons.emoji_events : CupertinoIcons.sparkles,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Rank Title & Subtitle Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: rankColor, width: 1.5),
                      ),
                      child: Text(
                        rankTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: rankColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      rankSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Star Rating Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            index < stars ? CupertinoIcons.star_fill : CupertinoIcons.star,
                            color: index < stars ? const Color(0xFFFFB800) : Colors.grey.shade600,
                            size: 26,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Playful Pastel Gamified Stat Cards Grid
                    Row(
                      children: [
                        // 1. Score Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2215) : const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFFFB800), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFB800).withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.bolt_fill, size: 12, color: Color(0xFFFFB800)),
                                      const SizedBox(width: 3),
                                      Text(
                                        'SCORE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? const Color(0xFFFFC107) : const Color(0xFFB78103),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$_score XP',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 2. Streak Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D1E16) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.orange, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🔥', style: TextStyle(fontSize: 11)),
                                      const SizedBox(width: 3),
                                      Text(
                                        'STREAK',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.orangeAccent : Colors.orange.shade800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$_maxStreak in row',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 3. Accuracy Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF16281E) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.green, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.scope, size: 12, color: Colors.green),
                                      const SizedBox(width: 3),
                                      Text(
                                        'ACCURACY',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.greenAccent : Colors.green.shade800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$accuracy%',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // "WHAT YOU MISSED" Section
                    if (_missedQuestions.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D191D) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.08),
                              blurRadius: 10,
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
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(CupertinoIcons.xmark, size: 12, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Words to Review (${_missedQuestions.length} Missed)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.redAccent,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ..._missedQuestions.map((q) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: InkWell(
                                  onTap: () => context.push('/word/${Uri.encodeComponent(q.word)}'),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              q.word.toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Study',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Icon(CupertinoIcons.chevron_right, size: 12, color: primaryColor),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '✓ ${q.correctOption}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade600,
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
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Words Mastered Chips Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181826) : const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.checkmark_seal_fill, size: 16, color: primaryColor),
                              const SizedBox(width: 8),
                              const Text('All Words Tested This Session', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _questions.map((q) {
                              final isMissed = _missedQuestions.contains(q);
                              return InkWell(
                                onTap: () => context.push('/word/${Uri.encodeComponent(q.word)}'),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF222238) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isMissed ? Colors.redAccent.withOpacity(0.4) : Colors.green.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(isMissed ? Icons.close : Icons.check, size: 12, color: isMissed ? Colors.redAccent : Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        q.word,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // CTA Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                              side: BorderSide(color: isDark ? Colors.white30 : AppColors.border, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              setState(() {
                                _questionIndex = 0;
                                _score = 0;
                                _streak = 0;
                                _maxStreak = 0;
                                _selectedOption = null;
                                _answered = false;
                                _generateQuiz(savedWords, db);
                              });
                            },
                            icon: const Icon(CupertinoIcons.refresh, size: 18),
                            label: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                            ),
                            onPressed: () => context.go('/flashcards'),
                            icon: const Icon(CupertinoIcons.rectangle_stack_fill, size: 18),
                            label: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
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
                // Header Score & Timer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_questionIndex + 1} of ${_questions.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        if (_streak > 1) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D1E16) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange, width: 1.2),
                            ),
                            child: Text(
                              '🔥 $_streak Streak',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: isDark ? Colors.orangeAccent : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF232338) : const Color(0xFFEEE8FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withOpacity(isDark ? 0.5 : 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⚡', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '$_score XP',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Countdown Timer Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _secondsRemaining / _maxSeconds,
                          minHeight: 8,
                          backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E2E8),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _secondsRemaining <= 4 ? Colors.redAccent : primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_secondsRemaining}s',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: _secondsRemaining <= 4 ? Colors.redAccent : (isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Hero Question Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          current.questionText.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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
                const SizedBox(height: 24),

                // Option Cards List with Option Letter Badges (A, B, C, D)
                Column(
                  children: current.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final label = index < optionLabels.length ? optionLabels[index] : '${index + 1}';

                    final isSelected = _selectedOption == option;
                    final isCorrect = option == current.correctOption;

                    Color cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
                    Color borderCol = isDark ? const Color(0xFF2C2C3F) : AppColors.border;
                    Color badgeBg = isDark ? const Color(0xFF2C2C3F) : const Color(0xFFF3EDFF);
                    Color badgeTextCol = primaryColor;

                    if (_answered) {
                      if (isCorrect) {
                        cardBg = Colors.green.withOpacity(0.18);
                        borderCol = Colors.green;
                        badgeBg = Colors.green;
                        badgeTextCol = Colors.white;
                      } else if (isSelected && !isCorrect) {
                        cardBg = Colors.redAccent.withOpacity(0.18);
                        borderCol = Colors.redAccent;
                        badgeBg = Colors.redAccent;
                        badgeTextCol = Colors.white;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _answerQuestion(option),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: borderCol, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: badgeTextCol,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
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
                              if (_answered) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  isCorrect
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : (isSelected ? CupertinoIcons.xmark_circle_fill : null),
                                  color: isCorrect ? Colors.green : Colors.redAccent,
                                  size: 22,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Post-Answer Actions (WordDetail Link & Next Button)
                if (_answered) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        context.push('/word/${Uri.encodeComponent(current.word)}');
                      },
                      icon: const Icon(CupertinoIcons.book_fill, size: 18),
                      label: Text(
                        'Study "${current.word}" in Word Detail',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                      ),
                      onPressed: _nextQuestion,
                      icon: const Icon(CupertinoIcons.arrow_right),
                      label: Text(
                        _questionIndex < _questions.length - 1 ? 'Next Question' : 'View Quiz Summary',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: primaryColor)),
        error: (e, __) => Center(child: Text('Error loading quiz: $e')),
      ),
    );
  }
}
