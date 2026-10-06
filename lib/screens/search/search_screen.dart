import 'dart:async';
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

  List<LexicalEntry> _results = [];
  List<String> _suggestions = [];
  List<String> _autoSuggestions = [];
  Timer? _debounceTimer;

  bool _isLoading = false;
  bool _isFuzzyMatch = false;
  String? _correctedQuery;
  double? _fuzzyConfidence;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusSearchField();
    });
  }

  void _onSearchQueryChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _autoSuggestions = [];
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 120), () async {
      final repo = ref.read(dictionaryRepositoryProvider);
      final suggestions = await repo.getAutoSuggestions(query);
      if (mounted && _searchController.text.trim().toLowerCase() == query.toLowerCase()) {
        setState(() {
          _autoSuggestions = suggestions;
        });
      }
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
    setState(() {
      _autoSuggestions = [];
    });

    if (cleanQuery.isEmpty) {
      setState(() {
        _results = [];
        _suggestions = [];
        _isFuzzyMatch = false;
        _correctedQuery = null;
        _fuzzyConfidence = null;
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

    final repository = ref.read(dictionaryRepositoryProvider);
    final searchResult = await repository.searchWord(cleanQuery);

    setState(() {
      _results = searchResult.entries;
      _suggestions = searchResult.suggestions;
      _isFuzzyMatch = searchResult.isFuzzyMatch;
      _correctedQuery = searchResult.correctedQuery;
      _fuzzyConfidence = searchResult.fuzzyConfidence;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchQueryChanged);
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
              'Find meanings, definitions and instant offline suggestions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSearchBar(context),
            if (_autoSuggestions.isNotEmpty)
              _buildAutoSuggestDropdown(context),
            const SizedBox(height: 24),
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: theme.primaryColor))
            else if (_results.isNotEmpty) ...[
              if (_isFuzzyMatch && _correctedQuery != null)
                _buildFuzzyMatchBanner(context),
              _buildSearchResults(context),
            ] else if (_lastQuery.isNotEmpty)
              _buildNoResults(context)
            else
              _buildDidYouMean(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoSuggestDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final currentQuery = _searchController.text.trim().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _autoSuggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            final isLast = index == _autoSuggestions.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _searchController.text = suggestion;
                    _performSearch(suggestion);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          size: 18,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildHighlightedText(
                            suggestion,
                            currentQuery,
                            isDark,
                            primaryColor,
                          ),
                        ),
                        // Google-style Auto-Fill button (copies to search bar without submitting)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            CupertinoIcons.arrow_up_left,
                            size: 18,
                            color: isDark ? Colors.white38 : AppColors.textDisabled,
                          ),
                          tooltip: 'Auto-fill',
                          onPressed: () {
                            _searchController.text = suggestion;
                            _searchController.selection = TextSelection.fromPosition(
                              TextPosition(offset: suggestion.length),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 48,
                    endIndent: 16,
                    color: isDark ? const Color(0xFF2C2C3F) : AppColors.border.withOpacity(0.5),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, bool isDark, Color primaryColor) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final index = lowerText.indexOf(query);

    if (index == -1) {
      return Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      );
    }

    final start = text.substring(0, index);
    final match = text.substring(index, index + query.length);
    final end = text.substring(index + query.length);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: start, style: const TextStyle(fontWeight: FontWeight.w400)),
          TextSpan(
            text: match,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: primaryColor,
            ),
          ),
          TextSpan(text: end, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFuzzyMatchBanner(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSoftPurpleText.withOpacity(0.3) : theme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.sparkles,
            color: isDark ? AppColors.darkSoftPurpleText : theme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Showing results for '),
                      TextSpan(
                        text: _correctedQuery?.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: ' (fuzzy match for "'),
                      TextSpan(
                        text: _lastQuery,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '")'),
                    ],
                  ),
                ),
                if (_fuzzyConfidence != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Similarity score: ${(_fuzzyConfidence! * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkSoftPurpleText.withOpacity(0.8) : theme.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final entry = _results[index];
        return _buildWordCard(context, entry);
      },
    );
  }

  Widget _buildWordCard(BuildContext context, LexicalEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headword = entry.core.headword;
    final pos = entry.core.partOfSpeech;
    final phonetic = entry.core.phonetic;
    final firstSense = entry.senses.isNotEmpty ? entry.senses.first : null;
    final def = firstSense?.definition ?? entry.lexiLens.simpleMeaning;

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1D1D2C) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C2C3F) : AppColors.border,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push('/word/$headword', extra: entry);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      headword,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (pos.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pos,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              if (phonetic.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  phonetic,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                def,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredSuggestions = _suggestions.where((s) => s.toLowerCase() != _lastQuery.toLowerCase()).toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.search_circle_fill,
              size: 64,
              color: isDark ? Colors.white24 : AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No exact definition found for "$_lastQuery"',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check spelling or try searching one of the suggestions below.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            if (filteredSuggestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: filteredSuggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      _searchController.text = suggestion;
                      _performSearch(suggestion);
                    },
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
