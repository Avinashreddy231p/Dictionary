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
        if (_lastSearchTap != null && now.difference(_lastSearchTap!) < const Duration(milliseconds: 600)) {
          // Double click detected -> open Search
          _lastSearchTap = null;
          context.go('/home/search');
          ref.read(searchFocusTriggerProvider.notifier).trigger();
        } else {
          // Single click from another screen -> open Home
          _lastSearchTap = now;
          context.go('/home');
        }
      } else {
        // Already on home tab -> open Search
        context.go('/home/search');
        ref.read(searchFocusTriggerProvider.notifier).trigger();
      }
      return;
    }

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
