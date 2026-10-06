import 'package:flutter/material.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reading Mode')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Paste text or import a book to start reading.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Paste Text'),
            ),
          ],
        ),
      ),
    );
  }
}
