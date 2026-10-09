import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers.dart';
import '../theme/background_patterns.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  DateTime? _lastSearchTap;

  void _handleDestinationSelected(int index) {
    final currentIndex = widget.navigationShell.currentIndex;
    final now = DateTime.now();

    if (index == 0) {
      if (currentIndex != 0) {
        // Tapping from another tab (e.g. Collections or Settings) goes directly to Home Screen (/home)
        _lastSearchTap = now;
        widget.navigationShell.goBranch(0, initialLocation: false);
        return;
      }

      // Already on Home tab (currentIndex == 0)
      final isDoubleTap = _lastSearchTap != null &&
          now.difference(_lastSearchTap!) < const Duration(milliseconds: 400);

      _lastSearchTap = isDoubleTap ? null : now;

      // Navigate to /home/search route
      context.go('/home/search');

      // Trigger focus and keyboard popup in SearchScreen, clearing query if double-tapped
      ref.read(searchFocusTriggerProvider.notifier).trigger(isDoubleTap: isDoubleTap);
      return;
    }

    _lastSearchTap = null;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: BackgroundTextureWidget(
        texture: settings.bgTexture,
        opacity: settings.bgTextureOpacity,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: isDark
              ? primaryColor.withOpacity(0.25)
              : primaryColor.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: isDark ? Colors.white : primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              );
            }
            return TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _handleDestinationSelected,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: Icon(CupertinoIcons.search,
                  color: isDark ? Colors.white54 : Colors.grey.shade600),
              selectedIcon: Icon(CupertinoIcons.search, color: primaryColor),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.book,
                  color: isDark ? Colors.white54 : Colors.grey.shade600),
              selectedIcon: Icon(CupertinoIcons.book_fill, color: primaryColor),
              label: 'Collections',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.settings,
                  color: isDark ? Colors.white54 : Colors.grey.shade600),
              selectedIcon: Icon(CupertinoIcons.settings_solid, color: primaryColor),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
