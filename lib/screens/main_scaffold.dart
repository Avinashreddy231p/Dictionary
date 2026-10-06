import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: navigationShell,
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
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
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
