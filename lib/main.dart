import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'theme/background_patterns.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const DictionaryApp(),
    ),
  );
}

class DictionaryApp extends ConsumerWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Dictionary',
      theme: AppTheme.getLight(
        settings.accentColor,
        variant: settings.themeVariant,
        fontFamily: settings.appFontFamily,
        radiusStyle: settings.cardRadiusStyle,
        borderWidthStyle: settings.borderWidthStyle,
        searchBarShape: settings.searchBarShape,
      ),
      darkTheme: AppTheme.getDark(
        settings.accentColor,
        variant: settings.themeVariant,
        fontFamily: settings.appFontFamily,
        radiusStyle: settings.cardRadiusStyle,
        borderWidthStyle: settings.borderWidthStyle,
        searchBarShape: settings.searchBarShape,
      ),
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return CustomErrorScreen(errorDetails: errorDetails);
        };
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: BackgroundTextureWidget(
            texture: settings.bgTexture,
            child: child!,
          ),
        );
      },
    );
  }
}

class CustomErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorScreen({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('An Error Occurred'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Exception:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(errorDetails.exceptionAsString()),
            const SizedBox(height: 16),
            const Text(
              'Stacktrace:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(errorDetails.stack?.toString() ?? 'No stack trace available'),
          ],
        ),
      ),
    );
  }
}
