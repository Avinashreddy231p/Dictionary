import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../data/models/lexical_entry.dart';
import '../../theme/app_colors.dart';

enum StatsTimeFilter { week, month, allTime }

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsTimeFilter _selectedFilter = StatsTimeFilter.week;
  final ScrollController _chartScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToEnd();
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chartScrollController.hasClients) {
        _chartScrollController.animateTo(
          _chartScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  List<SavedWord> _getFilteredWords(List<SavedWord> allWords) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case StatsTimeFilter.week:
        return allWords.where((w) => now.difference(w.dateAdded).inDays <= 14).toList();
      case StatsTimeFilter.month:
        return allWords.where((w) => now.difference(w.dateAdded).inDays <= 30).toList();
      case StatsTimeFilter.allTime:
        return allWords;
    }
  }

  int _calculateStreak(List<SavedWord> allWords) {
    if (allWords.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Set<DateTime> activeDates = {};

    for (final w in allWords) {
      activeDates.add(DateTime(w.dateAdded.year, w.dateAdded.month, w.dateAdded.day));
    }

    int streak = 0;
    DateTime checkDate = today;
    if (!activeDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (activeDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  LexicalEntry _lexicalEntryFromSavedWord(SavedWord saved) {
    return LexicalEntry(
      core: CoreData(
        headword: saved.word,
        homograph: 0,
        partOfSpeech: saved.partOfSpeech ?? 'noun',
        phonetic: saved.phonetic ?? '',
        audioUrl: '',
        syllables: (saved.syllables ?? saved.word).split('*'),
      ),
      senses: [
        Sense(
          senseNumber: '1',
          definition: saved.meaning ?? 'No definition available',
          examples: saved.example != null && saved.example!.isNotEmpty ? [saved.example!] : [],
          labels: [],
        )
      ],
      grammar: GrammarData(verbDivision: '', usageNotes: [], inflections: [], relatedForms: []),
      linguistic: LinguisticData(etymology: '', firstKnownUse: ''),
      lexiLens: LexiLensLayer(
        simpleMeaning: saved.meaning ?? 'No definition available',
        contextualMeaning: saved.contextSentence ?? '',
        synonyms: [],
        antonyms: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final settings = ref.watch(settingsProvider);

    final savedWordsAsync = ref.watch(savedWordsStreamProvider);
    final todayWordsAsync = ref.watch(todaySavedWordsStreamProvider);
    final masteredWordsAsync = ref.watch(masteredWordsStreamProvider);
    final needsReviewAsync = ref.watch(needsReviewStreamProvider);

    final allWords = savedWordsAsync.asData?.value ?? [];
    final todayWords = todayWordsAsync.asData?.value ?? [];
    final masteredWords = masteredWordsAsync.asData?.value ?? [];
    final needsReviewWords = needsReviewAsync.asData?.value ?? [];

    final filteredWords = _getFilteredWords(allWords);
    final streakDays = _calculateStreak(allWords);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Learning Analytics'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, primaryColor),
              const SizedBox(height: 20),
              _buildTimeFilterSelector(context, primaryColor, isDark),
              const SizedBox(height: 24),
              _buildOverviewGrid(
                context,
                primaryColor,
                isDark,
                totalSaved: filteredWords.length,
                todayCount: todayWords.length,
                dailyGoal: settings.dailyGoal,
                masteredCount: masteredWords.length,
                streakDays: streakDays,
              ),
              const SizedBox(height: 28),
              _buildSectionTitle(
                context,
                _selectedFilter == StatsTimeFilter.week
                    ? '14-Day Vocabulary Trend'
                    : (_selectedFilter == StatsTimeFilter.month
                        ? '30-Day Growth Scroll'
                        : '12-Month Historical Growth'),
                CupertinoIcons.graph_square_fill,
                primaryColor,
              ),
              const SizedBox(height: 12),
              _buildScrollableGrowthChartCard(context, filteredWords, settings.dailyGoal, primaryColor, isDark),
              const SizedBox(height: 28),
              _buildSectionTitle(context, 'CEFR Proficiency Breakdown', CupertinoIcons.chart_pie_fill, primaryColor),
              const SizedBox(height: 12),
              _buildCefrBreakdownCard(context, filteredWords, primaryColor, isDark),
              const SizedBox(height: 28),
              _buildSectionTitle(context, 'Learning Stage Lifecycle', CupertinoIcons.layers_fill, primaryColor),
              const SizedBox(height: 12),
              _buildStageDistributionCard(
                context,
                total: filteredWords.length,
                learning: filteredWords.length - masteredWords.length - needsReviewWords.length,
                inReview: needsReviewWords.length,
                mastered: masteredWords.length,
                primaryColor: primaryColor,
                isDark: isDark,
              ),
              const SizedBox(height: 28),
              _buildSectionTitle(context, 'Parts of Speech Breakdown', CupertinoIcons.textformat_abc, primaryColor),
              const SizedBox(height: 12),
              _buildPartsOfSpeechCard(context, filteredWords, primaryColor, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-time Analytics',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                height: 1.1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your vocabulary velocity, mastery, and daily habits.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildTimeFilterSelector(BuildContext context, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkTileBg : AppColors.softPurple.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          _buildFilterButton(context, label: '14 Days', filter: StatsTimeFilter.week, primaryColor: primaryColor, isDark: isDark),
          _buildFilterButton(context, label: '30 Days', filter: StatsTimeFilter.month, primaryColor: primaryColor, isDark: isDark),
          _buildFilterButton(context, label: '12 Months', filter: StatsTimeFilter.allTime, primaryColor: primaryColor, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required StatsTimeFilter filter,
    required Color primaryColor,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
          _scrollToEnd();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildOverviewGrid(
    BuildContext context,
    Color primaryColor,
    bool isDark, {
    required int totalSaved,
    required int todayCount,
    required int dailyGoal,
    required int masteredCount,
    required int streakDays,
  }) {
    final percentGoal = ((todayCount / dailyGoal) * 100).round();
    final masteryRate = totalSaved == 0 ? 0 : ((masteredCount / totalSaved) * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Filtered Words',
                value: '$totalSaved Words',
                subtitle: _selectedFilter == StatsTimeFilter.week
                    ? 'In the last 14 days'
                    : (_selectedFilter == StatsTimeFilter.month
                        ? 'In the last 30 days'
                        : 'In the last 12 months'),
                icon: CupertinoIcons.book_fill,
                iconColor: primaryColor,
                bgColor: isDark ? AppColors.darkSoftPurple : AppColors.softPurple.withOpacity(0.5),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Active Streak',
                value: '$streakDays Days 🔥',
                subtitle: streakDays > 0 ? 'Streak active' : 'Start streak today',
                icon: CupertinoIcons.flame_fill,
                iconColor: Colors.orange,
                bgColor: isDark ? AppColors.darkSoftYellow : AppColors.softYellow.withOpacity(0.5),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Today\'s Progress',
                value: '$todayCount / $dailyGoal Words',
                subtitle: '$percentGoal% goal completed',
                icon: CupertinoIcons.checkmark_seal_fill,
                iconColor: Colors.green,
                bgColor: isDark ? AppColors.darkSoftGreen : AppColors.softGreen.withOpacity(0.5),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Mastery Rate',
                value: '$masteryRate% Accuracy',
                subtitle: '$masteredCount words mastered',
                icon: CupertinoIcons.star_fill,
                iconColor: Colors.amber,
                bgColor: isDark ? AppColors.darkSoftBlue : AppColors.softBlue.withOpacity(0.5),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? iconColor.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Icon(CupertinoIcons.arrow_up_right, color: iconColor.withOpacity(0.7), size: 14),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableGrowthChartCard(
    BuildContext context,
    List<SavedWord> filteredWords,
    int dailyGoal,
    Color primaryColor,
    bool isDark,
  ) {
    final now = DateTime.now();
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<String> labels = [];
    List<int> counts = [];
    int numBins = 7;

    if (_selectedFilter == StatsTimeFilter.week) {
      numBins = 14; // 14 scrollable days ending on TODAY
      labels = List.filled(numBins, '');
      counts = List.filled(numBins, 0);

      for (int i = numBins - 1; i >= 0; i--) {
        final dayDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: numBins - 1 - i));
        final wName = weekdayNames[dayDate.weekday - 1];
        labels[i] = '$wName\n${dayDate.day}';
      }

      for (final word in filteredWords) {
        for (int i = 0; i < numBins; i++) {
          final targetDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: numBins - 1 - i));
          if (word.dateAdded.year == targetDate.year &&
              word.dateAdded.month == targetDate.month &&
              word.dateAdded.day == targetDate.day) {
            counts[i] = counts[i] + 1;
            break;
          }
        }
      }
    } else if (_selectedFilter == StatsTimeFilter.month) {
      numBins = 30; // 30 scrollable daily bars ending on TODAY
      labels = List.filled(numBins, '');
      counts = List.filled(numBins, 0);

      for (int i = numBins - 1; i >= 0; i--) {
        final dayDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: numBins - 1 - i));
        labels[i] = '${dayDate.day}/${dayDate.month}';
      }

      for (final word in filteredWords) {
        for (int i = 0; i < numBins; i++) {
          final targetDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: numBins - 1 - i));
          if (word.dateAdded.year == targetDate.year &&
              word.dateAdded.month == targetDate.month &&
              word.dateAdded.day == targetDate.day) {
            counts[i] = counts[i] + 1;
            break;
          }
        }
      }
    } else {
      numBins = 12; // 12 scrollable months ending on THIS MONTH
      labels = List.filled(numBins, '');
      counts = List.filled(numBins, 0);

      for (int i = numBins - 1; i >= 0; i--) {
        int targetMonth = now.month - (numBins - 1 - i);
        int targetYear = now.year;
        while (targetMonth <= 0) {
          targetMonth += 12;
          targetYear -= 1;
        }
        labels[i] = monthNames[targetMonth - 1];
      }

      for (final word in filteredWords) {
        for (int i = 0; i < numBins; i++) {
          int targetMonth = now.month - (numBins - 1 - i);
          int targetYear = now.year;
          while (targetMonth <= 0) {
            targetMonth += 12;
            targetYear -= 1;
          }
          if (word.dateAdded.month == targetMonth && word.dateAdded.year == targetYear) {
            counts[i] = counts[i] + 1;
            break;
          }
        }
      }
    }

    final maxCount = counts.fold<int>(dailyGoal, (prev, curr) => curr > prev ? curr : prev);
    final totalInPeriod = counts.reduce((a, b) => a + b);
    final avgVal = (totalInPeriod / counts.length).toStringAsFixed(1);
    final activeHighlightIndex = numBins - 1; // Always the rightmost bar (TODAY/NOW)

    return _buildCardContainer(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vocabulary Velocity',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal: $dailyGoal words/day',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 14, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe chart',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primaryColor),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Avg: $avgVal/period',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 160,
              child: SingleChildScrollView(
                controller: _chartScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(labels.length, (index) {
                    final count = counts[index];
                    final heightRatio = (count / maxCount).clamp(0.08, 1.0);
                    final isCurrentPeriod = index == activeHighlightIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isCurrentPeriod)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedFilter == StatsTimeFilter.allTime ? 'NOW' : 'TODAY',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white60 : AppColors.textSecondary,
                              ),
                            ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 32,
                            height: 95 * heightRatio,
                            decoration: BoxDecoration(
                              color: isCurrentPeriod
                                  ? primaryColor
                                  : (isDark ? const Color(0xFF32324A) : AppColors.softPurple),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isCurrentPeriod
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : null,
                            ),
                            child: isCurrentPeriod
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            labels[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCurrentPeriod ? FontWeight.w900 : FontWeight.w600,
                              color: isCurrentPeriod
                                  ? primaryColor
                                  : (isDark ? Colors.white54 : AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCefrBreakdownCard(
    BuildContext context,
    List<SavedWord> filteredWords,
    Color primaryColor,
    bool isDark,
  ) {
    int beginner = 0; // A1, A2
    int intermediate = 0; // B1, B2
    int advanced = 0; // C1, C2

    for (final word in filteredWords) {
      final cefr = (word.cefr ?? '').toUpperCase();
      if (cefr.contains('A1') || cefr.contains('A2')) {
        beginner++;
      } else if (cefr.contains('B1') || cefr.contains('B2')) {
        intermediate++;
      } else if (cefr.contains('C1') || cefr.contains('C2')) {
        advanced++;
      } else {
        intermediate++;
      }
    }

    final total = filteredWords.isEmpty ? 1 : filteredWords.length;
    String dominantTag = 'Intermediate (B2)';
    if (beginner >= intermediate && beginner >= advanced) {
      dominantTag = 'Beginner (A2)';
    } else if (advanced >= intermediate && advanced >= beginner) {
      dominantTag = 'Advanced (C1)';
    }

    return _buildCardContainer(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CEFR Level Distribution',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dominant: $dominantTag',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCefrRow(context, label: 'A1/A2 Beginner', count: beginner, total: total, color: Colors.teal, isDark: isDark),
            const SizedBox(height: 12),
            _buildCefrRow(context, label: 'B1/B2 Intermediate', count: intermediate, total: total, color: primaryColor, isDark: isDark),
            const SizedBox(height: 12),
            _buildCefrRow(context, label: 'C1/C2 Advanced', count: advanced, total: total, color: Colors.orange, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCefrRow(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required Color color,
    required bool isDark,
  }) {
    final ratio = (count / total).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Text(
              '$count words ($percent%)',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: isDark ? const Color(0xFF32324A) : color.withOpacity(0.15),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStageDistributionCard(
    BuildContext context, {
    required int total,
    required int learning,
    required int inReview,
    required int mastered,
    required Color primaryColor,
    required bool isDark,
  }) {
    final validTotal = total == 0 ? 1 : total;
    final learningRatio = (learning / validTotal).clamp(0.0, 1.0);
    final reviewRatio = (inReview / validTotal).clamp(0.0, 1.0);
    final masteredRatio = (mastered / validTotal).clamp(0.0, 1.0);

    return _buildCardContainer(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Word Retention Pipeline',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: [
                    if (learningRatio > 0)
                      Expanded(
                        flex: (learningRatio * 100).round(),
                        child: Container(color: Colors.deepOrange),
                      ),
                    if (reviewRatio > 0)
                      Expanded(
                        flex: (reviewRatio * 100).round(),
                        child: Container(color: Colors.amber),
                      ),
                    if (masteredRatio > 0)
                      Expanded(
                        flex: (masteredRatio * 100).round(),
                        child: Container(color: Colors.green),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStageLegend(context, label: 'Learning', count: learning < 0 ? 0 : learning, color: Colors.deepOrange),
                _buildStageLegend(context, label: 'In Review', count: inReview, color: Colors.amber),
                _buildStageLegend(context, label: 'Mastered', count: mastered, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageLegend(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('$count words', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ],
    );
  }

  Widget _buildPartsOfSpeechCard(
    BuildContext context,
    List<SavedWord> filteredWords,
    Color primaryColor,
    bool isDark,
  ) {
    Map<String, List<SavedWord>> posMap = {};
    for (final word in filteredWords) {
      final pos = (word.partOfSpeech ?? 'noun').toLowerCase();
      if (!posMap.containsKey(pos)) {
        posMap[pos] = [];
      }
      posMap[pos]!.add(word);
    }

    if (posMap.isEmpty) {
      return _buildCardContainer(
        isDark: isDark,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No words saved in this period yet.',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return _buildCardContainer(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: posMap.entries.map((e) {
            final pos = e.key;
            final wordsList = e.value;

            return InkWell(
              onTap: () {
                _showPartsOfSpeechBottomSheet(context, pos, wordsList, primaryColor, isDark);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27273C) : AppColors.softPurple.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF383852) : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pos.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${wordsList.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(CupertinoIcons.chevron_right, size: 12, color: primaryColor),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPartsOfSpeechBottomSheet(
    BuildContext context,
    String pos,
    List<SavedWord> words,
    Color primaryColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(CupertinoIcons.textformat_abc, color: primaryColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Saved ${pos.toUpperCase()}S (${words.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: words.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, index) {
                    final word = words[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(ctx);
                        final entry = _lexicalEntryFromSavedWord(word);
                        context.push('/home/search/detail', extra: entry);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF27273C)
                              : AppColors.softPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF383852)
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        word.word.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (word.phonetic != null && word.phonetic!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          word.phonetic!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    word.meaning ?? 'No definition available',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
