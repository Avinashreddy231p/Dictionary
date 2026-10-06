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
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return CustomErrorScreen(errorDetails: errorDetails);
        };
        return child!;
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
            Text(
              'Exception:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(errorDetails.exceptionAsString()),
            const SizedBox(height: 16),
            Text(
              'Stacktrace:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(errorDetails.stack?.toString() ?? 'No stack trace available'),
          ],
        ),
      ),
    );
  }
}
