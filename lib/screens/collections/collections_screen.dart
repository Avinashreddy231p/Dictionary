import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSearchBar(context),
                    const SizedBox(height: 16),
                    _buildFilterChips(context),
                    const SizedBox(height: 32),
                    _buildSmartCollectionsHeader(context),
                    const SizedBox(height: 16),
                    _buildSmartCollectionsGrid(context),
                    const SizedBox(height: 32),
                    _buildMyCollectionsHeader(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: _buildMyCollectionsList(context),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Collections',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your saved vocabulary.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const Icon(CupertinoIcons.sparkles, color: AppColors.primaryPurple, size: 32),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search your collections...',
        prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['All', 'Smart', 'Books', 'Custom', 'Tags'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == 'All';
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (bool selected) {},
              backgroundColor: AppColors.white,
              selectedColor: AppColors.textPrimary,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.textPrimary : AppColors.border,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSmartCollectionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(CupertinoIcons.sparkles, size: 20, color: AppColors.primaryPurple),
            const SizedBox(width: 8),
            Text(
              'Smart Collections',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'See all',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryPurple,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartCollectionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _buildSmartCard(
          context,
          title: 'Recently Saved',
          subtitle: '12 words',
          icon: CupertinoIcons.time,
          color: AppColors.softYellow,
        ),
        _buildSmartCard(
          context,
          title: 'Needs Review',
          subtitle: '8 words',
          icon: CupertinoIcons.arrow_2_circlepath,
          color: AppColors.softPurple,
        ),
        _buildSmartCard(
          context,
          title: 'Favorites',
          subtitle: '17 words',
          icon: CupertinoIcons.star,
          color: AppColors.softGreen,
        ),
        _buildSmartCard(
          context,
          title: 'From Books',
          subtitle: '36 words',
          icon: CupertinoIcons.book,
          color: AppColors.softBlue,
        ),
      ],
    );
  }

  Widget _buildSmartCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.arrow_right,
                  size: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyCollectionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Collections',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.add, size: 16),
          label: const Text('New Collection'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryPurple,
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyCollectionsList(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildCollectionListItem(
          context,
          title: 'The Great Gatsby',
          wordCount: '43 words',
          progress: '18 known • 25 learning',
          color: AppColors.softPurple,
        ),
        const SizedBox(height: 12),
        _buildCollectionListItem(
          context,
          title: 'Words I Keep Forgetting',
          wordCount: '24 words',
          progress: '12 learning • 8 known • 4 review',
          color: AppColors.softGreen,
        ),
        const SizedBox(height: 12),
        _buildCollectionListItem(
          context,
          title: 'IELTS Vocabulary',
          wordCount: '18 words',
          progress: '10 learning • 6 known • 2 review',
          color: AppColors.softPeach,
        ),
        const SizedBox(height: 12),
        _buildCollectionListItem(
          context,
          title: 'Harry Potter',
          wordCount: '81 words',
          progress: '45 known • 28 learning • 8 review',
          color: AppColors.softBlue,
        ),
      ]),
    );
  }

  Widget _buildCollectionListItem(
    BuildContext context, {
    required String title,
    required String wordCount,
    required String progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(CupertinoIcons.photo, color: AppColors.textSecondary), // Placeholder for image
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  wordCount,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryPurple,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  progress,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}