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

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'book', 'icon': CupertinoIcons.book_fill},
    {'name': 'bookmark', 'icon': CupertinoIcons.bookmark_fill},
    {'name': 'star', 'icon': CupertinoIcons.star_fill},
    {'name': 'flame', 'icon': CupertinoIcons.flame_fill},
    {'name': 'lightbulb', 'icon': CupertinoIcons.lightbulb_fill},
    {'name': 'heart', 'icon': CupertinoIcons.heart_fill},
    {'name': 'folder', 'icon': CupertinoIcons.folder_fill},
    {'name': 'tag', 'icon': CupertinoIcons.tag_fill},
    {'name': 'sparkles', 'icon': CupertinoIcons.sparkles},
    {'name': 'flag', 'icon': CupertinoIcons.flag_fill},
  ];

  final List<String> _colorOptions = [
    '0xFFE5D4FF', // Soft purple
    '0xFFD4F5E9', // Soft green
    '0xFFFFE2D4', // Soft peach
    '0xFFD4E3FF', // Soft blue
    '0xFFFFF3D4', // Soft yellow
    '0xFFFFD4E5', // Soft pink
  ];

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'bookmark':
        return CupertinoIcons.bookmark_fill;
      case 'star':
        return CupertinoIcons.star_fill;
      case 'flame':
        return CupertinoIcons.flame_fill;
      case 'lightbulb':
        return CupertinoIcons.lightbulb_fill;
      case 'heart':
        return CupertinoIcons.heart_fill;
      case 'folder':
        return CupertinoIcons.folder_fill;
      case 'tag':
        return CupertinoIcons.tag_fill;
      case 'sparkles':
        return CupertinoIcons.sparkles;
      case 'flag':
        return CupertinoIcons.flag_fill;
      case 'book':
      default:
        return CupertinoIcons.book_fill;
    }
  }

  Color _parseColor(String? colorHex, bool isDark) {
    if (colorHex == null || colorHex.isEmpty) return isDark ? AppColors.darkSoftPurple : AppColors.softPurple;
    try {
      return Color(int.parse(colorHex));
    } catch (_) {
      return isDark ? AppColors.darkSoftPurple : AppColors.softPurple;
    }
  }

  // Modal Bottom Sheet for Creating / Editing Collections
  void _showCollectionBottomSheet(BuildContext context, {Collection? collectionToEdit}) {
    final isEditing = collectionToEdit != null;
    final titleController = TextEditingController(text: collectionToEdit?.title ?? '');
    final descController = TextEditingController(text: collectionToEdit?.description ?? '');
    final tagsController = TextEditingController(text: collectionToEdit?.tags ?? '');
    String selectedColor = collectionToEdit?.colorHex ?? '0xFFE5D4FF';
    String selectedIcon = collectionToEdit?.iconName ?? 'book';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setBottomSheetState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final previewColor = _parseColor(selectedColor, isDark);
          final previewIcon = _getIconData(selectedIcon);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white30 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Collection' : 'Create New Collection',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(CupertinoIcons.xmark_circle_fill, color: isDark ? Colors.white54 : AppColors.textDisabled),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Live Card Preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: previewColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(previewIcon, color: AppColors.textPrimary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleController.text.trim().isNotEmpty
                                      ? titleController.text.trim()
                                      : 'Collection Title',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  descController.text.trim().isNotEmpty
                                      ? descController.text.trim()
                                      : 'Description preview',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Collection Name Field
                    TextField(
                      controller: titleController,
                      autofocus: !isEditing,
                      onChanged: (_) => setBottomSheetState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Collection Name',
                        hintText: 'e.g. Science Terminology',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    TextField(
                      controller: descController,
                      onChanged: (_) => setBottomSheetState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'e.g. Terms from biology chapter 4',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags Field
                    TextField(
                      controller: tagsController,
                      onChanged: (_) => setBottomSheetState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Tags (comma separated)',
                        hintText: 'e.g. Exam, IELTS, Classic, Science',
                        prefixIcon: const Icon(CupertinoIcons.tag_fill, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Icon Selector
                    Text('Choose Icon:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _iconOptions.map((opt) {
                          final name = opt['name'] as String;
                          final icon = opt['icon'] as IconData;
                          final isSelected = selectedIcon == name;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setBottomSheetState(() {
                                  selectedIcon = name;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 44,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.primaryColor : theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? theme.primaryColor : AppColors.cardBorder(context),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 20,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Color Selector
                    Text('Accent Color:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _colorOptions.map((cHex) {
                        final isSelected = selectedColor == cHex;
                        final color = Color(int.parse(cHex));
                        return GestureDetector(
                          onTap: () {
                            setBottomSheetState(() {
                              selectedColor = cHex;
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
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
                    ),
                    const SizedBox(height: 28),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isNotEmpty) {
                            Navigator.pop(ctx);
                            final db = ref.read(databaseProvider);
                            final tags = tagsController.text.trim();

                            if (isEditing) {
                              await db.updateCollection(
                                id: collectionToEdit.id,
                                title: title,
                                description: descController.text.trim(),
                                colorHex: selectedColor,
                                iconName: selectedIcon,
                                tags: tags.isNotEmpty ? tags : null,
                              );
                            } else {
                              await db.createCollection(
                                title: title,
                                description: descController.text.trim(),
                                colorHex: selectedColor,
                                iconName: selectedIcon,
                                tags: tags.isNotEmpty ? tags : null,
                              );
                            }
                          }
                        },
                        child: Text(
                          isEditing ? 'Save Changes' : 'Create Collection',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Bottom Sheet for Collection Options (Edit / Delete)
  void _showCollectionOptionsBottomSheet(BuildContext context, Collection collection, int wordCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = _parseColor(collection.colorHex, isDark);
    final iconData = _getIconData(collection.iconName);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header Preview
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(iconData, color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$wordCount words',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Option 1: Edit Collection
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoftBlue : AppColors.softBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(CupertinoIcons.pencil, color: isDark ? AppColors.darkSoftBlueText : AppColors.textPrimary, size: 20),
                ),
                title: const Text('Edit Collection', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Change name, description, tags, icon or color', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCollectionBottomSheet(context, collectionToEdit: collection);
                },
              ),

              const Divider(height: 16),

              // Option 2: Delete Collection
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 20),
                ),
                title: const Text('Delete Collection', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                subtitle: const Text('Permanently remove this collection', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteCollection(context, collection);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteCollection(BuildContext context, Collection collection) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Collection?'),
        content: Text('Are you sure you want to delete "${collection.title}"? The words will remain in your general vocabulary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(databaseProvider).deleteCollection(collection.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final recentWords = ref.watch(recentSavedWordsProvider).value ?? [];
    final reviewWords = ref.watch(needsReviewStreamProvider).value ?? [];
    final favoriteWords = ref.watch(favoritesStreamProvider).value ?? [];
    final bookWords = ref.watch(wordsWithSourceStreamProvider).value ?? [];
    final masteredWords = ref.watch(masteredWordsStreamProvider).value ?? [];
    final notesWords = ref.watch(wordsWithNotesStreamProvider).value ?? [];
    final userCollectionsAsync = ref.watch(userCollectionsStreamProvider);

    final userCollections = userCollectionsAsync.value ?? [];

    // Dynamically extract all unique tags from user collections
    final allExtractedTags = <String>{};
    for (final col in userCollections) {
      if (col.tags != null && col.tags!.isNotEmpty) {
        final split = col.tags!.split(',');
        for (final t in split) {
          final clean = t.trim();
          if (clean.isNotEmpty) {
            allExtractedTags.add(clean);
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Section: Header + Smart Collections Row
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSmartCollectionsHeader(context),
                    const SizedBox(height: 16),
                    _buildSmartCollectionsRow(
                      context,
                      filter: _selectedFilter,
                      recentCount: recentWords.length,
                      reviewCount: reviewWords.length,
                      favoritesCount: favoriteWords.length,
                      bookCount: bookWords.length,
                      masteredCount: masteredWords.length,
                      notesCount: notesWords.length,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Sticky Search Bar + Filter Chips Row (Pins at top on scroll!)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBarDelegate(
                height: 126.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context),
                      const SizedBox(height: 10),
                      _buildFilterChips(context, extractedTags: allExtractedTags.toList()),
                    ],
                  ),
                ),
              ),
            ),

            // 3. My Collections Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              sliver: SliverToBoxAdapter(
                child: _buildMyCollectionsHeader(context),
              ),
            ),

            // 4. Custom Collections List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: userCollectionsAsync.when(
                data: (cols) {
                  final filteredCols = cols.where((c) {
                    // Search Query filter
                    if (_searchQuery.isNotEmpty && !c.title.toLowerCase().contains(_searchQuery) && !(c.description?.toLowerCase().contains(_searchQuery) ?? false)) {
                      return false;
                    }
                    // Filter Pill selection
                    if (_selectedFilter == 'All' || _selectedFilter == 'Custom') {
                      return true;
                    }
                    if (_selectedFilter == 'Books') {
                      final t = '${c.title} ${c.description ?? ''} ${c.tags ?? ''}'.toLowerCase();
                      return t.contains('book') || t.contains('gatsby') || t.contains('potter') || t.contains('novel') || t.contains('chapter') || t.contains('read');
                    }
                    if (_selectedFilter == 'Recent' || _selectedFilter == 'Favorites' || _selectedFilter == 'Review') {
                      return true;
                    }
                    // Check if selected filter matches one of the custom tags!
                    if (c.tags != null && c.tags!.isNotEmpty) {
                      final colTags = c.tags!.split(',').map((t) => t.trim().toLowerCase()).toList();
                      if (colTags.contains(_selectedFilter.toLowerCase())) {
                        return true;
                      }
                    }
                    return false;
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
                                : 'No custom collections match "$_selectedFilter"',
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
                        return _buildCollectionCard(context, col);
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Collections',
                  maxLines: 1,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your saved vocabulary organized.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(CupertinoIcons.sparkles, color: theme.primaryColor, size: 24),
        ),
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
        hintText: 'Search your collections or tags...',
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

  Widget _buildFilterChips(BuildContext context, {required List<String> extractedTags}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultFilters = [
      'All',
      'Books',
      'Recent',
      'Favorites',
      'Review',
      'Mastered',
      'Notes',
    ];

    final combinedFilters = <String>[...defaultFilters];
    for (final tag in extractedTags) {
      if (!combinedFilters.any((f) => f.toLowerCase() == tag.toLowerCase())) {
        combinedFilters.add(tag);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: combinedFilters.map((filter) {
          final isSelected = _selectedFilter.toLowerCase() == filter.toLowerCase();
          final isCustomTag = !defaultFilters.contains(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              avatar: isCustomTag
                  ? Icon(
                      CupertinoIcons.tag_fill,
                      size: 14,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                    )
                  : null,
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
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isSelected ? theme.primaryColor : AppColors.cardBorder(context),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildSmartCollectionsRow(
    BuildContext context, {
    required String filter,
    required int recentCount,
    required int reviewCount,
    required int favoritesCount,
    required int bookCount,
    required int masteredCount,
    required int notesCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cards = <Widget>[];
    final fLower = filter.toLowerCase();

    if (fLower == 'all' || fLower == 'recent') {
      cards.add(
        _buildSmartCard(
          context,
          title: 'Recently Saved',
          subtitle: '$recentCount words',
          icon: CupertinoIcons.time_solid,
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
      );
    }

    if (fLower == 'all' || fLower == 'review') {
      cards.add(
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
      );
    }

    if (fLower == 'all' || fLower == 'favorites') {
      cards.add(
        _buildSmartCard(
          context,
          title: 'Favorites',
          subtitle: '$favoritesCount words',
          icon: CupertinoIcons.star_fill,
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
      );
    }

    if (fLower == 'all' || fLower == 'books') {
      cards.add(
        _buildSmartCard(
          context,
          title: 'From Books',
          subtitle: '$bookCount words',
          icon: CupertinoIcons.book_fill,
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
      );
    }

    if (fLower == 'all' || fLower == 'mastered') {
      cards.add(
        _buildSmartCard(
          context,
          title: 'Mastered',
          subtitle: '$masteredCount words',
          icon: CupertinoIcons.checkmark_seal_fill,
          color: isDark ? AppColors.darkSoftPink : AppColors.softPeach,
          textColor: isDark ? AppColors.darkSoftPinkText : AppColors.textPrimary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CollectionDetailScreen(
                  title: 'Mastered',
                  description: 'Words you have fully mastered and known',
                  smartType: 'mastered',
                ),
              ),
            );
          },
        ),
      );
    }

    if (fLower == 'all' || fLower == 'notes') {
      cards.add(
        _buildSmartCard(
          context,
          title: 'With Notes',
          subtitle: '$notesCount words',
          icon: CupertinoIcons.doc_text_fill,
          color: isDark ? const Color(0xFF1E3A40) : const Color(0xFFE0F2F1),
          textColor: isDark ? const Color(0xFF80CBC4) : const Color(0xFF004D40),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CollectionDetailScreen(
                  title: 'With Notes',
                  description: 'Words with personal notes and sentences',
                  smartType: 'notes',
                ),
              ),
            );
          },
        ),
      );
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 175,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: cards,
      ),
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

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: isDark ? Border.all(color: textColor.withOpacity(0.3), width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Icon Badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: textColor, size: 22),
                ),

                // Title & Subtitle + Arrow Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: textColor.withOpacity(0.85),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black38 : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.arrow_right,
                            size: 13,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyCollectionsHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'My Collections',
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => _showCollectionBottomSheet(context),
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

  Widget _buildCollectionCard(BuildContext context, Collection collection) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = _parseColor(collection.colorHex, isDark);
    final iconData = _getIconData(collection.iconName);
    final wordsAsync = ref.watch(collectionWordsStreamProvider(collection.id));

    final tagList = (collection.tags != null && collection.tags!.isNotEmpty)
        ? collection.tags!.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
        : <String>[];

    return wordsAsync.when(
      data: (words) {
        final known = words.where((w) => w.reviewState == 2).length;
        final learning = words.where((w) => w.reviewState == 0).length;
        final review = words.where((w) => w.reviewState == 1).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Custom Icon + Title/Desc + Option Icon (No Pill Badge!)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon Badge
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            iconData,
                            color: AppColors.textPrimary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title & Subtitle & Word Count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                collection.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '${words.length} words',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  if (collection.description != null && collection.description!.isNotEmpty) ...[
                                    const Text('  •  ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Expanded(
                                      child: Text(
                                        collection.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.ellipsis_vertical,
                            size: 18,
                            color: isDark ? Colors.white54 : AppColors.textSecondary,
                          ),
                          onPressed: () => _showCollectionOptionsBottomSheet(context, collection, words.length),
                        ),
                      ],
                    ),

                    // Tags Row (if tags present)
                    if (tagList.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tagList.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(isDark ? 0.25 : 0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.tag_fill, size: 10, color: isDark ? Colors.white70 : AppColors.textPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Progress Stats Breakdown
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildDotIndicator(isDark ? AppColors.darkSoftGreenText : AppColors.softGreen, '$known known'),
                        const SizedBox(width: 12),
                        _buildDotIndicator(isDark ? AppColors.darkSoftYellowText : AppColors.softYellow, '$learning learning'),
                        if (review > 0) ...[
                          const SizedBox(width: 12),
                          _buildDotIndicator(isDark ? AppColors.darkSoftPinkText : AppColors.softPeach, '$review review'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Multi-Segment Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 6,
                        child: Row(
                          children: [
                            if (words.isNotEmpty) ...[
                              Expanded(
                                flex: known > 0 ? known : 0,
                                child: Container(color: isDark ? AppColors.darkSoftGreen : AppColors.softGreen),
                              ),
                              Expanded(
                                flex: learning > 0 ? learning : 0,
                                child: Container(color: isDark ? AppColors.darkSoftYellow : AppColors.softYellow),
                              ),
                              Expanded(
                                flex: review > 0 ? review : 0,
                                child: Container(color: isDark ? AppColors.darkSoftPink : AppColors.softPeach),
                              ),
                              if (known == 0 && learning == 0 && review == 0)
                                Expanded(child: Container(color: AppColors.cardBorder(context))),
                            ] else
                              Expanded(child: Container(color: AppColors.cardBorder(context))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDotIndicator(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickySearchBarDelegate({required this.child, this.height = 126.0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
