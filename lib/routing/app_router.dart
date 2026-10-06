import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/word_detail/word_detail_screen.dart';
import '../screens/collections/collections_screen.dart';
import '../data/models/dictionary_entry.dart';
import '../screens/collections/collections_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/main_scaffold.dart';

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
                        final entry = state.extra as DictionaryEntry?;
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