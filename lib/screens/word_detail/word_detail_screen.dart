import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../data/models/dictionary_entry.dart';

class WordDetailScreen extends StatelessWidget {
  final DictionaryEntry? entry;

  const WordDetailScreen({super.key, this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return const Scaffold(
        body: Center(child: Text('Word not found.')),
      );
    }

    final simpleMeaning = entry!.meanings.isNotEmpty
        ? entry!.meanings.first.split(';').first
        : 'A word to describe something.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text('Word Detail'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bookmark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoreHeader(context),
            const SizedBox(height: 24),
            
            // MEANING SECTION
            _buildSimpleEnglishCard(context, simpleMeaning),
            const SizedBox(height: 16),
            if (entry!.meanings.isNotEmpty) _buildMeaningsCard(context, entry!.meanings),
            const SizedBox(height: 16),
            if (entry!.examples.isNotEmpty) _buildExampleCard(context, entry!.examples),
            const SizedBox(height: 16),
            _buildContextCard(context, entry!.word, simpleMeaning),
            const SizedBox(height: 16),
            
            // GRAMMAR & USAGE
            if (entry!.grammaticalInfo.isNotEmpty || entry!.registers.isNotEmpty || entry!.domains.isNotEmpty)
               _buildUsageGrammarSection(context),
            const SizedBox(height: 32),

            // RELATIONSHIPS
            if (entry!.inflections.isNotEmpty) _buildWordFamily(context),
            if (entry!.synonyms.isNotEmpty || entry!.antonyms.isNotEmpty) _buildRelationships(context),
            
            // LINGUISTIC
            if (entry!.etymology.isNotEmpty) const SizedBox(height: 24),
            if (entry!.etymology.isNotEmpty) _buildEtymologySection(context),
            
            const SizedBox(height: 32),
            _buildSaveButton(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCoreHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry!.word,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 40,
                height: 1.1,
              ),
        ),
        if (entry!.syllables.length > 1) ...[
          const SizedBox(height: 4),
          Text(
            entry!.syllables.join(' · '),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2.0,
                ),
          ),
        ],
        if (entry!.phonetic.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                entry!.phonetic,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.speaker_2, size: 20),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(context, entry!.partOfSpeech, AppColors.primaryPurple, isSolid: true),
            ...entry!.inflections.take(3).map((inf) => _buildChip(context, inf, AppColors.border)),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String text, Color color, {bool isSolid = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSolid ? color : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSolid ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildSimpleEnglishCard(BuildContext context, String simpleMeaning) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.lightbulb, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'In Simple English',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            simpleMeaning.replaceFirst(simpleMeaning[0], simpleMeaning[0].toUpperCase()) + '.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningsCard(BuildContext context, List<String> meanings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meanings.length > 1 ? 'Definitions' : 'Definition',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          ...meanings.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (meanings.length > 1)
                    Text(
                      '${e.key + 1}. ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  Expanded(
                    child: Text(
                      e.value.replaceFirst(e.value[0], e.value[0].toUpperCase()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExampleCard(BuildContext context, List<String> examples) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.quote_bubble, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                examples.length > 1 ? 'Examples' : 'Example',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...examples.take(3).map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '"${ex.replaceFirst(ex[0], ex[0].toUpperCase())}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContextCard(BuildContext context, String word, String simpleMeaning) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.book, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'In This Context',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
              children: [
                const TextSpan(text: 'Here, "'),
                TextSpan(
                  text: word,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                ),
                const TextSpan(text: '" means '),
                TextSpan(text: simpleMeaning.toLowerCase()),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageGrammarSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry!.grammaticalInfo.isNotEmpty) ...[
          Text('Grammar', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: entry!.grammaticalInfo.map((info) => _buildMinimalTag(context, info)).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (entry!.registers.isNotEmpty || entry!.domains.isNotEmpty) ...[
          Text('Usage & Domains', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ...entry!.registers.map((r) => _buildMinimalTag(context, r, color: AppColors.softPeach)),
              ...entry!.domains.map((d) => _buildMinimalTag(context, d, color: AppColors.softBlue)),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildMinimalTag(BuildContext context, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? AppColors.softGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildWordFamily(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Word Family',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          [entry!.word, ...entry!.inflections].join('  ·  '),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRelationships(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry!.synonyms.isNotEmpty) ...[
          Text('Synonyms', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            entry!.synonyms.join('  ·  '),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
        ],
        if (entry!.antonyms.isNotEmpty) ...[
          Text('Antonyms', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            entry!.antonyms.join('  ·  '),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildEtymologySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etymology / History',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Text(
          entry!.etymology,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(CupertinoIcons.heart),
        label: const Text('Save Word'),
      ),
    );
  }
}