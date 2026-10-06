import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.softYellow,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              );
            }
            return const TextStyle(
              color: AppColors.textSecondary,
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
          backgroundColor: AppColors.background,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(CupertinoIcons.search, color: AppColors.textSecondary),
              selectedIcon: Icon(CupertinoIcons.search, color: AppColors.textPrimary),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.book, color: AppColors.textSecondary),
              selectedIcon: Icon(CupertinoIcons.book_fill, color: AppColors.textPrimary),
              label: 'Collections',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.settings, color: AppColors.textSecondary),
              selectedIcon: Icon(CupertinoIcons.settings_solid, color: AppColors.textPrimary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}