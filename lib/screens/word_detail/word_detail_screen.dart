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
    final displayWord = entry?.word ?? 'reluctant';
    final phonetic = entry?.phonetic ?? '/rɪˈlʌktənt/';
    final pos = entry?.partOfSpeech ?? 'adjective';
    final meaning = entry?.meaning ?? 'Not wanting to do something.';
    final example = (entry != null && entry!.example.isNotEmpty) ? entry!.example : 'She was reluctant to leave the party.';
    
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
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis_vertical),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWordHeader(context, displayWord, phonetic, pos),
            const SizedBox(height: 24),
            _buildMeaningCard(context, meaning),
            const SizedBox(height: 16),
            _buildExampleCard(context, example),
            const SizedBox(height: 24),
            _buildSaveButton(context),
            const SizedBox(height: 48), // Padding for bottom scrolling
          ],
        ),
      ),
    );
  }

  Widget _buildWordHeader(BuildContext context, String word, String phonetic, String pos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 40,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              phonetic.isNotEmpty ? phonetic : '/.../',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.speaker_2, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTag(context, pos, AppColors.border),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor, width: 1.5),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildMeaningCard(BuildContext context, String meaning) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.lightbulb, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'What it means',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meaning,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(BuildContext context, String example) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.quote_bubble, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Example',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const Icon(CupertinoIcons.speaker_2, size: 20, color: AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"$example"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(CupertinoIcons.bookmark),
        label: const Text('Save Word'),
      ),
    );
  }
}