import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
            _buildDidYouMean(context),
            const SizedBox(height: 32),
            _buildSearchResults(context),
            const SizedBox(height: 24),
            _buildNoResults(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'reluctent',
        prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: const Icon(CupertinoIcons.clear_circled_solid, color: AppColors.textDisabled),
          onPressed: () {},
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
                  'Did you mean?',
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
              '3 results',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          context,
          word: 'RELUCTANT',
          pos: 'adjective • B2',
          meaning: 'Not wanting to do something.',
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          context,
          word: 'RELUCTANCE',
          pos: 'noun • B2',
          meaning: 'The feeling of not wanting to do something.',
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          context,
          word: 'RELUCTANTLY',
          pos: 'adverb • B2',
          meaning: 'In a reluctant way.',
        ),
      ],
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String word,
    required String pos,
    required String meaning,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/home/search/detail', extra: word.toLowerCase());
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
                      Text(
                        word,
                        style: Theme.of(context).textTheme.titleMedium,
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
                  'No results for "reluctent"?',
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