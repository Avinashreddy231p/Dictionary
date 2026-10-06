import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'routing/app_router.dart';

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
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
