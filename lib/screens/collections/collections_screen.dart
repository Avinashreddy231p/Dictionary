import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../theme/app_colors.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  void _showCreateCollectionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedColor = '0xFFE5D4FF';

    final colors = [
      '0xFFE5D4FF', // Soft purple
      '0xFFD4F5E9', // Soft green
      '0xFFFFE2D4', // Soft peach
      '0xFFD4E3FF', // Soft blue
      '0xFFFFF3D4', // Soft yellow
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Create New Collection'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Collection Name',
                    hintText: 'e.g. Science Terminology',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g. Terms from biology chapter 4',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Accent Color:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: colors.map((cHex) {
                    final isSelected = selectedColor == cHex;
                    final color = Color(int.parse(cHex));
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = cHex;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.textPrimary, width: 3)
                              : Border.all(color: AppColors.border, width: 1),
                        ),
                        child: isSelected
                            ? const Icon(CupertinoIcons.check_mark, size: 16, color: AppColors.textPrimary)
                            : null,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  Navigator.pop(ctx);
                  final db = ref.read(databaseProvider);
                  await db.createCollection(
                    title: title,
                    description: descController.text.trim(),
                    colorHex: selectedColor,
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? colorHex, bool isDark) {
    if (colorHex == null || colorHex.isEmpty) return isDark ? AppColors.darkSoftPurple : AppColors.softPurple;
    try {
      return Color(int.parse(colorHex));
    } catch (_) {
      return isDark ? AppColors.darkSoftPurple : AppColors.softPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final recentWords = ref.watch(recentSavedWordsProvider).value ?? [];
    final reviewWords = ref.watch(needsReviewStreamProvider).value ?? [];
    final favoriteWords = ref.watch(favoritesStreamProvider).value ?? [];
    final bookWords = ref.watch(wordsWithSourceStreamProvider).value ?? [];
    final userCollectionsAsync = ref.watch(userCollectionsStreamProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
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
                    if (_selectedFilter == 'All' || _selectedFilter == 'Smart') ...[
                      const SizedBox(height: 32),
                      _buildSmartCollectionsHeader(context),
                      const SizedBox(height: 16),
                      _buildSmartCollectionsGrid(
                        context,
                        recentCount: recentWords.length,
                        reviewCount: reviewWords.length,
                        favoritesCount: favoriteWords.length,
                        bookCount: bookWords.length,
                      ),
                    ],
                    if (_selectedFilter == 'All' || _selectedFilter == 'Custom' || _selectedFilter == 'Books') ...[
                      const SizedBox(height: 32),
                      _buildMyCollectionsHeader(context),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            if (_selectedFilter == 'All' || _selectedFilter == 'Custom' || _selectedFilter == 'Books')
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: userCollectionsAsync.when(
                  data: (cols) {
                    final filteredCols = cols.where((c) {
                      if (_searchQuery.isNotEmpty && !c.title.toLowerCase().contains(_searchQuery)) {
                        return false;
                      }
                      return true;
                    }).toList();

                    if (filteredCols.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.cardBorder(context)),
                          ),
                          child: Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No collections match "$_searchQuery"'
                                  : 'No custom collections yet. Create your first one!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final col = filteredCols[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCollectionListItem(context, col),
                          );
                        },
                        childCount: filteredCols.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SliverToBoxAdapter(child: Text('Error: $err')),
                ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Collections',
              style: theme.textTheme.displayMedium?.copyWith(
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your saved vocabulary organized.',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        Icon(CupertinoIcons.sparkles, color: theme.primaryColor, size: 32),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      onChanged: (val) {
        setState(() {
          _searchQuery = val.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search your collections...',
        prefixIcon: Icon(CupertinoIcons.search, color: isDark ? Colors.white60 : AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: AppColors.cardBorder(context), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: AppColors.cardBorder(context), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filters = ['All', 'Smart', 'Custom', 'Books'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              backgroundColor: theme.cardTheme.color,
              selectedColor: theme.primaryColor,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColors.textPrimary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? theme.primaryColor : AppColors.cardBorder(context),
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
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.sparkles, size: 20, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Smart Collections',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmartCollectionsGrid(
    BuildContext context, {
    required int recentCount,
    required int reviewCount,
    required int favoritesCount,
    required int bookCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          subtitle: '$recentCount words',
          icon: CupertinoIcons.time,
          color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow,
          textColor: isDark ? AppColors.darkSoftYellowText : AppColors.textPrimary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CollectionDetailScreen(
                  title: 'Recently Saved',
                  description: 'All your recently added vocabulary',
                  smartType: 'recent',
                ),
              ),
            );
          },
        ),
        _buildSmartCard(
          context,
          title: 'Needs Review',
          subtitle: '$reviewCount words',
          icon: CupertinoIcons.arrow_2_circlepath,
          color: isDark ? AppColors.darkSoftPurple : AppColors.softPurple,
          textColor: isDark ? AppColors.darkSoftPurpleText : AppColors.textPrimary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CollectionDetailScreen(
                  title: 'Needs Review',
                  description: 'Words currently in your learning & review queue',
                  smartType: 'review',
                ),
              ),
            );
          },
        ),
        _buildSmartCard(
          context,
          title: 'Favorites',
          subtitle: '$favoritesCount words',
          icon: CupertinoIcons.star,
          color: isDark ? AppColors.darkSoftGreen : AppColors.softGreen,
          textColor: isDark ? AppColors.darkSoftGreenText : AppColors.textPrimary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CollectionDetailScreen(
                  title: 'Favorites',
                  description: 'Your starred favorite vocabulary',
                  smartType: 'favorites',
                ),
              ),
            );
          },
        ),
        _buildSmartCard(
          context,
          title: 'From Books',
          subtitle: '$bookCount words',
          icon: CupertinoIcons.book,
          color: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
          textColor: isDark ? AppColors.darkSoftBlueText : AppColors.textPrimary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CollectionDetailScreen(
                  title: 'From Books',
                  description: 'Words collected from reading sources',
                  smartType: 'book',
                ),
              ),
            );
          },
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
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? Border.all(color: textColor.withOpacity(0.3), width: 1.5) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: textColor, size: 28),
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
                        style: theme.textTheme.titleSmall?.copyWith(
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black38 : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_right,
                    size: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCollectionsHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Collections',
          style: theme.textTheme.titleMedium,
        ),
        TextButton.icon(
          onPressed: () => _showCreateCollectionDialog(context),
          icon: const Icon(CupertinoIcons.add, size: 16),
          label: const Text('New Collection'),
          style: TextButton.styleFrom(
            foregroundColor: theme.primaryColor,
            textStyle: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionListItem(BuildContext context, Collection collection) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final wordsAsync = ref.watch(collectionWordsStreamProvider(collection.id));

    return wordsAsync.when(
      data: (words) {
        final known = words.where((w) => w.reviewState == 2).length;
        final learning = words.where((w) => w.reviewState == 0).length;
        final review = words.where((w) => w.reviewState == 1).length;

        final progressText = words.isEmpty
            ? '0 words'
            : '$known known • $learning learning${review > 0 ? ' • $review review' : ''}';

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CollectionDetailScreen(
                  collectionId: collection.id,
                  title: collection.title,
                  description: collection.description,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _parseColor(collection.colorHex, isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(CupertinoIcons.book, color: isDark ? Colors.white70 : AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${words.length} words',
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        progressText,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right, color: isDark ? Colors.white54 : AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 80,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
