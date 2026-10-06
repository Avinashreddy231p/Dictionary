import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/providers.dart';
import '../../domain/dictionary_repository.dart';
import '../../data/models/lexical_entry.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DictionaryRepository _repository = DictionaryRepository();

  List<LexicalEntry> _results = [];
  bool _isLoading = false;
  String _lastQuery = '';

  void _performSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _results = [];
        _lastQuery = '';
      });
      return;
    }

    // Save to recent searches DB table
    ref.read(databaseProvider).addRecentSearch(cleanQuery);

    setState(() {
      _isLoading = true;
      _lastQuery = cleanQuery;
    });

    final results = await _repository.searchWord(cleanQuery);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find the meaning, usage and more.',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSearchBar(context),
            const SizedBox(height: 24),
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: theme.primaryColor))
            else if (_results.isNotEmpty)
              _buildSearchResults(context)
            else if (_lastQuery.isNotEmpty)
              _buildNoResults(context)
            else
              _buildDidYouMean(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: _searchController,
      autofocus: true,
      onSubmitted: _performSearch,
      decoration: InputDecoration(
        hintText: 'Search a word...',
        prefixIcon: Icon(CupertinoIcons.search,
            color: isDark ? Colors.white60 : AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: const Icon(CupertinoIcons.clear_circled_solid,
              color: AppColors.textDisabled),
          onPressed: () {
            _searchController.clear();
            _performSearch('');
          },
        ),
      ),
    );
  }

  Widget _buildDidYouMean(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _searchController.text = 'reluctant';
        _performSearch('reluctant');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.adaptiveSoftYellow(context),
          borderRadius: BorderRadius.circular(24),
          border: isDark
              ? Border.all(color: AppColors.darkSoftYellowText.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.lightbulb,
                color: isDark ? AppColors.darkSoftYellowText : theme.primaryColor,
                size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try searching for',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkSoftYellowText.withOpacity(0.8)
                              : AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    'RELUCTANT',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkSoftYellowText
                              : AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Results',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '${_results.length} results',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._results.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildResultCard(
                context,
                word: entry.core.headword,
                pos: entry.core.partOfSpeech,
                meaning: entry.senses.isNotEmpty
                    ? entry.senses.first.definition
                    : 'No definition available',
                entry: entry,
              ),
            )),
      ],
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String word,
    required String pos,
    required String meaning,
    required LexicalEntry entry,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.push('/home/search/detail', extra: entry);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          word,
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(CupertinoIcons.speaker_2,
                          size: 16,
                          color: isDark ? Colors.white60 : AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pos,
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meaning,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                color: isDark ? Colors.white54 : AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSoftPink : AppColors.softPeach.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkSoftPinkText.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.search,
              color: isDark ? AppColors.darkSoftPinkText : AppColors.textPrimary,
              size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No results for "$_lastQuery"?',
                  style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkSoftPinkText
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching in different ways or check for typos.',
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkSoftPinkText.withOpacity(0.8)
                            : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
