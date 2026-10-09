import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/word_detail/word_detail_screen.dart';
import '../screens/collections/collections_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/sub_screens/appearance_settings_screen.dart';
import '../screens/settings/sub_screens/gemini_settings_screen.dart';
import '../screens/settings/sub_screens/audio_settings_screen.dart';
import '../screens/settings/sub_screens/goals_settings_screen.dart';
import '../screens/settings/sub_screens/storage_settings_screen.dart';
import '../screens/settings/sub_screens/about_settings_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/flashcards/flashcard_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/main_scaffold.dart';
import '../data/models/lexical_entry.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _collectionsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'collections');
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/stats',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/flashcards',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FlashcardScreen(),
    ),
    GoRoute(
      path: '/quiz',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/settings/appearance',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AppearanceSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/gemini',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GeminiSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/audio',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AudioSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/goals',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GoalsSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/storage',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StorageSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/about',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutSettingsScreen(),
    ),
    GoRoute(
      path: '/word/:word',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final entry = state.extra as LexicalEntry?;
        final wordParam = state.pathParameters['word'];
        return WordDetailScreen(entry: entry, initialWord: wordParam);
      },
    ),
    GoRoute(
      path: '/word',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final entry = state.extra as LexicalEntry?;
        return WordDetailScreen(entry: entry);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SearchScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final entry = state.extra as LexicalEntry?;
                        return WordDetailScreen(entry: entry);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _collectionsNavigatorKey,
          routes: [
            GoRoute(
              path: '/collections',
              builder: (context, state) => const CollectionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
