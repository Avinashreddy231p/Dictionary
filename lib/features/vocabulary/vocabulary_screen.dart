import 'package:flutter/material.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Vocabulary')),
      body: const Center(
        child: Text('Saved vocabulary will appear here'),
      ),
    );
  }
}
