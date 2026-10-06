import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/database/database.dart';

class WordDetailScreen extends ConsumerWidget {
  final String word;
  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.watch(wordRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(word, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Word saved to vocabulary')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Word?>(
        future: repo.getWordDetails(word.toLowerCase()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Couldn\'t find that word.', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Check your spelling or try another search.'),
                ],
              ),
            );
          }

          final wordData = snapshot.data!;
          return FutureBuilder<List<Definition>>(
            future: repo.getWordDefinitions(wordData.id),
            builder: (context, defSnapshot) {
              if (defSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final definitions = defSnapshot.data ?? [];
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wordData.word.toUpperCase(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (wordData.pronunciation != null)
                          Text(
                            wordData.pronunciation!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () {},
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (wordData.partOfSpeech != null)
                          Chip(
                            label: Text(wordData.partOfSpeech!),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                          ),
                        const SizedBox(width: 8),
                        if (wordData.cefr != null)
                          Chip(
                            label: Text(wordData.cefr!),
                            backgroundColor: theme.colorScheme.tertiaryContainer,
                            labelStyle: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ...definitions.map((def) => _DefinitionSection(definition: def, repo: repo)),
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }
}

class _DefinitionSection extends StatelessWidget {
  final Definition definition;
  final WordRepository repo;
  
  const _DefinitionSection({required this.definition, required this.repo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simple Meaning',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            definition.meaning,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (definition.simpleEnglish != null) ...[
            const SizedBox(height: 16),
            Text(
              'In Simple English',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              definition.simpleEnglish!,
              style: theme.textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 24),
          FutureBuilder<List<Example>>(
            future: repo.getDefinitionExamples(definition.id),
            builder: (context, exampleSnapshot) {
              final examples = exampleSnapshot.data ?? [];
              if (examples.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...examples.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '“${ex.sentence}”',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )),
                ],
              );
            }
          )
        ],
      ),
    );
  }
}
