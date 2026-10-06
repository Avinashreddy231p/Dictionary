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
  final FocusNode _searchFocusNode = FocusNode();
  final DictionaryRepository _repository = DictionaryRepository();

  List<LexicalEntry> _results = [];
  List<String> _suggestions = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusSearchField();
    });
  }

  void _focusSearchField() {
    if (mounted) {
      _searchFocusNode.requestFocus();
      if (_searchController.text.isNotEmpty) {
        _searchController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchController.text.length,
        );
      }
    }
  }

  void _performSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _results = [];
        _suggestions = [];
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

    final searchResult = await _repository.searchWord(cleanQuery);

    setState(() {
      _results = searchResult.entries;
      _suggestions = searchResult.suggestions;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for search double-tap / re-tap from bottom navigation bar
    ref.listen<int>(searchFocusTriggerProvider, (previous, next) {
      if (next != previous) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _focusSearchField();
        });
      }
    });

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
      focusNode: _searchFocusNode,
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
            _focusSearchField();
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESULTS (${_results.length})',
          style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: theme.primaryColor,
              ),
        ),
        const SizedBox(height: 12),
        ..._results.map((entry) {
          final word = entry.core.headword;
          final phonetic = entry.core.phonetic;
          final pos = entry.core.partOfSpeech;
          final meaning = entry.lexiLens.simpleMeaning;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.push('/home/search/detail', extra: entry);
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.border,
                      width: 1.0,
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
                                  word.toUpperCase(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    pos,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            if (phonetic.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                phonetic,
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              meaning,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.3,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(CupertinoIcons.search,
                size: 48,
                color: isDark ? Colors.white38 : AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No exact match for "$_lastQuery"',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check spelling or try these related suggestions:',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _suggestions.map((sug) {
                  return InkWell(
                    onTap: () {
                      _searchController.text = sug;
                      _performSearch(sug);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkSoftYellowText.withOpacity(0.3) : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.search,
                              size: 14,
                              color: isDark ? AppColors.darkSoftYellowText : AppColors.primaryPurple),
                          const SizedBox(width: 6),
                          Text(
                            sug,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
