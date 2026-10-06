import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LexiLensApp(),
    ),
  );
}

class LexiLensApp extends StatelessWidget {
  const LexiLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LexiLens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E5BFF), // A premium blue accent
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Roboto', letterSpacing: -1.0),
          displayMedium: TextStyle(fontFamily: 'Roboto', letterSpacing: -0.5),
          displaySmall: TextStyle(fontFamily: 'Roboto'),
          headlineLarge: TextStyle(fontFamily: 'Roboto'),
          headlineMedium: TextStyle(fontFamily: 'Roboto'),
          headlineSmall: TextStyle(fontFamily: 'Roboto'),
          titleLarge: TextStyle(fontFamily: 'Roboto'),
          titleMedium: TextStyle(fontFamily: 'Roboto'),
          titleSmall: TextStyle(fontFamily: 'Roboto'),
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
          bodySmall: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E5BFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
