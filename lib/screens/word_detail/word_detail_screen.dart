import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class WordDetailScreen extends StatelessWidget {
  final String? word;
  
  const WordDetailScreen({super.key, this.word});

  @override
  Widget build(BuildContext context) {
    final displayWord = word ?? 'reluctant';
    
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
            _buildWordHeader(context, displayWord),
            const SizedBox(height: 24),
            _buildMeaningCard(context),
            const SizedBox(height: 16),
            _buildSimpleEnglishCard(context),
            const SizedBox(height: 16),
            _buildExampleCard(context),
            const SizedBox(height: 24),
            _buildSaveButton(context),
            const SizedBox(height: 24),
            _buildInContextCard(context),
            const SizedBox(height: 16),
            _buildHowToUseIt(context),
            const SizedBox(height: 48), // Padding for bottom scrolling
          ],
        ),
      ),
    );
  }

  Widget _buildWordHeader(BuildContext context, String word) {
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
              '/rɪˈlʌktənt/',
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
            _buildTag(context, 'adjective', AppColors.border),
            const SizedBox(width: 8),
            _buildTag(context, 'B2', AppColors.border),
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

  Widget _buildMeaningCard(BuildContext context) {
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
            'Not wanting to do something.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleEnglishCard(BuildContext context) {
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
              const Icon(CupertinoIcons.doc_text, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'In simple English',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t really want to do it, but you may do it anyway.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(BuildContext context) {
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
            '"She was reluctant to leave the party."',
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

  Widget _buildInContextCard(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.book, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'In this context',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const Icon(CupertinoIcons.ellipsis_vertical, size: 20, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'From The Great Gatsby • Chapter 3',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            '"He was reluctant to enter the house."',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softYellow.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Here, reluctant means:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'He didn\'t really want to enter.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textSecondary),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHowToUseIt(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.doc_text, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'How to use it',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const Icon(CupertinoIcons.ellipsis_vertical, size: 20, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Grammar patterns',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _buildGrammarPattern(context, 'reluctant + to + verb', 'She was reluctant to speak.'),
          const Divider(height: 32),
          _buildGrammarPattern(context, 'reluctant + noun', 'a reluctant participant.'),
        ],
      ),
    );
  }

  Widget _buildGrammarPattern(BuildContext context, String pattern, String example) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pattern,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                example,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textSecondary),
      ],
    );
  }
}