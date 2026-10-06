import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../domain/dictionary_repository.dart';
import '../../data/models/dictionary_entry.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DictionaryRepository _repository = DictionaryRepository();
  
  List<DictionaryEntry> _results = [];
  bool _isLoading = false;
  String _lastQuery = '';

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _lastQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _lastQuery = query;
    });

    final results = await _repository.searchWord(query.trim());

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
    return Scaffold(
      backgroundColor: AppColors.background,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find the meaning, usage and more.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSearchBar(context),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
            else if (_results.isNotEmpty)
              _buildSearchResults(context)
            else if (_lastQuery.isNotEmpty)
              _buildNoResults(context)
            else
              _buildDidYouMean(context), // Show as placeholder when empty
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onSubmitted: _performSearch,
      decoration: InputDecoration(
        hintText: 'Search a word...',
        prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: const Icon(CupertinoIcons.clear_circled_solid, color: AppColors.textDisabled),
          onPressed: () {
            _searchController.clear();
            _performSearch('');
          },
        ),
      ),
    );
  }

  Widget _buildDidYouMean(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.lightbulb, color: AppColors.primaryPurple, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Try searching for',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  'RELUCTANT',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${_results.length} results',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._results.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildResultCard(
                context,
                word: entry.word,
                pos: entry.partOfSpeech,
                meaning: entry.meanings.isNotEmpty ? entry.meanings.first : 'No definition available',
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
    required DictionaryEntry entry,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/home/search/detail', extra: entry);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.5),
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
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(CupertinoIcons.speaker_2, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pos,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryPurple,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meaning,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softPeach.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.search, color: AppColors.textPrimary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No results for "$_lastQuery"?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching in different ways or check for typos.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}